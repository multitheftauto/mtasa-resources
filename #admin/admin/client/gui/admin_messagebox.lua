--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_messagebox.lua
*
*	Original File by lil_Toady
*
**************************************]]

aMessageForm = nil

function aMessageBox ( type, message, action )
	local x, y = guiGetScreenSize()
	if ( aMessageForm == nil ) then
		aMessageForm	= guiCreateWindow ( x / 2 - 150, y / 2 - 64, 300, 110, "", false )
					  guiWindowSetSizable ( aMessageForm, false )
		aMessageWarning	= guiCreateStaticImage ( 10, 32, 60, 60, "client\\images\\warning.png", false, aMessageForm )
		aMessageQuestion	= guiCreateStaticImage ( 10, 32, 60, 60, "client\\images\\question.png", false, aMessageForm )
		aMessageError		= guiCreateStaticImage ( 10, 32, 60, 60, "client\\images\\error.png", false, aMessageForm )
		aMessageInfo		= guiCreateStaticImage ( 10, 32, 60, 60, "client\\images\\info.png", false, aMessageForm )
		aMessageLabel		= guiCreateLabel ( 100, 32, 180, 16, "", false, aMessageForm )
					  guiLabelSetHorizontalAlign ( aMessageLabel, "center" )
		aMessageYes		= guiCreateButton ( 120, 70, 55, 17, "Yes", false, aMessageForm )
		aMessageNo		= guiCreateButton ( 180, 70, 55, 17, "No", false, aMessageForm )
		aMessageOk		= guiCreateButton ( 160, 70, 55, 17, "Ok", false, aMessageForm )
		guiSetProperty ( aMessageForm, "AlwaysOnTop", "true" )
		aMessageAction = nil
		bindKey ( "enter", "down", aMessageBoxAccept )
		bindKey ( "n", "down", aMessageBoxAccept )
		addEventHandler ( "onClientGUIClick", aMessageForm, aMessageBoxClick )
		--Register With Admin Form
		aRegister ( "MessageBox", aMessageForm, aMessageBox, aMessageBoxClose )
	end
	guiSetText ( aMessageForm, type )
	guiSetText ( aMessageLabel, tostring ( message ) )
	local width = guiLabelGetTextExtent ( aMessageLabel )
	if ( width > 180 ) then 
		guiSetSize ( aMessageForm, 100 + width + 20, 110, false )
		guiSetSize ( aMessageLabel, width, 16, false )
	else
		guiSetSize ( aMessageForm, 300, 110, false )
		guiSetSize ( aMessageLabel, 180, 16, false )
	end
	local sx, sy = guiGetSize ( aMessageForm, false )
	guiSetPosition ( aMessageOk, sx / 2 - 22, 70, false )
	guiSetPosition ( aMessageForm, x / 2 - sx / 2, y / 2 - sy / 2, false )
	guiBringToFront ( aMessageForm )
	guiSetVisible ( aMessageWarning, false )
	guiSetVisible ( aMessageQuestion, false )
	guiSetVisible ( aMessageError, false )
	guiSetVisible ( aMessageInfo, false )
	guiSetVisible ( aMessageYes, false )
	guiSetVisible ( aMessageNo, false )
	guiSetVisible ( aMessageOk, false )
	aHideFloaters()
	guiSetVisible ( aMessageForm, true )
	if ( type == "warning" ) then guiSetVisible ( aMessageWarning, true )
	elseif ( type == "question" ) then guiSetVisible ( aMessageQuestion, true )
	elseif ( type == "error" ) then guiSetVisible ( aMessageError, true )
	else guiSetVisible ( aMessageInfo, true ) end
	if ( ( action ~= "" ) and ( action ~= nil ) and ( action ~= false ) ) then
		guiSetVisible ( aMessageYes, true )
		guiSetVisible ( aMessageNo, true )
		aMessageAction = action
	else
		guiSetVisible ( aMessageOk, true )
	end
end

function aMessageBoxClose ( destroy )
	if ( ( destroy ) or ( aPerformanceMessage and guiCheckBoxGetSelected ( aPerformanceMessage ) ) ) then
		if ( aMessageForm ) then
			unbindKey ( "enter", "down", aMessageBoxAccept )
			unbindKey ( "n", "down", aMessageBoxAccept )
			removeEventHandler ( "onClientGUIClick", aMessageForm, aMessageBoxClick )
			aMessageAction = nil
			destroyElement ( aMessageForm )
			aMessageForm = nil
		end
	else
        if aMessageForm then guiSetVisible ( aMessageForm, false ) end
	end
end

function aMessageBoxAccept ( key, state )
	if ( guiGetVisible ( aMessageForm ) ) then
		if ( guiGetVisible ( aMessageOk ) ) then
			if ( key == "enter" ) then
				aMessageAction = nil
				aMessageBoxClose ( false )
			end
		else
			if ( key == "enter" ) then
				if ( aMessageAction ~= nil ) then 
					loadstring(aMessageAction)()
				end
				aMessageAction = nil
				aMessageBoxClose ( false )
			elseif ( key == "n" ) then
				aMessageAction = nil
				aMessageBoxClose ( false )
			end
		end
	end
end

function aMessageBoxClick ( button )
	if ( button == "left" ) then
		if ( source == aMessageYes ) then
			if ( aMessageAction ~= nil ) then 
				loadstring(aMessageAction)()
			end
			aMessageAction = nil
			aMessageBoxClose ( false )
		elseif ( ( source == aMessageNo ) or ( source == aMessageOk ) ) then
			aMessageAction = nil
			aMessageBoxClose ( false )
		end
	end
end

function aHideFloaters()
	if aMessagesForm then guiSetVisible ( aMessagesForm, false ) end	-- admin messages
	if aMessageForm then guiSetVisible ( aMessageForm, false ) end	-- message box
	if aInputForm then guiSetVisible ( aInputForm, false ) end
	if aBanInputForm then guiSetVisible ( aBanInputForm, false ) end
	if aMuteInputForm then guiSetVisible ( aMuteInputForm, false ) end
end
