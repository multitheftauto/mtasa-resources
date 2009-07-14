root = getRootElement()
spawn = {}
spawns = {}
randSpawn = {}
car = {}
textSpace = 0
elimination = 1
mapRunning = false

function onMapLoad ( name )
	priWeapon = {}
	priWeapon1 = {}
	priWeapon2 = {}
	priWeapon3 = {}
	secWeapon = {}
	secWeapon1 = {}
	secWeapon2 = {}
	vehicle1 = {}
	
	local currentmap = call(getResourceFromName"mapmanager","getRunningGamemodeMap")
	local successful = fileOpen(':' .. getResourceName(currentmap) .. '/' .. "vehicles.xml", true)
	if (successful ~= false) then
		fileClose(successful)
		vehicleRoot = getResourceRootElement(currentmap)
	else
		vehicleRoot = getResourceRootElement(getResourceFromName("i69-vehicles"))
	end

	local currentmap = call(getResourceFromName"mapmanager","getRunningGamemodeMap")
	maxDeaths = get(getResourceName(currentmap)..".maxdeaths")
	respawnMe = get(getResourceName(currentmap)..".respawntime" )
	theMode = get(getResourceName(currentmap)..".mode" )
	timelimit = get(getResourceName(currentmap)..".timelimit" )
	protectMe = get(getResourceName(currentmap)..".#spawnprotection" )
	allowSpawn = get(getResourceName(currentmap)..".#allowedspawntime" )
	cameraPos = get(getResourceName(currentmap)..".#camera")
	allowSpawn = allowSpawn * 1000
	if not (theMode) then
		theMode = 1
	end
	if tonumber(theMode) == 1 then
		outputChatBox("Mode: Elimination")
		canSpawn = setTimer (spawnDisable, tonumber(allowSpawn), 1 )
	elseif tonumber(theMode) == 2 then
		outputChatBox("Mode: Deathmatch")
		timelimit = timelimit * 1000
		theTimeLimit ()
	end
	youCanSpawn = true
	if not getTeamFromName("Alive") then
		aliveplayers = createTeam("Alive", 0, 255, 0)
	end
	if not getTeamFromName("Eliminated") then
		eliplayers = createTeam("Eliminated", 120, 120, 120)
	end
	Area = getElementsByType ("gamearea")
	if (Area) then
		tehX = getElementData (Area[1], "posX")
		if (tehX) then
			tehY = getElementData (Area[1], "posY")
			size = getElementData (Area[1], "size")
			gameArea = createColCircle ( tehX, tehY, size )
			if isElement(gameArea) then
				addEventHandler ( "onColShapeHit", gameArea, gameAreaEnter )
				addEventHandler ( "onColShapeLeave", gameArea, gameAreaLeave )
			end
		end
	end
		for k,v in ipairs(getElementsByType("player")) do
			realTime = withdrawTime
			setTimer (triggerClientEvent, 1000, 1, v,"onTheMapStart", v, maxDeaths, vehicleRoot, cameraPos, realTime,  theMode)
			if tonumber(theMode) == 2 then
				triggerClientEvent(v, "theRealTime", v, realTime)
			end
		end
		mapRunning = true
		players = getElementsByType ("player")
		for k,v in ipairs (players) do
			setElementData ( v, "deaths", 0 )
			setElementData ( v, "wins", 0 )
			setPlayerNametagShowing (v, true)
			setPlayerNametagShowing (v, false)
		end
	call(getResourceFromName("scoreboard"), "addScoreboardColumn", "deaths")
	call(getResourceFromName("scoreboard"), "addScoreboardColumn", "wins")
	
	spawnNum = 1
	
end
addEventHandler( "onGamemodeMapStart", root, onMapLoad)

dieBastid = {}
hasSpawned = {}
gameareaEnable = true
function gameAreaLeave ( source )
if (getElementType(source) == "player") then
if hasSpawned[source] == true and gameareaEnable == true then
	triggerClientEvent(source, "displayGUItext", source, 0.3, 0.3, "Return to the gamearea\nor you will die!", "sa-header", 255, 0, 0, 5000)
	dieBastid[source] = setTimer (killPed, 15000, 1, source)
end
end
end

--addCommandHandler("dis", function ()
	--gameareaEnable = false
--end)

