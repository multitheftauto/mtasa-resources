local rootElement = getRootElement()
local localPlayer = getLocalPlayer()
local speed = 0
local strafespeed = 0
local rotX, rotY = 0,0

local options = {
	smoothMovement = true,
	acceleration = 0.3,
	decceleration = 0.15,
	mouseSensitivity = 0.3,
	maxYAngle = 188
}



scanning = {}
lastShot = 0
miniLastShot = 0
lastFake = 0
function mechanicGUI ()
if source ~= getLocalPlayer() then return end
if not (mechanicForm) then
	local x, y = guiGetScreenSize()
	local x = 150/x
	local y = 200/y
	mechanicForm = guiCreateWindow ( 0.01, 0.26, x, y, "Mechanic", true )
	background = guiCreateStaticImage ( 0, 0, 1, 1, "bg.png", true, mechanicForm )
	text1 = guiCreateLabel ( 0.07, 0.15, 1.0, 0.30, "  1. Repair a vehicle", true, mechanicForm )
	guiLabelSetColor ( text1, 255, 255, 255 )
	text2 = guiCreateLabel ( 0.07, 0.25, 1.0, 0.30, "  2. Create new vehicle", true, mechanicForm )
	guiLabelSetColor ( text2, 255, 255, 255 )
	text3 = guiCreateLabel ( 0.07, 0.35, 1.0, 0.30, "", true, mechanicForm )
	guiLabelSetColor ( text3, 255, 255, 255 )
	text4 = guiCreateLabel ( 0.07, 0.45, 1.0, 0.30, "", true, mechanicForm )
	guiLabelSetColor ( text4, 255, 255, 255 )
	text5 = guiCreateLabel ( 0.07, 0.55, 1.0, 0.30, "", true, mechanicForm )
	guiLabelSetColor ( text5, 255, 255, 255 )
	text6 = guiCreateLabel ( 0.07, 0.65, 1.0, 0.30, "", true, mechanicForm )
	guiLabelSetColor ( text6, 255, 255, 255 )
	text7 = guiCreateLabel ( 0.07, 0.75, 1.0, 0.30, "", true, mechanicForm )
	guiLabelSetColor ( text7, 255, 255, 255 )
	text8 = guiCreateLabel ( 0.07, 0.85, 1.0, 0.30, "  8. Exit", true, mechanicForm )
	guiLabelSetColor ( text8, 255, 255, 255 )
	bindKey ( "1", "down", mechanicChoice )
	bindKey ( "2", "down", mechanicChoice )
	bindKey ( "8", "down", mechanicChoice )
else
	mechanicWindow()
end
end
addEvent ("mechanicGUI", true)
addEventHandler ("mechanicGUI", getLocalPlayer(), mechanicGUI)

function mechanicWindow ()
	unbindKey ( "1", "down" )
	unbindKey ( "2", "down" )
	unbindKey ( "3", "down" )
	unbindKey ( "4", "down" )
	unbindKey ( "5", "down" )
	unbindKey ( "6", "down" )
	unbindKey ( "7", "down" )
	unbindKey ( "8", "down" )
	guiSetText ( text1, "  1. Repair a vehicle" )
	guiSetText ( text2, "  2. Create new vehicle" )
	guiSetText ( text3, "" )
	guiSetText ( text4, "" )
	guiSetText ( text5, "" )
	guiSetText ( text6, "" )
	guiSetText ( text7, "" )
	guiSetText ( text8, "8. Exit" )
	guiSetVisible ( mechanicForm, true )
	bindKey ( "1", "down", mechanicChoice )
	bindKey ( "2", "down", mechanicChoice )
	bindKey ( "8", "down", mechanicChoice )
end

