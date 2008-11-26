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
	local vehicles = guiGridListAddRow ( helpGridList )
	local weapons = guiGridListAddRow ( helpGridList )
	local tips = guiGridListAddRow ( helpGridList )
	local questions = guiGridListAddRow ( helpGridList )
	guiGridListSetItemText ( helpGridList, general, column, "General", false, false)
	guiGridListSetItemText ( helpGridList, keys, column, "Keys", false, false)
	guiGridListSetItemText ( helpGridList, spawn, column, "Spawning", false, false)
	guiGridListSetItemText ( helpGridList, vehicles, column, "Vehicles", false, false)
	guiGridListSetItemText ( helpGridList, weapons, column, "Weapons", false, false)
	guiGridListSetItemText ( helpGridList, tips, column, "Tips", false, false)
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
			mainText = guiCreateMemo ( 0.25, 0.3, 0.7, 0.65, "Interstate 69 is a car-based game.\nThere are 2 modes avaiable; Deathmatch and Elimination.\n\nElimination: The last person alive wins the game.\n\nDeathmatch: The person with least deaths when the time is up wins the round.", true, helpTab)
			guiMemoSetReadOnly (mainText, true)
		else
			guiSetText (mainText, "Interstate 69 is a car-based game.\nThere are 2 modes avaiable; Deathmatch and Elimination.\n\nElimination: The last person alive wins the game.\n\nDeathmatch: The person with least deaths when the time is up wins the round.")
		end
	elseif choosenHelp == "Keys" then
		if not ( topic ) then
			topic = guiCreateLabel (0.3, 0.1, 0.5, 0.3, "Keys", true, helpTab)
			guiSetFont ( topic, "sa-gothic" )
		else
			guiSetText (topic, "Keys")
		end
		if not ( mainText ) then
			mainText = guiCreateMemo ( 0.25, 0.3, 0.7, 0.65, "To use the weapons on your vehicle, you use mouse1 and mouse2 for primary and secondary.\n\nAccessories may be used by pressing 'R'.\nNote that armor is passive, and automaticly added when you spawn", true, helpTab)
			guiMemoSetReadOnly (mainText, true)
		else
			guiSetText (mainText, "To use the weapons on your vehicle, you use mouse1 and mouse2 for primary and secondary.\n\nAccessories may be used by pressing 'R'.\nNote that armor is passive, and automaticly added when you spawn")
		end
	elseif choosenHelp == "Spawning" then
		if not ( topic ) then
			topic = guiCreateLabel (0.3, 0.1, 0.5, 0.3, "Spawning", true, helpTab)
			guiSetFont ( topic, "sa-gothic" )
		else
			guiSetText (topic, "Spawning")
		end
		if not ( mainText ) then
			mainText = guiCreateMemo ( 0.25, 0.3, 0.7, 0.65, "When you have choosed your vehicle and weapons, you will automaticly spawn. \nWhen you die you will respawn after a time.\n\nNOTE: when you have been eliminated, you can not respawn.", true, helpTab)
			guiMemoSetReadOnly (mainText, true)
		else
			guiSetText (mainText, "When you have choosed your vehicle and weapons, you will automaticly spawn. \nWhen you die you will respawn after a time.\n\nNOTE: when you have been eliminated, you can not respawn.")
		end
	elseif  choosenHelp == "Vehicles" then
		if not ( topic ) then
			topic = guiCreateLabel (0.3, 0.1, 0.5, 0.3, "Vehicles", true, helpTab)
			guiSetFont ( topic, "sa-gothic" )
		else
			guiSetText (topic, "Vehicles")
		end
		if not ( mainText ) then
			mainText = guiCreateMemo ( 0.25, 0.3, 0.7, 0.65, "When you join a server, you will be moved into a garage where you can choose between several different vehicles.\nThe amount of vehicles you can choose from depends on the server", true, helpTab)
			guiMemoSetReadOnly (mainText, true)
		else
			guiSetText (mainText, "When you join a server, you will be moved into a garage where you can choose between several different vehicles.\nThe amount of vehicles you can choose from depends on the server")
		end
	elseif choosenHelp == "Weapons" then
		if not ( topic ) then
			topic = guiCreateLabel (0.3, 0.1, 0.5, 0.3, "Weapons", true, helpTab)
			guiSetFont ( topic, "sa-gothic" )
		else
			guiSetText (topic, "Weapons")
		end
		if not ( mainText ) then
			mainText = guiCreateMemo ( 0.25, 0.3, 0.7, 0.65, "After you have selected your desired vehicle, you will be able to mount 2 weapons on it, and choose one accessory.\nAfter you have choosed everything, click 'Accept' to leave the garage.", true, helpTab)
			guiMemoSetReadOnly (mainText, true)
		else
			guiSetText (mainText, "After you have selected your desired vehicle, you will be able to mount 2 weapons on it (primary, and secondary), and choose one accessory.\nAfter you have choosed everything, click 'Accept' to leave the garage.")
		end
	elseif choosenHelp == "Tips" then
		if not ( topic ) then
			topic = guiCreateLabel (0.3, 0.1, 0.5, 0.3, "Tips", true, helpTab)
			guiSetFont ( topic, "sa-gothic" )
		else
			guiSetText (topic, "Tips")
		end
		if not ( mainText ) then
			mainText = guiCreateMemo ( 0.25, 0.3, 0.7, 0.65, "When firing SAM missiles (secondary weapon), try to aim a bit ahead of your target.\nPowerfull weapons (example; SAM x8) has longer reload times than less powerful weapons. ", true, helpTab)
			guiMemoSetReadOnly (mainText, true)
		else
			guiSetText (mainText, "When firing SAM missiles (secondary weapon), try to aim a bit ahead of your target.\nPowerfull weapons (example; SAM x8) has longer reload times than less powerful weapons.")
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