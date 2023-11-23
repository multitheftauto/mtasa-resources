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
	local modelID, posX, posY, posZ, rotX = unpack(vehicleData)
	local vehicleElement = createVehicle(modelID, posX, posY, posZ, 0, 0, rotX)

	setVehicleDamageProof(vehicleElement, true)
	setElementFrozen(vehicleElement, true)
	vehiclesToSpawn[vehicleElement] = vehicleData
end

function destroyVehicle(vehicleElement)
	local validElement = isElement(vehicleElement)

	if validElement then
		destroyElement(vehicleElement)
	end

	destroyVehicleTimer(vehicleElement)
end

function assignVehicleToPlayer(playerElement, vehicleElement)
	local savedVehicles = playerVehicles[playerElement]

	if not savedVehicles then
		playerVehicles[playerElement] = {}
		savedVehicles = playerVehicles[playerElement]
	end

	savedVehicles[vehicleElement] = true
end

function destroyPlayerVehicles(playerElement)
	local savedVehicles = playerVehicles[playerElement]

	if not savedVehicles then
		return false
	end

	for vehicleElement, _ in pairs(savedVehicles) do
		local validElement = isElement(vehicleElement)

		if validElement then
			destroyElement(vehicleElement)
		end

		destroyVehicleTimer(vehicleElement)
	end

	playerVehicles[playerElement] = nil
end

function destroyVehicleTimer(vehicleElement)
	local vehicleTimer = vehicleTimers[vehicleElement]

	if not vehicleTimer then
		return false
	end

	local validTimer = isTimer(vehicleTimer)

	if validTimer then
		killTimer(vehicleTimer)
	end

	vehicleTimers[vehicleElement] = nil
end

function onVehicleEnter(playerElement)
	local vehicleData = vehiclesToSpawn[source]

	destroyVehicleTimer(source)

	if not vehicleData then
		return false
	end

	local vehicleRespawnTime = get("vehicleRespawnTime")

	vehicleRespawnTime = tonumber(vehicleRespawnTime) or 10000
	vehicleRespawnTime = vehicleRespawnTime < 0 and 0 or vehicleRespawnTime
	vehiclesToSpawn[source] = nil

	setVehicleDamageProof(source, false)
	setElementFrozen(source, false)
	setTimer(createPlayVehicle, vehicleRespawnTime, 1, vehicleData)

	assignVehicleToPlayer(playerElement, source)
end

function onVehicleExit()
	local vehicleExpireTime = get("vehicleExpireTime")

	vehicleExpireTime = tonumber(vehicleExpireTime) or 600000
	vehicleExpireTime = vehicleExpireTime < 0 and 0 or vehicleExpireTime
	vehicleTimers[source] = setTimer(destroyVehicle, vehicleExpireTime, 1, source)
end

function onVehicleElementDestroy()
	local validElement = isElement(source)

	if not validElement then
		return false
	end

	local vehicleType = getElementType(source) == "vehicle"

	if not vehicleType then
		return false
	end
	
	destroyVehicleTimer(source)
	vehiclesToSpawn[source] = nil
end