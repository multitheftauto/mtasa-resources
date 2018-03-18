--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_report.lua
*
*	Original File by lil_Toady
*
**************************************]]

aReportForm = nil
local reportCategories
local aSelectPlayer = nil

function aReport ( )
	if ( aReportForm == nil ) then
		reportCategories = {}
		for i,cat in ipairs( split( g_Prefs.reportCategories, string.byte(',') ) ) do
			table.insert ( reportCategories, { subject = cat } )
		end
		for i,cat in ipairs( split( g_Prefs.playerReportCategories, string.byte(',') ) ) do
			table.insert ( reportCategories, { subject = cat, playerReport = true } )
		end

		local x, y = guiGetScreenSize()
		aReportForm		= guiCreateWindow ( x / 2 - 150, y / 2 - 170, 300, 340, "Contact Admin", false )
					   guiCreateLabel ( 0.05, 0.11, 0.20, 0.07, "Category:", true, aReportForm )
					   guiCreateLabel ( 0.05, 0.19, 0.20, 0.07, "Subject:", true, aReportForm )
					   guiCreateLabel ( 0.05, 0.34, 0.20, 0.07, "Message:", true, aReportForm )
		aReportLblPlayer = guiCreateLabel ( 0.05, 0.27, 0.20, 0.07, "Player:", true, aReportForm )
		aReportBtnPlayer = guiCreateButton ( 0.75, 0.27, 0.20, 0.07, "Select", true, aReportForm )
		aReportCategory	= guiCreateEdit ( 0.30, 0.10, 0.65, 0.07, "Question", true, aReportForm )
					   guiEditSetReadOnly ( aReportCategory, true )
		aReportDropDown	= guiCreateStaticImage ( 0.86, 0.10, 0.09, 0.07, "client\\images\\dropdown.png", true, aReportForm )
					   guiBringToFront ( aReportDropDown )
		aReportCategories	= guiCreateGridList ( 0.30, 0.10, 0.65, 0.28, true, aReportForm )
					   guiGridListAddColumn( aReportCategories, "", 0.85 )
					   guiSetVisible ( aReportCategories, false )
						for a=1, #reportCategories do
							guiGridListSetItemText ( aReportCategories, guiGridListAddRow ( aReportCategories ), 1, reportCategories[a].subject, false, false )
						end
						guiSetText( aReportCategory, reportCategories[1].subject )
		aReportSubject	= guiCreateEdit ( 0.30, 0.18, 0.65, 0.07, "", true, aReportForm )
		aReportPlayer	= guiCreateLabel ( 0.30, 0.27, 0.50, 0.07, "", true, aReportForm )
		aReportMessage	= guiCreateMemo ( 0.05, 0.41, 0.90, 0.42, "", true, aReportForm )
		aReportAccept	= guiCreateButton ( 0.40, 0.88, 0.25, 0.09, "Send", true, aReportForm )
		aReportCancel	= guiCreateButton ( 0.70, 0.88, 0.25, 0.09, "Cancel", true, aReportForm )

		if ( not reportCategories[1].playerReport ) then
			guiSetVisible ( aReportPlayer, false )
			guiSetVisible ( aReportLblPlayer, false )
			guiSetVisible ( aReportBtnPlayer, false )
		end

		addEventHandler ( "onClientGUIClick", aReportForm, aClientReportClick )
		addEventHandler ( "onClientGUIDoubleClick", aReportForm, aClientReportDoubleClick )
	end
	guiBringToFront ( aReportForm )
	showCursor ( true )
end
addCommandHandler ( "report", aReport )


function aReportClose ( )
	if ( aReportForm ) then
		removeEventHandler ( "onClientGUIClick", aReportForm, aClientReportClick )
		removeEventHandler ( "onClientGUIDoubleClick", aReportForm, aClientReportDoubleClick )
		destroyElement ( aReportForm )
		aReportForm = nil
		showCursor ( false )
	end
end

