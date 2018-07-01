_DEGUG = false
SUSPECT_CHEATER_LIMIT = 15000
g_Root = getRootElement()

addEvent"onPlayerPickUpRacePickup"
addEvent"onPlayerRaceWasted"
addEvent"onPlayerFinish"

addEventHandler( "onPlayerPickUpRacePickup", g_Root,
	function( ... )
		triggerClientEvent( source, "onClientPlayerPickUpRacePickup", source, ... )
	end
)

addEventHandler( "onPlayerRaceWasted", g_Root,
	function( ... )
		triggerClientEvent( source, "onClientPlayerRaceWasted", source, ... )
	end
)

addEventHandler( "onPlayerFinish", g_Root,
	function( ... )
		triggerClientEvent( root, "onClientPlayerFinished", source, ... )
	end
)

function outputDebug( ... )
	if _DEGUG then
		outputDebugString( ... )
	end
end

-- Until xmlCopyFile works
function copyFile( fileName, newName )
	local newFile = fileCreate( newName )
	local oldFile = fileOpen( fileName, true )

	if newFile and oldFile then
		local buffer
		while not fileIsEOF( oldFile ) do
			buffer = fileRead( oldFile, 500 )
			fileWrite( newFile, buffer )
		end
		fileClose( newFile )
		fileClose( oldFile )
		return true
	end
	return false
end

-- Trying to avoid client/server event errors
CLIENT_SCRIPT_LOADED = {}

addEvent( "onRaceGhostResourceStarted", true )
addEventHandler( "onRaceGhostResourceStarted", getResourceRootElement(),
	function()
		CLIENT_SCRIPT_LOADED[client] = true
	end
)

addEventHandler( "onPlayerQuit", g_Root,
	function()
		CLIENT_SCRIPT_LOADED[source] = nil
	end
)

_triggerClientEvent = triggerClientEvent
function triggerClientEvent( triggerFor, name, theElement, ... )
	local params = { ... }
	if type( triggerFor ) == "string" then
		params = { theElement, ... }
		theElement = name
		name = triggerFor
		triggerFor = g_Root
	end

	if triggerFor == g_Root then
		local players = getElementsByType( "player" )
		for k, player in ipairs( players ) do
			if CLIENT_SCRIPT_LOADED[player] then
				_triggerClientEvent( player, name, theElement, unpack( params ) )
			else
				setTimer( triggerClientEvent, 1000, 1, player, name, theElement, unpack( params ) )
			end
		end
	else
		if isElement( triggerFor ) and getPlayerName( triggerFor ) then -- Make sure triggerFor is valid player so it doesn't create an infinite loop
			if CLIENT_SCRIPT_LOADED[triggerFor] then
				_triggerClientEvent( triggerFor, name, theElement, unpack( params ) )
			else
				setTimer( triggerClientEvent, 1000, 1, triggerFor, name, theElement, unpack( params ) )
			end
		end
	end
end


---------------------------------------------------------------------------
--
-- Recording validation
--
--
--
---------------------------------------------------------------------------

-- Check the best time is after the last recorded item time, but not too far afterwards
function isBesttimeValidForRecording( recording, bestTime )
	local terror = getRecordingBesttimeError( recording, bestTime )
	return terror >= 0 and terror < 2000
end

function getRecordingBesttimeError( recording, bestTime )
	-- get time of last item
	local t
	for idx = #recording,1,-1 do
		local v = recording[idx]
		t = tonumber(v.t)
		if t then
			break
		end
	end
	-- Calc error
	if t then
		return bestTime - t
	end
	return math.huge
end


-- Check the best time is not (much) less than the map toptime
function isBesttimeValidForMap( map, bestTime )
	local terror = getMapBesttimeError( map, bestTime )
	outputDebug ( "isBesttimeValidForMap dif:" .. tostring(terror) )
	return terror >= -1000
end

function getMapBesttimeError( map, bestTime )
	-- get time of map top time
	local t
	local mapName = getResourceInfo(map, "name") or getResourceName(map)
	local tableName = 'race maptimes Sprint ' .. mapName
	local res = executeSQLQuery( "SELECT * from ? WHERE rowid=1", tableName )
	if res and #res >= 1 then
		t = tonumber(res[1]["timeMs"])
	end

	-- Calc error
	if t then
		return bestTime - t
	end
	outputDebugString ( "ghost_racer: getMapBesttimeError - Can't find toptime for " .. tostring(mapName) )
	return 0
end
