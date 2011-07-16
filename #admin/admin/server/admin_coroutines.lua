--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_coroutines.lua
*
*	Original File by lil_Toady
*
**************************************]]

--[[ Generates errors

local _addEventHandler = addEventHandler
function addEventHandler ( event, element, handler )
	_addEventHandler ( event, element, corouteHandler ( handler ) )
end

local _addCommandHandler = addCommandHandler
function addCommandHandler ( command, handler, restricted )
	_addCommandHandler ( command, corouteHandler ( handler ), restricted )
end

function corouteHandler ( handler )
	return function ( ... )
		local c = coroutine.create ( handler )
		coroutine.resume ( c, ... )
	end
end

function coroutineKill ( cr )
	if ( coroutine.status ( c ) ~= 'dead' ) then
		coroutine.resume ( c, nil )
	end
end

--]]