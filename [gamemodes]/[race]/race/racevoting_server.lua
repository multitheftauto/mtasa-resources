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
-- Start the vote menu if during a race and more than 30 seconds from the end
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

	-- Handle forced nextmap setting
	if maybeApplyForcedNextMap() then
		return
	end

	-- Get a random map chosen from the 10% of least recently player maps, with enough spawn points for all the players (if required)
	local map = getRandomMapCompatibleWithGamemode( getThisResource(), 10, g_GameOptions.ghostmode and 0 or getTotalPlayerCount() )
	if map then
		g_IgnoreSpawnCountProblems = map	-- Uber hack 4000
		if not exports.mapmanager:changeGamemodeMap ( map, nil, true ) then
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
		if toElement == rootElement then
			outputServerLog(message)
		end
		if getElementType(toElement) == 'player' then
			message = '[PM] ' .. message
		end
		outputChatBox(message, toElement, r, g, b)
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
	TimerManager.createTimerFor("resource","mapproblem"):setTimer(
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

	-- Handle forced nextmap setting
	if maybeApplyForcedNextMap() then
		return
	end

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
				problemChangingMap()
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
	if not stateAllowsRestartMapVote() then
		if player then
			outputRace( "I'm afraid I can't let you do that, " .. getPlayerName(player) .. ".", player )
		end
		return
	end

	displayHilariarseMessage( player )
	exports.votemanager:stopPoll()

	-- Actual vote started here
	local pollDidStart = exports.votemanager:startPoll {
			title='Do you want to restart the current map?',
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
				outputChatBox('Map restarted by ' .. getPlayerName(player), g_Root, 0, 240, 0)
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


addCommandHandler('random',
	function( player, command, value )
		if isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			if not stateAllowsRandomMapVote() or g_CurrentRaceMode:getTimeRemaining() < 1000 then
				outputRace( "Random command only works during a race and when no polls are running.", player )
			else
				local choice = {'curtailed', 'cut short', 'terminated', 'given the heave ho', 'dropkicked', 'expunged', 'put out of our misery', 'got rid of'}
				outputChatBox('Current map ' .. choice[math.random( 1, #choice )] .. ' by ' .. getPlayerName(player), g_Root, 0, 240, 0)
				startRandomMap()
			end
		end
	end
)


----------------------------------------------------------------------------
-- maybeApplyForcedNextMap
--
-- Returns true if nextmap did override
----------------------------------------------------------------------------
function maybeApplyForcedNextMap()
	if g_ForcedNextMap then
		local map = g_ForcedNextMap
		g_ForcedNextMap = nil
		g_IgnoreSpawnCountProblems = map	-- Uber hack 4000
		if not exports.mapmanager:changeGamemodeMap ( map, nil, true ) then
			outputWarning( 'Forced next map failed' )
			return false
		end
		return true
	end
	return false
end

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


---------------------------------------------------------------------------
--
-- getRandomMapCompatibleWithGamemode
--
-- This should go in mapmanager, but ACL needs doing
--
---------------------------------------------------------------------------

addEventHandler('onResourceStart', getRootElement(),
	function( res )
		if exports.mapmanager:isMap( res ) then
			setMapLastTimePlayed( res )
		end
	end
)

function getRandomMapCompatibleWithGamemode( gamemode, oldestPercentage, minSpawnCount )

	-- Get all relevant maps
	local compatibleMaps = exports.mapmanager:getMapsCompatibleWithGamemode( gamemode )

	if #compatibleMaps == 0 then
		outputDebugString( 'getRandomMapCompatibleWithGamemode: No maps.', 1 )
		return false
	end

	-- Sort maps by time since played
	local sortList = {}
	for i,map in ipairs(compatibleMaps) do
		sortList[i] = {}
		sortList[i].map = map
		sortList[i].lastTimePlayed = getMapLastTimePlayed( map )
	end

	table.sort( sortList, function(a, b) return a.lastTimePlayed > b.lastTimePlayed end )

	-- Use the bottom n% of maps as the initial selection pool
	local cutoff = #sortList - math.floor( #sortList * oldestPercentage / 100 )

	outputDebug( 'RANDMAP', 'getRandomMapCompatibleWithGamemode' )
	outputDebug( 'RANDMAP', ''
			.. ' minSpawns:' .. tostring( minSpawnCount )
			.. ' nummaps:' .. tostring( #sortList )
			.. ' cutoff:' .. tostring( cutoff )
			.. ' poolsize:' .. tostring( #sortList - cutoff + 1 )
			)

	math.randomseed( getTickCount() % 50000 )
	local fallbackMap
	while #sortList > 0 do
		-- Get random item from range
		local idx = math.random( cutoff, #sortList )
		local map = sortList[idx].map

		if not minSpawnCount or minSpawnCount <= getMapSpawnPointCount( map ) then
			outputDebug( 'RANDMAP', ''
					.. ' ++ using map:' .. tostring( getResourceName( map ) )
					.. ' spawns:' .. tostring( getMapSpawnPointCount( map ) )
					.. ' age:' .. tostring( getRealTimeSeconds() - getMapLastTimePlayed( map ) )
					)
			return map
		end

		-- Remember best match incase we cant find any with enough spawn points
		if not fallbackMap or getMapSpawnPointCount( fallbackMap ) < getMapSpawnPointCount( map ) then
			fallbackMap = map
		end

		outputDebug( 'RANDMAP', ''
				.. ' skip:' .. tostring( getResourceName( map ) )
				.. ' spawns:' .. tostring( getMapSpawnPointCount( map ) )
				.. ' age:' .. tostring( getRealTimeSeconds() - getMapLastTimePlayed( map ) )
				)

		-- If map not good enough, remove from the list and try another
		table.remove( sortList, idx )
		-- Move cutoff up the list if required
		cutoff = math.min( cutoff, #sortList )
	end

	-- No maps found - use best match
	outputDebug( 'RANDMAP', ''
			.. ' ** fallback map:' .. tostring( getResourceName( fallbackMap ) )
			.. ' spawns:' .. tostring( getMapSpawnPointCount( fallbackMap ) )
			.. ' ageLstPlyd:' .. tostring( getRealTimeSeconds() - getMapLastTimePlayed( fallbackMap ) )
			)
	return fallbackMap
end

-- Look for spawnpoints in map file
-- Not very quick as it loads the map file everytime
function countSpawnPointsInMap(res)
	local count = 0
	local meta = xmlLoadFile(':' .. getResourceName(res) .. '/' .. 'meta.xml')
	if meta then
		local mapnode = xmlFindChild(meta, 'map', 0) or xmlFindChild(meta, 'race', 0)
		local filename = mapnode and xmlNodeGetAttribute(mapnode, 'src')
		xmlUnloadFile(meta)
		if filename then
			local map = xmlLoadFile(':' .. getResourceName(res) .. '/' .. filename)
			if map then
				while xmlFindChild(map, 'spawnpoint', count) do
					count = count + 1
				end
				xmlUnloadFile(map)
			end
		end
	end
	return count
end

---------------------------------------------------------------------------
-- g_MapInfoList access
---------------------------------------------------------------------------
local g_MapInfoList

function getMapLastTimePlayed( map )
	local mapInfo = getMapInfo( map )
	return mapInfo.lastTimePlayed or 0
end

function setMapLastTimePlayed( map, time )
	time = time or getRealTimeSeconds()
	local mapInfo = getMapInfo( map )
	mapInfo.lastTimePlayed = time
	mapInfo.playedCount = ( mapInfo.playedCount or 0 ) + 1
	saveMapInfoItem( map, mapInfo )
end

function getMapSpawnPointCount( map )
	local mapInfo = getMapInfo( map )
	if not mapInfo.spawnPointCount then
		mapInfo.spawnPointCount = countSpawnPointsInMap( map )
		saveMapInfoItem( map, mapInfo )
	end
	return mapInfo.spawnPointCount
end

function getMapInfo( map )
	if not g_MapInfoList then
		loadMapInfoAll()
	end
	if not g_MapInfoList[map] then
		g_MapInfoList[map] = {}
	end
	local mapInfo = g_MapInfoList[map]
	if mapInfo.loadTime ~= getResourceLoadTime(map) then
		-- Reset or clear data that may change between loads
		mapInfo.loadTime = getResourceLoadTime( map )
		mapInfo.spawnPointCount = false
	end
	return mapInfo
end


---------------------------------------------------------------------------
-- g_MapInfoList <-> database
---------------------------------------------------------------------------
function sqlString(value)
	value = tostring(value) or ''
	return "'" .. value:gsub( "(['])", "''" ) .. "'"
end

function sqlInt(value)
	return tonumber(value) or 0
end

function getTableName(value)
	return sqlString( 'race_mapmanager_maps' )
end

function ensureTableExists()
	local cmd = ( 'CREATE TABLE IF NOT EXISTS ' .. getTableName() .. ' ('
					 .. 'resName TEXT UNIQUE'
					 .. ', infoName TEXT '
					 .. ', spawnPointCount INTEGER'
					 .. ', playedCount INTEGER'
					 .. ', lastTimePlayedText TEXT'
					 .. ', lastTimePlayed INTEGER'
			.. ')' )
	executeSQLQuery( cmd )
end

-- Load all rows into g_MapInfoList
function loadMapInfoAll()
	ensureTableExists()
	local rows = executeSQLQuery( 'SELECT * FROM ' .. getTableName() )
	g_MapInfoList = {}
	for i,row in ipairs(rows) do
		local map = getResourceFromName( row.resName )
		if map then
			local mapInfo = getMapInfo( map )
			mapInfo.playedCount = row.playedCount
			mapInfo.lastTimePlayed = row.lastTimePlayed
		end
	end
end

-- Save one row
function saveMapInfoItem( map, info )
	executeSQLQuery( 'BEGIN TRANSACTION' )

	ensureTableExists()

	local cmd = ( 'INSERT OR IGNORE INTO ' .. getTableName() .. ' VALUES ('
					.. ''		.. sqlString( getResourceName( map ) )
					.. ','		.. sqlString( "" )
					.. ','		.. sqlInt( 0 )
					.. ','		.. sqlInt( 0 )
					.. ','		.. sqlString( "" )
					.. ','		.. sqlInt( 0 )
			.. ')' )
	executeSQLQuery( cmd )

	cmd = ( 'UPDATE ' .. getTableName() .. ' SET '
					.. 'infoName='				.. sqlString( getResourceInfo( map, "name" ) )
					.. ',spawnPointCount='		.. sqlInt( info.spawnPointCount )
					.. ',playedCount='			.. sqlInt( info.playedCount )
					.. ',lastTimePlayedText='	.. sqlString( info.lastTimePlayed and info.lastTimePlayed > 0 and getRealDateTimeString(getRealTime(info.lastTimePlayed)) or "-" )
					.. ',lastTimePlayed='		.. sqlInt( info.lastTimePlayed )
			.. ' WHERE '
					.. 'resName='				.. sqlString( getResourceName( map ) )
			 )
	executeSQLQuery( cmd )

	executeSQLQuery( 'END TRANSACTION' )
end


---------------------------------------------------------------------------
--
-- More things that should go in mapmanager
--
---------------------------------------------------------------------------

addCommandHandler('checkmap',
	function( player, command, ... )
		local query = #{...}>0 and table.concat({...},' ') or nil
		if query then
			local map, errormsg = findMap( query )
			outputRace( errormsg, player )
		end
	end
)

addCommandHandler('nextmap',
	function( player, command, ... )
		local query = #{...}>0 and table.concat({...},' ') or nil
		if not query then
			if g_ForcedNextMap then
				outputRace( 'Next map is ' .. getMapName( g_ForcedNextMap ), player )
			else
				outputRace( 'Next map is not set', player )
			end
			return
		end
		if not _TESTING and not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			return
		end
		local map, errormsg = findMap( query )
		if not map then
			outputRace( errormsg, player )
			return
		end
		if g_ForcedNextMap == map then
			outputRace( 'Next map is already set to ' .. getMapName( g_ForcedNextMap ), player )
			return
		end
		g_ForcedNextMap = map
		outputChatBox('Next map set to ' .. getMapName( g_ForcedNextMap ) .. ' by ' .. getPlayerName( player ), g_Root, 0, 240, 0)
	end
)

--Find a map which matches, or nil and a text message if there is not one match
function findMap( query )
	local maps = findMaps( query )

	-- Make status string
	local status = "Found " .. #maps .. " match" .. ( #maps==1 and "" or "es" )
	for i=1,math.min(5,#maps) do
		status = status .. ( i==1 and ": " or ", " ) .. "'" .. getMapName( maps[i] ) .. "'"
	end
	if #maps > 5 then
		status = status .. " (" .. #maps - 5 .. " more)"
	end

	if #maps == 0 then
		return nil, status .. " for '" .. query .. "'"
	end
	if #maps == 1 then
		return maps[1], status
	end
	if #maps > 1 then
		return nil, status
	end
end

-- Find all maps which match the query string
function findMaps( query )
	local results = {}
	--escape all meta chars
	query = string.gsub(query, "([%*%+%?%.%(%)%[%]%{%}%\%/%|%^%$%-])","%%%1")
	-- Loop through and find matching maps
	for i,resource in ipairs(exports.mapmanager:getMapsCompatibleWithGamemode(getThisResource())) do
		local resName = getResourceName( resource )
		local infoName = getMapName( resource  )

		-- Look for exact match first
		if query == resName or query == infoName then
			return {resource}
		end

		-- Find match for query within infoName
		if string.find( infoName:lower(), query:lower() ) then
			table.insert( results, resource )
		end
	end
	return results
end

function getMapName( map )
	return getResourceInfo( map, "name" ) or getResourceName( map ) or "unknown"
end
