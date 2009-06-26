--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_inputbox.lua
*
*	Original File by lil_Toady
*
**************************************]]

aInputForm = nil

function aInputBox ( title, message, default, action )
	if ( aInputForm == nil ) then
		local x, y = guiGetScreenSize()
		aInputForm		= guiCreateWindow ( x / 2 - 150, y / 2 - 64, 300, 110, "", false )
				  	   guiWindowSetSizable ( aInputForm, false )
		aInputLabel		= guiCreateLabel ( 20, 24, 270, 15, "", false, aInputForm )
					   guiLabelSetHorizontalAlign ( aInputLabel, 2 )
		aInputValue		= guiCreateEdit ( 35, 47, 230, 24, "", false, aInputForm )
		aInputOk		= guiCreateButton ( 90, 80, 55, 17, "k", false, aInputForm )
		aInputCancel		= guiCreateButton ( 150, 80, 55, 17, "Cancel", false, aInputForm )
		guiSetProperty ( aInputForm, "AlwaysOnTop", "true" )
		aInputAction = nil

		addEventHandler ( "onClientGUIClick", aInputForm, aInputBoxClick )
		addEventHandler ( "onClientGUIAccepted", aInputValue, aInputBoxAccepted )
		--Register With Admin Form
		aRegister ( "InputBox", aInputForm, aInputBox, aInputBoxClose )
	end
	guiSetInputEnabled ( true )
	guiSetText ( aInputForm, title )
	guiSetText ( aInputLabel, message )
	guiSetText ( aInputValue, default )
	guiSetVisible ( aInputForm, true )
	guiSetVisible ( aMessageForm, false )
	guiBringToFront ( aInputForm )
	aInputAction = action
end

function aInputBoxClose ( destroy )
	guiSetInputEnabled ( false )
	if ( ( destroy ) or ( guiCheckBoxGetSelected ( aPerformanceInput ) ) ) then
		if ( aInputForm ) then
			removeEventHandler ( "onClientGUIClick", aInputForm, aInputBoxClick )
			removeEventHandler ( "onClientGUIAccepted", aInputValue, aInputBoxAccepted )
			aInputAction = nil
			destroyElement ( aInputForm )
			aInputForm = nil
		end
	else
		guiSetVisible ( aInputForm, false )
	end
end

function aInputBoxAccepted ()
	loadstring ( string.gsub ( aInputAction, "$value", "\""..guiGetText ( aInputValue ).."\"" ) )()
end

function aInputBoxClick ( button )
	if ( button == "left" ) then
		if ( source == aInputOk ) then
			loadstring ( string.gsub ( aInputAction, "$value", "\""..guiGetText ( aInputValue ).."\"" ) )()
			aInputAction = nil
			aInputBoxClose ( false )
		elseif ( source == aInputCancel ) then
			aInputAction = nil
			aInputBoxClose ( false )
		end
	end
end