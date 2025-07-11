mapSettingsCamera = {}
mapsettings = {}
screenX, screenY = guiGetScreenSize()
weather = {
[1] = "Hot, Sunny, Clear [0]",
[2] = "Sunny, Low Clouds [1]",
[3] = "Sunny, Clear [2]",
[4] = "Sunny, Cloudy [3]",
[5] = "Dark Clouds [4]",
[6] = "Sunny, More Low Clouds [5]",
[7] = "Sunny, Even More Low Clouds [6]",
[8] = "Cloudy Skies [7]",
[9] = "Thunderstorm [8]",
[10] = "Foggy [9]",
[11] = "Sunny, Cloudy (2) [10]",
[12] = "Hot, Sunny, Clear (2) [11]",
[13] = "White, Cloudy [12]",
[14] = "Sunny, Clear (2) [13]",
[15] = "Sunny, Low Clouds (2) [14]",
[16] = "Dark Clouds (2) [15]",
[17] = "Thunderstorm (2) [16]",
[18] = "Hot, Cloudy [17]",
[19] = "Hot, Cloudy (2) [18]",
[20] = "Sandstorm [19]"
}

function createMapSettings()
	mapsettings.window		=	guiCreateWindow ( screenX/2 - 320, screenY/2 - 180, 640, 360, "MAP SETTINGS", false )
	guiSetVisible(mapsettings.window, false )
	guiWindowSetSizable ( mapsettings.window, false )

	local tabpanel = guiCreateTabPanel ( 0.02388, 0.09444, 0.9582, 0.81389, true, mapsettings.window )
	mapsettings.environmentTab = guiCreateTab("Environment",tabpanel)
	mapsettings.gamemodeSettingsTab = guiCreateTab("Gamemode settings",tabpanel)
	mapsettings.metaTab = guiCreateTab("Meta",tabpanel)
	mapsettings.gamemodesTab = guiCreateTab("Gamemodes",tabpanel)

	mapsettings.ok = guiCreateButton ( 0.5, 0.919444, 0.22857142, 0.05555555, "OK", true, mapsettings.window )
	mapsettings.cancel = guiCreateButton ( 0.780357142, 0.919444, 0.22857142, 0.05555555, "Cancel", true, mapsettings.window )

	--create environment settings
	mapsettings.locked_time = editingControl.boolean:create{["x"]=0.26,["y"]=0.04,["width"]=1,["height"]=0.1,["relative"]=true,["parent"]=mapsettings.environmentTab,["label"]="Locked time"}
	mapsettings.useLODs = editingControl.boolean:create{["x"]=0.46,["y"]=0.04,["width"]=1,["height"]=0.1,["relative"]=true,["parent"]=mapsettings.environmentTab,["label"]="Use LODs"}
	guiCreateMinimalLabel ( 0.02, 0.06, "Time:", true, mapsettings.environmentTab )
	mapsettings.timeHour = editingControl.natural:create{["x"]=0.08,["y"]=0.04,["width"]=0.07,["height"]=0.11,["relative"]=true,["parent"]=mapsettings.environmentTab,["maxLength"]=2,["max"]=23}
	mapsettings.timeMinute = editingControl.natural:create{["x"]=0.16,["y"]=0.04,["width"]=0.07,["height"]=0.11,["relative"]=true,["parent"]=mapsettings.environmentTab,["maxLength"]=2,["max"]=59}
	local function handlerSetTime() if mapsettings.timeHour:getValue() and mapsettings.timeMinute:getValue() then setTime(mapsettings.timeHour:getValue(),mapsettings.timeMinute:getValue()) end end
	mapsettings.timeHour:addChangeHandler(handlerSetTime)
	mapsettings.timeMinute:addChangeHandler(handlerSetTime)
	--
	guiCreateMinimalLabel ( 0.02, 0.2, "Weather:", true, mapsettings.environmentTab )
	mapsettings.radioPreset = guiCreateRadioButton ( 0.12, 0.2, 0.1, 0.06, "Preset", true, mapsettings.environmentTab )
	guiRadioButtonSetSelected ( mapsettings.radioPreset, true )
	addEventHandler ( "onClientGUIMouseDown", mapsettings.radioPreset, mapsettings_radioChange )
	mapsettings.weather = editingControl.dropdown:create{["x"]=0.25,["y"]=0.2,["width"]=0.45,["height"]=0.07,["dropWidth"]=0.45,["dropHeight"]=0.8,["relative"]=true,["parent"]=mapsettings.environmentTab,["positive"]=true,["maxLength"]=3,["rows"]=weather}
	mapsettings.weather:addChangeHandler(function(self) if self:getRow() then setWeather(self:getRow() - 1) end end )
	--
	mapsettings.radioCustom = guiCreateRadioButton ( 0.12, 0.32, 0.1, 0.06, "Custom", true, mapsettings.environmentTab )
	mapsettings.customWeather = editingControl.natural:create{["x"]=0.25,["y"]=0.32,["width"]=0.08,["height"]=0.11,["relative"]=true,["parent"]=mapsettings.environmentTab,["positive"]=true,["max"]=255,["enabled"]=false}
	mapsettings.customWeather:addChangeHandler(function(self) local value = self:getValue() or 0 setWeather(value) end )
	addEventHandler ( "onClientGUIMouseDown", mapsettings.radioCustom, mapsettings_radioChange )
	--
	guiCreateMinimalLabel ( 0.02, 0.5, "Gamespeed:", true, mapsettings.environmentTab )
	mapsettings.gamespeed = editingControl.number:create{["x"]=0.16,["y"]=0.48,["width"]=0.08,["height"]=0.11,["relative"]=true,["parent"]=mapsettings.environmentTab,["positive"]=true, ["maxLength"]=3}

	guiCreateMinimalLabel ( 0.02, 0.68, "Gravity:", true, mapsettings.environmentTab )
	mapsettings.gravity = editingControl.number:create{["x"]=0.16,["y"]=0.64,["width"]=0.08,["height"]=0.11,["relative"]=true,["parent"]=mapsettings.environmentTab,["positive"]=true}

	guiCreateMinimalLabel ( 0.02, 0.86, "Wave Height:", true, mapsettings.environmentTab )
	mapsettings.waveheight = editingControl.number:create{["x"]=0.16,["y"]=0.82,["width"]=0.1,["height"]=0.11,["relative"]=true,["parent"]=mapsettings.environmentTab,["positive"]=true,["min"]=0,["max"]=100}
	mapsettings.waveheight:addChangeHandler(function(self) if self:getValue() then setWaveHeight(self:getValue()) end end )

	guiCreateMinimalLabel ( 0.35, 0.5, "Minimum players:", true, mapsettings.environmentTab )
	mapsettings.minplayers = editingControl.number:create{["x"]=0.52,["y"]=0.48,["width"]=0.08,["height"]=0.11,["relative"]=true,["parent"]=mapsettings.environmentTab,["positive"]=true, ["maxLength"]=3,["max"]=128}

	guiCreateMinimalLabel ( 0.35, 0.68, "Maximum players:", true, mapsettings.environmentTab )
	mapsettings.maxplayers = editingControl.number:create{["x"]=0.52,["y"]=0.64,["width"]=0.08,["height"]=0.11,["relative"]=true,["parent"]=mapsettings.environmentTab,["positive"]=true, ["maxLength"]=3,["min"]=2,["max"]=128}
	--create the gamemode settings tab
	mapsettings.settingsList = guiCreateGridList ( 0.02, 0.02, 0.3, 0.95, true, mapsettings.gamemodeSettingsTab )
	guiGridListAddColumn ( mapsettings.settingsList, "Settings", 0.8 )
	guiGridListSetSortingEnabled ( mapsettings.settingsList, false )
	mapsettings.value = guiCreateLabel ( 0.34, 0.62, 1, 0.1, "Value:", true, mapsettings.gamemodeSettingsTab )
	mapsettings.friendlyName = guiCreateLabel ( 0.34, 0.02, 1, 0.1, "", true, mapsettings.gamemodeSettingsTab )
	guiLabelSetColor ( mapsettings.friendlyName, 255,255,255 )
	guiSetFont ( mapsettings.friendlyName, "clear-normal" )
	mapsettings.required = guiCreateLabel( 0.34, 0.09, 1, 0.1, "", true, mapsettings.gamemodeSettingsTab )
	guiSetFont ( mapsettings.required, "default-bold-small" )
	guiLabelSetColor ( mapsettings.required, 16, 108, 11 )
	mapsettings.description = guiCreateLabel( 0.34, 0.16, 0.65, 1, "", true, mapsettings.gamemodeSettingsTab )
	guiSetFont ( mapsettings.description, "default-small" )
	guiLabelSetHorizontalAlign ( mapsettings.description, "left", true )
	toggleSettingsGUI(false)
	--create the META tab
	mapsettings.metaName = editingControl.string:create{["x"]=0.12,["y"]=0.04,["width"]=0.3,["height"]=0.11,["relative"]=true,["parent"]=mapsettings.metaTab, ["maxLength"]=30}

	guiCreateMinimalLabel ( 0.02, 0.06, "Name:", true, mapsettings.metaTab )
	mapsettings.metaAuthor = editingControl.string:create{["x"]=0.12,["y"]=0.2,["width"]=0.3,["height"]=0.11,["relative"]=true,["parent"]=mapsettings.metaTab, ["maxLength"]=30}

	guiCreateMinimalLabel ( 0.02, 0.22, "Author:", true, mapsettings.metaTab )
	mapsettings.metaVersion = editingControl.string:create{["x"]=0.12,["y"]=0.36,["width"]=0.3,["height"]=0.11,["relative"]=true,["parent"]=mapsettings.metaTab, ["maxLength"]=30}

	guiCreateMinimalLabel ( 0.02, 0.38, "Version:", true, mapsettings.metaTab )
	mapsettings.metaDescription = editingControl.string:create{["x"]=0.16,["y"]=0.54,["width"]=0.7,["height"]=0.11,["relative"]=true,["parent"]=mapsettings.metaTab, ["maxLength"]=60}

	guiCreateMinimalLabel ( 0.02, 0.56, "Description:", true, mapsettings.metaTab )
	--create the gamemodes tab
	mapsettings.availGamemodes = guiCreateGridList ( 0.02, 0.02, 0.3, 0.95, true, mapsettings.gamemodesTab )
	mapsettings.addedGamemodes = guiCreateGridList ( 0.68, 0.02, 0.3, 0.95, true, mapsettings.gamemodesTab )
	guiGridListAddColumn ( mapsettings.availGamemodes, "Available gamemodes", 0.8 )
	guiGridListAddColumn ( mapsettings.addedGamemodes, "Added gamemodes", 0.8 )
	mapsettings.gamemodesAdd = guiCreateButton ( 0.4, 0.3, 0.2, 0.1, "Add", true, mapsettings.gamemodesTab )
	mapsettings.gamemodesRemove = guiCreateButton ( 0.4, 0.6, 0.2, 0.1, "Remove", true, mapsettings.gamemodesTab )
	addEventHandler ( "onClientGUIClick", mapsettings.gamemodesAdd, gamemodesAdd )
	addEventHandler ( "onClientGUIDoubleClick", mapsettings.availGamemodes, gamemodesAdd )
	addEventHandler ( "onClientGUIClick", mapsettings.gamemodesRemove, gamemodesRemove )
	addEventHandler ( "onClientGUIDoubleClick", mapsettings.addedGamemodes, gamemodesRemove )
	--Add ok/cancel event handlers
	addEventHandler ( "onClientGUIClick", mapsettings.cancel, cancelMapSettings,false )
	addEventHandler ( "onClientGUIClick", mapsettings.ok, confirmMapSettings,false )
	---Hook the catalogs browser if it is launched
	addEventHandler("onClientControlBrowserLaunch", mapsettings.gamemodeSettingsTab,
		function ()
			guiSetVisible(mapsettings.window, false)
		end
	)
	addEventHandler("onClientControlBrowserClose", mapsettings.gamemodeSettingsTab,
		function ()
			guiSetVisible(mapsettings.window, true)
			guiSetInputEnabled(true)
		end
	)
