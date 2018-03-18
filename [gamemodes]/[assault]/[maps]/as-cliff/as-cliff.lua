local root = getRootElement()
local objectives = {}
local weps = {}
local cols = {}
local bombs = {}

local truck = createVehicle ( 455, 1898.92, -512.66, 20.66, 0, 0, 180 )
	setElementData ( truck, "noRespawn", true )
	setElementData ( truck, "posX", 1898.92 )
	setElementData ( truck, "posY", -512.66 )
	setElementData ( truck, "posZ", 20.66 )
	setElementData ( truck, "rotZ", 180 )

	-- === ON MAP START ===
	-- ======================

function spawnTruck ( delay )
	local x, y, z = getElementData ( truck, "posX" ), getElementData ( truck, "posY" ), getElementData ( truck, "posZ" )
	local rz = getElementData ( truck, "rotZ" )
	delay = delay or 5000

	setTimer ( spawnVehicle, delay, 1, truck, x, y, z, 0, 0, rz )
	setTimer ( setElementHealth, delay + 100, 1, truck, 2500 )

	if ( objectives.truck ~= "unlock" ) then
		setTimer ( setVehicleLocked, delay + 100, 1, truck, true )
	else setTimer ( attachRockets, delay + 100, 1 )
	end
end

function doAssaultStartRound()
	spawnTruck ( 3000 )

	local gate1 = getElementByID ( "gate01" )
	local gate2 = getElementByID ( "gate02" )
	local x1, y1, z1 = getElementData ( gate1, "posX" ), getElementData ( gate1, "posY" ), getElementData ( gate1, "posZ" )
	local x2, y2, z2 = getElementData ( gate2, "posX" ), getElementData ( gate2, "posY" ), getElementData ( gate2, "posZ" )
	local rz1, rz2 = getElementData ( gate1, "rotZ" ), getElementData ( gate2, "rotZ" )
	setElementPosition ( gate1, x1, y1, z1 )
	setElementPosition ( gate2, x2, y2, z2 )
	setObjectRotation ( gate1, 0, 0, rz1 )
	setObjectRotation ( gate2, 0, 0, rz2 )
end

function doAssaultEndRound()
	if ( objectives.bomb ) then
		for i, v in pairs ( bombs ) do
			destroyBomb ( i )
		end
	end

	if ( objectives.truck ) then
		local rocket = getElementData ( truck, "rocket" )
		local rocket2 = getElementData ( truck, "rocket2" )
		detachElements ( rocket, truck )
		detachElements ( rocket2, truck )
		destroyElement ( rocket )
		destroyElement ( rocket2 )
		destroyBlipsAttachedTo ( truck )
	end

	if ( objectives.finish ) then
		destroyElement ( cols.finalblip )
		cols.finalblip = nil
		removeEventHandler ( "onColShapeHit", cols.exitCol, outside )
		destroyElement ( cols.exitCol )
		cols.exitCol = nil
	end

	if ( objectives.alt_obj )  then
		if ( cols.altCol ) then
			removeEventHandler ( "onColShapeHit", cols.altCol, createWeapon )
			destroyElement ( cols.altCol )
			cols.altCol = nil
		else
			destroyElement ( weps.sniper )
			destroyElement ( weps.rpg )
			weps.sniper = nil
			weps.rpg = nil
		end
	end

	objectives = {}
end

	-- === OBJECTIVES ===
	-- ====================

function destroyBlipsAttachedTo ( element )
	local attachedElements = getAttachedElements ( element )
	for i, v in ipairs ( attachedElements ) do
		if ( getElementType ( v ) == "blip" ) then
			destroyElement ( v )
		end
	end
end

function unlockCar()
	setVehicleLocked ( truck, false	)
	createBlipAttachedTo ( truck, 51 )
end

function attachRockets()
	local rocket = createObject ( 3797, 0, 0, 0 )
	local rocket2 = createObject ( 3797, 0, 0, 5 )
	attachElements ( rocket, truck, 1.9, -2.5, 0.4, 40, 0, 280 )
	attachElements ( rocket2, truck, -1.9, -2.5, 0.4, 320, 0, 260 )
	setElementData ( truck, "rocket", rocket )
	setElementData ( truck, "rocket2", rocket2 )
