local CAMERA_LOAD_DELAY = 5000 -- delay used at beginning and end of round (ms)
_respawnTimers = {} -- lookup table for player respawn timers

-- default map settings
local defaults = {
	fragLimit = 10,
	timeLimit = 600, --10 minutes
	respawnTime = 10,
	spawnWeapons = "22:100", -- "weaponID:ammo,weaponID:ammmo"
}

--
--	startDeathmatchMode: initializes the deathmatch gamemode
--
local function startDeathmatchMode()
	-- update game state
	setElementData(resourceRoot, "gameState", GAME_WAITING)
	-- add scoreboard columns
	exports.scoreboard:addScoreboardColumn("Score")
	exports.scoreboard:addScoreboardColumn("Rank", root, 1, 0.05)
	-- initialize announcement display
	_announcementDisplay = dxText:create("1",0.5,0.1)
	_announcementDisplay:font("bankgothic")
	_announcementDisplay:type("stroke", 1)
	-- initialize frag limit display
	_fragLimitDisplay = dxText:create ("2", 0.5, 35, "default-bold", 1 )
	_fragLimitDisplay:align("center","top")
	_fragLimitDisplay:type("stroke",1)
end
addEventHandler("onGamemodeStart", resourceRoot, startDeathmatchMode)

--
--	stopDeathmatchMode: cleans up the deathmatch gamemode
--
local function stopDeathmatchMode()
	-- cleanup player score data, make sure scoreboard isn't forced
	for _, player in ipairs(getElementsByType("player")) do
		exports.scoreboard:setPlayerScoreboardForced(player, false)
		removeElementData(player, "Score")
		removeElementData(player, "Rank")
	end
	-- remove scoreboard columns
	exports.scoreboard:removeScoreboardColumn("Score")
	exports.scoreboard:removeScoreboardColumn("Rank")
end
addEventHandler("onGamemodeStop", resourceRoot, stopDeathmatchMode)

--
--	startDeathmatchMap: initializes a deathmatch map
--
local function startDeathmatchMap(resource)
	-- initalize map settings
	_mapResource = resource
	local resourceName = getResourceName(resource)
	_fragLimit = tonumber(get(resourceName..".frag_limit")) and math.floor(tonumber(get(resourceName..".frag_limit"))) or defaults.fragLimit
	_timeLimit  = (tonumber(get(resourceName..".time_limit")) and math.floor(tonumber(get(resourceName..".time_limit"))) or defaults.timeLimit)*1000
	_respawnTime = (tonumber(get(resourceName..".respawn_time")) and math.floor(tonumber(get(resourceName..".respawn_time"))) or defaults.respawnTime)*1000
	_spawnWeapons = {}
	local weaponsString = get(resourceName..".spawn_weapons") or defaults.spawnWeapons
	for _, weaponSub in ipairs(split(weaponsString, 44)) do
		local weapon = tonumber(gettok(weaponSub, 1, 58))
		local ammo = tonumber(gettok(weaponSub, 2, 58))
		if weapon and ammo then
			_spawnWeapons[weapon] = ammo
		end
	end
	-- set timer to calculate and apply loading camera matrix next frame
	setTimer(function()
		_loadingCameraMatrix = calculateLoadingCameraMatrix()
		setCameraMatrix(root, unpack(_loadingCameraMatrix))
	end, 0, 1)
	-- update game state
	setElementData(resourceRoot, "gameState", GAME_STARTING)
	-- schedule round to begin
	setTimer(beginRound, CAMERA_LOAD_DELAY, 1)
end
addEventHandler("onGamemodeMapStart", root, startDeathmatchMap)

--
--	stopDeathmatchMap: cleans up a deathmatch map
--
local function stopDeathmatchMap(resource)
	-- clear the loading camera matrix
	_loadingCameraMatrix = nil
	-- end the round
	endRound(false, false)
	-- update game state
	setElementData(resourceRoot, "gameState", GAME_WAITING)
end
addEventHandler("onGamemodeMapStop", root, stopDeathmatchMap)

--
--	beginRound: begins the round
--
--[[local]] function beginRound()
	-- reset player score data
	for _, player in ipairs(getElementsByType("player")) do
		setElementData(player, "Score", 0)
		setElementData(player, "Rank", "-")
	end
	-- reset announcement display
	_announcementDisplay:color(255, 255, 255, 255)
	_announcementDisplay:visible(false)
	_announcementDisplay:sync()
	-- hide scoreboard
	exports.scoreboard:scoreboardSetForced(false)
	-- start round timer
	_missionTimer = exports.missiontimer:createMissionTimer(_timeLimit, true, true, 0.5, 20, true, "default-bold", 1)
	addEventHandler("onMissionTimerElapsed", _missionTimer, onTimeElapsed)
	-- show frag limit display
	_fragLimitDisplay:text(string.format("Frag Limit: %s", _fragLimit))
	_fragLimitDisplay:visible(true)
	_fragLimitDisplay:sync()
	-- attach player wasted handler
	addEventHandler("onPlayerWasted", root, processPlayerWasted)
	-- update game state
	setElementData(resourceRoot, "gameState", GAME_IN_PROGRESS)
	-- spawn players
	for _, player in ipairs(getElementsByType("player")) do
		if _playerStates[player] == PLAYER_READY then
			spawnDeathmatchPlayer(player)
		end
	end
