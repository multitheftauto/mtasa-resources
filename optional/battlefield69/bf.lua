
root = getRootElement()
allyBlip = {}
axisBlip = {}
id = {}
flagpole = {}
flag = {}
allyFlag = {}
allyFlag1 = {}
axisFlag = {}
axisFlag1 = {}
lowerFlag = {}
--lowerAxisFlag = {}
--lowerAllyFlag = {}
--captured = {}
--raiseTheFlag = {}
capture = {}
skinID = {}
scanning = {}
samsite = {}
samcol = {}
airPlane = {}
airplane1 = {}
daChute = {}
daCar = {}
carX = {}
carY = {}
carZ = {}
allyCapt = 100
axisCapt = 100
lastDmg = 0
lastEvent = 0
theEar = {}
pot = {}
timer = {}
currentuse = {}
flashBlip = {}
mapRunning = false

--ADD RELOAD TO HUNTER AND HYDRA!
function onMapLoad ( name )
	setTimer (createBigAssEar, 5000, 1)
	currentmap = call(getResourceFromName"mapmanager","getRunningGamemodeMap")
	maxscore = get(getResourceName(currentmap)..".#maxscore")
	respawnMe = get(getResourceName(currentmap)..".#respawntime")
	protectMe = get(getResourceName(currentmap)..".spawnprotection")
	FF = get(getResourceName(currentmap)..".friendlyfire")
	camera = get(getResourceName(currentmap)..".camera")
	allycam = get(getResourceName(currentmap)..".alliescam")
	axiecam = get(getResourceName(currentmap)..".axiescam")

	local mapweather = get(getResourceName(currentmap)..".#weather")
	if mapweather then
		setWeather (mapweather)
	end
	
	if not getTeamFromName("Axis") then
		Axis = createTeam ("Axis", 255,0,0)
	end
	if not getTeamFromName("Ally") then
		Ally = createTeam ("Ally", 0,0,255)
	end

	if ( tonumber(FF) == 1 ) then
		local allTeams = getElementsByType ( "team" )
		for index, theTeam in ipairs(allTeams) do
              setTeamFriendlyFire ( theTeam, false )
		end
	else
		local allTeams = getElementsByType ( "team" )
		for index, theTeam in ipairs(allTeams) do
              setTeamFriendlyFire ( theTeam, true )
		end
	end
	if mapRunning == true then
		currentmap = call(getResourceFromName"mapmanager","getRunningGamemodeMap")
		respawnMe = get(getResourceName(currentmap)..".#respawntime")
		maptime = get(getResourceName(currentmap)..".#time")
		camera = get(getResourceName(currentmap)..".camera")
		allycam = get(getResourceName(currentmap)..".alliescam")
		axiecam = get(getResourceName(currentmap)..".axiescam")
		setTimer (triggerClientEvent, 2000, 1, getRootElement(),"onTheMapStart", getRootElement(), respawnMe, maptime, camera, allycam, axiecam)
	else
		mapRunning = true
	end
	if not ( allyCaptureDisplay ) then
		allyCaptureDisplay = textCreateDisplay ()
		allyCaptureText = textCreateTextItem ( ""..allyCapt.."/"..tonumber(maxscore).."", 0.425, 0.017, "medium", 0, 0, 255, 255, 1.5, "left" )
		textDisplayAddText ( allyCaptureDisplay, allyCaptureText )
	end
	
	if not ( axisCaptureDisplay ) then
		axisCaptureDisplay = textCreateDisplay ()
		axisCaptureText = textCreateTextItem ( ""..axisCapt.."/"..tonumber(maxscore).."", 0.425, 0.049, "medium", 255, 0, 0, 255, 1.5, "left" )
		textDisplayAddText ( axisCaptureDisplay, axisCaptureText )
	end

	allieSpawn = getElementsByType ("baseAllies")
	allieX = getElementData (allieSpawn[1], "posX")
	allieY = getElementData (allieSpawn[1], "posY")
	allieZ = getElementData (allieSpawn[1], "posZ")
	allieSpawnBlip = createBlip (allieX, allieY, allieZ, 30)
	
	axieSpawn = getElementsByType ("baseAxies")
	axieX = getElementData (axieSpawn[1], "posX")
	axieY = getElementData (axieSpawn[1], "posY")
	axieZ = getElementData (axieSpawn[1], "posZ")
	axieSpawnBlip = createBlip (axieX, axieY, axieZ, 20)
	
	samsites = getElementsByType ("antiair")
		for k,v in ipairs (samsites) do
			local x = getElementData (v, "posX")
			local y = getElementData (v, "posY")
			local z = getElementData (v, "posZ")
			local rot = getElementData (v, "rotX")
			myAA = k
			samsite[k] = createObject (3267, x, y, z, rot)
			samcol[k] = createColCircle (x, y, 2)
			addEventHandler ("onColShapeHit", samcol[k], function ( source )
				if isPedInVehicle(source) then return else
				outputChatBox ("Press 'R' to mount the Anti-Air gun", source)
				myAA = k
				end
			end)
			addEventHandler("onColShapeLeave", samcol[k], function ( thePlayer )
				triggerClientEvent(thePlayer,"doSetFreecamDisabled", getRootElement(), dontChangeFixedMode)
			end)
		end
		
		updateScore = setTimer (checkBases, 2000, 0)
		
		bases = getElementsByType("captureBase")
	for k,v in ipairs(getElementsByType("captureBase")) do
		local x = getElementData (v, "posX")
		local y = getElementData (v, "posY")
		local z = getElementData (v, "posZ")
		local id = getElementData (v, "name")
			mytimer = k
			flagpole[k] = createObject ( 1308, x + 4, y, z +10, 0, 180, 180 ) --pole
			local px, py, pz = getElementPosition(flagpole[k])
			local pz = pz -14
			flag[k] = createObject ( 11245, x + 4.5, y, z + 8, 0, 290, 0 ) --flag
			allyFlag[k] = createObject ( 2047, x + 5, y, pz )
			allyFlag1[k] = createObject ( 2047, x + 5, y, pz, 0,0,180 )
			axisFlag[k] = createObject ( 2048, x + 5, y, pz )
			axisFlag1[k] = createObject ( 2048, x + 5, y, pz, 0,0,180 )
			lowerFlag[k] = createColCircle ( x +4, y, 4 ) --circle
			capture[k] = createBlipAttachedTo (flagpole[k], 0, 2, 255, 255, 255, 255, root )
			addEventHandler ("onColShapeHit", lowerFlag[k], function (source) 
				if getElementType(source) ~= "player" then return end
				if isPedInVehicle(source) then return end
				if getElementData(lowerFlag[k], "blocker") ~= false then
				if isElementWithinColShape(getElementData(lowerFlag[k], "blocker"), lowerFlag[k]) == true and getElementData(lowerFlag[k], "blocker") ~= source then 
					local blocker = getElementData(lowerFlag[k], "blocker")
					outputDebugString ("Capture point "..id.." is blocked by "..getClientName(blocker).." !")
					else 
						removeElementData(lowerFlag[k], "blocker") 
				end
				end
				if getElementData(lowerFlag[k], "inuse") ~= true then
				setElementData (lowerFlag[k], "inuse", true )
				setElementData (source, "entered", true )
				captureTeam = getPlayerTeam(source)
				setElementData(lowerFlag[k], "hisTeam", captureTeam)
				local x, y, z = getElementPosition(flagpole[k]) 
				local x1, y1, z1 = getElementPosition(flag[k]) 
				local z2 = z -14 	
				local distance = z1 - z2
				local time = distance / 10 * 10000
					if time == 0 then
						local x, y, z = getElementPosition(flagpole[k])
						local z2 = z -14
						local distance = z - z2
						local time = distance / 10 * 10000
						if time == 0 then
								captureZone(source)
						else
								local allyX, allyY, allyZ = getElementPosition(allyFlag[k])
								local axisX, axisY, axisZ = getElementPosition(axisFlag[k])
								if getTeamName(getPlayerTeam(source)) == "Ally" and allyZ ~= z and axisZ == z2 then
									local x, y, z = getElementPosition(flagpole[k])
									local x1, y1, z1 = getElementPosition(allyFlag[k])
									local z2 = z -14
									local distance = z - z1
									local time = distance / 10 * 10000
									triggerClientEvent(source, "displayGUItext", source, 0.45, 0.3, "Capturing the " ..id.. "", "default-bold-small", 255, 255, 255, 3000)
									moveObject ( allyFlag[k], time, x + 1, y, z )
									moveObject ( allyFlag1[k], time, x + 1, y, z )
									setBlipColor ( capture[k], 0, 0, 255, 255)
									if getBlipIcon(capture[k]) == 20 then
										destroyElement(capture[k])
										capture[k] = createBlipAttachedTo (flagpole[k], 0, 2, 255, 255, 255, 255 )
									end
									triggerClientEvent (source, "captureProgressUp", source, time)
									timer[k] = setTimer ( captureZone, time, 1, source, k, id )
									currentuse[k] = setTimer ( setElementData, time-100, 1, lowerFlag[k], "inuse", false )
									triggerClientEvent (root, "captureTable", root, capture)
								elseif getTeamName(getPlayerTeam(source)) == "Axis" and allyZ ~= z2 then
									local x, y, z = getElementPosition(flagpole[k])
									local x1, y1, z1 = getElementPosition(allyFlag[k])
									local z2 = z -14
									local distance = z1 - z2
									local time = distance / 10 * 10000
									triggerClientEvent (source, "captureHelpCreate", source)
									triggerClientEvent(getRootElement(), "displayGUItextAll", getRootElement(), ""..getClientName(source).." has assaulted the " ..id.. "!", 255, 0, 0)
									moveObject ( allyFlag[k], time, x + 1, y, z2 )
									moveObject ( allyFlag1[k], time, x + 1, y, z2 )
									setBlipColor ( capture[k], 0, 255, 0, 255)
									triggerClientEvent (source, "captureProgressDown", source, time)
									timer[k] = setTimer ( triggerEvent, time, 1, "onColShapeHit", lowerFlag[k], source )
									currentuse[k] = setTimer ( setElementData, time-100, 1, lowerFlag[k], "inuse", false )
								elseif getTeamName(getPlayerTeam(source)) == "Axis" and axisZ == z and getBlipIcon(capture[k]) ~= 20 then
									isCaptured = setTimer ( captureZone, 1000, 1, source, k )
								elseif getTeamName(getPlayerTeam(source)) == "Axis" and axisZ ~= z and allyZ == z2 then
									local x, y, z = getElementPosition(flagpole[k])
									local x1, y1, z1 = getElementPosition(axisFlag[k])
									local z2 = z -14
									local distance = z - z1
									local time = distance / 10 * 10000
									triggerClientEvent(source, "displayGUItext", source, 0.45, 0.3, "Capturing the " ..id.. "", "default-bold-small", 255, 255, 255, 3000)
									setBlipColor ( capture[k], 255, 0, 0, 255)
									moveObject ( axisFlag[k], time, x + 1, y, z )
									moveObject ( axisFlag1[k], time, x + 1, y, z )
									if getBlipIcon(capture[k]) == 30 then
										destroyElement(capture[k])
										capture[k] = createBlipAttachedTo (flagpole[k], 0, 2, 255, 255, 255, 255 )
									end
									triggerClientEvent (source, "captureProgressUp", source, time)
									timer[k] = setTimer ( captureZone, time, 1, source, k, id )
									currentuse[k] = setTimer ( setElementData, time-100, 1, lowerFlag[k], "inuse", false )
									triggerClientEvent (root, "captureTable", root, capture)
								elseif getTeamName(getPlayerTeam(source)) == "Ally" and axisZ ~= z2 then
									local x, y, z = getElementPosition(flagpole[k])
									local x1, y1, z1 = getElementPosition(axisFlag[k])
									local z2 = z -14
									local distance = z1 - z2
									local time = distance / 10 * 10000
									triggerClientEvent (source, "captureHelpCreate", source)
									triggerClientEvent(getRootElement(), "displayGUItextAll", getRootElement(), ""..getClientName(source).." has assaulted the " ..id.. "!", 0, 0, 255 )
									setBlipColor ( capture[k], 0, 255, 0, 255)
									moveObject ( axisFlag[k], time, x + 1, y, z2 )
									moveObject ( axisFlag1[k], time, x + 1, y, z2 )
									triggerClientEvent (source, "captureProgressDown", source, time)
									timer[k] = setTimer ( triggerEvent, time, 1, "onColShapeHit", lowerFlag[k], source )
									currentuse[k] = setTimer ( setElementData, time-100, 1, lowerFlag[k], "inuse", false )
								elseif getTeamName(getPlayerTeam(source)) == "Ally" and allyZ == z and getBlipIcon(capture[k]) ~= 30 then
									isCaptured = setTimer ( captureZone, 1000, 1, source, k )
								end
						end
					else
						if getPlayerTeam(source) == false then
							outputChatBox ("uhm... You dont have a team..", source)
						else
							local r, g, b = getTeamColor(getPlayerTeam(source))
							triggerClientEvent (source, "captureHelpCreate", source)
							triggerClientEvent (source, "captureProgressDown", source, time)
							triggerClientEvent(root, "displayGUItextAll", root, ""..getClientName(source).." has claimed the " ..id.. "!", r, g, b)
							moveObject ( flag[k], time, x + 0.5, y, z2 )
							timer[k] = setTimer ( triggerEvent, time, 1, "onColShapeHit", lowerFlag[k], source )
							currentuse[k] = setTimer ( setElementData, time-100, 1, lowerFlag[k], "inuse", false )
							setBlipColor ( capture[k], 0, 255, 0, 255)
						end
					end
				else
					capturingTeam = getElementData(lowerFlag[k], "hisTeam")
					if getPlayerTeam(source) ~= capturingTeam then
						stopObject ( flag[k] )
						stopObject ( allyFlag[k] )
						stopObject ( allyFlag1[k] )
						stopObject ( axisFlag[k] )
						stopObject ( axisFlag1[k] )
						if ( timer[k] ) then
							killTimer(timer[k])
							timer[k] = nil
						end
						if ( currentuse[k] ) then
							killTimer ( currentuse[k] )
							currentuse[k] = nil
						end
						if ( flashBlip[k] ) then
							killTimer(flashBlip[k])
							flashBlip[k] = nil
						end
						setElementAlpha(capture[k], 255)
						setElementData(lowerFlag[k], "blocker", source)
						removeElementData(lowerFlag[k], "hisTeam")
						player = source
						inColshape = getElementsWithinColShape(lowerFlag[k], "player")
						for k,v in pairs(inColshape) do
							triggerClientEvent (v, "captureBlocked", player)
						end
					else
						triggerClientEvent(source, "displayGUItext", source, 0.45, 0.3, "This is already being captured", "default-bold-small", 255, 255, 255, 3000)
					end
				end
			end	)
			
			addEventHandler ("onColShapeLeave", lowerFlag[k], function (source)
			triggerClientEvent (source, "captureExit", source)
			if getElementData (source, "entered") ~= true then return end
				setElementData (lowerFlag[k], "inuse", false )
				setElementData (source, "entered", false)
				removeElementData(lowerFlag[k], "hisTeam")
				if ( timer[k] ) then
					killTimer(timer[k])
					timer[k] = nil
				end
				if ( currentuse[k] ) then
					killTimer ( currentuse[k] )
					currentuse[k] = nil
				end
					stopObject ( flag[k] )
					stopObject ( allyFlag[k] )
					stopObject ( allyFlag1[k] )
					stopObject ( axisFlag[k] )
					stopObject ( axisFlag1[k] )
			end )
			
			addEventHandler ("onPlayerWasted", getRootElement(), function (ammo, killer, killerweapon, bodypart)
			if getElementData(source, "feigndeath") == true then return end
			if getElementType(source) ~= "player" then return end
				triggerClientEvent (source, "rustlerExit", source )
				triggerClientEvent (source, "leaveRhino", source)
				unbindKey (source, "r", "down", specialKey)
				unbindKey (source, "r", "up", specialKey)
				if isElementWithinColShape(source, lowerFlag[k]) then
					triggerEvent ("onColShapeLeave", lowerFlag[k], source)
				end
				if samcol[1] ~= nil then
					if isElementWithinColShape(source, samcol[myAA] ) then
						triggerEvent("onColShapeLeave", samcol[myAA], source )
					end
				end

				if (killer) then
					triggerClientEvent(source, "killedCam", source, killer)
				end
				
			end )
			
			addEventHandler ("onPlayerQuit", getRootElement(), function ()
				if isElementWithinColShape(source, lowerFlag[k]) then
					triggerEvent ("onColShapeLeave", lowerFlag[k], source)
				end
			end)
	end
			

		
