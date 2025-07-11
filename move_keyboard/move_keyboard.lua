-- implement bounding box checking
local lastKEYSTATES = {}

local ignoreAllSurfaces = true
local moveSpeed = {slow = .025, medium = .25, fast = 2} -- meters per frame
local rotateSpeed = {slow = 1, medium = 8, fast = 40} -- degrees per scroll or frame
local scaleIncrement = 0.1

local isEnabled = false

local selectedElement

local posX, posY, posZ
local rotX, rotY, rotZ
local scale

local collisionless
local lockToAxes = false
local centerToBaseDistance

local movementType
local MOVEMENT_MOVE = 1
local MOVEMENT_ROTATE_WORLD = 2
local MOVEMENT_ROTATE_LOCAL = 3

local hasRotation = {
	object = true,
	player = true,
	vehicle = true,
	ped = true,
}

-- PRIVATE

local function getCameraRotation ()
	local px, py, pz, lx, ly, lz = getCameraMatrix()
	local rotz = 6.2831853071796 - math.atan2 ( ( lx - px ), ( ly - py ) ) % 6.2831853071796
	local rotx = math.atan2 ( lz - pz, getDistanceBetweenPoints2D ( lx, ly, px, py ) )
	--Convert to degrees
	rotx = math.deg(rotx)
	rotz = -math.deg(rotz)

	return rotx, 180, rotz
end

local function roundRotation ( rot )
	if rot < 45 then
		return -rot
	else return (90 - rot) end
end

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
	-- leave for now..
	local newX, newY, newZ = origX, origY, origZ
	return newX, newY, newZ
end

function getCommandTogSTATE(cmd)
	if getCommandState(cmd) == lastKEYSTATES[cmd] then
		return false
	end
	return getCommandState(cmd)
end

