--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_definitions.lua
*
*	Original File by lil_Toady
*
**************************************]]

_DEBUG = false

_version = '1.3.1'

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

enum
({
	"EVENT_SYNC",
	"EVENT_SYNC_PERMISSIONS",
	"EVENT_TEAM",
	"EVENT_ADMIN",
	"EVENT_PLAYER",
	"EVENT_VEHICLE",
	"EVENT_RESOURCE",
	"EVENT_SERVER",
	"EVENT_MESSAGE",
	"EVENT_BANS",
	"EVENT_EXECUTE",
	"EVENT_ADMIN_CHAT",
	"EVENT_ADMIN_OPEN",

	"EVENT_RESOURCE_START",
	"EVENT_RESOURCE_STOP",
	"EVENT_PLAYER_JOIN"
} )

-- SYNC DEFINITIONS

enum
({
	"SYNC_PLAYER",
	"SYNC_PLAYERS",
	"SYNC_RESOURCES",
	"SYNC_ADMINS",
	"SYNC_SERVER",
	"SYNC_RIGHTS",
	"SYNC_BANS",
	"SYNC_MESSAGES"
})

-- TEAM DEFINITIONS

enum
({
	"TEAM_CREATE",
	"TEAM_DESTROY"
})

-- ADMIN DEFINITIONS

enum
({
	"ADMIN_PASSWORD",
	"ADMIN_AUTOLOGIN",
	"ADMIN_SYNC",
	"ADMIN_ACL_CREATE",
	"ADMIN_ACL_DESTROY",
	"ADMIN_ACL_ADD",
	"ADMIN_ACL_REMOVE"
})

-- PLAYER DEFINITIONS

enum
({
	"PLAYER_KICK",
	"PLAYER_BAN",
	"PLAYER_MUTE",
	"PLAYER_FREEZE",
	"PLAYER_SHOUT",
	"PLAYER_SET_HEALTH",
	"PLAYER_SET_ARMOUR",
	"PLAYER_SET_SKIN",
	"PLAYER_SET_MONEY",
	"PLAYER_SET_STAT",
	"PLAYER_SET_TEAM",
	"PLAYER_SET_INTERIOR",
	"PLAYER_SET_DIMENSION",
	"PLAYER_JETPACK",
	"PLAYER_SET_GROUP",
	"PLAYER_GIVE_VEHICLE",
	"PLAYER_GIVE_WEAPON",
	"PLAYER_SLAP",
	"PLAYER_WARP",
	"PLAYER_WARP_TO"
})

-- VEHICLE DEFINITIONS

enum
({
	"VEHICLE_REPAIR",
	"VEHICLE_CUSTOMIZE",
	"VEHICLE_SET_PAINTJOB",
	"VEHICLE_SET_COLOR",
	"VEHICLE_BLOW",
	"VEHICLE_DESTROY"
})

-- RESOURCE DEFINITIONS

enum
({
	"RESOURCE_START",
	"RESOURCE_RESTART",
	"RESOURCE_STOP"
})

-- SERVER DEFINITIONS

enum
({
	"SERVER_SET_GAME",
	"SERVER_SET_MAP",
	"SERVER_SET_WELCOME",
	"SERVER_SET_TIME",
	"SERVER_SET_PASSWORD",
	"SERVER_SET_WEATHER",
	"SERVER_BLEND_WEATHER",
	"SERVER_SET_GAME_SPEED",
	"SERVER_SET_GRAVITY",
	"SERVER_SET_BLUR_LEVEL",
	"SERVER_SET_WAVE_HEIGHT"
})

-- MESSAGE DEFINITIONS

enum
({
	"MESSAGE_NEW",
	"MESSAGE_GET",
	"MESSAGE_READ",
	"MESSAGE_DELETE"
})

-- BANS DEFINITIONS

enum
({
	"BANS_BAN_IP",
	"BANS_BAN_SERIAL",
	"BANS_UNBAN_IP",
	"BANS_UNBAN_SERIAL"
})