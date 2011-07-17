function cdm_clientResourceStart ( resourcename )
	if ( resourcename == getThisResource () ) then
		bindKey ( "i", "down", "Show Vehicles", "1" )
		bindKey ( "i", "up", "Show Vehicles", "0" )
	end
end

function destroyAttachedVehicleBlips()
	local vehicles = getElementsByType( "vehicle" )
	for k,v in ipairs(vehicles) do
		local elements = getAttachedElements(v)
		for l, b in ipairs(elements) do
			if getElementType(b) == "blip" then
				destroyElement(b)
			end
		end
	end	
end

function createBlipsAttachedToVehicles()
	local vehicles = getElementsByType( "vehicle" )
	for k,v in ipairs(vehicles) do
		createBlipAttachedTo ( v, 0, 1, 255, 255, 0, 255 )
	end
end	

function showVehicles( command, keyState )
	local vehicles = getElementsByType( "vehicle" )
	if ( keyState == "1" ) then
		createBlipsAttachedToVehicles()
	else
		destroyAttachedVehicleBlips()
	end
end

addCommandHandler("Show Vehicles", showVehicles)

addEventHandler ( "onClientResourceStart", getRootElement(), cdm_clientResourceStart )