function iAmReady()
	if mapRunning == true then
		setTimer (triggerClientEvent, 500, 1, getRootElement(), "getPlayers", getRootElement())
		if tonumber(theMode) == 2 then
			realTime = withdrawTime
			setTimer (triggerClientEvent, 1000, 1, source,"onTheMapStart", source, maxDeaths, vehicleRoot, cameraPos, realTime, theMode)
		else
			realTime = 0
			setTimer (triggerClientEvent, 1000, 1, source,"onTheMapStart", source, maxDeaths, vehicleRoot, cameraPos, realTime, theMode)
		end

	end
end
addEvent("iAmReady", true)
addEventHandler("iAmReady", getRootElement(), iAmReady)

function theTimeLimit ()
	withdrawTime = timelimit
	timeCountDown = setTimer (withdrawTimeFunc, 5000, 0)
	timelimitTimer = setTimer (calculateWinners, tonumber(timelimit), 1)
end

function withdrawTimeFunc ()
	withdrawTime = withdrawTime - 5000
end

function calculateWinners ()
	playerdeaths = {}
	timelimitTimer = nil
	local players = getElementsByType("player")
	if #players > 0 then
		for k,v in ipairs(getElementsByType("player")) do
			if getPlayerTeam(v) == aliveplayers then
				playerdeaths[k] = getElementData(v, "deaths")
			end
		end
		if #playerdeaths > 1 then
			winners = math.min(unpack(playerdeaths))
		else
			for k,v in ipairs(getElementsByType("player")) do
				if getPlayerTeam(v) == aliveplayers then
					winners = getElementData(v, "deaths")
				end
			end
		end
		for k, v in ipairs(getElementsByType("player")) do
			if getElementData(v, "deaths") == winners then
				triggerClientEvent(getRootElement(), "displayGUItext", getRootElement(), 0.3, 0.3, "Winner: "..getPlayerName(v), "sa-header", 0, 0, 255, 5000)
				setElementData ( v, "wins", getElementData(v, "wins") + 1 )
			end
		end
	end
	setTimer(restartGame, 7000, 1)
end

function spawnDisable ()
	youCanSpawn = false
	canSpawn = nil
	triggerClientEvent(getRootElement(), "displayGUItextAll", getRootElement(), "INFO: Spawning is now disabled", 255, 155, 0)
end

function gameAreaEnter ( source )
if (getElementType(source) == "player") then
	triggerClientEvent(source, "displayGUItext", source, 0.45, 0.3, "You are in the gamearea.", "default-bold-small", 0, 0, 255, 3000)
	if dieBastid[source] then
		killTimer ( dieBastid[source] )
		dieBastid[source] = nil
	end
end
end

function spawnThePlayer (vehicle, primaryWeapon, primaryWeapon1, primaryWeapon2, primaryWeapon3, secondaryWeapon, secondaryWeapon1, secondaryWeapon2)
	if ( youCanSpawn == true ) then
	stopSpec ( source )
	if tonumber(theMode) == 1 then
		if getElementData ( source, "deaths" ) == tonumber(maxDeaths) then
			triggerClientEvent(source, "displayGUItext", source, 0.3, 0.3, "YOU ARE ELIMINATED!", "sa-header", 255, 0, 0, 3000)
		else
			priWeapon[source] = primaryWeapon[source]
			priWeapon1[source] = primaryWeapon1[source]
			priWeapon2[source] = primaryWeapon2[source]
			priWeapon3[source] = primaryWeapon3[source]
			secWeapon[source] = secondaryWeapon[source]
			secWeapon1[source] = secondaryWeapon1[source]
			secWeapon2[source] = secondaryWeapon2[source]
			vehicle1[source] = vehicle[source]
			setPlayerTeam(source, aliveplayers)
			spawn = getElementsByType ( "spawnpoint" )
			spawnNum = spawnNum + 1
			if spawnNum > #spawn then
				spawnNum = 1
			end
			hasSpawned[source] = true
			--setCameraMode(source, "fixed")
			setTimer (call, 2000, 1, getResourceFromName("spawnmanager"),"spawnPlayerAtSpawnpoint",source,spawn[spawnNum] )
		end
	else
		priWeapon[source] = primaryWeapon[source]
		priWeapon1[source] = primaryWeapon1[source]
		priWeapon2[source] = primaryWeapon2[source]
		priWeapon3[source] = primaryWeapon3[source]
		secWeapon[source] = secondaryWeapon[source]
		secWeapon1[source] = secondaryWeapon1[source]
		secWeapon2[source] = secondaryWeapon2[source]
		vehicle1[source] = vehicle[source]
		setPlayerTeam(source, aliveplayers)
		spawn = getElementsByType ( "spawnpoint" )
		spawnNum = spawnNum + 1
		if spawnNum > #spawn then
			spawnNum = 1
		end
		hasSpawned[source] = true
		--setCameraMode(source, "fixed")
		setTimer (call, 2000, 1, getResourceFromName("spawnmanager"),"spawnPlayerAtSpawnpoint",source,spawn[spawnNum] )
	end
	else
		local players = getElementsByType("player")
		if  #players <= 2 then
			--outputChatBox("Not enough players, restarting")
			triggerClientEvent(getRootElement(), "displayGUItextAll", getRootElement(), "Too few alive players, restarting", 255, 155, 0)
			setTimer(restartGame, 2000, 1)
		else
			triggerClientEvent(source, "displayGUItext", source, 0.45, 0.3, "Wait for the next round to spawn", "default-bold-small", 255, 255, 255, 3000)
			setPlayerTeam(source, eliplayers)
			spectateGay(source)
		end
	end