function mechanicChoice (key, keyState)
	if key == "1" then
		unbindKey ( "1", "down" )
		unbindKey ( "2", "down" )
		unbindKey ( "3", "down" )
		unbindKey ( "4", "down" )
		unbindKey ( "5", "down" )
		unbindKey ( "6", "down" )
		unbindKey ( "7", "down" )
		unbindKey ( "8", "down" )
		guiSetVisible (mechanicForm, false)
		create = false
		withdraw = 15
		triggerServerEvent ("vehicleRepair", getLocalPlayer())
	elseif key == "2" then 
		unbindKey ( "1", "down" )
		unbindKey ( "2", "down" )
		unbindKey ( "3", "down" )
		unbindKey ( "4", "down" )
		unbindKey ( "5", "down" )
		unbindKey ( "6", "down" )
		unbindKey ( "7", "down" )
		unbindKey ( "8", "down" )
		
		guiSetText ( text1, "  1. Rhino" )
		guiSetText ( text2, "  2. Hunter" )
		guiSetText ( text3, "  3. Hydra" )
		guiSetText ( text4, "  4. Patriot" )
		guiSetText ( text5, "  5. Dune" )
		guiSetText ( text6, "  6. Flatbed" )
		guiSetText ( text7, "  7. Rustler" )
		guiSetText ( text8, "  8. Exit" )
		
		bindKey ( "1", "down", vehicleCreate )
		bindKey ( "2", "down", vehicleCreate )
		bindKey ( "3", "down", vehicleCreate )
		bindKey ( "4", "down", vehicleCreate )
		bindKey ( "5", "down", vehicleCreate )
		bindKey ( "6", "down", vehicleCreate )
		bindKey ( "7", "down", vehicleCreate )
		bindKey ( "8", "down", mechanicWindow )
		create = true
	elseif key == "8" then --exit
		guiSetVisible (mechanicForm, false)
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

function vehicleCreate (key, keyState)
	if key == "1" then
		unbindKey ( "1", "down" )
		unbindKey ( "2", "down" )
		unbindKey ( "3", "down" )
		unbindKey ( "4", "down" )
		unbindKey ( "5", "down" )
		unbindKey ( "6", "down" )
		unbindKey ( "7", "down" )
		unbindKey ( "8", "down" )
	
		setElementData (getLocalPlayer(), "vehID", 432)
		guiSetVisible (mechanicForm, false)
		withdraw = 45
		mechanicProgressBars ()
	elseif key == "2" then
		unbindKey ( "1", "down" )
		unbindKey ( "2", "down" )
		unbindKey ( "3", "down" )
		unbindKey ( "4", "down" )
		unbindKey ( "5", "down" )
		unbindKey ( "6", "down" )
		unbindKey ( "7", "down" )
		unbindKey ( "8", "down" )
	
		setElementData (getLocalPlayer(), "vehID", 425)
		guiSetVisible (mechanicForm, false)		
		withdraw = 35
		mechanicProgressBars ()
	elseif key == "3" then
		unbindKey ( "1", "down" )
		unbindKey ( "2", "down" )
		unbindKey ( "3", "down" )
		unbindKey ( "4", "down" )
		unbindKey ( "5", "down" )
		unbindKey ( "6", "down" )
		unbindKey ( "7", "down" )
		unbindKey ( "8", "down" )
	
		setElementData (getLocalPlayer(), "vehID", 520)
		guiSetVisible (mechanicForm, false)	
		withdraw = 35		
		mechanicProgressBars ()
	elseif key == "4" then
		unbindKey ( "1", "down" )
		unbindKey ( "2", "down" )
		unbindKey ( "3", "down" )
		unbindKey ( "4", "down" )
		unbindKey ( "5", "down" )
		unbindKey ( "6", "down" )
		unbindKey ( "7", "down" )
		unbindKey ( "8", "down" )
	
		setElementData (getLocalPlayer(), "vehID", 470)
		guiSetVisible (mechanicForm, false)	
		withdraw = 20	
		mechanicProgressBars ()		
	elseif key == "5" then
		unbindKey ( "1", "down" )
		unbindKey ( "2", "down" )
		unbindKey ( "3", "down" )
		unbindKey ( "4", "down" )
		unbindKey ( "5", "down" )
		unbindKey ( "6", "down" )
		unbindKey ( "7", "down" )
		unbindKey ( "8", "down" )
		guiSetVisible (mechanicForm, false)	
		setElementData (getLocalPlayer(), "vehID", 573)
		withdraw = 20
		mechanicProgressBars ()
	elseif key == "6" then
		unbindKey ( "1", "down" )
		unbindKey ( "2", "down" )
		unbindKey ( "3", "down" )
		unbindKey ( "4", "down" )
		unbindKey ( "5", "down" )
		unbindKey ( "6", "down" )
		unbindKey ( "7", "down" )
		unbindKey ( "8", "down" )
		guiSetVisible (mechanicForm, false)	
		setElementData (getLocalPlayer(), "vehID", 455)
		withdraw = 15
		mechanicProgressBars ()
	elseif key == "7" then
		unbindKey ( "1", "down" )
		unbindKey ( "2", "down" )
		unbindKey ( "3", "down" )
		unbindKey ( "4", "down" )
		unbindKey ( "5", "down" )
		unbindKey ( "6", "down" )
		unbindKey ( "7", "down" )
		unbindKey ( "8", "down" )
		guiSetVisible (mechanicForm, false)	
		setElementData (getLocalPlayer(), "vehID", 476)
		withdraw = 30
		mechanicProgressBars ()
	end
