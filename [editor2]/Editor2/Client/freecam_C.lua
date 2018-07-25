-- state variables
local speed = 0
local strafespeed = 0
local rotX, rotY = 0,0
local velocityX, velocityY, velocityZ

-- configurable parameters
local options = {
	invertMouseLook = false,
	normalMaxSpeed = 2,
	slowMaxSpeed = 0.2,
	fastMaxSpeed = 12,
	smoothMovement = true,
	acceleration = 0.4,
	decceleration = 0.2,
	mouseSensitivity = 0.04,
	maxYAngle = 188,
	key_fastMove = "lshift",
	key_slowMove = "lalt",
	key_forward = "forwards",
	key_backward = "backwards",
	key_left = "left",
	key_right = "right",
	key_forward_veh = "accelerate",
	key_backward_veh = "brake_reverse",
	key_left_veh = "vehicle_left",
	key_right_veh = "vehicle_right"
}

local controlToKey = {
	["forwards"] = "w",
	["backwards"] = "s",
	["left"] = "a",
	["right"] = "d",
	["accelerate"] = "w",
	["brake_reverse"] = "s",
	["vehicle_left"] = "a",
	["vehicle_right"] = "d",
}

local mouseFrameDelay = 0


function getKeyStateA(key)
	if isMTAWindowActive() then
		return false
	end
	if key == "lshift" or key == "lalt" or key == "arrow_u" or key == "arrow_d" or key == "arrow_l" or key == "arrow_r" then
		return getKeyState(key)
	end
	if isPedDead(localPlayer) then
		-- We must use getKeyStateA when dead we also have to hope they're using WASD
		return getKeyState(controlToKey[key])
	else
		-- We can use getControlState
		return getPedControlState(key)
	end
end

-- PRIVATE

local function freecamFrame ()
	if getKeyState('space') then return end 
	
    -- work out an angle in radians based on the number of pixels the cursor has moved (ever)
    local cameraAngleX = rotX
    local cameraAngleY = rotY

    local freeModeAngleZ = math.sin(cameraAngleY)
    local freeModeAngleY = math.cos(cameraAngleY) * math.cos(cameraAngleX)
    local freeModeAngleX = math.cos(cameraAngleY) * math.sin(cameraAngleX)
    local camPosX, camPosY, camPosZ = getCameraMatrix()

    -- calculate a target based on the current position and an offset based on the angle
    local camTargetX = camPosX + freeModeAngleX * 100
    local camTargetY = camPosY + freeModeAngleY * 100
    local camTargetZ = camPosZ + freeModeAngleZ * 100

	-- Calculate what the maximum speed that the camera should be able to move at.
    local mspeed = CameraSpeed or 20
    if getKeyStateA ( options.key_fastMove ) then
        mspeed = CameraSpeed*2
	elseif getKeyStateA ( options.key_slowMove ) then
		mspeed = CameraSpeed/4
    end

	if options.smoothMovement then
		local acceleration = options.acceleration
		local decceleration = options.decceleration

	    -- Check to see if the forwards/backwards keys are pressed
	    local speedKeyPressed = false
	    if ( getKeyStateA ( options.key_forward ) or getKeyStateA ( options.key_forward_veh ) ) and not getKeyStateA("arrow_u") then
			speed = speed + acceleration
	        speedKeyPressed = true
	    end
		if ( getKeyStateA ( options.key_backward ) or getPedControlState ( options.key_backward_veh ) ) and not getKeyStateA("arrow_d") then
			speed = speed - acceleration
	        speedKeyPressed = true
	    end

	    -- Check to see if the strafe keys are pressed
	    local strafeSpeedKeyPressed = false
		if ( getKeyStateA ( options.key_right ) or getKeyStateA ( options.key_right_veh ) ) and not getKeyStateA("arrow_r") then
	        if strafespeed > 0 then -- for instance response
	            strafespeed = 0
	        end
	        strafespeed = strafespeed - acceleration / 2
	        strafeSpeedKeyPressed = true
	    end
		if ( getKeyStateA ( options.key_left ) or getKeyStateA ( options.key_left_veh ) ) and not getKeyStateA("arrow_l") then
	        if strafespeed < 0 then -- for instance response
	            strafespeed = 0
	        end
	        strafespeed = strafespeed + acceleration / 2
	        strafeSpeedKeyPressed = true
	    end

	    -- If no forwards/backwards keys were pressed, then gradually slow down the movement towards 0
	    if speedKeyPressed ~= true then
			if speed > 0 then
				speed = speed - decceleration
			elseif speed < 0 then
				speed = speed + decceleration
			end
	    end

	    -- If no strafe keys were pressed, then gradually slow down the movement towards 0
	    if strafeSpeedKeyPressed ~= true then
			if strafespeed > 0 then
				strafespeed = strafespeed - decceleration
			elseif strafespeed < 0 then
				strafespeed = strafespeed + decceleration
			end
	    end

	    -- Check the ranges of values - set the speed to 0 if its very close to 0 (stops jittering), and limit to the maximum speed
	    if speed > -decceleration and speed < decceleration then
	        speed = 0
	    elseif speed > mspeed then
	        speed = mspeed
	    elseif speed < -mspeed then
	        speed = -mspeed
	    end

	    if strafespeed > -(acceleration / 2) and strafespeed < (acceleration / 2) then
	        strafespeed = 0
	    elseif strafespeed > mspeed then
	        strafespeed = mspeed
	    elseif strafespeed < -mspeed then
	        strafespeed = -mspeed
	    end
	else
		speed = 0
		strafespeed = 0
		if getKeyStateA ( options.key_forward ) or getKeyStateA ( options.key_forward_veh ) then
			speed = mspeed
		end
		if getKeyStateA ( options.key_backward ) or getKeyStateA ( options.key_backward_veh ) then
			speed = -mspeed
		end
		if getKeyStateA ( options.key_left ) or getKeyStateA ( options.key_left_veh ) then
			strafespeed = mspeed
		end
		if getKeyStateA ( options.key_right ) or getKeyStateA ( options.key_right_veh ) then
			strafespeed = -mspeed
		end
	end

    -- Work out the distance between the target and the camera (should be 100 units)
    local camAngleX = camPosX - camTargetX
    local camAngleY = camPosY - camTargetY
    local camAngleZ = 0 -- we ignore this otherwise our vertical angle affects how fast you can strafe

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

    -- Update the camera position based on the forwards/backwards speed
    camPosX = camPosX + freeModeAngleX * speed
    camPosY = camPosY + freeModeAngleY * speed
    camPosZ = camPosZ + freeModeAngleZ * speed

    -- Update the camera position based on the strafe speed
    camPosX = camPosX + normalX * strafespeed
    camPosY = camPosY + normalY * strafespeed
    camPosZ = camPosZ + normalZ * strafespeed

	--Store the velocity
	velocityX = (freeModeAngleX * speed) + (normalX * strafespeed)
	velocityY = (freeModeAngleY * speed) + (normalY * strafespeed)
	velocityZ = (freeModeAngleZ * speed) + (normalZ * strafespeed)

    -- Update the target based on the new camera position (again, otherwise the camera kind of sways as the target is out by a frame)
    camTargetX = camPosX + freeModeAngleX * 100
    camTargetY = camPosY + freeModeAngleY * 100
    camTargetZ = camPosZ + freeModeAngleZ * 100

    -- Set the new camera position and target
    setCameraMatrix ( camPosX, camPosY, camPosZ, camTargetX, camTargetY, camTargetZ,0,105 )
