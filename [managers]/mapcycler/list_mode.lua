local rootElement = getRootElement()

local listMode
local configPath = "mapcycle.xml"
local gameList = {}
local nextGameIndex
-- shuffle mode
local notPlayedGames

-- error codes table
local errorCode = {
	modeNotSpecified = "The gamemode is not specified.",
	modeDoesntExist = "The specified gamemode doesn't exist.",
	modeInvalid = "The specified gamemode resource is not a gamemode.",

	mapDoesntExist = "The specified map doesn't exist.",
	mapInvalid = "The specified map resource is not a map.",

	roundsInvalid = "The number of rounds is not a valid number.",
	roundsZero = "The number of rounds can't be zero.",
}

function startCycler_list()
	local isCycleValid = readCycleXml(configPath)
	assert(isCycleValid, "The cycler xml list is not valid.")

	addCommandHandler("nextmode", outputNextMode)
	addCommandHandler("nextmap", outputNextMode)
	addCommandHandler("skipmap", skipMap, true)

	cycleMap_list()

	addEventHandler("onRoundFinished", rootElement, roundCounter)
end

function cycleMap_list()
	local gameIndex
	if listMode == "shuffle" then
		if #notPlayedGames > 1 then
			-- get the new game
			gameIndex = nextGameIndex
			-- remove it from the shuffle table
			table.remove(notPlayedGames, gameIndex)
			-- get a game at random to be the next game
			nextGameIndex = notPlayedGames[math.random(1, #notPlayedGames)]
		else
			-- get the last game
			gameIndex = notPlayedGames[1]
			-- repopulate the shuffle table
			notPlayedGames = {}
			for i=1, #gameList do
				table.insert(notPlayedGames, i)
			end
			-- get a new random starting index
			nextGameIndex = notPlayedGames[math.random(1, #notPlayedGames)]
		end
	elseif listMode == "sequential" then
		-- get the next game
		gameIndex = nextGameIndex
		-- increment next game index
		nextGameIndex = nextGameIndex + 1
		-- go back to the beggining if there's no more games
		if not gameList[nextGameIndex] then
			nextGameIndex = 1
		end
	end

	local gameInfo = gameList[gameIndex]

	local success
	if gameInfo.map then
		success = exports.mapmanager:changeGamemodeMap(gameInfo.map, gameInfo.mode)
	else
		success = exports.mapmanager:changeGamemode(gameInfo.mode)
	end

	if not success then
		return cycleMap_list()
	end

	if gameInfo.rounds then
		remainingRounds = gameInfo.rounds
	end

	return true
end

function readCycleXml(xmlFile)
	local cycleRoot = xmlLoadFile(xmlFile)
	if not cycleRoot then
		outputCyclerDebugString("The cycler configuration XML is missing.",1)
		return false
	end

	local isAnyNodeValid = false
	local nodeIndex = 0
	while true do
		local gameNode = xmlFindChild(cycleRoot, "game", nodeIndex)
		if gameNode then
			local gameInfo, returnedErrorCode = getGameNodeInfo(gameNode)
			if gameInfo then
				table.insert(gameList, gameInfo)
				isAnyNodeValid = true

				if not gameInfo.rounds then
					outputCyclerDebugString("The game #"..(nodeIndex+1).." defined on the configuration XML has no ending condition.",2)
				end
			else
				outputCyclerDebugString("Game node #"..(nodeIndex+1).." invalid: "..returnedErrorCode, 1)
			end
			nodeIndex = nodeIndex + 1
		else
			break
		end
	end

	-- choose sequential if the list is 1 item big
	if nodeIndex == 1 then
		listMode = "sequential"
		nextGameIndex = 1
	else
		listMode = xmlNodeGetAttribute(cycleRoot, "type")
		-- default mode to sequential
		if listMode ~= "shuffle" then
			listMode = "sequential"
			nextGameIndex = 1
		else
			notPlayedGames = {}
			-- populate the shuffle table
			for i=1, nodeIndex do
				table.insert(notPlayedGames, i)
			end
			-- get a random starting index
			nextGameIndex = notPlayedGames[math.random(1, #notPlayedGames)]
		end
	end
	xmlUnloadFile ( cycleRoot )

	if isAnyNodeValid then
		return true
	else
		outputCyclerDebugString("The cycler configuration XML has no valid maps.",1)
		return false
	end
end

function getGameNodeInfo(gameNode)
	local info = {}

	-- get the gamemode, and verify it's a gamemode
	local modeName = xmlNodeGetAttribute(gameNode, "mode")
	if not modeName then
		return false, errorCode.modeNotSpecified
	end
	info.mode = getResourceFromName(modeName)
	if not info.mode then
		return false, errorCode.modeDoesntExist
	end
	if exports.mapmanager:isGamemode(info.mode) ~= true then
		return false, errorCode.modeInvalid
	end

	-- get the map, and verify it's a valid map if there's one
	local mapName = xmlNodeGetAttribute(gameNode, "map")
	if mapName then
		info.map = getResourceFromName(mapName)
		if not info.map then
			return false, errorCode.mapDoesntExist
		end
		if exports.mapmanager:isMap(info.map) ~= true then
			return false, errorCode.mapInvalid
		end
	end

	-- get the number of rounds
	local roundsString = xmlNodeGetAttribute(gameNode, "rounds")
	if roundsString then
		info.rounds = tonumber(roundsString)
		if not info.rounds then
			return false, errorCode.roundsInvalid
		end
		info.rounds = math.ceil(math.abs(info.rounds))
		if info.rounds == 0 then
			return false, errorCode.roundsZero
		end
	end

	return info
end

function outputNextMode(sourcePlayer)
	local nextModeName = getResourceInfo(gameList[nextGameIndex].mode, "name") or getResourceName(gameList[nextGameIndex].mode)
	local outputString = "The next mode is '"..nextModeName.."'"
	local nextMap = gameList[nextGameIndex].map
	if nextMap then
		local nextMapName = getResourceInfo(gameList[nextGameIndex].map, "name") or getResourceName(gameList[nextGameIndex].map)
		outputString = outputString .. " on map '"..nextMapName.."'"
	end
	outputString = outputString .. "."

	outputCycler(outputString, sourcePlayer)
end

function skipMap(sourcePlayer, command)
	if not hasObjectPermissionTo(sourcePlayer, command, false) then
		--! deny access
		--! return false
	end
	outputCyclerDebugString("Map skipped by "..getPlayerName(sourcePlayer)) --! change to server log when security is added
	cycleMap_list()
end
