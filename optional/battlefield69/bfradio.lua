function radioChat (player)
if isPlayerDead(getLocalPlayer()) then return end
if not ( radioForm ) then
	local x, y = guiGetScreenSize()
	local x = 150/x
	local y = 200/y
	radioForm = guiCreateWindow ( 0.01, 0.26, x, y, "Radio Messages", true )
	background = guiCreateStaticImage ( 0, 0, 1, 1, "bg.png", true, radioForm )
	text1 = guiCreateLabel ( 0.07, 0.15, 0.90, 0.30, "  1. Bases", true, radioForm )
	guiLabelSetColor ( text1, 255, 255, 255 )
	text2 = guiCreateLabel ( 0.07, 0.25, 0.90, 0.30, "  2. Request", true, radioForm )
	guiLabelSetColor ( text2, 255, 255, 255 )
	text3 = guiCreateLabel ( 0.07, 0.35, 0.90, 0.30, "  3. Spotted", true, radioForm )
	guiLabelSetColor ( text3, 255, 255, 255 )
	text4 = guiCreateLabel ( 0.07, 0.45, 0.90, 0.30, "  4. Common", true, radioForm )
	guiLabelSetColor ( text4, 255, 255, 255 )
	text5 = guiCreateLabel ( 0.07, 0.55, 0.90, 0.30, "  5. Taking fire", true, radioForm )
	guiLabelSetColor ( text5, 255, 255, 255 )
	text6 = guiCreateLabel ( 0.07, 0.65, 0.90, 0.30, "", true, radioForm )
	guiLabelSetColor ( text6, 255, 255, 255 )
	text7 = guiCreateLabel ( 0.07, 0.75, 0.90, 0.30, "", true, radioForm )
	guiLabelSetColor ( text7, 255, 255, 255 )
	text8 = guiCreateLabel ( 0.07, 0.85, 0.90, 0.30, "  8. Exit", true, radioForm )
	guiLabelSetColor ( text8, 255, 255, 255 )
	bindKey ( "1", "down", radioChoice )
	bindKey ( "2", "down", radioChoice )
	bindKey ( "3", "down", radioChoice )
	bindKey ( "4", "down", radioChoice )
	bindKey ( "5", "down", radioChoice )
	bindKey ( "6", "down", radioChoice )
	bindKey ( "7", "down", radioChoice )
	bindKey ( "8", "down", radioChoice )
else
	radioWindow(player)
end
end
addCommandHandler ("radio", radioChat )

function radioWindow (player)
	unbindKey ( "1", "down" )
	unbindKey ( "2", "down" )
	unbindKey ( "3", "down" )
	unbindKey ( "4", "down" )
	unbindKey ( "5", "down" )
	unbindKey ( "6", "down" )
	unbindKey ( "7", "down" )
	unbindKey ( "8", "down" )
	guiSetText ( text1, "  1. Bases" )
	guiSetText ( text2, "  2. Request" )
	guiSetText ( text3, "  3. Spotted" )
	guiSetText ( text4, "  4. Common" )
	guiSetText ( text5, "  5. Taking fire" )
	guiSetText ( text6, "" )
	guiSetText ( text7, "" )
	guiSetText ( text8, "  8. Exit" )
	guiSetVisible ( radioForm, true )
	bindKey ( "1", "down", radioChoice )
	bindKey ( "2", "down", radioChoice )
	bindKey ( "3", "down", radioChoice )
	bindKey ( "4", "down", radioChoice )
	bindKey ( "5", "down", radioChoice )
	bindKey ( "6", "down", radioChoice )
	bindKey ( "7", "down", radioChoice )
	bindKey ( "8", "down", radioChoice )
end

