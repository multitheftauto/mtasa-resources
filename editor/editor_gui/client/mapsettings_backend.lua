--store defaults
local MINUTE_DURATION = 2147483647
local SET_TIME_TIMER

currentMapSettings = {}
local mapSettingFunctionsGet = {}
local mapSettingFunctionsSet = {}
local mapSettingTypes = { 
"lockTime",
"timeHour",
"timeMinute",
"gamespeed",
"gravity",
"waveheight",
"metaAuthor",
"metaDescription",
"metaName",
"metaVersion",
"maxPlayers",
"minPlayers"
}
mapSettingSpecial = {
["availGamemodes"] = "gridlist",
["addedGamemodes"] = "gridlist",
["gamemodeSettings"] = "",
["newSettings"] = "",
["rowData"] = "",
["weather"] = "weather",
}


addEventHandler ( "onClientResourceStart", getResourceRootElement(getThisResource()),
	function()
		freezeTime ( true, 12, 00 )
	end
)

addEvent ( "syncMapSettings",true)
addEventHandler ( "syncMapSettings", getRootElement(), 
function ( newMapSettings )
	currentMapSettings = newMapSettings
	freezeTime ( true, currentMapSettings.timeHour, currentMapSettings.timeMinute )
	setWeather ( currentMapSettings.weather )
	refreshGamemodeSettings()
	setMapSettings()
end
)

function freezeTime ( enabled, hr, mn )
	if enabled then
		setTime ( hr, mn )
		
		if ( SET_TIME_TIMER ) then
			for i,timer in ipairs(getTimers()) do
				if timer == SET_TIME_TIMER then
					killTimer ( timer )
					break
				end
			end
		end
		
		SET_TIME_TIMER = setTimer(
			function() 
				setTime(tonumber(currentMapSettings.timeHour), tonumber(currentMapSettings.timeMinute)) 
			end, 
		MINUTE_DURATION, 0)
		
		return setMinuteDuration ( MINUTE_DURATION )
	else
		if ( SET_TIME_TIMER ) then
			for i,timer in ipairs(getTimers()) do
				if timer == SET_TIME_TIMER then
					killTimer ( timer )
					break
				end
			end
		end
		setMinuteDuration ( 1000 )
		if hr and mn then
			return setTime ( hr, mn )
		end
	end
end

function dumpMapSettings()
	--first we dump the settings
	for k,gui in pairs(mapSettingTypes) do
		currentMapSettings[gui] = mapsettings[gui]:getValue()
	end
	--these are special
	for gui,setType in pairs(mapSettingSpecial) do
		if ( mapSettingFunctionsGet[setType] ) then
			mapSettingFunctionsGet[setType]( gui )
		end
	end
end

function setMapSettings()
	--copy over the temporary gamemode settings - not just reference it
	--we update the settings
	for gui,value in pairs(currentMapSettings) do
		local theType = mapSettingSpecial[gui]
		if theType then
			if 	mapSettingFunctionsSet[theType] then 
				mapSettingFunctionsSet[theType](gui) 
			end
		else
			mapsettings[gui]:setValue(value) 
		end
		--[[
		if mapSettingAction[gui] then 
			mapSettingAction[gui]() 
		end
		]]
	end
end

--Previously individual all widgets had their own mapSettingFunctionsGet/Set functions.  This is now handled by a generic system using classes
--Gridlists/Settings however still use the old system because they require lots of special code, and are not needed in terms of EDF.
function mapSettingFunctionsGet.weather( gui )
	if guiRadioButtonGetSelected ( mapsettings.radioPreset ) then
		currentMapSettings[gui] = mapsettings.weather:getRow() - 1
	else
		currentMapSettings[gui] = mapsettings.customWeather:getValue()
	end
end

function mapSettingFunctionsSet.weather( gui )
	if tonumber(currentMapSettings[gui]) > 19 then
		guiRadioButtonSetSelected ( mapsettings.radioCustom,true )
		mapsettings.customWeather:setValue(currentMapSettings[gui])
	else
		guiRadioButtonSetSelected ( mapsettings.radioPreset,true )
		guiSetText(mapsettings.customWeather.GUI.editField,"")
		mapsettings.weather:setValue(currentMapSettings[gui] + 1)
	end
	mapsettings_radioChange()
end

function mapSettingFunctionsGet.gridlist( gui )
	local totalRows = guiGridListGetRowCount(mapsettings[gui])
	local row = 0
	local items = {}
	while row ~= totalRows do
		local text = guiGridListGetItemText ( mapsettings[gui], row, 1 )
		if text ~= "" then
			table.insert ( items, text )
		end
		row = row + 1
	end
	currentMapSettings[gui] = items
end

---set functions
function mapSettingFunctionsSet.gridlist( gui )
	guiGridListClear ( mapsettings[gui] )
	for k,v in ipairs(currentMapSettings[gui]) do
		local row = guiGridListAddRow ( mapsettings[gui] )
		guiGridListSetItemText ( mapsettings[gui], row, 1, v, false, false )
	end
end