end


function fieldgun ()
	bindKey ("mouse1", "down", fireFieldGun)
end
addEvent ("fieldgun", true)
addEventHandler("fieldgun", getLocalPlayer(), fieldgun)

function fireFieldGun ()
	outputChatBox ("fajjer!")
	local x, y, z = getElementPosition(getLocalPlayer())
	createProjectile (getLocalPlayer(), 19, x, y, z +1, 100)
end

function exitfieldgun ()
	unbindKey ("mouse1", "down", fireFieldGun)
end
addEvent ("exitfieldgun", true)
addEventHandler("exitfieldgun", getLocalPlayer(), exitfieldgun)

lastCreate = 0
function mechanicProgressBars (source, x, y, z, rz)
	if not ( progressbar ) then
		progressbar = guiCreateProgressBar ( 0.4, 0.9, 0.3, 0.05, true )
		guiProgressBarSetProgress (progressbar, 100)
		progresslabel = guiCreateLabel (0.3, 0.3, 1, 1, "Spare parts", true, progressbar)
		guiLabelSetColor (progresslabel, 1, 1, 1)
		guiSetVisible (progressbar, true)
	end
		if guiProgressBarGetProgress(progressbar) < withdraw then
			displayGUItextToPlayer(0.45, 0.3, "Not enough spare parts", "default-bold-small", 255, 255, 255, 5000)
			guiSetVisible (progressbar, false)
		else
			if ( create == true ) then
				if lastCreate > getTickCount() then
					displayGUItextToPlayer(0.45, 0.3, "You have already requested a vehicle.\nPlease wait before requesting a new one", "default-bold-small", 255, 255, 255, 5000)
				else
					lastCreate = getTickCount() + 6000
					guiSetVisible (progressbar, true)
					guiProgressBarSetProgress (progressbar, guiProgressBarGetProgress(progressbar) - withdraw )
					triggerServerEvent ("vehicleCreate", getLocalPlayer())
				end
			else
				guiSetVisible (progressbar, true)
				guiProgressBarSetProgress (progressbar, guiProgressBarGetProgress(progressbar) - withdraw )
				triggerServerEvent ("acceptRepair", getLocalPlayer(), source, x, y, z,rz )
			end
		end
end
addEvent ("mechanicProgressBars", true)
addEventHandler ("mechanicProgressBars", getLocalPlayer(), mechanicProgressBars)


function medicProgressBars (withdraw)
	if not ( progressbar ) then
		progressbar = guiCreateProgressBar ( 0.4, 0.9, 0.3, 0.05, true )
		guiProgressBarSetProgress (progressbar, 100)
		progresslabel = guiCreateLabel (0.3, 0.3, 1, 1, "Medicine", true, progressbar)
		guiLabelSetColor(progressLabel, 1, 1, 1)
		guiSetVisible (progressbar, true)
	end
		if guiProgressBarGetProgress(progressbar) < withdraw then
			displayGUItextToPlayer(0.45, 0.3, "Not enough medicine", "default-bold-small", 255, 255, 255, 5000)
			guiSetVisible (progressbar, false)
		else
			guiSetVisible (progressbar, true)
			guiProgressBarSetProgress (progressbar, guiProgressBarGetProgress(progressbar) - withdraw )
		end
end
addEvent ("medicProgressBars", true)
addEventHandler ("medicProgressBars", getLocalPlayer(), medicProgressBars)		

addEventHandler ("onClientPlayerSpawn", getLocalPlayer(), function()
	if ( progressbar ) then
		destroyElement ( progressbar )
		progressbar = nil
	end
end )
	
