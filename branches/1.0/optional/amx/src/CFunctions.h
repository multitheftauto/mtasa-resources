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

#ifndef __CFUNCTIONS_H
#define __CFUNCTIONS_H

class CFunctions
{
public:

	static int amxLoadPlugin(lua_State *luaVM);
	static int amxIsPluginLoaded(lua_State *luaVM);
	static int amxLoad(lua_State *luaVM);
	static int amxCall(lua_State *luaVM);
	static int amxMTReadDATCell(lua_State *luaVM);
	static int amxMTWriteDATCell(lua_State *luaVM);
	static int amxReadString(lua_State *luaVM);
	static int amxWriteString(lua_State *luaVM);
	static int amxUnload(lua_State *luaVM);
	static int amxUnloadAllPlugins(lua_State *luaVM);

	static int amxRegisterLuaPrototypes(lua_State *luaVM);
	static int amxVersion(lua_State *luaVM);
	static int amxVersionString(lua_State *luaVM);
	static int startResource(lua_State *luaVM);

	static int sqlite3OpenDB(lua_State *luaVM);
	static int sqlite3Query(lua_State *luaVM);
	static int sqlite3CloseDB(lua_State *luaVM);

	static int pawn(lua_State *luaVM);
	static int cell2float(lua_State *luaVM);
	static int float2cell(lua_State *luaVM);

};

#endif
