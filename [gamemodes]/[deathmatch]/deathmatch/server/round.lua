--
--	beginRound: begins the round
--
function beginRound()
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
--	endRound: ends the round
--
function endRound(winner, draw)
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