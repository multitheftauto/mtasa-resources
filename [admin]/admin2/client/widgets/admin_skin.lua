--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_skin.lua
*
*	Original File by lil_Toady
*
*	Thanks to: 
*	Talidan and Slothman for Skins list
*
**************************************]]

aSkin = {
	Form = nil,
	skins = {},
}

function aSkin.Show ( player )
	if ( aSkin.Form == nil ) then
		local x, y = guiGetScreenSize()
		aSkin.Form		= guiCreateWindow ( x / 2 - 140, y / 2 - 125, 280, 250, "Player Skin Select", false )
		aSkin.Label		= guiCreateLabel ( 0.03, 0.09, 0.94, 0.07, "Select a skin from the list or enter the id", true, aSkin.Form )
					  guiLabelSetHorizontalAlign ( aSkin.Label, "center" )
					  guiLabelSetColor ( aSkin.Label, 255, 0, 0 )
		aSkin.Groups	= guiCreateCheckBox ( 0.03, 0.90, 0.70, 0.09, "Sort by groups", false, true, aSkin.Form )
					  if ( aGetSetting ( "skinsGroup" ) ) then guiCheckBoxSetSelected ( aSkin.Groups, true ) end

		aSkin.List		= guiCreateGridList ( 0.03, 0.18, 0.70, 0.71, true, aSkin.Form )
					  guiGridListAddColumn( aSkin.List, "ID", 0.20 )
					  guiGridListAddColumn( aSkin.List, "", 0.75 )

		aSkin.ID		= guiCreateEdit ( 0.75, 0.18, 0.27, 0.09, "0", true, aSkin.Form )
					  guiEditSetMaxLength ( aSkin.ID, 3 )

		aSkin.Accept	= guiCreateButton ( 0.75, 0.28, 0.27, 0.09, "Select", true, aSkin.Form, "setskin" )
		aSkin.Cancel	= guiCreateButton ( 0.75, 0.88, 0.27, 0.09, "Cancel", true, aSkin.Form )


		aSkin.Load ()
		aSkin.Refresh ( guiCheckBoxGetSelected ( aSkin.Groups ) )

		addEventHandler ( "onClientGUIClick", aSkin.Form, aSkin.onClick )
		addEventHandler ( "onClientGUIDoubleClick", aSkin.Form, aSkin.onDoubleClick )
		--Register With Admin Form
		aRegister ( "PlayerSkin", aSkin.Form, aSkin.Show, aSkin.Close )
	end

	aSkin.Select = player
	guiSetVisible ( aSkin.Form, true )
	guiBringToFront ( aSkin.Form )
end

function aSkin.Close ( destroy )
	if ( destroy ) then
		aSkin.skins = {}
		if ( aSkin.Form ) then
			removeEventHandler ( "onClientGUIClick", aSkin.Form, aSkin.onClick )
			removeEventHandler ( "onClientGUIDoubleClick", aSkin.Form, aSkin.onDoubleClick )
			destroyElement ( aSkin.Form )
			aSkin.Form = nil
		end
	else
		guiSetVisible ( aSkin.Form, false )
	end
end

function aSkin.onDoubleClick ( button )
	if ( button == "left" ) then
		if ( source == aSkin.List ) then
			if ( guiGridListGetSelectedItem ( aSkin.List ) ~= -1 ) then
				local id = tonumber ( guiGridListGetItemText ( aSkin.List, guiGridListGetSelectedItem ( aSkin.List ), 1 ) )
				triggerServerEvent ( "aPlayer", getLocalPlayer(), aSkin.Select, "setskin", id )
				aSkin.Close ( false )
			end
		end
	end
end

function aSkin.onClick ( button )
	if ( button == "left" ) then
		if ( source == aSkin.Accept ) then
			if ( tonumber ( guiGetText ( aSkin.ID ) ) ) then
					triggerServerEvent ( "aPlayer", getLocalPlayer(), aSkin.Select, "setskin", tonumber ( guiGetText ( aSkin.ID ) ) )
					aSkin.Close ( false )
			else
				if ( guiGridListGetSelectedItem ( aSkin.List ) ~= -1 ) then
					local id = tonumber ( guiGridListGetItemText ( aSkin.List, guiGridListGetSelectedItem ( aSkin.List ), 1 ) )
					guiSetVisible ( aSkin.Form, false )
					triggerServerEvent ( "aPlayer", getLocalPlayer(), aSkin.Select, "setskin", id )
				else
					messageBox ( "No skin selected!", MB_ERROR, MB_OK )
				end
			end
		elseif ( source == aSkin.List ) then
			if ( guiGridListGetSelectedItem ( aSkin.List ) ~= -1 ) then
				local id = guiGridListGetItemText ( aSkin.List, guiGridListGetSelectedItem ( aSkin.List ), 1 )
				guiSetText ( aSkin.ID, id )
			end
		elseif ( source == aSkin.Cancel ) then
			aSkin.Close ( false )
		elseif ( source == aSkin.Groups ) then
			aSkin.Refresh ( guiCheckBoxGetSelected ( aSkin.Groups ) )
		end
	end
end

function aSkin.Load ()
	local table = {}
	local node = xmlLoadFile ( "conf\\skins.xml" )
	if ( node ) then
		local groups = 0
		while ( xmlFindChild ( node, "group", groups ) ~= false ) do
			local group = xmlFindChild ( node, "group", groups )
			local groupn = xmlNodeGetAttribute ( group, "name" )
			table[groupn] = {}
			local skins = 0
			while ( xmlFindChild ( group, "skin", skins ) ~= false ) do
				local skin = xmlFindChild ( group, "skin", skins )
				local id = #table[groupn] + 1
				table[groupn][id] = {}
				table[groupn][id]["model"] = xmlNodeGetAttribute ( skin, "model" )
				table[groupn][id]["name"] = xmlNodeGetAttribute ( skin, "name" )
				skins = skins + 1
			end
			groups = groups + 1
		end
	end
	aSkin.skins = table
end

function aSkin.Refresh ( groups )
	aSetSetting ( "skinsGroup", groups )
	guiGridListClear ( aSkin.List )
	if ( groups ) then
		for name, group in pairs ( aSkin.skins ) do
			local row = guiGridListAddRow ( aSkin.List )
			guiGridListSetItemText ( aSkin.List, row, 2, name, true, false )
			for id, skin in ipairs ( aSkin.skins[name] ) do
				row = guiGridListAddRow ( aSkin.List )
				guiGridListSetItemText ( aSkin.List, row, 1, skin.model, false, true )
				guiGridListSetItemText ( aSkin.List, row, 2, skin.name, false, false )
			end
		end
		guiGridListSetSortingEnabled ( aSkin.List, false )
	else
		local skins = {}
		for name, group in pairs ( aSkin.skins ) do
			for id, skin in pairs ( group ) do
				local id = tonumber ( skin.model )
				skins[id] = skin.name
			end
		end
		local i = 0
		while ( i <= 288 ) do
			if ( skins[i] ~= nil ) then
				local row = guiGridListAddRow ( aSkin.List )
				guiGridListSetItemText ( aSkin.List, row, 1, tostring ( i ), false, true )
				guiGridListSetItemText ( aSkin.List, row, 2, skins[i], false, false )
			end
			i = i + 1
		end
		guiGridListSetSortingEnabled ( aSkin.List, true )
	end
end