end
addEventHandler( "onGamemodeMapStart", root, onMapLoad)

function iAmReady()
	if mapRunning == true then
		currentmap = call(getResourceFromName"mapmanager","getRunningGamemodeMap")
		respawnMe = get(getResourceName(currentmap)..".#respawntime")
		maptime = get(getResourceName(currentmap)..".#time")
		camera = get(getResourceName(currentmap)..".camera")
		allycam = get(getResourceName(currentmap)..".alliescam")
		axiecam = get(getResourceName(currentmap)..".axiescam")
		setTimer (triggerClientEvent, 2000, 1, source,"onTheMapStart", source, respawnMe, maptime, camera, allycam, axiecam)
	end
end
addEvent("iAmReady", true)
addEventHandler("iAmReady", getRootElement(), iAmReady)

function onMapStop ()
	if (allieSpawnBlip) then
		destroyElement (allieSpawnBlip)
	end
	if (axieSpawnBlip) then
		destroyElement (axieSpawnBlip)
	end
	for k,v in pairs(flagpole) do
		destroyElement(v)
	end
	for k,v in pairs(flag) do
		destroyElement(v)
	end
	for k,v in pairs(allyFlag) do
		destroyElement(v)
	end
	for k,v in pairs(allyFlag1) do
		destroyElement(v)
	end
	for k,v in pairs(axisFlag) do
		destroyElement(v)
	end
	for k,v in pairs(axisFlag1) do
		destroyElement(v)
	end
	for k,v in pairs(lowerFlag) do
		destroyElement(v)
	end
	for k,v in pairs(capture) do
		destroyElement(v)
	end
	local axis = getTeamFromName("Axis")
	local ally = getTeamFromName("Ally")
	for k,v in pairs(getPlayersInTeam(axis)) do
		if isPedInVehicle(v) then
			removePedFromVehicle(v)
		end
		destroyBlipsAttachedTo(v)
		axisBlip[v] = nil
		setPlayerTeam(v, nil)
	end
	for k,v in pairs(getPlayersInTeam(ally)) do
		if isPedInVehicle(v) then
			removePedFromVehicle(v)
		end
		destroyBlipsAttachedTo(v)
		allyBlip[v] = nil
		setPlayerTeam(v, nil)
	end
	if samcol[1] ~= nil then
		for k,v in pairs(samsite) do
			destroyElement(v)
		end
		for k,v in pairs(samcol) do
			destroyElement(v)
		end
	end
	
	local vehicles = getElementsByType("vehicle")
	for k,v in pairs(vehicles) do
		destroyElement(v)
	end
	for k,v in pairs(daCar) do
		destroyElement(v)
	end
	killTimer (updateScore)
	updateScore = nil

	triggerClientEvent(getRootElement(), "onTheMapStop", getRootElement())
	
