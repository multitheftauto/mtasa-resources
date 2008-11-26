index = {}
bases = {}
axieBase = {}
allyBase = {}
lastDmg = 0
maximized = false
mapStopped = false
hasSpawned = false

allyResource = guiCreateStaticImage ( 0.4, 0.02, 0.015, 0.02, "alliebase.png", true)
axieResource = guiCreateStaticImage ( 0.4, 0.05, 0.015, 0.02, "axisbase.png", true)

function menuHelpCreate ()
	if not ( spawnHelp ) then
		spawnHelp = guiCreateMemo(0.25, 0.85, 0.50, 0.13, "Select your class, then click on one of your bases to spawn.\nAllies are blue, and axis are red.\nYou can zoom the map by clicking on it.", true)
	else
		guiSetText(spawnHelp, "Select your class, then click on one of your bases to spawn.\nAllies are blue, and axis are red.\nYou can zoom the map by clicking on it.")
	end
	guiMemoSetReadOnly(spawnHelp, true)
	guiSetAlpha(spawnHelp, 0)
	guiSetVisible(spawnHelp, true)
	addEventHandler("onClientRender", getLocalPlayer(), fadeMenuHelpIn)
end
addCommandHandler("show", menuHelpCreate)

function fadeMenuHelpIn()
	local alpha = guiGetAlpha(spawnHelp)
	local alpha = alpha + 0.01
	if alpha <= 1 then
		guiSetAlpha(spawnHelp, alpha)
	else
		removeEventHandler("onClientRender", getLocalPlayer(), fadeMenuHelpIn)
	end
end

function fadeMenuHelpOut()
	hideHelpTimer = nil
	local function hideMenuHelp()
		local alpha = guiGetAlpha(spawnHelp)
		local alpha = alpha - 0.01
		if alpha >= 0 then
			guiSetAlpha(spawnHelp, alpha)
		else
			removeEventHandler("onClientRender", getLocalPlayer(), hideMenuHelp)
		end
	end
	addEventHandler("onClientRender", getLocalPlayer(), hideMenuHelp)
end
addCommandHandler("hide", fadeMenuHelpOut)

function spawnHelpCreate ()
	if not ( spawnHelp ) then
		spawnHelp = guiCreateMemo(0.25, 0.85, 0.50, 0.13, "You have spawned.\nCapture the bases and stop the enemy team from capturing them!", true)
	else
		guiSetText(spawnHelp, "You have spawned.\nCapture the bases and stop the enemy team from capturing them!")
	end
	guiMemoSetReadOnly(spawnHelp, true)
	guiSetAlpha(spawnHelp, 0)
	guiSetVisible(spawnHelp, true)
	addEventHandler("onClientRender", getLocalPlayer(), fadeMenuHelpIn)
end
addCommandHandler("showspawn", spawnHelpCreate)

function captureHelpCreate ()
if getElementData(getLocalPlayer(), "showHelp") == true then
	if ( hideHelpTimer ) then
		killTimer(hideHelpTimer)
		hideHelpTimer = nil
	end
	if not ( spawnHelp ) then
		spawnHelp = guiCreateMemo(0.25, 0.85, 0.50, 0.13, "Stay within range to capture the base.", true)
	else
		guiSetText(spawnHelp, "Stay within range to capture the base.")
	end
	guiMemoSetReadOnly(spawnHelp, true)
	guiSetAlpha(spawnHelp, 0)
	guiSetVisible(spawnHelp, true)
	addEventHandler("onClientRender", getLocalPlayer(), fadeMenuHelpIn)
	hideHelpTimer = setTimer (fadeMenuHelpOut, 10000, 1)
end
end
addCommandHandler("showcapt", captureHelpCreate)
addEvent("captureHelpCreate", true)
addEventHandler("captureHelpCreate", getRootElement(), captureHelpCreate)

function capturedHelpCreate ()
if getElementData(getLocalPlayer(), "showHelp") == true then
	if ( hideHelpTimer ) then
		killTimer(hideHelpTimer)
		hideHelpTimer = nil
	end
	if not ( spawnHelp ) then
		spawnHelp = guiCreateMemo(0.25, 0.85, 0.50, 0.13, "You have successfully captured a base.\nMake sure the enemy team doesn't steal it now.", true)
	else
		guiSetText(spawnHelp, "You have successfully captured a base.\nMake sure the enemy team doesn't steal it now.")
	end
	guiMemoSetReadOnly(spawnHelp, true)
	guiSetAlpha(spawnHelp, 0)
	guiSetVisible(spawnHelp, true)
	addEventHandler("onClientRender", getLocalPlayer(), fadeMenuHelpIn)
	hideHelpTimer = setTimer (fadeMenuHelpOut, 10000, 1)
end
end
addCommandHandler("showcaptd", capturedHelpCreate)
addEvent("capturedHelpCreate", true)
addEventHandler("capturedHelpCreate", getRootElement(), capturedHelpCreate)

function blockHelpCreate ()
	if ( hideHelpTimer ) then
		killTimer(hideHelpTimer)
		hideHelpTimer = nil
	end
	if not ( spawnHelp ) then
		spawnHelp = guiCreateMemo(0.25, 0.85, 0.50, 0.13, "You have blocked the enemy from capturing the base.", true)
	else
		guiSetText(spawnHelp, "You have blocked the enemy from capturing the base.")
	end
	guiMemoSetReadOnly(spawnHelp, true)
	guiSetAlpha(spawnHelp, 0)
	guiSetVisible(spawnHelp, true)
	addEventHandler("onClientRender", getLocalPlayer(), fadeMenuHelpIn)
	hideHelpTimer = setTimer (fadeMenuHelpOut, 10000, 1)
