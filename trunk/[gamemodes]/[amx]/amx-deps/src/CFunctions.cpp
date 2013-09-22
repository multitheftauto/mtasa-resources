/*********************************************************
*
*  Multi Theft Auto: San Andreas - Deathmatch
*
*  ml_base, External lua add-on module
*
*  Copyright © 2003-2008 MTA.  All Rights Reserved.
*
*  Grand Theft Auto is © 2002-2003 Rockstar North
*
*  THE FOLLOWING SOURCES ARE PART OF THE MULTI THEFT
*  AUTO SOFTWARE DEVELOPMENT KIT AND ARE RELEASED AS
*  OPEN SOURCE FILES. THESE FILES MAY BE USED AS LONG
*  AS THE DEVELOPER AGREES TO THE LICENSE THAT IS
*  PROVIDED WITH THIS PACKAGE.
*
*********************************************************/

#include "StdInc.h"

using namespace std;
using namespace boost::filesystem;

extern ILuaModuleManager10 *pModuleManager;

int amx_SAMPInit(AMX *amx);

typedef int  (STDCALL AmxLoad_t)   (AMX *);
typedef int  (STDCALL AmxUnload_t) (AMX *);
typedef bool (STDCALL Load_t)      (void**);

extern void *pluginInitData[];
extern lua_State *mainVM;

map< AMX *, AMXPROPS > loadedAMXs;
map< AMX *, map< int, sqlite3 * > > loadedDBs;		// amx => (dbID => db)
map< string, HMODULE > loadedPlugins;

AMX *suspendedAMX = NULL;

// amxLoadPlugin(pluginName)
int CFunctions::amxLoadPlugin(lua_State *luaVM) {
	static const char *requiredExports[] = { "Load", "AmxLoad", "AmxUnload", "Unload", 0 };

	const char *pluginName = luaL_checkstring(luaVM, 1);
	if(!pluginName || loadedPlugins.find(pluginName) != loadedPlugins.end() || !isSafePath(pluginName)) {
		lua_pushboolean(luaVM, 0);
		return 1;
	}

	string pluginPath = "mods/deathmatch/resources/amx/plugins/";
	pluginPath += pluginName;
	#ifdef WIN32
		pluginPath += ".dll";
	#else
		pluginPath += ".so";
	#endif

	HMODULE hPlugin = loadLib(pluginPath.c_str());
	if(!hPlugin) {
		lua_pushboolean(luaVM, 0);
		return 1;
	}

	bool hasAllReqFns = true;
	for(const char **fnName = requiredExports; *fnName; fnName++) {
		if(!getProcAddr(hPlugin, *fnName)) {
			pModuleManager->ErrorPrintf("Plugin \"%s\" does not export required function %s\n", pluginName, *fnName);
			hasAllReqFns = false;
		}
	}
	if(!hasAllReqFns) {
		freeLib(hPlugin);
		lua_pushboolean(luaVM, 0);
		return 1;
	}

	printf("Loading plugin %s\n", pluginName);
	Load_t *pfnLoad = (Load_t *)getProcAddr(hPlugin, "Load");
	pfnLoad(pluginInitData);

	loadedPlugins[pluginName] = hPlugin;

	lua_pushboolean(luaVM, 1);
	return 1;
}

// amxIsPluginLoaded(pluginName)
int CFunctions::amxIsPluginLoaded(lua_State *luaVM) {
	const char *pluginName = luaL_checkstring(luaVM, 1);
	if(loadedPlugins.find(pluginName) != loadedPlugins.end())
		lua_pushboolean(luaVM, 1);
	else
		lua_pushboolean(luaVM, 0);
	return 1;
}

