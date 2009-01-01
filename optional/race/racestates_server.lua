--
-- racestates_server.lua
--
-- Possible states are
--
-- NoMap            * No map loaded
-- LoadingMap       * Loading a map
-- PreRace          * Pre race 'Gentlemen, start you engiens'
-- GridCountdown    * Countdown
-- Racing           * Racing
-- 	  MidRaceVote      * Mid-race random map vote
-- SomeoneWon       * Someone won - Remaining race time is reduced to 'timeafterfirstfinish'
-- TimesUp			* Not everyone finished - (Immediately changes to PostRace)
-- EveryoneFinished	* Everyone finished - (Immediately changes to PostRace)
-- PostRace	        * Post race - '[Vote for] next map starts in 'n' seconds'
-- NextMapSelect    * Vote for next map or Random select
-- 


local currentRaceStateName = "undefined"


----------------------------------------------------------------------------
-- gotoState
--
-- Change the current state
----------------------------------------------------------------------------
function gotoState(stateName)
    outputDebugString( "Changing race state from " .. currentRaceStateName .. " to " .. stateName )
    currentRaceStateName = stateName
end


----------------------------------------------------------------------------
-- stateAllowsRandomMapVote
--
-- Check if the current state allows a random map vote to take place
----------------------------------------------------------------------------
function stateAllowsRandomMapVote()
    if currentRaceStateName == "Racing"        then    return true     end
    return false
end


----------------------------------------------------------------------------
-- stateAllowsKillPlayer
--
-- Check if the current state allows killPlayer
----------------------------------------------------------------------------
function stateAllowsKillPlayer()
    if currentRaceStateName == "Racing"        then    return true     end
    if currentRaceStateName == "MidRaceVote"   then    return true     end
    return false
end

