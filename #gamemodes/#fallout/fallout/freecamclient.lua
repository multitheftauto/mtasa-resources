--Script credit: eAi
--outputChatBox ( "Freecam Loaded", 255, 127, 0 ) --DEBUG
local collision = true
local maxspeed, superspeed = .5, .75
local speed = 0
local strafespeed = 0
local rotspeed = 0.5
local accelfactor, deccelfactor = 0.3, 0.15
local rotX, rotY = 0,0
spectateActivated = false

function freecamLoad ( name )
	if name ~= getThisResource() then return end
end
addEventHandler ( "onClientResourceStart", getRootElement(), freecamLoad )

function activateFreeCam ( status )
	spectateActivated = status
end
addEvent("clientActivateFreeCam", true) --For triggering from server
addEventHandler("clientActivateFreeCam", getRootElement(), activateFreeCam)

function freecamFrame ()
	if ( spectateActivated == true ) then
	    -- work out an angle in radians based on the number of pixels the cursor has moved (ever)
	    local cameraAngleX = rotX / 120
	    local cameraAngleY = rotY / 120

	    local freeModeAngleX = math.sin(cameraAngleX / 2)
	    local freeModeAngleY = math.cos(cameraAngleX / 2)
	    local yangle = cameraAngleY / 1.5 -- the 1.5 limits the ammount the camera can rotate, decrease it to increase the amount

	    local freeModeAngleZ = math.sin(yangle)
	    local camPosX, camPosY, camPosZ, camTargetX, camTargetY, camTargetZ = getCameraMatrix()

	    -- calculate a target based on the current position and an offset based on the angle
	    local camTargetX = camPosX + freeModeAngleX * 100
	    local camTargetY = camPosY + freeModeAngleY * 100
	    local camTargetZ = camPosZ + freeModeAngleZ * 100

	    -- Check to see if the forwards/backwards keys are pressed
	    local speedKeyPressed = false
	    if getControlState ( "forwards" ) then
	        speed = speed + accelfactor
	        speedKeyPressed = true
	    end
		if getControlState ( "backwards" ) then
	        speed = speed - accelfactor
	        speedKeyPressed = true
	    end

	    -- Check to see if the strafe keys are pressed
	    local strafeSpeedKeyPressed = false
		if getControlState ( "right" ) then
	        if strafespeed > 0 then -- for instance response
	            strafespeed = 0
	        end
	        strafespeed = strafespeed - accelfactor / 2
	        strafeSpeedKeyPressed = true
	    end
		if getControlState ( "left" ) then
	        if strafespeed < 0 then -- for instance response
	            strafespeed = 0
	        end
	        strafespeed = strafespeed + accelfactor / 2
	        strafeSpeedKeyPressed = true
	    end


	    -- If no forwards/backwards keys were pressed, then gradually slow down the movement towards 0
	    if speedKeyPressed ~= true then
	        if speed > 0 then
	            speed = speed - deccelfactor
	        elseif speed < 0 then
	            speed = speed + deccelfactor
	        end
	    end

	    -- If no strafe keys were pressed, then gradually slow down the movement towards 0
	    if strafeSpeedKeyPressed ~= true then
	        if strafespeed > 0 then
	            strafespeed = strafespeed - deccelfactor
	        elseif strafespeed < 0 then
	            strafespeed = strafespeed + deccelfactor
	        end
	    end

	    -- Calculate what the maximum speed that the camera should be able to move at.
	    local mspeed = maxspeed
	    if getControlState ( "sprint" ) then
	        mspeed = superspeed
	    end

	    -- Check the ranges of values - set the speed to 0 if its very close to 0 (stops jittering), and limit to the maximum speed
	    if speed > -deccelfactor and speed < deccelfactor then
	        speed = 0
	    elseif speed > mspeed then
	        speed = mspeed
	    elseif speed < -mspeed then
	        speed = -mspeed
	    end

	    if strafespeed > -(accelfactor / 2) and strafespeed < (accelfactor / 2) then
	        strafespeed = 0
	    elseif strafespeed > mspeed then
	        strafespeed = mspeed
	    elseif strafespeed < -mspeed then
	        strafespeed = -mspeed
	    end

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

	    --Update the camera postion based on the forwards/backwards speed
	    camPosX = camPosX + freeModeAngleX * speed
	    camPosY = camPosY + freeModeAngleY * speed
	    camPosZ = camPosZ + freeModeAngleZ * speed

	    --Update the camera postion based on the strafe speed
	    camPosX = camPosX + normalX * strafespeed
	    camPosY = camPosY + normalY * strafespeed
	    camPosZ = camPosZ + normalZ * strafespeed

	    --Update the target based on the new camera position (again, otherwise the camera kind of sways as the target is out by a frame)
	    camTargetX = camPosX + freeModeAngleX * 100
	    camTargetY = camPosY + freeModeAngleY * 100
	    camTargetZ = camPosZ + freeModeAngleZ * 100

	    -- Set the new camera position and target
		setCameraMatrix( camPosX, camPosY, camPosZ, camTargetX, camTargetY, camTargetZ )
	    --setCameraLookAt ( camTargetX, camTargetY, camTargetZ )
	    --setCameraPosition ( camPosX, camPosY, camPosZ )
	end
end
------------------addEvent("shakePieces") --For triggering from server
addEventHandler ( "onClientRender", getRootElement(), freecamFrame )

function freecamMouse (cX,cY,aX,aY)
    local width, height = guiGetScreenSize()
    aX = aX - width / 2
    aY = aY - height / 2
    rotX = rotX + aX
    rotY = rotY - aY

    -- limit the camera to stop it going too far up or down
    if rotY < -200 then
        rotY = -200
    elseif rotY > 200 then
        rotY = 200
    end
end
addEventHandler ("onClientCursorMove",getRootElement(), freecamMouse )

 
function onGUIClicked (element)
	if element == dbg_col_button then
		collision = not collision
		guiSetText(element,dbg_col[collision])
	end
end
addEventHandler ("onClientGUIClicked",getRootElement(), onGUIClicked )