// amxLoad(resName, amxName)
int CFunctions::amxLoad(lua_State *luaVM) {
	const char *resName = luaL_checkstring(luaVM, 1);
	const char *amxName = luaL_checkstring(luaVM, 2);
	if(!resName || !isSafePath(resName) || !amxName || !isSafePath(amxName)) {
		lua_pushboolean(luaVM, 0);
		return 1;
	}
	
	path amxPath = path("mods/deathmatch/resources/[gamemodes]/[amx]/") / resName / amxName;

	// Load .amx
	AMX *amx = new AMX;
	int err = aux_LoadProgram(amx, amxPath.string().c_str(), NULL);
	if(err != AMX_ERR_NONE) {
		delete amx;
		lua_pushboolean(luaVM, 0);
		return 1;
	}

	// Register sa-mp and plugin natives
	amx_CoreInit(amx);
	amx_ConsoleInit(amx);
	amx_FloatInit(amx);
	amx_StringInit(amx);
	amx_TimeInit(amx);
	amx_FileInit(amx);
	err = amx_SAMPInit(amx);
	for(map< string, HMODULE >::iterator it = loadedPlugins.begin(); it != loadedPlugins.end(); it++) {
		AmxLoad_t* pfnAmxLoad = (AmxLoad_t*)getProcAddr(it->second, "AmxLoad");
		err = pfnAmxLoad(amx);
	}

	if(err != AMX_ERR_NONE) {
		pModuleManager->ErrorPrintf("%s can't be loaded due to missing functions:\n", amxName);
		AMX_HEADER *header = (AMX_HEADER *)amx->base;
		AMX_FUNCSTUBNT *func = (AMX_FUNCSTUBNT *)((BYTE *)amx->base + header->natives);
		while( func != ((AMX_FUNCSTUBNT *)((BYTE *)amx->base + header->libraries)) ) {
			if(!func->address)
				pModuleManager->ErrorPrintf("  %s\n", (char *)amx->base + func->nameofs);
			func++;
		}
		aux_FreeProgram(amx);
		delete amx;
		lua_pushboolean(luaVM, 0);
		return 1;
	}

	// Save info about the amx
	AMXPROPS props;
	props.filePath = amxPath;
	props.resourceName = resName;
	props.resourceVM = pModuleManager->GetResourceFromName(resName);

	lua_register(props.resourceVM, "pawn", CFunctions::pawn);
	loadedAMXs[amx] = props;
	
	lua_getfield(luaVM, LUA_REGISTRYINDEX, "amx");
	lua_getfield(luaVM, -1, resName);
	if(lua_isnil(luaVM, -1)) {
        lua_newtable(luaVM);
		lua_setfield(luaVM, -3, resName);
	}

	// All done
	lua_pushlightuserdata(luaVM, amx);
	return 1;
}

// amxCall(amxptr, fnName|fnIndex, arg1, arg2, ...)
int CFunctions::amxCall(lua_State *luaVM) {
	AMX *amx = (AMX *)lua_touserdata(luaVM, 1);
	if(!amx || loadedAMXs.find(amx) == loadedAMXs.end()) {
		pModuleManager->ErrorPrintf("amxCall: invalid amx parameter\n");
		lua_pushboolean(luaVM, 0);
		return 1;
	}

	// Get the function to call
	int fnIndex;
	if(lua_isnumber(luaVM, 2)) {
		fnIndex = (int)lua_tonumber(luaVM, 2);
	} else if(amx_FindPublic(amx, luaL_checkstring(luaVM, 2), &fnIndex) != AMX_ERR_NONE) {
		lua_pushboolean(luaVM, 0);
		return 1;
	}

	// Collect the arguments
	vector<cell> stringsToRelease;
	for(int i = lua_gettop(luaVM); i > 2; i--) {
		switch(lua_type(luaVM, i)) {
			case LUA_TNIL: {
				amx_Push(amx, 0);
				break;
			}
			case LUA_TBOOLEAN: {
				amx_Push(amx, lua_toboolean(luaVM, i));
				break;
			}
			case LUA_TNUMBER: {
				std::string str = lua_tostring(luaVM, i);
				if(str.find(".")!=std::string::npos) 
				{
					float fval = lua_tonumber(luaVM, i);
					cell val = *(cell*)&fval;
					amx_Push(amx, val);
				}
				else
				{
					amx_Push(amx, (cell)lua_tonumber(luaVM, i));
				}
				break;
			}
			case LUA_TSTRING: {
				cell amxStringAddr;
				cell *physStringAddr;
				std::string newstr = ToOriginalCP(lua_tostring(luaVM, i));
				amx_PushString(amx, &amxStringAddr, &physStringAddr, newstr.c_str(), 0, 0);
				stringsToRelease.push_back(amxStringAddr);
				break;
			}
			default: {
				amx_Push(amx, 0);
				break;
			}
		}
	}

	// Do the call
	cell ret;
	int err = amx_Exec(amx, &ret, fnIndex);
	// Release string arguments
	for(vector<cell>::iterator it = stringsToRelease.begin(); it != stringsToRelease.end(); it++) {
		amx_Release(amx, *it);
	}
	if(err != AMX_ERR_NONE) {
		if(err == AMX_ERR_SLEEP)
			lua_pushstring(luaVM, "suspended");
		else
			lua_pushboolean(luaVM, 0);
		return 1;
	}
	
	// Return value
	lua_pushnumber(luaVM, ret);
	return 1;
}

