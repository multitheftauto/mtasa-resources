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

_version = '1.6'

-- MISC DEFINITIONS
ADMIN_CHAT_MAXLENGTH = 225

function enum ( args, prefix )
	for i, v in ipairs ( args ) do
		if ( prefix ) then _G[v] = prefix..i
		else _G[v] = i end
	end
end