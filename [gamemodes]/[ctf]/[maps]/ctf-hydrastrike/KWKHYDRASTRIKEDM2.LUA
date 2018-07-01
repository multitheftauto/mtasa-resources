function onResourceStart( resourcename )
	KWKHYDRASTRIKEDM_vehicles = getElementsByType("vehicle")
	for k,v in ipairs(KWKHYDRASTRIKEDM_vehicles) do
		setVehicleFuelTankExplodable ( v, true )
		local x, y, z = getElementPosition( v )
		local rx, ry, rz = getVehicleRotation ( v )
		setElementData( v, "posX", x )
		setElementData( v, "posY", y )
		setElementData( v, "posZ", z )
		setElementData( v, "rotX", rx )
		setElementData( v, "rotY", ry )
		setElementData( v, "rotZ", rz )
	end
	idleRespawn( 1 )
end

function respawnVehicle( vehicle )
	spawnVehicle ( vehicle, getElementData( vehicle, "posX" ), getElementData( vehicle, "posY" ), getElementData( vehicle, "posZ" ), getElementData( vehicle, "rotX" ), getElementData( vehicle, "rotY" ), getElementData( vehicle, "rotZ" ) )
end

function onVehicleExplode ()
	setTimer( respawnVehicle, 5000, 1, source )
end

function dist2DFixed( element, x, y, z )
	local x1, y1, z1 = getElementPosition( element )
	local dist = (( x - x1 )^2) + (( y - y1 )^2)
	return dist
end

function idleRespawn( num )
	--local one = getTickCount()
	local players = getElementsByType("player")
	local x, y, z = getElementPosition( KWKHYDRASTRIKEDM_vehicles[num] )
	local flag = true
	for k,v in ipairs(players) do
		if ( dist2DFixed( v, x, y, z ) < 62500 ) then
			flag = false
		end
	end
	if flag then respawnVehicle( KWKHYDRASTRIKEDM_vehicles[num] ) end
	num = num + 1
	if ( KWKHYDRASTRIKEDM_vehicles[num] ) then
	else
		num = 1
		--outputChatBox( "New cycle started." )
	end
	setTimer( idleRespawn, 100, 1, num )
	--outputConsole( getTickCount() - one )
end

addEventHandler ( "onResourceStart", getResourceRootElement(getThisResource()), onResourceStart )
addEventHandler ( "onVehicleExplode", getRootElement(), onVehicleExplode )