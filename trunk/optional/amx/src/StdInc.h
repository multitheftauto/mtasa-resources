#ifndef _STDINC_H
#define _STDINC_H

#ifdef WIN32
    #define WIN32_LEAN_AND_MEAN
	#include <windows.h>
#else
	#include <dlfcn.h>
#endif

#include <boost/filesystem.hpp>

#include <stdio.h>
#include <cstdarg>
#include <cstring>
#include <list>
#include <map>
#include <set>
#include <string>
#include <vector>

#include "Common.h"
#include "include/ILuaModuleManager.h"
#include "include/sqlite3.h"

extern "C"
{
    #include "amx/amx.h"
    #include "amx/amxaux.h"

    int AMXEXPORT amx_CoreInit(AMX *amx);
	int AMXEXPORT amx_ConsoleInit(AMX *amx);
	int AMXEXPORT amx_FloatInit(AMX *amx);
	int AMXEXPORT amx_StringInit(AMX *amx);
	int AMXEXPORT amx_TimeInit(AMX *amx);
	int AMXEXPORT amx_FileInit(AMX *amx);

    #include "include/lua.h"
    #include "include/lualib.h"
    #include "include/lauxlib.h"
	#include "include/lobject.h"
};

#include "ml_base.h"
#include "util.h"
#include "CFunctions.h"

#endif