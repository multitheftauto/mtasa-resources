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
local aSuspectInfo = nil
local viewID

function aViewMessage ( id )
	if ( aSuspectInfo and viewID and viewID ~= id ) then
		destroyElement(aSuspectInfo)
		aSuspectInfo = nil
	end
	viewID = id
	if ( aViewMessageForm == nil ) then
		local x, y = guiGetScreenSize()
		aViewMessageForm	= guiCreateWindow ( x / 2 - 150, y / 2 - 129, 300, 258, "", false )
					   guiCreateLabel ( 0.05, 0.10, 0.30, 0.09, "Category:", true, aViewMessageForm )
					   guiCreateLabel ( 0.05, 0.18, 0.30, 0.09, "Time:", true, aViewMessageForm )
					   guiCreateLabel ( 0.05, 0.26, 0.30, 0.09, "By:", true, aViewMessageForm )
		aViewMessageLabelSuspect = guiCreateLabel ( 0.05, 0.34, 0.30, 0.09, "Suspect:", true, aViewMessageForm )
		aViewMessageSuspect	= guiCreateButton ( 0.40, 0.34, 0.55, 0.07, "View info", true, aViewMessageForm )
		aViewMessageCategory	= guiCreateLabel ( 0.40, 0.10, 0.55, 0.09, "", true, aViewMessageForm )
		aViewMessageTime	= guiCreateLabel ( 0.40, 0.18, 0.55, 0.09, "", true, aViewMessageForm )
		aViewMessageAuthor	= guiCreateLabel ( 0.40, 0.26, 0.55, 0.09, "", true, aViewMessageForm )
		aViewMessageText	= guiCreateMemo ( 0.05, 0.42, 0.90, 0.44, "", true, aViewMessageForm )
					   guiMemoSetReadOnly ( aViewMessageText, true )
		aViewMessageCloseB	= guiCreateButton ( 0.77, 0.86, 0.20, 0.09, "Close", true, aViewMessageForm )

		addEventHandler ( "onClientGUIClick", aViewMessageForm, aClientMessageClick )
		addEventHandler ( "onClientGUIClick", aViewMessageSuspect, aViewSuspectInfo )

		--Register With Admin Form
		aRegister ( "Message", aViewMessageForm, aViewMessage, aViewMessageClose )
	end
	if ( _messages[id] ) then
		guiSetText ( aViewMessageCategory, _messages[id].category )
		guiSetText ( aViewMessageForm, _messages[id].subject )
		guiSetText ( aViewMessageTime, _messages[id].time )
		guiSetText ( aViewMessageAuthor, _messages[id].author )
		guiSetText ( aViewMessageText, _messages[id].text )
		guiSetVisible ( aViewMessageForm, true )
		local isVisible = _messages[id].suspect ~= nil
		guiSetVisible ( aViewMessageLabelSuspect, isVisible )
		guiSetVisible ( aViewMessageSuspect, isVisible )
		guiBringToFront ( aViewMessageForm )
		triggerServerEvent ( "aMessage", getLocalPlayer(), "read", id )
	end
end

function aViewSuspectInfo ( button )
	if ( button == "left" ) then
		if ( source == aViewMessageSuspect ) then
			if ( aSuspectInfo == nil ) then
				local suspectInfo = _messages[viewID].suspect
				if ( suspectInfo ) then
					local x, y = guiGetScreenSize()
					aSuspectInfo = guiCreateWindow(x / 2 - 145, y / 2 - 192.5, 290, 385, "Player information", false)
					local btnClose = guiCreateButton(0.365, 0.88, 0.27, 0.10, "Close", true, aSuspectInfo)
					addEventHandler("onClientGUIClick", btnClose, function()
						destroyElement(aSuspectInfo)
						aSuspectInfo = nil
					end, false)

					local infoMemo = guiCreateMemo(0.04, 0.1, 0.96, 0.75, "Nickname: "..suspectInfo.name.."\nAccount name: "..suspectInfo.username.."\nIP: "
						..suspectInfo.ip.."\nSerial: "..suspectInfo.serial.."\nMTA version: "..suspectInfo.version.."\n\nChat log:\n"..suspectInfo.chatLog,
					true, aSuspectInfo)
					guiMemoSetReadOnly(infoMemo, true)
				else
					aMessageBox ( "error", "This report does have any suspect information." )
				end
			end
		end
	end
end

function aViewMessageClose ( destroy )
	if ( ( destroy ) or ( guiCheckBoxGetSelected ( aPerformanceMessage ) ) ) then
		if ( aViewMessageForm ) then
			removeEventHandler ( "onClientGUIClick", aViewMessageForm, aClientMessageClick )
			if ( aViewMessageSuspect ) then
				removeEventHandler ( "onClientGUIClick", aViewMessageSuspect, aViewSuspectInfo )
			end
			destroyElement ( aViewMessageForm )
			aViewMessageForm = nil
			destroyElement(aSuspectInfo)
			aSuspectInfo = nil
		end
	else
		if aViewMessageForm then guiSetVisible ( aViewMessageForm, false ) end
		if aSuspectInfo then
			destroyElement ( aSuspectInfo )
			aSuspectInfo = nil
		end
	end
end

function aClientMessageClick ( button )
	if ( button == "left" ) then
		if ( source == aViewMessageCloseB ) then
			aViewMessageClose ( false )
		end
	end
end
