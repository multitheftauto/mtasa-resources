local resourceRoot = getResourceRootElement ( getThisResource() )
local root = getRootElement()
local moneybags, keycards, cols = {}, {}, {}
local attackers, currentObj, isInterior = nil, nil, nil
local wanted, money = 0, 0
local display = {}

local van = createVehicle ( 428, 2510.85, 2394.33, 11.30, 0, 0, 90 )
	setElementData ( van, "noRespawn", true )
	setElementData ( van, "posX", 2510.85 )
	setElementData ( van, "posY", 2394.33 )
	setElementData ( van, "posZ", 11.3 )
	setElementData ( van, "rotX", 0 )
	setElementData ( van, "rotY", 0 )
	setElementData ( van, "rotZ", 90 )

	-- === MISC FUNCTIONS ===
	-- =========================

	-- this function changes the wanted level for the entire team
function wantedLevel ( level )
	for i, v in ipairs ( getPlayersInTeam ( attackers ) ) do
		setPlayerWantedLevel ( v, level )
	end
end

	-- this function changes the amount of cash for the entire team
function setCash ( amount )
	for i, v in ipairs ( getPlayersInTeam ( attackers ) ) do
		setPlayerMoney ( v, amount )
	end
end

	-- setting the current wanted level and amount of cash for the attackers and interior when needed
function playerStats ( spawnpoint )
	if ( isInterior ) then
		setTimer ( setElementInterior, 200, 1, source, 1 )
	end
	if ( getPlayerTeam ( source ) == attackers ) then
		setPlayerHudComponentVisible( source, "money", true )
		setPlayerWantedLevel ( source, wanted )
		--setPlayerMoney ( source, money )
	end
end

	-- update the text item, if the health reaches a critical state the text turns red
function damageVehicle ( loss )
	local health = math.floor ( getElementHealth ( van ) )
	if ( health < 1000 ) and ( health > 600 ) then
		textItemSetColor ( display.vanText, 250, 0, 20, 255 )
	end
	textItemSetText ( display.vanText, tostring ( health ) )
end

	-- showing health to the driver / passenger
function displayHealth ( player, seat, jacker )
	textDisplayAddObserver ( display.vanTextDisplay, player )
end

	-- hiding health
function hideHealth ( player, seat, jacker )
	textDisplayRemoveObserver ( display.vanTextDisplay, player )
end

	-- respawning the van
function spawnVan ( delay, x, y, z, rx, ry, rz )
	local health = 1000
	local count = math.floor ( getPlayerCount() / 2 )
	count = count * 500
	health = ( count <= 4000 ) and health + count or 5000
	delay = delay or 10000

	if not ( x and y and z ) then
		x, y, z = getElementPosition ( van )
		rx, ry, rz = getVehicleRotation ( van )
		z = z - 20
	end
	if ( currentObj == "none" ) then
		setTimer ( setVehicleLocked, delay + 100, 1, van, true )
	end

	textItemSetText ( display.vanText, tostring ( health ) )
	textItemSetColor ( display.vanText, 255, 255, 255, 255 )
	setTimer ( spawnVehicle, delay, 1, van, x, y, z, 0, 0, rz )
	setTimer ( setElementHealth, delay + 100, 1, van, health )
end

	-- destroying blips attached to an element
function destroyBlipsAttachedTo ( element )
	for i, v in ipairs ( getAttachedElements ( element ) ) do
		if ( getElementType ( v ) == "blip" ) then
			destroyElement ( v )
		end
	end
end

	-- === ON MAP START & END ===
	-- ============================

function scriptResourceStart()
		-- some objects need to be visible inside
	local door = getElementByID ( "door" )
	local doortwo = getElementByID ( "doortwo" )
	local vaultdoor = getElementByID ( "vaultdoor" )
	local pillar = getElementByID ( "pillar" )
	setElementInterior ( door, 1 )
	setElementInterior ( doortwo, 1 )
	setElementInterior ( vaultdoor, 1 )
	setElementInterior ( pillar, 1 )
