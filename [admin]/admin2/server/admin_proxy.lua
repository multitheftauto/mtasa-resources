--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_proxy.lua
*
*	Original File by lil_Toady
*
**************************************]]

local worldSpecialProperties = { hovercars = false, aircars = false, extrabunny = false, extrajump = false }

function isWorldSpecialPropertyEnabled ( property )
	if ( worldSpecialProperties[property] ) then
		return true
	end
	return false
end

function setWorldSpecialPropertyEnabled ( property, enabled )
	local v = worldSpecialProperties[property]
	if ( type ( enabled ) == "boolean" ) then
		worldSpecialProperties[property] = iif ( enabled, true, false )
		triggerClientEvent ( client, EVENT_PROXY, client, PROXY_SPECIAL, property, worldSpecialProperties[property] )
		return true
	end
	return false
end

local blurLevel = 36
function setBlurLevel ( level )
	local level = tonumber ( level )
	if ( level and level >= 0 and level <= 255 ) then
		blurLevel = level
		triggerClientEvent ( client, EVENT_PROXY, client, PROXY_BLUR, blurLevel )
		return true
	end
	return false
end

function getBlurLevel ()
	return blurLevel
end

addEventHandler ( EVENT_SESSION, _root, function ( type )
	if ( type == SESSION_START ) then
		triggerClientEvent ( client, EVENT_PROXY, client, PROXY_ALL, {
			[PROXY_BLUR] = blurLevel,
			[PROXY_SPECIAL] = worldSpecialProperties
		} )
	end
end )