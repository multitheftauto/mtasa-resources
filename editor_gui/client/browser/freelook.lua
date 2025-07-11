---Created by norby89, based upon freecam by eAi
-- state variables
local rotX, rotY = 0, 0
local cameraDistance = 0
local isEnabled = false
--coldnt figure out a "this event is already handled" bug so events are always handed until browser is turned off
local isHandled1, isHandled2
-- local tx, ty, tz = 0, 0, 0

-- configurable parameters
browserElementLookOptions = {
	mouseSensitivity = 1,
	maxYAngle = 188, -- 188.4955575 (90 degrees)
	camZOffset = 0, -- increase if the cam is too low

	invertedX = -1, -- invertedX should be left unchanged
	invertedY = -1,

	distance = 4,
	minDistance = 2,
	maxDistance = 40,
	scrollUnits = 2,
	scrollSpeed = 0.1,
	up = "mouse_wheel_up",
	down = "mouse_wheel_down",

	target = localPlayer
}

function elementLookFrame ()
	if not browserElementLookOptions.target then return end
	if not isHandled1 then return end
	if not isElementLookEnabled() then return end
	if ( cameraDistance ~= browserElementLookOptions.distance ) then
		resetCamDist()
	end

	-- work out an angle in radians based on the number of pixels the cursor has moved (ever)
	local camAngleX = browserElementLookOptions.invertedX * rotX / 120
	local camAngleY = browserElementLookOptions.invertedY * rotY / 120

	-- get the position of the target
	local camTargetX, camTargetY, camTargetZ = getElementPosition ( browserElementLookOptions.target )  -- tx, ty, tz
	camTargetZ = camTargetZ + browserElementLookOptions.camZOffset
	-- calculate a new positions for the camera
	local distX = math.cos ( camAngleY ) * cameraDistance
	local camPosX = camTargetX + ( ( math.cos ( camAngleX ) ) * distX )
	local camPosY = camTargetY + ( ( math.sin ( camAngleX ) ) * distX )
	local camPosZ = camTargetZ + math.sin ( camAngleY ) * cameraDistance

	-- set the new camera position and target
	setCameraMatrix ( camPosX, camPosY, camPosZ, camTargetX, camTargetY, camTargetZ )
end

function elementLookMouse ( cX, cY, aX, aY )
	if not isHandled2 then return end
	if not isElementLookEnabled() then return end
	if isMTAWindowActive() then return end
	--ignore mouse movement if the cursor is on
	if isCursorShowing() then return end

	local width, height = guiGetScreenSize()
	aX = aX - width / 2
	aY = aY - height / 2
	rotX = rotX + aX * browserElementLookOptions.mouseSensitivity
	rotY = rotY - aY * browserElementLookOptions.mouseSensitivity

	-- limit the camera to stop it going too far up or down
	if rotY < -browserElementLookOptions.maxYAngle then
		rotY = -browserElementLookOptions.maxYAngle
	elseif rotY > browserElementLookOptions.maxYAngle then
		rotY = browserElementLookOptions.maxYAngle
	end

	-- keep the angle within the 0, 360 range
	rotX = keepInRange ( toRad(360), rotX )
end

function resetCamDist()
	local multiplier = math.abs ( cameraDistance - browserElementLookOptions.distance )
	if multiplier < 0.1 then
		multiplier = 0
	end
	local newDistance = browserElementLookOptions.scrollSpeed * multiplier

	if cameraDistance < browserElementLookOptions.distance then
		if cameraDistance + newDistance < browserElementLookOptions.distance then
			cameraDistance = cameraDistance + newDistance
		else cameraDistance = browserElementLookOptions.distance
		end
	elseif cameraDistance - newDistance > browserElementLookOptions.distance then
			cameraDistance = cameraDistance - newDistance
		else cameraDistance = browserElementLookOptions.distance
	end
end

function keepInRange ( range, angle )
	if angle > range then
		while angle > range do
			angle = angle - range
		end
	elseif angle < 0 then
		while angle < 0 do
			angle = angle + range
		end
	end
	return angle
end

function toRad ( angle )
	return ( math.rad ( angle ) * 120 )
end

function toDeg ( angle )
	return ( math.deg ( angle / 120 ) )
end

function math.round ( value )
	return math.floor ( value + 0.5 )
end

function scrollDown()
	if browserElementLookOptions.distance + browserElementLookOptions.scrollUnits < browserElementLookOptions.maxDistance
		then browserElementLookOptions.distance = browserElementLookOptions.distance + browserElementLookOptions.scrollUnits
		else browserElementLookOptions.distance = browserElementLookOptions.maxDistance
	end
end

function scrollUp()
	if browserElementLookOptions.distance - browserElementLookOptions.scrollUnits > browserElementLookOptions.minDistance
		then browserElementLookOptions.distance = browserElementLookOptions.distance - browserElementLookOptions.scrollUnits
		else browserElementLookOptions.distance = browserElementLookOptions.minDistance
	end
end

-- param:  dontChangeFixedMode  leaves toggleCameraFixedMode alone if true, enables it if false or nil (optional)
function enableElementLook (dontChangeFixedMode, target, newRotX, newRotY)
	if isElementLookEnabled() then
		return false
	end

	if target then
		browserElementLookOptions.target = target
	else browserElementLookOptions.target = localPlayer
	end

	--tx, ty, tz = getElementPosition ( browserElementLookOptions.target )
	cameraDistance = browserElementLookOptions.distance
	if ( newRotX and newRotY ) then
		rotX = toRad ( 360 + 90 - newRotX )
		rotY = toRad ( newRotY )
	end

	bindControl ( browserElementLookOptions.down, "down", scrollDown )
	bindControl ( browserElementLookOptions.up, "down", scrollUp )
	isEnabled = true
end


-- param:  dontChangeFixedMode  leaves toggleCameraFixedMode alone if true, disables it if false or nil (optional)
function disableElementLook(dontChangeFixedMode)
	unbindControl ( browserElementLookOptions.up, "down", scrollUp )
	unbindControl ( browserElementLookOptions.down, "down", scrollDown )
	isEnabled = false
end

function isElementLookEnabled()
	return isEnabled
end

function setFreelookEvents(bool)
	if bool then
		isHandled1 = addEventHandler("onClientRender", root, elementLookFrame)
		isHandled2 = addEventHandler("onClientCursorMove",root,elementLookMouse)
	else
		removeEventHandler("onClientRender", root, elementLookFrame)
		removeEventHandler("onClientCursorMove",root,elementLookMouse)
		isHandled1,isHandled2 = false,false
	end
end