end

function placeBomb ( ID, players )
	local bomb = getElementByID ( "bomb" .. tostring ( ID ) )
	local x, y, z = getElementData ( bomb, "posX" ), getElementData ( bomb, "posY" ), getElementData ( bomb, "posZ" )
	local rx, ry, rz = getElementData ( bomb, "rotX" ), getElementData ( bomb, "rotY" ), getElementData ( bomb, "rotZ" )
	local bombglow = createMarker ( x, y, z, "corona", 1, 255, 255, 200, 80 )
	bombs[ID] = createObject ( 1654, x, y, z, rx, ry, rz )

	setElementData ( bombs[ID], "bombglow", bombglow )
	if ( players ) then
		for i, v in ipairs ( players ) do
			setTimer ( playSoundFrontEnd, 200, 1, v, 5 )
			setTimer ( playSoundFrontEnd, 360, 1, v, 5 )
		end
	end
end

function destroyBomb ( ID )
	local bombglow = getElementData ( bombs[ID], "bombglow" )
	destroyElement ( bombglow )
	destroyElement ( bombs[ID] )
	bombs[ID] = nil
end

function moveGate ()
	local gate1 = getElementByID ( "gate01" )
	local gate2 = getElementByID ( "gate02" )
	local x1, y1, z1 = getElementData ( gate1, "posX" ), getElementData ( gate1, "posY" ), getElementData ( gate1, "posZ" )
	local x2, y2, z2 = getElementData ( gate2, "posX" ), getElementData ( gate2, "posY" ), getElementData ( gate2, "posZ" )

	setTimer ( moveObject, 100, 1, gate1, 200, x1 + 4.5, y1, z1 - 1.5, 0, 1.5, 7 )
	setTimer ( moveObject, 100, 1, gate2, 300, x2 - 6, y2, z2, 3, 0.5, 3.5 )
	setTimer ( moveObject, 800, 1, gate2, 100, x2 - 14, y2, z2 - 1, 5, 1, 4.5 )
	setTimer ( createExplosion, 90, 1, 1912.75, -424.06, 36.32, 1 )
	setTimer ( createExplosion, 100, 1, 1912.75, -424.06, 32.32, 10 )
	setTimer ( createExplosion, 750, 1, 1904.75, -424.06, 34.32, 10 )

	destroyBomb ( 6 )
	destroyBomb ( 7 )
end

function updateCount ( textDisplay, text )
	if ( cols.count ~= 0 ) then
		cols.count = cols.count - 1
		textItemSetText ( text, tostring ( cols.count ) )
	else cols.count = nil
		textDestroyTextItem ( text )
		textDestroyDisplay ( textDisplay )
	end
end

function createWeapon ()
	weps.sniper = createPickup ( 1927.00, -664.06, 120.05, 2, 34, 30000, 10 ) -- SNIPER
	weps.rpg = createPickup ( 1942.97, -607.64, 74.00, 2, 36, 60000, 3 ) -- HEAT SEAKER
	call ( getResourceFromName ( "assault" ), "triggerObjective", "alt_obj" )
	removeEventHandler ( "onColShapeHit", cols.altCol, createWeapon )
	destroyElement ( cols.altCol )
	cols.altCol = nil
end

	-- === GRAND FINALE ===
	-- ======================

function outside ( player, dimension )
	if ( player == truck ) then
		destroyElement ( cols.finalblip )
		cols.finalblip = nil
		removeEventHandler ( "onColShapeHit", cols.exitCol, outside )
		destroyElement ( cols.exitCol )
		cols.exitCol = nil
		objectives.finish = false
		destroyFacility()
	end
end

function triggerLastObjective()
	call ( getResourceFromName( "assault" ), "triggerObjective", "finish" )
end

