currentGamemode = nil
currentGamemodeMap = nil
nextGamemode = nil
nextGamemodeMap = nil

setGameType(false)
setMapName("None")

rootElement = getRootElement()

addEvent("onGamemodeStart")
addEvent("onGamemodeStop")
addEvent("onGamemodeMapStart")
addEvent("onGamemodeMapStop")

addEventHandler("onResourcePreStart", rootElement,
	function (startingResource)
		--Is starting resource a gamemode?
		if isGamemode(startingResource) then
			--Check if another gamemode is running already
			if getRunningGamemode() and getRunningGamemode() ~= startingResource then
				-- Initiate a new changemode sequence and cancel this event
				outputMapManager( "Initiating changemode from '" .. getResourceName(getRunningGamemode()) .. "' to '" .. getResourceName(startingResource) .. "'" )
				changeGamemode(startingResource)
				cancelEvent(true)
			end
		elseif isMap(startingResource) then
			--Check if another map is running already
			if getRunningGamemodeMap() and getRunningGamemodeMap() ~= startingResource then
				-- Initiate a new changemap sequence and cancel this event
				if isGamemodeCompatibleWithMap ( getRunningGamemode(), startingResource ) then
					outputMapManager( "Initiating changemap from '" .. getResourceName(getRunningGamemodeMap()) .. "' to '" .. getResourceName(startingResource) .. "'" )
					changeGamemodeMap(startingResource)
				end
				cancelEvent(true)
			end
		end
	end
)

addEventHandler("onPlayerJoin", rootElement,
	function()
		if get("currentmap") and getRunningGamemode() and getRunningGamemodeMap() then
			outputMapManager(
				"Currently playing: " ..
				(getResourceInfo(getRunningGamemode(), "name") or getResourceName(getRunningGamemode())) ..
				" - " ..
				(getResourceInfo(getRunningGamemodeMap(), "name") or getResourceName(getRunningGamemodeMap())),
				source
			)
		end
	end
)

