--store defaults
local MINUTE_DURATION = 2147483647
local SET_TIME_TIMER
local previousEnvironment,radioWeather = {}
currentMapSettings = {}
local mapSettingFunctionsGet = {}
local mapSettingFunctionsSet = {}
local mapSettingTypes = {
"locked_time",
"useLODs",
"timeHour",
"timeMinute",
"gamespeed",
"gravity",
"waveheight",
"metaAuthor",
"metaDescription",
"metaName",
"metaVersion",
"maxplayers",
"minplayers"
}
mapSettingSpecial = {
["availGamemodes"] = "gridlist",
["addedGamemodes"] = "gridlist",
["gamemodeSettings"] = "",
["newSettings"] = "",
["rowData"] = "",
["weather"] = "weather",
}
local mapSettingChangeHandled = { --Ones that change live
	"customWeather",
	"weather",
	"timeHour",
	"timeMinute",
	"waveheight",
}

local function deepTableEqual(table1, table2)
	--compare table1 keys with table2's, mark the ones we compare
	local checked = {}
	for k, v in pairs(table1) do
		if type(v) == "table" then
			if type(table2[k]) == "table" then
				local result = deepTableEqual(v, table2[k])
				if not result then
					return false
				end
			else
				return false
			end
		else
			if v ~= table2[k] then
				return false
			end
		end
		checked[k] = true
	end
	--if one key in table2 was not checked, table2 has more keys than table1
	for k in pairs(table2) do
		if not checked[k] then
			return false
		end
	end

	return true
end

function storeOldMapSettings()
	previousEnvironment = {}
	for i,setting in ipairs(mapSettingChangeHandled) do
		previousEnvironment[setting] = mapsettings[setting]:getValue()
	end
	radioPresetWeather = guiRadioButtonGetSelected ( mapsettings.radioPreset )
end

function undoEnvironment()
	for k,control in ipairs(mapSettingChangeHandled) do
		local value = mapsettings[control]:getValue()
		local modified

		if type(value) ~= "table" then
			modified = (value ~= previousEnvironment[control])
		else
			modified = not deepTableEqual(value, previousEnvironment[control])
		end

		if modified then
			mapsettings[control]:setValue(previousEnvironment[control])
		end
	end
	guiRadioButtonSetSelected ( mapsettings.radioPreset, radioPresetWeather )
	mapsettings_radioChange ()
end


addEventHandler ( "onClientResourceStart", resourceRoot,
	function()
		freezeTime ( true, 12, 00 )
	end
)

addEvent ( "syncMapSettings",true)
addEventHandler ( "syncMapSettings", root,
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
		setMinuteDuration ( MINUTE_DURATION )
	else
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
