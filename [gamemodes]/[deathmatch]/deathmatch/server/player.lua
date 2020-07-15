--
--	processPlayerJoin: triggered when a player joins the game
--
local function processPlayerJoin()
	_playerStates[source] = PLAYER_JOINED
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
--	deathmatchPlayerReady: triggered when a client is ready to play
--
-- triggered by the client post-onClientResourceStart
 function deathmatchPlayerReady()
	-- inform client of current game state by triggering certain events
	if getElementData(resourceRoot, "gameState") == GAME_STARTING then
		triggerClientEvent(source, "onClientDeathmatchMapStart", resourceRoot, _mapTitle, _mapAuthor, _fragLimit, _respawnTime)
	elseif getElementData(resourceRoot, "gameState") == GAME_IN_PROGRESS then
		triggerClientEvent(source, "onClientDeathmatchMapStart", resourceRoot, _mapTitle, _mapAuthor, _fragLimit, _respawnTime)
		triggerClientEvent(source, "onClientDeathmatchRoundStart", resourceRoot)
		spawnDeathmatchPlayer(source)
	elseif getElementData(resourceRoot, "gameState") == GAME_FINISHED then
		triggerClientEvent(source, "onClientDeathmatchRoundEnd", resourceRoot, false, false)
	end
	-- update player state
	_playerStates[source] = PLAYER_READY
end
addEvent("onDeathmatchPlayerReady", true)
addEventHandler("onDeathmatchPlayerReady", root, deathmatchPlayerReady)

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
	-- set timer to respawn player
	_respawnTimers[source] = setTimer(spawnDeathmatchPlayer, _respawnTime, 1, source)
end
