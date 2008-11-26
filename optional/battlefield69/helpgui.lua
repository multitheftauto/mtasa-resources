function battlefieldHelp ()
	--outputChatBox ("Battlefield69 Helpgui loaded")
	--setTimer(function() outputChatBox("Press F9 to read the help", 0, 255, 0) end, 2000, 1, getLocalPlayer())
	helpTab = call(getResourceFromName("helpmanager"), "addHelpTab", getThisResource(), true)
	helpGridList = guiCreateGridList ( 0.03, 0.05, 0.20, 0.9, true, helpTab )
	addEventHandler ("onClientGUIClick", helpGridList, chooseHelp )
	column = guiGridListAddColumn ( helpGridList, "Contents: ", 0.85 )
	guiGridListSetSortingEnabled ( helpGridList, false )
	local general = guiGridListAddRow ( helpGridList )
	local keys = guiGridListAddRow ( helpGridList )
	local spawn = guiGridListAddRow ( helpGridList )
	local capturing = guiGridListAddRow ( helpGridList )
	local class = guiGridListAddRow ( helpGridList )
	local abilitys = guiGridListAddRow ( helpGridList )
	local vehicles = guiGridListAddRow ( helpGridList )
	local tips = guiGridListAddRow ( helpGridList )
	local ONSHelp = guiGridListAddRow ( helpGridList )
	local questions = guiGridListAddRow ( helpGridList )
	guiGridListSetItemText ( helpGridList, general, column, "General", false, false)
	guiGridListSetItemText ( helpGridList, keys, column, "Special Keys", false, false)
	guiGridListSetItemText ( helpGridList, spawn, column, "Spawning", false, false)
	guiGridListSetItemText ( helpGridList, capturing, column, "Capturing", false, false)
	guiGridListSetItemText ( helpGridList, class, column, "Classes", false, false)
	guiGridListSetItemText ( helpGridList, abilitys, column, "Abilities", false, false)
	guiGridListSetItemText ( helpGridList, vehicles, column, "Vehicles", false, false)
	guiGridListSetItemText ( helpGridList, tips, column, "Tips", false, false)
	guiGridListSetItemText ( helpGridList, ONSHelp, column, "ONS Help", false, false)
	guiGridListSetItemText ( helpGridList, questions, column, "Questions?", false, false)
end
addEventHandler ("onClientResourceStart", getResourceRootElement(getThisResource()), battlefieldHelp)