end

local function freecamMouse (cX,cY,aX,aY)
	--ignore mouse movement if the cursor or MTA window is on
	--and do not resume it until at least 5 frames after it is toggled off
	--(prevents cursor mousemove data from reaching this handler)
	if isCursorShowing() or isMTAWindowActive() then
		mouseFrameDelay = 5
		return
	elseif mouseFrameDelay > 0 then
		mouseFrameDelay = mouseFrameDelay - 1
		return
	end

	-- how far have we moved the mouse from the screen center?
    local width, height = guiGetScreenSize()
    aX = aX - width / 2
    aY = aY - height / 2

	--invert the mouse look if specified
	if options.invertMouseLook then
		aY = -aY
	end

    rotX = rotX + aX * (options.mouseSensitivity / (getKeyState('lalt') and 5 or 1)) * 0.01745
    rotY = rotY - aY * (options.mouseSensitivity / (getKeyState('lalt') and 5 or 1)) * 0.01745

	local PI = math.pi
	if rotX > PI then
		rotX = rotX - 2 * PI
	elseif rotX < -PI then
		rotX = rotX + 2 * PI
	end

	if rotY > PI then
		rotY = rotY - 2 * PI
	elseif rotY < -PI then
		rotY = rotY + 2 * PI
	end
    -- limit the camera to stop it going too far up or down - PI/2 is the limit, but we can't let it quite reach that or it will lock up
	-- and strafeing will break entirely as the camera loses any concept of what is 'up'
    if rotY < -PI / 2.05 then
       rotY = -PI / 2.05
    elseif rotY > PI / 2.05 then
        rotY = PI / 2.05
    end
end

-- PUBLIC

function getFreecamVelocity()
	return velocityX,velocityY,velocityZ
end

function getFreecamSpeed()
	if velocityX then
		return((velocityX^2 + velocityY^2 + velocityZ^2)^(0.5))* 111.847
	else
		return 0
	end
end

-- params: x, y, z  sets camera's position (optional)
function setFreecamEnabled (x, y, z)
	if isFreecamEnabled() then
		return false
	end

	if (x and y and z) then
	    setCameraMatrix ( x, y, z )
	end
	addEventHandler("onClientRender", root, freecamFrame)
	addEventHandler("onClientCursorMove",root, freecamMouse)
	setElementData(localPlayer, "freecam:state", true)

	return true
end

-- param:  dontChangeFixedMode  leaves toggleCameraFixedMode alone if true, disables it if false or nil (optional)
function setFreecamDisabled()
	if not isFreecamEnabled() then
		return false
	end

	velocityX,velocityY,velocityZ = 0,0,0
	speed = 0
	strafespeed = 0
	removeEventHandler("onClientRender", root, freecamFrame)
	removeEventHandler("onClientCursorMove",root, freecamMouse)
	setElementData(localPlayer, "freecam:state", false)

	return true
end

function isFreecamEnabled()
	return getElementData(localPlayer,"freecam:state")
end

function getFreecamOption(theOption, value)
	return options[theOption]
end

function setFreecamOption(theOption, value)
	if options[theOption] ~= nil then
		options[theOption] = value
		return true
	else
		return false
	end
end

addEvent("doSetFreecamEnabled", true)
addEventHandler("doSetFreecamEnabled", root, setFreecamEnabled)

addEvent("doSetFreecamDisabled", true)
addEventHandler("doSetFreecamDisabled", root, setFreecamDisabled)

addEvent("doSetFreecamOption")
addEventHandler("doSetFreecamOption", root, setFreecamOption)
