local spawnsCount = #playerSpawns
local skinsCount = #playerSkins

function playSpawnPlayer(playerElement)
	local validPlayer = isElement(playerElement)

	if validPlayer then
		local randomSpawn = math.random(1, spawnsCount)
		local spawnData = playerSpawns[randomSpawn]
		local posX, posY, posZ, rotX = spawnData[1], spawnData[2], spawnData[3], spawnData[4]
		local randomSkin = math.random(1, skinsCount)
		local skinID = playerSkins[randomSkin]

		posX, posY = posX + math.random(-3, 3), posY + math.random(-3, 3)

		spawnPlayer(playerElement, posX, posY, posZ, rotX, skinID, 0, 0, nil)
		fadeCamera(playerElement, true)
		setCameraTarget(playerElement, playerElement)
	end
end

function onPlayerJoinOrWasted()
	local joinEvent = eventName == "onPlayerJoin"

	if joinEvent then
		playSpawnPlayer(source)
	else
		local playerRespawnTime = get("playerRespawnTime")

		playerRespawnTime = tonumber(playerRespawnTime) or 5000
		playerRespawnTime = playerRespawnTime > 50 and playerRespawnTime or 50

		setTimer(playSpawnPlayer, playerRespawnTime, 1, source)
	end
end

function onPlayerQuit()
	destroyPlayerVehicles(source)
end