end
addCommandHandler("showblock", blockHelpCreate)

function blockedHelpCreate ()
	if ( hideHelpTimer ) then
		killTimer(hideHelpTimer)
		hideHelpTimer = nil
	end
	if not ( spawnHelp ) then
		spawnHelp = guiCreateMemo(0.25, 0.85, 0.50, 0.13, "You have been blocked by an enemy, you cant capture this point untill he's gone", true)
	else
		guiSetText(spawnHelp, "You have been blocked by an enemy, you cant capture this point untill he's gone")
	end
	guiMemoSetReadOnly(spawnHelp, true)
	guiSetAlpha(spawnHelp, 0)
	guiSetVisible(spawnHelp, true)
	addEventHandler("onClientRender", getLocalPlayer(), fadeMenuHelpIn)
	hideHelpTimer = setTimer (fadeMenuHelpOut, 10000, 1)
end
addCommandHandler("showblocked", blockedHelpCreate)

function killedHelpCreate ()
	if not ( spawnHelp ) then
		spawnHelp = guiCreateMemo(0.25, 0.85, 0.50, 0.13, "You have been killed. Wait for the spawnmenu to appear.", true)
	else
		guiSetText(spawnHelp, "You have been killed. Wait for the spawnmenu to appear.")
	end
	guiMemoSetReadOnly(spawnHelp, true)
	guiSetAlpha(spawnHelp, 0)
	guiSetVisible(spawnHelp, true)
	addEventHandler("onClientRender", getLocalPlayer(), fadeMenuHelpIn)
end
addCommandHandler("showkilled", killedHelpCreate)

function disableHelp ()
	setElementData(getLocalPlayer(), "showHelp", false)
	xmlNodeSetValue(guiHelpXML, "false")
	xmlSaveFile(guiHelpXML)
end
addCommandHandler("disableguihelp", disableHelp)

function enableHelp ()
	setElementData(getLocalPlayer(), "showHelp", true)
	xmlNodeSetValue(guiHelpXML, "true")
	xmlSaveFile(guiHelpXML)
end
addCommandHandler("enableguihelp", enableHelp)

addEventHandler("onClientPlayerSpawn", getLocalPlayer(), function (team)
if getElementData(getLocalPlayer(), "feigndeath") == true then return end
	if getElementData(getLocalPlayer(), "showHelp") == true then
		if ( hideHelpTimer ) then
			killTimer(hideHelpTimer)
			hideHelpTimer = nil
		end
		spawnHelpCreate ()
		hideHelpTimer = setTimer (fadeMenuHelpOut, 10000, 1)
	end
end)

function captureTable (capture)
capture1 = capture
end
addEvent ("captureTable", true)
addEventHandler ("captureTable", getLocalPlayer(), captureTable)
function teamMenu ()
if not ( teamForm ) then
	--setCameraLookAt (tarX, tarY, tarZ)
	teamForm = guiCreateStaticImage ( 0.15, 0.15, 0.7, 0.7, "bg.png", true, teamForm )
	addEventHandler ("onClientGUIMove", teamForm, function() guiSetPosition (teamForm, 0.15, 0.15, true) end, false )
	addEventHandler ("onClientGUISize", teamForm, function() guiSetSize (teamForm, 0.7, 0.7, true) end, false )
	local page = xmlNodeGetValue(guiHelpXML)
		if page == "true" then
			helpCheck = guiCreateCheckBox ( 0.025, 0.95, 0.17, 0.05, "Show help", true, true, teamForm )
			setElementData(getLocalPlayer(), "showHelp", true)
		elseif page == "false" then
			helpCheck = guiCreateCheckBox ( 0.025, 0.95, 0.17, 0.05, "Show help", false, true, teamForm )
			setElementData(getLocalPlayer(), "showHelp", false)
		else
			helpCheck = guiCreateCheckBox ( 0.025, 0.95, 0.17, 0.05, "Show help", true, true, teamForm )
			setElementData(getLocalPlayer(), "showHelp", true)
			xmlNodeSetValue(guiHelpXML, "true")
			xmlSaveFile(guiHelpXML)
		end
	addEventHandler("onClientGUIClick", helpCheck, function ()
		if guiCheckBoxGetSelected(helpCheck) == true then
			setElementData(getLocalPlayer(), "showHelp", true)
			xmlNodeSetValue(guiHelpXML, "true")
			xmlSaveFile(guiHelpXML)
		else
			setElementData(getLocalPlayer(), "showHelp", false)
			xmlNodeSetValue(guiHelpXML, "false")
			xmlSaveFile(guiHelpXML)
		end
	end, false)
	guiSetAlpha ( teamForm, 0.9 )
	guiSetVisible ( teamForm, true )
	showCursor ( true )
	alliesImage = guiCreateStaticImage ( 0.30, 0.05, 0.4, 0.2, "allies.png", true, teamForm )
	alliesButton = guiCreateStaticImage ( 0.375, 0.27, 0.25, 0.1, "buttonAllies.png", true, teamForm )
	addEventHandler ( "onClientGUIClick", alliesButton, joinAllies, false )
	axisImage = guiCreateStaticImage ( 0.3, 0.45, 0.4, 0.2, "axis.png", true, teamForm )
	axisButton = guiCreateStaticImage ( 0.375, 0.67, 0.25, 0.1, "buttonAxis.png", true, teamForm )
	addEventHandler ( "onClientGUIClick", axisButton, joinAxis, false )