end

function gamemodesAdd ()
	local row = guiGridListGetSelectedItem ( mapsettings.availGamemodes )
	local text = guiGridListGetItemText ( mapsettings.availGamemodes, row, 1 )
	if text == "" then return end
	guiGridListRemoveRow ( mapsettings.availGamemodes,row )
	local newRow = guiGridListAddRow ( mapsettings.addedGamemodes )
	guiGridListSetItemText ( mapsettings.addedGamemodes, newRow, 1, text, false, false )
end

function gamemodesRemove ()
	local row = guiGridListGetSelectedItem ( mapsettings.addedGamemodes )
	local text = guiGridListGetItemText ( mapsettings.addedGamemodes, row, 1 )
	if text == "" then return end
	guiGridListRemoveRow ( mapsettings.addedGamemodes,row )
	local newRow = guiGridListAddRow ( mapsettings.availGamemodes )
	guiGridListSetItemText ( mapsettings.availGamemodes, newRow, 1, text, false, false )
end

------OK and Cancel clicking

function cancelMapSettings ()
	undoEnvironment()
	guiGridListSetSelectedItem ( mapsettings.settingsList, -1, -1 )
	removeEventHandler ( "onClientGUIMouseDown", mapsettings.settingsList, settingsListMouseDown )
	guiSetVisible ( mapsettings.window, false )
	setGUIShowing(true)
	guiSetInputEnabled ( false )
	setWorldClickEnabled ( true )
	previousRow = -1
	if ( tutorialVars.onMSClose ) then
		tutorialNext ()
	end
	setCameraMatrix(unpack(mapSettingsCamera))
