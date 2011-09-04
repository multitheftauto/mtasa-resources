local spawnpoint

addEventHandler("onResourceStart", resourceRoot,
	function()
		spawnpoint = getRandomSpawnPoint()
		resetMapInfo()
		for i,player in ipairs(getElementsByType("player")) do
			spawn(player)
		end
	end
)

function spawn(player)
	if not isElement(player) then return end
	if get("spawnreset") == "onSpawn" then
		spawnpoint = getRandomSpawnPoint()
	end
	exports.spawnmanager:spawnPlayerAtSpawnpoint(player,spawnpoint,false)
	repeat until setElementModel(player,math.random(312))
	fadeCamera(player, true)
	setCameraTarget(player, player)
	showChat(player, true)
end

function getRandomSpawnPoint ()
	local spawnpoints = getElementsByType("spawnpoint")
	return spawnpoints[math.random(1,#spawnpoints)]
end

addEventHandler("onPlayerJoin", root,
	function()
		spawn(source)
	end
)

addEventHandler("onPlayerQuit",root,
	function ()
		if getPlayerCount() == 1 and get("spawnreset") == "onServerEmpty" then
			spawnpoint = getRandomSpawnPoint()
		end
	end
)

addEventHandler("onPlayerWasted", root,
	function()
		setTimer(spawn, 1800, 1, source)
	end
)