else
	guiSetVisible ( teamForm, true )
	showCursor ( true )
end
	triggerServerEvent ("fetchTable", getLocalPlayer() )
	
end
addCommandHandler ("menu1", teamMenu)

function joinAllies ()
	if source ~= alliesButton then return end
	local allies = getTeamFromName ( "Ally" )
	local axies = getTeamFromName ( "Axis" )
	if getTeamFromName ( "Ally" ) == false then
		--setCameraPosition (allycamX, allycamY, allycamZ)
		--setTimer (setCameraLookAt, 1000, 1, allytarX, allytarY, allytarZ)
		setCameraMatrix( allycamX, allycamY, allycamZ, allytarX, allytarY, allytarZ )
		guiSetVisible ( teamForm, false )
		showCursor ( false )
		setTimer (spawnMenu, 5000, 1, getLocalPlayer())
		triggerServerEvent ("addAlly", getLocalPlayer())
	elseif countPlayersInTeam(allies) < countPlayersInTeam(axies) or countPlayersInTeam(allies) == countPlayersInTeam(axies) then
		--setCameraPosition (allycamX, allycamY, allycamZ)
		--setTimer (setCameraLookAt, 1000, 1, allytarX, allytarY, allytarZ)
		setCameraMatrix( allycamX, allycamY, allycamZ, allytarX, allytarY, allytarZ )
		guiSetVisible ( teamForm, false )
		showCursor ( false )
		setTimer (spawnMenu, 5000, 1, getLocalPlayer())
		triggerServerEvent ("addAlly", getLocalPlayer())
	else
		outputChatBox ("Too many players in selected team")
	end
end

function joinAxis ()
if source ~= axisButton then return end
	local allies = getTeamFromName ( "Ally" )
	local axies = getTeamFromName ( "Axis" )
	if getTeamFromName ( "Axis" ) == false then
		--setCameraPosition (axiecamX, axiecamY, axiecamZ)
		--setTimer (setCameraLookAt, 1000, 1, axietarX, axietarY, axietarZ)
		setCameraMatrix( axiecamX, axiecamY, axiecamZ, axietarX, axietarY, axietarZ )
		guiSetVisible ( teamForm, false )
		showCursor ( false )
		setTimer (spawnMenu, 5000, 1, getLocalPlayer())
		triggerServerEvent ("addAxis", getLocalPlayer())
	elseif countPlayersInTeam(allies) > countPlayersInTeam(axies) or countPlayersInTeam(allies) == countPlayersInTeam(axies) then
		--setCameraPosition (axiecamX, axiecamY, axiecamZ)
		--setTimer (setCameraLookAt, 1000, 1, axietarX, axietarY, axietarZ)
		setCameraMatrix( axiecamX, axiecamY, axiecamZ, axietarX, axietarY, axietarZ )
		guiSetVisible ( teamForm, false )
		showCursor ( false )
		setTimer (spawnMenu, 5000, 1, getLocalPlayer())
		triggerServerEvent ("addAxis", getLocalPlayer())
	else
		outputChatBox ("Too many players in selected team")
	end
end

function spawnMenu ()
	if getElementData(getLocalPlayer(), "showHelp") == true then
		if ( hideHelpTimer ) then
			killTimer(hideHelpTimer)
			hideHelpTimer = nil
		end
		menuHelpCreate()
		hideHelpTimer = setTimer (fadeMenuHelpOut, 10000, 1)
	end
	setTimer (guiSetText, 1000, 1, menuAppearText, "")
	triggerServerEvent ("fetchTable", getLocalPlayer() )
	index[getLocalPlayer()] = 1
if not spawnForm then
	local x, y = guiGetScreenSize()
	spawnForm = guiCreateStaticImage ( 0.15, 0.15, 0.7, 0.7, "bg.png", true )
else
	guiSetVisible (spawnForm, true)
