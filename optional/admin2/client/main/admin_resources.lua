--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\main\admin_resources.lua
*
*	Original File by lil_Toady
*
**************************************]]

aResourcesTab = {
	LogLines = 1,
	Resources = {}
}

addEvent ( "aClientResourceStart", true )
addEvent ( "aClientResourceStop", true )

function aResourcesTab.Create ( tab )
	aResourcesTab.Tab = tab

	aResourcesTab.Panel			= guiCreateTabPanel ( 0.01, 0.02, 0.98, 0.96, true, aResourcesTab.Tab )
	aResourcesTab.MainTab			= guiCreateTab ( "Main", aResourcesTab.Panel )

	aResourcesTab.ResourceList		= guiCreateGridList ( 0.01, 0.02, 0.35, 0.91, true, aResourcesTab.MainTab )
					  		  guiGridListAddColumn( aResourcesTab.ResourceList, "Resource", 0.55 )
					  		  guiGridListAddColumn( aResourcesTab.ResourceList, "State", 0.40 )
	aResourcesTab.ResourceRefresh		= guiCreateButton ( 0.01, 0.94, 0.35, 0.04, "Refresh list", true, aResourcesTab.MainTab, "listresources" )
	aResourcesTab.ResourceStart		= guiCreateButton ( 0.79, 0.02, 0.20, 0.04, "Start", true, aResourcesTab.MainTab, "start" )
	aResourcesTab.ResourceRestart		= guiCreateButton ( 0.79, 0.07, 0.20, 0.04, "Restart", true, aResourcesTab.MainTab, "restart" )
	aResourcesTab.ResourceStop		= guiCreateButton ( 0.79, 0.12, 0.20, 0.04, "Stop", true, aResourcesTab.MainTab, "stop" )
							  guiCreateHeader ( 0.38, 0.03, 0.20, 0.04, "Resource info:", true, aResourcesTab.MainTab )
	aResourcesTab.Name			= guiCreateLabel ( 0.39, 0.07, 0.40, 0.04, "Name: -", true, aResourcesTab.MainTab );
	aResourcesTab.Type			= guiCreateLabel ( 0.39, 0.11, 0.40, 0.04, "Type: -", true, aResourcesTab.MainTab );
	aResourcesTab.Author			= guiCreateLabel ( 0.39, 0.15, 0.40, 0.04, "Author: -", true, aResourcesTab.MainTab );
	aResourcesTab.Version			= guiCreateLabel ( 0.39, 0.19, 0.40, 0.04, "Version: -", true, aResourcesTab.MainTab );
	aResourcesTab.Description		= guiCreateLabel ( 0.39, 0.23, 0.60, 0.10, "Description: -", true, aResourcesTab.MainTab );
							  guiLabelSetHorizontalAlign ( aResourcesTab.Description, "left", true )
							  guiCreateHeader ( 0.38, 0.32, 0.20, 0.04, "Resource content:", true, aResourcesTab.MainTab )
	aModules					= guiCreateTabPanel ( 0.38, 0.35, 0.61, 0.38, true, aResourcesTab.MainTab )
					 		  guiCreateHeader ( 0.38, 0.75, 0.20, 0.04, "Execute code:", true, aResourcesTab.MainTab )
	aResourcesTab.Command			= guiCreateMemo ( 0.38, 0.80, 0.50, 0.18, "", true, aResourcesTab.MainTab )
	aResourcesTab.ExecuteClient		= guiCreateButton ( 0.89, 0.80, 0.10, 0.04, "Client", true, aResourcesTab.MainTab, "execute" )
	aResourcesTab.ExecuteServer		= guiCreateButton ( 0.89, 0.85, 0.10, 0.04, "Server", true, aResourcesTab.MainTab, "execute" )
	aResourcesTab.ExecuteAdvanced		= guiCreateLabel ( 0.2, 0.4, 1.0, 0.50, "For advanced users only.", true, aResourcesTab.Command )
					  		  guiLabelSetColor ( aResourcesTab.ExecuteAdvanced, 255, 0, 0 )

	-- EVENTS
	addEventHandler ( "aClientSync", _root, aResourcesTab.onClientSync )
	addEventHandler ( "onClientGUIClick", aResourcesTab.MainTab, aResourcesTab.onClientClick )
	addEventHandler ( "aClientResourceStart", _root, aResourcesTab.onClientResourceStart )
	addEventHandler ( "aClientResourceStop", _root, aResourcesTab.onClientResourceStop )

	if ( hasPermissionTo ( "command.listresources" ) ) then triggerServerEvent ( "aSync", getLocalPlayer(), "resources" ) end

end

