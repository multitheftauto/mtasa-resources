--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_inputbox.lua
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
		aInputOk		= guiCreateButton ( 90, 80, 55, 17, "Ok", false, aInputForm )
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



--
-- Ban input box
--

aBanInputForm = nil

function aBanInputBox ( player )
	if ( aBanInputForm == nil ) then
		local x, y = guiGetScreenSize()
		aBanInputForm			= guiCreateWindow ( x / 2 - 150, y / 2 - 64, 300, 210, "", false )
							  guiWindowSetSizable ( aBanInputForm, false )
		guiSetAlpha(aBanInputForm, 1)		
		y = 24

		aBanInputLabel			= guiCreateLabel ( 20, y, 270, 15, "", false, aBanInputForm )
		guiLabelSetHorizontalAlign ( aBanInputLabel, 2 )
		y = y + 23
		
		aBanInputValue			= guiCreateEdit ( 35, y, 230, 24, "", false, aBanInputForm )
		y = y + 33

		aRadioSet1bg			= guiCreateTabPanel( 10, y, 115, 80, false, aBanInputForm)
		aRadioSet1				= guiCreateStaticImage(0,0,1,1, 'client\\images\\empty.png', true, aRadioSet1bg)
		guiSetAlpha ( aRadioSet1bg, 0.3 )
		guiSetProperty ( aRadioSet1, 'InheritsAlpha', 'false' )

		aBanInputRadio1Label	= guiCreateLabel ( 10, 20, 270, 15, "Type:", false, aRadioSet1 )
		aBanInputRadio1A		= guiCreateRadioButton ( 50, 20, 50, 15, "IP", false, aRadioSet1 )
		aBanInputRadio1B		= guiCreateRadioButton ( 50, 35, 120, 15, "Serial", false, aRadioSet1 )

		aRadioSet2bg			= guiCreateTabPanel( 135, y, 285, 80, false, aBanInputForm)
		aRadioSet2				= guiCreateStaticImage(0,0,1,1, 'client\\images\\empty.png', true, aRadioSet2bg)
		guiSetAlpha ( aRadioSet2bg, 0.3 )
		guiSetProperty ( aRadioSet2, 'InheritsAlpha', 'false' )

		aBanInputRadio2Label	= guiCreateLabel ( 10, 5, 270, 15, "Duration:", false, aRadioSet2 )
		aBanInputRadio2A		= guiCreateRadioButton ( 70, 5, 100, 15, "10 min", false, aRadioSet2 )
		aBanInputRadio2B		= guiCreateRadioButton ( 70, 20, 100, 15, "1 hour", false, aRadioSet2 )
		aBanInputRadio2C		= guiCreateRadioButton ( 70, 35, 100, 15, "12 hours", false, aRadioSet2 )
		aBanInputRadio2D		= guiCreateRadioButton ( 70, 50, 100, 15, "1000 years", false, aRadioSet2 )
		y = y + 90
				
		aBanInputOk			= guiCreateButton ( 90, y, 55, 17, "Ok", false, aBanInputForm )
		aBanInputCancel		= guiCreateButton ( 150, y, 55, 17, "Cancel", false, aBanInputForm )
		y = y + 30
		
		guiSetSize ( aBanInputForm, guiGetSize ( aBanInputForm, false ), y, false )
		
		guiSetProperty ( aBanInputForm, "AlwaysOnTop", "true" )
		aBanInputPlayer = nil

		addEventHandler ( "onClientGUIClick", aBanInputForm, aBanInputBoxClick )
		addEventHandler ( "onClientGUIAccepted", aBanInputValue, aBanInputBoxAccepted )
		--Register With Admin Form
		aRegister ( "BanInputBox", aBanInputForm, aBanInputBox, aBanInputBoxClose )
	end
	guiSetInputEnabled ( true )
	guiSetText ( aBanInputForm, "Ban player " .. getPlayerName(player) )
	guiSetText ( aBanInputLabel, "Enter the ban reason" )
	guiSetVisible ( aBanInputForm, true )
	guiSetVisible ( aMessageForm, false )
	guiBringToFront ( aBanInputForm )
	aBanInputPlayer = player
end

function aBanInputBoxClose ( destroy )
	guiSetInputEnabled ( false )
	if ( ( destroy ) or ( guiCheckBoxGetSelected ( aPerformanceInput ) ) ) then
		if ( aBanInputForm ) then
			removeEventHandler ( "onClientGUIClick", aBanInputForm, aBanInputBoxClick )
			removeEventHandler ( "onClientGUIAccepted", aBanInputValue, aBanInputBoxAccepted )
			aBanInputPlayer = nil
			destroyElement ( aBanInputForm )
			aBanInputForm = nil
		end
	else
		guiSetVisible ( aBanInputForm, false )
	end
end

function aBanInputBoxAccepted ()
	aBanInputBoxFinish()
end

function aBanInputBoxClick ( button )
	if ( button == "left" ) then
		if ( source == aBanInputOk ) then
			aBanInputBoxFinish()
			aBanInputPlayer = nil
			aBanInputBoxClose ( false )
		elseif ( source == aBanInputCancel ) then
			aBanInputPlayer = nil
			aBanInputBoxClose ( false )
		end
	end
end


function aBanInputBoxFinish ()
	-- Get options
	local bUseIP	 = guiRadioButtonGetSelected( aBanInputRadio1A )
	local bUseSerial = guiRadioButtonGetSelected( aBanInputRadio1B )

	local bDur10min		= guiRadioButtonGetSelected( aBanInputRadio2A )
	local bDur1hour		= guiRadioButtonGetSelected( aBanInputRadio2B )
	local bDur12hours	= guiRadioButtonGetSelected( aBanInputRadio2C )
	local bDurNoend		= guiRadioButtonGetSelected( aBanInputRadio2D )

	local reason = guiGetText ( aBanInputValue )

	-- Calc duration
	local seconds = false
	if bDur10min then
		reason = reason .. " [10 mins]"
		seconds = 60 * 10
	elseif bDur1hour then
		reason = reason .. " [1 hour]"
		seconds = 60 * 60
	elseif bDur12hours then
		reason = reason .. " [12 hours]"
		seconds = 60 * 60 * 12
	elseif bDurNoend then
		seconds = 0
	end

	-- Validate settings
	if not bUseIP and not bUseSerial then
		aMessageBox ( "error", "No type selected!" )
		return
	end

	if seconds == false then
		aMessageBox ( "error", "No duration selected!" )
		return
	end

	-- Send ban info to the server
	triggerServerEvent ( "aPlayer", getLocalPlayer(), aBanInputPlayer, "ban", reason, seconds, bUseSerial )

	-- Clear input
	guiSetText ( aBanInputValue, "" )
	guiRadioButtonSetSelected( aBanInputRadio1A, false )
	guiRadioButtonSetSelected( aBanInputRadio1B, false )
	guiRadioButtonSetSelected( aBanInputRadio2A, false )
	guiRadioButtonSetSelected( aBanInputRadio2B, false )
	guiRadioButtonSetSelected( aBanInputRadio2C, false )
	guiRadioButtonSetSelected( aBanInputRadio2D, false )
end

