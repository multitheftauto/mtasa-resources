-- state variables
local speed = 0
local strafespeed = 0
local rotX, rotY = 0,0
local velocityX, velocityY, velocityZ
local width, height = guiGetScreenSize()

-- configurable parameters
local options = {
	invertMouseLook = false,
	normalMaxSpeed = 2,
	slowMaxSpeed = 0.2,
	fastMaxSpeed = 12,
	smoothMovement = true,
	acceleration = 0.3,
	decceleration = 0.15,
	mouseSensitivity = 0.3,
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
	key_right_veh = "vehicle_right",
	fov = 70
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

local mta_getKeyState = getKeyState
function getKeyState(key)
	if isMTAWindowActive() then
		return false
	end
	if not isMTAWindowFocused() then
		return false
	end
	if key == "lshift" or key == "lalt" or key == "arrow_u" or key == "arrow_d" or key == "arrow_l" or key == "arrow_r" then
		return mta_getKeyState(key)
	end
	if isPedDead(localPlayer) then
		-- We must use getKeyState when dead we also have to hope they're using WASD
		return mta_getKeyState(controlToKey[key])
	else
		-- We can use getControlState
		return getPedControlState(key)
	end
end

-- PRIVATE

local function freecamFrame (deltaTime)
    freecamMouseApply(deltaTime)
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
    local camTargetZ

	-- Calculate what the maximum speed that the camera should be able to move at.
    local mspeed = options.normalMaxSpeed
    if getKeyState ( options.key_fastMove ) then
        mspeed = options.fastMaxSpeed
	elseif getKeyState ( options.key_slowMove ) then
		mspeed = options.slowMaxSpeed
    end

	if options.smoothMovement then
		local acceleration = options.acceleration
		local decceleration = options.decceleration

	    -- Check to see if the forwards/backwards keys are pressed
	    local speedKeyPressed = false
	    if ( getKeyState ( options.key_forward ) or getKeyState ( options.key_forward_veh ) ) and not getKeyState("arrow_u") then
			speed = speed + acceleration
	        speedKeyPressed = true
	    end
		if ( getKeyState ( options.key_backward ) or getPedControlState ( options.key_backward_veh ) ) and not getKeyState("arrow_d") then
			speed = speed - acceleration
	        speedKeyPressed = true
	    end

	    -- Check to see if the strafe keys are pressed
	    local strafeSpeedKeyPressed = false
		if ( getKeyState ( options.key_right ) or getKeyState ( options.key_right_veh ) ) and not getKeyState("arrow_r") then
	        if strafespeed > 0 then -- for instance response
	            strafespeed = 0
	        end
	        strafespeed = strafespeed - acceleration / 2
	        strafeSpeedKeyPressed = true
	    end
		if ( getKeyState ( options.key_left ) or getKeyState ( options.key_left_veh ) ) and not getKeyState("arrow_l") then
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
		if getKeyState ( options.key_forward ) or getKeyState ( options.key_forward_veh ) then
			speed = mspeed
		end
		if getKeyState ( options.key_backward ) or getKeyState ( options.key_backward_veh ) then
			speed = -mspeed
		end
		if getKeyState ( options.key_left ) or getKeyState ( options.key_left_veh ) then
			strafespeed = mspeed
		end
		if getKeyState ( options.key_right ) or getKeyState ( options.key_right_veh ) then
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
    setCameraMatrix ( camPosX, camPosY, camPosZ, camTargetX, camTargetY, camTargetZ, 0, options.fov )
end

-- Internal state (module-level)
local mouseFrameDelay   = 0           -- frames to ignore after cursor/window toggles
local accumDX, accumDY  = 0, 0        -- accumulated raw mouse deltas (pixels)
local PI, RAD           = math.pi, math.pi / 180

-- Tunables (adjust to taste)
local RESUME_FRAMES     = 5           -- frames to wait after cursor/window active
local DEADZONE_PX       = 0.15        -- ignore tiny jitters
local MAX_EVENT_DELTA   = 200         -- clamp a single event spike (px)
local APPLY_K_60FPS     = 0.42        -- how quickly to drain accumulator at 60fps (0..1)

-- Normalize angle to [-PI, PI]
local function normPI(a)
    a = a % (2 * PI)
    if a > PI then
		a = a - 2 * PI
	end
    return a
end

function freecamMouse(cX, cY, aX, aY)
    -- Gate input when the UI is up / focus lost
    if isCursorShowing() or isMTAWindowActive() or (not isMTAWindowFocused()) then
        mouseFrameDelay = RESUME_FRAMES
        accumDX, accumDY = 0, 0
        return
    elseif mouseFrameDelay > 0 then
        mouseFrameDelay = mouseFrameDelay - 1
        accumDX, accumDY = 0, 0
        return
    end

    -- How far from screen center?
    local dx = (aX - width  * 0.5)
    local dy = (aY - height * 0.5)

    -- Optional invert
    if options.invertMouseLook then
        dy = -dy
    end

    -- Deadzone + spike clamp
    if math.abs(dx) < DEADZONE_PX then
		dx = 0
	end
    if math.abs(dy) < DEADZONE_PX then
		dy = 0
	end
    if dx > MAX_EVENT_DELTA then
		dx = MAX_EVENT_DELTA
	elseif dx < -MAX_EVENT_DELTA then
		dx = -MAX_EVENT_DELTA
	end
    if dy > MAX_EVENT_DELTA then
		dy = MAX_EVENT_DELTA
	elseif dy < -MAX_EVENT_DELTA then
		dy = -MAX_EVENT_DELTA
	end

    -- Accumulate; application to rot happens in freecamMouseApply() every frame
    accumDX = accumDX + dx
    accumDY = accumDY + dy
end

function freecamMouseApply(deltaTime)
    -- If UI pops up mid-frame, bail early
    if isCursorShowing() or isMTAWindowActive() or (not isMTAWindowFocused()) then
        mouseFrameDelay = RESUME_FRAMES
        accumDX, accumDY = 0, 0
        return
    end

    -- Frame-rate–independent smoothing: convert APPLY_K_60FPS to current deltaTime
    -- factor = 1 - (1 - k)^(deltaTime * 60ms^-1)
    local factor = 1 - ((1 - APPLY_K_60FPS) ^ math.max(deltaTime / 16.666, 0.001))

    -- Take a smooth chunk out of the accumulator
    local useDX = accumDX * factor
    local useDY = accumDY * factor
    accumDX = accumDX - useDX
    accumDY = accumDY - useDY

    -- Convert pixels -> radians (sensitivity is in degrees/pixel)
    local rpp = (options.mouseSensitivity or 1) * RAD

    -- Apply to camera (note Y is typically "pitch" and inverted vs screen Y)
    rotX = normPI(rotX + useDX * rpp)
    rotY = rotY - useDY * rpp

    -- Clamp pitch to avoid gimbal lock / upside-down strafing
    local limit = PI / 2.05
    if rotY < -limit then
		rotY = -limit
    elseif rotY >  limit then
		rotY =  limit
    end
end

-- PUBLIC

function getFreecamVelocity()
	return velocityX,velocityY,velocityZ
end

-- params: x, y, z  sets camera's position (optional)
function setFreecamEnabled (x, y, z)
	if isFreecamEnabled() then
		return false
	end

	if (x and y and z) then
	    setCameraMatrix ( x, y, z, nil, nil, nil, 0, options.fov )
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

addEvent("doSetFreecamOption", true)
addEventHandler("doSetFreecamOption", root, setFreecamOption)
