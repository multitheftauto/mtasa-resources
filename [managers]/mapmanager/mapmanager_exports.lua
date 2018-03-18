local GAMEMODE_LIST_SEPARATOR = string.byte(',')

function changeGamemode(gamemode, map, ignorePlayerCount)
	if not isGamemode(gamemode) then
		outputDebugString("mapmanager: Invalid gamemode specified.",1)
		return false
	end
	if map then
		if not isMap(map) then
			outputDebugString("mapmanager: Invalid map specified.",1)
			return false
		end
		if not isMapCompatibleWithGamemode(map, gamemode) then
			outputDebugString("mapmanager: Map '"..getResourceName(map)..
				"' is not compatible with '"..getResourceName(gamemode).."'.",1)
			return false
		end
		if not ignorePlayerCount and not doesMapSupportPlayerCount(map) then
			outputDebugString("mapmanager: Map does not support player count.",1)
			return false
		end
	end

    -- Special thing if trying to start a gamemode which is already running, and mapmanger does not know about it.
	if currentGamemode == nil and getResourceState(gamemode) == "running" then
	    currentGamemode = gamemode
    end

	if currentGamemode then
		nextGamemode = gamemode
		nextGamemodeMap = map
		stopGamemode()
		return true
	else
		local result = startGamemode(gamemode)
		if map then
			 result = changeGamemodeMap(map,nil,ignorePlayerCount)
		end
		return result
	end
end

function changeGamemodeByName ( gamemodeName, mapName, ignorePlayerCount )
	local gamemode,map = getResourceFromName ( gamemodeName ), nil
	if not gamemode then
		outputDebugString("mapmanager: Invalid gamemode resource specified.",1)
		return false
	end
	if ( mapName ) then
		map = getMapFromName ( mapName )
		if not map then
			outputDebugString("mapmanager: Invalid map resource specified.",1)
			return false
		end
	end
	return changeGamemode ( gamemode, map, ignorePlayerCount )
end

function changeGamemodeMap(map, gamemode, ignorePlayerCount)
	if gamemode and isGamemode(gamemode) and gamemode ~= currentGamemode then
		return changeGamemode(gamemode, map, ignorePlayerCount)
	else
		if not isMap(map) then
			outputDebugString("mapmanager: Invalid map specified.",1)
			return false
		end
		if not isMapCompatibleWithGamemode(map, currentGamemode) then
			outputDebugString("mapmanager: Map '"..getResourceName(map)..
				"' is not compatible with '"..getResourceName(currentGamemode).."'.",1)
			return false
		end
		if not ignorePlayerCount and not doesMapSupportPlayerCount(map) then
			outputDebugString("mapmanager: Map does not support player count.",1)
			return false
		end

		if currentGamemodeMap then
			nextGamemodeMap = map
			stopGamemodeMap()
			return true
		else
			return startGamemodeMap(map)
		end
	end
end

function getGamemodes()
	local resourceList = getResources()

	local gamemodeList = {}
	for i,theResource in ipairs(resourceList) do
		if isGamemode(theResource) then
			table.insert(gamemodeList, theResource)
		end
	end

	return gamemodeList
end

function getGamemodesCompatibleWithMap(map)
	if not isMap(map) then
		outputDebugString("getGamemodesCompatibleWithMap: Invalid map resource.", 1)
		return false
	end

	local gmListString = getResourceInfo(map, "gamemodes")
	if not gmListString then
		return {}
	end

	local compatibleGamemodes = {}
	local gmNameList = split(gmListString, GAMEMODE_LIST_SEPARATOR)
	for i, gmName in ipairs(gmNameList) do
		local gamemode = getResourceFromName(gmName)
		if gamemode then
			table.insert(compatibleGamemodes, gamemode)
		end
	end

	return compatibleGamemodes
end

function getMaps()
	local resourceList = getResources()

	local mapList = {}
	for i,theResource in ipairs(resourceList) do
		if isMap(theResource) then
			table.insert(mapList, theResource)
		end
	end

	return mapList
end

function getMapsCompatibleWithGamemode(gamemode)
	local compatibleMaps

	if not gamemode then
		local resourceList = getResources()

		compatibleMaps = {}
		for i,theResource in ipairs(resourceList) do
			if isMap(theResource) and #getGamemodesCompatibleWithMap(theResource) == 0 then
				table.insert(compatibleMaps, theResource)
			end
		end
	elseif isGamemode(gamemode) then
		local resourceList = getResources()

		compatibleMaps = {}
		for i,theResource in ipairs(resourceList) do
			if isMap(theResource) and isMapCompatibleWithGamemode(theResource, gamemode) then
				table.insert(compatibleMaps, theResource)
			end
		end
	else
		outputDebugString("getMapsCompatibleWithGamemode: Invalid gamemode resource.", 1)
		return false
	end

	return compatibleMaps
end

function getRunningGamemode()
	return currentGamemode
end

function getRunningGamemodeMap()
	return currentGamemodeMap
end

function isGamemode(resource)
	if type(resource) ~= "userdata" then
		return false
	end
	return (getResourceInfo(resource,"type") == "gamemode")
end

function isGamemodeCompatibleWithMap(gamemode, map)
	if not isGamemode(gamemode) then
		outputDebugString("isGamemodeCompatibleWithMap: Invalid gamemode resource.", 1)
		return false
	end
	if not isMap(map) then
		outputDebugString("isGamemodeCompatibleWithMap: Invalid map resource.", 1)
		return false
	end

	return isMapCompatibleWithGamemode(map, gamemode)
end

function isMap(resource)
	if type(resource) ~= "userdata" then --!w
		return false
	end
	return (getResourceInfo(resource,"type") == "map")
end

function isMapCompatibleWithGamemode(map, gamemode)
	if not isMap(map) then
		outputDebugString("isMapCompatibleWithGamemode: Invalid map resource.", 1)
		return false
	end
	if not isGamemode(gamemode) then
		outputDebugString("isMapCompatibleWithGamemode: Invalid gamemode resource.", 1)
		return false
	end

	for i, compatibleGamemode in ipairs(getGamemodesCompatibleWithMap(map)) do
		if gamemode == compatibleGamemode then
			return true
		end
	end

	return false
end

function stopGamemode()
	if currentGamemode then
		return stopResource(currentGamemode)
	else
		return false
	end
end

function stopGamemodeMap()
	if currentGamemodeMap then
		return stopResource(currentGamemodeMap)
	else
		return false
	end
end
