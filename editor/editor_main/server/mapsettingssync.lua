local rootElement = getRootElement()

--current settings' table, initially default map settings
local defaults = {
	gamespeed = 1,
	gravity = "0.008",
	lockTime = false,
	timeHour = 12,
	timeMinute = 00,
	waveheight = 0,
	weather = 0,
	metaAuthor = "",
	metaDescription = "",
	metaName = "",
	metaVersion = "1.0.0",
	minPlayers = 0,
	maxPlayers = 128,
}
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

	waveheight = setWaveHeight,
}


function doSaveNewMapSettings( newMapSettings, hidden )
	currentMapSettings = newMapSettings
	for setting, value in pairs(currentMapSettings) do
		if mapSettingAction[setting] then 
			mapSettingAction[setting](value)
		end
	end
	if not hidden then
		editor_gui.outputMessage ( getPlayerName(client).." updated the map settings.", rootElement, 255, 255, 0 )
		for k,v in ipairs(getElementsByType("player")) do
			if v ~= client then
				triggerClientEvent ( v, "syncMapSettings", rootElement, currentMapSettings )
			end
		end
	end
end
addEventHandler ( "doSaveMapSettings", rootElement, doSaveNewMapSettings )

addEventHandler ( "onResourceStart", thisResourceRoot,
	function ()
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
)

addEventHandler ( "onClientGUILoaded", getRootElement(),
	function()
		triggerClientEvent ( client, "syncMapSettings", client, currentMapSettings )
	end
)

function passDefaultMapSettings()
	currentMapSettings = defaults
	currentMapSettings.gamemodeSettings = {}
	doSaveNewMapSettings(currentMapSettings, true)
	triggerClientEvent ( rootElement, "syncMapSettings", rootElement, currentMapSettings )
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
	currentMapSettings.minPlayers =	settings.minplayers or currentMapSettings.minPlayers
	currentMapSettings.maxPlayers =	settings.maxplayers or currentMapSettings.maxPlayers
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
	triggerClientEvent ( rootElement, "syncMapSettings", rootElement, currentMapSettings )
end

function getSettings(resource)
	local meta = xmlLoadFile( ':' .. getResourceName(resource) .. '/' .. "meta.xml" )
	local settings = {}
	local settingsNode = xmlFindChild ( meta, "settings" ,0 )
	if not settingsNode then return settings end
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
	return settings
end
