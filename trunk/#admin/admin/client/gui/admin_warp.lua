--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_warp.lua
*
*	Original File by lil_Toady
*
**************************************]]

aWarpForm = nil

function aPlayerWarp ( player )
	if ( aWarpForm == nil ) then
		local x, y = guiGetScreenSize()
		aWarpForm		= guiCreateWindow ( x / 2 - 110, y / 2 - 150, 200, 300, "Player Warp Management", false )
		aWarpList		= guiCreateGridList ( 0.03, 0.08, 0.94, 0.73, true, aWarpForm )
					   guiGridListAddColumn( aWarpList, "Player", 0.9 )
		aWarpSelect		= guiCreateButton ( 0.03, 0.82, 0.94, 0.075, "Select", true, aWarpForm )
		aWarpCancel		= guiCreateButton ( 0.03, 0.90, 0.94, 0.075, "Cancel", true, aWarpForm )

		addEventHandler ( "onClientGUIDoubleClick", aWarpForm, aClientWarpDoubleClick )
		addEventHandler ( "onClientGUIClick", aWarpForm, aClientWarpClick )
		--Register With Admin Form
		aRegister ( "PlayerWarp", aWarpForm, aPlayerWarp, aPlayerWarpClose )
	end
	aWarpSelectPointer = player
	guiGridListClear ( aWarpList )
	for id, player in ipairs ( getElementsByType ( "player" ) ) do
		guiGridListSetItemPlayerName ( aWarpList, guiGridListAddRow ( aWarpList ), 1, getPlayerName ( player ), false, false )
	end
	guiSetVisible ( aWarpForm, true )
	guiBringToFront ( aWarpForm )
end

function aPlayerWarpClose ( destroy )
	if ( ( destroy ) or ( aPerformanceWarp and guiCheckBoxGetSelected ( aPerformanceWarp ) ) ) then
		if ( aWarpForm ) then
			removeEventHandler ( "onClientGUIDoubleClick", aWarpForm, aClientWarpDoubleClick )
			removeEventHandler ( "onClientGUIClick", aWarpForm, aClientWarpClick )
			destroyElement ( aWarpForm )
			aWarpForm = nil
		end
	else
		guiSetVisible ( aWarpForm, false )
	end
end

function aClientWarpDoubleClick ( button )
	if ( button == "left" ) then
		if ( source == aWarpList ) then
			if ( guiGridListGetSelectedItem ( aWarpList ) ~= -1 ) then
				triggerServerEvent ( "aPlayer", getLocalPlayer(), aWarpSelectPointer, "warpto", getPlayerFromNick ( guiGridListGetItemPlayerName ( aWarpList, guiGridListGetSelectedItem ( aWarpList ), 1 ) ) )
				aPlayerWarpClose ( false )
			end
		end
	end
end

function aClientWarpClick ( button )
	if ( button == "left" ) then
		if ( source == aWarpSelect ) then
			if ( guiGridListGetSelectedItem ( aWarpList ) ~= -1 ) then
				triggerServerEvent ( "aPlayer", getLocalPlayer(), aWarpSelectPointer, "warpto", getPlayerFromNick ( guiGridListGetItemPlayerName ( aWarpList, guiGridListGetSelectedItem ( aWarpList ), 1 ) ) )
				aPlayerWarpClose ( false )
			end
		elseif ( source == aWarpCancel ) then
			aPlayerWarpClose ( false )
		end
	end
end