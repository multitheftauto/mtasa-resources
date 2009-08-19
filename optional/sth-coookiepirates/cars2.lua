function enterVehicle ( player, seat, jacked ) 
    if ( getVehicleID(source) ) then
        cancelEvent()
    end
end
addEventHandler ( "onVehicleStartEnter", getRootElement(), enterVehicle )