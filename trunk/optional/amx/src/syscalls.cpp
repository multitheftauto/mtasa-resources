#include "StdInc.h"

using namespace std;

extern ILuaModuleManager10 *pModuleManager;

extern lua_State *mainVM;
extern map < AMX *, AMXPROPS > loadedAMXs;
extern map < string, HMODULE > loadedPlugins;

AMX_NATIVE_INFO *sampNatives = NULL;

static cell AMX_NATIVE_CALL n_samp(AMX *amx, const cell *params) {
	char fnName[128];
	*fnName = 0;
	if(amx_GetNative(amx, *(cell *)(amx->code + amx->cip - sizeof(cell)), fnName) != AMX_ERR_NONE)
		return 0;

	int mainTop = lua_gettop(mainVM);

	lua_getglobal(mainVM, "syscall");
	lua_pushlightuserdata(mainVM, amx);
	lua_pushstring(mainVM, fnName);
	lua_getglobal(mainVM, "g_SAMPSyscallPrototypes");
	lua_getfield(mainVM, -1, fnName);
	lua_remove(mainVM, -2);
	if(lua_isnil(mainVM, -1)) {
		pModuleManager->ErrorPrintf("No implementation for function %s", fnName);
		lua_settop(mainVM, mainTop);
		return 0;
	}
	
	size_t numPrototypeArgs = lua_objlen(mainVM, -1);
	cell numParams = params[0]/sizeof(cell);
	char type;
	for(cell i = 1; i <= numParams; i++) {
		if(i <= numPrototypeArgs) {
			lua_pushnumber(mainVM, i);
			lua_gettable(mainVM, -1 - i);
			type = *lua_tostring(mainVM, -1);
			lua_pop(mainVM, 1);
			switch(type) {
				case 'f':
					lua_pushnumber(mainVM, *(float *)&params[i]);
					break;
				case 's':
					lua_pushamxstring(mainVM, amx, params[i]);
					break;
				default:
					lua_pushnumber(mainVM, params[i]);
					break;
			}
		} else {
			lua_pushnumber(mainVM, params[i]);
		}
	}
    
	if(lua_pcall(mainVM, 3 + numParams, 1, 0) != 0) {
		pModuleManager->ErrorPrintf("%lX %s\n", amx->cip, lua_tostring(mainVM, -1));
		lua_pop(mainVM, 1);
		return 0;
	} else {
		cell result = (cell)lua_tonumber(mainVM, -1);
		lua_pop(mainVM, 1);
		return result;
	}
}

int callLuaMTRead(lua_State *luaVM) {
	luaL_checktype(luaVM, 1, LUA_TTABLE);
	lua_getfield(luaVM, 1, "amx");
	AMX *amx = (AMX *)lua_touserdata(luaVM, -1);
	cell addr = (cell)luaL_checknumber(luaVM, 2);
	if(!amx || loadedAMXs.find(amx) == loadedAMXs.end())
		return 0;
	cell *physaddr;
	amx_GetAddr(amx, addr, &physaddr);
	if(!physaddr)
		return 0;
	
	lua_getfield(luaVM, 1, "pointers");
	luaL_checktype(luaVM, -1, LUA_TTABLE);
	lua_pushnumber(luaVM, addr);
	lua_gettable(luaVM, -2);
	if(!lua_isnil(luaVM, -1)) {
		const char *type = luaL_checkstring(luaVM, -1);
		switch(*type) {
			case 'b': {
				lua_pushboolean(luaVM, *physaddr);
				break;
			}
			case 'i':
			case 'd':
			case 's': {
				lua_pushnumber(luaVM, *physaddr);
				break;
			}
			case 'f': {
				lua_pushnumber(luaVM, *(float *)physaddr);
				break;
			}
			default: {
				lua_getglobal(mainVM, "argsToMTA");
				lua_pushlightuserdata(mainVM, amx);
				lua_newtable(mainVM);
				lua_pushnumber(mainVM, 1);
				lua_pushstring(mainVM, type);
				lua_settable(mainVM, -3);
				lua_pushnumber(mainVM, *physaddr);
				lua_pcall(mainVM, 3, 2, 0);
				if(lua_toboolean(mainVM, -1)) {
					lua_pop(mainVM, 2);
					return 0;
				}
				lua_pop(mainVM, 1);

				lua_pushnumber(mainVM, 1);
				lua_gettable(mainVM, -2);
				lua_pushremotevalue(luaVM, mainVM, -1);
				lua_pop(mainVM, 2);
				break;
			}
		}
	} else {
		lua_pushnumber(luaVM, *physaddr);
	}
	return 1;
}

