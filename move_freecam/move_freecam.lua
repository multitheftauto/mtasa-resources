-- TO DO
-- stop game physics from making OBJECTS spin and fall
-- make it possible for elements to hit surfaces properly

local SURFACE_ERROR_CORRECTION_OFFSET = .05
local MAX_DISTANCE = 150	--units
local MIN_DISTANCE = 2		--units

local maxMoveDistance = 100 --default
local rotateSpeed = {slow = 1, medium = 8, fast = 40} -- degrees per scroll
local zoomSpeed = {slow = 0.5, medium = 2, fast = 6}  -- units per scroll
local ignoreElementWalls = true -- 'false' not supported yet

local isEnabled = false

local camX, camY, camZ

local selectedElement
local centerToBaseDistance

local rotationless
local rotX, rotY, rotZ

local collisionless
local minZ

local hasRotation = {
	object = true,
	player = true,
	spawnpoint = true,
	vehicle = true,
	ped = true,
}

-- PRIVATE
local mta_getElementRotation = getElementRotation
local function getElementRotation(element)
	local elementType = getElementType(element)
	if elementType == "player" or elementType == "ped" then
		return 0,0,getPedRotation(element)
	elseif elementType == "object" then
		return mta_getElementRotation(element, "ZYX")
	elseif elementType == "vehicle" then
		return mta_getElementRotation(element, "ZYX")
	end
end

local function getCoordsWithBoundingBox(origX, origY, origZ)
	if (not collisionless) then
		local newX, newY, newZ = origX, origY, origZ
		if (ignoreElementWalls) then
			local surfaceFound, surfaceX, surfaceY, surfaceZ, element = processLineOfSight(origX, origY, origZ + SURFACE_ERROR_CORRECTION_OFFSET, origX, origY, origZ + minZ, true, true, true, true, true, true, false, true, selectedElement)
			if (surfaceFound) then
				newZ = surfaceZ + centerToBaseDistance
			end
		end
		return newX, newY, newZ
	else
		return false
	end
end

local function rotateWithMouseWheel(key, keyState)
	if (not rotationless) and getCommandState("mod_rotate") then
		local speed
		if (getCommandState("mod_slow_speed")) then
			speed = rotateSpeed.slow
		elseif (getCommandState("mod_fast_speed")) then
			speed = rotateSpeed.fast
		else
			speed = rotateSpeed.medium
		end
		if (key == "quick_rotate_decrease") then
			speed = speed * -1
		end
		if (getElementType(selectedElement) == "vehicle") or (getElementType(selectedElement) == "object") then
			rotX, rotY, rotZ = exports.editor_main:applyIncrementalRotation(selectedElement, "yaw", speed)
			--Peds dont have their rotation updated with their attached parents
			for i,element in ipairs(getAttachedElements(selectedElement)) do
				if getElementType(element) == "ped" then
					setElementRotation(element, 0,0,-rotZ)
					setPedRotation(element, rotZ)
				end
			end
		elseif (getElementType(selectedElement) == "ped") then
			rotZ = rotZ + speed
			rotZ = rotZ % 360
			setPedRotation(selectedElement, rotZ)
			setElementRotation(selectedElement, 0,0,-rotZ%360)
		end
	end
end

local function zoomWithMouseWheel(key, keyState)
	if not getCommandState("mod_rotate") then
		local speed
	    if (getCommandState("mod_slow_speed")) then
			speed = zoomSpeed.slow
		elseif (getCommandState("mod_fast_speed")) then
			speed = zoomSpeed.fast
	    else
			speed = zoomSpeed.medium
	    end

	    if key == "zoom_in" then
			maxMoveDistance = math.max(maxMoveDistance - speed, MIN_DISTANCE)
	    else --if key == "zoom_out"
			maxMoveDistance = math.min(maxMoveDistance + speed, MAX_DISTANCE)
	    end
	end
end