end
addEvent ("doTheSpawn", true)
addEventHandler ("doTheSpawn", root, spawnThePlayer )

function reSpawnThePlayer (source)
if tonumber(theMode) == 1 then
	if getElementData ( source, "deaths" ) == tonumber(maxDeaths) then
		triggerClientEvent(source, "displayGUItext", source, 0.3, 0.3, "YOU ARE ELIMINATED!", "sa-header", 255, 0, 0, 3000)
	else
		stopSpec ( source )
		spawn = getElementsByType ( "spawnpoint" )
		spawnNum = spawnNum + 1
			if spawnNum > #spawn then
				spawnNum = 1
			end
		call (getResourceFromName("spawnmanager"),"spawnPlayerAtSpawnpoint",source,spawn[spawnNum] )
	end
else
	stopSpec ( source )
	spawn = getElementsByType ( "spawnpoint" )
	spawnNum = spawnNum + 1
	if spawnNum > #spawn then
		spawnNum = 1
	end
	call (getResourceFromName("spawnmanager"),"spawnPlayerAtSpawnpoint",source,spawn[spawnNum] )
end
end
addCommandHandler ("spawn1", reSpawnThePlayer)

function playerSpawned ( posX, posY, posZ, spawnRotation, theTeam, theSkin, theInterior, theDimension  )
	setElementPosition(source, posX, posY, posZ) -- seems to work as a workaround for the whitescreen issue.
	setTimer(function (source)
		local x, y, z = getElementPosition(source)
		if string.find(tostring(x), "#") ~= nil then
			outputChatBox("whitescreen issue detected, respawning...", source)
			reSpawnThePlayer(source)
		end
		end, 1000, 1, source)
	--if isPlayerNametagShowing (source) == true then
		--outputChatBox("nametag showing, hiding")
	--end
		--setCameraMode ( source, "player" )
		removePedFromVehicle ( source )
		setCameraTarget ( source, source )
		local x, y, z = getElementPosition (source)
		spawnCar = createVehicle (unpack(vehicle1[source]), x + 2, y, z)
		myWeapon = createObject (unpack(priWeapon[source].object), x + 2, y, z + 2)
		attachElements (myWeapon, spawnCar, unpack(priWeapon[source].pos) )
		setElementParent ( myWeapon, spawnCar )
		if priWeapon1[source] ~= nil then
			myWeapon = createObject (unpack(priWeapon[source].object), x + 2, y, z + 2)
			attachElements (myWeapon, spawnCar, unpack(priWeapon1[source].pos) )
			setElementParent ( myWeapon, spawnCar )
		end
		if priWeapon2[source] ~= nil then
			myWeapon = createObject (unpack(priWeapon[source].object), x + 2, y, z + 2)
			attachElements (myWeapon, spawnCar, unpack(priWeapon2[source].pos) )
			setElementParent ( myWeapon, spawnCar )
		end
		if priWeapon3[source] ~= nil then
			myWeapon = createObject (unpack(priWeapon[source].object), x + 2, y, z + 2)
			attachElements (myWeapon, spawnCar, unpack(priWeapon3[source].pos) )
			setElementParent ( myWeapon, spawnCar )
		end
		
		if secWeapon[source] ~= nil then
			mySecWeapon1 = createObject (unpack(secWeapon[source].object), x + 2, y, z + 2)
			attachElements (mySecWeapon1, spawnCar, unpack(secWeapon[source].pos) )
			setElementParent ( mySecWeapon1, spawnCar )
		end
		if secWeapon1[source] ~= nil then
			mySecWeapon2 = createObject (unpack(secWeapon[source].object), x + 2, y, z + 2)
			attachElements (mySecWeapon2, spawnCar, unpack(secWeapon1[source].pos) )
			setElementParent ( mySecWeapon2, spawnCar )
		end
		if secWeapon2[source] ~= nil then
			mySecWeapon3 = createObject (unpack(secWeapon[source].object), x + 2, y, z + 2)
			attachElements (mySecWeapon3, spawnCar, unpack(secWeapon2[source].pos) )
			setElementParent ( mySecWeapon3, spawnCar )
		end
		setElementData ( source, "spawnVehicle", spawnCar )
		maRide = getElementData ( source, "spawnVehicle" )
		triggerClientEvent (source, "noCollBandito", source, myWeapon, mySecWeapon1, mySecWeapon2, mySecWeapon3)
		createBlipAttachedTo ( source, 0, 2, math.random(0,255), math.random(0,255), math.random(0,255) )
		setTimer (warpPedIntoVehicle, 500, 1, source, maRide )
		setVehicleDamageProof ( maRide, true )
		protection = createMarker ( x, y, z, "cylinder", 4, 255, 0, 0, 90 )
		attachElements ( protection, maRide )
		setElementParent ( protection, maRide )
		setTimer (destroyElement, tonumber(protectMe), 1, protection)
		setTimer (setVehicleDamageProof, tonumber(protectMe), 1, maRide, false)
	if tonumber(theMode) == 1 then
		if getElementData ( source, "deaths" ) == tonumber(maxDeaths) then
			triggerClientEvent(source, "displayGUItext", source, 0.3, 0.3, "YOU ARE ELIMINATED!", "sa-header", 255, 0, 0, 3000)
			killPed ( source )
		end
	end
