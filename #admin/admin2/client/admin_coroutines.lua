--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client/admin_coroutines.lua
*
*	Original File by lil_Toady
*
**************************************]]

sourceCoroutine = nil

local _addEventHandler = addEventHandler
function addEventHandler ( event, element, handler )
	_addEventHandler ( event, element, corouteHandler ( handler ) )
end

function corouteHandler ( handler )
	return function ( ... )
		local c = coroutine.create ( handler )
		sourceCoroutine = c
		local result, error = coroutine.resume ( c, ... )
		if ( not result ) then
			outputDebugString ( tostring ( error ) )
		end
		if ( sourceCoroutine == c ) then
			sourceCoroutine = nil
		end
	end
end

function coroutineKill ( cr )
	if ( coroutine.status ( c ) ~= 'dead' ) then
		coroutine.resume ( c, nil )
	end
end