local function onClientRender_freecam()
	if (selectedElement and isElement(selectedElement)) then
		setElementVelocity(selectedElement,0,0,0) --!w

	    camX, camY, camZ, targetX, targetY, targetZ = getCameraMatrix()

		-- alter the vector length to fit the maximum distance
		local distance = getDistanceBetweenPoints3D ( camX, camY, camZ, targetX, targetY, targetZ )
		targetX = camX + ((targetX - camX)/distance) * maxMoveDistance
		targetY = camY + ((targetY - camY)/distance) * maxMoveDistance
		targetZ = camZ + ((targetZ - camZ)/distance) * maxMoveDistance

		-- process line, checking for water and surfaces
		local surfaceFound, surfaceX, surfaceY, surfaceZ, element = processLineOfSight(camX, camY, camZ, targetX, targetY, targetZ, true, true, true, true, true, true, false, true, selectedElement)
		local waterFound, waterX, waterY, waterZ = testLineAgainstWater(camX, camY, camZ, targetX, targetY, targetZ)

		-- raise height if pickup or a marker
		if (getElementType(selectedElement) == "pickup") or (getElementType(selectedElement) == "marker") then
			if (surfaceFound) then
				surfaceZ = surfaceZ + 1
			end
			if (waterFound) then
				waterZ = waterZ + 1
			end
		end

		-- check if water or surface was found
		if (surfaceFound and waterFound) then
			-- if both found, compare distances
			local waterDistanceSquared = (waterX - camX)^2 + (waterY - camY)^2 + (waterZ - camZ)^2
			local surfaceDistanceSquared = (surfaceX - camX)^2 + (surfaceY - camY)^2 + (surfaceZ - camZ)^2
			if (waterDistanceSquared >= surfaceDistanceSquared) then
				if (not collisionless) then
					local finalX, finalY, finalZ = getCoordsWithBoundingBox(surfaceX, surfaceY, surfaceZ)
					setElementPosition(selectedElement, finalX, finalY, finalZ)
				else
					setElementPosition(selectedElement, surfaceX, surfaceY, surfaceZ)
				end
			else
				if (not collisionless) then
					local finalX, finalY, finalZ = getCoordsWithBoundingBox(waterX, waterY, waterZ)
					setElementPosition(selectedElement, finalX, finalY, finalZ)
				else
					setElementPosition(selectedElement, waterX, waterY, waterZ)
				end
			end
		elseif (surfaceFound) then
			if (not collisionless) then
				local finalX, finalY, finalZ = getCoordsWithBoundingBox(surfaceX, surfaceY, surfaceZ)
				setElementPosition(selectedElement, finalX, finalY, finalZ)
			else
				setElementPosition(selectedElement, surfaceX, surfaceY, surfaceZ)
			end
		elseif (waterFound) then
			if (not collisionless) then
				local finalX, finalY, finalZ = getCoordsWithBoundingBox(waterX, waterY, waterZ)
				setElementPosition(selectedElement, finalX, finalY, finalZ)
			else
				setElementPosition(selectedElement, waterX, waterY, waterZ)
			end
		else
			setElementPosition(selectedElement, targetX, targetY, targetZ)
		end

		rotX, rotY, rotZ = getElementRotation(selectedElement, "ZYX")
	else
		selectedElement = nil
	end
end