end
	guiSetAlpha ( spawnForm, 0.9 )
	if not map then
		if getElementsByType ("custommap") then
			specialmap = getElementsByType("custommap")
			if isElement(specialmap[1]) then
				specialimage = getElementData(specialmap[1], "file")
			end
				thisResource = getThisResource()
			if ( specialimage ) then
				specialname = getElementData(specialmap[1], "name")
				mapresource = getResourceFromName (specialname)
				mapbase = guiCreateScrollPane ( 0.30, 0.10, 0.675, 0.8, true, spawnForm)
				map1 = guiCreateStaticImage ( 0, 0, 1, 1, "map.png", true, mapbase )
				addEventHandler ( "onClientGUIClick", map1, mapEnlarge, false )
				map = guiCreateStaticImage (0, 0, 1, 1, specialimage, true, map1, mapresource)
			else
				mapbase = guiCreateScrollPane ( 0.30, 0.10, 0.675, 0.8, true, spawnForm)
				map = guiCreateStaticImage ( 0, 0, 1, 1, "map.png", true, mapbase )
			end
		else
			mapbase = guiCreateScrollPane ( 0.30, 0.10, 0.675, 0.8, true, spawnForm)
			map = guiCreateStaticImage ( 0, 0, 1, 1, "map.png", true, mapbase )
		end
		addEventHandler ( "onClientGUIClick", map, mapEnlarge, false )
	end
	if ( accept ) then
		destroyElement ( accept )
		accept = nil
	end
	
		for blipKey, blipValue in ipairs(capture1) do
			local baseX, baseY, baseZ = getElementPosition (blipValue)
			local x3 = ( baseX + 3000 ) / 6000
			local y3 = ( 3000 - baseY ) / 6000
			if getBlipIcon (blipValue) == 0 then
				if (bases[blipKey]) then
					guiStaticImageLoadImage(bases[blipKey], "bases.png")
				else
					bases[blipKey] = guiCreateStaticImage ( x3 - 0.011, y3 - 0.011, 0.02, 0.02, "bases.png", true, map)
				end
				addEventHandler ( "onClientGUIClick", bases[blipKey], function ()
				end, false )
			elseif getBlipIcon (blipValue) == 20 then
				if (bases[blipKey]) then
					guiStaticImageLoadImage(bases[blipKey], "axisbase.png")
				else
				bases[blipKey] = guiCreateStaticImage ( x3 - 0.011, y3 - 0.011, 0.02, 0.02, "axisbase.png", true, map)
				end
				addEventHandler ( "onClientGUIClick", bases[blipKey], function ()
				if getTeamName(getPlayerTeam(getLocalPlayer())) ~= "Axis" then return end
				local baseX1, baseY1, baseZ1 = getElementPosition (capture1[blipKey])
					if ( mapmarker ) then
						destroyElement ( mapmarker )
					end
					if maximized == false then
						mapmarker = guiCreateStaticImage ( x3 - 0.015, y3 - 0.02, 0.030, 0.04, "dot.png", true, map)
					else
						mapmarker = guiCreateStaticImage ( x3 - 0.0075, y3 - 0.01, 0.015, 0.02, "dot.png", true, map)
					end 
					if getTeamName(getPlayerTeam(getLocalPlayer())) == "Axis" then
						if ( accept ) then 
							guiBringToFront ( accept ) 
						else
							accept = guiCreateStaticImage ( 0.825, 0.915, 0.15, 0.075, "buttonAccept.png", true, spawnForm )
							addEventHandler ("onClientGUIClick", accept, function (accept)
								triggerServerEvent ("spawn", getLocalPlayer(), baseX1, baseY1, baseZ1-7, index )
								setTimer (hideSpawnMenu, 500, 1)
								--toggleCameraFixedMode ( false )
								setCameraTarget ( getLocalPlayer() )
								stopFollow ()
							end, false )
						end
					else
						if ( accept ) then
							destroyElement ( accept )
							accept = nil
						end
					end
				end, false )
			elseif getBlipIcon (blipValue) == 30 then
				if (bases[blipKey]) then
					guiStaticImageLoadImage(bases[blipKey], "alliebase.png")
				else
				bases[blipKey] = guiCreateStaticImage ( x3 - 0.011, y3 - 0.011, 0.02, 0.02, "alliebase.png", true, map)
				end
				addEventHandler ( "onClientGUIClick", bases[blipKey], function ()
				if getTeamName(getPlayerTeam(getLocalPlayer())) ~= "Ally" then return end
				local baseX1, baseY1, baseZ1 = getElementPosition (capture1[blipKey])
					if ( mapmarker ) then
						destroyElement ( mapmarker )
					end
					if maximized == false then
						mapmarker = guiCreateStaticImage ( x3 - 0.015, y3 - 0.02, 0.030, 0.04, "dot.png", true, map)
					else
						mapmarker = guiCreateStaticImage ( x3 - 0.0075, y3 - 0.01, 0.015, 0.02, "dot.png", true, map)
					end
					if getTeamName(getPlayerTeam(getLocalPlayer())) == "Ally" then
						if ( accept ) then 
							destroyElement ( accept ) 
						end
							accept = guiCreateStaticImage ( 0.825, 0.915, 0.15, 0.075, "buttonAccept.png", true, spawnForm )
							addEventHandler ("onClientGUIClick", accept, function (accept)
								triggerServerEvent ("spawn", getLocalPlayer(), baseX1, baseY1, baseZ1-7, index )
								setTimer (hideSpawnMenu, 500, 1)
								--toggleCameraFixedMode ( false )
								setCameraTarget ( getLocalPlayer() )
								stopFollow ()
							end, false )
					else
						if ( accept ) then
							destroyElement ( accept )
							accept = nil
						end
					end
				end, false )
			else
				outputChatBox ("poo")
			end
		end

		local x3 = ( allieX + 3000 ) / 6000
		local y3 = ( 3000 - allieY ) / 6000
		if not ( allieMarker ) then
			allieMarker = guiCreateStaticImage ( x3 - 0.015, y3 - 0.015, 0.029, 0.03, "alliebase.png", true, map)
		end

		addEventHandler ( "onClientGUIClick", allieMarker, function ()
		if getTeamName(getPlayerTeam(getLocalPlayer())) ~= "Ally" then return end
			if source ~= allieMarker then return end
			if ( mapmarker ) then
				destroyElement ( mapmarker )
			end
			if maximized == false then
				mapmarker = guiCreateStaticImage ( x3 - 0.015, y3 - 0.02, 0.030, 0.04, "dot.png", true, map)
			else
				mapmarker = guiCreateStaticImage ( x3 - 0.015, y3 - 0.02, 0.015, 0.02, "dot.png", true, map)
			end
			if getTeamName(getPlayerTeam(getLocalPlayer())) == "Ally" then
				if ( accept ) then 
					destroyElement ( accept ) 
				end
				accept = guiCreateStaticImage ( 0.825, 0.915, 0.15, 0.075, "buttonAccept.png", true, spawnForm )
				addEventHandler ("onClientGUIClick", accept, function (accept)
					local baseX1, baseY1, baseZ1 = allieX, allieY, allieZ
					triggerServerEvent ("spawn", getLocalPlayer(), baseX1, baseY1, baseZ1, index )
					setTimer (hideSpawnMenu, 500, 1)
					--toggleCameraFixedMode ( false )
					setCameraTarget ( getLocalPlayer() )
					stopFollow ()
				end, false )
			end
		end, false )
		
		
		

		local x3 = ( axieX + 3000 ) / 6000
		local y3 = ( 3000 - axieY ) / 6000
		if not ( axieMarker ) then
			axieMarker = guiCreateStaticImage ( x3 - 0.015, y3 - 0.015, 0.029, 0.03, "axisbase.png", true, map)
		end
		addEventHandler ( "onClientGUIClick", axieMarker, function ()
		if getTeamName(getPlayerTeam(getLocalPlayer())) ~= "Axis" then return end
			if source ~= axieMarker then return end
			if ( mapmarker ) then
				destroyElement ( mapmarker )
			end
			if maximized == false then
				mapmarker = guiCreateStaticImage ( x3 - 0.015, y3 - 0.02, 0.030, 0.04, "dot.png", true, map)
			else
				mapmarker = guiCreateStaticImage ( x3 - 0.015, y3 - 0.02, 0.015, 0.02, "dot.png", true, map)
			end
			if getTeamName(getPlayerTeam(getLocalPlayer())) == "Axis" then
				if ( accept ) then 
					destroyElement ( accept ) 
				end
				accept = guiCreateStaticImage ( 0.825, 0.915, 0.15, 0.075, "buttonAccept.png", true, spawnForm )
				addEventHandler ("onClientGUIClick", accept, function (accept)
					local baseX1, baseY1, baseZ1 = axieX, axieY, axieZ
					triggerServerEvent ("spawn", getLocalPlayer(), baseX1, baseY1, baseZ1, index )
					setTimer (hideSpawnMenu, 500, 1)
					--toggleCameraFixedMode ( false )
					setCameraTarget ( getLocalPlayer() )
					stopFollow ()
				end, false )
			end
		end, false )
	
	
	prevChar = guiCreateStaticImage ( 0.05, 0.1, 0.05, 0.05, "previous.png", true, spawnForm )
	addEventHandler ( "onClientGUIClick", prevChar, previousChar, false )
	nextChar = guiCreateStaticImage ( 0.20, 0.1, 0.05, 0.05, "next.png", true, spawnForm )
	addEventHandler ( "onClientGUIClick", nextChar, nextCharacter, false )
	if getTeamName(getPlayerTeam(getLocalPlayer())) == "Ally" then
		if index[getLocalPlayer()] == 1 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "allysoldier.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "allysoldier.png")
			end
			if ( description1 ) then
				destroyElement ( description1 )
				description1 = nil
			end
				description1 = guiCreateLabel ( 0.033, 0.600, 0.25, 0.50, "With his accurate automatic weapon, a soldier is perfect for assaulting enemy bases. M4, Desert Eagle, Grenades and Armor are standard equipment", true, spawnForm )
				guiLabelSetColor (description1, 255, 255, 255)
				guiLabelSetHorizontalAlign ( description1, "left", true )
		end
	elseif getTeamName(getPlayerTeam(getLocalPlayer())) == "Axis" then
		if index[getLocalPlayer()] == 1 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "axissoldier.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "axissoldier.png")
			end
			if ( description1 ) then
				destroyElement ( description1 )
				description1 = nil
			end
				description1 = guiCreateLabel ( 0.033, 0.600, 0.25, 0.50, "With his accurate automatic weapon, a soldier is perfect for assaulting enemy bases. AK47, Desert Eagle, Grenades and Armor are standard equipment", true, spawnForm )
				guiLabelSetColor (description1, 255, 255, 255)
				guiLabelSetHorizontalAlign ( description1, "left", true )
		end
	end
	
	showCursor ( true )