// amxMTReadDATCell(t, addr)
// __index metamethod
int CFunctions::amxMTReadDATCell(lua_State *luaVM) {
	luaL_checktype(luaVM, 1, LUA_TTABLE);
	cell addr = (cell)luaL_checknumber(luaVM, 2);
	lua_getfield(luaVM, 1, "amx");
	AMX *amx = (AMX *)lua_touserdata(luaVM, -1);
	if(!amx || loadedAMXs.find(amx) == loadedAMXs.end())
		return 0;
	cell *physaddr;
	amx_GetAddr(amx, addr, &physaddr);
	if(!physaddr)
		return 0;
	lua_pushnumber(luaVM, *physaddr);
	return 1;
}

// amxMTWriteCell(t, addr, value)
// __newindex metamethod
int CFunctions::amxMTWriteDATCell(lua_State *luaVM) {
	luaL_checktype(luaVM, 1, LUA_TTABLE);
	cell addr = (cell)luaL_checknumber(luaVM, 2);
	cell value = (cell)luaL_checknumber(luaVM, 3);
	lua_getfield(luaVM, 1, "amx");
	AMX *amx = (AMX *)lua_touserdata(luaVM, -1);
	if(!amx || loadedAMXs.find(amx) == loadedAMXs.end())
		return 0;
	cell *physaddr;
	amx_GetAddr(amx, addr, &physaddr);
	if(!physaddr)
		return 0;
	*physaddr = value;
	return 0;
}

// amxReadString(amxptr, addr, maxlen)
int CFunctions::amxReadString(lua_State *luaVM) {
	AMX *amx = (AMX *)lua_touserdata(luaVM, 1);
	if(!amx || loadedAMXs.find(amx) == loadedAMXs.end())
		return 0;
	const cell addr = (cell)lua_tonumber(luaVM, 2);
	lua_pushamxstring(luaVM, amx, addr);
	return 1;
}

// amxWriteString(amxptr, addr, str)
int CFunctions::amxWriteString(lua_State *luaVM) {
	AMX *amx = (AMX *)lua_touserdata(luaVM, 1);
	if(!amx || loadedAMXs.find(amx) == loadedAMXs.end())
		return 0;
	const cell addr = (cell)lua_tonumber(luaVM, 2);
	const char *str = luaL_checkstring(luaVM, 3);
	std::string newstr = ToOriginalCP(str);
	cell* physaddr;
	amx_GetAddr(amx, addr, &physaddr);
	if(!physaddr)
		return 0;
	amx_SetString(physaddr, newstr.c_str(), 0, 0, UNLIMITED);
	lua_pushboolean(luaVM, 1);
	return 1;
}

// amxUnload(amxptr)
int CFunctions::amxUnload(lua_State *luaVM) {
	AMX *amx = (AMX *)lua_touserdata(luaVM, 1);
	if(!amx || loadedAMXs.find(amx) == loadedAMXs.end()) {
		pModuleManager->ErrorPrintf("amxUnload: invalid amx parameter\n");
		lua_pushboolean(luaVM, 0);
		return 1;
	}
	// Call all plugins' AmxUnload function
	for(map< string, HMODULE >::iterator piIt = loadedPlugins.begin(); piIt != loadedPlugins.end(); piIt++) {
		AmxUnload_t *pfnAmxUnload = (AmxUnload_t*)getProcAddr(piIt->second, "AmxUnload");
		pfnAmxUnload(amx);
	}
	// Close any open databases
	if(loadedDBs.find(amx) != loadedDBs.end()) {
		for(map< int, sqlite3 * >::iterator dbIt = loadedDBs[amx].begin(); dbIt != loadedDBs[amx].end(); dbIt++)
			sqlite3_close(dbIt->second);
		loadedDBs.erase(amx);
	}
	// Unload
	aux_FreeProgram(amx);
	lua_getfield(luaVM, LUA_REGISTRYINDEX, "amx");
	lua_pushnil(luaVM);
	lua_setfield(luaVM, -2, loadedAMXs[amx].resourceName.c_str());
	loadedAMXs.erase(amx);
	delete amx;
	lua_pushboolean(luaVM, 1);
	return 1;
}