-- EXPORTED
function attachElement(element)
	if (not selectedElement and not isCursorShowing()) then
		-- get element info
	    selectedElement = element
		-- do not attach if it's not really an element
		if not isElement(selectedElement) then
			selectedElement = nil
			return false
		end
		--EDF implementation
		if getResourceFromName"edf" and exports.edf:edfGetParent(element) ~= element then
			if (getElementType(element) == "object") then
				rotationless = false
				rotX, rotY, rotZ = getElementRotation(element, "ZYX")
				collisionless = false
				_, _, minZ = exports.edf:edfGetElementBoundingBox(element)
				centerToBaseDistance = exports.edf:edfGetElementDistanceToBase(element)
			end
		else
			if (getElementType(element) == "vehicle") then
				rotationless = false
				rotX, rotY, rotZ = getElementRotation(element, "ZYX")
				collisionless = false
				_, _, minZ = getElementBoundingBox(element)
				centerToBaseDistance = getElementDistanceFromCentreOfMassToBaseOfModel(element)
			elseif (getElementType(element) == "object") then
				rotationless = false
				rotX, rotY, rotZ = getElementRotation(element, "ZYX")
				collisionless = false
				_, _, minZ = getElementBoundingBox(element)
				centerToBaseDistance = getElementDistanceFromCentreOfMassToBaseOfModel(element)
			elseif (getElementType(element) == "ped") then
				rotationless = false
				rotX, rotY, rotZ = 0, 0, getPedRotation(element)
				collisionless = false
				_, _, minZ = getElementBoundingBox(element)
				centerToBaseDistance = getElementDistanceFromCentreOfMassToBaseOfModel(element)
			else
				rotationless = true
				collisionless = true
			end
		end
	    -- add events, bind keys
		enable()
	    return true
	else
	    return false
	end
end

function detachElement()
	if (selectedElement) then
		-- remove events, unbind keys
		disable()
		
		-- fix for local elements
		if not isElementLocal(selectedElement) then
		
			-- sync position/rotation
			local tempPosX, tempPosY, tempPosZ = getElementPosition(selectedElement)
			
			triggerServerEvent("syncProperty", localPlayer, "position", {tempPosX, tempPosY, tempPosZ}, exports.edf:edfGetAncestor(selectedElement))
			if hasRotation[getElementType(selectedElement)] then
				triggerServerEvent("syncProperty", localPlayer, "rotation", {rotX, rotY, rotZ}, exports.edf:edfGetAncestor(selectedElement))
			end
		end
		selectedElement = nil

		-- clear variables
		camX, camY, camZ = nil, nil, nil
		if (not rotationless) then
			rotX, rotY, rotZ = nil, nil, nil
		end
		rotationless = nil
		if (not collisionless) then
			minZ = nil
			centerToBaseDistance = nil
		end
		collisionless = nil
		return true
	else
		return false
	end
end

function ignoreWalls(ignore)
	ignoreElementWalls = ignore
end

function setMaxMoveDistance(distance)
	maxMoveDistance = distance
end

function setRotateSpeeds(slow, medium, fast)
	rotateSpeed.slow = slow
	rotateSpeed.medium = medium
	rotateSpeed.fast = fast
end

function setZoomSpeeds(slow, medium, fast)
	zoomSpeed.slow = slow
	zoomSpeed.medium = medium
	zoomSpeed.fast = fast
end

function getAttachedElement()
	return selectedElement or false
end

function getMaxMoveDistance()
	return maxMoveDistance
end

function getRotateSpeeds()
	return rotateSpeed.slow, rotateSpeed.medium, rotateSpeed.fast
end

function getZoomSpeeds()
	return zoomSpeed.slow, zoomSpeed.medium, zoomSpeed.fast
end

function enable()
	if isEnabled then
		return false
	end
	addEventHandler("onClientRender", root, onClientRender_freecam)
	bindControl("quick_rotate_increase", "down", rotateWithMouseWheel) --rotate left
	bindControl("quick_rotate_decrease", "down", rotateWithMouseWheel) --rotate right
	bindControl("zoom_in", "down", zoomWithMouseWheel) --zoom in
	bindControl("zoom_out", "down", zoomWithMouseWheel) --zoom out
	isEnabled = true
end

function disable()
	if (not isEnabled) then
		return false
	end
	removeEventHandler("onClientRender", root, onClientRender_freecam)
	unbindControl("quick_rotate_increase", "down", rotateWithMouseWheel) --rotate left
	unbindControl("quick_rotate_decrease", "down", rotateWithMouseWheel) --rotate right
	unbindControl("zoom_in", "down", zoomWithMouseWheel) --zoom in
	unbindControl("zoom_out", "down", zoomWithMouseWheel) --zoom out
	isEnabled = false
end