end

function scriptStartRound ( attacker )
		-- in the beginning the attackers have no money or wanted level
	attackers = attacker
	currentObj = "none"
	wanted = 0
	money = 0

		-- displaying the van's health
	display.vanTextDisplay = textCreateDisplay()
	display.vanText = textCreateTextItem ( "10000", 0.72, 0.07, "high", 255, 255, 255, 255, 2, "center", "top" )
	display.vanText2 = textCreateTextItem ( "van armor", 0.722, 0.11, "high", 255, 255, 255, 255, 1.5, "center", "top" )
	textDisplayAddText ( display.vanTextDisplay, display.vanText )
	textDisplayAddText ( display.vanTextDisplay, display.vanText2 )
	addEventHandler ( "onVehicleEnter", van, displayHealth )
	addEventHandler ( "onVehicleExit", van, hideHealth )

		-- resetting the van's position, locking it for now and giving it extra armor
	local x, y, z = getElementData ( van, "posX" ), getElementData ( van, "posY" ), getElementData ( van, "posZ" )
	local rx, ry, rz = getElementData ( van, "rotX" ), getElementData ( van, "rotY" ), getElementData ( van, "rotZ" )
	spawnVan ( 1000, x, y, z, rx, ry, rz )
	addEventHandler ( "onVehicleDamage", van, damageVehicle )

		-- locking the tank, secret shh!
	local tank = getElementByID ( "tank" )
	setVehicleLocked ( tank, true )

		-- opening garage doors
	local gdoor = getElementByID ( "gdoor" )
	local gdoortwo = getElementByID ( "gdoortwo" )
	local x, y, z = getElementData ( gdoor, "posX" ), getElementData ( gdoor, "posY" ), getElementData ( gdoor, "posZ" )
	local x2, y2, z2 = getElementData ( gdoortwo, "posX" ), getElementData ( gdoortwo, "posY" ), getElementData ( gdoortwo, "posZ" )
	setElementPosition ( gdoor, x, y, z )
	setElementPosition ( gdoortwo, x2, y2, z2 )
end

function scriptEndRound ( conquered )
	textDestroyTextItem ( display.vanText )
	textDestroyTextItem ( display.vanText2 )
	textDestroyDisplay ( display.vanTextDisplay )
	removeEventHandler ( "onVehicleEnter", van, displayHealth )
	removeEventHandler ( "onVehicleExit", van, hideHealth )
	removeEventHandler ( "onVehicleDamage", van, damageVehicle )

		-- cleaning up
	if ( currentObj ~= "none" ) and ( currentObj ~= "bombs" ) and ( currentObj ~= "outfits" ) then
		destroyBlipsAttachedTo ( van )

		if ( currentObj == "securicar" ) then
			scriptRemoveSecuricar()

		elseif ( currentObj == "park" ) then
			scriptRemovePark()

		elseif ( currentObj == "casino" ) then
			scriptRemoveCasino()

		elseif ( currentObj == "key" ) then
			scriptRemoveKey()
			scriptRemoveCasino() -- closing the entrance

		elseif ( currentObj == "keycard" ) then
			scriptRemoveCasino() -- closing the entrance
		else
				-- resetting the first door's rotation, position remains the same
			local door = getElementByID ( "door" )
			local rx, ry, rz = getElementData ( door, "rotX" ), getElementData ( door, "rotY" ), getElementData ( door, "rotZ" )
			setObjectRotation ( door, rx, ry, rz )

			if ( currentObj ~= "vault" ) then
					-- putting the vault door in the right place
				local vaultdoor = getElementByID ( "vaultdoor" )
				local x, y, z = getElementData ( vaultdoor, "posX" ), getElementData ( vaultdoor, "posY" ), getElementData ( vaultdoor, "posZ" )
				local rx, ry, rz = getElementData ( vaultdoor, "rotX" ), getElementData ( vaultdoor, "rotY" ), getElementData ( vaultdoor, "rotZ" )
				setElementPosition ( vaultdoor, x, y, z )
				setObjectRotation ( vaultdoor, rx, ry, rz )

					-- placing the pillar back to its original position
				local pillar = getElementByID ( "pillar" )
				local x, y, z = getElementData ( pillar, "posX" ), getElementData ( pillar, "posY" ), getElementData ( pillar, "posZ" )
				local rx, ry, rz = getElementData ( pillar, "rotX" ), getElementData ( pillar, "rotY" ), getElementData ( pillar, "rotZ" )
				setElementPosition ( pillar, x, y, z )
				setObjectRotation ( pillar, rx, ry, rz )

				if ( currentObj == "money" ) then
						-- destroy any remaining bags
					for i, v in ipairs ( moneybags ) do
						destroyElement ( v )
					end
					setCash ( 0 )
					scriptRemoveMoney()
				else
					setCash ( 0 )
						-- resetting the second door's rotation, position remains the same
					local doortwo = getElementByID ( "doortwo" )
					rx, ry, rz = getElementData ( doortwo, "rotX" ), getElementData ( doortwo, "rotY" ), getElementData ( doortwo, "rotZ" )
					setObjectRotation ( doortwo, rx, ry, rz )

					if ( currentObj == "backdoor" ) then
						scriptRemoveBackdoor()
					elseif ( currentObj == "hideout" ) then
						scriptRemoveHideout()
					end
				end
			end
		end
	end
