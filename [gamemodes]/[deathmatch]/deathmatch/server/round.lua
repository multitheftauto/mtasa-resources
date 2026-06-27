--
--	beginRound: begins the round
--
function beginRound()
	-- destroy start timer
	destroyElement(_startTimer)
	-- start round timer
	if _timeLimit > 0 then
		_missionTimer = exports.missiontimer:createMissionTimer(_timeLimit, true, "%m:%s", 0.5, 20, true, "default-bold", 1)
		addEventHandler("onMissionTimerElapsed", _missionTimer, onTimeElapsed)
	end
	-- attach player wasted handler
	addEventHandler("onPlayerWasted", root, processPlayerWasted)
	-- update game state
	setElementData(resourceRoot, "gameState", GAME_IN_PROGRESS)
	-- spawn players
	local players = getElementsByType("player")
	for i = 1, #players do
		setElementData(players[i], "Score", 0)
		setElementData(players[i], "Rank", "-")
		if _playerStates[players[i]] == PLAYER_READY then
            spawnGamemodePlayer(players[i])
            triggerClientEvent(players[i], "onClientGamemodeRoundStart", resourceRoot)
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
function endRound(winner, draw, aborted)
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
	-- make all other players focus on the winner and begin to fade out camera
	local players = getElementsByType("player")
    for i = 1, #players do
		if _playerStates[players[i]] ~= PLAYER_JOINED then
            -- update player state
            _playerStates[players[i]] = PLAYER_READY
			-- inform client round is over
			triggerClientEvent(players[i], "onClientGamemodeRoundEnd", resourceRoot, winner, draw, aborted)
        end
	end
	-- don't cycle the map if the round was aborted (map resource was stopped)
	if aborted then
		return
	end
	-- if mapcycler is running, signal that this round is over by triggering onRoundFinished
	-- otherwise, schedule the next round
	local mapcycler = getResourceFromName("mapcycler")
	if mapcycler and getResourceState(mapcycler) == "running" then
		triggerEvent("onRoundFinished", resourceRoot)
	else
		setTimer(beginRound, ROUND_START_DELAY * 2, 1)
	end
end