end
addEventHandler ("onPlayerSpawn", root, playerSpawned)

function VehicleShot ( x, y, z )
	createExplosion ( x, y, z, 12, source )
end
addEvent ( "VehicleShot", true )
addEventHandler ( "VehicleShot", getRootElement(), VehicleShot )

landmine = {}
function zeMINE ( sX, sY, sZ )
	landmine[source] = createObject ( 1252, sX, sY, sZ - 0.8 )
	setTimer (zeMINE1, 1000, 1, source)
end
addEvent ( "zeMINE", true )
addEventHandler ( "zeMINE", getRootElement(), zeMINE )

landminecol = {}
function zeMINE1 ( source )
if isElement(landminecol[source]) then
	destroyElement (landminecol[source])
end
	x, y, z = getElementPosition ( landmine[source] )
	landminecol[source] = createColSphere ( x, y, z, 3 )
	setElementParent ( landmine[source], landminecol[source] )
	addEventHandler("onColShapeHit", landminecol[source], function()
		local posx, posy, posz = getElementPosition ( landminecol[source] )
		createExplosion (posx, posy, posz, 8)
		destroyElement ( landminecol[source] )
	end)
end

oil = {}
function zeSlippery ( sX, sY, sZ )
	local rx, ry, rz = getVehicleRotation(getPedOccupiedVehicle(source))
	if isElement(oil[source]) then
		destroyElement(oil[source])
	end
	oil[source] = createObject(17453, sX, sY, sZ - 0.65, ry, -rx, rz + 90)
	triggerClientEvent(getRootElement(), "oilScale", getRootElement(), oil)
	setTimer (zeSlippery1, 1000, 1, source)
end
addEvent("zeSlippery", true)
addEventHandler("zeSlippery", getRootElement(), zeSlippery)

oilcol = {}
function zeSlippery1 (source)
	if isElement(oilcol[source]) then
		destroyElement(oilcol[source])
	end
	x, y, z = getElementPosition(oil[source])
	oilcol[source] = createColSphere ( x, y, z, 4 )
	setElementParent (oil[source], oilcol[source])
	addEventHandler("onColShapeHit", oilcol[source], function (hitElement, matchingDimension)
		if getElementType(hitElement) == "vehicle" then
			local rx, ry, rz = getVehicleTurnVelocity(hitElement)
			setVehicleTurnVelocity(hitElement, rx, ry, rz + 0.3)
		end
	end)
