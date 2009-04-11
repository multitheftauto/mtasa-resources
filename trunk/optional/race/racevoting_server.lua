--
-- racemidvote_server.lua
--
-- Mid-race random map vote and
-- NextMapVote handled in this file
--

local lastVoteStarterName = ''
local lastVoteStarterCount = 0

----------------------------------------------------------------------------
-- startMidMapVoteForRandomMap
--
-- Start the vote menu if during a race and more than a minute from the end
-- No messages if this was not started by a player
----------------------------------------------------------------------------
function startMidMapVoteForRandomMap(player)

    -- Check state and race time left
    if not stateAllowsRandomMapVote() or g_CurrentRaceMode:getTimeRemaining() < 60000 then
        if player then
            outputConsole( "I'm afraid I can't let you do that, " .. getPlayerName(player) .. ".", player )
        end 
        return
    end

    -- 'Hilariarse' messages
    if player then

        local playerName = getPlayerName(player)

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

    votemanager.stopPoll()

    -- Actual vote started here
    local pollDidStart = exports.votemanager:startPoll {
           title='Do you want to change to a random map?',
           percentage=51,
           timeout=15,
           allowchange=false,
           visibleTo=getRootElement(),
           [1]={'Yes', 'midMapVoteResult', getRootElement(), true},
           [2]={'No', 'midMapVoteResult', getRootElement(), false;default=true},
    }

    -- Change state if vote did start
    if pollDidStart then
        gotoState('MidMapVote')
    end

end
addCommandHandler('new',startMidMapVoteForRandomMap)


----------------------------------------------------------------------------
-- event midMapVoteResult
--
-- Called from the votemanager when the poll has completed
----------------------------------------------------------------------------
addEvent('midMapVoteResult')
addEventHandler('midMapVoteResult', getRootElement(),
	function( votedYes )
        -- Change state back
        if stateAllowsRandomMapVoteResult() then
            gotoState('Running')
            if votedYes then
                startRandomMap()
            else
                if lastVoteStarterName ~= '' then
                    outputVoteManager( 'Offical news: Everybody hates ' .. lastVoteStarterName )
                end
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



--
--
-- NextMapVote
--
--
--

local numPollOptions = 0

----------------------------------------------------------------------------
-- startNextMapVote
--
-- Start a votemap for the next map. Should only be called during the
-- race state 'NextMapSelect'
----------------------------------------------------------------------------
function startNextMapVote()

    votemanager.stopPoll()

    -- Get all maps
    local compatibleMaps = exports.mapmanager:getMapsCompatibleWithGamemode(getThisResource())
	
	-- limit it to eight random maps
	if #compatibleMaps > 8 then
		math.randomseed(getTickCount())
		repeat
			table.remove(compatibleMaps, math.random(1, #compatibleMaps))
		until #compatibleMaps == 8
	elseif #compatibleMaps < 2 then
		return false, errorCode.onlyOneCompatibleMap
	end

    -- mix up the list order
    for i,map in ipairs(compatibleMaps) do
        local swapWith = math.random(1, #compatibleMaps)
        local temp = compatibleMaps[i]
        compatibleMaps[i] = compatibleMaps[swapWith]
        compatibleMaps[swapWith] = temp
    end
	
	local poll = {
		title="Choose the next map:",
		visibleTo=getRootElement(),
		percentage=51,
		timeout=15,
        adjustwidth=50,
		allowchange=false;
		}
	
	for index, map in ipairs(compatibleMaps) do
		local mapName = getResourceInfo(map, "name") or getResourceName(map)
		table.insert(poll, {mapName, 'nextMapVoteResult', getRootElement(), map})
	end

	numPollOptions = #poll - 1
	local pollDidStart = exports.votemanager:startPoll(poll)

	if pollDidStart then
        gotoState('NextMapVote')
		addEventHandler("onPollEnd", getRootElement(), chooseRandomMap)
	end

    return pollDidStart
end


function chooseRandomMap (chosen)
	if not chosen then
		cancelEvent()
		math.randomseed(getTickCount())
		exports.votemanager:finishPoll(1)
	end
	removeEventHandler("onPollEnd", getRootElement(), chooseRandomMap)
end



----------------------------------------------------------------------------
-- event nextMapVoteResult
--
-- Called from the votemanager when the poll has completed
----------------------------------------------------------------------------
addEvent('nextMapVoteResult')
addEventHandler('nextMapVoteResult', getRootElement(),
	function( map )
        if stateAllowsNextMapVoteResult() then
            exports.mapmanager:changeGamemodeMap ( map )
        end
	end
)


---------------------------------------------------------------------------
--
-- Testing
--
--
--
---------------------------------------------------------------------------
addCommandHandler('forcevote',
    function( player, command, value )
		if not _TESTING and not isPlayerInACLGroup(player, 'Admin') then
			return
		end
        startNextMapVote()
    end
)