root = getRootElement()
allyBlip = {}
axisBlip = {}
id = {}
flagpole = {}
flag = {}
allyFlag = {}
allyFlag1 = {}
axisFlag = {}
axisFlag1 = {}
lowerFlag = {}
capture = {}
skinID = {}
scanning = {}
samsite = {}
samcol = {}
airPlane = {}
airplane1 = {}
daChute = {}
daCar = {}
carX = {}
carY = {}
carZ = {}
allyCapt = 100
axisCapt = 100
lastDmg = 0
lastEvent = 0
theEar = {}
pot = {}
timer = {}
currentuse = {}
flashBlip = {}
end
addEventHandler("onGamemodeMapStop", getRootElement(), onMapStop)

addEventHandler ("onPlayerTarget", root, function ( targetedElement )
	if getControlState (source, "aim_weapon") == true then
		if ( targetedElement ) then
			if getElementType(targetedElement) == "player" then
				if getPlayerTeam(targetedElement) ~= getPlayerTeam(source) then
					if getTeamName(getPlayerTeam(targetedElement)) == "Ally" then
						local team = getTeamFromName ( getTeamName(getPlayerTeam(source)) )
						local players = getPlayersInTeam ( team )
						for k,v in ipairs(players) do
							setElementVisibleTo(allyBlip[targetedElement], v, true)
							setTimer (setElementVisibleTo, 2000, 1, allyBlip[targetedElement], v, false)
						end
					elseif getTeamName(getPlayerTeam(targetedElement)) == "Axis" then
						local team = getTeamFromName ( getTeamName(getPlayerTeam(source)) )
						local players = getPlayersInTeam ( team )
						for k,v in ipairs(players) do
							setElementVisibleTo(axisBlip[targetedElement], v, true)
							setTimer (setElementVisibleTo, 2000, 1, axisBlip[targetedElement], v, false)
						end
					end
				end
			end
		end
	end
end)

function nametagColorChange ( thePlayer, commandName, r, g, b )
    setPlayerNametagColor ( thePlayer, r, g, b )