end

stinger = {}
function zeStinger ( sX, sY, sZ )
	stinger[source] = createObject ( 1593, sX, sY, sZ - 0.5 )
	setTimer (zeStinger1, 1000, 1, source)
end
addEvent ( "zeStinger", true )
addEventHandler ( "zeStinger", getRootElement(), zeStinger )

stingercol = {}
function zeStinger1 ( source )
if isElement(stingercol[source]) then
	destroyElement (stingercol[source])
end
	x, y, z = getElementPosition ( stinger[source] )
	stingercol[source] = createColSphere ( x, y, z, 3 )
	setElementParent ( stinger[source], stingercol[source] )
	addEventHandler("onColShapeHit", stingercol[source], function ( Daplayer, matchingDimension )
		local vehicle = getPedOccupiedVehicle ( Daplayer )
		local randDamage = math.random(1,4)
		if ( randDamage == 1 ) then
			setVehicleWheelStates ( vehicle, -1, -1, -1, 1 )
		elseif ( randDamage == 2 ) then
			setVehicleWheelStates ( vehicle, -1, -1, 1, -1 )
		elseif ( randDamage == 3 ) then
			setVehicleWheelStates ( vehicle, -1, 1, -1, -1 )
		elseif ( randDamage == 4 ) then
			setVehicleWheelStates ( vehicle, 1, -1, -1, -1 )
		end
		destroyElement ( stingercol[source] )
	end)
end

function PlayerJoin()
	if tonumber(theMode) == 1 then
		outputChatBox("Mode: Elimination", source)
	elseif tonumber(theMode) == 2 then
		outputChatBox("Mode: Deathmatch", source)
	end
	local players = getPlayersInTeam(getTeamFromName("Alive"))
	if #players > 2 then
		playerdeaths = {}
		for k,v in ipairs(players) do
			playerdeaths[k] = getElementData(v, "deaths")
		end
		mindeath = math.min(unpack(playerdeaths))
		maxdeath = math.max(unpack(playerdeaths))
		newdeaths = ( maxdeath + mindeath ) / 2
		setElementData ( source, "deaths", math.floor(newdeaths) )
	else
		setElementData ( source, "deaths", 0 )
	end
	if (oil) then
		triggerClientEvent(source, "oilScale", source, oil)
	end
	setElementData ( source, "wins", 0 )
	setPlayerNametagShowing (source, false)
end
addEventHandler ( "onPlayerJoin", root, PlayerJoin )

function testDeads ( source )
if tonumber(theMode) == 1 then
local players = getElementsByType("player")
if #players > 0 then
	alivePlayers = countPlayersInTeam ( getTeamFromName("Alive") )
	if alivePlayers == 1 then
		local players = getPlayersInTeam(getTeamFromName("Alive"))
		for k,v in ipairs(players) do
			--showTextForAll ( 5000, 0, 0, 255, 2.0, getClientName (v) .." has Survived the match!" )
			triggerClientEvent(getRootElement(), "displayGUItext", getRootElement(), 0.3, 0.3, getPlayerName (v) .." has Survived the match!", "sa-header", 0, 0, 255, 3000)
			setElementData ( v, "wins", getElementData ( v, "wins" ) + 1 )
			setTimer ( restartGame, 5000, 1, source )
		end
	end
else
	restartGame()
end
end
end
addCommandHandler ("didiwin", testDeads)

lastEli = 0
function PlayerWasted ( ammo, attacker, weapon, bodypart )
	if isElement(stingercol[source]) then
		destroyElement (stingercol[source])
	end
	if isElement(landminecol[source]) then
		destroyElement (landminecol[source])
	end

if tonumber(theMode) == 1 and getElementData ( source, "deaths" ) == tonumber(maxDeaths) then return