function aReportSelectPlayer ( )
	if ( aSelectPlayer == nil ) then
		local x, y = guiGetScreenSize ( )
		aSelectPlayer = guiCreateWindow ( x / 2 - 155, y / 2 - 250, 310, 500, "Select player", false)
		local playerList = guiCreateGridList(0.03, 0.06, 0.97, 0.78, true, aSelectPlayer)
		local searchBox = guiCreateEdit(0.115, 0.86, 0.77, 0.06, "", true, aSelectPlayer)
		addEventHandler ( "onClientGUIChanged", searchBox, function ( )
			guiGridListClear ( playerList )
			local text = guiGetText ( source )
			for _, player in pairs ( getElementsByType ( "player" ) ) do
				local playerName = getPlayerName ( player )
				if ( string.find ( string.upper ( playerName ), string.upper ( text ), 1, true ) ) then
					guiGridListSetItemText ( playerList, guiGridListAddRow ( playerList ), 1, playerName, false, false )
				end
			end
		end )
		guiGridListAddColumn ( playerList, "Player name", 0.85 )
		for _, player in pairs (getElementsByType("player")) do
			guiGridListSetItemText(playerList, guiGridListAddRow(playerList), 1, getPlayerName(player), false, false)
		end
		local btnSelectPlayer = guiCreateButton(0.57, 0.93, 0.33, 0.05, "Select", true, aSelectPlayer)
		addEventHandler ( "onClientGUIClick", btnSelectPlayer, function ( )
			guiSetText ( aReportPlayer, guiGridListGetItemText ( playerList, guiGridListGetSelectedItem ( playerList ), 1 ) )
			destroyElement ( aSelectPlayer )
			aSelectPlayer = nil
		end, false )
		local btnClose = guiCreateButton(0.10, 0.93, 0.33, 0.05, "Close", true, aSelectPlayer)
		addEventHandler ( "onClientGUIClick", btnClose, function ( )
			destroyElement ( aSelectPlayer )
			aSelectPlayer = nil
		end, false )
	end
end

function aClientReportDoubleClick ( button )
	if ( button == "left" ) then
		if ( source == aReportCategories ) then
			if ( guiGridListGetSelectedItem ( aReportCategories ) ~= -1 ) then
				local cat = guiGridListGetItemText ( aReportCategories, guiGridListGetSelectedItem ( aReportCategories ), 1 )
				guiSetText ( aReportCategory, cat )
				for i=1, #reportCategories do
					if ( reportCategories[i].subject == cat ) then
						if ( reportCategories[i].playerReport ) then
							guiSetVisible ( aReportPlayer, true )
							guiSetVisible ( aReportLblPlayer, true )
							guiSetVisible ( aReportBtnPlayer, true )
						else
							guiSetVisible ( aReportPlayer, false )
							guiSetVisible ( aReportLblPlayer, false )
							guiSetVisible ( aReportBtnPlayer, false )
						end
					end
				end
				guiSetVisible ( aReportCategories, false )
			end
		end
	end
end

function aClientReportClick ( button )
	if ( source == aReportCategory ) then
		guiBringToFront ( aReportDropDown )
	end
	if ( source ~= aReportCategories ) then
		guiSetVisible ( aReportCategories, false )
	end
	if ( button == "left" ) then
		if ( source == aReportAccept ) then
			if ( ( string.len ( guiGetText ( aReportSubject ) ) < 1 ) or ( string.len ( guiGetText ( aReportMessage ) ) < 5 ) ) then
				aMessageBox ( "error", "Subject/Message missing." )
			else
				local tableOut = {}
				if ( guiGetVisible ( aReportPlayer ) ) then
					local text = guiGetText ( aReportPlayer )
					if ( text ~= "" ) then
						tableOut.suspect = text
					end
				end
				aMessageBox ( "info", "Your message has been submitted and will be processed as soon as possible." )
				setTimer ( aMessageBoxClose, 3000, 1, true )
				tableOut.category = guiGetText ( aReportCategory )
				tableOut.subject = guiGetText ( aReportSubject )
				tableOut.message = guiGetText ( aReportMessage )
				triggerServerEvent ( "aMessage", getLocalPlayer(), "new", tableOut )
				aReportClose ()
			end
		elseif ( source == aReportSubject ) then

		elseif ( source == aReportMessage ) then

		elseif ( source == aReportCancel ) then
			aReportClose ()
		elseif ( source == aReportDropDown ) then
			guiBringToFront ( aReportCategories )
			guiSetVisible ( aReportCategories, true )
		elseif ( source == aReportBtnPlayer ) then
			aReportSelectPlayer ( )
		end
	end
end