end

	-- === OBJECTIVES ===
	-- ====================


	-- (( OBJECTIVE: SECURICAR )) --

	-- check if the jacker is an attacker otherwise don't let him enter the van, OBJECTIVE DONE!
function scriptJacker ( player, seat, jacked )
	if ( getPlayerTeam ( player ) == attackers ) then
		call ( getResourceFromName( "assault" ), "triggerObjective", "securicar" )
	else cancelEvent()
		outputChatBox ( "you've got better things to do :P", player )
	end
end

	-- set attacker's wanted level to 1, unlock the van and prevent the defenders from entering it
function scriptCreateSecuricar()
	setVehicleLocked ( van, false )
	createBlipAttachedTo ( van, 51 )
	wanted = 1
	wantedLevel ( wanted )
	addEventHandler ( "onVehicleStartEnter", van, scriptJacker )
end

	-- increase wanted level to 2
function scriptEndSecuricar()
	wanted = 2
	wantedLevel ( wanted )
end
	-- cleaning up
function scriptRemoveSecuricar()
	removeEventHandler ( "onVehicleStartEnter", van, scriptJacker )
end


	-- (( OBJECTIVE: PARK )) --

	-- if the van is in the colshape change the marker's color
function parkColShapeEnter ( player, dimension )
	if ( player == van ) then
		setMarkerColor ( cols.parkMarker, 200, 0, 133, 255 )
		setElementData ( cols.parkCol, "state", true )
	end
end

	-- if the van left in the colshape change the marker's color back
function parkColShapeLeave ( player, dimension )
	if ( player == van ) then
		setMarkerColor ( cols.parkMarker, 255, 128, 64, 255 )
		setElementData ( cols.parkCol, "state", false )
	end
end

	-- when the driver exits the vehicle check if he's in the colshape, OBJECTIVE DONE!
function parkColShape ( player, seat, jacker )
	if ( getElementData ( cols.parkCol, "state" ) ) and ( seat == 0 ) then
		call ( getResourceFromName( "assault" ), "triggerObjective", "park" )
	end
end

	-- create a col marker