end
addCommandHandler ( "nametagcolorchange", nametagColorChange )
guiWindowOpen = {}
addEventHandler ("onPlayerSpawn", root, function (x, y, z, rotation, theTeam, model, interior, dimension)
if getElementData(source, "feigndeath") == true then return end
	guiWindowOpen[source] = {}
	bindKey (source, "F1", "down", function (source)
		guiWindowOpen[source] = true
		end)
	triggerClientEvent (source, "scale", source, theEar)
	setElementData (source, "spawnProtection", true)
	setTimer (setElementData, tonumber(protectMe), 1, source, "spawnProtection", false)
	bindKey (source, "r", "down", specialKey)
	bindKey (source, "r", "up", specialKey)
	textDisplayAddObserver ( allyCaptureDisplay, source )
	textDisplayAddObserver ( axisCaptureDisplay, source )
	local r, g, b = getTeamColor(getPlayerTeam(source))
	if getTeamName(getPlayerTeam(source)) == "Ally" then
		local r, g, b = getTeamColor(getPlayerTeam(source))
		setPlayerNametagColor (source, 0, 0, 255 )
		if not allyBlip[source] then
			allyBlip[source] = createBlipAttachedTo (source, 0, 2, r, g, b, 255, root)
			setElementVisibleTo (allyBlip[source], root, false)
			local team = getTeamFromName ( getTeamName(getPlayerTeam(source)) )
			local players = getPlayersInTeam ( team )
			for k,v in ipairs(players) do
				setElementVisibleTo(allyBlip[source], v, true)
			end
			for k,v in ipairs(allyBlip) do
				setElementVisibleTo(v, source, true)
			end
		end
		if ( skinID[source] == 1 ) then
			setPedArmor (source, 99)
			takeAllWeapons ( source )
			giveWeapon ( source, 31, 330 )
			bindKey (source, "1", "down", weaponChange)
			giveWeapon ( source, 24, 55 )
			bindKey (source, "2", "down", weaponChange)
			giveWeapon ( source, 1, 1 )
			bindKey (source, "3", "down", weaponChange)
			giveWeapon ( source, 16, 10 )
			bindKey (source, "4", "down", weaponChange)
		elseif ( skinID[source] == 2 ) then
			setPedArmor (source, 0)
			takeAllWeapons ( source )
			giveWeapon ( source, 34, 15 )
			bindKey (source, "1", "down", weaponChange)
			giveWeapon ( source, 23, 100 )
			bindKey (source, "2", "down", weaponChange)
			giveWeapon ( source, 4, 1 )
			bindKey (source, "3", "down", weaponChange)
			giveWeapon ( source, 17, 10 )
			bindKey (source, "4", "down", weaponChange)
			giveWeapon ( source, 44, 1 )
			bindKey (source, "5", "down", weaponChange)
		elseif ( skinID[source] == 3 ) then
			takeAllWeapons ( source )
			setPedArmor (source, 0)
			giveWeapon ( source, 29, 300 )
			bindKey (source, "1", "down", weaponChange)
			giveWeapon ( source, 22, 100 )
			bindKey (source, "2", "down", weaponChange)
			giveWeapon ( source, 14, 1 )
			bindKey (source, "3", "down", weaponChange)
			giveWeapon ( source, 42, 500 )
			bindKey (source, "4", "down", weaponChange)
		elseif ( skinID[source] == 4 ) then
			setPedArmor (source, 0)
			takeAllWeapons ( source )
			giveWeapon ( source, 36, 5 )
			bindKey (source, "1", "down", weaponChange)
			giveWeapon ( source, 28, 300 )
			bindKey (source, "2", "down", weaponChange)
			giveWeapon ( source, 9, 1 )
			bindKey (source, "3", "down", weaponChange)
			giveWeapon ( source, 39, 10 )
			bindKey (source, "4", "down", weaponChange)
			giveWeapon ( source, 40, 11 )
			bindKey (source, "5", "down", weaponChange)
		elseif ( skinID[source] == 5 ) then
			setPedArmor (source, 0)
			takeAllWeapons ( source )
			giveWeapon ( source, 33, 100 )
			bindKey (source, "1", "down", weaponChange)
			giveWeapon ( source, 25, 30 )
			bindKey (source, "2", "down", weaponChange)
			giveWeapon ( source, 5, 1 )
			bindKey (source, "3", "down", weaponChange)
			giveWeapon ( source, 46, 500 )
			bindKey (source, "4", "down", weaponChange)
		end
	elseif getTeamName(getPlayerTeam(source)) == "Axis" then
		local r, g, b = getTeamColor(getPlayerTeam(source))
		setPlayerNametagColor (source, 255, 0, 0 )
		if not axisBlip[source] then
			axisBlip[source] = createBlipAttachedTo (source, 0, 2, r, g, b, 255, root)
			setElementVisibleTo (axisBlip[source], root, false)
			local team = getTeamFromName ( "Axis" )
			local players = getPlayersInTeam ( team )
			for k,v in ipairs(players) do
				setElementVisibleTo(axisBlip[source], v, true)
			end
			for k,v in ipairs(axisBlip) do
				setElementVisibleTo(v, source, true)
			end
		end
		if ( skinID[source] == 1 ) then
			setPedArmor (source, 99)
			takeAllWeapons ( source )
			giveWeapon ( source, 30, 330 )
			bindKey (source, "1", "down", weaponChange)
			giveWeapon ( source, 24, 55 )
			bindKey (source, "2", "down", weaponChange)
			giveWeapon ( source, 1, 1 )
			bindKey (source, "3", "down", weaponChange)
			giveWeapon ( source, 16, 10 )
			bindKey (source, "4", "down", weaponChange)
		elseif ( skinID[source] == 2 ) then
			setPedArmor (source, 0)
			takeAllWeapons ( source )
			giveWeapon ( source, 34, 15 )
			bindKey (source, "1", "down", weaponChange)
			giveWeapon ( source, 23, 100 )
			bindKey (source, "2", "down", weaponChange)
			giveWeapon ( source, 4, 1 )
			bindKey (source, "3", "down", weaponChange)
			giveWeapon ( source, 17, 10 )
			bindKey (source, "4", "down", weaponChange)
			giveWeapon ( source, 44, 1 )
			bindKey (source, "5", "down", weaponChange)
		elseif ( skinID[source] == 3 ) then
			setPedArmor (source, 0)
			takeAllWeapons ( source )
			giveWeapon ( source, 29, 300 )
			bindKey (source, "1", "down", weaponChange)
			giveWeapon ( source, 22, 100 )
			bindKey (source, "2", "down", weaponChange)
			giveWeapon ( source, 14, 1 )
			bindKey (source, "3", "down", weaponChange)
			giveWeapon ( source, 42, 500 )
			bindKey (source, "4", "down", weaponChange)
		elseif ( skinID[source] == 4 ) then
			setPedArmor (source, 0)
			takeAllWeapons ( source )
			giveWeapon ( source, 36, 5 )
			bindKey (source, "1", "down", weaponChange)
			giveWeapon ( source, 28, 300 )
			bindKey (source, "2", "down", weaponChange)
			giveWeapon ( source, 9, 1 )
			bindKey (source, "3", "down", weaponChange)
			giveWeapon ( source, 39, 10 )
			bindKey (source, "4", "down", weaponChange)
			giveWeapon ( source, 40, 11 )
			bindKey (source, "5", "down", weaponChange)
		elseif ( skinID[source] == 5 ) then
			setPedArmor (source, 0)
			takeAllWeapons ( source )
			giveWeapon ( source, 33, 100 )
			bindKey (source, "1", "down", weaponChange)
			giveWeapon ( source, 25, 30 )
			bindKey (source, "2", "down", weaponChange)
			giveWeapon ( source, 5, 1 )
			bindKey (source, "3", "down", weaponChange)
			giveWeapon ( source, 46, 500 )
			bindKey (source, "4", "down", weaponChange)
		end
	end
end )
prevChange = {}
function weaponChange (source, key, keyState)
if guiWindowOpen[source] == true then return end
if isPedInVehicle(source) then return end
	if prevChange[source] then return end
	prevChange[source] = setTimer(function (source)
		prevChange[source] = nil end, 1000, 1,source)
	if key == "1" and keyState == "down" then
		if skinID[source] == 1 then
			setPedWeaponSlot(source, 5)
		elseif skinID[source] == 2 then
			setPedWeaponSlot(source, 6)
		elseif skinID[source] == 3 then
			setPedWeaponSlot(source, 4)
		elseif skinID[source] == 4 then
			setPedWeaponSlot(source, 7)
		elseif skinID[source] == 5 then
			setPedWeaponSlot(source, 6)
		end
	elseif key == "2" and keyState == "down" then
		if skinID[source] == 1 then
			setPedWeaponSlot(source, 2)
		elseif skinID[source] == 2 then
			setPedWeaponSlot(source, 2)
		elseif skinID[source] == 3 then
			setPedWeaponSlot(source, 2)
		elseif skinID[source] == 4 then
			setPedWeaponSlot(source, 4)
		elseif skinID[source] == 5 then
			setPedWeaponSlot(source, 3)
		end
	elseif key == "3" and keyState == "down" then
		if skinID[source] == 1 then
			setPedWeaponSlot(source, 0)
		elseif skinID[source] == 2 then
			setPedWeaponSlot(source, 1)
		elseif skinID[source] == 3 then
			setPedWeaponSlot(source, 10)
		elseif skinID[source] == 4 then
			setPedWeaponSlot(source, 1)
		elseif skinID[source] == 5 then
			setPedWeaponSlot(source, 1)
		end
	elseif key == "4" and keyState == "down" then
		if skinID[source] == 1 then
			setPedWeaponSlot(source, 8)
		elseif skinID[source] == 2 then
			setPedWeaponSlot(source, 8)
		elseif skinID[source] == 3 then
			setPedWeaponSlot(source, 9)
		elseif skinID[source] == 4 then
			setPedWeaponSlot(source, 8)
		elseif skinID[source] == 5 then
			setPedWeaponSlot(source, 11)
		end
	elseif key == "5" and keyState == "down" then
		if skinID[source] == 2 then
			setPedWeaponSlot(source, 11)
		elseif skinID[source] == 4 then
			setPedWeaponSlot(source, 12)
		end
	end
end

addEventHandler("onPlayerWasted", getRootElement(), function ()
	if getElementData(source, "feigndeath") == true then return end
	unbindKey (source, "1", "down", weaponChange)
	unbindKey (source, "2", "down", weaponChange)
	unbindKey (source, "3", "down", weaponChange)
	unbindKey (source, "4", "down", weaponChange)
	unbindKey (source, "5", "down", weaponChange)
end)

addEventHandler ("onPlayerQuit", getRootElement(), function ( reason )
	destroyBlipsAttachedTo ( source )
	if axisBlip[source] then
		axisBlip[source] = nil
	elseif allyBlip[source] then
		allyBlip[source] = nil
	end
end )

addEventHandler ("onPlayerDamage", getRootElement(), function (attacker, weapon, bodypart, loss )
if getElementData (source, "spawnProtection") == true then return end
	if ( lastDmg > getTickCount() ) then return end
	lastDmg = getTickCount() + 200
	if bodypart == 9 then
		if weapon == 34 then
			killPed(source, attacker, weapon, bodypart)
			triggerClientEvent(attacker, "displayGUItext", attacker, 0.45, 0.3, "You killed "..getClientName(source).." with a headshot!", "default-bold-small", 255, 255, 255, 3000)
		else
			local loss1 = loss + loss
			local totalHealth = getElementHealth(source) - ( loss1 )
			loss1 = 0
			if totalHealth <= 5 then
				killPed(source, attacker, weapon, bodypart)
				triggerClientEvent(attacker, "displayGUItext", attacker, 0.45, 0.3, "You killed "..getClientName(source).." with a headshot!", "default-bold-small", 255, 255, 255, 3000)
			else
				setElementHealth(source, totalHealth)
			end
		end
	else
		if weapon == 34 then
			local totalHealth = getElementHealth(source) - ( loss + loss )
			if totalHealth <= 5 then
				killPed(source, attacker, weapon, bodypart)
			else
				setElementHealth(source, totalHealth)
			end
		end
	end
end )

addEventHandler ("onVehicleDamage", getRootElement(), function (loss)
	if getElementModel(source) == 594 then
		local tank = getElementParent (source)
		if ( getVehicleOccupant(tank) ~= false ) then
			triggerClientEvent (getVehicleOccupant(tank), "damageVehicle", source, loss ) 
		end
		setElementHealth (tank, getElementHealth(source))
	end
end)

function captureZone ( source, k, id )
	inuse1 = nil
	timer[k] = nil
	currentuse[k] = nil
	local r, g, b = getTeamColor(getPlayerTeam(source))	
	triggerClientEvent(source, "capturedHelpCreate", source)
	if getTeamName(getPlayerTeam(source)) == "Ally" then
		triggerClientEvent(getRootElement(), "displayGUItextAll", getRootElement(), ""..getClientName(source).." has Captured the " ..id.. "!", 0, 0, 255)
		destroyBlipsAttachedTo ( flagpole[k] )
		capture[k] = createBlipAttachedTo (flagpole[k], 30, 1, 255, 255, 255, 255 )
		triggerClientEvent (getRootElement(), "captureTable", getRootElement(), capture)
		
	elseif getTeamName(getPlayerTeam(source)) == "Axis" then
		triggerClientEvent(getRootElement(), "displayGUItextAll", getRootElement(), ""..getClientName(source).." has Captured the " ..id.. "!", 255, 0, 0)
		destroyBlipsAttachedTo ( flagpole[k] )
		capture[k] = createBlipAttachedTo (flagpole[k], 20, 1, 255, 255, 255, 255 )
		triggerClientEvent (getRootElement(), "captureTable", getRootElement(), capture)
	end
	captured = nil