end
addCommandHandler ("menu", spawnMenu)

function testimage ()
	resource = getResourceFromName ("BFruins")
	outputChatBox ("creating custom map")
	specialmap = getElementsByType("custommap")
	specialimage = getElementData(specialmap[1], "file")
	mapimage = guiCreateStaticImage (0.2, 0.4, 0.5, 0.5, specialimage, true, resource)
end
addCommandHandler ("map1", testimage)

function nextCharacter ( nextChar )
	if ( description1 ) then
		destroyElement ( description1 )
		description1 = nil
	end
	if index[getLocalPlayer()] == 5 then
		index[getLocalPlayer()] = 0
	end
	index[getLocalPlayer()] = index[getLocalPlayer()] + 1
	if getTeamName(getPlayerTeam(getLocalPlayer())) == "Ally" then
		if index[getLocalPlayer()] == 1 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "allysoldier.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "allysoldier.png")
			end
			infoText = "With his accurate automatic weapon, a soldier is perfect for assaulting enemy bases. M4, Desert Eagle, Grenades and Armor are standard equipment"
		elseif index[getLocalPlayer()] == 2 then
			if not (character) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "allyscout.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "allyscout.png")
			end
			infoText = "Armed with a highly accurate sniper rifle, this soldier is the ultimate choice for defence."
		elseif index[getLocalPlayer()] == 3 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "allymedic.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "allymedic.png")
			end
			infoText = "Medics, what would the world be without them? This is the most important soldier on the battlefield, without them - you have lost the war."
		elseif index[getLocalPlayer()] == 4 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "allyantitank.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "allyantitank.png")
			end
			infoText = "This heavily armed soldier is the only choice when it comes to taking out an enemy tank. Armed with a massive flamethrower, this guy laughs death in the face."
		elseif index[getLocalPlayer()] == 5 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "allymechanic.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "allymechanic.png")
			end
			infoText = "The mechanic is the team's vehicle supplier. He can repair vehicles on the battlefield, and request new ones. Don't leave this guy behind - he's actually quite useful."
		end
	elseif getTeamName(getPlayerTeam(getLocalPlayer())) == "Axis" then
		if index[getLocalPlayer()] == 1 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "axissoldier.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "axissoldier.png")
			end
			infoText = "With his accurate automatic weapon, a soldier is perfect for assaulting enemy bases. AK47, Desert Eagle, Grenades and Armor are standard equipment"
		elseif index[getLocalPlayer()] == 2 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "axisscout.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "axisscout.png")
			end
			infoText = "Armed with a highly accurate sniper rifle, this soldier is the ultimate choice for defence."
		elseif index[getLocalPlayer()] == 3 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "axismedic.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "axismedic.png")
			end
			infoText = "Medics, what would the world be without them? This is the most important soldier on the battlefield, without them - you have lost the war."
		elseif index[getLocalPlayer()] == 4 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "axisantitank.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "axisantitank.png")
			end
			infoText = "This heavily armed soldier is the only choice when it comes to taking out an enemy tank. Armed with a massive flamethrower, this guy laughs death in the face."
		elseif index[getLocalPlayer()] == 5 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "axismechanic.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "axismechanic.png")
			end
			infoText = "The mechanic is the team's vehicle supplier. He can repair vehicles on the battlefield, and request new ones. Don't leave this guy behind - he's actually quite useful."
		end
	end
	description1 = guiCreateLabel ( 0.033, 0.600, 0.25, 0.50, infoText, true, spawnForm )
	guiLabelSetColor (description1, 255, 255, 255)
	guiLabelSetHorizontalAlign ( description1, "left", true )