function aResourcesTab.onClientClick ( button )
	guiSetInputEnabled ( false )
	if ( button == "left" ) then
		if ( ( source == aResourcesTab.ResourceStart ) or ( source == aResourcesTab.ResourceRestart ) or ( source == aResourcesTab.ResourceStop ) ) then
			if ( guiGridListGetSelectedItem ( aResourcesTab.ResourceList ) == -1 ) then
				aMessageBox ( "error", "No resource selected!" )
			else
				local name = guiGridListGetItemText ( aResourcesTab.ResourceList, guiGridListGetSelectedItem ( aResourcesTab.ResourceList ), 1 )
				if ( source == aResourcesTab.ResourceStart ) then triggerServerEvent ( "aResource", getLocalPlayer(), name, "start" )
				elseif ( source == aResourcesTab.ResourceRestart ) then triggerServerEvent ( "aResource", getLocalPlayer(), name, "restart" )
				elseif ( source == aResourcesTab.ResourceStop ) then triggerServerEvent ( "aResource", getLocalPlayer(), name, "stop" )
				end
			end
		elseif ( source == aResourcesTab.ResourceList ) then
			if ( guiGridListGetSelectedItem ( aResourcesTab.ResourceList ) ~= -1 ) then
				local name = guiGridListGetItemText ( aResourcesTab.ResourceList, guiGridListGetSelectedItem ( aResourcesTab.ResourceList ), 1 )
				local info = aResourcesTab.Resources[name]
				if ( info ) then
					guiSetText ( aResourcesTab.Name, "Name: "..( info.name or name ) )
					guiSetText ( aResourcesTab.Type, "Type: "..( info.type or "Unknown" ) )
					guiSetText ( aResourcesTab.Author, "Author: "..( info.author or "Unknown" ) )
					guiSetText ( aResourcesTab.Version, "Version: "..( info.version or "Unknown" ) )
					guiSetText ( aResourcesTab.Description, "Description: "..( info.description or "None" ) )
				else
					triggerServerEvent ( "aSync", getLocalPlayer(), "resource", name )
				end
			end
		elseif ( source == aResourcesTab.ResourceRefresh ) then
			guiGridListClear ( aResourcesTab.ResourceList )
			triggerServerEvent ( "aSync", getLocalPlayer(), "resources" )
		elseif ( source == aResourcesTab.ExecuteClient ) then
			local code = guiGetText ( aResourcesTab.Command )
			if ( ( code ) and ( code ~= "" ) ) then
				local results = { pcall ( assert ( loadstring ( "return "..code ) ) ) }
				if ( results[1] ) then
					for i = 2, #results do
						local value = results[i]
						local type = type ( value )
						if ( isElement ( type ) ) then type = getElementType ( value ) end
						outputChatBox ( ( i - 1 )..": "..tostring ( value ).."["..type.."]", 10, 220, 10 )
					end
				else
					outputChatBox ( "Error: "..tostring ( results[2] ), 220, 10, 10 )
				end
			end
		elseif ( source == aResourcesTab.ExecuteServer ) then
			local code = guiGetText ( aResourcesTab.Command )
			if ( ( code ) and ( code ~= "" ) ) then
				triggerServerEvent ( "aExecute", getLocalPlayer(), code, true )
			end
		elseif ( source == aResourcesTab.Command ) then
			guiSetInputEnabled ( true )
			guiSetVisible ( aResourcesTab.ExecuteAdvanced, false )
		elseif ( source == aResourcesTab.ExecuteAdvanced ) then
			guiSetVisible ( aResourcesTab.ExecuteAdvanced, false )
		end
	end
end

function aResourcesTab.onClientSync ( type, data )
	if ( type == "resources" ) then
		for id, resource in ipairs ( data ) do
			local row = guiGridListAddRow ( aResourcesTab.ResourceList )
			guiGridListSetItemText ( aResourcesTab.ResourceList, row, 1, resource.name, false, false )
			guiGridListSetItemText ( aResourcesTab.ResourceList, row, 2, resource.state, false, false )
		end
	elseif ( type == "resource" ) then
		aResourcesTab.Resources[data.name] = data.info
		guiSetText ( aResourcesTab.Name, "Name: "..( data.info.name or data.name ) )
		guiSetText ( aResourcesTab.Type, "Type: "..( data.info.type or "Unknown" ) )
		guiSetText ( aResourcesTab.Author, "Author: "..( data.info.author or "Unknown" ) )
		guiSetText ( aResourcesTab.Version, "Version: "..( data.info.version or "Unknown" ) )
		guiSetText ( aResourcesTab.Description, "Description: "..( data.info.description or "None" ) )
	end
end

function aResourcesTab.onClientResourceStart ( resource )
	local id = 0
	while ( id <= guiGridListGetRowCount( aResourcesTab.ResourceList ) ) do
		if ( guiGridListGetItemText ( aResourcesTab.ResourceList, id, 1 ) == resource ) then
			guiGridListSetItemText ( aResourcesTab.ResourceList, id, 2, "running", false, false )
		end
		id = id + 1
	end
end

function aResourcesTab.onClientResourceStop ( resource )
	local id = 0
	while ( id <= guiGridListGetRowCount( aResourcesTab.ResourceList ) ) do
		if ( guiGridListGetItemText ( aResourcesTab.ResourceList, id, 1 ) == resource ) then
			guiGridListSetItemText ( aResourcesTab.ResourceList, id, 2, "loaded", false, false )
		end
		id = id + 1
	end
end