end

function specialKey (source, key, keyState)
if samcol[1] ~= nil and isElementWithinColShape(source, samcol[myAA] ) then
	if keyState == "down" then
		local x, y, z = getElementPosition(samsite[myAA])
		triggerClientEvent(source,"doSetFreecamEnabled", source, x, y, z, dontChangeFixedMode)
	end
else
	local target = getPedTarget ( source )
	local weaponType = getPlayerWeapon ( source )
	if ( target ) and getElementType(target) == "vehicle" and ( weaponType ~= 46 ) and ( weaponType ~= 14 ) then
		if isPedDead(source) then return end
		if keyState == "down" then
			if getElementType ( target ) == "vehicle" then
				triggerClientEvent (source, "mountPatriot", source)
			end
		end
	else
		if ( skinID[source] == 5 ) then
			if isPedDead(source) then return end
			local weaponType = getPlayerWeapon ( source )
			if ( weaponType == 46) then
				if isPedInVehicle(source) then return end
				if keyState == "down" then
					guiWindowOpen[source] = true
					triggerClientEvent (source, "mechanicGUI", source)
					showCursor (source, false)
				end
			else
				if isPedInVehicle(source) then return end
				if ( lastEvent > getTickCount() ) then return end
				lastEvent = getTickCount() + 500
				triggerClientEvent(source, "displayGUItext", source, 0.45, 0.3, "You need to equip your backpack!", "default-bold-small", 255, 255, 255, 3000)
			end
		elseif ( skinID[source] == 3 ) then
			if isPedDead(source) then return end
			local weaponType = getPlayerWeapon ( source )
			if ( weaponType == 14) then
				if keyState == "down" then
					if isPedInVehicle(source) then return end
					triggerClientEvent(source, "displayGUItext", source, 0.45, 0.3, "Hold 'R' and click on the player\nyou want to mend", "default-bold-small", 255, 255, 255, 3000)
					showCursor (source, true)
				elseif keyState == "up" then
					showCursor (source, false)
					if ( mendPet ) then
						killTimer ( mendPet )
						mendPet = nil
					end
				end
			else
				if isPedInVehicle(source) then return end
				if ( lastEvent > getTickCount() ) then return end
				lastEvent = getTickCount() + 500
				triggerClientEvent(source, "displayGUItext", source, 0.45, 0.3, "You need to equip your medicine\n flowers!", "default-bold-small", 255, 255, 255, 3000)
			end
		elseif ( skinID[source] == 2 ) then
			if keyState == "down" then
			if isPedInVehicle(source) then return end
				if isPedDead(source) and getElementData(source, "feigndeath") == true then
					triggerClientEvent (source, "restoreDeath", source)
				else
					feignHealth = getElementHealth(source)
					feignX, feignY, feignZ = getElementPosition(source)
					feignRot = getPedRotation(source)
					feignSkin = getElementModel(source)
					setElementData(source, "feigndeath", true)
					triggerClientEvent (source, "feigndeath", source, feignHealth, feignX, feignY, feignZ, feignRot, feignSkin)
				end
			end
			
		end
		if isPedInVehicle(source) then
			if isPedDead(source) then return end
			if getElementModel(getPedOccupiedVehicle(source)) == 485 then
				if detached == true then
					detached = false
				else
					detached = true
				end
				detachTrailerFromVehicle (getPedOccupiedVehicle(source))
				local x, y, z = getElementPosition(bagBox)
				activateFieldgun = createColCircle (x, y, z, 3)
				addEventHandler ("onColShapeHit", activateFieldgun, activateFieldgun1 )	
				addEventHandler ("onColShapeLeave", activateFieldgun, leaveFieldgun )
			end
		end
	end

end
end

addCommandHandler("resetdeath", function (source)
setElementData(source, "feigndeath", false)
end)

function killScout ( source )
	killPed(source)
end
addEvent ("killscout", true)
addEventHandler("killscout", getRootElement(), killScout)

function ressurectScout (source, restoreHealth, restoreX, restoreY, restoreZ, restoreRot, restoreSkin, restorePistol, restoreSniper, restoreNades)
	spawnPlayer(source, restoreX, restoreY, restoreZ, restoreRot, restoreSkin)
	setElementHealth (source, tonumber(restoreHealth))
	setTimer (setElementData, 1000, 1, source, "feigndeath", false)
	takeAllWeapons ( source )
	giveWeapon ( source, 34, restoreSniper )
	giveWeapon ( source, 23, restorePistol )
	giveWeapon ( source, 4, 1 )
	giveWeapon ( source, 17, restoreNades )
	giveWeapon ( source, 44, 1 )
end
addEvent("ressurect", true)
addEventHandler("ressurect", getRootElement(), ressurectScout)

function attachPatriot (target)
	local status = getElementAttachedTo( target )
	if ( status ) then
	else
		if ( target ) then
			if getElementType ( target ) == "vehicle" then
				if getElementModel(target) == 470 then
					attachElements (source, target, 0, -2.1, 0.8)
					giveWeapon (source, 38, 500, true)
				elseif getElementModel(target) == 455 then
					local driver = getVehicleController(target)
					if driver then
						setCameraTarget (source, driver)
						attachElements (source, target, math.random(-0.9,0.9), math.random(-4, 0), 0.8)
					else
						triggerClientEvent(source, "displayGUItext", source, 0.45, 0.3, "You need someone to drive!", "default-bold-small", 255, 255, 255, 3000)
					end
				elseif getElementModel(target) == 548 then
					local driver = getVehicleController(target)
					if driver then
						setCameraTarget (source, driver)
						attachElements (source, target, math.random(-0.6, 0.6), math.random(-2, 3), -0.8)
					else
						triggerClientEvent(source, "displayGUItext", source, 0.45, 0.3, "You need someone to drive!", "default-bold-small", 255, 255, 255, 3000)
					end
				end
			end
		end
	end

end
addEvent ("attachPatriot", true)
addEventHandler ("attachPatriot", root, attachPatriot)

function detachPatriot (target)
	detachElements ( source )
	setCameraTarget (source, source)
	takeWeapon (source, 38)
	if ( skinID[source] == 4 ) then
		giveWeapon ( source, 35, 20 )
	end
end
addEvent ("detachPatriot", true)
addEventHandler ("detachPatriot", root, detachPatriot)

function vehicleRepair ()
	guiWindowOpen[source] = "closed"
	triggerClientEvent(source, "displayGUItext", source, 0.45, 0.3, "Click on the vehicle you\nwant to repair.", "default-bold-small", 255, 255, 255, 3000)
	showCursor (source, true)
end
addEvent ("vehicleRepair", true)
addEventHandler("vehicleRepair", getRootElement(), vehicleRepair)

function acceptRepair(source, x, y, z, rz)
	spawnVehicle(source, x, y, z, 0, 0, rz)
end
addEvent("acceptRepair", true)
addEventHandler("acceptRepair", getRootElement(), acceptRepair)

addEventHandler ("onElementClicked", getRootElement(), function (button, state, clicker, posX, posY, posZ)
	if state == "down" then
	if ( skinID[clicker] == 5 ) then
		showCursor (clicker, false)
		if getElementType(source) == "vehicle" then
			local x, y, z = getElementPosition (source)
			local rx, ry, rz = getVehicleRotation(source)
			local x1, y1, z1 = getElementPosition (clicker)
			local distance = getDistanceBetweenPoints3D (x1, y1, z1, x, y, z)
			if distance < 4 then
				if getElementModel(source) ~= 432 and getElementModel(source) ~= 594 then
					triggerClientEvent(clicker, "displayGUItext", clicker, 0.45, 0.3, "Fixing vehicle...", "default-bold-small", 255, 255, 255, 3000)
					triggerClientEvent (clicker, "mechanicProgressBars", clicker, source, x, y, z, rz)				
				else
					triggerClientEvent(clicker, "displayGUItext", clicker, 0.45, 0.3, "You cant repair a tank!", "default-bold-small", 255, 255, 255, 3000)
				end
			else
				triggerClientEvent(clicker, "displayGUItext", clicker, 0.45, 0.3, "You are too far away", "default-bold-small", 255, 255, 255, 3000)
			end
		else
			triggerClientEvent(clicker, "displayGUItext", clicker, 0.45, 0.3, "You cant repair that!", "default-bold-small", 255, 255, 255, 3000)
		end	
	elseif ( skinID[clicker] == 3 ) then
		if getElementType(source) == "player" then
			local x, y, z = getElementPosition (source)
			local x1, y1, z1 = getElementPosition (clicker)
			local distance = getDistanceBetweenPoints3D (x1, y1, z1, x, y, z)
			if distance < 2 then
				triggerClientEvent(clicker, "displayGUItext", clicker, 0.45, 0.3, "Mending player...", "default-bold-small", 255, 255, 255, 3000)
				mendPet = setTimer (mendPlayer, 500, 20, clicker, source)
				
			else
				triggerClientEvent(clicker, "displayGUItext", clicker, 0.45, 0.3, "You are too far away", "default-bold-small", 255, 255, 255, 3000)
			end
		else
			triggerClientEvent(clicker, "displayGUItext", clicker, 0.45, 0.3, "You cant mend that!", "default-bold-small", 255, 255, 255, 3000)
		end

	end
	end
end )