end

function previousChar ( prevChar )
	if ( description1 ) then
		destroyElement ( description1 )
		description1 = nil
	end
	
	if index[getLocalPlayer()] == 1 then
		index[getLocalPlayer()] = 6
	end
	index[getLocalPlayer()] = index[getLocalPlayer()] - 1
	if getTeamName(getPlayerTeam(getLocalPlayer())) == "Ally" then
		if index[getLocalPlayer()] == 1 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "allysoldier.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "allysoldier.png")
			end
			infoText = "With his accurate automatic weapon, a soldier is perfect for assaulting enemy bases. M4, Desert Eagle, Grenades and Armor are standard equipment"
		elseif index[getLocalPlayer()] == 2 then
			if not (character) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "allyscout.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "allyscout.png")
			end
			infoText = "Armed with a highly accurate sniper rifle, this soldier is the ultimate choice for defence."
		elseif index[getLocalPlayer()] == 3 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "allymedic.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "allymedic.png")
			end
			infoText = "Medics, what would the world be without them? This is the most important soldier on the battlefield, without them - you have lost the war."
		elseif index[getLocalPlayer()] == 4 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "allyantitank.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "allyantitank.png")
			end
			infoText = "This heavily armed soldier is the only choice when it comes to taking out an enemy tank. Armed with a massive flamethrower, this guy laughs death in the face."
		elseif index[getLocalPlayer()] == 5 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "allymechanic.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "allymechanic.png")
			end
			infoText = "The mechanic is the team's vehicle supplier. He can repair vehicles on the battlefield, and request new ones. Don't leave this guy behind - he's actually quite useful."
		end
	elseif getTeamName(getPlayerTeam(getLocalPlayer())) == "Axis" then
		if index[getLocalPlayer()] == 1 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "axissoldier.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "axissoldier.png")
			end
			infoText = "With his accurate automatic weapon, a soldier is perfect for assaulting enemy bases. AK47, Desert Eagle, Grenades and Armor are standard equipment"
		elseif index[getLocalPlayer()] == 2 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "axisscout.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "axisscout.png")
			end
			infoText = "Armed with a highly accurate sniper rifle, this soldier is the ultimate choice for defence."
		elseif index[getLocalPlayer()] == 3 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "axismedic.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "axismedic.png")
			end
			infoText = "Medics, what would the world be without them? This is the most important soldier on the battlefield, without them - you have lost the war."
		elseif index[getLocalPlayer()] == 4 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "axisantitank.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "axisantitank.png")
			end
			infoText = "This heavily armed soldier is the only choice when it comes to taking out an enemy tank. Armed with a massive flamethrower, this guy laughs death in the face."
		elseif index[getLocalPlayer()] == 5 then
			if not ( character ) then
				character = guiCreateStaticImage ( 0.035, 0.185, 0.25, 0.40, "axismechanic.png", true, spawnForm )
			else
				guiStaticImageLoadImage(character, "axismechanic.png")
			end
			infoText = "The mechanic is the team's vehicle supplier. He can repair vehicles on the battlefield, and request new ones. Don't leave this guy behind - he's actually quite useful."
		end
	end
	description1 = guiCreateLabel ( 0.033, 0.600, 0.25, 0.50, infoText, true, spawnForm )
	guiLabelSetColor (description1, 255, 255, 255)
	guiLabelSetHorizontalAlign ( description1, "left", true )
