--current settings' table, initially default map settings
local defaults = {
	gamespeed = 1,
	gravity = "0.008",
	locked_time = false,
	useLODs = false,
	timeHour = 12,
	timeMinute = 00,
	waveheight = 0,
	weather = 0,
	metaAuthor = "",
	metaDescription = "",
	metaName = "",
	metaVersion = "1.0.0",
	minplayers = 0,
	maxplayers = 128,
}

-- This function is required because defaults get overwritten. #7405
function makeSettingsDefault()
	defaults = {
		gamespeed = 1,
		gravity = "0.008",
		locked_time = false,
		useLODs = false,
		timeHour = 12,
		timeMinute = 00,
		waveheight = 0,
		weather = 0,
		metaAuthor = "",
		metaDescription = "",
		metaName = "",
		metaVersion = "1.0.0",
		minplayers = 0,
		maxplayers = 128,
	}
	return defaults
end

mapSettingDefaults = defaults
currentMapSettings = defaults
currentMapSettings.gamemodeSettings = {}

local mapSettingAction = {
	timeHour = function ( value )
		setTime(value, currentMapSettings.timeMinute)
	end,

	timeMinute = function ( value )
		setTime(currentMapSettings.timeHour, value)
	end,

	weather = function ( value )
		setWeather(value)
	end,

	gravity = function(value)
		setGravity(value)
		setTimer(function()
			for i, p in ipairs(getElementsByType("player")) do
				setPedGravity(p, value)
			end
		end, 1000, 1)
	end,

	gamespeed = setGameSpeed,

	waveheight = setWaveHeight,

	locked_time = function(value)
		if (value) then
			setMinuteDuration(100000)
		else
			setMinuteDuration(1000)
		end
	end
}


function doSaveNewMapSettings( newMapSettings, hidden )
	if client and not hidden and not isPlayerAllowedToDoEditorAction(client,"mapSettings") then
		editor_gui.outputMessage ("You don't have permissions to change the map settings!", client,255,0,0)
		triggerClientEvent ( client, "syncMapSettings", root, currentMapSettings )
		return
	end

	currentMapSettings = newMapSettings
	for setting, value in pairs(currentMapSettings) do
		if mapSettingAction[setting] then
			mapSettingAction[setting](value)
		end
	end
	if not hidden then
		editor_gui.outputMessage ( getPlayerName(client).." updated the map settings.", root, 255, 255, 0 )
		for k,v in ipairs(getElementsByType("player")) do
			if v ~= client then
				triggerClientEvent ( v, "syncMapSettings", root, currentMapSettings )
			end
		end
		--start definitions from added gamemodes if necessary
		local edfLoaded
		for _, gamemodeResName in ipairs(currentMapSettings.addedGamemodes) do
			local gamemode = getResourceFromName(gamemodeResName)
			if gamemode and edf.edfHasDefinition(gamemode) and getResourceState(gamemode) ~= 'running' then
				blockMapManager(gamemode) --Stop mapmanager from treating this like a game.  LIFE IS NOT A GAME.
				edf.edfStartResource(gamemode)
				table.insert(allEDF.addedEDF, gamemodeResName)
				local index = table.find(allEDF.availEDF, gamemodeResName)
				if index then
					table.remove(allEDF.availEDF, index)
				end
				edfLoaded = true
			end
		end
		if edfLoaded then
			triggerClientEvent('syncEDFDefinitions', root, allEDF)
		end
	end
end
addEventHandler ( "doSaveMapSettings", root, doSaveNewMapSettings )

function setupMapSettings()
	resetMapInfo()
	if getResourceState( mapmanager.res ) ~= "running" then
		return
	end
	--get the gamemodes
	local gamemodes = mapmanager.getGamemodes()
	currentMapSettings.availGamemodes = {}
	currentMapSettings.addedGamemodes = {}
	for k,v in ipairs(gamemodes) do
		local name = getResourceName ( v )
		if string.lower(name) ~= "freeroam" then
			table.insert ( currentMapSettings.availGamemodes, name )
		end
	end
	for setting, value in pairs(currentMapSettings) do
		if mapSettingAction[setting] then
			mapSettingAction[setting](value)
		end
	end
end
addEventHandler ( "onResourceStart", resourceRoot, setupMapSettings )

addEventHandler ( "onClientGUILoaded", root,
	function()
		triggerClientEvent ( client, "syncMapSettings", client, currentMapSettings )
	end
)

