--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_message.lua
*
*	Original File by lil_Toady
*
**************************************]]

aViewMessageForm = nil

function aViewMessage ( id )
	if ( aViewMessageForm == nil ) then
		local x, y = guiGetScreenSize()
		aViewMessageForm	= guiCreateWindow ( x / 2 - 150, y / 2 - 125, 300, 250, "", false )
					   guiCreateLabel ( 0.05, 0.10, 0.30, 0.09, "Category:", true, aViewMessageForm )
					   guiCreateLabel ( 0.05, 0.18, 0.30, 0.09, "Subject:", true, aViewMessageForm )
					   guiCreateLabel ( 0.05, 0.26, 0.30, 0.09, "Time:", true, aViewMessageForm )
					   guiCreateLabel ( 0.05, 0.34, 0.30, 0.09, "By:", true, aViewMessageForm )
		aViewMessageCategory	= guiCreateLabel ( 0.40, 0.10, 0.55, 0.09, "", true, aViewMessageForm )
		aViewMessageSubject	= guiCreateLabel ( 0.40, 0.18, 0.55, 0.09, "", true, aViewMessageForm )
		aViewMessageTime	= guiCreateLabel ( 0.40, 0.26, 0.55, 0.09, "", true, aViewMessageForm )
		aViewMessageAuthor	= guiCreateLabel ( 0.40, 0.34, 0.55, 0.09, "", true, aViewMessageForm )
		aViewMessageText	= guiCreateMemo ( 0.05, 0.41, 0.90, 0.45, "", true, aViewMessageForm )
					   guiMemoSetReadOnly ( aViewMessageText, true )
		aViewMessageCloseB	= guiCreateButton ( 0.77, 0.88, 0.20, 0.09, "Close", true, aViewMessageForm )

		addEventHandler ( "onClientGUIClick", aViewMessageForm, aClientMessageClick )
		--Register With Admin Form
		aRegister ( "Message", aViewMessageForm, aViewMessage, aViewMessageClose )
	end
	if ( _messages[id] ) then
		guiSetText ( aViewMessageCategory, _messages[id].category )
		guiSetText ( aViewMessageSubject, _messages[id].subject )
		guiSetText ( aViewMessageTime, _messages[id].time )
		guiSetText ( aViewMessageAuthor, _messages[id].author )
		guiSetText ( aViewMessageText, _messages[id].text )
		guiSetVisible ( aViewMessageForm, true )
		guiBringToFront ( aViewMessageForm )
		triggerServerEvent ( "aMessage", getLocalPlayer(), "read", id )
	end
end

function aViewMessageClose ( destroy )
	if ( ( destroy ) or ( guiCheckBoxGetSelected ( aPerformanceMessage ) ) ) then
		if ( aViewMessageForm ) then
			removeEventHandler ( "onClientGUIClick", aViewMessageForm, aClientMessageClick )
			destroyElement ( aViewMessageForm )
			aViewMessageForm = nil
		end
	else
		if aViewMessageForm then guiSetVisible ( aViewMessageForm, false ) end
	end
end

function aClientMessageClick ( button )
	if ( button == "left" ) then
		if ( source == aViewMessageCloseB ) then
			aViewMessageClose ( false )
		end
	end
end