// amxUnloadAllPlugins()
int CFunctions::amxUnloadAllPlugins(lua_State *luaVM) {
	for(map< string, HMODULE >::iterator it = loadedPlugins.begin(); it != loadedPlugins.end(); it++)
		freeLib(it->second);
	loadedPlugins.clear();

	lua_pushboolean(luaVM, 1);
	return 1;
}

// amxRegisterLuaPrototypes({ [fnName] = {'s', 'i', 'f'}, ... })
int CFunctions::amxRegisterLuaPrototypes(lua_State *luaVM) {
	luaL_checktype(luaVM, 1, LUA_TTABLE);
	int mainTop = lua_gettop(mainVM);

	string resName;
	pModuleManager->GetResourceName(luaVM, resName);
	lua_getfield(mainVM, LUA_REGISTRYINDEX, "amx");
	lua_getfield(mainVM, -1, resName.c_str());
	if(lua_isnil(mainVM, -1)) {
		lua_pop(mainVM, 1);
		lua_newtable(mainVM);
		lua_pushvalue(mainVM, -1);
		lua_setfield(mainVM, -3, resName.c_str());
	}

	lua_newtable(mainVM);
	lua_pushnil(luaVM);
	while(lua_next(luaVM, 1)) {
		if(!lua_istable(luaVM, -1)) {
			lua_settop(mainVM, mainTop);
			return luaL_error(luaVM, "amxRegisterLuaPrototypes: table expected as prototype for \"%s\"", lua_tostring(luaVM, -2));
		}

		lua_getglobal(luaVM, "string");
		lua_getfield(luaVM, -1, "match");
		lua_remove(luaVM, -2);
		lua_pushvalue(luaVM, -3);
		lua_pushstring(luaVM, "([^:]+):?(.*)");
		lua_pcall(luaVM, 2, 2, 0);
		if(lua_objlen(luaVM, -1) == 0) {
			// No return type
			lua_insert(luaVM, -2);
		}

		lua_pushvalue(luaVM, -1);
		lua_gettable(luaVM, LUA_GLOBALSINDEX);
		if(!lua_isfunction(luaVM, -1)) {
			lua_settop(mainVM, mainTop);
			return luaL_error(luaVM, "amxRegisterLuaPrototypes: no function named \"%s\" exists", lua_tostring(luaVM, -3));
		}
		lua_pop(luaVM, 1);

		lua_pushremotevalue(mainVM, luaVM, -1);
		lua_pushremotevalue(mainVM, luaVM, -3);
		if(lua_objlen(luaVM, -2) > 0) {
			lua_newtable(mainVM);
			lua_pushnumber(mainVM, 1);
			lua_pushremotevalue(mainVM, luaVM, -2);
			lua_settable(mainVM, -3);
			lua_setfield(mainVM, -2, "ret");
		}
		lua_settable(mainVM, -3);
		lua_pop(luaVM, 3);
	}

	lua_setfield(mainVM, -2, "luaprototypes");
	lua_settop(mainVM, mainTop);
	lua_pushboolean(luaVM, 1);
	return 1;
}