end

--
--	endRound: ends the round
--
--[[local]] function endRound(winner, draw)
	-- remove player wasted handler
	removeEventHandler("onPlayerWasted", root, processPlayerWasted)
	-- kill player respawn timers
	for player, timer in pairs(_respawnTimers) do
		killTimer(timer)
	end
	_respawnTimers = {}
	-- kill mission timer
	if isElement(_missionTimer) then
		destroyElement(_missionTimer)
	end
	-- update game state
	setElementData(resourceRoot, "gameState", GAME_FINISHED)
	-- disable frag limit text
	_fragLimitDisplay:visible(false)
	_fragLimitDisplay:sync()
	-- announce winner
	if winner then
		_announcementDisplay:text(string.format("%s has won the match!", getPlayerName(winner)))
		_announcementDisplay:color(getPlayerNametagColor(winner))
		_announcementDisplay:visible(true)
		_announcementDisplay:sync()
	else
		if draw then
			_announcementDisplay:text("The match was a draw!")
			_announcementDisplay:color(255, 255, 255, 255)
			_announcementDisplay:visible(true)
			_announcementDisplay:sync()
		end
	end
	-- make all other players focus on the winner and begin to fade out camera
	for _, player in ipairs(getElementsByType("player")) do
		if player ~= winner then
			setCameraTarget(player, winner)
			toggleAllControls(player, true, true, false)
		end
		fadeCamera(player, false, CAMERA_LOAD_DELAY/1000)
		-- update player state
		_playerStates[player] = PLAYER_READY
	end
	-- if there was no match result, do not continue to the next match
	if not (winner or draw) then
		return
	end
	-- show the scoreboard
	exports.scoreboard:scoreboardSetForced(true)
	-- update game state
	setElementData(resourceRoot, "gameState", GAME_FINISHED)
	-- if mapcycler is running, signal that this round is over by triggering onRoundFinished
	-- otherwise, schedule the next round
	local mapcycler = getResourceFromName("mapcycler")
	if mapcycler and getResourceState(mapcycler) == "running" then
		triggerEvent("onRoundFinished", resourceRoot)
	else
		setTimer(beginRound, CAMERA_LOAD_DELAY * 2, 1)
	end
end

--
--	scoreSortingFunction: used to sort a table of players by their score
--
local function scoreSortingFunction(a, b)
	return (getElementData(a, "Score") or 0) > (getElementData(b, "Score") or 0)
end

--
--	onTimeElapsed: triggered when the missiontimer has elapsed
--
function onTimeElapsed()
	local players = getElementsByType("player")
	-- sort players by score
	table.sort(players, scoreSortingFunction)
	-- if the two top players have the same score, end the round in a draw
	-- otherwise, the player with the highest score wins
	if players[2] and getElementData(players[1], "Score") == getElementData(players[2], "Score") then
		endRound(false, true)
	else
		endRound(players[1])
	end
end

--
--	calculatePlayerRanks(): calculates player ranks
--
function calculatePlayerRanks()
	local ranks = {}
	local players = getElementsByType("player")
	table.sort(players, scoreSortingFunction)
	--Take into account people with the same score
	for i, player in ipairs(players) do
		local previousPlayer = players[i-1]
		if players[i-1] then
			local previousScore = getElementData(previousPlayer, "Score")
			local playerScore = getElementData(player, "Score")
			if previousScore == playerScore then
				setElementData (player, "Rank", getElementData(previousPlayer, "Rank"))
			else
				setElementData (player, "Rank", i)
			end
		else
			setElementData(player, "Rank", 1)
		end
	end
end

--
--	calculateCameraMatrix(): calculates the map loading camera matrix
--
function calculateLoadingCameraMatrix()
	local spawnpoints = getElementsByType("spawnpoint", getResourceRootElement(_mapResource))
	if #spawnpoints == 0 then
		return {0,0,0,0,0,0}
	end
	-- calculate our camera position by calculating an average spawnpoint position
	local camX, camY, camZ = 0, 0, 0
	for _, spawnpoint in ipairs(spawnpoints) do
		local x, y, z = getElementPosition(spawnpoint)
		camX = camX + x
		camY = camY + y
		camZ = camZ + z
	end
	camX, camY, camZ = camX/#spawnpoints, camY/#spawnpoints, camZ/#spawnpoints + 30
	-- use a random spawnpoint as the look-at position
	local lookAt = spawnpoints[math.random(1, #spawnpoints)]
	lookX, lookY, lookZ = getElementPosition(lookAt)
	return {camX, camY, camZ, lookX, lookY, lookZ}
end
