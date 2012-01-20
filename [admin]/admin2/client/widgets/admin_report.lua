--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_report.lua
*
*	Original File by lil_Toady
*
**************************************]]

aReport = {
	Form = nil
}

function aReport.Open ()
	if ( not aReport.Form ) then
		local x, y = guiGetScreenSize()
		aReport.Form		= guiCreateWindow ( x / 2 - 150, y / 2 - 150, 300, 300, "Contact Admin", false )
					   	  guiCreateLabel ( 0.05, 0.11, 0.20, 0.09, "Category:", true, aReport.Form )
					   	  guiCreateLabel ( 0.05, 0.21, 0.20, 0.09, "Subject:", true, aReport.Form )
					   	  guiCreateLabel ( 0.05, 0.30, 0.20, 0.07, "Message:", true, aReport.Form )
		aReport.Category		= guiCreateComboBox ( 0.30, 0.10, 0.65, 0.09, "Question", true, aReport.Form )
					   	  guiEditSetReadOnly ( aReport.Category, true )
					   	  guiComboBoxAddItem ( aReport.Categories "Question" )
					   	  guiComboBoxAddItem ( aReport.Categories "Suggestion" )
					   	  guiComboBoxAddItem ( aReport.Categories "Abuse" )
					   	  guiComboBoxAddItem ( aReport.Categories "Player" )
					   	  guiComboBoxAddItem ( aReport.Categories "Other" )
		aReport.Subject		= guiCreateEdit ( 0.30, 0.20, 0.65, 0.09, "", true, aReport.Form )
						  guiHandleInput ( aReport.Subject )
		aReport.Message		= guiCreateMemo ( 0.05, 0.38, 0.90, 0.45, "", true, aReport.Form )
						  guiHandleInput ( aReport.Message )
		aReport.Accept		= guiCreateButton ( 0.40, 0.88, 0.25, 0.09, "Send", true, aReport.Form )
		aReport.Cancel		= guiCreateButton ( 0.70, 0.88, 0.25, 0.09, "Cancel", true, aReport.Form )

		addEventHandler ( "onClientGUIClick", aReportForm, aClientReportClick )
	end
	guiBringToFront ( aReport.Form )
	showCursor ( true )
end
addCommandHandler ( "report", aReport.Open )

function aReportClose ( )
	guiSetInputEnabled ( false )
	if ( aReportForm ) then
		removeEventHandler ( "onClientGUIClick", aReportForm, aClientReportClick )
		destroyElement ( aReportForm )
		aReportForm = nil
		showCursor ( false )
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
				messageBox ( "Subject/Message missing.", MB_ERROR )
			else
				local tableOut = {}
				tableOut.category = guiGetText ( aReportCategory )
				tableOut.subject = guiGetText ( aReportSubject )
				tableOut.message = guiGetText ( aReportMessage )
				triggerServerEvent ( "aMessage", getLocalPlayer(), "new", tableOut )
				aReportClose ()
				messageBox ( "Your message has been submited and will be processed as soon as possible.", MB_INFO )
				setTimer ( aMessageBox.Close, 3000, 1, true )
			end
		elseif ( source == aReportSubject ) then
			guiSetInputEnabled ( true )
		elseif ( source == aReportMessage ) then
			guiSetInputEnabled ( true )
		elseif ( source == aReportCancel ) then
			aReportClose ()
		elseif ( source == aReportDropDown ) then
			guiBringToFront ( aReportCategories )
			guiSetVisible ( aReportCategories, true )
		end
	end
end