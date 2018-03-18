function initVehicleSystem()
	local gameVehicles = getElementsByType("vehicle", mapResource)
	for k,v in ipairs(gameVehicles) do
		toggleVehicleRespawn ( v, true )
		setVehicleRespawnDelay ( v, 30000 )
		setVehicleIdleRespawnDelay ( v, 120000 )
	end
end
