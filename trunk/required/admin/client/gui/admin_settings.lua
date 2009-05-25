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
		aSettingsList	= guiCreateGridList ( 0.03, 0.05, 0.97, 0.87, true, aSettingsForm )
						guiGridListAddColumn( aSettingsList, "name", 0.50 )
						guiGridListAddColumn( aSettingsList, "current", 0.25 )
						guiGridListAddColumn( aSettingsList, "default", 0.25 )
		aSettingsExit		= guiCreateButton ( 0.75, 0.95, 0.27, 0.04, "Close", true, aSettingsForm )

		addEvent ( "aAdminSettings", true )
		addEventHandler ( "aAdminSettings", getLocalPlayer(), aAdminSettings )
		addEventHandler ( "onClientGUIClick", aSettingsForm, aClientSettingsClick )
		addEventHandler ( "onClientGUIDoubleClick", aSettingsForm, aClientSettingsDoubleClick )
		--Register With Admin Form
		aRegister ( "SettingsManage", aSettingsForm, aManageSettings, aSettingsClose )
	end
	guiSetText( aSettingsForm, resName .. " Settings" )
	guiGridListClear( aSettingsList )
	triggerServerEvent ( "aAdmin", getLocalPlayer(), "settings", "getall", resName )
	guiSetVisible ( aSettingsForm, true )
	guiBringToFront ( aSettingsForm )
end

function aSettingsClose ( destroy )
	if ( ( destroy ) or ( guiCheckBoxGetSelected ( aPerformanceSettings ) ) ) then
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
		guiGridListClear( aSettingsList )
		-- get names
		local namesList = {}
		for name,value in pairs(aSettingsData["settings"]) do
			table.insert(namesList,name)
		end
		-- sort names
		table.sort(namesList, function(a,b) return(a < b) end)
		-- Add to gridlist using sorted names
		for i,name in ipairs(namesList) do
			local value = aSettingsData["settings"][name]
			local row = guiGridListAddRow( aSettingsList )
			guiGridListSetItemText ( aSettingsList, row, 1, name, false, false )
			guiGridListSetItemText ( aSettingsList, row, 2, tostring(value.current), false, false )
			guiGridListSetItemText ( aSettingsList, row, 3, tostring(value.default), false, false )
		end
	end
end

function aClientSettingsDoubleClick ( button )
	if ( button == "left" ) then
		if ( source == aSettingsList ) then
			local row = guiGridListGetSelectedItem ( aSettingsList )
			if ( row ~= -1 ) then
				local name = guiGridListGetItemText ( aSettingsList, row, 1 )
				if not aSettingsData["settings"][name] then
					outputDebugString( "aClientSettingsDoubleClick: Error with " .. name )
					return
				end
				local current = aSettingsData["settings"][name].current
				current = current == nil and "" or current
				aInputBox ( "Change setting",
							"Enter new value for '"..name.."'",
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
	end
end
