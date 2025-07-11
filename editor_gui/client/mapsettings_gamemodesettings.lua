local edfSettings = {}
rowData = {}
mapsettings.rowValues = {}
mapsettings.gamemodeSettings = {}
local valueWidget
local isHandled
addEventHandler ( "doLoadEDF", root,
function(tableEDF, resource)
	--store all our data neatly under the resource
	edfSettings[resource] = tableEDF["settings"]
	refreshGamemodeSettings()
	--send back the intepreted gui table so the server knows the settings !!Lazy, server could interpret this info or only one client could send it
	mapsettings.gamemodeSettings = copyTable ( mapsettings.rowValues )
	currentMapSettings.rowData = rowData
	currentMapSettings.gamemodeSettings = mapsettings.gamemodeSettings
	triggerServerEvent ( "doSaveMapSettings", localPlayer, currentMapSettings, true )
end )

addEventHandler ( "doUnloadEDF", root,
function(resource)
	--store all our data neatly under the resource
	edfSettings[resource] = nil
	refreshGamemodeSettings()
	--send back the intepreted gui table so the server knows the settings !!Lazy, server could interpret this info or only one client could send it
	mapsettings.gamemodeSettings = copyTable ( mapsettings.rowValues )
	currentMapSettings.rowData = rowData
	currentMapSettings.gamemodeSettings = mapsettings.gamemodeSettings
	triggerServerEvent ( "doSaveMapSettings", localPlayer, currentMapSettings, true )
end )

function refreshGamemodeSettings()
	guiGridListClear ( mapsettings.settingsList )
	local resourceCount = 0
	for resourceName,valueTable in pairs(edfSettings) do
		local row = guiGridListAddRow ( mapsettings.settingsList )
		guiGridListSetItemText ( mapsettings.settingsList, row, 1, resourceName, true, false )
		local count = 0
		for dataName, dataInfo in pairs(valueTable) do
			count = count + 1
			local subRow = guiGridListAddRow ( mapsettings.settingsList )
			guiGridListSetItemText ( mapsettings.settingsList, subRow, 1, dataName, false, false )
			rowData[subRow] = dataInfo
			rowData[subRow].resourceName = resourceName
			rowData[subRow].internalName = dataName
			mapsettings.rowValues[subRow] = dataInfo.default
			if currentMapSettings.newSettings and currentMapSettings.newSettings[dataName] then
				mapsettings.rowValues[subRow] = currentMapSettings.newSettings[dataName]
				mapsettings.gamemodeSettings = copyTable ( mapsettings.rowValues )
			end
		end
		if count == 0 then
			guiGridListRemoveRow ( mapsettings.settingsList, row )
		else
			resourceCount = resourceCount + 1
		end
	end
	if resourceCount == 0 then
		local row = guiGridListAddRow ( mapsettings.settingsList )
		guiGridListSetItemText ( mapsettings.settingsList, row, 1, "No Settings definitions", true, false )
	end
	currentMapSettings.newSettings = nil
end

local requiredText = { [true]="REQUIRED" }
function settingsListClicked()
	local row = guiGridListGetSelectedItem ( mapsettings.settingsList )
	local data = rowData[row]
	if row == previousRow then return end
	if ( valueWidget ) and ( previousRow ) then
		mapsettings.rowValues[previousRow] = valueWidget:getValue()
		if ( mapsettings.rowValues[previousRow] == "" or mapsettings.rowValues[previousRow] == nil ) and ( rowData[previousRow] ) and ( rowData[previousRow].default ) then
			mapsettings.rowValues[previousRow] = rowData[previousRow].default
		end
	end
	if data then
		toggleSettingsGUI(true)
		guiSetText ( mapsettings.required, requiredText[data.required] or "Optional" )
		local name = data.internalName
		if ( data.friendlyname  ) then
			name = data.friendlyname
		end
		guiSetText ( mapsettings.friendlyName, name )
		--
		if ( data.description ) then
			guiSetText ( mapsettings.description, data.description )
		end
		--
		local dataType = data.datatype
		if ( valueWidget ) then
			valueWidget:destroy()
			valueWidget = nil
		end
		local key,rows = gettok ( data.datatype,1,58 ),nil
		local token2 = gettok ( data.datatype,2,58 ) or key
		if key == "element" then
			dataType = key
			key = "types"
			rows = split(token2,44)
		elseif key == "selection" then
			dataType = key
			key = "validvalues"
			rows = split(token2,44)
		end

		valueWidget = editingControl[dataType]:create{x=208,y=182,label="Enabled",parent=mapsettings.gamemodeSettingsTab,[key]=rows}
		if mapsettings.rowValues[row] then
			valueWidget:setValue(mapsettings.rowValues[row])
		elseif data.default then
			valueWidget:setValue(data.default)
		end
	else
		toggleSettingsGUI(false)
	end
	previousRow = row
end

function toggleSettingsGUI(bool)
	if bool then
		if not isHandled then
			isHandled = true
			addEventHandler ( "onClientGUIMouseDown",root,applyGamemodeSettings )
		end
	else
		isHandled = false
		removeEventHandler ( "onClientGUIMouseDown",root,applyGamemodeSettings )
		if previousRow ~= -1 then
			if valueWidget then
				mapsettings.rowValues[previousRow] = valueWidget:getValue()
				if ( mapsettings.rowValues[previousRow] == "" or mapsettings.rowValues[previousRow] == nil ) and ( rowData[previousRow] ) and ( rowData[previousRow].default ) then
					mapsettings.rowValues[previousRow] = rowData[previousRow].default
				end
			end
		end
	end
	if mapsettings.applyGamemodeSettings then
		guiSetVisible ( mapsettings.applyGamemodeSettings, bool)
	end
	guiSetVisible ( mapsettings.description,bool )
	guiSetVisible ( mapsettings.value,bool)
	guiSetVisible ( mapsettings.required, bool)
	guiSetVisible ( mapsettings.friendlyName, bool)
	if ( valueWidget ) then
		valueWidget:destroy()
		valueWidget = nil
	end
end

function applyGamemodeSettings()
	if source == mapsettings.settingsList then return end
	local row = guiGridListGetSelectedItem ( mapsettings.settingsList )
	if row == -1 then return end
	mapsettings.rowValues[row] = valueWidget:getValue()
	if ( mapsettings.rowValues[row] == "" or mapsettings.rowValues[row] == nil ) and ( rowData[row] ) and ( rowData[row].default ) then
		mapsettings.rowValues[row] = rowData[row].default
	end
end

function settingsListMouseDown( button,state,x,y )
	if state == "up" then return end
	settingsListClicked()
end

function copyTable ( theTable )
	local copiedTable = {}
	for k,v in pairs(theTable) do
		copiedTable[k] = v
	end
	return copiedTable
end

addEventHandler ( "saveloadtest_return", root,
	function ( command )
		if command == "new" then
			mapsettings.rowValues = {}
			mapsettings.gamemodeSettings = {}
			refreshGamemodeSettings()
		end
	end
)