end


function confirmMapSettings ()
	local versionText = mapsettings.metaVersion:getValue()
	if not versionText or not (( string.match (versionText, "^%d+$") ) or ( string.match (versionText, "^%d+%.%d+$") ) or ( string.match (versionText, "^%d+%.%d+%.%d+$") )) then
		exports.dialogs:messageBox("Bad value", "Invalid META \"Version\" specified", false, "ERROR", "OK")
		return
	end
	if not mapsettings.timeHour:getValue() or not mapsettings.timeMinute:getValue()
		or mapsettings.timeHour:getValue() > 23 or mapsettings.timeMinute:getValue() > 59 then
		exports.dialogs:messageBox("Bad value", "Invalid time specified", false, "ERROR", "OK")
		return
	end

	-- if mapsettings.metaAuthor:getValue() == "" then
		-- exports.dialogs:messageBox("Bad value", "Invalid META \"Author\" specified", false, "ERROR", "OK")
		-- return
	-- end
	if not tonumber(mapsettings.maxplayers:getValue()) then
		exports.dialogs:messageBox("Bad value", "Invalid \"Maximum Players\" specified", false, "ERROR", "OK")
		return
	end
	if not tonumber(mapsettings.minplayers:getValue()) then
		exports.dialogs:messageBox("Bad value", "Invalid \"Maximum Players\" specified", false, "ERROR", "OK")
		return
	end
	if mapsettings.minplayers:getValue() >=  mapsettings.maxplayers:getValue() then
		exports.dialogs:messageBox("Bad value", "Invalid \"Maximum Players\" specified", false, "ERROR", "OK")
		return
	end
	if not tonumber(mapsettings.gamespeed:getValue()) then
		mapsettings.gamespeed:setValue(currentMapSettings.gamespeed)
	end
	if not tonumber(mapsettings.gravity:getValue()) then
		mapsettings.gravity:setValue(currentMapSettings.gravity)
	end
	if not tonumber(mapsettings.waveheight:getValue()) then
		mapsettings.waveheight:setValue(currentMapSettings.waveheight)
	end
	if ( not tonumber(mapsettings.customWeather:getValue()) ) and ( guiRadioButtonGetSelected ( mapsettings.radioCustom )  ) then
		--Put it back onto the preset radio button
		guiRadioButtonSetSelected ( mapsettings.radioPreset, true )
		mapsettings_radioChange()
	end
	guiGridListSetSelectedItem ( mapsettings.settingsList, -1, -1 )
	mapsettings.gamemodeSettings = copyTable ( mapsettings.rowValues )
	currentMapSettings.rowData = rowData
	currentMapSettings.gamemodeSettings = mapsettings.gamemodeSettings
	dumpMapSettings()
	setMapSettings()
	triggerServerEvent ( "doSaveMapSettings", localPlayer, currentMapSettings )
	setGUIShowing(true)
	guiSetInputEnabled ( false )
	setWorldClickEnabled ( true )
	guiSetVisible ( mapsettings.window, false )
	previousRow = -1
	removeEventHandler ( "onClientGUIMouseDown", mapsettings.settingsList, settingsListMouseDown )
	--tut
	if ( tutorialVars.onMSClose ) then
		tutorialNext()
	end
	setCameraMatrix(unpack(mapSettingsCamera))
end


function mapsettings_radioChange ()
	if guiRadioButtonGetSelected ( mapsettings.radioPreset ) then
		mapsettings.weather:enable()
		mapsettings.customWeather:disable()
		if mapsettings.weather:getRow() then setWeather(mapsettings.weather:getRow() - 1) end
	else
		mapsettings.weather:disable()
		mapsettings.customWeather:enable()
		if mapsettings.customWeather:getValue() then setWeather(mapsettings.customWeather:getValue()) end
	end
end
