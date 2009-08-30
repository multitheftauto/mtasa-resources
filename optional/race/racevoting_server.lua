--
-- racemidvote_server.lua
--
-- Mid-race random map vote and
-- NextMapVote handled in this file
--

local lastVoteStarterName = ''
local lastVoteStarterCount = 0

----------------------------------------------------------------------------
-- displayHilariarseMessage
--
-- Comedy gold
----------------------------------------------------------------------------
function displayHilariarseMessage( player )
	if not player then
		lastVoteStarterName = ''
	else
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
		outputRace( msg )
	end
end


----------------------------------------------------------------------------
-- displayKillerPunchLine
--
-- Sewing kits available in the foyer
----------------------------------------------------------------------------
function displayKillerPunchLine( player )
	if lastVoteStarterName ~= '' then
		outputRace( 'Offical news: Everybody hates ' .. lastVoteStarterName )
	end
end


----------------------------------------------------------------------------
-- startMidMapVoteForRandomMap
--
-- Start the vote menu if during a race and more than a minute from the end
-- No messages if this was not started by a player
----------------------------------------------------------------------------
function startMidMapVoteForRandomMap(player)

	-- Check state and race time left
	if not stateAllowsRandomMapVote() or g_CurrentRaceMode:getTimeRemaining() < 30000 then
		if player then
			outputRace( "I'm afraid I can't let you do that, " .. getPlayerName(player) .. ".", player )
		end 
		return
	end

	displayHilariarseMessage( player )
	exports.votemanager:stopPoll()

	-- Actual vote started here
	local pollDidStart = exports.votemanager:startPoll {
			title='Do you want to change to a random map?',
			percentage=51,
			timeout=15,
			allowchange=true,
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
				displayKillerPunchLine()
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
		if g_MapInfo and name == g_MapInfo.resname then
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
		if not exports.mapmanager:changeGamemodeMap ( compatibleMaps[1], nil, true ) then
			problemChangingMap()
		end
	else
		outputWarning( 'startRandomMap failed' )
	end
end


----------------------------------------------------------------------------
-- outputRace
--
-- Race color is defined in the settings
----------------------------------------------------------------------------
function outputRace(message, toElement)
	toElement = toElement or g_Root
	local r, g, b = getColorFromString(string.upper(get("color")))
	if getElementType(toElement) == 'console' then
		outputServerLog(message)
	else
		outputChatBox(message, toElement, r, g, b)
		if toElement == rootElement then
			outputServerLog(message)
		end
	end
end


----------------------------------------------------------------------------
-- problemChangingMap
--
-- Sort it
----------------------------------------------------------------------------
function problemChangingMap()
	outputRace( 'Changing to random map in 5 seconds' )
	local currentMap = exports.mapmanager:getRunningGamemodeMap()
	setTimer(
        function()
			-- Check that something else hasn't already changed the map
			if currentMap == exports.mapmanager:getRunningGamemodeMap() then
	            startRandomMap()
			end
        end,
        math.random(4500,5500), 1 )
end



--
--
-- NextMapVote
--
--
--

local g_Poll

----------------------------------------------------------------------------
-- startNextMapVote
--
-- Start a votemap for the next map. Should only be called during the
-- race state 'NextMapSelect'
----------------------------------------------------------------------------
function startNextMapVote()

	exports.votemanager:stopPoll()

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
		adjustwidth=100,
		allowchange=true;
		}
	
	for index, map in ipairs(compatibleMaps) do
		local mapName = getResourceInfo(map, "name") or getResourceName(map)
		table.insert(poll, {mapName, 'nextMapVoteResult', getRootElement(), map})
	end
	
	local currentMap = exports.mapmanager:getRunningGamemodeMap()
	if currentMap then
		table.insert(poll, {"Play again", 'nextMapVoteResult', getRootElement(), currentMap})
	end

	-- Allow addons to modify the poll
	g_Poll = poll
	triggerEvent('onPollStarting', g_Root, poll )
	poll = g_Poll
	g_Poll = nil

	local pollDidStart = exports.votemanager:startPoll(poll)

	if pollDidStart then
		gotoState('NextMapVote')
		addEventHandler("onPollEnd", getRootElement(), chooseRandomMap)
	end

	return pollDidStart
end


-- Used by addons in response to onPollStarting
addEvent('onPollModified')
addEventHandler('onPollModified', getRootElement(),
	function( poll )
		g_Poll = poll
	end
)


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
			if not exports.mapmanager:changeGamemodeMap ( map, nil, true ) then
				problemChangingMap(map)
			end
		end
	end
)



----------------------------------------------------------------------------
-- startMidMapVoteForRestartMap
--
-- Start the vote menu to restart the current map if during a race
-- No messages if this was not started by a player
----------------------------------------------------------------------------
function startMidMapVoteForRestartMap(player)

	-- Check state and race time left
	if not stateAllowsRandomMapVote() then
		if player then
			outputRace( "I'm afraid I can't let you do that, " .. getPlayerName(player) .. ".", player )
		end 
		return
	end

	displayHilariarseMessage( player )
	exports.votemanager:stopPoll()

	-- Actual vote started here
	local pollDidStart = exports.votemanager:startPoll {
			title='Do you want to restart/n the current map?',
			percentage=51,
			timeout=15,
			allowchange=true,
			visibleTo=getRootElement(),
			[1]={'Yes', 'midMapRestartVoteResult', getRootElement(), true},
			[2]={'No', 'midMapRestartVoteResult', getRootElement(), false;default=true},
	}

	-- Change state if vote did start
	if pollDidStart then
		gotoState('MidMapVote')
	end

end
addCommandHandler('voteredo',startMidMapVoteForRestartMap)


----------------------------------------------------------------------------
-- event midMapRestartVoteResult
--
-- Called from the votemanager when the poll has completed
----------------------------------------------------------------------------
addEvent('midMapRestartVoteResult')
addEventHandler('midMapRestartVoteResult', getRootElement(),
	function( votedYes )
		-- Change state back
		if stateAllowsRandomMapVoteResult() then
			gotoState('Running')
			if votedYes then
				if not exports.mapmanager:changeGamemodeMap ( exports.mapmanager:getRunningGamemodeMap(), nil, true ) then
					problemChangingMap()
				end
			else
				displayKillerPunchLine()
			end
		end
	end
)

addCommandHandler('redo',
	function( player, command, value )
		if isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			local currentMap = exports.mapmanager:getRunningGamemodeMap()
			if currentMap then
				if not exports.mapmanager:changeGamemodeMap (currentMap, nil, true) then
					problemChangingMap()
				end
			else
				outputRace("You can't restart the map because no map is running", player)
			end
		else
			outputRace("You are not an Admin", player)
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
		if not _TESTING and not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			return
		end
		startNextMapVote()
	end
)