function scriptCreatePark ( obj )
	cols.parkCol = createColCircle ( obj.posX, obj.posY, 4 )
	cols.parkMarker = createMarker ( obj.posX, obj.posY, obj.posZ, "cylinder", 4, 255, 128, 64, 255 )
	createBlipAttachedTo ( cols.parkMarker, 0, 2, 255, 128, 64, 255 )
	addEventHandler ( "onColShapeHit", cols.parkCol, parkColShapeEnter )
	addEventHandler ( "onColShapeLeave", cols.parkCol, parkColShapeLeave )
	addEventHandler ( "onVehicleExit", van, parkColShape )
end

	-- locking the car and setting it a new respawn position
function scriptEndPark()
	local x, y, z = 2288.05, 1733.72, 10.82
	local rx, ry, rz = 0, 0, 270
	spawnVan ( 1000, x, y, z, rx, ry, rz )
	setTimer ( setVehicleLocked, 2000, 1, van, true )
end

	-- cleaning up
function scriptRemovePark()
	removeEventHandler ( "onColShapeHit", cols.parkCol, parkColShapeEnter )
	removeEventHandler ( "onColShapeLeave", cols.parkCol, parkColShapeLeave )
	removeEventHandler ( "onVehicleExit", van, parkColShape )
	destroyBlipsAttachedTo ( cols.parkMarker )
	destroyElement ( cols.parkMarker )
	destroyElement ( cols.parkCol )
end


	-- (( OBJECTIVE: CASINO )) --

	-- teleporting the player in the casino, making the teleport marker invisible
function enterCasino ( player, dimension )
	setElementInterior ( player, 1, 2233.85, 1698.85, 1008.35 )
	setPedRotation ( player, 180 )
end

	-- teleporting the player outside, making the teleport marker visible again
function leaveCasino ( player, dimension )
	setElementInterior ( player, 0, 2183.67, 1677.30, 11.07 )
end

	-- create 2 col markers that let you in and out the casino
function scriptCreateCasino()
	local x, y, z = 2195.28, 1677.15, 12.37
	local x2, y2, z2 = 2234.00, 1713.55, 1012.17
	cols.teleCol = createColCircle ( x, y, 2 )
	cols.teleCol2 = createColCircle ( x2, y2, 2 )
	cols.teleMarker = createMarker ( x, y, z + 1.8, "arrow", 2, 255, 128, 64, 255 )
	cols.teleMarker2 = createMarker ( x2, y2, z2 + 1.8, "arrow", 2, 255, 128, 64, 255 )
	cols.teleBlip = createBlipAttachedTo ( cols.teleMarker, 31 )
	setElementInterior ( cols.teleMarker2, 1 )
	addEventHandler ( "onColShapeHit", cols.teleCol, enterCasino )
	addEventHandler ( "onColShapeHit", cols.teleCol2, leaveCasino )
end

	-- if anyone for some reason remained outside kill them so they spawn in the interior
function scriptEndCasino()
	for i, v in ipairs ( getElementsByType ( "player" ) ) do
		if ( getElementInterior ( v ) == 0 ) and ( not isPedDead ( v ) ) then
			killPed ( v )
		end
	end
end

	-- cleaning up
function scriptRemoveCasino()
	removeEventHandler ( "onColShapeHit", cols.teleCol, enterCasino )
	removeEventHandler ( "onColShapeHit", cols.teleCol2, leaveCasino )
	destroyBlipsAttachedTo ( cols.teleMarker )
	destroyElement ( cols.teleMarker )
	destroyElement ( cols.teleMarker2 )
	destroyElement ( cols.teleCol )
	destroyElement ( cols.teleCol2 )
end


	-- (( OBJECTIVE: KEY )) --

	-- creating a custom pickup, making it glow if it's a keycard
function customPickup ( x, y, z, ID, createGlow )
	local pickup = createPickup ( x, y, z, 3, ID, 0 )
	if ( createGlow ) then
		local glow = createMarker ( x, y, z, "corona", 1, 255, 255, 200, 80 )
		local blip = createBlip ( x, y, z, 0, 1, 255, 255, 150, 50 )
		setElementData ( pickup, "glow", glow )
		setElementData ( pickup, "blip", blip )
		setElementInterior ( glow, 1 )
		setElementInterior ( blip, 1 )
	end
	setElementInterior ( pickup, 1 )
	return pickup
