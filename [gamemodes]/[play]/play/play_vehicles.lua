local vehicleTimers = {}
local playerVehicles = {}
local vehiclesToSpawn = {}

function createVehicles()
	for vehicleID = 1, #vehicleSpawns do
		local vehicleData = vehicleSpawns[vehicleID]

		createPlayVehicle(vehicleData)
	end
end

function createPlayVehicle(vehicleData)
	local modelID, posX, posY, posZ, rotX = vehicleData[1], vehicleData[2], vehicleData[3], vehicleData[4], vehicleData[5]
	local vehicleElement = createVehicle(modelID, posX, posY, posZ, 0, 0, rotX)

	setVehicleDamageProof(vehicleElement, true)
	setElementFrozen(vehicleElement, true)
	vehiclesToSpawn[vehicleElement] = vehicleData
end

function destroyVehicle(vehicleElement)
	local validVehicle = isElement(vehicleElement)

	if validVehicle then
		destroyElement(vehicleElement)
	end

	destroyVehicleTimer(vehicleElement)
end

function destroyPlayerVehicles(playerElement)
	local savedVehicles = playerVehicles[playerElement]

	if savedVehicles then

		for vehicleID = 1, #savedVehicles do
			local vehicleElement = savedVehicles[vehicleID]
			local validVehicle = isElement(vehicleElement)

			if validVehicle then
				destroyElement(vehicleElement)
			end

			destroyVehicleTimer(vehicleElement)
		end

		playerVehicles[playerElement] = nil
	end
end

function destroyVehicleTimer(vehicleElement)
	local vehicleTimer = vehicleTimers[vehicleElement]

	if vehicleTimer then
		local validTimer = isTimer(vehicleTimer)

		if validTimer then
			killTimer(vehicleTimer)
		end

		vehicleTimers[vehicleElement] = nil
	end
end

function onVehicleEnter(playerElement)
	local vehicleRespawnTime = get("vehicleRespawnTime")
	local vehicleData = vehiclesToSpawn[source]

	vehicleRespawnTime = tonumber(vehicleRespawnTime) or 60000
	vehicleRespawnTime = vehicleRespawnTime > 50 and vehicleRespawnTime or 50
	vehiclesToSpawn[source] = nil

	setVehicleDamageProof(source, false)
	setElementFrozen(source, false)
	setTimer(createPlayVehicle, vehicleRespawnTime, 1, vehicleData)

	local savedVehicles = playerVehicles[playerElement]

	if not savedVehicles then
		playerVehicles[playerElement] = {}
		savedVehicles = playerVehicles[playerElement]
	end

	local playerVehiclesCount = #savedVehicles + 1

	savedVehicles[playerVehiclesCount] = source
	destroyVehicleTimer(source)
end

function onVehicleExit()
	local vehicleExpireTime = get("vehicleExpireTime")

	vehicleExpireTime = tonumber(vehicleExpireTime) or 600000
	vehicleExpireTime = vehicleExpireTime > 50 and vehicleExpireTime or 50
	vehicleTimers[source] = setTimer(destroyVehicle, vehicleExpireTime, 1, source)
end

function onVehicleElementDestroy()
	local validElement = isElement(source)

	if validElement then
		local vehicleType = getElementType(source) == "vehicle"

		if vehicleType then
			destroyVehicleTimer(source)
			vehiclesToSpawn[source] = nil
		end
	end
end