function medicine ()
	
end
addEvent ("medicine", true)
addEventHandler ("medicine", getRootElement(), medicine)

function mendPlayer ( clicker, source)
	--if isElement(source) ~=  true then
		--killTimer ( mendPet )
		--mendPet = nil
	--end
	if getElementHealth(source) >= 100 then
		triggerClientEvent(clicker, "displayGUItext", clicker, 0.45, 0.3, "Player mended", "default-bold-small", 255, 255, 255, 3000)
		killTimer ( mendPet )
		mendPet = nil
	else
		local x, y, z = getElementPosition (source)
		local x1, y1, z1 = getElementPosition (clicker)
		local distance = getDistanceBetweenPoints3D (x1, y1, z1, x, y, z)
		if distance < 2 then
			if source == clicker then
				triggerClientEvent(clicker, "displayGUItext", clicker, 0.45, 0.3, "You cant mend yourself!", "default-bold-small", 255, 255, 255, 3000)
				killTimer ( mendPet )
				mendPet = nil
			elseif getPlayerTeam(source) ~= getPlayerTeam(clicker) then
				triggerClientEvent(clicker, "displayGUItext", clicker, 0.3, 0.3, "Traitor!\nYou are not allowed to mend the\nopposing team!", "sa-header", 255, 0, 0, 3000)
				killTimer ( mendPet )
				mendPet = nil
			else
				health = getElementHealth (source) + 5
				setElementHealth (source, health)
				withdraw = 2
				triggerClientEvent (clicker, "medicProgressBars", clicker, withdraw)
			end
		else
			killTimer ( mendPet )
			mendPet = nil
			triggerClientEvent(clicker, "displayGUItext", clicker, 0.45, 0.3, "You are too far away", "default-bold-small", 255, 255, 255, 3000)
		end
	end
end

function vehicleCreate ()
	guiWindowOpen[source] = false
	carX[source], carY[source], carZ[source] = getElementPosition ( source )
	airPlane[source] = createObject (2469, carX[source], carY[source] - 200, carZ[source] + 40)
	airplane1[source] = createVehicle (577, carX[source], carY[source] - 200, carZ[source] + 39)
	setElementParent ( airplane1[source], airPlane[source] )
	setVehicleLandingGearDown ( airplane1[source], false )
	setTimer (attachElements, 500, 1, airplane1[source], airPlane[source], 0, 0, -1)
	setTimer ( vehicleCreate1, 600, 1, airPlane[source], carX[source], carY[source], carZ[source] )
	setTimer ( createVehicle1, 5600, 1, source, carX[source], carY[source], carZ[source] )

end
addEvent ("vehicleCreate", true)
addEventHandler ("vehicleCreate", root, vehicleCreate)

function vehicleCreate1 ( airPlane, carX, carY, carZ )
	moveObject ( airPlane, 10000, carX, carY + 200, carZ + 15 )
	setTimer (destroyElement, 10000, 1, airPlane)
end

function createVehicle1 (source, carX, carY, carZ)
	wX = wX
	wY = wY
	wZ = wZ
	local vehID = getElementData (source, "vehID")
	daChute[source] = createObject (2903, carX +5, carY, carZ + 30 )
	daCar[source] = createVehicle (vehID, carX +5, carY, carZ + 20 )
	setTimer (attachElements, 300, 1, daCar[source], daChute[source], 0, 0, -8, 0, 0, 0)
	setTimer (createVehicle2, 500, 1, daChute[source], carX, carY, carZ )
	setTimer (detachElements, 10500, 1, daCar[source], daChute[source])
end


function createVehicle2 ( daChute, carX, carY, carZ )
	moveObject (daChute, 10000, carX + 5, carY, carZ + 8)
	setTimer ( destroyElement, 10000, 1, daChute )
end

function fetchTable ()
	triggerClientEvent (source, "captureTable", source, capture)
end
addEvent ("fetchTable", true)
addEventHandler ("fetchTable", getRootElement(), fetchTable )

function radio ( x )
guiWindowOpen[source] = false
local r, g, b = getTeamColor(getPlayerTeam(source))
local team = getTeamFromName ( getTeamName(getPlayerTeam(source)) )
local players = getPlayersInTeam ( team )
for k,v in ipairs(players) do
	if getTeamName(getPlayerTeam(source)) == "Ally" then
		setElementVisibleTo (allyBlip[source], v, false)
		setTimer (setElementVisibleTo, 500, 1, allyBlip[source], v, true)
		setTimer (setElementVisibleTo, 1000, 1, allyBlip[source], v, false)
		setTimer (setElementVisibleTo, 1500, 1, allyBlip[source], v, true)
		setTimer (setElementVisibleTo, 2000, 1, allyBlip[source], v, false)
		setTimer (setElementVisibleTo, 2500, 1, allyBlip[source], v, true)
	elseif getTeamName(getPlayerTeam(source)) == "Axis" then
		setElementVisibleTo (axisBlip[source], v, false)
		setTimer (setElementVisibleTo, 500, 1, axisBlip[source], v, true)
		setTimer (setElementVisibleTo, 1000, 1, axisBlip[source], v, false)
		setTimer (setElementVisibleTo, 1500, 1, axisBlip[source], v, true)
		setTimer (setElementVisibleTo, 2000, 1, axisBlip[source], v, false)
		setTimer (setElementVisibleTo, 2500, 1, axisBlip[source], v, true)
	end
	if ( x == 5) then
		outputChatBox (""..getClientName(source)..": Taking Fire! Need Assistance!", v, r, g, b)
	elseif ( x == 1 ) then
		outputChatBox (""..getClientName(source)..": Attack the enemy base!", v, r, g, b)
	elseif ( x == 2 ) then
		outputChatBox (""..getClientName(source)..": Defend our bases!", v, r, g, b)
	elseif ( x == 3 ) then
		outputChatBox (""..getClientName(source)..": Its ours", v, r, g, b)
	elseif ( x == 4 ) then
		outputChatBox (""..getClientName(source)..": I cant hold it!", v, r, g, b)
	elseif ( x == 6 ) then
		outputChatBox (""..getClientName(source)..": Requesting backup!", v, r, g, b)
	elseif ( x == 7 ) then
		outputChatBox (""..getClientName(source)..": MEEEDIIIC!", v, r, g, b)
	elseif ( x == 8 ) then
		outputChatBox (""..getClientName(source)..": Requesting a pickup!", v, r, g, b)
	elseif ( x == 9 ) then
		outputChatBox (""..getClientName(source)..": Requesting Anti-tank!", v, r, g, b)
	elseif ( x == 10 ) then
		outputChatBox (""..getClientName(source)..": Requesting a Mechanic!", v, r, g, b)
	elseif ( x == 11 ) then
		outputChatBox (""..getClientName(source)..": Enemy Soldier spotted!", v, r, g, b)
	elseif ( x == 12 ) then
		outputChatBox (""..getClientName(source)..": Enemy Vehicle spotted!", v, r, g, b)
	elseif ( x == 13 ) then
		outputChatBox (""..getClientName(source)..": Enemy Airplane spotted!", v, r, g, b)
	elseif ( x == 14 ) then
		outputChatBox (""..getClientName(source)..": Enemy Scout spotted!", v, r, g, b)
	elseif ( x == 15 ) then
		outputChatBox (""..getClientName(source)..": Enemy Anti-tank spotted!", v, r, g, b)
	elseif ( x == 16 ) then
		outputChatBox (""..getClientName(source)..": Roger that!", v, r, g, b)
	elseif ( x == 17 ) then
		outputChatBox (""..getClientName(source)..": Negative!", v, r, g, b)
	elseif ( x == 18 ) then
		outputChatBox (""..getClientName(source)..": I got one!", v, r, g, b)
	end
end
	if ( x == 19 ) then
		outputChatBox (""..getClientName(source)..": Take that bitch!", root, r, g, b)
	elseif ( x == 20 ) then
		outputChatBox (""..getClientName(source)..": I would surrender if i were you..", root, r, g, b)
	elseif ( x == 21 ) then
		outputChatBox (""..getClientName(source)..": All your bases are belong to us.", root, r, g, b)
	end
end
addEvent ("radio", true)
addEventHandler ("radio", getRootElement(), radio)

