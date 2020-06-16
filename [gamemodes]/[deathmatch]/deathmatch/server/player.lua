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
--	TODO: handle players joining mid-round more gracefully
--
local function processPlayerJoin()
	iprint("p")
	-- initialize player score data
	setElementData(source, "Score", 0)
	setElementData(source, "Rank", "-")
	-- if a map is loaded, apply the loading camera matrix
	if _loadingCameraMatrix then
		setCameraMatrix(source, unpack(_loadingCameraMatrix))
	end
	calculatePlayerRanks()
	if _fragLimitDisplay then
		_fragLimitDisplay:sync(source)
	end
	if _announcementDisplay then
		_announcementDisplay:sync(source)
	end
	spawnDeathmatchPlayer(source)
end
addEventHandler("onPlayerJoin", root, processPlayerJoin)

--
--	processPlayerQuit: cleans up after a player when they quit
--
local function processPlayerQuit()
	-- kill player respawn timer, if it exists
	if _respawnTimers[source] then
		killTimer(_respawnTimers[source])
		_respawnTimers[source] = nil
	end
end
addEventHandler("onPlayerQuit", root, processPlayerQuit)
