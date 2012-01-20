--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_inputbox.lua
*
*	Original File by lil_Toady
*
**************************************]]

aInputBox = {
	Thread = nil,
	Result = nil
}

function inputBox ( title, message, default )
	if ( message ) then
		return aInputBox.Show ( title, message, default )
	end
	return false
end

function aInputBox.Show ( title, message, default )
	if ( aInputBox.Form == nil ) then
		local x, y = guiGetScreenSize()
		aInputBox.Form		= guiCreateWindow ( x / 2 - 150, y / 2 - 64, 300, 110, "", false )
				  	   	  guiWindowSetSizable ( aInputBox.Form, false )
		aInputBox.Label		= guiCreateLabel ( 20, 24, 270, 15, "", false, aInputBox.Form )
					   	  guiLabelSetHorizontalAlign ( aInputBox.Label, "center" )
		aInputBox.Value		= guiCreateEdit ( 35, 47, 230, 24, "", false, aInputBox.Form )
						  guiHandleInput ( aInputBox.Value )
		aInputBox.Ok		= guiCreateButton ( 90, 80, 55, 17, "Ok", false, aInputBox.Form )
		aInputBox.Cancel		= guiCreateButton ( 150, 80, 55, 17, "Cancel", false, aInputBox.Form )
		guiSetProperty ( aInputBox.Form, "AlwaysOnTop", "true" )

		addEventHandler ( "onClientGUIClick", aInputBox.Form, aInputBox.onClick )
		addEventHandler ( "onClientGUIAccepted", aInputBox.Value, aInputBox.onAccepted )
		--Register With Admin Form
		aRegister ( "InputBox", aInputBox.Form, aInputBox.Show, aInputBox.Close )
	end
	guiSetText ( aInputBox.Form, title )
	guiSetText ( aInputBox.Label, message )
	guiSetText ( aInputBox.Value, default or "" )
	guiSetVisible ( aInputBox.Form, true )
	if ( aMessageBox.Form ) then
		guiSetVisible ( aMessageBox.Form, false )
	end
	guiBringToFront ( aInputBox.Form )

	aInputBox.Result = nil
	aInputBox.Thread = sourceCoroutine
	coroutine.yield ()
	if ( aInputBox.Result ) then
		return guiGetText ( aInputBox.Value )
	end
	return false
end

function aInputBox.Close ( destroy )
	guiSetInputEnabled ( false )
	if ( aInputBox.Form ) then
		if ( destroy ) then
			removeEventHandler ( "onClientGUIClick", aInputBox.Form, aInputBox.onClick )
			removeEventHandler ( "onClientGUIAccepted", aInputBox.Value, aInputBox.Accepted )
			aInputAction = nil
			destroyElement ( aInputForm )
			aInputForm = nil
		else
			guiSetVisible ( aInputBox.Form, false )
		end
		if ( aInputBox.Thread ) then
			coroutine.resume ( aInputBox.Thread )
		end
	end
end

function aInputBox.onAccepted ()
	aInputBox.Result = true
	aInputBox.Close ( false )
end

function aInputBox.onClick ( button )
	if ( button == "left" ) then
		if ( source == aInputBox.Ok ) then
			aInputBox.Result = true
			aInputBox.Close ( false )
		elseif ( source == aInputBox.Cancel ) then
			aInputBox.Result = false
			aInputBox.Close ( false )
		end
	end
end