// pawn(fnName, ...)
int CFunctions::pawn(lua_State *luaVM) {
	vector<AMX *> amxs = getResourceAMXs(luaVM);
	if(amxs.empty()) {
		lua_pushboolean(luaVM, 0);
		return 1;
	}

	const char *fnName = luaL_checkstring(luaVM, 1);
	int numFnParams = lua_gettop(luaVM) - 1;

	int fnIndex;
	AMX *amx = NULL;
	for(vector<AMX *>::iterator it = amxs.begin(); it != amxs.end(); it++) {
		if(amx_FindPublic(*it, fnName, &fnIndex) == AMX_ERR_NONE) {
			amx = *it;
			break;
		}
	}
	if(!amx)
		return luaL_error(luaVM, "No Pawn function named %s exists", fnName);
	
	int mainTop = lua_gettop(mainVM);

	string resName;
	pModuleManager->GetResourceName(luaVM, resName);
	lua_getfield(mainVM, LUA_REGISTRYINDEX, "amx");
	lua_getfield(mainVM, -1, resName.c_str());
	if(lua_isnil(mainVM, -1)) {
		lua_settop(mainVM, mainTop);
		return luaL_error(luaVM, "pawn: resource %s is not an amx resource", resName.c_str());
	}
	lua_getfield(mainVM, -1, "pawnprototypes");
	if(lua_isnil(mainVM, -1)) {
		lua_settop(mainVM, mainTop);
		return luaL_error(luaVM, "pawn: resource %s does not have any registered Pawn functions - see amxRegisterPawnPrototypes", resName.c_str());
	}
	lua_getfield(mainVM, -1, fnName);
	if(lua_isnil(mainVM, -1)) {
		lua_settop(mainVM, mainTop);
		return luaL_error(luaVM, "pawn: function %s is not registered", lua_tostring(luaVM, 1));
	}

	lua_remove(mainVM, -2);
	lua_remove(mainVM, -2);
	lua_remove(mainVM, -2);

	lua_pushcfunction(mainVM, CFunctions::amxCall);
	lua_pushlightuserdata(mainVM, amx);
	lua_pushnumber(mainVM, fnIndex);
	lua_getglobal(mainVM, "unpack");
	lua_getglobal(mainVM, "argsToSAMP");
	lua_pushlightuserdata(mainVM, amx);
	lua_pushvalue(mainVM, -7);
	for(int i = 0; i < numFnParams; i++) {
		lua_pushremotevalue(mainVM, luaVM, 2 + i);
	}
	lua_pcall(mainVM, 2 + numFnParams, 1, 0);		// argsToSAMP
	lua_pcall(mainVM, 1, numFnParams, 0);			// unpack
	if(lua_pcall(mainVM, 2 + numFnParams, 1, 0))	// amxCall
		return luaL_error(luaVM, lua_tostring(mainVM, -1));

	lua_getfield(mainVM, -2, "ret");
	if(!lua_isnil(mainVM, -1)) {
		lua_getglobal(mainVM, "argsToMTA");
		lua_pushlightuserdata(mainVM, amx);
		lua_pushvalue(mainVM, -3);
		lua_pushvalue(mainVM, -5);
		lua_pcall(mainVM, 3, 1, 0);
		lua_pushnumber(mainVM, 1);
		lua_gettable(mainVM, -2);
	}

	lua_pushremotevalue(luaVM, mainVM, -1);
	lua_settop(mainVM, mainTop);
	return 1;
}

// amxVersion()
int CFunctions::amxVersion(lua_State *luaVM) {
	lua_pushnumber(luaVM, MODULE_VERSION);
	return 1;
}

// amxVersionString()
int CFunctions::amxVersionString(lua_State *luaVM) {
	lua_pushstring(luaVM, MODULE_VERSIONSTRING);
	return 1;
}

// sqlite3OpenDB(amx, dbName)
int CFunctions::sqlite3OpenDB(lua_State *luaVM) {
	AMX *amx = (AMX *)lua_touserdata(luaVM, 1);
	const char *dbName = luaL_checkstring(luaVM, 2);
	if(!amx || loadedAMXs.find(amx) == loadedAMXs.end() || !isSafePath(dbName)) {
		lua_pushboolean(luaVM, 0);
		return 1;
	}
	// Open the database
	string dbPath = getScriptFilePath(amx, dbName);
	if(dbPath.empty()) {
		lua_pushboolean(luaVM, 0);
		return 1;
	}
	sqlite3 *db;
	sqlite3_open(dbPath.c_str(), &db);
	if(!db) {
		lua_pushboolean(luaVM, 0);
		return 1;
	}
	// Check if amx is already present in loadedDBs
	if(loadedDBs.find(amx) == loadedDBs.end())
		loadedDBs[amx] = map< int, sqlite3 *>();
	// Find a free ID
	int dbID = 1;
	for(; loadedDBs[amx].find(dbID) != loadedDBs[amx].end(); dbID++);
	loadedDBs[amx][dbID] = db;
	lua_pushnumber(luaVM, dbID);
	return 1;
}

