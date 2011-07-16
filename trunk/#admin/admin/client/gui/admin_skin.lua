--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_skin.lua
*
*	Original File by lil_Toady
*
*	Thanks to: 
*	Talidan and Slothman for Skins list
*
**************************************]]

aSkins = {}
aSkinForm = nil
aSkinSelect = nil

function aPlayerSkin ( player )
	if ( aSkinForm == nil ) then
		local x, y = guiGetScreenSize()
		aSkinForm		= guiCreateWindow ( x / 2 - 140, y / 2 - 125, 280, 250, "Player Skin Select", false )
		aSkinLabel		= guiCreateLabel ( 0.03, 0.09, 0.94, 0.07, "Select a skin from the list or enter the id", true, aSkinForm )
					  guiLabelSetHorizontalAlign ( aSkinLabel, "center" )
					  guiLabelSetColor ( aSkinLabel, 255, 0, 0 )
		aSkinGroups		= guiCreateCheckBox ( 0.03, 0.90, 0.70, 0.09, "Sort by groups", false, true, aSkinForm )
					   if ( aGetSetting ( "skinsGroup" ) ) then guiCheckBoxSetSelected ( aSkinGroups, true ) end
		aSkinList		= guiCreateGridList ( 0.03, 0.18, 0.70, 0.71, true, aSkinForm )
					  guiGridListAddColumn( aSkinList, "ID", 0.20 )
					  guiGridListAddColumn( aSkinList, "", 0.75 )
					  aSkins = aLoadSkins ( )
					  aListSkins ( iif ( guiCheckBoxGetSelected ( aSkinGroups ), 2, 1 ) )

		aSkinID			= guiCreateEdit ( 0.75, 0.18, 0.27, 0.09, "0", true, aSkinForm )
					  guiEditSetMaxLength ( aSkinID, 3 )
		aSkinAccept		= guiCreateButton ( 0.75, 0.28, 0.27, 0.09, "Select", true, aSkinForm, "setskin" )
		aSkinCancel		= guiCreateButton ( 0.75, 0.88, 0.27, 0.09, "Cancel", true, aSkinForm )
		addEventHandler ( "onClientGUIClick", aSkinForm, aClientSkinClick )
		addEventHandler ( "onClientGUIDoubleClick", aSkinForm, aClientSkinDoubleClick )
		--Register With Admin Form
		aRegister ( "PlayerSkin", aSkinForm, aPlayerSkin, aPlayerSkinClose )
	end
	aSkinSelect = player
	guiSetVisible ( aSkinForm, true )
	guiBringToFront ( aSkinForm )
end

function aPlayerSkinClose ( destroy )
	if ( ( destroy ) or ( guiCheckBoxGetSelected ( aPerformanceSkin ) ) ) then
		if ( aSkinForm ) then
			removeEventHandler ( "onClientGUIClick", aSkinForm, aClientSkinClick )
			removeEventHandler ( "onClientGUIDoubleClick", aSkinForm, aClientSkinDoubleClick )
			aSkins = {}
			destroyElement ( aSkinForm )
			aStatsForm = nil
		end
	else
		guiSetVisible ( aSkinForm, false )
	end
end

function aClientSkinDoubleClick ( button )
	if ( button == "left" ) then
		if ( source == aSkinList ) then
			if ( guiGridListGetSelectedItem ( aSkinList ) ~= -1 ) then
				local id = tonumber ( guiGridListGetItemText ( aSkinList, guiGridListGetSelectedItem ( aSkinList ), 1 ) )
				triggerServerEvent ( "aPlayer", getLocalPlayer(), aSkinSelect, "setskin", id )
				aPlayerSkinClose ( false )
			end
		end
	end
end

function aClientSkinClick ( button )
	if ( button == "left" ) then
		if ( source == aSkinAccept ) then
			if ( tonumber ( guiGetText ( aSkinID ) ) ) then
					triggerServerEvent ( "aPlayer", getLocalPlayer(), aSkinSelect, "setskin", tonumber ( guiGetText ( aSkinID ) ) )
					aPlayerSkinClose ( false )
			else
				if ( guiGridListGetSelectedItem ( aSkinList ) ~= -1 ) then
					local id = tonumber ( guiGridListGetItemText ( aSkinList, guiGridListGetSelectedItem ( aSkinList ), 1 ) )
					guiSetVisible ( aSkinForm, false )
					triggerServerEvent ( "aPlayer", getLocalPlayer(), aSkinSelect, "setskin", id )
				else
					aMessageBox ( "warning", "No player selected/Invalid ID!" )
				end
			end
		elseif ( source == aSkinList ) then
			if ( guiGridListGetSelectedItem ( aSkinList ) ~= -1 ) then
				local id = guiGridListGetItemText ( aSkinList, guiGridListGetSelectedItem ( aSkinList ), 1 )
				guiSetText ( aSkinID, id )
			end
		elseif ( source == aSkinCancel ) then
			aPlayerSkinClose ( false )
		elseif ( source == aSkinGroups ) then
			if ( guiCheckBoxGetSelected ( aSkinGroups ) ) then aListSkins ( 2 )
			else aListSkins ( 1 ) end
		end
	end
end

function aLoadSkins ()
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
		xmlUnloadFile ( node )
	end
	return table
end

function aListSkins ( mode )
	aSetSetting ( "skinsGroup", iif ( mode == 1, false, true ) )
	guiGridListClear ( aSkinList )
	if ( mode == 1 ) then --Normal
		local skins = {}
		for name, group in pairs ( aSkins ) do
			if (name ~= "Special" or name == "Special" and getVersion().number >= 272) then
				for id, skin in pairs ( group ) do
					local id = tonumber ( skin["model"] )
					skins[id] = skin["name"]
				end
			end
		end
		local i = 0
		while ( i <= 312 ) do
			if ( skins[i] ~= nil ) then
				local row = guiGridListAddRow ( aSkinList )
				guiGridListSetItemText ( aSkinList, row, 1, tostring ( i ), false, true )
				guiGridListSetItemText ( aSkinList, row, 2, skins[i], false, false )
			end
			i = i + 1
		end
		guiGridListSetSortingEnabled ( aSkinList, true )
	else	--Groups
		for name, group in pairs ( aSkins ) do
			if (name ~= "Special" or name == "Special" and getVersion().number >= 272) then
				local row = guiGridListAddRow ( aSkinList )
				guiGridListSetItemText ( aSkinList, row, 2, name, true, false )
				for id, skin in ipairs ( aSkins[name] ) do
					row = guiGridListAddRow ( aSkinList )
					guiGridListSetItemText ( aSkinList, row, 1, skin["model"], false, true )
					guiGridListSetItemText ( aSkinList, row, 2, skin["name"], false, false )
				end
			end
		end
		guiGridListSetSortingEnabled ( aSkinList, false )
	end
end