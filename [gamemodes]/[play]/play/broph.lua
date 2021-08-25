local positionsVehicle = {
	-- {model id, x, y, z, r}
	{411, -2507.703125, -334.5881652832, 58.109756469727, 140}
}

local spawnPosition = {
	-- {x, y, w, r}
	{-2511.6953125, -342.90386962891, 58.481922149658, 90},
}

local defaultTimes = {
	["VehRespawn"] = 60000,
	["Expire"] = 600000,
	["PlayerRespawn"] = 4000
}

local vehTimeToDestroy = {}
local vehToSpawn = {}
local playerVeh = {}

addEventHandler("onResourceStop", resourceRoot, function()
	destroyElements()
end)

addEventHandler("onResourceStart", resourceRoot, function()
	for _, players in ipairs(getElementsByType("player")) do
		spawn(players)
	end

	for k, v in pairs(positionsVehicle) do
		createVeh(v)
	end
end)

addEventHandler("onPlayerJoin", root, function()
	spawn(source)
end)

addEventHandler("onPlayerQuit", root, function()
	destroyElements()
end)

addEventHandler("onPlayerWasted", root, function()
	local playerRespawn = defaultTimes["PlayerRespawn"]
	setTimer(spawn, (playerRespawn > 50 and playerRespawn or 50), 1, source)
end)

addEventHandler("onVehicleEnter", root, function(player)
	if isElement(source) then
		if vehTimeToDestroy[source] and isTimer(vehTimeToDestroy[source]) then
			killTimer(vehTimeToDestroy[source])
		end

		setVehicleDamageProof(source, false)
		setElementFrozen(source, false)

		local vehData = vehToSpawn[source]
		local vehRespawn = defaultTimes["VehRespawn"]
		setTimer(createVeh, (vehRespawn > 50 and vehRespawn or 50), 1, vehData)

		if not playerVeh[player] then
			playerVeh[player] = {}
		end

		table.insert(playerVeh[player], source)

		vehData = nil
	end
end)

addEventHandler("onVehicleExit", root, function()
	if isElement(source) then
		local expire = defaultTimes["Expire"]

		vehTimeToDestroy[source] = setTimer(function(elem)
			if isElement(elem) and getElementType(elem) == "vehicle" then
				destroyElement(elem)
			end
		end, (expire > 50 and expire or 50), 1, source)
	end
end)

function spawn(player)
	if not player then
		player = client
	end

	if player and isElement(player) then
		local randomSpawn = math.random(1, #spawnPosition)
		local x, y, z, r = unpack(spawnPosition[randomSpawn])

		local randomXY = math.random(-3, 3)

		local randomSkin = math.random(0, 312)

		if getElementType(player) == "ped" and not getElementModel(player) == randomSkin then
			randomSkin = 0

			setElementModel(player, randomSkin)
		end

		spawnPlayer(player, x + randomXY, y + randomXY, z, r, randomSkin)
		fadeCamera(player, true)
		setCameraTarget(player, player)
	end
end

function createVeh(data)
	local id, x, y, z, r = unpack(data)

	local vehCreated = createVehicle(id, x, y, z, 0, 0, r)
	setVehicleDamageProof(vehCreated, true)
	setElementFrozen(vehCreated, true)

	vehToSpawn[vehCreated] = data
end

function destroyElements()
	if table.maxn(playerVeh) > 0 then
		for k, v in pairs(playerVeh[source]) do
			if isElement(v) then
				destroyElement(v)
			end

			if vehTimeToDestroy[v] and isTimer(vehTimeToDestroy[v]) then
				killTimer(vehTimeToDestroy[v])
				vehTimeToDestroy[v] = nil
			end
		end

		playerVeh[source] = nil
	end
end
