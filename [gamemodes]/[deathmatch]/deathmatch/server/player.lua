--
--	processPlayerJoin: triggered when a player joins the game
--
local function processPlayerJoin()
	_playerStates[source] = PLAYER_JOINED
	-- begin protecting player element data
	addEventHandler("onElementDataChange", source, checkElementData)
	-- initialize player score data
	setElementData(source, "Score", 0)
	setElementData(source, "Rank", "-")
	calculatePlayerRanks()
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

--
--	gamemodePlayerReady: triggered when a client is ready to play
--
-- triggered by the client post-onClientResourceStart
 local function gamemodePlayerReady(loadedResource)
	if loadedResource ~= resource then
		return
	end
	-- inform client of current game state by triggering certain events
	local gameState = getElementData(resourceRoot, "gameState")
	if gameState == GAME_STARTING then
		triggerClientEvent(source, "onClientGamemodeMapStart", resourceRoot, _mapTitle, _mapAuthor, _fragLimit, _respawnTime)
	elseif gameState == GAME_IN_PROGRESS then
		triggerClientEvent(source, "onClientGamemodeMapStart", resourceRoot, _mapTitle, _mapAuthor, _fragLimit, _respawnTime)
		triggerClientEvent(source, "onClientGamemodeRoundStart", resourceRoot)
		spawnGamemodePlayer(source)
	elseif gameState == GAME_FINISHED then
		triggerClientEvent(source, "onClientGamemodeRoundEnd", resourceRoot, false, false)
	end
	-- update player state
	_playerStates[source] = PLAYER_READY
end
addEventHandler("onPlayerResourceStart", root, gamemodePlayerReady)

--
--	spawnGamemodePlayer: spawns a player in Gamemode mode
--
function spawnGamemodePlayer(player)
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
		if _fragLimit > 0 and killerScore >= _fragLimit then
			return endRound(killer)
		end
		-- if respawn is disabled, end the round if this is the last player alive
		if _respawnTime == 0 then
			local isLastPlayerAlive = true
			local players = getElementsByType("player")
			for i = 1, #players do
				if not isPedDead(players[i]) and players[i] ~= killer and _playerStates[players[i]] == PLAYER_IN_GAME then
					iprint(players[i], " is the last player alive, respawn is disabled, ending round")
					isLastPlayerAlive = false
					break
				end
			end
			if isLastPlayerAlive then
				return endRound(killer)
			end
		end
	end
	-- update player ranks
	calculatePlayerRanks()
	-- set timer to respawn player
	if _respawnTime > 0 then
		_respawnTimers[source] = setTimer(spawnGamemodePlayer, _respawnTime + WASTED_CAMERA_DURATION, 1, source)
	end
end