function radioChoice ( key, keyState )
	if key == "1" then --bases
		guiSetText ( text1, "  1. Attack" )
		guiSetText ( text2, "  2. Defend" )
		guiSetText ( text3, "  3. Its ours" )
		guiSetText ( text4, "  4. Cant hold" )
		guiSetText ( text5, "" )
		guiSetText ( text8, "  8. Back" )
		
		unbindKey ( "1", "down", radioChoice )
		unbindKey ( "2", "down", radioChoice )
		unbindKey ( "3", "down", radioChoice )
		unbindKey ( "4", "down", radioChoice )
		unbindKey ( "5", "down", radioChoice )
		unbindKey ( "6", "down", radioChoice )
		unbindKey ( "7", "down", radioChoice )
		unbindKey ( "8", "down", radioChoice )
		
		bindKey ( "1", "down", radioBases )
		bindKey ( "2", "down", radioBases )
		bindKey ( "3", "down", radioBases )
		bindKey ( "4", "down", radioBases )
		bindKey ( "8", "down", radioWindow )
	elseif key == "2" then --request
		guiSetText ( text1, "  1. Backup" )
		guiSetText ( text2, "  2. Medic" )
		guiSetText ( text3, "  3. Pickup" )
		guiSetText ( text4, "  4. Anti-tank" )
		guiSetText ( text5, "  5. Mechanic" )
		guiSetText ( text8, "  8. Back" )
		
		unbindKey ( "1", "down", radioChoice )
		unbindKey ( "2", "down", radioChoice )
		unbindKey ( "3", "down", radioChoice )
		unbindKey ( "4", "down", radioChoice )
		unbindKey ( "5", "down", radioChoice )
		unbindKey ( "6", "down", radioChoice )
		unbindKey ( "7", "down", radioChoice )
		unbindKey ( "8", "down", radioChoice )
		
		bindKey ( "1", "down", radioRequest )
		bindKey ( "2", "down", radioRequest )
		bindKey ( "3", "down", radioRequest )
		bindKey ( "4", "down", radioRequest )
		bindKey ( "5", "down", radioRequest )
		bindKey ( "8", "down", radioWindow )
	elseif key == "3" then --spotted
		guiSetText ( text1, "  1. Soldier" )
		guiSetText ( text2, "  2. Vehicle" )
		guiSetText ( text3, "  3. Airplane" )
		guiSetText ( text4, "  4. Scout" )
		guiSetText ( text5, "  5. Anti-tank" )
		guiSetText ( text8, "  8. Back" )
		
		unbindKey ( "1", "down", radioChoice )
		unbindKey ( "2", "down", radioChoice )
		unbindKey ( "3", "down", radioChoice )
		unbindKey ( "4", "down", radioChoice )
		unbindKey ( "5", "down", radioChoice )
		unbindKey ( "6", "down", radioChoice )
		unbindKey ( "7", "down", radioChoice )
		unbindKey ( "8", "down", radioChoice )
		
		bindKey ( "1", "down", radioSpotted )
		bindKey ( "2", "down", radioSpotted )
		bindKey ( "3", "down", radioSpotted )
		bindKey ( "4", "down", radioSpotted )
		bindKey ( "5", "down", radioSpotted )
		bindKey ( "8", "down", radioWindow )
	elseif key == "4" then --common
		guiSetText ( text1, "  1. Roger" )
		guiSetText ( text2, "  2. Negative" )
		guiSetText ( text3, "  3. Enemy down" )
		guiSetText ( text4, "  4. *all* Take that" )
		guiSetText ( text5, "  5. *all* Give up" )
		guiSetText ( text6, "  6. *all* All your bases" )
		guiSetText ( text8, "  8. Back" )
		
		unbindKey ( "1", "down", radioChoice )
		unbindKey ( "2", "down", radioChoice )
		unbindKey ( "3", "down", radioChoice )
		unbindKey ( "4", "down", radioChoice )
		unbindKey ( "5", "down", radioChoice )
		unbindKey ( "6", "down", radioChoice )
		unbindKey ( "7", "down", radioChoice )
		unbindKey ( "8", "down", radioChoice )
		
		bindKey ( "1", "down", radioCommon )
		bindKey ( "2", "down", radioCommon )
		bindKey ( "3", "down", radioCommon )
		bindKey ( "4", "down", radioCommon )
		bindKey ( "5", "down", radioCommon )
		bindKey ( "6", "down", radioCommon )
		bindKey ( "8", "down", radioWindow )
	elseif key == "5" then --taking fire
		local x = 5
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
	elseif key == "8" then --exit
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down" )
		unbindKey ( "2", "down" )
		unbindKey ( "3", "down" )
		unbindKey ( "4", "down" )
		unbindKey ( "5", "down" )
		unbindKey ( "6", "down" )
		unbindKey ( "7", "down" )
		unbindKey ( "8", "down" )
	end