function passDefaultMapSettings()
	currentMapSettings = makeSettingsDefault()
	currentMapSettings.gamemodeSettings = {}
	currentMapSettings.availGamemodes = {}
	currentMapSettings.addedGamemodes = {}
	local gamemodes = mapmanager.getGamemodes()
	for k,v in ipairs(gamemodes) do
		local name = getResourceName ( v )
		if string.lower(name) ~= "freeroam" then
			table.insert ( currentMapSettings.availGamemodes, name )
		end
	end
	doSaveNewMapSettings(currentMapSettings, true)

	-- Unload definitions
	local loadedDefs = edf.edfGetLoadedEDFResources()
	for k, resourceName in ipairs(allEDF.addedEDF) do
		if ( resourceName ~= "editor_main" ) then
			local resource = getResourceFromName(resourceName)
			if ( resource ) then
				local loaded = false
				for k2, loadedResource in ipairs(loadedDefs) do
					if ( loadedResource == resource ) then
						loaded = true
						break
					end
				end
				if ( loaded == true ) then
					outputServerLog("Unloading "..resourceName.." def.")
					outputConsole("Unloading "..resourceName.." def.")
					edf.edfStopResource(resource)
				end
			else
				table.remove(allEDF.availEDF, k)
			end
		end
	end

	setClientAddedEDFs({getResourceFromName("editor_main")})
	triggerClientEvent(root, "syncMapSettings", root, currentMapSettings)
end

function passNewMapSettings()
	local mapResource = getResourceFromName(loadedMap)

	--General settings
	local settings = getSettings(mapResource)
	for settingName,settingValue in pairs(defaults) do
		if settings[settingName] then
			currentMapSettings[settingName] = fromJSON(settings[settingName])
			if currentMapSettings[settingName] == nil then
				currentMapSettings[settingName] = settings[settingName]
			end
		else
			currentMapSettings[settingName] = defaults[settingName]
		end
	end
	if settings.time then
		currentMapSettings.timeHour = gettok ( settings.time, 1, 58 )
		currentMapSettings.timeMinute = gettok ( settings.time, 2, 58 )
	end
	--Gamemode settings
	for settingName,settingValue in pairs(settings) do
		settings[settingName] = fromJSON(settingValue)
	end
	currentMapSettings.minplayers =	settings.minplayers or currentMapSettings.minplayers
	currentMapSettings.maxplayers =	settings.maxplayers or currentMapSettings.maxplayers
	--Resource info
	local gamemodesString = getResourceInfo(mapResource,"gamemodes") or ""
	--compile the added gamemodes into an array
	local gamemodesArray = {}
	for k,gamemodeName in ipairs(split(gamemodesString,string.byte(','))) do
		gamemodesArray[gamemodeName] = true
	end

	currentMapSettings.availGamemodes = {}
	currentMapSettings.addedGamemodes = {}
	local gamemodes = mapmanager.getGamemodes()
	for k,gamemodeRes in ipairs(gamemodes) do
		local gamemodeName = getResourceName ( gamemodeRes )
		if ( gamemodesArray[gamemodeName] ) then
			table.insert ( currentMapSettings.addedGamemodes, gamemodeName )
		else
			table.insert ( currentMapSettings.availGamemodes, gamemodeName )
		end
	end
	currentMapSettings.metaName = getResourceInfo(mapResource,"name") or ""
	currentMapSettings.metaAuthor = getResourceInfo(mapResource,"author") or ""
	currentMapSettings.metaVersion = getResourceInfo(mapResource,"version") or "1.0"
	currentMapSettings.metaDescription = getResourceInfo(mapResource,"description") or ""
	--
	currentMapSettings.newSettings = settings
	-- sync it
	triggerClientEvent ( root, "syncMapSettings", root, currentMapSettings )
end

function getSettings(resource)
	local meta = xmlLoadFile( ':' .. getResourceName(resource) .. '/' .. "meta.xml" )
	local settings = {}
	local settingsNode = xmlFindChild ( meta, "settings" ,0 )
	if not settingsNode then xmlUnloadFile ( meta ) return settings end
	local nodes = xmlNodeGetChildren ( settingsNode )
	for i,node in ipairs(nodes) do
		if xmlNodeGetName(node) == "setting" then
			local name = xmlNodeGetAttribute(node,"name")
			local value = xmlNodeGetAttribute(node,"value")
			if ( name ) and ( value ) then
				if string.find(name,"*") == 1 or string.find(name,"#") == 1 or string.find(name,"@") == 1 then
					name = string.sub(name,2)
				end
				settings[name] = value
			end
		end
	end
	xmlUnloadFile ( meta )
	return settings
end