int callLuaMTWrite(lua_State *luaVM) {
	luaL_checktype(luaVM, 1, LUA_TTABLE);
	lua_getfield(luaVM, 1, "amx");
	AMX *amx = (AMX *)lua_touserdata(luaVM, -1);
	if(!amx || loadedAMXs.find(amx) == loadedAMXs.end())
		return 0;
	cell addr = (cell)luaL_checknumber(luaVM, 2);
	cell *physaddr;
	amx_GetAddr(amx, addr, &physaddr);
	if(!physaddr)
		return 0;
	
	switch(lua_type(luaVM, 3)) {
		case LUA_TNIL: {
			*physaddr = 0;
			break;
		}
		case LUA_TBOOLEAN: {
			*physaddr = lua_toboolean(luaVM, 3);
			break;
		}
		case LUA_TNUMBER: {
			lua_Number num = lua_tonumber(luaVM, 3);
			lua_getfield(luaVM, 1, "pointers");
			luaL_checktype(luaVM, -1, LUA_TTABLE);
			lua_pushnumber(luaVM, addr);
			lua_gettable(luaVM, -2);
			if(!lua_isnil(luaVM, -1)) {
				const char t = *luaL_checkstring(luaVM, -1);
				if(t == 'f') {
					float f = (float)num;
					*physaddr = *(cell *)&f;
				} else {
					*physaddr = (cell)num;
				}
			} else {
				*physaddr = (cell)num;
			}
			lua_pop(luaVM, 2);
			break;
		}
		case LUA_TSTRING: {
			amx_SetString(physaddr, lua_tostring(luaVM, 3), 0, 0, UNLIMITED);
			break;
		}
		case LUA_TLIGHTUSERDATA:
		case LUA_TUSERDATA: {
			lua_getglobal(mainVM, "argsToSAMP");

			lua_pushlightuserdata(mainVM, amx);
			
			lua_newtable(mainVM);
			lua_pushnumber(mainVM, 1);
			lua_getfield(luaVM, 1, "pointers");
			luaL_checktype(luaVM, -1, LUA_TTABLE);
			lua_pushnumber(luaVM, addr);
			lua_gettable(luaVM, -2);
			lua_pushremotevalue(mainVM, luaVM, -1);
			lua_settable(mainVM, -3);

			lua_pushremotevalue(mainVM, luaVM, 3);

			lua_pcall(mainVM, 3, 1, 0);

			lua_pushnumber(mainVM, 1);
			lua_gettable(mainVM, -2);
			*physaddr = (cell)lua_tonumber(mainVM, -1);
			lua_pop(mainVM, 2);
			break;
		}
		default: {
			return luaL_error(luaVM, "%lX attempt to save an invalid value to amx memory");
		}
	}
	return 1;
}