end

	-- destroy a pickup when somebody picks it up
function destroyPickup ( pickup, theTable, isGlow )
	for i, v in ipairs ( theTable ) do
		if ( pickup == v ) then
			if ( isGlow ) then
				destroyElement ( getElementData ( pickup, "glow" ) )
				destroyElement ( getElementData ( pickup, "blip" ) )
			end
			destroyElement ( v )
			table.remove ( theTable, i )
			break
		end
	end
end

	-- do nothing if the player is not an attacker, check if the real keycard is picked up, OBJECTIVE DONE!
function checkCard ( player )
	if ( getPickupType ( source ) == 3 ) then
		if ( getPlayerTeam ( player ) == attackers ) then
			if ( getElementData ( source, "theone" ) ) then
				call ( getResourceFromName( "assault" ), "triggerObjective", "key" )
			else destroyPickup ( source, keycards, true )
			end
		else cancelEvent()
		end
	end
end

	-- creating 8 keycards scattered around the place, only 1 is real
function scriptCreateKey()
	local cards = getElementsByType ( "card" )
	for i, v in ipairs ( cards ) do
		local x, y, z = getElementData ( v, "posX" ), getElementData ( v, "posY" ), getElementData ( v, "posZ" )
		table.insert ( keycards, customPickup ( x, y, z, 1581, true ) )
	end
	isInterior = true
	setElementData ( keycards[math.random ( 1, 8 )], "theone", true )
	addEventHandler ( "onPickupUse", root, checkCard )
end

	-- destroy the remaining keycards
function scriptRemoveKey()
	removeEventHandler ( "onPickupUse", root, checkCard )
	for i, v in ipairs ( keycards ) do
		destroyElement ( getElementData ( v, "glow" ) )
		destroyElement ( getElementData ( v, "blip" ) )
		destroyElement ( v )
	end
	keycards = {}
end


	-- (( OBJECTIVE: KEYCARD )) --

	-- opening the door
function openDoor ( ID )
	local door = getElementByID ( ID )
	local x, y, z = getElementData ( door, "posX" ), getElementData ( door, "posY" ), getElementData ( door, "posZ" )
	moveObject ( door, 1000, x, y, z, 0, 0, 100 )
end

	-- open the first door
function scriptEndKeycard()
	openDoor ( "door" ) -- rotation 260, 0, 0 ( + 20 )
end


	-- (( OBJECTIVE: VAULT )) --

	-- place a bomb and blow up the door, block the first door
function scriptEndVault ( players )
	local vaultdoor = getElementByID ( "vaultdoor" )
	local pillar = getElementByID ( "pillar" )
	local bomb = createObject ( 1252, 2144.60, 1626.80, 994.50, 0, 40, 0 )
	local bombGlow = createMarker ( 2144.60, 1626.80, 994.50, "corona", 1, 255, 255, 200, 80 )

	for i, v in ipairs ( players ) do
		setTimer ( playSoundFrontEnd, 100, 1, v, 4 )
	end

	setElementInterior ( bomb, 1 )
	setElementInterior ( bombGlow, 1 )
	setTimer ( destroyElement, 4900, 1, bomb )
	setTimer ( destroyElement, 4900, 1, bombGlow )
	setTimer ( createExplosion, 4800, 1, 2144.60, 1626.80, 994.50, 12 )
	setTimer ( createExplosion, 4900, 1, 2144.00, 1626.80, 993.50, 11 )
	setTimer ( moveObject, 1000, 1, pillar, 300, 2147.70, 1605.70, 1006.55, 0, 30, -10 ) -- rotation 0, 30, -10
	setTimer ( moveObject, 5000, 1, vaultdoor, 400, 2142.50, 1642.00, 996.00, 30, 50 + 720, 360 ) -- rotation 30, 50, 180
	setTimer ( moveObject, 5400, 1, vaultdoor, 600, 2142.50, 1638.00, 992.70, 60 + 360, 100, 0 ) -- rotation 90, 150, 180

	wanted = 3
	wantedLevel ( wanted )
