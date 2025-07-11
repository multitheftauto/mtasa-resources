-- TO DO
-- stop game physics from making OBJECTS spin and fall
-- make it possible for elements to hit surfaces properly

local g_screenX,g_screenY = guiGetScreenSize()
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

local ignoreFirst

local hasRotation = {
	object = true,
	player = true,
	vehicle = true,
	ped = true,
}

local onClientMouseMove

local function getCoordsWithBoundingBox(origX, origY, origZ)
	if (not collisionless) then
		local newX, newY, newZ = origX, origY, origZ
		if ignoreElementWalls then
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

local function processCursorMove(absoluteX, absoluteY)
	if not absoluteX or not absoluteY then
		local relX, relY = getCursorPosition()
		-- brief cursor fix
		if not (relX and relY) then return end
		absoluteX, absoluteY = relX*g_screenX, relY*g_screenY
	end
	-- process line, checking for water and surfaces
	local worldX, worldY, worldZ = getWorldFromScreenPosition(absoluteX, absoluteY, MAX_DISTANCE )
	-- make sure there is a camera position
	if camX and camY then
		local surfaceFound, surfaceX, surfaceY, surfaceZ, element = processLineOfSight(camX, camY, camZ, worldX, worldY, worldZ, true, true, true, true, true, true, false, true, selectedElement)
		local waterFound, waterX, waterY, waterZ = testLineAgainstWater(camX, camY, camZ, worldX, worldY, worldZ)

		-- check if surfaces are not too far
		local surfaceDistance
		local waterDistance
		if (surfaceFound) then
			surfaceDistance = math.sqrt((surfaceX - camX)^2 + (surfaceY - camY)^2 + (surfaceZ - camZ)^2)
			if (surfaceDistance > maxMoveDistance) then
				surfaceFound = false
			end
		end
		if (waterFound) then
			waterDistance = math.sqrt((waterX - camX)^2 + (waterY - camY)^2 + (waterZ - camZ)^2)
			if (waterDistance > maxMoveDistance) then
				waterFound = false
			end
		end

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
			if (waterDistance >= surfaceDistance) then
				if (not collisionless) then
					centerToBaseDistance = exports.edf:edfGetElementDistanceToBase(selectedElement)
					local finalX, finalY, finalZ = getCoordsWithBoundingBox(surfaceX, surfaceY, surfaceZ)
					setElementPosition(selectedElement, finalX, finalY, finalZ)
				else
					setElementPosition(selectedElement, surfaceX, surfaceY, surfaceZ)
				end
			else
				if (not collisionless) then
					centerToBaseDistance = exports.edf:edfGetElementDistanceToBase(selectedElement)
					local finalX, finalY, finalZ = getCoordsWithBoundingBox(waterX, waterY, waterZ)
					setElementPosition(selectedElement, finalX, finalY, finalZ)
				else
					setElementPosition(selectedElement, waterX, waterY, waterZ)
				end
			end
		elseif (surfaceFound) then
			if (not collisionless) then
				centerToBaseDistance = exports.edf:edfGetElementDistanceToBase(selectedElement)
				local finalX, finalY, finalZ = getCoordsWithBoundingBox(surfaceX, surfaceY, surfaceZ)
				setElementPosition(selectedElement, finalX, finalY, finalZ)
			else
				setElementPosition(selectedElement, surfaceX, surfaceY, surfaceZ)
			end
		elseif (waterFound) then
			if (not collisionless) then
				centerToBaseDistance = exports.edf:edfGetElementDistanceToBase(selectedElement)
				local finalX, finalY, finalZ = getCoordsWithBoundingBox(waterX, waterY, waterZ)
				setElementPosition(selectedElement, finalX, finalY, finalZ)
			else
				setElementPosition(selectedElement, waterX, waterY, waterZ)
			end
		else -- in air
			local tempDistance = math.sqrt((worldX - camX)^2 + (worldY - camY)^2 + (worldZ - camZ)^2)
			local distanceRatio = maxMoveDistance / tempDistance
			local x = camX + (worldX - camX) * distanceRatio
			local y = camY + (worldY - camY) * distanceRatio
			local z = camZ + (worldZ - camZ) * distanceRatio
			setElementPosition(selectedElement, x, y, z)
		end
	end
end

local function onClientCursorMove_cursor(_, _, absoluteX, absoluteY )
	if (selectedElement and isElement(selectedElement)) then
		if ignoreFirst then
			ignoreFirst = false
			return
		end
		processCursorMove ( absoluteX, absoluteY )
	else
		selectedElement = nil
		return
	end