// sqlite3Query(amx, dbID, query)
// if successful and SELECT, returns:
// {
//    columns = { colname1, colname2, ... },
//    [1] = { coldata1, coldata2, ... },
//    [2] = ...
// }
// if successful and other query, returns true
// on failure, returns false
int CFunctions::sqlite3Query(lua_State *luaVM) {
	AMX *amx = (AMX *)lua_touserdata(luaVM, 1);
	int dbID = (int)luaL_checknumber(luaVM, 2);
	const char *query = luaL_checkstring(luaVM, 3);
	if(!amx || loadedDBs.find(amx) == loadedDBs.end() || loadedDBs[amx].find(dbID) == loadedDBs[amx].end() || !query) {
		lua_pushboolean(luaVM, 0);
		return 1;
	}

	sqlite3 *db = loadedDBs[amx][dbID];
	sqlite3_stmt *stmt;
	if(sqlite3_prepare(db, query, -1, &stmt, NULL) != SQLITE_OK) {
		lua_pushboolean(luaVM, 0);
		return 1;
	}
	int colcount = sqlite3_column_count(stmt);
	if(colcount > 0) {
		int res;
		// SELECT query
		// create main table to return
		lua_newtable(luaVM);
		// create table with column names
		lua_newtable(luaVM);
		for(int i = 0; i < colcount; i++) {
			lua_pushnumber(luaVM, i + 1);
			lua_pushstring(luaVM, sqlite3_column_name(stmt, i));
			lua_settable(luaVM, -3);
		}
		lua_setfield(luaVM, -2, "columns");

		// Read rows
		int row = 1;
		while((res = sqlite3_step(stmt)) == SQLITE_ROW) {
			lua_pushnumber(luaVM, row);
			lua_newtable(luaVM);
			for(int i = 0; i < colcount; i++) {
				lua_pushnumber(luaVM, i + 1);
				lua_pushstring(luaVM, (const char *)sqlite3_column_text(stmt, i));
				lua_settable(luaVM, -3);
			}
			lua_settable(luaVM, -3);
			row++;
		}
		if(res == SQLITE_ERROR) {
			lua_pop(luaVM, 1);
			lua_pushboolean(luaVM, 0);
		}
	} else {
		// Other kind of query
		if(sqlite3_step(stmt) == SQLITE_ERROR)
			lua_pushboolean(luaVM, 0);
		else
			lua_pushboolean(luaVM, 1);
	}

	sqlite3_finalize(stmt);
	return 1;
}

// sqlite3CloseDB(amx, dbID)
int CFunctions::sqlite3CloseDB(lua_State *luaVM) {
	AMX *amx = (AMX *)lua_touserdata(luaVM, 1);
	int dbID = (int)luaL_checknumber(luaVM, 2);
	if(!amx || loadedDBs.find(amx) == loadedDBs.end() || loadedDBs[amx].find(dbID) == loadedDBs[amx].end()) {
		lua_pushboolean(luaVM, 0);
		return 1;
	}

	sqlite3 *db = loadedDBs[amx][dbID];
	sqlite3_close(db);
	loadedDBs[amx].erase(dbID);
	if(loadedDBs[amx].size() == 0)
		loadedDBs.erase(amx);
	lua_pushboolean(luaVM, 1);
	return 1;
}

// cell2float(cell)
int CFunctions::cell2float(lua_State *luaVM) {
	cell c = (cell)luaL_checknumber(luaVM, 1);
	lua_pushnumber(luaVM, *(float *)&c);
	return 1;
}

// float2cell(float)
int CFunctions::float2cell(lua_State *luaVM) {
	float f = (float)luaL_checknumber(luaVM, 1);
	lua_pushnumber(luaVM, *(cell *)&f);
	return 1;
}
