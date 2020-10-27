--
-- racestates_server.lua
--
-- Possible states are
--
-- undefined        *
-- NoMap            * No map loaded
-- LoadingMap       * Loading a map
-- PreGridCountdown * Pre race 'Gentlemen, start you engiens'
-- GridCountdown    * Countdown
-- Running          * Racing
-- 	  MidMapVote    * Mid-race random map vote
-- SomeoneWon       * Someone won - Remaining race time is reduced to 'timeafterfirstfinish'
-- TimesUp			* Not everyone finished - (Immediately changes to PostFinish)
-- EveryoneFinished	* Everyone finished - (Immediately changes to PostFinish)
-- PostFinish	    * Post race - '[Vote for] next map starts in 'n' seconds'
-- NextMapSelect    * Vote for next map or Random select
-- NextMapVote      * Vote for next map
-- ResourceStopping *
--


local currentRaceStateName = 'undefined'


----------------------------------------------------------------------------
-- gotoState
--
-- Change the current state
----------------------------------------------------------------------------
function gotoState(stateName)
    outputDebug( 'STATE', 'Changing race state from ' .. currentRaceStateName .. ' to ' .. stateName )

    -- If leaving a state dedicated to voting, ensure the voting stops
    if currentRaceStateName == 'MidMapVote' or currentRaceStateName == 'NextMapVote' then
        exports.votemanager:stopPoll()
    end

    if currentRaceStateName ~= stateName then
		triggerEvent('onRaceStateChanging', g_Root, stateName, currentRaceStateName )
		currentRaceStateName = stateName
	end
--[[
    local levelInfo = getElementByID('mylevelinfo')
    if not levelInfo then
        levelInfo = createElement( 'levelinfo', 'mylevelinfo' )
    end
    if levelInfo then
        setElementData( levelInfo, 'state', currentRaceStateName )
    end
--]]
end


----------------------------------------------------------------------------
-- stateAllowsRandomMapVote
--
-- Check if the current state allows a random map vote to take place
----------------------------------------------------------------------------
function stateAllowsRandomMapVote()
    if currentRaceStateName == 'Running'        then    return true     end
    return false
end

----------------------------------------------------------------------------
-- stateAllowsRestartMapVote
--
-- Check if the current state allows a random map vote to take place
----------------------------------------------------------------------------
function stateAllowsRestartMapVote()
    if currentRaceStateName == 'Running'        then    return true     end
	if currentRaceStateName == 'SomeoneWon'   then    return true     end
    return false
end

----------------------------------------------------------------------------
-- stateAllowsRandomMapVoteResult
--
-- Check if the current state allows a random map vote result to apply
----------------------------------------------------------------------------
function stateAllowsRandomMapVoteResult()
    if currentRaceStateName == 'MidMapVote'        then    return true     end
    return false
end


----------------------------------------------------------------------------
-- stateAllowsNextMapVoteResult
--
-- Check if the current state allows a next map vote to apply
----------------------------------------------------------------------------
function stateAllowsNextMapVoteResult()
    if currentRaceStateName == 'NextMapVote'        then    return true     end
    return false
end


----------------------------------------------------------------------------
-- stateAllowsKillPlayer
--
-- Check if the current state allows killPlayer
----------------------------------------------------------------------------
function stateAllowsKillPlayer()
    if currentRaceStateName == 'Running'        then    return true     end
    if currentRaceStateName == 'MidMapVote'   then    return true     end
    if currentRaceStateName == 'SomeoneWon'   then    return true     end
    return false
end


----------------------------------------------------------------------------
-- stateAllowsCheckpoint
--
-- Check if the current state allows checkpoint processing
----------------------------------------------------------------------------
function stateAllowsCheckpoint()
    if currentRaceStateName == 'Running'        then    return true     end
    if currentRaceStateName == 'MidMapVote'   then    return true     end
    if currentRaceStateName == 'SomeoneWon'   then    return true     end
    return false
end


----------------------------------------------------------------------------
-- stateAllowsPostFinish
--
-- Check if the current state allows the post finish state to to entered
----------------------------------------------------------------------------
function stateAllowsPostFinish()
    if currentRaceStateName == 'PostFinish'         then    return false     end
    if currentRaceStateName == 'NextMapSelect'      then    return false     end
    if currentRaceStateName == 'NextMapVote'        then    return false     end
	if currentRaceStateName == 'LoadingMap'			then	return false	end
	return true
end


----------------------------------------------------------------------------
-- stateAllowsNextMapSelect
--
-- Check if the current state allows the NextMapSelect state to to entered
----------------------------------------------------------------------------
function stateAllowsNextMapSelect()
	if currentRaceStateName == 'PostFinish'			then	return true		end
	return false
end


----------------------------------------------------------------------------
-- stateAllowsNotReadyMessage
--
-- Check if the current state allows the 'other players not ready' message to be displayed
----------------------------------------------------------------------------
function stateAllowsNotReadyMessage()
    if currentRaceStateName == 'LoadingMap'         then    return true     end
    if currentRaceStateName == 'PreGridCountdown'   then    return true     end
    return false
end


----------------------------------------------------------------------------
-- stateAllowsGridCountdown
--
-- Check if the current state allows the grid countdown to start
----------------------------------------------------------------------------
function stateAllowsGridCountdown()
    if currentRaceStateName == 'PreGridCountdown'   then    return true     end
    return false
end


----------------------------------------------------------------------------
-- stateAllowsManualSpectate
--
-- Check if the current state allows a player to manualy select to spectate
----------------------------------------------------------------------------
function stateAllowsManualSpectate()
	if currentRaceStateName == 'Running'			then	return true	 end
	if currentRaceStateName == 'MidMapVote'			then	return true	 end
	if currentRaceStateName == 'SomeoneWon'			then	return true	 end
	return false
end


----------------------------------------------------------------------------
-- stateAllowsSpawnInNoRespawnMap
--
-- Check if the current state allows a joining player to spawn when the current mode/map is no respawn
----------------------------------------------------------------------------
function stateAllowsSpawnInNoRespawnMap()
	if currentRaceStateName == 'NoMap'				then	return true	 end
	if currentRaceStateName == 'LoadingMap'			then	return true	 end
	if currentRaceStateName == 'PreGridCountdown'	then	return true	 end
	if currentRaceStateName == 'GridCountdown'		then	return true	 end
	return false
end


----------------------------------------------------------------------------
-- stateAllowsTimesUp
--
-- Check if the current state allows 'TimesUp' state to be entered
----------------------------------------------------------------------------
function stateAllowsTimesUp()
	if currentRaceStateName == 'PostFinish'			then	return false	 end
	if currentRaceStateName == 'NextMapSelect'		then	return false	 end
	if currentRaceStateName == 'NextMapVote'		then	return false	 end
	return true
end