end

function mapEnlarge ()
	if (map1) then
		local x, y = guiGetSize (map1, true)
		if math.ceil(x*10) ~= 14 and math.ceil(y*10) ~= 17 then
			maximized = true
			guiSetSize (map1, 1.4, 1.7, true)
			for blipKey, blipValue in ipairs(bases)do
				guiSetSize(blipValue, 0.015, 0.015, true)
			end
			guiSetSize(allieMarker, 0.0145, 0.015, true)
			guiSetSize(axieMarker, 0.0145, 0.015, true)
		else
			maximized = false
			guiSetSize (map1, 1, 1, true)
			guiSetSize(allieMarker, 0.029, 0.03, true)
			guiSetSize(axieMarker, 0.029, 0.03, true)
			for blipKey, blipValue in ipairs(bases) do 
				guiSetSize(blipValue, 0.02, 0.02, true)
			end
		end
	else
		local x, y = guiGetSize (map, true)
		if math.ceil(x*10) ~= 14 and math.ceil(y*10) ~= 17 then
			maximized = true
			guiSetSize (map, 1.4, 1.7, true)
			guiSetSize(allieMarker, 0.0145, 0.015, true)
			guiSetSize(axieMarker, 0.0145, 0.015, true)
			for blipKey, blipValue in ipairs(bases) do
				guiSetSize(blipValue, 0.015, 0.015, true)
			end
		else
			maximized = false
			guiSetSize (map, 1, 1, true)
			guiSetSize(allieMarker, 0.029, 0.03, true)
			guiSetSize(axieMarker, 0.029, 0.03, true)
			for blipKey, blipValue in ipairs(bases) do
				guiSetSize(blipValue, 0.02, 0.02, true)
			end
		end
	end
	if ( mapmarker ) then
		if maximized == false then
			guiSetSize ( mapmarker, 0.030, 0.04, true )
		else
			guiSetSize ( mapmarker, 0.015, 0.02, true )
		end
	end
end

function hideSpawnMenu ()
	if ( mapmarker ) then
		destroyElement ( mapmarker )
		mapmarker = nil
	end
	for key, value in ipairs(capture1) do
		destroyElement(value)
	end
	guiSetVisible ( spawnForm, false )
	showCursor ( false )
end
addCommandHandler ("hidemenu", hideSpawnMenu)

addEventHandler ("onClientPlayerDamage", getLocalPlayer(), function ( attacker, weapon, bodypart )
	if getElementData (getLocalPlayer(), "spawnProtection") == true then
		cancelEvent()
	else
		if ( lastDmg > getTickCount() ) then return end
		lastDmg = getTickCount() + 2000
		if bodypart == 9 then
			displayGUItextToPlayer(0.45, 0.3, "You got shot in the head!", "default-bold-small", 255, 0, 0, 3000)
		end
	end
end )

addEventHandler("onClientPlayerSpawn", getLocalPlayer(), function ()
	if hasSpawned == false then
		hasSpawned = true
	end
	if mapStopped == true then
		mapStopped = false
	end
end)

addEventHandler ("onClientPlayerWasted", getLocalPlayer(), function (attacker, weapon, bodypart)
if hasSpawned == false then return end
if mapStopped == true then return end
if getElementData(getLocalPlayer(), "feigndeath") == true then return end
	if getElementData(getLocalPlayer(), "showHelp") == true then
		if ( hideHelpTimer ) then
			killTimer(hideHelpTimer)
			hideHelpTimer = nil
		end
		killedHelpCreate ()
		hideHelpTimer = setTimer (fadeMenuHelpOut, 10000, 1)
	end
	if not ( menuAppearText ) then
		menuAppearText = guiCreateLabel ( 0.3, 0.3, 0, 0, "", true )
	end
	guiSetFont (menuAppearText, "sa-header")
	guiLabelSetColor ( menuAppearText, 255, 255, 255, 255 )
	menuCountDown = tonumber(respawnMe1) / 1000
	setTimer (spawnMenu, tonumber(respawnMe1), 1, getLocalPlayer() )
	setTimer (triggerServerEvent, tonumber(respawnMe1) - 3000, 1, "fetchTable", getLocalPlayer() )
	setTimer (aMenuCountDown, 1000, tonumber(menuCountDown), getLocalPlayer())
	setTimer(hideMenuText, tonumber(respawnMe1) + 1000, 1)
end )

function hideMenuText()
	guiSetText (menuAppearText, "")
	destroyElement(menuAppearText)
	menuAppearText = nil
end

function aMenuCountDown ()
	menuCountDown = menuCountDown - 1
	guiSetText (menuAppearText, "Spawnmenu will appear in: " ..menuCountDown)
	guiSetSize ( menuAppearText, guiLabelGetTextExtent ( menuAppearText ), guiLabelGetFontHeight ( menuAppearText ) + 26, false )
end

function setTimeStatic ()
	setTime(tonumber(splitString[1]),tonumber(splitString[2]))