function chooseHelp ()
	local choosenHelp = guiGridListGetItemText ( helpGridList, guiGridListGetSelectedItem ( helpGridList ), 1 )
	if choosenHelp == "General" then
		if not ( topic ) then
			topic = guiCreateLabel (0.3, 0.1, 0.5, 0.3, "General", true, helpTab)
			guiSetFont ( topic, "sa-gothic" )
		else
			guiSetText (topic, "General")
		end
		if not ( mainText ) then
			mainText = guiCreateMemo ( 0.25, 0.3, 0.7, 0.65, "Battlefield69 is a teambased game.\nYour main goal is to take control of all the bases around the map. The first team to reach the max score wins the round.", true, helpTab)
			guiMemoSetReadOnly (mainText, true)
		else
			guiSetText (mainText, "Battlefield69 is a teambased game.\nYour main goal is to take control of all the bases around the map. The first team to reach the max score wins the round.")
		end
	elseif choosenHelp == "Special Keys" then
		if not ( topic ) then
			topic = guiCreateLabel (0.3, 0.1, 0.5, 0.3, "Special Keys", true, helpTab)
			guiSetFont ( topic, "sa-gothic" )
		else
			guiSetText (topic, "Special Keys")
		end
		if not ( mainText ) then
			mainText = guiCreateMemo ( 0.25, 0.3, 0.7, 0.65, "When using special abilities, extra seats, anti-air guns etc 'R' is the magic key.\nBattlefield69 also got premade radiomessages, which may be accessed by hitting 'F1'.\n\nYou can also change your weapon by pressing 1-5.", true, helpTab)
			guiMemoSetReadOnly (mainText, true)
		else
			guiSetText (mainText, "When using special abilities, extra seats, anti-air guns etc 'R' is the magic key.\nBattlefield69 also got premade radiomessages, which may be accessed by hitting 'F1'.\n\nYou can also change your weapon by pressing 1-5.")
		end
	elseif choosenHelp == "Spawning" then
		if not ( topic ) then
			topic = guiCreateLabel (0.3, 0.1, 0.5, 0.3, "Spawning", true, helpTab)
			guiSetFont ( topic, "sa-gothic" )
		else
			guiSetText (topic, "Spawning")
		end
		if not ( mainText ) then
			mainText = guiCreateMemo ( 0.25, 0.3, 0.7, 0.65, "Spawning in battlefield69 is a bit different to what you are used to.\nTo spawn in battlefield, select your class and press your team's base icon on the map (red for axis, blue for ally), you will then see an 'accept' button. Press it, and you will spawn.", true, helpTab)
			guiMemoSetReadOnly (mainText, true)
		else
			guiSetText (mainText, "Spawning in battlefield69 is a bit different to what you are used to.\nTo spawn in battlefield, select your class and press your team's base icon on the map (red for axis, blue for ally), you will then see an 'accept' button. Press it, and you will spawn.")
		end
	elseif  choosenHelp == "Capturing" then
		if not ( topic ) then
			topic = guiCreateLabel (0.3, 0.1, 0.5, 0.3, "Capturing", true, helpTab)
			guiSetFont ( topic, "sa-gothic" )
		else
			guiSetText (topic, "Capturing")
		end
		if not ( mainText ) then
			mainText = guiCreateMemo ( 0.25, 0.3, 0.7, 0.65, "To capture a base in battlefield, simply stand next to the flag.\n\nThe time it takes to capture a base depends on the position of the current flag. Maximum time is 20 seconds.", true, helpTab)
			guiMemoSetReadOnly (mainText, true)
		else
			guiSetText (mainText, "To capture a base in battlefield, simply stand next to the flag.\n\nThe time it takes to capture a base depends on the position of the current flag. Maximum time is 20 seconds.")
		end
	elseif choosenHelp == "Classes" then
		if not ( topic ) then
			topic = guiCreateLabel (0.3, 0.1, 0.5, 0.3, "Classes", true, helpTab)
			guiSetFont ( topic, "sa-gothic" )
		else
			guiSetText (topic, "Classes")
		end
		if not ( mainText ) then
			mainText = guiCreateMemo ( 0.25, 0.3, 0.7, 0.65, "Battlefield69 is a teamgame, so choose your class carefully.\nEach class has its weakness.\n\nThe soldier is an excellent infantry class, while the scout is a good long ranger.\nThe mechanic is the only class that can repair vehicles, or even request new ones.\nThe medic can heal other players, while the anti-tank can take out tanks with ease.", true, helpTab)
			guiMemoSetReadOnly (mainText, true)
		else
			guiSetText (mainText, "Battlefield69 is a teamgame, so choose your class carefully.\nEach class has its weakness.\n\nThe soldier is an excellent infantry class, while the scout is a good long ranger.\nThe mechanic is the only class that can repair vehicles, or even request new ones.\nThe medic can heal other players, while the anti-tank can take out tanks with ease.")
		end
	elseif choosenHelp == "Abilities" then
		if not ( topic ) then
			topic = guiCreateLabel (0.3, 0.1, 0.5, 0.3, "Abilities", true, helpTab)
			guiSetFont ( topic, "sa-gothic" )
		else
			guiSetText (topic, "Abilities")
		end
		if not ( mainText ) then
			mainText = guiCreateMemo ( 0.25, 0.3, 0.7, 0.65, "Scout: A scout has the special ability of being able to fake death. To do so, press 'R'.\n\nMechanic: The mechanic can request new vehicles, as well as repair wasted ones. Equip your backpack and press 'R' to access the menu.\n\nMedic: The medic can heal wounded players. To do so, equip your medicine flowers and Hold 'R', then click on the player you want to heal.", true, helpTab)
			guiMemoSetReadOnly (mainText, true)
		else
			guiSetText (mainText, "Scout: A scout has the special ability of being able to fake death. To do so, press 'R'.\n\nMechanic: The mechanic can request new vehicles, as well as repair wasted ones. Equip your backpack and press 'R' to access the menu.\n\nMedic: The medic can heal wounded players. To do so, equip your medicine flowers and Hold 'R', then click on the player you want to heal.")
		end
	elseif choosenHelp == "Vehicles" then
		if not ( topic ) then
			topic = guiCreateLabel (0.3, 0.1, 0.5, 0.3, "Vehicles", true, helpTab)
			guiSetFont ( topic, "sa-gothic" )
		else
			guiSetText (topic, "Vehicles")
		end
		if not ( mainText ) then
			mainText = guiCreateMemo ( 0.25, 0.3, 0.7, 0.65, "Some vehicles are capable of performing special actions.\n\nRustler: while in a rustler, press R to drop a bomb.\n\nPatriot: This vehicle is equipped with a minigun in the back. Aim at the vehicle and press 'R' to mount the minigun. To dismount, aim at the vehicle and press 'R' again.\n\nFlatbed: the flatbed is capable of taking multiple passengers in the back. Simply press 'R' while aiming at the vehicle to hop on the back.\n\nCargobob: same as flatbed.\n\nDFT-30: aka radartruck. While in this vehicle, all your teammates will be able to see the other team's position.", true, helpTab)
			guiMemoSetReadOnly (mainText, true)
		else
			guiSetText (mainText, "Some vehicles are capable of performing special actions.\n\nRustler: while in a rustler, press R to drop a bomb.\n\nPatriot: This vehicle is equipped with a minigun in the back. Aim at the vehicle and press 'R' to mount the minigun. To dismount, aim at the vehicle and press 'R' again.\n\nFlatbed: the flatbed is capable of taking multiple passengers in the back. Simply press 'R' while aiming at the vehicle to hop on the back.\n\nCargobob: same as flatbed.\n\nDFT-30: aka radartruck. While in this vehicle, all your teammates will be able to see the other team's position.")
		end
	elseif choosenHelp == "Tips" then
		if not ( topic ) then
			topic = guiCreateLabel (0.3, 0.1, 0.5, 0.3, "Tips", true, helpTab)
			guiSetFont ( topic, "sa-gothic" )
		else
			guiSetText (topic, "Tips")
		end
		if not ( mainText ) then
			mainText = guiCreateMemo ( 0.25, 0.3, 0.7, 0.65, "Try to stay out of close contact if you're not a soldier.\n\nWhen you aim at an enemy, your teammates will be able to see his position for a short while.\n\nWhen trying to take out a tank, try to aim at the front of the tank.\n\nTry to shoot enemies in the head. This will instantly kill them.\n\nWhen using the radio commands, your icon on the radar will flash for a short while, so your teammates know where you are.", true, helpTab)
			guiMemoSetReadOnly (mainText, true)
		else
			guiSetText (mainText, "Try to stay out of close contact if you're not a soldier.\n\nWhen you aim at an enemy, your teammates will be able to see his position for a short while.\n\nWhen trying to take out a tank, try to aim at the front of the tank.\n\nTry to shoot enemies in the head. This will instantly kill them.\n\nWhen using the radio commands, your icon on the radar will flash for a short while, so your teammates know where you are.")
		end
	elseif choosenHelp == "ONS Help" then
		if not ( topic ) then
			topic = guiCreateLabel (0.3, 0.1, 0.5, 0.3, "On screen help", true, helpTab)
			guiSetFont ( topic, "sa-gothic" )
		else
			guiSetText (topic, "On screen help")
		end
		if not ( mainText ) then
			mainText = guiCreateMemo ( 0.25, 0.3, 0.7, 0.65, "Battlefield69 features an on screen helpsystem.\n\nYou can enable/disable it on the team selection menu.\n\nIf you want to enable/disable the ingame help in the middle of a game, you can do so by typing:\n/enableguihelp to enable\n/disableguihelp to disable", true, helpTab)
			guiMemoSetReadOnly (mainText, true)
		else
			guiSetText (mainText, "Battlefield69 features an on screen helpsystem.\n\nYou can enable/disable it on the team selection menu.\n\nIf you want to enable/disable the ingame help in the middle of a game, you can do so by typing:\n/enableguihelp to enable\n/disableguihelp to disable")
		end
	elseif choosenHelp == "Questions?" then
		if not ( topic ) then
			topic = guiCreateLabel (0.3, 0.1, 0.5, 0.3, "Questions", true, helpTab)
			guiSetFont ( topic, "sa-gothic" )
		else
			guiSetText (topic, "Questions")
		end
		if not ( mainText ) then
			mainText = guiCreateMemo ( 0.25, 0.3, 0.7, 0.65, "If you have any questions, bug reports, maping problems etc etc. feel free to contact me on IRC, and i'll try to help.\n\n //Lucif3r", true, helpTab)
			guiMemoSetReadOnly (mainText, true)
		else
			guiSetText (mainText, "If you have any questions, bug reports, maping problems etc etc. feel free to contact me on IRC, and i'll try to help.\n\n //Lucif3r")
		end
	end
end