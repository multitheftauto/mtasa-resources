--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_moddetails.lua
*
**************************************]]

aModdetailsForm = nil
local modDetailsPlayer = nil
local currentModDetails

function aViewModdetails ( player )
	modDetailsPlayer = player
	if ( aModdetailsForm == nil ) then
		local x, y = guiGetScreenSize()
		aModdetailsForm	= guiCreateWindow ( x / 2 - 250, y / 2 - 125, 500, 350, "View Mod Details", false )
		guiWindowSetSizable( aModdetailsForm, false )
		aModdetailsList		= guiCreateGridList ( 0.02, 0.09, 0.72, 0.85, true, aModdetailsForm )
					   guiGridListAddColumn( aModdetailsList, "Filename", 0.3 )
					   guiGridListAddColumn( aModdetailsList, "Modification", 0.60 )
		aModdetailsCopy		= guiCreateButton ( 0.76, 0.71, 0.32, 0.05, "Copy", true, aModdetailsForm )
		aModdetailsRefresh	= guiCreateButton ( 0.76, 0.78, 0.32, 0.05, "Refresh", true, aModdetailsForm )
		aModdetailsClose	= guiCreateButton ( 0.76, 0.85, 0.32, 0.05, "Close", true, aModdetailsForm )
		addEventHandler ( "aModdetails", resourceRoot, aModdetailsSync )
		addEventHandler ( "onClientGUIClick", aModdetailsForm, aClientModdetailsClick )
		--Register With Admin Form
		aRegister ( "Moddetails", aModdetailsForm, aViewModdetails, aViewModdetailsClose )
	end
	guiSetText( aModdetailsForm, "Mod details for: '" .. tostring(getPlayerName(modDetailsPlayer)) .."'" )
	aHideFloaters()
	guiSetVisible ( aModdetailsForm, true )
	guiBringToFront ( aModdetailsForm )
	triggerServerEvent ( "aModdetails", resourceRoot, "get", modDetailsPlayer )
end

function aViewModdetailsClose ( destroy )
	if ( ( destroy ) or ( guiCheckBoxGetSelected ( aPerformanceMessage ) ) ) then
		if ( aModdetailsForm ) then
			removeEventHandler ( "aModdetails", resourceRoot, aModdetailsSync )
			removeEventHandler ( "onClientGUIClick", aModdetailsForm, aClientModdetailsClick )
			destroyElement ( aModdetailsForm )
			aModdetailsForm = nil
		end
	else
		guiSetVisible ( aModdetailsForm, false )
	end
	currentModDetails = nil
end

function aModdetailsSync ( action, list, player )
	if player ~= modDetailsPlayer then
		return
	end
	if ( action == "get" ) then
		currentModDetails = list
		if not aModdetailsList then
			aModdetailsList	= guiCreateGridList ( 0.02, 0.09, 0.72, 0.85, true, aModdetailsForm )
			guiGridListAddColumn( aModdetailsList, "Filename", 0.3 )
			guiGridListAddColumn( aModdetailsList, "Modification", 0.60 )
		else
			guiGridListClear ( aModdetailsList )
		end
		for filename, mods in pairs( list ) do
			for _, mod in ipairs(mods) do
				local row = guiGridListAddRow ( aModdetailsList )
				guiGridListSetItemText ( aModdetailsList, row, 1, tostring(filename), false, false )
				guiGridListSetItemText ( aModdetailsList, row, 2, tostring(mod.name), false, false )
			end
		end
	end
end

function aClientModdetailsClick ( button )
	if ( button == "left" ) then
		if ( source == aModdetailsClose ) then
			aViewModdetailsClose ( false )
		elseif ( source == aModdetailsRefresh ) then
			triggerServerEvent ( "aModdetails", resourceRoot, "get", modDetailsPlayer )
		elseif ( source == aModdetailsCopy ) then
			setClipboard ( toJSON ( currentModDetails ) )
			outputChatBox("* Player mod details copied to clipboard.", 255, 100, 70)
		end
	end
end