local function onClientRender_keyboard()
	if isMTAWindowActive() then
		return
	end
	if (selectedElement) then
		if (not isElement(selectedElement)) then
			selectedElement = nil
			return
		end
		if (getElementType(selectedElement) == "vehicle" and getVehicleType(selectedElement) == "Train") then
			setTrainDerailed(selectedElement, true)
		end
		if not (getCommandState("mod_rotate")) and not (getCommandState("mod_rotate_local")) then -- set position
			if movementType ~= MOVEMENT_MOVE then
				setMovementType("move")
				movementType = MOVEMENT_MOVE
			end

			local tempX, tempY, tempZ = posX, posY, posZ
			local camRotX, camRotY, camRotZ = getCameraRotation()
			camRotZ = camRotZ%360
			if ( lockToAxes ) then
				local remainder = math.mod ( camRotZ, 90 )
				camRotZ = camRotZ + roundRotation ( remainder )
			end

			local speed
			if (getCommandState("mod_slow_speed")) then
				speed = moveSpeed.slow
			elseif (getCommandState("mod_fast_speed")) then
				speed = moveSpeed.fast
			else
				speed = moveSpeed.medium
			end

			-- convert getCameraRotation output to radians
			camRotZ = math.rad(camRotZ)
			local distanceX = speed * math.cos(camRotZ)
			local distanceY = speed * math.sin(camRotZ)

			-- right/left
			if (getCommandState("element_move_right")) then
				tempX = tempX + distanceX
				tempY = tempY - distanceY
			end
			if (getCommandState("element_move_left")) then
				tempX = tempX - distanceX
				tempY = tempY + distanceY
			end

			-- forward/back
			if (getCommandState("element_move_forward")) then
				tempX = tempX + distanceY
				tempY = tempY + distanceX
			end

			if (getCommandState("element_move_backward")) then
				tempX = tempX - distanceY
				tempY = tempY - distanceX
			end

			-- up/down
			if (getCommandState("element_move_upwards")) then
				tempZ = tempZ + speed
			end
			if (getCommandState("element_move_downwards")) then
				tempZ = tempZ - speed
			end

			-- check if position changed
			if (not (tempX == posX and tempY == posY and tempZ == posZ)) then
				if (ignoreAllSurfaces) then
					posX, posY, posZ = tempX, tempY, tempZ
				else
					-- get new coords with offsets from element's bounding box
					posX, posY, posZ = getCoordsWithBoundingBox(tempX, tempY, tempZ)
				end
				setElementPosition(selectedElement, posX, posY, posZ)
			end

		elseif (not getCommandState("reset_rotation")) then -- set rotation
			local exactsnap = exports["editor_gui"]:sx_getOptionData("enablePrecisionRotation")
			local snaplevel = tonumber(exports["editor_gui"]:sx_getOptionData("precisionRotLevel"))
			if exactsnap then -- if we want a exact rotation lets fix keyboard...
				local world_space = not getCommandState("mod_rotate_local")
				if world_space and movementType ~= MOVEMENT_ROTATE_WORLD then
					setMovementType("rotate_world")
					movementType = MOVEMENT_ROTATE_WORLD
				elseif not world_space and movementType ~= MOVEMENT_ROTATE_LOCAL then
					setMovementType("rotate_local")
					movementType = MOVEMENT_ROTATE_LOCAL
				end

				local speed = snaplevel

				if (getElementType(selectedElement) == "ped") or getElementType(selectedElement) == "player" then
					local tempRot = rotZ

					-- right/left
					if (getCommandTogSTATE("element_move_right")) then
						tempRot = tempRot - speed
					end
					if (getCommandTogSTATE("element_move_left")) then
						tempRot = tempRot + speed
					end
					tempRot = tempRot % 360

					-- check if rotation changed
					if (tempRot ~= rotZ) then
						if (getElementType(selectedElement) == "ped") then
							setElementRotation(selectedElement, 0,0,-tempRot%360)
							setPedRotation(selectedElement, tempRot)
						end
					end
					rotZ = tempRot
				else
					local tempRotX, tempRotY, tempRotZ = rotX, rotY, rotZ
					if (not tempRotX) then return false end
					
					local yaw, pitch, roll = 0, 0, 0
					
					-- yaw
					if (getCommandTogSTATE("element_move_right")) then
						yaw = speed
					elseif (getCommandTogSTATE("element_move_left")) then
						yaw = -speed
					end

					-- pitch
					if (getCommandTogSTATE("element_move_upwards")) then
						pitch = speed
					elseif (getCommandTogSTATE("element_move_downwards")) then
						pitch = -speed
					end
					
					-- roll
					if (getCommandTogSTATE("element_move_forward")) then
						roll = speed
					elseif (getCommandTogSTATE("element_move_backward")) then
						roll = -speed
					end
					
					-- Perform rotation about one axis at a time
					if yaw ~= 0 then
						tempRotX, tempRotY, tempRotZ = exports.editor_main:applyIncrementalRotation(selectedElement, "yaw", yaw, world_space)
					end
					if pitch ~= 0 then
						tempRotX, tempRotY, tempRotZ = exports.editor_main:applyIncrementalRotation(selectedElement, "pitch", pitch, world_space)
					end
					if roll ~= 0 then
						tempRotX, tempRotY, tempRotZ = exports.editor_main:applyIncrementalRotation(selectedElement, "roll", roll, world_space)
					end

					-- check if rotation changed
					if (not (tempRotX == rotX and tempRotY == rotY and tempRotZ == rotZ)) then
						--Peds dont have their rotation updated with their attached parents
						for i,element in ipairs(getAttachedElements(selectedElement)) do
							if getElementType(element) == "ped" then
								setElementRotation(element, 0,0,-tempRotZ%360)
								setPedRotation(element, tempRotZ%360)
							end
						end
						rotX, rotY, rotZ = tempRotX, tempRotY, tempRotZ
					end
				end
				lastKEYSTATES["element_move_right"] = getCommandState("element_move_right")
				lastKEYSTATES["element_move_left"] = getCommandState("element_move_left")
				lastKEYSTATES["element_move_forward"] = getCommandState("element_move_forward")
				lastKEYSTATES["element_move_backward"] = getCommandState("element_move_backward")
				lastKEYSTATES["element_move_upwards"] = getCommandState("element_move_upwards")
				lastKEYSTATES["element_move_downwards"] = getCommandState("element_move_downwards")
			else
				local bind
				local world_space = not getCommandState("mod_rotate_local")
				if world_space and movementType ~= MOVEMENT_ROTATE_WORLD then
					setMovementType("rotate_world")
					movementType = MOVEMENT_ROTATE_WORLD
				elseif not world_space and movementType ~= MOVEMENT_ROTATE_LOCAL then
					setMovementType("rotate_local")
					movementType = MOVEMENT_ROTATE_LOCAL
				end

				local speed
				if (getCommandState("mod_slow_speed")) then
					speed = rotateSpeed.slow
				elseif (getCommandState("mod_fast_speed")) then
					speed = rotateSpeed.fast
				else
					speed = rotateSpeed.medium
				end

				if (getElementType(selectedElement) == "ped") or getElementType(selectedElement) == "player" then
					local tempRot = rotZ

					-- right/left
					if (getCommandState("element_move_right")) then
						tempRot = tempRot - speed
					end
					if (getCommandState("element_move_left")) then
							tempRot = tempRot + speed
					end
					tempRot = tempRot % 360

					-- check if rotation changed
					if (tempRot ~= rotZ) then
						if (getElementType(selectedElement) == "ped") then
							setElementRotation(selectedElement, 0,0,-tempRot%360)
							setPedRotation(selectedElement, tempRot)
						end
					end
					rotZ = tempRot

				else
					local tempRotX, tempRotY, tempRotZ = rotX, rotY, rotZ
					if (not tempRotX) then return false end

					local yaw, pitch, roll = 0, 0, 0
					
					-- yaw
					if (getCommandTogSTATE("element_move_right")) then
						yaw = speed
					elseif (getCommandTogSTATE("element_move_left")) then
						yaw = -speed
					end

					-- pitch
					if (getCommandTogSTATE("element_move_upwards")) then
						pitch = speed
					elseif (getCommandTogSTATE("element_move_downwards")) then
						pitch = -speed
					end
					
					-- roll
					if (getCommandTogSTATE("element_move_forward")) then
						roll = speed
					elseif (getCommandTogSTATE("element_move_backward")) then
						roll = -speed
					end
					
					-- Perform rotation about one axis at a time
					if yaw ~= 0 then
						tempRotX, tempRotY, tempRotZ = exports.editor_main:applyIncrementalRotation(selectedElement, "yaw", yaw, world_space)
					end
					if pitch ~= 0 then
						tempRotX, tempRotY, tempRotZ = exports.editor_main:applyIncrementalRotation(selectedElement, "pitch", pitch, world_space)
					end
					if roll ~= 0 then
						tempRotX, tempRotY, tempRotZ = exports.editor_main:applyIncrementalRotation(selectedElement, "roll", roll, world_space)
					end

					-- check if rotation changed
					if (not (tempRotX == rotX and tempRotY == rotY and tempRotZ == rotZ)) then
						--Peds dont have their rotation updated with their attached parents
						for i,element in ipairs(getAttachedElements(selectedElement)) do
							if getElementType(element) == "ped" then
								setElementRotation(element, 0,0,-tempRotZ%360)
								setPedRotation(element, tempRotZ%360)
							end
						end
						rotX, rotY, rotZ = tempRotX, tempRotY, tempRotZ
					end
				end
			end
		else -- reset rotation
			if (rotX and rotY and rotZ) then
				if getCommandState("mod_rotate") then
					if (getElementType(selectedElement) == "vehicle") or (getElementType(selectedElement) == "object") then
						exports.editor_main:clearElementQuat(selectedElement)
						setElementRotation(selectedElement, 0, 0, rotZ)
						rotX, rotY = 0, 0
						for i,element in ipairs(getAttachedElements(selectedElement)) do
							if getElementType(element) == "ped" then
								setElementRotation(element, 0,0,-rotZ%360)
								setPedRotation(element, rotZ%360)
							end
						end
					elseif (getElementType(selectedElement) == "ped") then
						rotZ = 0
						setPedRotation ( selectedElement, 0, 0, 0 )
						setElementRotation ( selectedElement, 0, 0, 0 )
					end
				end
			end
		end

		-- Scale up/down for objects
        if getElementType(selectedElement) == "object" then
			local currentScale = getObjectScale(selectedElement)
            if getCommandState("element_scale_up") then
                currentScale = currentScale + scaleIncrement
			elseif getCommandState("element_scale_down") then
                currentScale = currentScale - scaleIncrement
            end
            setObjectScale(selectedElement, currentScale)
        end
	end
