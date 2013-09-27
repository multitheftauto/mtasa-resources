--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_moddetails.lua
*
**************************************]]

aModdetailsForm = nil
local modDetailsPlayer = nil

function aViewModdetails ( player )
	modDetailsPlayer = player
	if ( aModdetailsForm == nil ) then
		local x, y = guiGetScreenSize()
		aModdetailsForm	= guiCreateWindow ( x / 2 - 250, y / 2 - 125, 350, 350, "View Moddetails", false )
		guiWindowSetSizable( aModdetailsForm, false )
		aModdetailsList		= guiCreateGridList ( 0.02, 0.09, 0.72, 0.85, true, aModdetailsForm )
					   guiGridListAddColumn( aModdetailsList, "Id", 0.25 )
					   guiGridListAddColumn( aModdetailsList, "Name", 0.60 )
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
end

function aModdetailsSync ( action, list, player )
	if player ~= modDetailsPlayer then
		return
	end
	if ( action == "get" ) then
		guiGridListClear ( aModdetailsList )
		destroyElement ( aModdetailsList )
		aModdetailsList	= guiCreateGridList ( 0.02, 0.09, 0.72, 0.85, true, aModdetailsForm )
					   guiGridListAddColumn( aModdetailsList, "Id", 0.25 )
					   guiGridListAddColumn( aModdetailsList, "Name", 0.60 )
		for id,mod in ipairs( list ) do
			local row = guiGridListAddRow ( aModdetailsList )
			guiGridListSetItemText ( aModdetailsList, row, 1, tostring(mod.id), false, false )
			guiGridListSetItemText ( aModdetailsList, row, 2, tostring(mod.name), false, false )
		end
	end
end

function aClientModdetailsClick ( button )
	if ( button == "left" ) then
		if ( source == aModdetailsClose ) then
			aViewModdetailsClose ( false )
		elseif ( source == aModdetailsRefresh ) then
			triggerServerEvent ( "aModdetails", resourceRoot, "get", modDetailsPlayer )
		end
	end
end