local function getCamRotation ()
	local px, py, pz, lx, ly, lz = getCameraMatrix()
	local rotz = 6.2831853071796 - math.atan2 ( ( lx - px ), ( ly - py ) ) % 6.2831853071796
 	local rotx = math.atan2 ( lz - pz, getDistanceBetweenPoints2D ( lx, ly, px, py ) )
	--Convert to degrees
	rotx = math.deg(rotx)
	rotz = -math.deg(rotz)
	
 	return rotx, 180, rotz
end
	
function antiAir ()
	if lastShot > getTickCount() then return end
	lastShot = getTickCount() + 500
		local distance = 50
		local sX, sY, sZ = getElementPosition ( getLocalPlayer() )
		local fX, fY, fZ = sX, sY, sZ
		rX, rY, rZ = getCamRotation ()
		local offset = math.sqrt ( ( distance ^ 2 ) * 2 )
		sX = sX + math.sin ( math.rad ( rZ ) ) * 1.5
		sY = sY + math.cos ( math.rad ( rZ ) ) * 1.5
		fX = fX + math.sin ( math.rad ( rZ ) ) * offset
		fY = fY + math.cos ( math.rad ( rZ ) ) * offset
		fZ = fZ - math.tan ( math.rad ( rX ) ) * offset
		local col, x, y, z, element = processLineOfSight ( sX, sY, sZ + 0.5, fX, fY, fZ )
		if ( col ) then
			triggerServerEvent ( "antiAirShot", getLocalPlayer(), x, y, z, rX, rY, rZ )
		else 
			triggerServerEvent ( "antiAirShot", getLocalPlayer(), fX, fY, fZ, rX, rY, rZ ) 
		end
end
	
function rustlerBomb ()
	if lastShot > getTickCount() then return end
	lastShot = getTickCount() + 10000
	local vehicle = getPedOccupiedVehicle ( getLocalPlayer() )
	local x, y, z = getElementPosition ( vehicle )
	local col, fX, fY, fZ, element = processLineOfSight ( x, y, z - 2, x, y, z - 300 )
	triggerServerEvent ( "rustlerBomb", getLocalPlayer(), x, y, z - 1, fX, fY, fZ )
end

function rustlerEnter()
	displayGUItextToPlayer(0.3, 0.3, "press 'R' to drop a bomb", "sa-header", 255, 255, 255, 5000)
	bindKey ("r", "down", function ()
		setTimer (rustlerBomb, 500, 1)
	end)
end
addEvent("rustlerEnter", true)
addEventHandler("rustlerEnter", getLocalPlayer(), rustlerEnter)

function rustlerExit()
	unbindKey ("r", "down" )
end
addEvent("rustlerExit", true)
addEventHandler("rustlerExit", getLocalPlayer(), rustlerExit)


function mountPatriot ()
	local target = getPedTarget ( getLocalPlayer() )
	if ( status == true ) then
		status = false
		triggerServerEvent ("detachPatriot", getLocalPlayer(), target)
	else
		if ( target ) then
			if getElementType ( target ) == "vehicle" then
					triggerServerEvent ("attachPatriot", getLocalPlayer(), target)
					status = true
			end
		end
	end
end
addEvent("mountPatriot", true)
addEventHandler("mountPatriot", getLocalPlayer(), mountPatriot)

addEventHandler("onClientPlayerWeaponFire", getLocalPlayer(), function (weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement )
    if weapon == 38 and getKeyState("mouse1") == true then
		if miniLastShot > getTickCount() then
			toggleControl ("fire", false )
			setTimer (toggleControl, 800, 1, "fire", true )
			setTimer (setControlState, 820, 1, "fire", true)
		else
			miniLastShot = getTickCount() + 800
		end
	elseif weapon == 38 and getKeyState("mouse") == false then
		setControlState("fire", false)
	end
end)

addEventHandler ("onClientPlayerWasted", getLocalPlayer(), function (attacker, weapon, bodypart)
	if status == true then
		status = false
		triggerServerEvent ("detachPatriot", getLocalPlayer(), target)
	end
	guiSetVisible (mechanicForm, false)
end)

