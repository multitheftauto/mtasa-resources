--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_interior.lua
*
*	Original File by lil_Toady
*
**************************************]]

aInteriorForm = nil

function aPlayerInterior ( player )
	if ( aInteriorForm == nil ) then
		local x, y = guiGetScreenSize()
		aInteriorForm		= guiCreateWindow ( x / 2 - 110, y / 2 - 150, 220, 300, "Player Interior Management", false )
		aInteriorList		= guiCreateGridList ( 0.03, 0.08, 0.94, 0.73, true, aInteriorForm )
					   guiGridListAddColumn( aInteriorList, "World", 0.2 )
					   guiGridListAddColumn( aInteriorList, "Description", 0.75 )
		aInteriorSelect		= guiCreateButton ( 0.03, 0.82, 0.94, 0.075, "Select", true, aInteriorForm )
		aInteriorCancel		= guiCreateButton ( 0.03, 0.90, 0.94, 0.075, "Cancel", true, aInteriorForm )

		local node = xmlLoadFile ( "conf\\interiors.xml" )
		if ( node ) then
			local interiors = 0
			while ( xmlFindChild ( node, "interior", interiors ) ~= false ) do
				local interior = xmlFindChild ( node, "interior", interiors )
				local row = guiGridListAddRow ( aInteriorList )
				guiGridListSetItemText ( aInteriorList, row, 1, xmlNodeGetAttribute ( interior, "world" ), false, true )
				guiGridListSetItemText ( aInteriorList, row, 2, xmlNodeGetAttribute ( interior, "id" ), false, false )
				interiors = interiors + 1
			end
			xmlUnloadFile ( node )
		end
		addEventHandler ( "onClientGUIDoubleClick", aInteriorForm, aClientInteriorDoubleClick )
		addEventHandler ( "onClientGUIClick", aInteriorForm, aClientInteriorClick )
		--Register With Admin Form
		aRegister ( "PlayerInterior", aInteriorForm, aPlayerInterior, aPlayerInteriorClose )
	end
	aInteriorSelectPointer = player
	guiSetVisible ( aInteriorForm, true )
	guiBringToFront ( aInteriorForm )
end

function aPlayerInteriorClose ( destroy )
	if ( ( destroy ) or ( aPerformanceInterior and guiCheckBoxGetSelected ( aPerformanceInterior ) ) ) then
		if ( aInteriorForm ) then
			removeEventHandler ( "onClientGUIDoubleClick", aInteriorForm, aClientInteriorDoubleClick )
			removeEventHandler ( "onClientGUIClick", aInteriorForm, aClientInteriorClick )
			destroyElement ( aInteriorForm )
			aInteriorForm = nil
		end
	else
		guiSetVisible ( aInteriorForm, false )
	end
end

function aClientInteriorDoubleClick ( button )
	if ( button == "left" ) then
		if ( source == aInteriorList ) then
			if ( guiGridListGetSelectedItem ( aInteriorList ) ~= -1 ) then
				triggerServerEvent ( "aPlayer", getLocalPlayer(), aInteriorSelectPointer, "setinterior", guiGridListGetItemText ( aInteriorList, guiGridListGetSelectedItem ( aInteriorList ), 2 ) )
				aPlayerInteriorClose ( false )
			end
		end
	end
end

function aClientInteriorClick ( button )
	if ( button == "left" ) then
		if ( source == aInteriorSelect ) then
			if ( guiGridListGetSelectedItem ( aInteriorList ) ~= -1 ) then
				triggerServerEvent ( "aPlayer", getLocalPlayer(), aInteriorSelectPointer, "setinterior", guiGridListGetItemText ( aInteriorList, guiGridListGetSelectedItem ( aInteriorList ), 2 ) )
				guiSetVisible ( aInteriorForm, false )
			end
		elseif ( source == aInteriorCancel ) then
			aPlayerInteriorClose ( false )
		end
	end
end