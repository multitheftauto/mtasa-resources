_playerStates = {}

-- triggered by the client post-onClientResourceStart
addEvent("onDeathmatchPlayerReady", true)
addEventHandler("onDeathmatchPlayerReady", root, function()
	_playerStates[client] = PLAYER_READY

	-- spawn player if a round is already in progress
	if getElementData(resourceRoot, "gameState") == GAME_IN_PROGRESS then
		spawnDeathmatchPlayer(source)
		-- show the frag limit display and spawn the player if the game is in progress
		if _fragLimitDisplay then
			_fragLimitDisplay:sync(source)
		end
	end
end)

-- set default player state on gamemode start (clients will report in when ready)
addEventHandler("onResourceStart", resourceRoot, function()
	for _, player in ipairs(getElementsByType("player")) do
		_playerStates[player] = PLAYER_JOINED
	end
end)

--
--	spawnDeathmatchPlayer: spawns a player in deathmatch mode
--
function spawnDeathmatchPlayer(player)
	if not isElement(player) then
		return
	end
	-- spawn the player at a random spawnpoint
	exports.spawnmanager:spawnPlayerAtSpawnpoint(player)
	-- give player spawn weapons
	for weapon, ammo in pairs(_spawnWeapons) do
		giveWeapon(player, weapon, ammo, true)
	end
	-- reset their camera controls
	fadeCamera(player, true)
	setCameraTarget(player, player)
	-- delete the respawn timer
	_respawnTimers[player] = nil
	-- update player state
	_playerStates[player] = PLAYER_IN_GAME
end

--
--	processPlayerWasted: triggered when a player dies during a round
--
function processPlayerWasted(totalAmmo, killer, killerWeapon, bodypart)
	-- deduct 1 point for dying
	setElementData(source, "Score", getElementData(source, "Score") - 1)
	-- give the killer one point (if they exist)
	if isElement(killer) and killer ~= source then
		if getElementType(killer) == "vehicle" then
			killer = getVehicleOccupant(killer)
		end
		local killerScore = getElementData(killer, "Score") + 1
		setElementData(killer, "Score", killerScore)
		-- end the round if the killer has reached the frag limit
		if killerScore >= _fragLimit then
			return endRound(killer)
		end
	end
	-- update player ranks
	calculatePlayerRanks()
	-- tell client to begin on-screen countdown
	triggerClientEvent(source, "requestCountdown", source, _respawnTime)
	-- set timer to respawn player
	_respawnTimers[source] = setTimer(spawnDeathmatchPlayer, _respawnTime, 1, source)
end

--
--	processPlayerJoin: triggered when a player joins the game
--
local function processPlayerJoin()
	_playerStates[source] = PLAYER_JOINED
	-- initialize player score data
	setElementData(source, "Score", 0)
	setElementData(source, "Rank", "-")
	-- if a map is loaded, apply the loading camera matrix
	if _loadingCameraMatrix then
		setCameraMatrix(source, unpack(_loadingCameraMatrix))
	end
	calculatePlayerRanks()
	if getElementData(resourceRoot, "gameState") == GAME_FINISHED then
		-- show the game finished screen if the game is already over
		if _announcementDisplay then
			_announcementDisplay:sync(source)
		end
	elseif getElementData(resourceRoot, "gameState") == GAME_IN_PROGRESS then
		-- show the frag limit display and spawn the player if the game is in progress
		--[[if _fragLimitDisplay then
			_fragLimitDisplay:sync(source)
		end
		spawnDeathmatchPlayer(source)]]
	end
end
addEventHandler("onPlayerJoin", root, processPlayerJoin)

--
--	processPlayerQuit: cleans up after a player when they quit
--
local function processPlayerQuit()
	-- clear player state
	_playerStates[source] = nil
	-- kill player respawn timer, if it exists
	if _respawnTimers[source] then
		killTimer(_respawnTimers[source])
		_respawnTimers[source] = nil
	end
end
addEventHandler("onPlayerQuit", root, processPlayerQuit)
