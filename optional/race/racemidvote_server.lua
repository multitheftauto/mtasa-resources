--
-- racemidvote_server.lua
--
-- Mid-race random map vote
--

local lastVoteStarterName = ''
local lastVoteStarterCount = 0

----------------------------------------------------------------------------
-- startMidRaceVoteForRandomMap
--
-- Start the vote menu if during a race and more than a minute from the end
-- No messages if this was not started by a player
----------------------------------------------------------------------------
function startMidRaceVoteForRandomMap(player)

    -- Check state and race time left
    if not stateAllowsRandomMapVote() or g_CurrentRaceMode:getTimeRemaining() < 60000 then
        if player then
            outputConsole( "I'm afraid I can't let you do that, " .. getClientName(player) .. ".", player )
        end 
        return
    end

    -- 'Hilariarse' messages
    if player then

        local playerName = getClientName(player)

        local msg = ''

        if playerName == lastVoteStarterName then
            lastVoteStarterCount = lastVoteStarterCount + 1
            if lastVoteStarterCount == 5 then
                msg = playerName .. ' started a vote. Hardly a suprise.'
            elseif lastVoteStarterCount == 10 then
                msg = 'Guess what! '..playerName .. ' started ANOTHER vote!'
            elseif lastVoteStarterCount < 5 then
                msg = playerName .. ' started another vote.'
            else
                msg = playerName .. ' continues to abuse the vote system.'
            end
        else
            lastVoteStarterCount = 0
            lastVoteStarterName = playerName
            msg = playerName .. ' started a vote.'
        end

        outputVoteManager( msg )
    end

    if not player then
        lastVoteStarterName = ''
    end

    -- Actual vote started here
    local pollDidStart = exports.votemanager:startPoll {
           title='Do you want to change to a random map?',
           percentage=51,
           timeout=15,
           allowchange=false,
           visibleTo=getRootElement(),
           [1]={'Yes', 'midRaceVoteResult', getRootElement(), true},
           [2]={'No', 'midRaceVoteResult', getRootElement(), false;default=true},
    }

    -- Change state if vote did start
    if pollDidStart then
        gotoState('MidRaceVote')
    end

end
addCommandHandler('new',startMidRaceVoteForRandomMap)


----------------------------------------------------------------------------
-- event midRaceVoteResult
--
-- Called from the votemanager when the poll has completed
----------------------------------------------------------------------------
addEvent('midRaceVoteResult')
addEventHandler('midRaceVoteResult', getRootElement(),
	function( votedYes )
        -- Change state back
        gotoState('Racing')
        if votedYes then
            startRandomMap()
        else
            if lastVoteStarterName ~= '' then
                outputVoteManager( 'Offical news: Everybody hates ' .. lastVoteStarterName )
            end
        end
	end
)


----------------------------------------------------------------------------
-- startRandomMap
--
-- Changes the current map to a random race map
----------------------------------------------------------------------------
function startRandomMap()

    -- Get all maps
    local compatibleMaps = exports.mapmanager:getMapsCompatibleWithGamemode(getThisResource())

    -- Remove current one
    for i,map in ipairs(compatibleMaps) do
        local name = getResourceName(map)
        if name == g_MapInfo.resname then
	        table.removevalue(compatibleMaps, map)
            break
        end
    end

    -- Remove all but one
    math.randomseed(getTickCount())
    repeat
	    table.remove(compatibleMaps, math.random(1, #compatibleMaps))
    until #compatibleMaps < 2

    -- If we have one, launch it!
    if #compatibleMaps == 1 then
        exports.mapmanager:changeGamemodeMap ( compatibleMaps[1] )
    else
        outputWarning( 'startRandomMap failed' )
    end
end


----------------------------------------------------------------------------
-- outputVoteManager
--
-- Same color as votemanager
----------------------------------------------------------------------------
function outputVoteManager(message, toElement)
	toElement = toElement or g_Root
	local r, g, b = getColorFromString(string.upper(get('votemanager.color')))
	if getElementType(toElement) == 'console' then
		outputServerLog(message)
	else
		outputChatBox(message, toElement, r, g, b)
		if toElement == rootElement then
			outputServerLog(message)
		end
	end
end