end

local function rotateWithMouseWheel(key, keyState)
	if (isCursorShowing() and exports.editor_gui:guiGetMouseOverElement()) then
		return
	end
	local speed

	local world_space = not getCommandState("mod_rotate_local")
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

	rotX, rotY, rotZ = getElementRotation(selectedElement, "ZYX")
	if (getElementType(selectedElement) == "vehicle" or getElementType(selectedElement) == "object") then
		rotX, rotY, rotZ = exports.editor_main:applyIncrementalRotation(selectedElement, "yaw", speed, world_space)
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
		setElementRotation(selectedElement, 0,0,-rotZ)
		setPedRotation(selectedElement, rotZ)
	end
end

-- PUBLIC

function attachElement(element)
	if (not selectedElement) then
		selectedElement = element
		posX, posY, posZ = getElementPosition(element)
		movementType = MOVEMENT_MOVE

		-- Clear the quat rotation when attaching to element
		exports.editor_main:clearElementQuat(selectedElement)

		if (getElementType(element) == "vehicle") or (getElementType(element) == "object") then
			rotX, rotY, rotZ = getElementRotation(element, "ZYX")
		elseif (getElementType(element) == "player") or (getElementType(element) == "ped") then
			rotX, rotY, rotZ = 0,0,getPedRotation ( element )
		end
		enable()
		return true
	else
		return false
	end