addEventHandler("onResourceStart", rootElement,
	function (startedResource)
		--Is this resource a gamemode?
		if isGamemode(startedResource) then
			--Check no gamemode is running already
			if getRunningGamemode() then
                return
			end
			if triggerEvent("onGamemodeStart", getResourceRootElement(startedResource), startedResource) then
				currentGamemode = startedResource
				--Setup our announcements
				local gamemodeName = getResourceInfo(currentGamemode, "name") or getResourceName(currentGamemode)
				if get("ASE") then
					setGameType(gamemodeName)
				end
				if get("messages") then
					local name = getInstigatorName ( " by " ) or ""
					outputMapManager("Gamemode '"..gamemodeName.."' started" .. name .. "." )
				end
				--We need to wait a while to see if any maps were started.  If not, lets try and start a random one
				setTimer(
					function()
						if not getRunningGamemodeMap() then
							--Lets check if there are any maps for this gamemode
							local maps = getMapsCompatibleWithGamemode(getRunningGamemode())
							--If we have any, we'll start a random one
							if #maps > 0 then
								changeGamemodeMap (maps[math.random(1,#maps)])
							end
						end
					end,
				50, 1 )
			else
				currentGamemode = nil
			end
		elseif isMap(startedResource) then --If its a map
			--Make sure there is a gamemode running
			if not getRunningGamemode() then
				return
			end
			--Is there a map running already?
			if getRunningGamemodeMap() then
				return
			end
			--Is it compatible with our gamemode?
			if isGamemodeCompatibleWithMap ( getRunningGamemode(), startedResource ) then
				--Lets link the map with the gamemode
				if ( triggerEvent("onGamemodeMapStart", getResourceRootElement(startedResource), startedResource) ) then
					currentGamemodeMap = startedResource
					--Setup our announcements
					local gamemodeMapName = getResourceInfo(currentGamemodeMap, "name") or getResourceName(currentGamemodeMap)
					applyMapSettings( currentGamemodeMap )

					if get("ASE") then
						setMapName(gamemodeMapName)
					end
					if get("messages") then
						local name = getInstigatorName ( " by " ) or ""
						outputMapManager("Map '"..gamemodeMapName.."' started" .. name .. ".")
					end
				else
					currentGamemodeMap = nil
				end
			end
		end
	end
)

addEventHandler("onResourceStop", rootElement,
	function (stoppedResource)
		-- Incase the resource being stopped has been deleted
		local stillExists = false
		for i, res in ipairs(getResources()) do
			if res == stoppedResource then
				stillExists = true
				break
			end
		end

		local resourceRoot = stillExists and getResourceRootElement(stoppedResource)

		if stoppedResource == currentGamemode then
			if stillExists then
				triggerEvent("onGamemodeStop", resourceRoot, currentGamemode)
			end

			currentGamemode = nil
			setGameType(false)

			if currentGamemodeMap then
				stopResource(currentGamemodeMap)
			elseif nextGamemode then
				startGamemodeT(nextGamemode)
				nextGamemode = nil
				if nextGamemodeMap then
					startGamemodeMapT(nextGamemodeMap)
					nextGamemodeMap = nil
				end
			end
		elseif stoppedResource == currentGamemodeMap then
			if stillExists then
				triggerEvent("onGamemodeMapStop", resourceRoot, currentGamemodeMap)
			end

			currentGamemodeMap = nil
			resetMapInfo()
			setMapName("None")

			if nextGamemode then
				startGamemodeT(nextGamemode)
				nextGamemode = nil
				if nextGamemodeMap then
					startGamemodeMapT(nextGamemodeMap)
					nextGamemodeMap = nil
				end
			elseif nextGamemodeMap then
				startGamemodeMapT(nextGamemodeMap)
				nextGamemodeMap = nil
			end
		end
	end
)


addEventHandler("onResourceStart", resourceRoot,
	function ()
		-- Investigate if there is a starting/running gamemode
		local gamemodeRequiresRestart = false

		for index, gamemode in pairs(getGamemodes()) do
			local gamemodeState = getResourceState(gamemode)

			if gamemodeState == "starting" or gamemodeState == "running" then
				if not currentGamemode then
					outputServerLog(("mapmanager: Running gamemode %q found"):format(getResourceName(gamemode)))
					currentGamemode = gamemode
				else
					outputServerLog(("mapmanager: Stopping running gamemode %q"):format(getResourceName(gamemode)))
					stopResource(gamemode)
					gamemodeRequiresRestart = true
				end
			end
		end

		-- Search for starting/running maps
		local runningMaps = {}

		for index, map in pairs(getMaps()) do
			local mapState = getResourceState(map)

			if mapState == "starting" or mapState == "running" then
				runningMaps[#runningMaps + 1] = map
			end
		end

		-- Investigate if there is a starting/running compatible map
		if runningMaps[1] then
			if currentGamemode then
				-- Select the first starting/running compatible map for our gamemode
				for index, map in pairs(runningMaps) do
					if not currentGamemodeMap and isMapCompatibleWithGamemode(map, currentGamemode) then
						outputServerLog(("mapmanager: Running map %q found"):format(getResourceName(map)))
						currentGamemodeMap = map
					else
						outputServerLog(("mapmanager: Stopping running map %q"):format(getResourceName(map)))
						stopResource(map)
					end
				end
			else
				-- Select a random map from the list because we have no running gamemode
				currentGamemodeMap = table.remove(runningMaps, math.random(#runningMaps))
				outputServerLog(("mapmanager: Running map %q found"):format(getResourceName(currentGamemodeMap)))

				-- Stop the remaining maps
				for index, map in pairs(runningMaps) do
					outputServerLog(("mapmanager: Stopping running map %q"):format(getResourceName(map)))
					stopResource(map)
				end
			end
		end

		-- a) Stopping gamemodes is dangerous and the stopping gamemodes might stop essential resources for the current gamemode
		-- b) A gamemode and a map are running, but the map and/or gamemode might be stuck/error'ed
		if gamemodeRequiresRestart or (currentGamemode and currentGamemodeMap) then
			nextGamemode = currentGamemode
			nextGamemodeMap = currentGamemodeMap
			return stopGamemode()
		end

		if currentGamemode and not currentGamemodeMap then
			-- A gamemode, but no map; are running
			local maps = getMapsCompatibleWithGamemode(currentGamemode)

			if maps and maps[1] then
				local randomMap = maps[math.random(#maps)]
				outputServerLog(("mapmanager: Starting random map %q for gamemode %q"):format(getResourceName(randomMap), getResourceName(currentGamemode)))
				return setTimer(changeGamemodeMap, 50, 1, randomMap, nil, true)
			else
				outputServerLog("mapmanager: Running gamemode has no compatible maps")
			end
		elseif not currentGamemode and currentGamemodeMap then
			-- A map, but no gamemode; are running
			local gamemodes = getGamemodesCompatibleWithMap(currentGamemodeMap)

			if gamemodes and gamemodes[1] then
				local randomGamemode = gamemodes[math.random(#gamemodes)]
				outputServerLog(("mapmanager: Starting random gamemode %q for map %q"):format(getResourceName(randomGamemode), getResourceName(currentGamemodeMap)))
				return setTimer(changeGamemode, 50, 1, randomGamemode, currentGamemodeMap, true)
			else
				outputServerLog("mapmanager: Running map has no compatible gamemodes")
			end
		end
	end,
false)


function changeGamemodeMap_cmd(source, command, ...)
    local mapName = #{...}>0 and table.concat({...},' ') or nil
	source = source or serverConsole

	local map
	if mapName then
		map = getMapFromName(mapName)
		if not isMap(map) then
			if (refreshResources and hasObjectPermissionTo(getThisResource(), "function.refreshResources", false)) then
				outputMapManager("'"..mapName.."' is not a valid map.", source)
			else
				outputMapManager("'"..mapName.."' is not a valid map. Use the refresh command and try again", source)
			end
			return false
		end
	else
		outputMapManager("Usage: /"..command.." map",source)
		return false
	end

	local gamemode = currentGamemode
	if not isGamemode(gamemode) then
		outputMapManager("No gamemode is running.",source)
	elseif not isMapCompatibleWithGamemode(map, gamemode) then
		outputMapManager("Map '"..getResourceName(map)..
			"' is not compatible with '"..getResourceName(gamemode).."'.",source)
	else
		setInstigator( source )
		changeGamemodeMap(map, gamemode)
	end
end
addCommandHandler("changemap", changeGamemodeMap_cmd, true)

function changeGamemode_cmd(source, command, gamemodeName,...)
    local mapName = #{...}>0 and table.concat({...},' ') or nil
	source = source or serverConsole

	local gamemode
	if gamemodeName then
		gamemode = getResourceFromName(gamemodeName)
		if not isGamemode(gamemode) then
			if (refreshResources and hasObjectPermissionTo(getThisResource(), "function.refreshResources", false)) then
				refreshResources(false)
				gamemode = getResourceFromName(gamemodeName)
				if not isGamemode(gamemode) then
					outputMapManager("'"..gamemodeName.."' is not a valid gamemode.", source)
					return false
				end
			else
				outputMapManager("'"..gamemodeName.."' is not a valid gamemode. Use the refresh command and try again", source)
				return false
			end
		end
	else
		outputMapManager("Usage: /"..command.." gamemode [map]",source)
		return false
	end

	local map
	if mapName then
		map = getMapFromName(mapName)
		if not isMap(map) then
			if (refreshResources and hasObjectPermissionTo(getThisResource(), "function.refreshResources", false)) then
				outputMapManager("'"..mapName.."' is not a valid map.", source)
			else
				outputMapManager("'"..mapName.."' is not a valid map. Use the refresh command and try again", source)
			end
			return false
		end
	end
	setInstigator( source )
	changeGamemode(gamemode,map)
end
addCommandHandler("gamemode", changeGamemode_cmd, true)
addCommandHandler("changemode", changeGamemode_cmd, true)

function stopGamemode_cmd(source)
	source = source or serverConsole

	if currentGamemode then
		stopGamemode()
		local gamemodeName = getResourceInfo(currentGamemode, "name") or getResourceName(currentGamemode)
		outputMapManager("Gamemode '"..gamemodeName.."' stopped.",source)
	else
		outputMapManager("No gamemode is running.",source)
	end
end
addCommandHandler("stopmode", stopGamemode_cmd, true)

function stopGamemodeMap_cmd(source)
	source = source or serverConsole

	if currentGamemodeMap then
		stopGamemodeMap()
		local mapName = getResourceInfo(currentGamemodeMap, "name") or getResourceName(currentGamemodeMap)
		outputMapManager("Map '"..mapName.."' stopped.",source)
	else
		outputMapManager("No gamemode map is running.",source)
	end
end
addCommandHandler("stopmap", stopGamemodeMap_cmd, true)

function outputGamemodeListToConsole(source)
	source = source or serverConsole

	local allGamemodes = getGamemodes()
	local numberOfGamemodes = #allGamemodes

	if numberOfGamemodes == 0 then
		outputMapManagerConsole("There are no gamemodes.", source)
	else
		local s = "s"
		if numberOfGamemodes == 1 then s="" end
		outputMapManagerConsole("There are "..numberOfGamemodes.." gamemode"..s..":", source)
	end

	for k, gamemode in ipairs(allGamemodes) do
		local gamemodeFriendlyName = getResourceInfo(gamemode, "name")
		if gamemodeFriendlyName then
			gamemodeFriendlyName = " ("..gamemodeFriendlyName..") "
		else
			gamemodeFriendlyName = ""
		end

		local numberOfCompatibleMaps = #getMapsCompatibleWithGamemode(gamemode)

		local s = "s"
		if numberOfCompatibleMaps == 1 then s="" end

		outputMapManagerConsole(getResourceName(gamemode) .. gamemodeFriendlyName .. " [".. numberOfCompatibleMaps .. " map"..s.."]", source)
	end
end
addCommandHandler("gamemodes",outputGamemodeListToConsole)

function outputMapListToConsole(source, command, gamemodeName)
	source = source or serverConsole

	if not gamemodeName then
		local allMaps = getMaps()
		local numberOfMaps = #allMaps

		if numberOfMaps == 0 then
			outputMapManagerConsole("There are no maps.", source)
		else
			local s = "s"
			if numberOfMaps == 1 then s="" end
			outputMapManagerConsole("There are "..numberOfMaps.." map"..s..":", source)
		end

		for k, map in ipairs(allMaps) do
			local gamemodeMapFriendlyName = getResourceInfo(map, "name")
			if gamemodeMapFriendlyName then
				gamemodeMapFriendlyName = " ("..gamemodeMapFriendlyName..") "
			else
				gamemodeMapFriendlyName = ""
			end
			outputMapManagerConsole(getResourceName(map) .. gamemodeMapFriendlyName, source)
		end
	else
		local gamemode = getResourceFromName(gamemodeName)
		if not gamemode then
			outputMapManager("Gamemode '"..gamemodeName.."' does not exist.", source)
			return false
		end

		local compatibleMaps = getMapsCompatibleWithGamemode(gamemode)
		if not compatibleMaps then
			outputMapManager("Gamemode '"..gamemodeName.."' does not exist.", source)
			return false
		end

		local numberOfCompatibleMaps = #compatibleMaps
		if numberOfCompatibleMaps == 0 then
			outputMapManagerConsole("'"..gamemodeName.."' has no maps.", source)
		else
			local s = "s"
			if numberOfCompatibleMaps == 1 then s="" end
			outputMapManagerConsole("'"..gamemodeName.."' has "..#compatibleMaps.." map"..s..":", source)
		end

		for k, map in ipairs(compatibleMaps) do
			local gamemodeMapFriendlyName = getResourceInfo(map, "name")
			if gamemodeMapFriendlyName then
				gamemodeMapFriendlyName = " ("..gamemodeMapFriendlyName..") "
			else
				gamemodeMapFriendlyName = ""
			end
			outputMapManagerConsole(getResourceName(map) .. gamemodeMapFriendlyName, source)
		end
	end
end
addCommandHandler("maps",outputMapListToConsole)

function startGamemode(gamemode)
	if not startResource(gamemode, true) then
		error("mapmanager: gamemode resource could not be started.", 2)
		return false
	end
	return true
end

function startGamemodeT(gamemode)
	setTimer(startGamemode, 50, 1, gamemode)
end

function startGamemodeMap(map)
	if not startResource(map) then
		error("mapmanager: map resource could not be started.", 2)
		return false
	end
	return true
end

function startGamemodeMapT(map)
	setTimer(startGamemodeMap, 50, 1, map)
end

local serverConsole = getElementByIndex("console", 0)

function outputMapManager(message, toElement)
	toElement = toElement or rootElement
	local r, g, b = getColorFromString(string.upper(get("color")))
	if getElementType(toElement) == "console" then
		outputServerLog(message)
	else
		outputChatBox(message, toElement, r, g, b)
		if toElement == rootElement then
			outputServerLog(message)
		end
	end
end

function outputMapManagerConsole(message, toElement)
	toElement = toElement or rootElement
	if getElementType(toElement) == "console" then
		outputServerLog(message)
	else
		outputConsole(message, toElement)
		if toElement == rootElement then
			outputServerLog(message)
		end
	end
end

function doesMapSupportPlayerCount( map )
	local mapName = getResourceName(map)
	local minPlayers = tonumber(get(mapName..".minplayers"))
	local maxPlayers = tonumber(get(mapName..".maxplayers"))

	local playersIn = getPlayerCount()
	if minPlayers and minPlayers > playersIn then
		outputMapManager( (minPlayers).." or more players are required to start '"..mapName.."'" )
		return false
	end

	if maxPlayers and maxPlayers < playersIn then
		outputMapManager( (maxPlayers).." or less players are required to start '"..mapName.."'" )
		return false
	end

	return true
end

local settingApplier = {
	gamespeed = function(value) setGameSpeed(tonumber(value)) end,
	gravity = function(value) setGravity(tonumber(value)) end,
	time = function(value)
		local splitString = split(value, string.byte(':'))
		hr = tonumber(splitString[1]) or 12
		mn = tonumber(splitString[2]) or 0
		setTime(hr, mn)
	end,
	locked_time = function(value) if value then setMinuteDuration(2147483647) else setMinuteDuration(1000) end end,
	weather = function(value) setWeather(tonumber(value)) end,
	waveheight = function(value) setWaveHeight(tonumber(value)) end,
}

local defaultSettings = {
	gamespeed = 1,
	gravity = 0.008,
	locked_time = false,
	time = "12:00",
	weather = 0,
	waveheight = 0,
}

function applyMapSettings( map )
	local mapSettingsGroup = getResourceName(map).."."
	for setting, defaultValue in pairs(defaultSettings) do
		settingApplier[setting](get(mapSettingsGroup..setting) or defaultValue)
	end
end

function getMapFromName ( name )
	local resource = getResourceFromName ( name )
	if resource then
		return resource
	end
	if (refreshResources and hasObjectPermissionTo(getThisResource(), "function.refreshResources", false)) then -- If this version has refreshResources, refresh resources.
		refreshResources(false)
	end
	local resource = getResourceFromName ( name ) --and try get the resource again.
	if resource then
		return resource
	end
	name = string.lower(name) --Remove case sensitivity.  May cause minor problems with linux servers.
	--Loop through and find resources with a matching 'name' param
	for i,resource in ipairs(getMaps()) do
		local infoName = getResourceInfo ( resource, "name" )
		if (infoName and (string.lower(infoName) == name)) then
			return resource
		end
	end
	return false
end

function setInstigator( admin )
	g_InstigatorName = getPlayerName( admin )
	g_InstigatorTime = getTickCount()
end

function getInstigatorName( prepend )
	local age = getTickCount() - ( g_InstigatorTime or 0 )
	local name = g_InstigatorName
	g_InstigatorName = nil
	g_InstigatorTime = nil
	return age < 2000 and name and ( prepend .. name ) or nil
end
