
g_Root = getRootElement();
g_ResRoot = getResourceRootElement();


function table.size( tab )
	local size = 0;
	for i,v in pairs( tab ) do
		size = size + 1;
	end
	return size;
end


addEvent( "onGamemodeMapStart" )
addEventHandler( "onGamemodeMapStart", g_Root,
	function( resMap )
		--g_MapRes = resMap;
		--outputChatBox( "vehicles: " .. #getElementsByType( "vehicle", getResourceRootElement( resMap ) ) );
	end
)


addEvent( "onPlayerPickUpRacePickup" )
addEventHandler( "onPlayerPickUpRacePickup", g_Root,
	function( _, type, veh )
		if type == "nitro" then
			setVehicleNOS( getPedOccupiedVehicle( source ), 100 );
		end
	end
)


function setVehicleNOS( vehicle, nos )
	if getElementData( vehicle, "NOS" ) == 100 then
		triggerClientEvent( getVehicleOccupant( vehicle ), "refillNOS", vehicle, 100 );
	else
		setElementData( vehicle, "NOS", 100 );
	end
end