end

function radioBases (key, keyState)
	if ( key == "1" ) then
		local x = 1
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioBases )
		unbindKey ( "2", "down", radioBases )
		unbindKey ( "3", "down", radioBases )
		unbindKey ( "4", "down", radioBases )
		unbindKey ( "8", "down", radioWindow )
	elseif ( key == "2" ) then
		local x = 2
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioBases )
		unbindKey ( "2", "down", radioBases )
		unbindKey ( "3", "down", radioBases )
		unbindKey ( "4", "down", radioBases )
		unbindKey ( "8", "down", radioWindow )
	elseif ( key == "3" ) then
		local x = 3
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioBases )
		unbindKey ( "2", "down", radioBases )
		unbindKey ( "3", "down", radioBases )
		unbindKey ( "4", "down", radioBases )
		unbindKey ( "8", "down", radioWindow )
	elseif ( key == "4" ) then
		local x = 4
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioBases )
		unbindKey ( "2", "down", radioBases )
		unbindKey ( "3", "down", radioBases )
		unbindKey ( "4", "down", radioBases )
		unbindKey ( "8", "down", radioWindow )
	end
end

function radioRequest ( key, keyState )
	if ( key == "1" ) then
		local x = 6
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioRequest )
		unbindKey ( "2", "down", radioRequest )
		unbindKey ( "3", "down", radioRequest )
		unbindKey ( "4", "down", radioRequest )
		unbindKey ( "5", "down", radioRequest )
		unbindKey ( "8", "down", radioRequest )
	elseif ( key == "2" ) then
		local x = 7
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioRequest )
		unbindKey ( "2", "down", radioRequest )
		unbindKey ( "3", "down", radioRequest )
		unbindKey ( "4", "down", radioRequest )
		unbindKey ( "5", "down", radioRequest )
		unbindKey ( "8", "down", radioRequest )
	elseif ( key == "3" ) then
		local x = 8
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioRequest )
		unbindKey ( "2", "down", radioRequest )
		unbindKey ( "3", "down", radioRequest )
		unbindKey ( "4", "down", radioRequest )
		unbindKey ( "5", "down", radioRequest )
		unbindKey ( "8", "down", radioRequest )
	elseif ( key == "4" ) then
		local x = 9
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioRequest )
		unbindKey ( "2", "down", radioRequest )
		unbindKey ( "3", "down", radioRequest )
		unbindKey ( "4", "down", radioRequest )
		unbindKey ( "5", "down", radioRequest )
		unbindKey ( "8", "down", radioRequest )
	elseif ( key == "5" ) then
		local x = 10
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioRequest )
		unbindKey ( "2", "down", radioRequest )
		unbindKey ( "3", "down", radioRequest )
		unbindKey ( "4", "down", radioRequest )
		unbindKey ( "5", "down", radioRequest )
		unbindKey ( "8", "down", radioRequest )
	end
end