function spawn (baseX1, baseY1, baseZ1, index)
	skinID[source] = index[source]
	if ( index[source] == 1 ) then --soldier
		if getTeamName(getPlayerTeam(source)) == "Ally" then
			spawnPlayer (source, baseX1 + (math.random(0,10)), baseY1 + (math.random(0,10)), baseZ1, 0, 287 )
		elseif getTeamName(getPlayerTeam(source)) == "Axis" then
			spawnPlayer (source, baseX1 + (math.random(0,10)), baseY1 + (math.random(0,10)), baseZ1, 0, 165 )
		end
	elseif ( index[source] == 2 ) then --scout
		if getTeamName(getPlayerTeam(source)) == "Ally" then
			spawnPlayer (source, baseX1 + (math.random(0,10)), baseY1 + (math.random(0,10)), baseZ1, 0, 285 )
		elseif getTeamName(getPlayerTeam(source)) == "Axis" then
			spawnPlayer (source, baseX1 + (math.random(0,10)), baseY1 + (math.random(0,10)), baseZ1, 0, 163 )
		end
	elseif ( index[source] == 3 ) then --medic
		if getTeamName(getPlayerTeam(source)) == "Ally" then
			spawnPlayer (source, baseX1 + (math.random(0,10)), baseY1 + (math.random(0,10)), baseZ1, 0, 286 )
		elseif getTeamName(getPlayerTeam(source)) == "Axis" then
			spawnPlayer (source, baseX1 + (math.random(0,10)), baseY1 + (math.random(0,10)), baseZ1, 0, 164 )
		end
	elseif ( index[source] == 4 ) then --anti-tank
		if getTeamName(getPlayerTeam(source)) == "Ally" then
			spawnPlayer (source, baseX1 + (math.random(0,10)), baseY1 + (math.random(0,10)), baseZ1, 0, 284 )
		elseif getTeamName(getPlayerTeam(source)) == "Axis" then
			spawnPlayer (source, baseX1 + (math.random(0,10)), baseY1 + (math.random(0,10)), baseZ1, 0, 166 )
		end
	elseif ( index[source] == 5 ) then --mechanic
		if getTeamName(getPlayerTeam(source)) == "Ally" then
			spawnPlayer (source, baseX1 + (math.random(0,10)), baseY1 + (math.random(0,10)), baseZ1, 0, 260 )
		elseif getTeamName(getPlayerTeam(source)) == "Axis" then
			spawnPlayer (source, baseX1 + (math.random(0,10)), baseY1 + (math.random(0,10)), baseZ1, 0, 50 )
		end
	end
		
end
addEvent ("spawn", true)
addEventHandler ("spawn", getRootElement(), spawn)

function addAlly ()
	setPlayerTeam ( source, Ally )
end
addEvent("addAlly", true)
addEventHandler ("addAlly", getRootElement(), addAlly)

function addAxis ()
	setPlayerTeam ( source, Axis )
end
addEvent("addAxis", true)
addEventHandler ("addAxis", getRootElement(), addAxis)

function checkBases (source)
	allyNumberBases = 0
	axisNumberBases = 0
	for k,v in pairs(capture) do
		if getBlipIcon(v) == 30 then
			allyNumberBases = allyNumberBases + 1
		elseif getBlipIcon(v) == 20 then
			axisNumberBases = axisNumberBases + 1
		end
	end
	if tonumber(allyNumberBases) > 1 then
		allyCapt = allyCapt + 2 * tonumber(allyNumberBases)
	end
	if tonumber(axisNumberBases) > 1 then
		axisCapt = axisCapt + 2 * tonumber(axisNumberBases)
	end
	if tonumber(allyNumberBases) == 1 then
		allyCapt = allyCapt + 1
	end
	if tonumber(axisNumberBases) == 1 then
		axisCapt = axisCapt + 1
		
	end
	if tonumber(axisCapt) > tonumber(maxscore) -1 then
		axisCapt = tonumber(maxscore)
		killTimer ( updateScore ) 
		updateScore = nil
		local axis = getTeamFromName("Axis")
		local ally = getTeamFromName("Ally")
		for k,v in pairs(getPlayersInTeam(axis)) do
			triggerClientEvent(v, "displayGUItext", v, 0.3, 0.3, "You are Victorious!", "sa-header", 255, 0, 0, 7000)
		end
		for k,v in pairs (getPlayersInTeam(ally)) do
			triggerClientEvent(v, "displayGUItext", v, 0.3, 0.3, "You have been Defeated!", "sa-header", 0, 0, 255, 7000)
		end
		setTimer (restartGame, 10000, 1)
		triggerClientEvent (getRootElement(), "axisWin", getRootElement())
	elseif tonumber(allyCapt) > tonumber(maxscore) -1 then
		allyCapt = tonumber(maxscore)
		killTimer ( updateScore ) 
		updateScore = nil
		local axis = getTeamFromName("Axis")
		local ally = getTeamFromName("Ally")
		for k,v in pairs(getPlayersInTeam(axis)) do
			triggerClientEvent(v, "displayGUItext", v, 0.3, 0.3, "You have been Defeated!", "sa-header", 255, 0, 0, 7000)
		end
		for k,v in pairs (getPlayersInTeam(ally)) do
			triggerClientEvent(v, "displayGUItext", v, 0.3, 0.3, "You are Victorious!", "sa-header", 0, 0, 255, 7000)
		end
		setTimer (restartGame, 10000, 1)
		triggerClientEvent (getRootElement(), "allyWin", getRootElement())
	end
	textItemSetText ( allyCaptureText, ""..allyCapt.."/"..tonumber(maxscore).."" )
	textItemSetText ( axisCaptureText, ""..axisCapt.."/"..tonumber(maxscore).."" )
end
--addCommandHandler ("check", checkBases )
--addCommandHandler ("stopT", function() killTimer ( updateScore ) updateScore = nil end )
--addCommandHandler ("startT", function() updateScore = setTimer (checkBases, 2000, 0) end )


--480 x 518
function restartGame()
	triggerEvent("onRoundFinished", getResourceRootElement(getThisResource()))
	allyCapt = 100
	axisCapt = 100
	textItemSetText ( allyCaptureText, ""..allyCapt.."/"..tonumber(maxscore).."" )
	textItemSetText ( axisCaptureText, ""..axisCapt.."/"..tonumber(maxscore).."" )
	
	for k,v in pairs(flag) do
		destroyElement(v)
	end
	for k,v in pairs(allyFlag) do
		destroyElement(v)
	end
	for k,v in pairs(allyFlag1) do
		destroyElement(v)
	end	
	for k,v in pairs(axisFlag) do
		destroyElement(v)
	end
	for k,v in pairs(axisFlag1) do
		destroyElement(v)
	end
	for k,v in pairs(getElementsByType("captureBase")) do
		local x = getElementData (v, "posX")
		local y = getElementData (v, "posY")
		local z = getElementData (v, "posZ")
		local id = getElementData (v, "name")
		local px, py, pz = getElementPosition(flagpole[k])
		local pz = pz -14
		flag[k] = createObject ( 11245, x + 4.5, y, z + 8, 0, 290, 0 ) --flag
		allyFlag[k] = createObject ( 2047, x + 5, y, pz )
		allyFlag1[k] = createObject ( 2047, x + 5, y, pz, 0,0,180 )
		axisFlag[k] = createObject ( 2048, x + 5, y, pz )
		axisFlag1[k] = createObject ( 2048, x + 5, y, pz, 0,0,180 )
	end
	for k,v in ipairs(flagpole) do
		destroyBlipsAttachedTo (v)
		capture[k] = createBlipAttachedTo (v, 0, 2, 255, 255, 255, 255 )
	end
	local axis = getTeamFromName("Axis")
	local ally = getTeamFromName("Ally")
	for k,v in pairs(getPlayersInTeam(axis)) do
		if isPedInVehicle(v) then
			removePedFromVehicle(v)
		end
		destroyBlipsAttachedTo(v)
		axisBlip[v] = nil
		setPlayerTeam(v, nil)
		setTimer (setPlayerTeam, 1000, 1, v, ally)
		killPed(v)
		triggerClientEvent (v, "captureTable", v, capture)
	end
	for k,v in pairs(getPlayersInTeam(ally)) do
		if isPedInVehicle(v) then
			removePedFromVehicle(v)
		end
		destroyBlipsAttachedTo(v)
		allyBlip[v] = nil
		setPlayerTeam(v, nil)
		setTimer (setPlayerTeam, 1000, 1, v, axis)
		killPed(v)
		triggerClientEvent (v, "captureTable", v, capture)
	end
	local vehicles = getElementsByType("vehicle")
	for k,v in pairs(vehicles) do
		local model = getElementData (v, "model")
		local x = getElementData (v, "posX")
		local y = getElementData (v, "posY")
		local z = getElementData (v, "posZ")
		local rx = getElementData (v, "rotX")
		local ry = getElementData (v, "rotY")
		local rz = getElementData (v, "rotZ")
		spawnVehicle (v, x, y, z, rx, ry, rz)
	end
	for k,v in pairs(daCar) do
		destroyElement(v)
	end
	updateScore = setTimer (checkBases, 2000, 0)
	setTimer (createBigAssEar, 2000, 1)
