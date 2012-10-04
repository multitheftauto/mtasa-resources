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

function aReport ( player )
	if ( aReportForm == nil ) then
		local x, y = guiGetScreenSize()
		aReportForm		= guiCreateWindow ( x / 2 - 150, y / 2 - 150, 300, 300, "Contact Admin", false )
					   guiCreateLabel ( 0.05, 0.11, 0.20, 0.09, "Category:", true, aReportForm )
					   guiCreateLabel ( 0.05, 0.21, 0.20, 0.09, "Subject:", true, aReportForm )
					   guiCreateLabel ( 0.05, 0.30, 0.20, 0.07, "Message:", true, aReportForm )
		aReportCategory	= guiCreateEdit ( 0.30, 0.10, 0.65, 0.09, "Question", true, aReportForm )
					   guiEditSetReadOnly ( aReportCategory, true )
		aReportDropDown	= guiCreateStaticImage ( 0.86, 0.10, 0.09, 0.09, "client\\images\\dropdown.png", true, aReportForm )
					   guiBringToFront ( aReportDropDown )
		aReportCategories	= guiCreateGridList ( 0.30, 0.10, 0.65, 0.30, true, aReportForm )
					   guiGridListAddColumn( aReportCategories, "", 0.85 )
					   guiSetVisible ( aReportCategories, false )
					   guiGridListSetItemText ( aReportCategories, guiGridListAddRow ( aReportCategories ), 1, "Question", false, false )
					   guiGridListSetItemText ( aReportCategories, guiGridListAddRow ( aReportCategories ), 1, "Suggestion", false, false )
					   guiGridListSetItemText ( aReportCategories, guiGridListAddRow ( aReportCategories ), 1, "Cheater/Moder", false, false )
					   guiGridListSetItemText ( aReportCategories, guiGridListAddRow ( aReportCategories ), 1, "Other", false, false )
		aReportSubject		= guiCreateEdit ( 0.30, 0.20, 0.65, 0.09, "", true, aReportForm )
		aReportMessage	= guiCreateMemo ( 0.05, 0.38, 0.90, 0.45, "", true, aReportForm )
		aReportAccept		= guiCreateButton ( 0.40, 0.88, 0.25, 0.09, "Send", true, aReportForm )
		aReportCancel		= guiCreateButton ( 0.70, 0.88, 0.25, 0.09, "Cancel", true, aReportForm )

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

function aClientReportDoubleClick ( button )
	if ( button == "left" ) then
		if ( source == aReportCategories ) then
			if ( guiGridListGetSelectedItem ( aReportCategories ) ~= -1 ) then
				local cat = guiGridListGetItemText ( aReportCategories, guiGridListGetSelectedItem ( aReportCategories ), 1 )
				guiSetText ( aReportCategory, cat )
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
				aMessageBox ( "info", "Your message has been submited and will be processed as soon as possible." )
				setTimer ( aMessageBoxClose, 3000, 1, true )
				local tableOut = {}
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
		end
	end
end