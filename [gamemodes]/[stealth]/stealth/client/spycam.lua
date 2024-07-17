--this was heavilly based on freecam, thanks eAi
--max rots are half the distance either way
local buttonStates = {}
local maxRot = 90
local maxRotX = 90
local moveSpeed = 2
local rotX,rotY,rotZ = 0,0,0
local spyCamX, spyCamY, spyCamZ= false,false,false
local spyCamTargetX, spyCamTargetY, spyCamTargetZ = false,false,false
local camFixed = false
local minXBound, maxXBound
local firstTime

function spyCamFrame ()
	aX = 0
	aY = 0
	if buttonStates["right"] == true then
		aX = moveSpeed
	end
	if buttonStates["left"] == true then
		aX = -moveSpeed
	end
	if buttonStates["forwards"] == true then
		aY = -moveSpeed
	end
	if buttonStates["backwards"] == true then
		aY = moveSpeed
	end
	rotX = rotX + aX
    rotY = rotY - aY
    -- limit the camera to stop it going too far up or down, left or right
    if rotY < -maxRot then
        rotY = -maxRot
    elseif rotY > maxRot then
        rotY = maxRot
    end
	if rotX < minXBound then
        rotX = minXBound
    elseif rotX > maxXBound then
        rotX = maxXBound
    end

    -- work out an angle in radians based on the number of pixels the cursor has moved (ever)
    local cameraAngleX = rotX / 120
    local cameraAngleY = rotY / 120

    local freeModeAngleX = math.sin(cameraAngleX / 2)
    local freeModeAngleY = math.cos(cameraAngleX / 2)
    local yangle = cameraAngleY / 1.5 -- the 1.5 limits the ammount the camera can rotate, decrease it to increase the amount

    local freeModeAngleZ = math.sin(yangle)
    local camPosX, camPosY, camPosZ = spyCamX,spyCamY,spyCamZ

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

    -- Update the target based on the new camera position (again, otherwise the camera kind of sways as the target is out by a frame)
    camTargetX = camPosX + freeModeAngleX * 100
    camTargetY = camPosY + freeModeAngleY * 100
    camTargetZ = camPosZ + freeModeAngleZ * 100
	if firstTime == true then
		camTargetX,camTargetY,camTargetZ = spyCamTargetX, spyCamTargetY, spyCamTargetZ
		firstTime = false
	end
    -- Set the new camera position and target
    --setCameraLookAt ( camTargetX, camTargetY, camTargetZ )
	setCameraMatrix(camPosX, camPosY, camPosZ, camTargetX, camTargetY, camTargetZ)
end

addEvent ("setcamerapos", true )

function placeSpyCam ( x,y,z, rot )
	if ( not tonumber(rot) ) then return false end
	if not getZoneName ( x,y,z ) then return false end
	rotX = rot * -4

	minXBound = rotX - ( (maxRotX/2) * 4 )
	maxXBound = rotX + ( (maxRotX/2) * 4 )

	rot = math.rad ( rot )

	spyCamTargetX,spyCamTargetY,spyCamTargetZ = x,y,z
	spyCamX = spyCamTargetX
	spyCamY = spyCamTargetY
	spyCamZ = spyCamTargetZ
	--set it to look straight ahead
	spyCamTargetX = spyCamTargetX + ( -1000000 * math.sin(rot) )
	spyCamTargetY = spyCamTargetY + ( 1000000 * math.cos(rot) )
	--
	--make the camera level
	return true
end

addEventHandler ( "setcamerapos", root, placeSpyCam )

function removeSpyCam()
	spyCamX = false
	spyCamY = false
	spyCamZ = false
	spyCamTargetX = false
	spyCamTargetY = false
	spyCamTargetZ = false
	camFixed = false
	--toggleCameraFixedMode ( false )
	setCameraTarget(localPlayer)
	return true
end

function toggleSpyCam()
	if camFixed == false then
		--if the spy cam hasnt been placed yet
		if ( spyCamX == false ) or ( spyCamY == false ) or ( spyCamZ == false ) or ( spyCamTargetX == false ) or ( spyCamTargetY == false ) or ( spyCamTargetZ == false ) then
			return false
		end
		--setCameraPosition ( spyCamX,spyCamY,spyCamZ )
		--setCameraLookAt ( spyCamTargetX, spyCamTargetY, spyCamTargetZ )
		--toggleCameraFixedMode ( true )
		setCameraMatrix(spyCamX, spyCamY, spyCamZ, spyCamTargetX, spyCamTargetY, spyCamTargetZ)
		firstTime = true
		camFixed = true
		fadeSpyCam ( true )
		return addEventHandler ( "onClientRender", root, spyCamFrame )
	else
		--toggleCameraFixedMode ( false )
		setCameraTarget(localPlayer)
		camFixed = false
		--bindCamKeys ( false )
		fadeSpyCam ( false )
		return removeEventHandler ( "onClientRender", root, spyCamFrame )
	end
end

function ejectSmokeGrenade ( throwPower )
	if camFixed == false then return false end
	local x,y,z = spyCamX, spyCamY, spyCamZ
	local returnValue = createProjectile ( localPlayer, 17, x, y, z, throwPower )
	return returnValue
end

--this is to create a green look
function fadeSpyCam ( state )
	if state == true then
		fadeCamera ( false, 1.0, 0,255,0  )
		setTimer ( fadeCamera, 250, 1, true, 9999999, 0, 255, 0 )
	else
		fadeCamera ( true, 0, 0,255,0  )
	end
end


--this replaces getControlState as keys are toggled
function bindCamKeys ( state )
	if ( state == true ) then
		bindKey ( "right", "both", setButtonState )
		bindKey ( "left", "both", setButtonState )
		bindKey ( "forwards", "both", setButtonState )
		bindKey ( "backwards", "both", setButtonState )
	else
		unbindKey ( "right", "both", setButtonState )
		unbindKey ( "left", "both", setButtonState )
		unbindKey ( "forwards", "both", setButtonState )
		unbindKey ( "backwards", "both", setButtonState )
	end
end

function setButtonState ( key, keyState )
	local state
	if keyState == "down" then
		state = true
	elseif keyState == "up" then
		state = false
	end
	buttonStates[key] = state
end

bindCamKeys ( true )
