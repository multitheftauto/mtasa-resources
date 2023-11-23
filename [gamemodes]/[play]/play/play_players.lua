local spawnsCount = #playerSpawns
local skinsCount = #playerSkins

function playSpawnPlayer(playerElement)
	local validElement = isElement(playerElement)

	if not validElement then
		return false
	end

	local randomSpawn = math.random(spawnsCount)
	local spawnData = playerSpawns[randomSpawn]
	local posX, posY, posZ, rotX = unpack(spawnData)
	local randomSkin = math.random(skinsCount)
	local skinID = playerSkins[randomSkin]

	posX, posY = posX + math.random(-3, 3), posY + math.random(-3, 3)

	spawnPlayer(playerElement, posX, posY, posZ, rotX, skinID, 0, 0, nil)
	fadeCamera(playerElement, true)
	setCameraTarget(playerElement)
end

function onPlayerJoin()
	playSpawnPlayer(source)
end

function onPlayerWasted()
	local playerRespawnTime = get("playerRespawnTime")

	playerRespawnTime = tonumber(playerRespawnTime) or 5000
	playerRespawnTime = playerRespawnTime < 0 and 0 or playerRespawnTime

	setTimer(playSpawnPlayer, playerRespawnTime, 1, source)
end

function onPlayerQuit()
	destroyPlayerVehicles(source)
end