else
		setElementData ( source, "deaths", getElementData ( source, "deaths" ) + 1 )
		if tonumber(theMode) == 1 and getElementData ( source, "deaths" ) == tonumber(maxDeaths) then
			setPlayerTeam(source, eliplayers)
			alivePlayers = countPlayersInTeam ( getTeamFromName("Alive") )
			if alivePlayers == 1 then
				spectateGay ( source )
				local players = getPlayersInTeam(getTeamFromName("Alive"))
				for k,v in ipairs(players) do
					triggerClientEvent(getRootElement(), "displayGUItext", getRootElement(), 0.3, 0.3, getPlayerName (v) .." has Survived the match!", "sa-header", 0, 0, 255, 3000)
					setElementData ( v, "wins", getElementData ( v, "wins" ) + 1 )
					setTimer ( removePedFromVehicle, 8000, 1, source )
					setTimer ( restartGame, 10000, 1, source )
					destroyBlipsAttachedTo ( source )
				end
			else
				triggerClientEvent(getRootElement(), "displayGUItextAll", getRootElement(), getPlayerName (source) .. " has been eliminated!", 255, 0, 0)
				setPlayerTeam(source, eliplayers)
				destroyBlipsAttachedTo ( source )
				spectateGay ( source )
				call(getResourceFromName("snake"), "startSnake", source)
			end
		else
			local deaths = getElementData(source, "deaths")
			if tonumber(theMode) == 1 then
				triggerClientEvent(getRootElement(), "displayGUItextAll", getRootElement(), getPlayerName (source) .. " died. ("..deaths.."/"..tonumber(maxDeaths).." deaths)", 0, 255, 0)
			elseif tonumber(theMode) == 2 then
				triggerClientEvent(getRootElement(), "displayGUItextAll", getRootElement(), getPlayerName (source) .. " died. ("..deaths.." deaths)", 0, 255, 0)
			end
			setTimer ( reSpawnThePlayer, tonumber(respawnMe), 1, source )
			destroyBlipsAttachedTo ( source )
		end
	end
end
addEventHandler ( "onPlayerWasted", root, PlayerWasted )
addEvent ("onInterstatePlayerWasted")

function vehicleExplode ()
	for k,v in ipairs(getAttachedElements(source)) do
		destroyElement(v)
	end
	setTimer ( destroyElement, 10000, 1, source )
end
addEventHandler ( "onVehicleExplode", root, vehicleExplode )

function vehicleDamage ( loss )
if getVehicleOccupant (source) then
	triggerClientEvent (getVehicleOccupant(source), "damageVehicle", source, loss ) 
	driver = getVehicleOccupant(source)
	vehHealth = getElementHealth(source) - loss
	vehHealth = vehHealth / 10
	if vehHealth < 10 then
		vehHealth = 10
	end
	setElementHealth ( driver, vehHealth )
end
end
addEventHandler ( "onVehicleDamage", root, vehicleDamage )

function vehicleEnter ( vehicle, seat, jacked )
	local vehicle1 = getPedOccupiedVehicle ( source )
	triggerClientEvent (source, "damageVehicle", vehicle1 ) 
	triggerClientEvent (source, "enterVehicle", source )
end
addEventHandler ("onPlayerVehicleEnter", root, vehicleEnter)


function vehicleExit ( source )
	cancelEvent()
	outputChatBox ( "Stay in the car!", source )
end
addEventHandler ("onVehicleStartExit", root, vehicleExit)

function restartGame ( source )
triggerClientEvent(getRootElement(), "displayGUItextAll", getRootElement(), "-=Game is restarting=-", 100, 100, 255)
triggerEvent("onRoundFinished", getResourceRootElement(getThisResource()))
	priWeapon = {}
	priWeapon1 = {}
	priWeapon2 = {}
	priWeapon3 = {}
	secWeapon = {}
	secWeapon1 = {}
	secWeapon2 = {}
	vehicle1 = {}
	for k,v in ipairs(getElementsByType("colshape")) do
		destroyElement ( v )
	end
	gameArea = createColCircle ( tehX, tehY, size )
	if isElement(gameArea) then
		addEventHandler ( "onColShapeHit", gameArea, gameAreaEnter )
		addEventHandler ( "onColShapeLeave", gameArea, gameAreaLeave )
	end
	for k,v in ipairs (getElementsByType("vehicle")) do
		destroyElement (v)
	end
	for k,v in ipairs(getElementsByType("player")) do
		--if isPlayerDead(v) then
			call(getResourceFromName("snake"), "stopSnake", v)
		--end
		destroyBlipsAttachedTo (v)
		removePedFromVehicle (v)
		hasSpawned[v] = false
		setCameraTarget ( v, v )
		setElementData ( v, "deaths", 0 )
		setTimer(triggerClientEvent, 1000, 1, v, "vehicleChooser", v )
		setTimer(triggerClientEvent, 500, 1, v, "resetDeaths", v )
	end
	if ( canSpawn ) then
		killTimer (canSpawn)
		canSpawn = setTimer (spawnDisable, tonumber(allowSpawn), 1 )
		youCanSpawn = true
	else
		if tonumber(theMode) == 1 then
			canSpawn = setTimer (spawnDisable, tonumber(allowSpawn), 1 )
			youCanSpawn = true
		elseif tonumber(theMode) == 2 then
			if timeCountDown then
				killTimer(timeCountDown)
				timeCountDown = nil
			end
			if timelimitTimer then
				killTimer(timelimitTimer)
				timelimitTimer = nil
			end
			theTimeLimit ()
			withdrawTime = timelimit
			realTime = withdrawTime
			for k,v in ipairs(getElementsByType("player")) do
				triggerClientEvent(v, "theRealTime", v, realTime)
			end
		end
	end
