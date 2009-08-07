function cdm_clientResourceStart ( resourcename )
	if ( resourcename == getThisResource () ) then
		bindKey ( "i", "down", "showvehicles", "1" )
		bindKey ( "i", "up", "showvehicles", "0" )
	end
end

function dist2DFixed( element, x, y, z )
	local x1, y1, z1 = getElementPosition( element )
	local dist = (( x - x1 )^2) + (( y - y1 )^2)
	return dist
end

function showVehicles( command, keyState )
	local vehicles = getElementsByType( "vehicle" )
	if ( keyState == "1" ) then
		blipsFlag = true
		updateBlips()
	else
		blipsFlag = false
		local vehicles = getElementsByType( "vehicle" )
		for k,v in ipairs(vehicles) do
			destroyBlipsAttachedTo ( v )
		end
	end
end

function updateBlips()
	--local one = getTickCount()
	local vehicles = getElementsByType( "vehicle" )
	if ( blipsFlag == true ) then
		local x, y, z = getElementPosition( getLocalPlayer() )
		for k,v in ipairs(vehicles) do
			if ( dist2DFixed( v, x, y, z ) < 62500 ) then 
				createBlipAttachedTo ( v, 0, 1, 255, 255, 0, 255 )
			else
				destroyBlipsAttachedTo ( v )
			end
		end
		setTimer( updateBlips, 1000, 1 )
	end
	--outputConsole( tostring(getTickCount() - one) )
end

addEventHandler ( "onClientResourceStart", getRootElement(), cdm_clientResourceStart )