end
addCommandHandler ("restartNOW", restartGame)


function spectateGay ( source )
	bindKey (source, "F1", "down", spectateNext)
	bindKey (source, "F2", "down", spectatePrev)
	bindKey (source, "F3", "down", stopSpec)
	setElementData ( source, "spect", 1 )
	spect = getElementData ( source, "spect" )
	spectateNext ( source )
	outputChatBox ("press F1 to spectate another player, F2 for previous, F3 to stop", source, 0, 255, 0)
end
addCommandHandler ("spec", spectateGay)

function spectateNext ( source )
	spect = getElementData ( source, "spect" )
	myTeam = getPlayerTeam(source)
	teamMates = getPlayersInTeam(myTeam)
	if isPedDead(teamMates[spect]) then
		if spect == #teamMates then
			setElementData ( source, "spect", 1 )
			spectateNext (source)
		else
			setElementData ( source, "spect", getElementData ( source, "spect" ) + 1 )
			spectateNext (source)
		end
	else
		setCameraTarget ( source, teamMates[spect] )
	end
	if spect == #teamMates then
		--spect = 1
		setElementData ( source, "spect", 1 )
	else
		setElementData ( source, "spect", getElementData ( source, "spect" ) + 1 )
		--setElementData ( source, "spect", getElementData ( source, "spect" ) + 1 )
	end
end
addCommandHandler ("next", spectateNext)

function spectatePrev ( source )
	spect = getElementData ( source, "spect" )
	myTeam = getPlayerTeam(source)
	teamMates = getPlayersInTeam(myTeam)
	if isPedDead(teamMates[spect]) then
		if spect == 1 then
			spectN = #teamMates
			setElementData ( source, "spect", spectN )
			spectatePrev (source)
		else
			setElementData ( source, "spect", getElementData ( source, "spect" ) - 1 )
			spectateNext (source)
		end
	else
		setCameraTarget ( source, teamMates[spect] )
	end
	if spect == 1 then
		spectN = #teamMates
		setElementData ( source, "spect", spectN )
	else
		setElementData ( source, "spect", getElementData ( source, "spect" ) - 1 )
	end
end
addCommandHandler ("prev", spectatePrev)

function stopSpec ( source )
	unbindKey (source, "F1", "down", spectateNext)
	unbindKey (source, "F2", "down", spectatePrev)
	unbindKey (source, "F3", "down", stopSpec)
	setCameraTarget ( source, source )
end
addCommandHandler ( "stopspec", stopSpec )

function showTextForAll ( time, red, green, blue, scale, text )
	local textDisplay = textCreateDisplay ()
	local textItem = textCreateTextItem ( text, 0.5, 0.1, 2, red, green, blue, 255, scale, "center" )
	textDisplayAddText ( textDisplay, textItem )
	local players = getElementsByType( "player" )
	for k,v in ipairs(players) do
		textDisplayAddObserver ( textDisplay, v )
	end
	setTimer(textDestroyTextItem, time, 1, textItem)
	setTimer(textDestroyDisplay, time, 1, textDisplay)
end

function showTextForPlayer ( source, time, red, green, blue, scale, text )
	local textDisplay = textCreateDisplay ()
	local textItem = textCreateTextItem ( text, 0.5, 0.2, 2, red, green, blue, 255, scale, "center" )
	textDisplayAddText ( textDisplay, textItem )
	textDisplayAddObserver ( textDisplay, source )
	setTimer(textDestroyTextItem, time, 1, textItem)
	setTimer(textDestroyDisplay, time, 1, textDisplay)
end

addEventHandler("onVehicleExplode", root, function ()
	if getElementModel(source) == 432 then
		setTimer ( destroyElement, 10000, 1, source )
	end
end)

addEventHandler ("onVehicleEnter", root, function ( player, seat, jacked )
	if getElementModel(source) == 476 then
		triggerClientEvent (player, "rustlerEnter", player )
		local x, y, z = getElementPosition(source)
		local rotX, rotY, rotZ = getVehicleRotation(source)
		bomb1 = createObject( 3790, x, y, z - 1, rotZ - 90, rotY, rotZ)
		attachElements (bomb1, source, 0, 0, -1.2, 0, 0, -1.5 )
	elseif getElementModel(source) == 432 then
		local x, y, z = getElementPosition (source)
		if not (pot[source]) then
			pot[source] = createVehicle (594, x + 3, y, z)
			attachElements (pot[source], source, 0, 4, 0.5, 0, 0, 0)
			setVehicleLocked (pot[source], true)
			setElementParent (pot[source], source)
			setElementHealth (pot[source], 1000)
			setElementHealth (source, 1000)
			setElementAlpha (pot[source], 0)
		end
		triggerClientEvent (getVehicleOccupant(source), "damageVehicle", source )
		triggerClientEvent (getVehicleOccupant(source), "enterRhino", source )
	elseif getElementModel(source) == 520 or getElementModel(source) == 425 then
		triggerClientEvent (getVehicleOccupant(source), "enterRhino", source )
	elseif getElementModel(source) == 578 then
		if getTeamName(getPlayerTeam(player)) == "Ally" then
			for k,v in pairs(axisBlip) do
				setElementVisibleTo(v, root, true)
			end
		elseif getTeamName(getPlayerTeam(player)) == "Axis" then
			for k,v in pairs(allyBlip) do
				setElementVisibleTo(v, root, true)
			end
		end	
	end
end)
addEventHandler ("onVehicleExit", root, function ( player, seat, jacked )
	if getElementModel(source) == 476 then
		triggerClientEvent (player, "rustlerExit", player )
		destroyElement (bomb1)
	elseif getElementModel(source) == 432 or getElementModel(source) == 520 or getElementModel(source) == 425 then
		triggerClientEvent (getVehicleOccupant(source), "leaveRhino", source)
	elseif getElementModel(source) == 578 then
		if getTeamName(getPlayerTeam(player)) == "Ally" then
			for k,v in pairs(axisBlip) do
				setElementVisibleTo(v, root, false)
			end
		elseif getTeamName(getPlayerTeam(player)) == "Axis" then
			for k,v in pairs(allyBlip) do
				setElementVisibleTo(v, root, false)
			end
		end	
	end
end)

function createBomb ( source )
	local rustler = getPedOccupiedVehicle(source)
	local x, y, z = getElementPosition(rustler)
	local rotX, rotY, rotZ = getVehicleRotation(rustler)
	bomb1 = createObject( 3790, x, y, z - 1, rotZ - 90, rotY, rotZ)
	attachElements (bomb1, rustler, 0, 0, -1.2, 0, 0, -1.5 )
end

function rustlerBomb ( sX, sY, sZ, fX, fY, fZ )
	destroyElement (bomb1)
	setTimer (createBomb, 10000, 1, source)
	local rotX, rotY, rotZ = getVehicleRotation(getPedOccupiedVehicle(source))
	local time = ( sZ - fZ ) * 50
	local bomb = createObject( 3790, sX, sY, sZ - 6, rotZ - 90, rotY, rotZ )
	moveObject ( bomb, time, fX, fY, fZ )
	setTimer ( destroyElement, time, 1, bomb )
	setTimer ( createExplosion, time, 1, fX, fY, fZ, 7, source )
	setTimer ( createExplosion, time + 100, 1, fX, fY, fZ, 1, source )
	setTimer ( createExplosion, time + 200, 1, fX, fY, fZ, 7, source )
end
addEvent ( "rustlerBomb", true )
addEventHandler ( "rustlerBomb", getRootElement(), rustlerBomb )

function antiAirShot ( x, y, z, rX, rY, rZ )
	createExplosion ( x, y, z, 12, source )
end
addEvent ( "antiAirShot", true )
addEventHandler ( "antiAirShot", getRootElement(), antiAirShot )

function createBigAssEar ()
	for k,v in pairs(getElementsByType("vehicle")) do
	if getElementModel(v) == 578 then
		local x, y, z = getElementPosition(v)
		theEar[k] = createObject (1595, x + 2, y, z + 5 )
		attachElements (theEar[k], v, 0, -1, 2)
		setElementParent (theEar[k], v)
		for k,v in pairs(getElementsByType("player")) do
			triggerClientEvent (v, "scale", v, theEar)
		end
	end
	end
end
addCommandHandler ("myear", createBigAssEar)

function destroyBlipsAttachedTo(player)
if not isElement(player) then return false end
local attached = getAttachedElements ( player )
	if not attached then return false end
		for k,element in ipairs(attached) do
			if getElementType ( element ) == "blip" then
				destroyElement ( element )
			end
		end
	return true
end