// lua(fnName, ...)
static cell AMX_NATIVE_CALL n_lua(AMX *amx, const cell *params) {
	cell numParams = params[0] / sizeof(cell);
	if(numParams == 0 || loadedAMXs.find(amx) == loadedAMXs.end())
		return 0;

	lua_State *resVM = loadedAMXs[amx].resourceVM;
	int mainTop = lua_gettop(mainVM);

	lua_getfield(mainVM, LUA_REGISTRYINDEX, "amx");
	lua_getfield(mainVM, -1, loadedAMXs[amx].resourceName.c_str());
	lua_getfield(mainVM, -1, "luaprototypes");
	if(lua_isnil(mainVM, -1)) {
		pModuleManager->ErrorPrintf("callLua: %s does not have any registered Lua functions\n", loadedAMXs[amx].resourceName.c_str());
		lua_settop(mainVM, mainTop);
		return 0;
	}
	lua_pushamxstring(mainVM, amx, params[1]);
	lua_gettable(mainVM, -2);
	if(lua_isnil(mainVM, -1)) {
		lua_pushamxstring(mainVM, amx, params[1]);
		pModuleManager->ErrorPrintf("callLua: no Lua function named %s is registered\n", lua_tostring(mainVM, -1));
		lua_settop(mainVM, mainTop);
		return 0;
	}

	lua_pushamxstring(resVM, amx, params[1]);
	lua_gettable(resVM, LUA_GLOBALSINDEX);
	luaL_checktype(resVM, -1, LUA_TFUNCTION);
	
	lua_newtable(resVM);
	lua_pushlightuserdata(resVM, amx);
	lua_setfield(resVM, -2, "amx");
	lua_newtable(resVM);
	lua_setfield(resVM, -2, "pointers");
	lua_newtable(resVM);
	lua_pushcfunction(resVM, callLuaMTRead);
	lua_setfield(resVM, -2, "__index");
	lua_pushcfunction(resVM, callLuaMTWrite);
	lua_setfield(resVM, -2, "__newindex");
	lua_pushboolean(resVM, 0);
	lua_setfield(resVM, -2, "__metatable");
	lua_setmetatable(resVM, -2);

	size_t numPrototypeArgs = lua_objlen(mainVM, -1);

	lua_getglobal(mainVM, "argsToMTA");
	lua_pushlightuserdata(mainVM, amx);
	lua_pushvalue(mainVM, -3);

	lua_getfield(resVM, -1, "pointers");
	for(cell i = 1; i < numParams; i++) {
		if(i - 1 < numPrototypeArgs) {
			lua_pushnumber(mainVM, i);
			lua_gettable(mainVM, -1 - i);
			const char *t = lua_tostring(mainVM, -1);
			lua_pop(mainVM, 1);

			cell *physaddr;
			amx_GetAddr(amx, params[1 + i], &physaddr);
			if(!physaddr) {
				lua_settop(mainVM, mainTop);
				return 0;
			}
			switch(*t) {
				case 'f':
					lua_pushnumber(mainVM, *(float *)physaddr);
					break;
				case 's':
					lua_pushamxstring(mainVM, amx, params[1 + i]);
					break;
				case '&':
					lua_pushnumber(mainVM, params[1 + i]);
					lua_pushnumber(resVM, params[1 + i]);
					lua_pushstring(resVM, t + 1);
					lua_settable(resVM, -3);
					break;
				default:
					lua_pushnumber(mainVM, *physaddr);
					break;
			}
		} else {
			lua_pushnumber(mainVM, params[1 + i]);
		}
	}
	lua_pop(resVM, 1);
	lua_setglobal(resVM, "_");

	lua_pcall(mainVM, 2 + numParams - 1, 2, 0);
	if(lua_toboolean(mainVM, -1)) {
		// One or more arguments could not be resolved (invalid element id passed)
		lua_settop(mainVM, mainTop);
		return 0;
	}
	lua_pop(mainVM, 1);

	lua_getglobal(resVM, "unpack");
	lua_pushremotevalue(resVM, mainVM, -1);
	lua_pcall(resVM, 1, numParams-1, 0);
	lua_pop(mainVM, 1);

	bool success = lua_pcall(resVM, numParams-1, 1, 0) == 0;
	lua_pushnil(resVM);
	lua_setglobal(resVM, "_");
	if(!success) {
		lua_settop(mainVM, mainTop);
		pModuleManager->ErrorPrintf("%lX %s\n", amx->cip, lua_tostring(resVM, -1));
		lua_pop(resVM, 1);
		return 0;
	}
	cell result;
	lua_getfield(mainVM, -1, "ret");
	if(!lua_isnil(mainVM, -1)) {
		lua_getglobal(mainVM, "argsToSAMP");
		lua_insert(mainVM, -2);
		lua_pushlightuserdata(mainVM, amx);
		lua_insert(mainVM, -2);
		lua_pushremotevalue(mainVM, resVM, -1);
		lua_pcall(mainVM, 3, 1, 0);
		lua_pushnumber(mainVM, 1);
		lua_gettable(mainVM, -2);
		result = (cell)lua_tonumber(mainVM, -1);
	} else {
		result = (cell)lua_tonumber(resVM, -1);
	}
	lua_pop(resVM, 1);
	lua_settop(mainVM, mainTop);
	return result;
}