end


	-- (( OBJECTIVE: MONEY )) --

	-- increase their amount of cash, do it until all bags are picked up, OBJECTIVE DONE!
function checkBag ( player )
	if ( getPickupType ( source ) == 3 ) then
		if ( getPlayerTeam ( player ) == attackers ) then
			moneybags.count = moneybags.count + 1
			money = money + 100000
			setCash ( money )
			destroyPickup ( source, moneybags )
			if ( moneybags.count == 10 ) then
				call ( getResourceFromName( "assault" ), "triggerObjective", "money" )
			end
		else cancelEvent()
		end
	end
end

	-- create bags of cash for the attackers to pick up
function scriptCreateMoney()
	local bags = getElementsByType ( "money" )
	for i, v in ipairs ( bags ) do
		local x, y, z = getElementData ( v, "posX" ), getElementData ( v, "posY" ), getElementData ( v, "posZ" )
		table.insert ( moneybags, customPickup ( x, y, z, 1550 ) )
	end
	moneybags.count = 0
	addEventHandler ( "onPickupUse", root, checkBag )
end

	-- cleaning up
function scriptRemoveMoney()
	removeEventHandler ( "onPickupUse", root, checkBag )
	moneybags = {}
end


	-- (( OBJECTIVE: DOOR2 )) --

	-- open the second door
function scriptEndDoor2()
	openDoor ( "doortwo" ) -- rotation 350, 0, 0 ( + 20 )
end


	-- (( OBJECTIVE: BACKDOOR )) --

function leaveCasino2 ( player, dimension )
	if ( getPlayerTeam ( player ) == attackers ) then
		call ( getResourceFromName( "assault" ), "triggerObjective", "backdoor" )
	end
end

	-- creating a col marker that leads out
function scriptCreateBackdoor()
	local x, y, z = 2205.80, 1551.97, 1008.19
	cols.backMarker = createMarker ( x, y, z + 1.8, "arrow", 2, 255, 128, 64, 255 )
	cols.backCol = createColCircle ( x, y, 2 )
	createBlipAttachedTo ( cols.backMarker, 0, 2, 0, 255, 0, 255 )
	setElementInterior ( cols.backMarker, 1 )
	for i, v in ipairs ( getAttachedElements ( cols.backMarker ) ) do
		setElementInterior ( v, 1 )
	end
	addEventHandler ( "onColShapeHit", cols.backCol, leaveCasino2 )
end

	-- unlocking the car and make sure it's in the right place, unlocking the tank
function scriptEndBackdoor()
	local tank = getElementByID ( "tank" )
	setVehicleLocked ( tank, false )
	setVehicleLocked ( van, false )
	wanted = 4
	wantedLevel ( wanted )
	isInterior = false
end

	-- cleaning up
function scriptRemoveBackdoor()
	removeEventHandler ( "onColShapeHit", cols.backCol, leaveCasino2 )
	destroyBlipsAttachedTo ( cols.backMarker )
	destroyElement ( cols.backMarker )
	destroyElement ( cols.backCol )
end


	-- (( OBJECTIVE: HIDEOUT )) --

	-- changing the camera position for everyone and closing the garage door
