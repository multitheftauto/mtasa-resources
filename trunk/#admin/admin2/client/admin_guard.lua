--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client/admin_guard.lua
*
*	Original File by lil_Toady
*
**************************************]]

_addEventHandler = addEventHandler
function addEventHandler ( event, element, handler, propagated )
	_addEventHandler ( event, element, function ( ... )
		if ( sourceResource ~= getThisResource() ) then
			local resource = getResourceName ( sourceResource )
			outputDebugString ( "Warning: Resource \'"..resource.."\' tried to access admin event \'"..event.."\'", 2, 255, 0, 0 )
			return
		end
		handler ( ... )
	end, propagated )
end