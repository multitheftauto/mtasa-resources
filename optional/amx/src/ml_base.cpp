/*********************************************************
*
*  Multi Theft Auto: San Andreas - Deathmatch
*
*  ml_base, External lua add-on module
*  
*  Copyright � 2003-2008 MTA.  All Rights Reserved.
*
*  Grand Theft Auto is � 2002-2003 Rockstar North
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

ILuaModuleManager10 *pModuleManager = NULL;
lua_State *mainVM = NULL;
extern map < AMX *, AMXPROPS > loadedAMXs;

enum PLUGIN_DATA_TYPE
{
	PLUGIN_DATA_LOGPRINTF		= 0x00,	// void (*logprintf)(char* format, ...)

	PLUGIN_DATA_AMX_EXPORTS		= 0x10,	// void* AmxFunctionTable[]    (see PLUGIN_AMX_EXPORT)
	PLUGIN_DATA_CALLPUBLIC_FS	= 0x11, // int (*AmxCallPublicFilterScript)(char *szFunctionName)
	PLUGIN_DATA_CALLPUBLIC_GM	= 0x12, // int (*AmxCallPublicGameMode)(char *szFunctionName)
};

void *pluginInitData[0x13];

void *amxFunctions[] = {
	0,
	0,
	0,
	(void*)&amx_Allot,
	(void*)&amx_Callback,
	(void*)&amx_Cleanup,
	(void*)&amx_Clone,
	(void*)&amx_Exec,
	(void*)&amx_FindNative,
	(void*)&amx_FindPublic,
	(void*)&amx_FindPubVar,
	(void*)&amx_FindTagId,
	(void*)&amx_Flags,
	(void*)&amx_GetAddr,
	(void*)&amx_GetNative,
	(void*)&amx_GetPublic,
	(void*)&amx_GetPubVar,
	(void*)&amx_GetString,
	(void*)&amx_GetTag,
	(void*)&amx_GetUserData,
	(void*)&amx_Init,
	(void*)&amx_InitJIT,
	(void*)&amx_MemInfo,
	(void*)&amx_NameLength,
	(void*)&amx_NativeInfo,
	(void*)&amx_NumNatives,
	(void*)&amx_NumPublics,
	(void*)&amx_NumPubVars,
	(void*)&amx_NumTags,
	(void*)&amx_Push,
	(void*)&amx_PushArray,
	(void*)&amx_PushString,
	(void*)&amx_RaiseError,
	(void*)&amx_Register,
	(void*)&amx_Release,
	(void*)&amx_SetCallback,
	(void*)&amx_SetDebugHook,
	(void*)&amx_SetString,
	(void*)&amx_SetUserData,
	(void*)&amx_StrLen,
	(void*)&amx_UTF8Check,
	(void*)&amx_UTF8Get,
	(void*)&amx_UTF8Len,
	(void*)&amx_UTF8Put
};

MTAEXPORT bool InitModule ( ILuaModuleManager10 *pManager, char *szModuleName, char *szAuthor, float *fVersion )
{
	pModuleManager = pManager;

	// Set the module info
	strncpy ( szModuleName, MODULE_NAME, MAX_INFO_LENGTH );
	strncpy ( szAuthor, MODULE_AUTHOR, MAX_INFO_LENGTH );
	(*fVersion) = MODULE_VERSION;

	// Initiate plugin data
	pluginInitData[PLUGIN_DATA_LOGPRINTF] = (void*)&logprintf;
	pluginInitData[PLUGIN_DATA_AMX_EXPORTS] = amxFunctions;
	pluginInitData[PLUGIN_DATA_CALLPUBLIC_FS] = (void*)&AMXCallPublicFilterScript;
	pluginInitData[PLUGIN_DATA_CALLPUBLIC_GM] = (void*)&AMXCallPublicGameMode;

	string PATH = getenv("PATH");
	PATH += ";mods/deathmatch/resources/amx/plugins/";
	setenv("PATH", PATH.c_str(), 1);

	return true;
}

void logprintf(char *fmt, ...) {
	vprintf(fmt, (va_list)(&fmt + 1));
	printf("\n");
}

int AMXCallPublicFilterScript(char *fnName) {
	int fnIndex = -1;
	cell ret = 0;
	for(map< AMX *, AMXPROPS >::iterator it = loadedAMXs.begin(); it != loadedAMXs.end(); it++) {
		if(amx_FindPublic(it->first, "OnFilterScriptInit", &fnIndex) != AMX_ERR_NONE)
			continue;
		if(amx_FindPublic(it->first, fnName, &fnIndex) != AMX_ERR_NONE)
			continue;
		amx_Exec(it->first, &ret, fnIndex);
		return ret;
	}
	return 0;
}

int AMXCallPublicGameMode(char *fnName) {
	int fnIndex = -1;
	cell ret = 0;
	for(map< AMX *, AMXPROPS >::iterator it = loadedAMXs.begin(); it != loadedAMXs.end(); it++) {
		if(amx_FindPublic(it->first, "OnGameModeInit", &fnIndex) != AMX_ERR_NONE)
			continue;
		if(amx_FindPublic(it->first, fnName, &fnIndex) != AMX_ERR_NONE)
			continue;
		amx_Exec(it->first, &ret, fnIndex);
		return ret;
	}
	return 0;
}

MTAEXPORT void RegisterFunctions ( lua_State * luaVM )
{
	if ( pModuleManager && luaVM )
	{
		pModuleManager->RegisterFunction(luaVM, "amxIsPluginLoaded", CFunctions::amxIsPluginLoaded);
		pModuleManager->RegisterFunction(luaVM, "amxRegisterLuaPrototypes", CFunctions::amxRegisterLuaPrototypes);
		pModuleManager->RegisterFunction(luaVM, "amxVersion", CFunctions::amxVersion);
		pModuleManager->RegisterFunction(luaVM, "amxVersionString", CFunctions::amxVersionString);
		
		string resName;
		if(!pModuleManager->GetResourceName(luaVM, resName) || resName.compare("amx"))
			return;

		mainVM = luaVM;

		pModuleManager->RegisterFunction(luaVM, "amxLoadPlugin", CFunctions::amxLoadPlugin);
		pModuleManager->RegisterFunction(luaVM, "amxLoad", CFunctions::amxLoad);
		pModuleManager->RegisterFunction(luaVM, "amxCall", CFunctions::amxCall);
		pModuleManager->RegisterFunction(luaVM, "amxMTReadDATCell", CFunctions::amxMTReadDATCell);
		pModuleManager->RegisterFunction(luaVM, "amxMTWriteDATCell", CFunctions::amxMTWriteDATCell);
		pModuleManager->RegisterFunction(luaVM, "amxReadString", CFunctions::amxReadString);
		pModuleManager->RegisterFunction(luaVM, "amxWriteString", CFunctions::amxWriteString);
		pModuleManager->RegisterFunction(luaVM, "amxUnload", CFunctions::amxUnload);
		pModuleManager->RegisterFunction(luaVM, "amxUnloadAllPlugins", CFunctions::amxUnloadAllPlugins);

		pModuleManager->RegisterFunction(luaVM, "sqlite3OpenDB", CFunctions::sqlite3OpenDB);
		pModuleManager->RegisterFunction(luaVM, "sqlite3Query", CFunctions::sqlite3Query);
		pModuleManager->RegisterFunction(luaVM, "sqlite3CloseDB", CFunctions::sqlite3CloseDB);

		pModuleManager->RegisterFunction(luaVM, "cell2float", CFunctions::cell2float);
		pModuleManager->RegisterFunction(luaVM, "float2cell", CFunctions::float2cell);

		lua_newtable(luaVM);
		lua_setfield(luaVM, LUA_REGISTRYINDEX, "amx");
	}
}

MTAEXPORT bool DoPulse ( void )
{
	return true;
}

MTAEXPORT bool ShutdownModule ( void )
{
	
	return true;
}