function radioSpotted ( key, keyState )
	if ( key == "1" ) then
		local x = 11
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioSpotted )
		unbindKey ( "2", "down", radioSpotted )
		unbindKey ( "3", "down", radioSpotted )
		unbindKey ( "4", "down", radioSpotted )
		unbindKey ( "5", "down", radioSpotted )
		unbindKey ( "8", "down", radioWindow )
	elseif ( key == "2" ) then
		local x = 12
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioSpotted )
		unbindKey ( "2", "down", radioSpotted )
		unbindKey ( "3", "down", radioSpotted )
		unbindKey ( "4", "down", radioSpotted )
		unbindKey ( "5", "down", radioSpotted )
		unbindKey ( "8", "down", radioWindow )
	elseif ( key == "3" ) then
		local x = 13
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioSpotted )
		unbindKey ( "2", "down", radioSpotted )
		unbindKey ( "3", "down", radioSpotted )
		unbindKey ( "4", "down", radioSpotted )
		unbindKey ( "5", "down", radioSpotted )
		unbindKey ( "8", "down", radioWindow )
	elseif ( key == "4" ) then
		local x = 14
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioSpotted )
		unbindKey ( "2", "down", radioSpotted )
		unbindKey ( "3", "down", radioSpotted )
		unbindKey ( "4", "down", radioSpotted )
		unbindKey ( "5", "down", radioSpotted )
		unbindKey ( "8", "down", radioWindow )
	elseif ( key == "5" ) then
		local x = 15
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioSpotted )
		unbindKey ( "2", "down", radioSpotted )
		unbindKey ( "3", "down", radioSpotted )
		unbindKey ( "4", "down", radioSpotted )
		unbindKey ( "5", "down", radioSpotted )
		unbindKey ( "8", "down", radioWindow )
	end
end

function radioCommon ( key, keyState )
	if ( key == "1" ) then
		local x = 16
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioCommon )
		unbindKey ( "2", "down", radioCommon )
		unbindKey ( "3", "down", radioCommon )
		unbindKey ( "4", "down", radioCommon )
		unbindKey ( "5", "down", radioCommon )
		unbindKey ( "8", "down", radioWindow )
	elseif ( key == "2" ) then
		local x = 17
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioCommon )
		unbindKey ( "2", "down", radioCommon )
		unbindKey ( "3", "down", radioCommon )
		unbindKey ( "4", "down", radioCommon )
		unbindKey ( "5", "down", radioCommon )
		unbindKey ( "8", "down", radioWindow )
	elseif ( key == "3" ) then
		local x = 18
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioCommon )
		unbindKey ( "2", "down", radioCommon )
		unbindKey ( "3", "down", radioCommon )
		unbindKey ( "4", "down", radioCommon )
		unbindKey ( "5", "down", radioCommon )
		unbindKey ( "8", "down", radioWindow )
	elseif ( key == "4" ) then
		local x = 19
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioCommon )
		unbindKey ( "2", "down", radioCommon )
		unbindKey ( "3", "down", radioCommon )
		unbindKey ( "4", "down", radioCommon )
		unbindKey ( "5", "down", radioCommon )
		unbindKey ( "8", "down", radioWindow )
	elseif ( key == "5" ) then
		local x = 20
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioCommon )
		unbindKey ( "2", "down", radioCommon )
		unbindKey ( "3", "down", radioCommon )
		unbindKey ( "4", "down", radioCommon )
		unbindKey ( "5", "down", radioCommon )
		unbindKey ( "8", "down", radioWindow )
	elseif ( key == "6" ) then
		local x = 21
		triggerServerEvent ("radio", getLocalPlayer(), x )
		guiSetVisible (radioForm, false)
		unbindKey ( "1", "down", radioCommon )
		unbindKey ( "2", "down", radioCommon )
		unbindKey ( "3", "down", radioCommon )
		unbindKey ( "4", "down", radioCommon )
		unbindKey ( "5", "down", radioCommon )
		unbindKey ( "6", "down", radioCommon )
		unbindKey ( "8", "down", radioWindow )
	end
end

bindKey ("F1", "down", radioChat)