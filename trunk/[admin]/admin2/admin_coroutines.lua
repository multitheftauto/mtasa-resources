--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client/admin_coroutines.lua
*
*	Original File by lil_Toady
*
**************************************]]

local aCoroutines = {}

sourceCoroutine = nil

local _addEventHandler = addEventHandler
function addEventHandler ( event, element, handler, ... )
	if ( not _addEventHandler ( event, element, corouteHandler ( handler ), ... ) ) then
		local info = debug.getinfo ( 2, "nS" )
		outputDebugString ( "addEventHandler call failed from: "..tostring ( info.name ).." ("..info.short_src..")" )
	end
end

local _removeEventHandler = removeEventHandler
function removeEventHandler ( event, element, handler )
	if ( aCoroutines[handler] ) then
		for id, wrapper in ipairs ( aCoroutines[handler] ) do
			_removeEventHandler ( event, element, wrapper )
		end
		aCoroutines[handler] = {}
	else
		_removeEventHandler ( event, element, handler )
	end
end

function corouteHandler ( handler )
	local wrapper = function ( ... )
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
	if ( not aCoroutines[handler] ) then
		aCoroutines[handler] = {}
	end
	table.insert ( aCoroutines[handler], wrapper )
	return wrapper
end

function coroutineKill ( cr )
	if ( coroutine.status ( c ) ~= 'dead' ) then
		coroutine.resume ( c, nil )
	end
end