end
addCommandHandler ("restartNOW", restartGame)

function mapStop()
	for k,v in ipairs(getElementsByType("colshape")) do
		destroyElement ( v )
	end
	for k,v in ipairs (getElementsByType("vehicle")) do
		destroyElement (v)
	end
	for k,v in ipairs(getElementsByType("player")) do
		removePedFromVehicle (v)
		call(getResourceFromName("snake"), "stopSnake", v)
		destroyBlipsAttachedTo (v)
		setCameraTarget ( v, v )
		setPlayerTeam(v, nil)
		setElementData ( v, "deaths", 0 )
		setPlayerNametagShowing (v, true)
	end
	if ( canSpawn ) then
		killTimer (canSpawn)
		canSpawn = nil
	end
	if timeCountDown then
		killTimer(timeCountDown)
		timeCountDown = nil
	end
	triggerClientEvent(getRootElement(), "onTheMapStop", getRootElement())
	if ( timelimitTimer ) then
		killTimer (timelimitTimer)
		timelimitTimer = nil
	end
	call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "deaths")
	call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "wins")
end
addEventHandler("onGamemodeMapStop", getRootElement(), mapStop)


function playerQuit ( )
if tonumber(theMode) == 1 then
	setTimer( testDeads, tonumber(respawnMe) + 500, 1)
end
local vehicle = getPedOccupiedVehicle(source)
if vehicle then
	for k,v in ipairs(getAttachedElements(getPedOccupiedVehicle(source))) do
		destroyElement(v)
	end
	destroyElement(getPedOccupiedVehicle(source))
end
	destroyBlipsAttachedTo ( source )
	setPlayerTeam(source, nil)
end 
addEventHandler( "onPlayerQuit", root, playerQuit )

function resourceStop ( name )
	if getThisResource() ~= name then return end
	for k,v in ipairs(getElementsByType("player")) do
		setPlayerNametagShowing (v, true)
	end
	call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "deaths")
	call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "wins")
end

function stopFire ()
	for k,v in ipairs(getElementsByType("player")) do
		if v ~= source then
			triggerClientEvent ( v, "stopBullets", source )
		end
	end
end
addEvent ( "stopFire", true )
addEventHandler ( "stopFire", getRootElement(), stopFire )

function startFire ()
for k,v in ipairs(getElementsByType("player")) do
	if v ~= source then
		triggerClientEvent ( v, "zeBullet", source )
	end
end
end
addEvent ( "startFire", true )
addEventHandler ( "startFire", getRootElement(), startFire )

function stopFireLaser ()
	for k,v in ipairs(getElementsByType("player")) do
		if v ~= source then
			triggerClientEvent ( v, "stopLaserBeam", source )
		end
	end
end
addEvent ( "stopFireLaser", true )
addEventHandler ( "stopFireLaser", getRootElement(), stopFireLaser )

function startFireLaser ()
for k,v in ipairs(getElementsByType("player")) do
	if v ~= source then
		triggerClientEvent ( v, "zeLaserBeam", source )
	end
end
end
addEvent ( "startFireLaser", true )
addEventHandler ( "startFireLaser", getRootElement(), startFireLaser )

--spect = {}
function spectateGay ( source )
--if isPlayerDead(source) then
	bindKey (source, "F1", "down", spectateNext)
	bindKey (source, "F2", "down", spectatePrev)
	--bindKey (source, "F3", "down", stopSpec)
	setElementData ( source, "spect", 1 )
	--spect[source] = 1
	--setCameraMode(source, "fixed")
	--setCameraMode ( source, "player" )
	spectateNext ( source )
	outputChatBox ("Press F1 to spectate another player, F2 for previous player", source, 0, 255, 0)
