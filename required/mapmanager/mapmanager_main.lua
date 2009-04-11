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
			currentGamemode = startedResource
			triggerEvent("onGamemodeStart", getResourceRootElement(startedResource), startedResource)
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
		elseif isMap(startedResource) then --If its a map
			--Is there a map running already?
			if getRunningGamemodeMap() then
				return
			end
			--Is it compatible with our gamemode?
			if isGamemodeCompatibleWithMap ( getRunningGamemode(), startedResource ) then
				--Lets link the map with the gamemode
				currentGamemodeMap = startedResource
				triggerEvent("onGamemodeMapStart", getResourceRootElement(startedResource), startedResource)	
			end
		end
	end
)

addEventHandler("onResourceStop", rootElement, 
	function (stoppedResource)
		local resourceRoot = getResourceRootElement(stoppedResource)
		if stoppedResource == currentGamemode then
			currentGamemode = nil
			setGameType(false)
			
			triggerEvent("onGamemodeStop", resourceRoot, currentGamemode)
			
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
			currentGamemodeMap = nil
			resetMapInfo()
			setMapName("None")
			
			triggerEvent("onGamemodeMapStop", resourceRoot, currentGamemodeMap)
			
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

addEventHandler("onGamemodeStart", rootElement, 
	function ( startedGamemode )
		local gamemodeName = getResourceInfo(startedGamemode, "name") or getResourceName(startedGamemode)
		
		if get("ASE") then
			setGameType(gamemodeName)
		end
		if get("messages") then
			outputMapManager("Gamemode '"..gamemodeName.."' started.")
		end
	end
)

addEventHandler("onGamemodeMapStart", rootElement, 
	function ( startedGamemodeMap )
		local gamemodeMapName = getResourceInfo(startedGamemodeMap, "name") or getResourceName(startedGamemodeMap)
		
		applyMapSettings( currentGamemodeMap )
		
		if get("ASE") then
			setMapName(gamemodeMapName)
		end
		if get("messages") then
			outputMapManager("Map '"..gamemodeMapName.."' started.")
		end
	end
)

function changeGamemodeMap_cmd(source, command, ...)
    local mapName = table.concat({...},' ')
	source = source or serverConsole

	local map
	if mapName then
		map = getResourceFromName(mapName)
		if not isMap(map) then
			outputMapManager("'"..mapName.."' is not a valid map.",source)
			return false
		end
	else
		outputMapManager("Usage: /"..command.." map [gamemode]",source)
		return false
	end
	
	local gamemode = currentGamemode
	if gamemodeName then
		gamemode = getResourceFromName(gamemodeName)
		if not isGamemode(gamemode) then
			outputMapManager("'"..gamemodeName.."' is not a valid gamemode.",source)
			return false
		end
	end

	if not isGamemode(gamemode) then
		outputMapManager("No gamemode is running.",source)
	elseif not isMapCompatibleWithGamemode(map, gamemode) then
		outputMapManager("Map '"..getResourceName(map)..
			"' is not compatible with '"..getResourceName(gamemode).."'.",source)
	else
		changeGamemodeMap(map, gamemode)
	end
end
addCommandHandler("changemap", changeGamemodeMap_cmd, true)

function changeGamemode_cmd(source, command, ...)
    local gamemodeName = table.concat({...},' ',1,1)
    local mapName = table.concat({...},' ',2)
	source = source or serverConsole

	local gamemode
	if gamemodeName then
		gamemode = getResourceFromName(gamemodeName)
		if not isGamemode(gamemode) then
			outputMapManager("'"..gamemodeName.."' is not a valid gamemode.",source)
			return false
		end
	else
		outputMapManager("Usage: /"..command.." gamemode [map]",source)
		return false
	end
	
	local map
	if mapName then
		map = getResourceFromName(mapName)
		if not isMap(map) then
			outputMapManager("'"..mapName.."' is not a valid map.",source)
			return false
		end
	end
	
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
	if not startResource(gamemode) then
		error("mapmanager: gamemode resource could not be started.", 2)
	end
end

function startGamemodeT(gamemode)
	setTimer(startGamemode, 50, 1, gamemode)
end

function startGamemodeMap(map)
	if not startResource(map) then
		error("mapmanager: map resource could not be started.", 2)
	end
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
		outputMapManager( "More than "..(minPlayers).." are required to start '"..mapName.."'" )
		return false
	end
	
	if maxPlayers and maxPlayers < playersIn then
		outputMapManager( "Less than "..(maxPlayers).." are required to start '"..mapName.."'" )
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