function vehicleDamage ()
	if not ( rhinoHealth ) then
		rhinoHealth = guiCreateProgressBar ( 0.775, 0.225, 0.18, 0.04, true )
		rhinoHealthText = guiCreateLabel ( 0.775, 0.235, 0.18, 0.04, "", true )
		guiLabelSetColor ( rhinoHealthText, 1, 1, 1, 255 )
	else
		guiSetVisible (rhinoHealth, true)
		guiSetVisible (rhinoHealthText, true)
	end
	local zeHealth = getElementHealth ( source )
	guiSetText (rhinoHealthText, "   - Health:   " ..math.ceil(zeHealth).. "" )
	local zeHealth1 = zeHealth / 10
	guiProgressBarSetProgress (rhinoHealth, tonumber(zeHealth1))
end
addEvent ("damageVehicle", true)
addEventHandler ( "damageVehicle", getRootElement(), vehicleDamage )

function enterRhino()
	if not ( rhinoReload ) then
		rhinoReload = guiCreateProgressBar ( 0.775, 0.265, 0.18, 0.04, true )
		rhinoReloadText = guiCreateLabel ( 0.775, 0.275, 0.18, 0.04, "    --- READY ---   ", true )
		guiLabelSetColor ( rhinoReloadText, 1, 1, 1, 255 )
		guiProgressBarSetProgress (rhinoReload, 100)
		addEventHandler("onClientRender", getLocalPlayer(), rhinoShoot)
	else
		guiSetVisible (rhinoReload, true)
		guiSetVisible (rhinoReloadText, true)
		addEventHandler("onClientRender", getLocalPlayer(), rhinoShoot)
	end
end
addEvent("enterRhino", true)
addEventHandler("enterRhino", getRootElement(), enterRhino)

function hideGUIs()
	guiSetVisible (rhinoHealth, false)
	guiSetVisible (rhinoHealthText, false)
	guiSetVisible (rhinoReload, false)
	guiSetVisible (rhinoReloadText, false)
	removeEventHandler("onClientRender", getLocalPlayer(), rhinoShoot)
end
addEvent ("leaveRhino", true)
addEventHandler ("leaveRhino", getRootElement(), hideGUIs)
lastPressed = 0
function rhinoShoot ()
if isPedInVehicle(getLocalPlayer()) == true then
	if getControlState("vehicle_fire") == true or getElementModel(getPedOccupiedVehicle(getLocalPlayer())) == 432 and getControlState("vehicle_secondary_fire") == true then
		if lastPressed > getTickCount() then return end
		lastPressed = getTickCount() + 49
		setTimer(toggleControl, 50, 1, "vehicle_fire", false)
		setTimer (toggleControl, 4500, 1, "vehicle_fire", true)
		if getElementModel(getPedOccupiedVehicle(getLocalPlayer())) == 432 then
			toggleControl ("vehicle_secondary_fire", false)
			setTimer (toggleControl, 4500, 1, "vehicle_secondary_fire", true)
		end
		guiProgressBarSetProgress(rhinoReload, 0)
		guiSetText (rhinoReloadText, "    --- RELOAD ---   ")
		setTimer (guiSetText, 4050, 1, rhinoReloadText, "    --- READY ---   ")
		setTimer (function()
					guiProgressBarSetProgress(rhinoReload, guiProgressBarGetProgress(rhinoReload) + 25)
					end, 1000, 4)
	end
else
	hideGUIs()
	removeEventHandler("onClientRender", getLocalPlayer(), rhinoShoot)
end
end
		

function killedCam (killer)
	local x, y, z = getElementPosition(source)
	--toggleCameraFixedMode (true)
	target = killer
	--setCameraPosition(x, y, z)
	setCameraMatrix(x, y, z, x, y, z)
	addEventHandler("onClientRender", getLocalPlayer(), followKiller)
end
addEvent ("killedCam", true)
addEventHandler ("killedCam", getRootElement(), killedCam)

function followKiller ()
	local x, y, z = getElementPosition (target)
	local cx, cy, cz, lookX, lookY, lookZ = getCameraMatrix ( getLocalPlayer() )
	--setCameraLookAt(x, y, z)
	setCameraMatrix (cx, cy, cz, x, y, z)
end

