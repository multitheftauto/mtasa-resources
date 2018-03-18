--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_messages.lua
*
*	Original File by lil_Toady
*
**************************************]]

aMessagesForm = nil
_messages = nil

function aViewMessages ( player )
	if ( aMessagesForm == nil ) then
		local x, y = guiGetScreenSize()
		aMessagesForm	= guiCreateWindow ( x / 2 - 250, y / 2 - 125, 620, 250, "View Messages", false )

		aMessagesList		= guiCreateGridList ( 0.02, 0.09, 0.82, 0.85, true, aMessagesForm )
					   guiGridListAddColumn( aMessagesList, "#", 0.08 )
					   guiGridListAddColumn( aMessagesList, "Subject", 0.46 )
					   guiGridListAddColumn( aMessagesList, "Date", 0.23 )
					   guiGridListAddColumn( aMessagesList, "Author", 0.19 )
		aMessagesRead		= guiCreateButton ( 0.86, 0.15, 0.12, 0.09, "Read", true, aMessagesForm )
		aMessagesDelete		= guiCreateButton ( 0.86, 0.25, 0.12, 0.09, "Delete", true, aMessagesForm )
		aMessagesBanSerial	= guiCreateButton ( 0.86, 0.40, 0.12, 0.09, "Ban serial", true, aMessagesForm )
		aMessagesBanIP		= guiCreateButton ( 0.86, 0.50, 0.12, 0.09, "Ban IP", true, aMessagesForm )
		aMessagesRefresh	= guiCreateButton ( 0.86, 0.65, 0.12, 0.09, "Refresh", true, aMessagesForm )
		aMessagesClose		= guiCreateButton ( 0.86, 0.85, 0.12, 0.09, "Close", true, aMessagesForm )
		addEventHandler ( "aMessage", _root, aMessagesSync )
		addEventHandler ( "onClientGUIClick", aMessagesForm, aClientMessagesClick )
		addEventHandler ( "onClientGUIDoubleClick", aMessagesForm, aClientMessagesDoubleClick )
		guiSetEnabled( aMessagesBanSerial, false )
		guiSetEnabled( aMessagesBanIP, false )
		--Register With Admin Form
		aRegister ( "Messages", aMessagesForm, aViewMessages, aViewMessagesClose )
	end
	aHideFloaters()
	guiSetVisible ( aMessagesForm, true )
	guiBringToFront ( aMessagesForm )
	triggerServerEvent ( "aMessage", getLocalPlayer(), "get" )
end

function aViewMessagesClose ( destroy )
	if ( ( destroy ) or ( guiCheckBoxGetSelected ( aPerformanceMessage ) ) ) then
		if ( aMessagesForm ) then
			removeEventHandler ( "aMessage", _root, aMessagesSync )
			removeEventHandler ( "onClientGUIClick", aMessagesForm, aClientMessagesClick )
			removeEventHandler ( "onClientGUIDoubleClick", aMessagesForm, aClientMessagesDoubleClick )
			destroyElement ( aMessagesForm )
			aMessagesForm = nil
		end
	else
		guiSetVisible ( aMessagesForm, false )
	end
end

function aMessagesSync ( action, data )
	if ( action == "get" ) then
		_messages = data
		guiGridListClear ( aMessagesList )
		for id=#data,1,-1 do
			local message = data[id]
			local row = guiGridListAddRow ( aMessagesList )
			guiGridListSetItemText ( aMessagesList, row, 1, tostring ( id ), false, false )
			if ( message.read ) then guiGridListSetItemText ( aMessagesList, row, 2, message.subject, false, false )
			else guiGridListSetItemText ( aMessagesList, row, 2, "* "..message.subject, false, false ) end
			guiGridListSetItemText ( aMessagesList, row, 3, message.time, false, false )
			guiGridListSetItemText ( aMessagesList, row, 4, message.author, false, false )
		end
	end
end

function aClientMessagesDoubleClick ( button )
	if ( button == "left" ) then
		if ( source == aMessagesList ) then
			local row = guiGridListGetSelectedItem ( aMessagesList )
			if ( row ~= -1 ) then
				local id = guiGridListGetItemText ( aMessagesList, row, 1 )
				aViewMessage ( tonumber ( id ) )
			end
		end
	end
end

function aClientMessagesClick ( button )
	if ( button == "left" ) then
		if ( source == aMessagesClose ) then
			aViewMessagesClose ( false )
		elseif ( source == aMessagesRefresh ) then
			triggerServerEvent ( "aMessage", getLocalPlayer(), "get" )
		elseif ( source == aMessagesRead ) then
			local row = guiGridListGetSelectedItem ( aMessagesList )
			if ( row == -1 ) then aMessageBox ( "Warning", "No message selected!", nil )
			else
				local id = guiGridListGetItemText ( aMessagesList, row, 1 )
				aViewMessage ( tonumber ( id ) )
			end
		elseif ( source == aMessagesDelete ) then
			local row = guiGridListGetSelectedItem ( aMessagesList )
			if ( row == -1 ) then aMessageBox ( "Warning", "No message selected!" )
			else
				local id = guiGridListGetItemText ( aMessagesList, row, 1 )
				triggerServerEvent ( "aMessage", getLocalPlayer(), "delete", tonumber ( id ) )
			end
		elseif ( source == aMessagesBanSerial ) then
			local data = _messages[tonumber ( guiGridListGetItemText ( aMessagesList, guiGridListGetSelectedItem ( aMessagesList ), 1 ) )]
			aInputBox ( "Add Serial Ban", "Enter Serial to be banned", data.suspect.serial, "banSerial", _, _, data.suspect.name, data.category )
		elseif ( source == aMessagesBanIP ) then
			local data = _messages[tonumber ( guiGridListGetItemText ( aMessagesList, guiGridListGetSelectedItem ( aMessagesList ), 1 ) )]
			aInputBox ( "Add IP Ban", "Enter IP to be banned", data.suspect.ip, "banIP", _, _, data.suspect.name, data.category )
		elseif ( source == aMessagesList ) then
			local row = guiGridListGetSelectedItem ( aMessagesList )
			if ( row == -1 ) then
				guiSetEnabled( aMessagesBanSerial, false )
				guiSetEnabled( aMessagesBanIP, false )
			else
				local id = tonumber(guiGridListGetItemText ( aMessagesList, row, 1 ))
				local suspectInfo = _messages[id].suspect
				if ( suspectInfo ) then
					if ( hasPermissionTo ( "command.banserial" ) ) then
						guiSetEnabled( aMessagesBanSerial, true )
					end
					if ( hasPermissionTo ( "command.banip" ) ) then
						guiSetEnabled( aMessagesBanIP, true )
					end
				else
					guiSetEnabled( aMessagesBanSerial, false )
					guiSetEnabled( aMessagesBanIP, false )
				end
			end
		end
	end
end