--end
end
addCommandHandler ("spec", spectateGay)

getPlayerSpectatee = {}
function spectateNext (source) -- THIS IS THE FUNCTION USED TO SWICH WHO IS BEING SPECTATED BY PRESSING R
		--if ( isPlayerDead ( source ) ) then --IF THE PLAYER IS DEAD
			local specPlayer = getPlayerSpectatee[source] -- gets the spectatee player
			if not specPlayer then 
				specPlayer = 1 
			end
			local playersTable = getPlayersInTeam ( getTeamFromName("Alive") )
			playersTable = filterPlayersTable ( playersTable )
			--
			local playerCount = #playersTable
			if playerCount == 0 then
				--outputSpectateMessage("Nobody to Spectate",player) -- IF ITS JUST THE 1 PLAYER, SPECTATING IS IMPOSSIBLE
			else
		
				specPlayer = specPlayer+1
				if playersTable[specPlayer] == source then
					specPlayer = specPlayer+1
				end
				if specPlayer > playerCount then
					specPlayer = 1
				end
				--setCameraMode ( source, "player" )    
				setCameraTarget ( source, playersTable[specPlayer] )
				--outputSpectateMessage("Now spectating "..getClientName(playersTable[specPlayer]),source)
				getPlayerSpectatee[source] = specPlayer
			end
		--end
end
addCommandHandler ("next", spectateNext)

function spectatePrev ( source )
--if isPlayerDead(source) then
		--if ( isPlayerDead ( source ) ) then --IF THE PLAYER IS DEAD
			local specPlayer = getPlayerSpectatee[source] -- gets the spectatee player
			if not specPlayer then 
				specPlayer = 1 
			end
			local playersTable = getPlayersInTeam ( getTeamFromName("Alive") )
			playersTable = filterPlayersTable ( playersTable )
			--
			local playerCount = #playersTable
			if playerCount == 0 then
				--outputSpectateMessage("Nobody to Spectate",player) -- IF ITS JUST THE 1 PLAYER, SPECTATING IS IMPOSSIBLE
			else
				specPlayer = specPlayer-1
				if playersTable[specPlayer] == source then
					specPlayer = specPlayer-1
				end
				if specPlayer < 1 then
					specPlayer = playerCount
				end
				--setCameraMode ( source, "player" )    
				setCameraTarget ( source, playersTable[specPlayer] )
				--outputSpectateMessage("Now spectating "..getClientName(playersTable[specPlayer]),source)
				getPlayerSpectatee[source] = specPlayer
			end
		--end
--end
end
addCommandHandler ("prev", spectatePrev)

function filterPlayersTable ( playerTable ) --this function clears out useless players from spectators table
	for k,v in ipairs(playerTable) do
		if isPedDead ( v ) then
			table.remove(playerTable,k)
		end
	end
	return playerTable
end

function stopSpec ( source )
	--setCameraMode ( source, "player" )
	if isKeyBound(source, "F1") then
		unbindKey (source, "F1", "down", spectateNext)
	end
	if isKeyBound(source, "F2") then
		unbindKey (source, "F2", "down", spectatePrev)
	end
	--unbindKey (source, "F3", "down", stopSpec)
	setCameraTarget ( source, source )
	--setTimer ( spawnThePlayer, tonumber(respawnMe), 1, source )
end
addCommandHandler ( "stopspec", stopSpec )

function addHealthVehicle ()
	local vehicle1 = getPedOccupiedVehicle ( source )
	setElementHealth (vehicle1, 1500)
	setElementData (source, "armor1", true)
end
addCommandHandler ( "testhealth", addHealthVehicle )
addEvent ("zeArmor", true)
addEventHandler ("zeArmor", root, addHealthVehicle)

function addNitroVehicle ()
	local vehicle1 = getPedOccupiedVehicle ( source )
	addVehicleUpgrade(vehicle1, 1010)
end
addEvent("zeNOS", true)
addEventHandler("zeNOS", root, addNitroVehicle)

addEventHandler("onResourceStop", getRootElement(), function ()
	for k,v in ipairs(getElementsByType("player")) do
		setCameraTarget ( v, v )
		unbindKey (v, "F1", "down", spectateNext)
		unbindKey (v, "F2", "down", spectatePrev)
		unbindKey (v, "F3", "down", stopSpec)
	end
end)

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