static cell AMX_NATIVE_CALL n_amxRegisterPawnPrototypes(AMX *amx, const cell *params) {
	if(params[0]/sizeof(cell) != 1)
		return 0;
	cell addr;
	cell *physaddr;
	addr = params[1];
	amx_GetAddr(amx, addr, &physaddr);
	if(!physaddr || loadedAMXs.find(amx) == loadedAMXs.end())
		return 0;

	int mainTop = lua_gettop(mainVM);
	lua_getfield(mainVM, LUA_REGISTRYINDEX, "amx");
	lua_getfield(mainVM, -1, loadedAMXs[amx].resourceName.c_str());
	if(lua_isnil(mainVM, -1)) {
		lua_pop(mainVM, 1);
		lua_newtable(mainVM);
		lua_pushvalue(mainVM, -1);
		lua_setfield(mainVM, -3, loadedAMXs[amx].resourceName.c_str());
	}
	
	lua_newtable(mainVM);
	cell *pFn = physaddr;
	int fnIndex;
	cell *pArg, *pArgEnd;
	int argNum, argLen;
	cell numFunctions = (*pFn / sizeof(cell) - 1) / 2;
	for(cell i = 0; i < numFunctions; i++) {
		lua_newtable(mainVM);

		lua_getglobal(mainVM, "string");
		lua_getfield(mainVM, -1, "match");
		lua_remove(mainVM, -2);
		lua_pushamxstring(mainVM, amx, pFn + *pFn/sizeof(cell));
		lua_pushstring(mainVM, "([^:]+):?(.*)");
		lua_pcall(mainVM, 2, 2, 0);
		if(lua_objlen(mainVM, -1) == 0) {
			// No return type
			lua_pop(mainVM, 1);
		} else {
			lua_insert(mainVM, -2);
			lua_newtable(mainVM);
			lua_insert(mainVM, -2);
			lua_pushnumber(mainVM, 1);
			lua_insert(mainVM, -2);
			lua_settable(mainVM, -3);
			lua_setfield(mainVM, -3, "ret");
		}
		lua_insert(mainVM, -2);
		
		if(amx_FindPublic(amx, lua_tostring(mainVM, -2), &fnIndex) != AMX_ERR_NONE)
			return luaL_error(mainVM, "amxRegisterPawnPrototypes: %s: no public function named %s exists", loadedAMXs[amx].resourceName.c_str(), lua_tostring(mainVM, -1));

		argNum = 1;
		pArg = pFn + 1 + *(pFn+1)/sizeof(cell);
		pArgEnd = pFn + 2 + *(pFn+2)/sizeof(cell);
		while(pArg < pArgEnd) {
			lua_pushnumber(mainVM, argNum);
			lua_pushamxstring(mainVM, amx, pArg);
			if(*lua_tostring(mainVM, -1) == '&')
				return luaL_error(mainVM, "amxRegisterPawnPrototypes: %s: %s: by-reference arguments are not supported", loadedAMXs[amx].resourceName.c_str(), lua_tostring(mainVM, -4));
			lua_settable(mainVM, -3);

			amx_StrLen(pArg, &argLen);
			pArg += argLen + 1;
			argNum++;
		}
		lua_settable(mainVM, -3);
		pFn += 2;
	}
	lua_setfield(mainVM, -2, "pawnprototypes");
	lua_settop(mainVM, mainTop);
	return 1;
}

// amxVersion(&Float:ver)
static cell AMX_NATIVE_CALL n_amxVersion(AMX *amx, const cell *params) {
	if(params[0]/sizeof(cell) != 1)
		return 0;
	cell *physaddr;
	amx_GetAddr(amx, params[1], &physaddr);
	if(!physaddr)
		return 0;
	float version = MODULE_VERSION;
	*physaddr = *(cell *)&version;
	return 1;
}

// amxVersionString(&ver, bufsize)
static cell AMX_NATIVE_CALL n_amxVersionString(AMX *amx, const cell *params) {
	if(params[0]/sizeof(cell) != 2)
		return 0;
	cell *physaddr;
	amx_GetAddr(amx, params[1], &physaddr);
	if(!physaddr)
		return 0;
	amx_SetString(physaddr, MODULE_VERSIONSTRING, 0, 0, params[2]);
	return 1;
}

void initSAMPSyscalls() {
	if(!mainVM || sampNatives)
		return;

	lua_getglobal(mainVM, "g_SAMPSyscallPrototypes");
	int numNatives = 0;
	lua_pushnil(mainVM);
	while(lua_next(mainVM, -2)) {
		numNatives++;
		lua_pop(mainVM, 1);
	}

	sampNatives = new AMX_NATIVE_INFO[numNatives + 4 + 1];
	int i = 0;
	lua_pushnil(mainVM);
	while(lua_next(mainVM, -2)) {
		sampNatives[i].name = strdup(lua_tostring(mainVM, -2));
		sampNatives[i].func = n_samp;
		lua_pop(mainVM, 1);
		i++;
	}
	lua_pop(mainVM, 1);

	sampNatives[numNatives + 0].name = "lua";
	sampNatives[numNatives + 0].func = n_lua;
	sampNatives[numNatives + 1].name = "amxRegisterPawnPrototypes";
	sampNatives[numNatives + 1].func = n_amxRegisterPawnPrototypes;
	sampNatives[numNatives + 2].name = "amxVersion";
	sampNatives[numNatives + 2].func = n_amxVersion;
	sampNatives[numNatives + 3].name = "amxVersionString";
	sampNatives[numNatives + 3].func = n_amxVersionString;

	sampNatives[numNatives + 4].name = NULL;
	sampNatives[numNatives + 4].func = NULL;
}

int amx_SAMPInit(AMX *amx) {
	if(!sampNatives)
		initSAMPSyscalls();

	return amx_Register(amx, sampNatives, -1);
}