end
addCommandHandler("testtime", setTimeStatic)
function axisWin ()
	--toggleCameraFixedMode ( true )
	--setTimer (setCameraPosition, 100, 1, allycamX, allycamY, allycamZ)
	--setTimer (setCameraLookAt, 500, 1, allytarX, allytarY, allytarZ)
	setCameraMatrix( allycamX, allycamY, allycamZ, allytarX, allytarY, allytarZ )
	setTimer (axisWinBoom, 1000, 1)

end
addCommandHandler("axiswin", axisWin)
addEvent("axisWin", true)
addEventHandler("axisWin", getRootElement(), axisWin)

function axisWinBoom ()
	setTimer (createExplosion, 50, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,50), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 100, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 200, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 300, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 400, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 500, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 600, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 700, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 800, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 900, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 1000, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 1500, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 2000, 1, allytarX + math.random(-30,53), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	
	setTimer (createExplosion, 2500, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 2600, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 2700, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 2800, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 2900, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3000, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3100, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3200, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3300, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3400, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3500, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3600, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3700, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3800, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3900, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 4000, 1, allytarX + math.random(-30,30), allytarY + math.random(-30,30), allytarZ, 6, true, -1.0, false)
end

function allyWin ()
	--toggleCameraFixedMode ( true )
	--setTimer (setCameraPosition, 100, 1, axiecamX, axiecamY, axiecamZ)
	--setTimer (setCameraLookAt, 500, 1, axietarX, axietarY, axietarZ)
	setCameraMatrix( axiecamX, axiecamY, axiecamZ, axietarX, axietarY, axietarZ )
	setTimer (allyWinBoom, 1000, 1)
end
addCommandHandler("allywin", allyWin)
addEvent("allyWin", true)
addEventHandler("allyWin", getRootElement(), allyWin)

function allyWinBoom ()
	setTimer (createExplosion, 50, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 100, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 200, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 300, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 400, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 500, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 600, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 700, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 800, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 900, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 1000, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 1500, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 2000, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	
	setTimer (createExplosion, 2500, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 2600, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 2700, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 2800, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 2900, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3000, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3100, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3200, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3300, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3400, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3500, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3600, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3700, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3800, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 3900, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
	setTimer (createExplosion, 4000, 1, axietarX + math.random(-30,30), axietarY + math.random(-30,30), axietarZ, 6, true, -1.0, false)
end

function onTheMapStop()
	mapStopped = true
	for k,v in ipairs(bases) do
		destroyElement(v)
	end
	for k,v in pairs(capture1) do
		destroyElement(v)
	end
	destroyElement(allieMarker)
	allieMarker = nil
	destroyElement(axieMarker)
	axieMarker = nil
	
	if ( map ) then
		destroyElement(map)
		map = nil
	end
	if ( map1 ) then
		destroyElement(map1)
		map1 = nil
	end
	if ( mapbase ) then
		destroyElement(mapbase)
		mapbase = nil
	end
	
index = {}
bases = {}
axieBase = {}
allyBase = {}
lastDmg = 0
maximized = false
end
addEvent("onTheMapStop", true)
addEventHandler("onTheMapStop", getRootElement(), onTheMapStop)


function readMapData()
		allieSpawn = getElementsByType ("baseAllies")
		allieX = getElementData (allieSpawn[1], "posX")
		allieY = getElementData (allieSpawn[1], "posY")
		allieZ = getElementData (allieSpawn[1], "posZ")

		axieSpawn = getElementsByType ("baseAxies")
		axieX = getElementData (axieSpawn[1], "posX")
		axieY = getElementData (axieSpawn[1], "posY")
		axieZ = getElementData (axieSpawn[1], "posZ")

if maptime1 then
	splitString = split(maptime1, string.byte(':'))
	setTime(tonumber(splitString[1]),tonumber(splitString[2]))
	setTimer (setTimeStatic, 900, 0 )
end

posX = camera1[1]
posY = camera1[2]
posZ = camera1[3]
tarX = camera1[4]
tarY = camera1[5]
tarZ = camera1[6]

allycamX = allycam1[1]
allycamY = allycam1[2]
allycamZ = allycam1[3]
allytarX = allycam1[4]
allytarY = allycam1[5]
allytarZ = allycam1[6]

axiecamX = axiecam1[1]
axiecamY = axiecam1[2]
axiecamZ = axiecam1[3]
axietarX = axiecam1[4]
axietarY = axiecam1[5]
axietarZ = axiecam1[6]

--toggleCameraFixedMode ( true )
--setTimer (setCameraPosition, 1000, 1, posX, posY, posZ)
setTimer (setCameraMatrix, 1000, 1, posX, posY, posZ, tarX, tarY, tarZ)
setTimer (teamMenu, 2000, 1 )
end
menuAppearText = guiCreateLabel ( 0.3, 0.3, 0, 0, "", true )
guiHelpXML = xmlLoadFile("guihelp.xml")
if not guiHelpXML then
	guiHelpXML = xmlCreateFile("guihelp.xml", "help")
end

function onTheMapStart(respawnMe, maptime, camera, allycam, axiecam)
	camera1 = camera
	allycam1 = allycam
	axiecam1 = axiecam
	maptime1 = maptime
	respawnMe1 = respawnMe
	setTimer (readMapData, 2000, 1 )
	setTimer (fadeCamera, 400, 1, true)
end
addEvent("onTheMapStart", true)
addEventHandler("onTheMapStart", getRootElement(), onTheMapStart)

function isReady(resource)
	triggerServerEvent ("iAmReady", getLocalPlayer())
end
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), isReady)