--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_settings.lua
*
*	Original File by ccw
*
**************************************]]

aSettingsForm = nil
aSettingsData = {}

function aManageSettings ( resName )
	aSettingsData["settings"] = {}
	aSettingsData["resName"] = resName
	if ( aSettingsForm == nil ) then
		local x, y = guiGetScreenSize()
		aSettingsForm	= guiCreateWindow ( x / 2 - 230, y / 2 - 250, 460, 500, "", false )
		aSettingsTabPanel = guiCreateTabPanel ( 0.00, 0.05, 1, 0.95, true, aSettingsForm )
		aSettingsTab	= guiCreateTab ( "Players", aSettingsTabPanel, "players" )
		aSettingsList	= guiCreateGridList ( 0.03, 0.03, 0.94, 0.72, true, aSettingsTab )
						guiGridListAddColumn( aSettingsList, "name", 0.50 )
						guiGridListAddColumn( aSettingsList, "current", 0.25 )
						guiGridListAddColumn( aSettingsList, "default", 0.25 )
		aSettingsExit		= guiCreateButton ( 0.80, 0.93, 0.17, 0.04, "Close", true, aSettingsTab )
		aSettingDesc		= guiCreateMemo ( 0.03, 0.80, 0.75, 0.17, "", true, aSettingsTab )
		addEvent ( "aAdminSettings", true )
		addEventHandler ( "aAdminSettings", getLocalPlayer(), aAdminSettings )
		addEventHandler ( "onClientGUIClick", aSettingsForm, aClientSettingsClick )
		addEventHandler ( "onClientGUIDoubleClick", aSettingsForm, aClientSettingsDoubleClick )
		--Register With Admin Form
		aRegister ( "SettingsManage", aSettingsForm, aManageSettings, aSettingsClose )
	end
	guiSetText( aSettingsTab, resName .. " Settings" )
	guiSetText( aSettingDesc, "" )
	guiMemoSetReadOnly ( aSettingDesc, true )
	guiGridListClear( aSettingsList )
	triggerServerEvent ( "aAdmin", getLocalPlayer(), "settings", "getall", resName )
	guiSetVisible ( aSettingsForm, true )
	guiBringToFront ( aSettingsForm )
end

function aSettingsClose ( destroy )
	if ( ( destroy ) or ( aPerformanceSettings and guiCheckBoxGetSelected ( aPerformanceSettings ) ) ) then
		if ( aSettingsForm ) then
			removeEventHandler ( "onClientGUIClick", aSettingsForm, aClientSettingsClick )
			removeEventHandler ( "onClientGUIDoubleClick", aSettingsForm, aClientSettingsDoubleClick )
			destroyElement ( aSettingsForm )
			aSettingsForm = nil
		end
	else
		guiSetVisible ( aSettingsForm, false )
	end
end

function aAdminSettings ( type, resName, settingstable )
	-- Update gridlist
	if aSettingsData["resName"] ~= resName then
		outputDebugString( "aAdminSettings: Error for aSettingsData['resName'] ~= resName with " .. resName )
		return
	end
	if type == "change" then
		triggerServerEvent ( "aAdmin", getLocalPlayer(), "settings", "getall", resName )
	elseif type == "getall" then
		aSettingsData["settings"] = settingstable
		local rowindex = { [1] = 0 }
		-- get groups
		local groups = {}
		local groupnameList = {}
		for name,value in pairs(aSettingsData["settings"]) do
			local groupname = aSettingsData["settings"][name].group or ' '
			if not groups[groupname] then
				groups[groupname] = {}
				table.insert(groupnameList,groupname)
			end
			table.insert(groups[groupname],name)
		end
		-- sort groupnames
		table.sort(groupnameList, function(a,b) return(a < b) end)
		-- for each group
		for _,groupname in ipairs(groupnameList) do
			local namesList = groups[groupname]
			-- sort names
			table.sort(namesList, function(a,b) return(a < b) end)
			-- Add to gridlist using sorted names
			local row = guiGridListAddRowMaybe( aSettingsList, rowindex )
			guiGridListSetItemText ( aSettingsList, row, 1, string.sub(groupname,1,1)=='_' and string.sub(groupname,2) or groupname, true, false )
			for i,name in ipairs(namesList) do
				local value = aSettingsData["settings"][name]
				row = guiGridListAddRowMaybe( aSettingsList, rowindex )
				guiGridListSetItemText ( aSettingsList, row, 1, tostring(value.friendlyname or name), false, false )
				guiGridListSetItemText ( aSettingsList, row, 2, tostring(value.current), false, false )
				guiGridListSetItemText ( aSettingsList, row, 3, tostring(value.default), false, false )
				guiGridListSetItemData ( aSettingsList, row, 1, tostring(name) )
			end
		end
		guiGridListRemoveLastRows( aSettingsList, guiGridListGetRowCount( aSettingsList ) - rowindex[1] )
	end
end

function guiGridListAddRowMaybe ( aSettingsList, rowindex )
	local row
	if rowindex[1] < guiGridListGetRowCount( aSettingsList ) then
		row = rowindex[1]
	else
		row = guiGridListAddRow( aSettingsList )
	end
	rowindex[1] = rowindex[1] + 1
	return row
end

function guiGridListRemoveLastRows ( aSettingsList, amount )
	for i=1,amount do
		guiGridListRemoveRow( aSettingsList, guiGridListGetRowCount( aSettingsList ) - 1 )
	end
end

function aClientSettingsDoubleClick ( button )
	if ( button == "left" ) then
		if ( source == aSettingsList ) then
			local row = guiGridListGetSelectedItem ( aSettingsList )
			if ( row ~= -1 ) then
				local name = tostring( guiGridListGetItemData ( aSettingsList, row, 1 ) )
				if not aSettingsData["settings"][name] then
					outputDebugString( "aClientSettingsDoubleClick: Error with " .. name )
					return
				end
				local friendlyname = aSettingsData["settings"][name].friendlyname
				friendlyname = friendlyname or name
				local current = aSettingsData["settings"][name].current
				current = current == nil and "" or current
				aInputBox ( "Change setting",
							"Enter new value for '".. friendlyname .."'",
							tostring(current),
							"triggerServerEvent ( \"aAdmin\", getLocalPlayer(), \"settings\", \"change\", \""..aSettingsData["resName"].."\", \""..name.."\", $value )" )
			end
		end
	end
end

function aClientSettingsClick ( button )
	if ( button == "left" ) then
		if ( source == aSettingsExit ) then
			aSettingsClose ( false )
		end
		if ( source == aSettingsList ) then
			local row = guiGridListGetSelectedItem ( aSettingsList )
			if ( row ~= -1 ) then
				local name = tostring( guiGridListGetItemData ( aSettingsList, row, 1 ) )
				if not aSettingsData["settings"][name] then
					outputDebugString( "aClientSettingsClick: Error with " .. name )
					return
				end
				local desc = aSettingsData["settings"][name].desc or ''
				local accept = aSettingsData["settings"][name].accept
				local examples = aSettingsData["settings"][name].examples
				if examples then
					desc = desc .. '\n[Examples: ' .. examples .. ']'
				elseif accept and accept ~= '*' then
					desc = desc .. '\n[Values: ' .. accept .. ']'
				end
				guiSetText( aSettingDesc, desc )
			end
		end
	end
end