function destroyFacility ()
	setTimer ( setCameraMatrix, 100, 1, root, 1891.37, -536.45, 38.95, 1916.50, -633.24, 11.52 )
		setTimer ( createExplosion, 1400, 1, 1900.79, -559.62, 27.19, 1 )
		setTimer ( createExplosion, 1600, 1, 1912.93, -568.59, 30.16, 10 )
		setTimer ( createExplosion, 2000, 1, 1901.38, -576.28, 39.31, 10 )
		setTimer ( createExplosion, 2200, 1, 1890.45, -569.91, 42.50, 10 )

	setTimer ( setCameraMatrix, 2500, 1, root, 1954.60, -558.81, 18.94, 1912.60, -649.57, 87.51 )
		setTimer ( createExplosion, 2800, 1, 1918.27, -576.59, 37.31, 1 )
			setTimer ( createExplosion, 3000, 1, 1952.49, -597.33, 28.04, 1 )
			setTimer ( createExplosion, 3300, 1, 1944.41, -596.90, 41.17, 10 )
			setTimer ( createExplosion, 3000, 1, 1948.40, -599.14, 66.17, 10 )
			setTimer ( createExplosion, 3500, 1, 1933.78, -600.41, 73.07, 10 )

	setTimer ( setCameraMatrix, 2500, 1, root, 1900.13, -503.14, 67.95, 1911.77, -602.46, 72.94 )
		setTimer ( createExplosion, 4300, 1, 1925.80, -595.26, 60.21, 1 )
		setTimer ( createExplosion, 4600, 1, 1924.75, -612.78, 59.10, 10 )
		setTimer ( createExplosion, 4900, 1, 1924.11, -628.83, 78.23, 10 )
		setTimer ( createExplosion, 5200, 1, 1924.61, -643.65, 95.55, 10 )
		setTimer ( createExplosion, 5500, 1, 1937.06, -658.26, 96.98, 10 )
		setTimer ( createExplosion, 5500, 1, 1924.40, -658.26, 100.58, 10 )

	setTimer ( triggerLastObjective, 8000, 1 )
end

	-- === HANDLERS ===
	-- ==================

function checkObjective( obj, players )
	if ( obj.id == "bomb01" ) then
		placeBomb ( 1, players )

	elseif ( obj.id == "bomb02" ) then
		placeBomb ( 2, players )

	elseif ( obj.id == "bomb03" ) then
		placeBomb ( 3, players )
		placeBomb ( 4 )

	elseif ( obj.id == "bomb04" ) then
		placeBomb ( 5, players )

	elseif ( obj.id == "gate" ) then
		placeBomb ( 6, players )
		placeBomb ( 7 )

		cols.count = 10
		local textDisplay = textCreateDisplay()
		local text = textCreateTextItem ( tostring ( cols.count ), 0.5, 0.7, "high", 255, 255, 255, 200, 3, "center", "center" )
		for i, v in ipairs ( getElementsByType ( "player" ) ) do
			textDisplayAddObserver ( textDisplay, v )
		end
		textDisplayAddText ( textDisplay, text )
		setTimer ( updateCount, 1000, 11, textDisplay, text )
		setTimer ( moveGate, 10000, 1 )

	elseif ( obj.id == "truck" ) then
		unlockCar()
		attachRockets()
		objectives[obj.id] = "unlock"
	end
end

function createObjective ( obj )
	if ( obj.id == "bomb01" ) then
		objectives.bomb = true

	elseif ( obj.id =="truck" ) then
		objectives[obj.id] = true

	elseif ( obj.id == "finish" ) then
		objectives[obj.id] = true
		cols.exitCol = createColTube ( obj.posX, obj.posY, obj.posZ, 70, 10 )
		cols.finalblip = createBlip ( obj.posX, obj.posY, obj.posZ, 0, 2, 0, 245, 184, 255 )
		addEventHandler ( "onColShapeHit", cols.exitCol, outside )

	elseif ( obj.id == "alt_obj" ) then
		objectives[obj.id] = true
		cols.altCol = createColCircle ( obj.posX, obj.posY, 1 )
		addEventHandler ( "onColShapeHit", cols.altCol, createWeapon )
	end
end

addEventHandler ( "onVehicleExplode", truck, spawnTruck )

addEventHandler ( "onAssaultObjectiveReached", root, checkObjective )
addEventHandler ( "onAssaultCreateObjective", root, createObjective )
addEventHandler ( "onAssaultStartRound", root, doAssaultStartRound )
addEventHandler ( "onAssaultEndRound", root, doAssaultEndRound )
