function enterVehicle ( player, seat, jacked )
    if ( getElementModel(source) ) then
        cancelEvent()
    end
end
addEventHandler ( "onVehicleStartEnter", getRootElement(), enterVehicle )
