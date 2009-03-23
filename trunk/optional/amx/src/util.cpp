#include "StdInc.h"

using namespace std;
using namespace boost::filesystem;

extern map < AMX *, AMXPROPS > loadedAMXs;

#ifdef WIN32

	int setenv(const char* name, const char* value, int overwrite) {
		((void)overwrite);
		return SetEnvironmentVariable(name, value) ? 0 : -1;
	}

#else

	void *getProcAddr ( HMODULE hModule, const char *szProcName )
	{
		char *szError = NULL;
		dlerror ();
		void *pFunc = dlsym ( hModule, szProcName );
		if ( ( szError = dlerror () ) != NULL )
			return NULL;
		return pFunc;
	}

#endif

void lua_pushamxstring(lua_State* luaVM, AMX* amx, cell *physaddr) {
	if(!physaddr) {
		lua_pushnil(luaVM);
		return;
	}

	int strLen;
	amx_StrLen(physaddr, &strLen);

	char *str = new char[strLen+1];
	amx_GetString(str, physaddr, 0, strLen+1);
	lua_pushlstring(luaVM, str, strLen);
	delete[] str;
}

void lua_pushamxstring(lua_State *luaVM, AMX *amx, cell addr) {
	cell *physaddr;

	amx_GetAddr(amx, addr, &physaddr);
	lua_pushamxstring(luaVM, amx, physaddr);
}

void lua_pushremotevalue(lua_State *localVM, lua_State *remoteVM, int index, bool toplevel) {
	bool seenTableList = false;
	
	switch(lua_type(remoteVM, index)) {
		case LUA_TNIL: {
			lua_pushnil(localVM);
			break;
		}
		case LUA_TBOOLEAN: {
			lua_pushboolean(localVM, lua_toboolean(remoteVM, index));
			break;
		}
		case LUA_TNUMBER: {
			lua_pushnumber(localVM, lua_tonumber(remoteVM, index));
			break;
		}
		case LUA_TSTRING: {
			size_t len;
			const char *str = lua_tolstring(remoteVM, index, &len);
			lua_pushlstring(localVM, str, len);
			break;
		}
		case LUA_TTABLE: {
			if(toplevel && !seenTableList) {
				lua_newtable(localVM);
				lua_setfield(localVM, LUA_REGISTRYINDEX, "_dstSeenTables");
				lua_newtable(remoteVM);
				lua_setfield(remoteVM, LUA_REGISTRYINDEX, "_srcSeenTables");
				seenTableList = true;
			}

			if(index < 0)
				index = lua_gettop(remoteVM) + index + 1;

			lua_getfield(remoteVM, LUA_REGISTRYINDEX, "_srcSeenTables");

			lua_pushvalue(remoteVM, index);
			lua_gettable(remoteVM, -2);
			if(!lua_isnil(remoteVM, -1)) {
				lua_Number tblNum = lua_tonumber(remoteVM, -1);
				lua_pop(remoteVM, 2);
				lua_getfield(localVM, LUA_REGISTRYINDEX, "_dstSeenTables");
				lua_pushnumber(localVM, tblNum);
				lua_gettable(localVM, -2);
				lua_remove(localVM, -2);
				break;
			}
			lua_pop(remoteVM, 1);

			lua_newtable(localVM);
			lua_getfield(localVM, LUA_REGISTRYINDEX, "_dstSeenTables");
			lua_Number tblNum = lua_objlen(localVM, -1) + 1;
			lua_pushnumber(localVM, tblNum);
			lua_pushvalue(localVM, -3);
			lua_settable(localVM, -3);
			lua_pop(localVM, 1);

			lua_pushvalue(remoteVM, index);
			lua_pushnumber(remoteVM, tblNum);
			lua_settable(remoteVM, -3);
			lua_pop(remoteVM, 1);

			lua_pushnil(remoteVM);
			while(lua_next(remoteVM, index)) {
				lua_pushremotevalue(localVM, remoteVM, -2, false);
				lua_pushremotevalue(localVM, remoteVM, -1, false);
				lua_settable(localVM, -3);
				lua_pop(remoteVM, 1);
			}
			break;
		}
		case LUA_TUSERDATA:
		case LUA_TLIGHTUSERDATA: {
			lua_pushlightuserdata(localVM, lua_touserdata(remoteVM, index));
			break;
		}
		default: {
			lua_pushboolean(localVM, 0);
			break;
		}
	}
	if(toplevel && seenTableList) {
		lua_pushnil(localVM);
		lua_setfield(localVM, LUA_REGISTRYINDEX, "_dstSeenTables");
		lua_pushnil(remoteVM);
		lua_setfield(remoteVM, LUA_REGISTRYINDEX, "_srcSeenTables");
	}
}

void lua_pushremotevalues(lua_State *localVM, lua_State *remoteVM, int num) {
	for(int i = -num; i < 0; i++) {
		lua_pushremotevalue(localVM, remoteVM, i);
	}
}

vector<AMX *> getResourceAMXs(lua_State *luaVM) {
	vector<AMX *> amxs;
	for(map< AMX *, AMXPROPS >::iterator it = loadedAMXs.begin(); it != loadedAMXs.end(); it++) {
		if(it->second.resourceVM == luaVM)
			amxs.push_back(it->first);
	}
	return amxs;
}

string getScriptFilePath(AMX *amx, const char *filename) {
	if(!isSafePath(filename) || loadedAMXs.find(amx) == loadedAMXs.end())
		return string();

	// First check if it exists in the resource folder
	path respath = loadedAMXs[amx].filePath;
	respath = respath.remove_leaf() / filename;
	if(exists(respath))
		return respath.string();

	// Then check if it exists in the main scriptfiles folder
	path scriptfilespath = path("mods/deathmatch/resources/amx/scriptfiles") / filename;
	if(exists(scriptfilespath))
		return scriptfilespath.string();

	// Otherwise default to amx's resource folder - make sure the folder
	// where the file is expected exists
	path folder = respath;
	folder.remove_leaf();
	create_directories(folder);
	return respath.string();
}

extern "C" char* getScriptFilePath(AMX *amx, char *dest, const char *filename, size_t destsize) {
	if(!isSafePath(filename))
		return 0;

	string path = getScriptFilePath(amx, filename);
	if(!path.empty() && path.size() < destsize) {
		strcpy(dest, path.c_str());
		return dest;
	} else {
		return 0;
	}
}

bool isSafePath(const char *path) {
	return path && !strstr(path, "..") && !strchr(path, ':') && !strchr(path, '|') && path[0] != '\\' && path[0] != '/';
}
