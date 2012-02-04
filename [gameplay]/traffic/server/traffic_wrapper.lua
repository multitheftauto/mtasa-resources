_createVehicle = createVehicle
function createVehicle ( ... )
	-- Store our vehicle
	local veh = _createVehicle ( ... )
	TRAFFIC_VEHICLES[veh] = true
	return veh
end