end

function detachElement()
	if (selectedElement) then
		disable()

		-- Clear the quat rotation when detaching from element
		exports.editor_main:clearElementQuat(selectedElement)

		-- fix for local elements
		if not isElementLocal(selectedElement) then
			-- sync position/rotation
			posX, posY, posZ = getElementPosition(selectedElement)
			triggerServerEvent("syncProperty", localPlayer, "position", {posX, posY, posZ}, exports.edf:edfGetAncestor(selectedElement))
			if hasRotation[getElementType(selectedElement)] then
				rotX, rotY, rotZ = getElementRotation(selectedElement, "ZYX")
				triggerServerEvent("syncProperty", localPlayer, "rotation", {rotX, rotY, rotZ}, exports.edf:edfGetAncestor(selectedElement))
			end
			if getElementType(selectedElement) == "object" then
				scale = getObjectScale(selectedElement)
				triggerServerEvent("syncProperty", localPlayer, "scale", scale, exports.edf:edfGetAncestor(selectedElement))
			end
		end
		selectedElement = nil
		posX, posY, posZ = nil, nil, nil
		rotX, rotY, rotZ = nil, nil, nil
		scale = nil
		return true
	else
		return false
	end
end

function ignoreAllSurfaces(ignore)
	ignoreAllSurfaces = ignore
end

function setMoveSpeeds(slow, medium, fast)
	moveSpeed.slow = slow
	moveSpeed.medium = medium
	moveSpeed.fast = fast
end

function setRotateSpeeds(slow, medium, fast)
	rotateSpeed.slow = slow
	rotateSpeed.medium = medium
	rotateSpeed.fast = fast
end

function setScaleIncrement(increment)
	scaleIncrement = increment
end

function getAttachedElement()
	if (selectedElement) then
		return selectedElement
	else
	    return false
	end
end

function getMoveSpeeds()
	return moveSpeed.slow, moveSpeed.medium, moveSpeed.fast
end

function getRotateSpeeds()
	return rotateSpeed.slow, rotateSpeed.medium, rotateSpeed.fast
end

function getScaleIncrement()
	return scaleIncrement
end

function toggleAxesLock ( bool )
	lockToAxes = bool
	return true
end

function enable()
	if isEnabled then
		return false
	end
	bindControl("quick_rotate_increase", "down", rotateWithMouseWheel) --rotate left
	bindControl("quick_rotate_decrease", "down", rotateWithMouseWheel) --rotate right
	addEventHandler("onClientRender", root, onClientRender_keyboard)
	isEnabled = true
end

function disable()
	if (not isEnabled) then
		return false
	end
	unbindControl("quick_rotate_increase", "down", rotateWithMouseWheel) --rotate left
	unbindControl("quick_rotate_decrease", "down", rotateWithMouseWheel) --rotate right
	removeEventHandler("onClientRender", root, onClientRender_keyboard)
	isEnabled = false
end

function setMovementType(movementType2)
	call(getResourceFromName("editor_main"), "setMovementType", movementType2)
end
