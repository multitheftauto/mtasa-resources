--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_definitions.lua
*
*	Original File by lil_Toady
*
**************************************]]

_DEBUG = true

_version = '2.0'

_root = getRootElement()

if ( getLocalPlayer ) then
	_local = getLocalPlayer()
else
	_local = getResourceRootElement ( getThisResource() )
end

function enum ( args, prefix )
	for i, v in ipairs ( args ) do
		if ( prefix ) then _G[v] = prefix..i
		else _G[v] = i end
	end
end

-- EVENT CALLS

enum ({
	"EVENT_SYNC",
	"EVENT_SESSION",
	"EVENT_TEAM",
	"EVENT_ACL",
	"EVENT_PLAYER",
	"EVENT_VEHICLE",
	"EVENT_RESOURCE",
	"EVENT_SERVER",
	"EVENT_MESSAGE",
	"EVENT_BANS",
	"EVENT_NETWORK",
	"EVENT_EXECUTE",
	"EVENT_PROXY",
	"EVENT_ADMIN_CHAT",
	"EVENT_ADMIN_OPEN",
	"EVENT_MESSAGE_BOX",

	"EVENT_RESOURCE_START",
	"EVENT_RESOURCE_STOP",
	"EVENT_PLAYER_JOIN"
}, "ae" )

-- SYNC DEFINITIONS

enum ({
	"SYNC_PLAYER",
	"SYNC_PLAYERS",
	"SYNC_RESOURCES",
	"SYNC_RESOURCE",
	"SYNC_ADMINS",
	"SYNC_SERVER",
	"SYNC_BANS",
	"SYNC_MESSAGES"
}, "as" )

-- ACL DEFINITIONS
enum ({
	"ACL_GROUPS",
	"ACL_USERS",
	"ACL_RESOURCES",
	"ACL_ACL",
	"ACL_GET",
	"ACL_ADD",
	"ACL_REMOVE"
}, "aa" )

-- NETWORD DEFINITIONS
enum ({
	"NETWORK_REQUEST"
}, "an" )

-- SESSION DEFINITIONS
enum ({
	"SESSION_START",
	"SESSION_UPDATE"
}, "ase" )

-- PROXY DEFINITIONS
enum ({
	"PROXY_ALL",
	"PROXY_BLUR",
	"PROXY_SPECIAL"
}, "ap" )

if ( not _DEBUG ) then
	function outputDebugString ()
		return
	end
end