function stopFollow ()
	--toggleCameraFixedMode (false)
	setCameraTarget ( getLocalPlayer() )
	removeEventHandler ("onClientRender", getLocalPlayer(), followKiller)
end
addCommandHandler ("stopfollow", stopFollow)

function setScale ( theEar)
for k,v in pairs(theEar) do
	setElementCollisionsEnabled (v, false)
	setObjectScale ( v, 0.5)
end
end
addEvent ("scale", true)
addEventHandler("scale", getRootElement(), setScale)

function freecamFrame ()
    -- work out an angle in radians based on the number of pixels the cursor has moved (ever)
    local cameraAngleX = rotX / 120
    local cameraAngleY = rotY / 120

    local freeModeAngleX = math.sin(cameraAngleX / 2)
    local freeModeAngleY = math.cos(cameraAngleX / 2) 
    local yangle = cameraAngleY / 1.5 -- the factor limits the ammount the camera can rotate, decrease it to increase the amount

    local freeModeAngleZ = math.sin(yangle)
    local camPosX, camPosY, camPosZ, camTargetX, camTargetY, camTargetZ = getCameraMatrix()

    -- calculate a target based on the current position and an offset based on the angle
    local camTargetX = camPosX + freeModeAngleX * 100
    local camTargetY = camPosY + freeModeAngleY * 100
    local camTargetZ = camPosZ + freeModeAngleZ * 100

    -- Work out the distance between the target and the camera (should be 100 units)
    local camAngleX = camPosX - camTargetX
    local camAngleY = camPosY - camTargetY
    local camAngleZ = camPosZ - camTargetZ

    -- Calulcate the length of the vector
    local angleLength = math.sqrt(camAngleX*camAngleX+camAngleY*camAngleY+camAngleZ*camAngleZ)

    -- Normalize the vector, ignoring the Z axis, as the camera is stuck to the XY plane (it can't roll)
    local camNormalizedAngleX = camAngleX / angleLength
    local camNormalizedAngleY = camAngleY / angleLength
    local camNormalizedAngleZ = 0

    -- We use this as our rotation vector
    local normalAngleX = 0
    local normalAngleY = 0
    local normalAngleZ = 1

    -- Perform a cross product with the rotation vector and the normalzied angle
    local normalX = (camNormalizedAngleY * normalAngleZ - camNormalizedAngleZ * normalAngleY)
    local normalY = (camNormalizedAngleZ * normalAngleX - camNormalizedAngleX * normalAngleZ)
    local normalZ = (camNormalizedAngleX * normalAngleY - camNormalizedAngleY * normalAngleX)


    -- Update the target based on the new camera position (again, otherwise the camera kind of sways as the target is out by a frame)
    camTargetX = camPosX + freeModeAngleX * 100
    camTargetY = camPosY + freeModeAngleY * 100
    camTargetZ = camPosZ + freeModeAngleZ * 100

    -- Set the new camera position and target
    --setCameraLookAt ( camTargetX, camTargetY, camTargetZ )
	serCameraMatrix( camPosX, camPosY, camPosZ, camTargetX, camTargetY, camTargetZ )
end

function freecamMouse (cX,cY,aX,aY)
	--ignore mouse movement if the cursor is on
	if isCursorShowing() then return end

    local width, height = guiGetScreenSize()
    aX = aX - width / 2
    aY = aY - height / 2
    rotX = rotX + aX * options.mouseSensitivity
    rotY = rotY - aY * options.mouseSensitivity

    -- limit the camera to stop it going too far up or down
    if rotY < -options.maxYAngle then
        rotY = -options.maxYAngle
    elseif rotY > options.maxYAngle then
        rotY = options.maxYAngle
    end
end

function setFreecamEnabled (x, y, z, dontChangeFixedMode)
	if (x and y and z) then
	    --setCameraPosition(x, y, z + 3)
		setCameraMatrix(x, y, z + 4, x, y, z + 3)
		outputChatBox ("Press mouse2 to fire, 'R' to dismount.")
		bindKey ("mouse2", "down", antiAir)
	else
		--setCameraPosition(getElementPosition(getLocalPlayer()))
		setCameraMatrix(getElementPosition(getLocalPlayer()), getElementPosition(getLocalPlayer()))
	end
    	--toggleCameraFixedMode(true)
	if getElementData(localPlayer, "freecam:state") == true then
		setFreecamDisabled()
	else
		addEventHandler("onClientRender", rootElement, freecamFrame)
		addEventHandler("onClientCursorMove",rootElement, freecamMouse)
		setElementData(localPlayer, "freecam:state", true)
	end
	return true
end
addEvent("doSetFreecamEnabled", true)
addEventHandler("doSetFreecamEnabled", rootElement, setFreecamEnabled)

function setFreecamDisabled(dontChangeFixedMode)
    --toggleCameraFixedMode(false)
	setCameraTarget ( getLocalPlayer() )
	removeEventHandler("onClientRender", rootElement, freecamFrame)
	removeEventHandler("onClientCursorMove",rootElement, freecamMouse)
	setElementData(localPlayer, "freecam:state", false)
	unbindKey ("mouse2", "down", antiAir)
	
	return true
end
addEvent("doSetFreecamDisabled", true)
addEventHandler("doSetFreecamDisabled", rootElement, setFreecamDisabled)


function feignDeath (feignHealth, feignX, feignY, feignZ, feignRot, feignSkin)
	if not ( feignTime) then
		feignTime = guiCreateProgressBar ( 0.775, 0.425, 0.18, 0.04, true )
		feignTimeText = guiCreateLabel ( 0.785, 0.435, 0.18, 0.04, "Feign Death", true )
		guiLabelSetColor ( feignTimeText, 1, 1, 1, 255 )
		guiProgressBarSetProgress (feignTime, 100)
	else
		guiSetVisible (feignTime, true)
		guiSetVisible (feignTimeText, true)
	end
if guiProgressBarGetProgress(feignTime) < 1 then return
else
	local x, y, z = getElementPosition(getLocalPlayer())
	if countUp then
		killTimer (countUp)
		countUp = nil
	end
	if countDown then
		killTimer (countDown)
		countDown = nil
	end
	countDown = setTimer (feignDeathCountDown, 1000, 0, getLocalPlayer() )
	restoreHealth = feignHealth
	restoreX =  feignX
	restoreY =  feignY
	restoreZ =  feignZ
	restoreRot = feignRot
	restoreSkin =  feignSkin
	restorePistol = getPedTotalAmmo (getLocalPlayer(), 2)
	restoreSniper = getPedTotalAmmo (getLocalPlayer(), 6)
	restoreNades = getPedTotalAmmo (getLocalPlayer(), 8)
	triggerServerEvent ("killscout", getLocalPlayer(), source)
	setTimer (setFreecamEnabled, 1000, 1 )
end
end
addEvent("feigndeath", true)
addEventHandler("feigndeath", getRootElement(), feignDeath)

function feignDeathCountDown (source)
	if guiProgressBarGetProgress(feignTime) < 1 then
		--outputChatBox ("out of time!")
		displayGUItextToPlayer(0.45, 0.3, "Out of time!", "default-bold-small", 255, 255, 255, 5000)
		triggerServerEvent ("ressurect", getLocalPlayer(),source, restoreHealth, restoreX, restoreY, restoreZ, restoreRot, restoreSkin, restorePistol, restoreSniper, restoreNades)
		killTimer (countDown)
		setFreecamDisabled()
		countUp = setTimer (feignCountUp, 1000, 0, getLocalPlayer())
	else
		guiProgressBarSetProgress(feignTime, guiProgressBarGetProgress(feignTime) - 1.6)
	end
end

function feignCountUp ()
if guiProgressBarGetProgress(feignTime) == 100 then
	guiSetVisible (feignTime, false)
	guiSetVisible (feignTimeText, false)
	killTimer (countUp)
	countUp = nil
else
	guiProgressBarSetProgress(feignTime, guiProgressBarGetProgress(feignTime) + 2.0)
end
end

function restoreDeath ()
	if ( countDown ) then
		killTimer (countDown)
		countDown = nil
		countUp = setTimer (feignCountUp, 1000, 100)
	end
	triggerServerEvent ("ressurect", getLocalPlayer(),source, restoreHealth, restoreX, restoreY, restoreZ, restoreRot, restoreSkin, restorePistol, restoreSniper, restoreNades)
	setFreecamDisabled()
end
addEvent ("restoreDeath", true)
addEventHandler("restoreDeath", getRootElement(), restoreDeath)

function captureProgressDown (time)
	if not captureProgressBarDown then
		captureProgressBarDown = guiCreateProgressBar ( 0.43, 0.5, 0.15, 0.05, true)
		lowerFlag = guiCreateLabel (0.3, 0.3, 1, 1, "Lowering...", true, captureProgressBarDown)
		guiLabelSetColor ( lowerFlag, 1, 1, 1, 255 )
	else
		guiSetVisible(captureProgressBarDown, true)
	end
	progress = time / 120
	guiProgressBarSetProgress(captureProgressBarDown, progress)
	captureTimerDown = setTimer (captureCountDown, 1000, 0)
end
addEvent("captureProgressDown", true)
addEventHandler("captureProgressDown", getRootElement(), captureProgressDown)

function captureCountDown ()
	if guiProgressBarGetProgress(captureProgressBarDown) > 0 then
		guiSetVisible(captureProgressBarDown, true)
		guiProgressBarSetProgress(captureProgressBarDown, guiProgressBarGetProgress(captureProgressBarDown) - 8.3)
	else
		killTimer(captureTimerDown)
		captureTimerDown = nil
		guiSetVisible(captureProgressBarDown, false)
	end
end

function captureProgressUp (time)
	guiSetVisible(captureProgressBarDown, false)
	if not captureProgressBarUp then
		captureProgressBarUp = guiCreateProgressBar ( 0.43, 0.5, 0.15, 0.05, true)
		riseFlag = guiCreateLabel (0.3, 0.3, 1, 1, "Capturing...", true, captureProgressBarUp)
		guiLabelSetColor ( riseFlag, 1, 1, 1, 255 )
	else
		guiSetVisible(captureProgressBarUp, true)
	end
	mytime = time
	progress = 100 / ( (1000 - 12000) / (time - 12000 ))
	progress1 = 100 - progress
	guiProgressBarSetProgress(captureProgressBarUp, progress)
	captureTimerUp = setTimer (captureCountUp, 1000, 0)
end
addEvent("captureProgressUp", true)
addEventHandler("captureProgressUp", getRootElement(), captureProgressUp)

function captureCountUp ()
	if guiProgressBarGetProgress(captureProgressBarUp) < 100 then
		mytime = mytime - 1000
		progress = 100 / ( (1000 - 12000) / ( mytime - 12000 ))
		guiSetVisible(captureProgressBarUp, true)
		guiProgressBarSetProgress(captureProgressBarUp, progress)
	else
		killTimer(captureTimerUp)
		captureTimerUp = nil
		guiSetVisible(captureProgressBarUp, false)
	end
end

function captureExit()
	guiSetVisible(captureProgressBarDown, false)
	guiSetVisible(captureProgressBarUp, false)
	guiSetVisible(blockedProgressBar, false)
	if (captureTimerDown) then
		killTimer(captureTimerDown)
		captureTimerDown = nil
	end
	if (captureTimerUp) then
		killTimer(captureTimerUp)
		captureTimerUp = nil
	end
end
addEvent("captureExit", true)
addEventHandler("captureExit", getRootElement(), captureExit)

function captureBlocked()
	if source == getLocalPlayer() then
		if getElementData(source, "showHelp") == true then
			blockHelpCreate()
		end
	else
		if getElementData(getLocalPlayer(), "showHelp") == true then
			blockedHelpCreate ()
		end
	end
	if not ( blockedProgressBar ) then
		blockedProgressBar = guiCreateProgressBar ( 0.43, 0.5, 0.15, 0.05, true)
		blocked = guiCreateLabel (0.3, 0.3, 1, 1, "BLOCKED!", true, blockedProgressBar)
		guiLabelSetColor ( blocked, 1, 1, 1, 255 )
	else
		guiSetVisible(blockedProgressBar, true)
	end
	guiSetVisible(captureProgressBarDown, false)
	guiSetVisible(captureProgressBarUp, false)
	if (captureTimerDown) then
		killTimer(captureTimerDown)
		captureTimerDown = nil
	end
	if (captureTimerUp) then
		killTimer(captureTimerUp)
		captureTimerUp = nil
	end
end
addEvent ("captureBlocked", true)
addEventHandler("captureBlocked", getRootElement(), captureBlocked)
	
	