end

local function rotateWithMouseWheel(key, keyState)
	if (not rotationless) and getCommandState("mod_rotate") then
		rotX, rotY, rotZ = getElementRotation(selectedElement)
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
		
		local elementType = getElementType(selectedElement)
		if (elementType == "vehicle") or (elementType == "object") then
			rotX, rotY, rotZ = exports.editor_main:applyIncrementalRotation(selectedElement, "yaw", speed)
			--Peds dont have their rotation updated with their attached parents
			for i,element in ipairs(getAttachedElements(selectedElement)) do
				if getElementType(element) == "ped" then
					setElementRotation(element, 0,0,-rotZ)
					setPedRotation(element, rotZ)
				end
			end
		elseif (elementType == "ped") then
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

		--force an update if an element is selected
		if selectedElement then
			local elemX, elemY, elemZ = getElementPosition(selectedElement)
			onClientCursorMove_cursor(false, false, false, false, elemX, elemY, elemZ)
		end
	end
end

-- EXPORTED
function attachElement(element)
	if selectedElement or not isCursorShowing() then
		return false
	end

	camX, camY, camZ = getCameraMatrix()
	-- get element info
	selectedElement = element
	
	-- do not attach if it's not really an element
	if not (selectedElement and isElement(selectedElement)) then
		selectedElement = nil
		return false
	end
	
	--EDF implementation
	if getResourceFromName"edf" and exports.edf:edfGetParent(element) ~= element then
		if (getElementType(element) == "object") then
			rotationless = false
			rotX, rotY, rotZ = getElementRotation(element)
			collisionless = false
			_, _, minZ = exports.edf:edfGetElementBoundingBox(element)
		end
	else
		if (getElementType(element) == "vehicle") or (getElementType(element) == "object") then
			rotationless = false
			rotX, rotY, rotZ = getElementRotation(element)
			collisionless = false
			_, _, minZ = getElementBoundingBox(element)
		elseif (getElementType(element) == "ped") then
			rotationless = false
			rotX, rotY, rotZ = 0, 0, getPedRotation(element)
			collisionless = false
			_, _, minZ = getElementBoundingBox(element)
		else
			rotationless = true
			collisionless = true
		end
	end

	enable()

	return true
end

function detachElement()
	if not selectedElement then
		return false
	end

	-- remove events, unbind keys
	disable()
	
	-- fix for local elements
	if not isElementLocal(selectedElement) then
		-- sync position/rotation
		local tempPosX, tempPosY, tempPosZ = getElementPosition(selectedElement)
		
		triggerServerEvent("syncProperty", localPlayer, "position", {tempPosX, tempPosY, tempPosZ}, exports.edf:edfGetAncestor(selectedElement))
		if hasRotation[getElementType(selectedElement)] then
			rotX, rotY, rotZ = getElementRotation(selectedElement, "ZYX")
			triggerServerEvent("syncProperty", localPlayer, "rotation", {rotX, rotY, rotZ}, exports.edf:edfGetAncestor(selectedElement))
		end
	end
	selectedElement = nil

	-- clear variables
	camX, camY, camZ = nil, nil, nil
	rotX, rotY, rotZ = nil, nil, nil
	rotationless = nil
	minZ = nil
	collisionless = nil

	return true
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
	return selectedElement
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

function disable()
	if isEnabled then
		removeEventHandler("onClientCursorMove", root, onClientCursorMove_cursor)
		unbindControl("quick_rotate_increase", "down", rotateWithMouseWheel)
		unbindControl("quick_rotate_decrease", "down", rotateWithMouseWheel)
		unbindControl("zoom_in", "down", zoomWithMouseWheel)
		unbindControl("zoom_out", "down", zoomWithMouseWheel)
		isEnabled = false
	end
	return true
end

function enable()
	if not isEnabled then
		ignoreFirst = true
		addEventHandler("onClientCursorMove", root, onClientCursorMove_cursor)
		bindControl("quick_rotate_increase", "down", rotateWithMouseWheel)
		bindControl("quick_rotate_decrease", "down", rotateWithMouseWheel)
		bindControl("zoom_in", "down", zoomWithMouseWheel)
		bindControl("zoom_out", "down", zoomWithMouseWheel)
		setTimer(processCursorMove, 50, 1) --Lazy but we have to wait for MTA to switch modes
		isEnabled = true
	end
	return true
end