function endColShapeEnter ( player, dimension )
	if ( player == van ) then

		local gdoor = getElementByID ( "gdoor" )
		local gdoortwo = getElementByID ( "gdoortwo" )
		local x, y, z = getElementPosition ( gdoor )
		local x2, y2, z2 = getElementPosition ( gdoortwo )
		setTimer ( setCameraMatrix, 100, 1, root, 1039.013671875, 2087.5078125, 25.104822158813, 1114.0322265625, 2087.136718, 0 )
		setTimer ( moveObject, 1500, 1, gdoor, 3000, x, y, 12.7 )
		setTimer ( moveObject, 1500, 1, gdoortwo, 2000, x2, y2, 12.7 )

		currentObj = "theEnd"
		setTimer ( scriptRemoveHideout, 1000, 1 )
		setTimer ( call, 7000, 1, getResourceFromName( "assault" ), "triggerObjective", "hideout" )
	end
end

	-- killing everyone to make them respawn and creating the final marker
function scriptCreateHideout ( obj )
	cols.endCol = createColCircle ( obj.posX, obj.posY, 4 )
	cols.endMarker = createMarker ( obj.posX, obj.posY, obj.posZ, "cylinder", 4, 255, 128, 64, 255 )
	createBlipAttachedTo ( cols.endMarker, 0, 2, 255, 128, 64, 255 )
	addEventHandler ( "onColShapeHit", cols.endCol, endColShapeEnter )
end

	-- cleaning up
function scriptRemoveHideout()
	removeEventHandler ( "onColShapeHit", cols.endCol, endColShapeEnter )
	destroyBlipsAttachedTo ( cols.endMarker )
	destroyElement ( cols.endMarker )
	destroyElement ( cols.endCol )
end

	-- === HANDLERS ===
	-- ==================

	-- what happens when an objective is reached
function checkObjective ( obj, players )
	if ( obj.id == "securicar" ) then
		scriptEndSecuricar()
		setTimer ( scriptRemoveSecuricar, 1000, 1 )
	elseif ( obj.id == "park" ) then
		scriptEndPark()
		setTimer ( scriptRemovePark, 1000, 1 )
	elseif ( obj.id == "casino" ) then
		--scriptRemoveCasino() -- leaving the entrance open
	elseif ( obj.id == "key" ) then
		setTimer ( scriptRemoveKey, 1000, 1 )
	elseif ( obj.id == "keycard" ) then
		scriptEndKeycard()
		scriptEndCasino()
		setTimer ( scriptRemoveCasino, 1000, 1 ) -- closing the entrance
	elseif ( obj.id == "vault" ) then
		scriptEndVault( players )
	elseif ( obj.id == "money" ) then
		setTimer ( scriptRemoveMoney, 1000, 1 )
	elseif ( obj.id == "door2" ) then
		scriptEndDoor2()
	elseif ( obj.id == "backdoor" ) then
		scriptEndBackdoor()
		setTimer ( scriptRemoveBackdoor, 1000, 1 )
	end
end

	-- what happens when an objective is created
function createObjective ( obj )
		currentObj = obj.id -- NOTE: onAssaultStartRound gets triggered after the first objective(s) has/have been created
	if ( obj.id == "securicar" ) then
		scriptCreateSecuricar()
	elseif ( obj.id == "park" ) then
		scriptCreatePark ( obj )
	elseif ( obj.id == "casino" ) then
		scriptCreateCasino()
	elseif ( obj.id == "key" ) then
		scriptCreateKey()
	elseif ( obj.id == "money" ) then
		scriptCreateMoney()
	elseif ( obj.id == "backdoor" ) then
		scriptCreateBackdoor()
	elseif ( obj.id == "hideout" ) then
		scriptCreateHideout ( obj )
	end
end


addEventHandler ( "onAssaultObjectiveReached", root, checkObjective )
addEventHandler ( "onAssaultCreateObjective", root, createObjective )
addEventHandler ( "onAssaultStartRound", root, scriptStartRound )
addEventHandler ( "onAssaultEndRound", root, scriptEndRound )

addEventHandler ( "onResourceStart", resourceRoot, scriptResourceStart )
addEventHandler ( "onResourceStop", resourceRoot, scriptEndRound )
addEventHandler ( "onVehicleExplode", van, spawnVan )
addEventHandler ( "onPlayerSpawn", root, playerStats )
