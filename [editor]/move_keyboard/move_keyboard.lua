-- implement bounding box checking
local lastKEYSTATES = {}

local ignoreAllSurfaces = true
local moveSpeed = {slow = .025, medium = .25, fast = 2} -- meters per frame
local rotateSpeed = {slow = 1, medium = 8, fast = 40} -- degrees per scroll or frame

local selectedElement

local posX, posY, posZ

local rotationless
local rotX, rotY, rotZ
local rotFlipped = false

local collisionless
local lockToAxes = false
local minX, minY, minZ, maxX, maxY, maxZ
local centerToBaseDistance

local movementType
local MOVEMENT_MOVE = 1
local MOVEMENT_ROTATE = 2

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
		return mta_getElementRotation(element)
	elseif elementType == "vehicle" then
		return mta_getElementRotation(element)
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
		if not (getCommandState("mod_rotate")) then -- set position
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
				if movementType ~= MOVEMENT_ROTATE then
					setMovementType("rotate")
					movementType = MOVEMENT_ROTATE
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
					if (not (tempRot == rotZ)) then
						if (getElementType(selectedElement) == "ped") then
							setElementRotation(selectedElement, 0,0,-tempRot%360)
							setPedRotation(selectedElement, tempRot)
						end
					end
					rotZ = tempRot

				else
					local tempRotX, tempRotY, tempRotZ = rotX, rotY, rotZ
					if (not tempRotX) then return false end

					-- conversion to XYZ order
					tempRotX, tempRotY, tempRotZ = convertRotationFromMTA(tempRotX, tempRotY, tempRotZ)
					tempRotX = math.deg(tempRotX)
					tempRotY = math.deg(tempRotY)
					tempRotZ = math.deg(tempRotZ)

					-- roll
					if (getCommandTogSTATE("element_move_forward")) then
						if rotFlipped then
							tempRotY = tempRotY - speed
						else
							tempRotY = tempRotY + speed
						end
					elseif (getCommandTogSTATE("element_move_backward")) then
						if rotFlipped then
							tempRotY = tempRotY + speed
						else
							tempRotY = tempRotY - speed
						end
					end

					-- not sure why, maybe rotation conversion has singularity
					if tempRotY > 90 or tempRotY < -90 then
						rotFlipped = not rotFlipped
					end

					-- pitch
					if (getCommandTogSTATE("element_move_upwards")) then
						tempRotX = tempRotX + speed
					elseif (getCommandTogSTATE("element_move_downwards")) then
						tempRotX = tempRotX - speed
					end

					-- spin
					if (getCommandTogSTATE("element_move_right")) then
						tempRotZ = tempRotZ + speed
					elseif (getCommandTogSTATE("element_move_left")) then
						tempRotZ = tempRotZ - speed
					end

					-- conversion back to YXZ order
					tempRotX, tempRotY, tempRotZ = convertRotationToMTA(math.rad(tempRotX), math.rad(tempRotY), math.rad(tempRotZ))

					-- check if rotation changed
					if (not (tempRotX == rotX and tempRotY == rotY and tempRotZ == rotZ)) then
						setElementRotation(selectedElement, tempRotX, tempRotY, tempRotZ)
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
				if movementType ~= MOVEMENT_ROTATE then
					setMovementType("rotate")
					movementType = MOVEMENT_ROTATE
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
					if (not (tempRot == rotZ)) then
						if (getElementType(selectedElement) == "ped") then
							setElementRotation(selectedElement, 0,0,-tempRot%360)
							setPedRotation(selectedElement, tempRot)
						end
					end
					rotZ = tempRot

				else
					local tempRotX, tempRotY, tempRotZ = rotX, rotY, rotZ
					if (not tempRotX) then return false end

					-- conversion to XYZ order
					tempRotX, tempRotY, tempRotZ = convertRotationFromMTA(tempRotX, tempRotY, tempRotZ)
					tempRotX = math.deg(tempRotX)
					tempRotY = math.deg(tempRotY)
					tempRotZ = math.deg(tempRotZ)

					-- roll
					if (getCommandState("element_move_forward")) then
						if rotFlipped then
							tempRotY = tempRotY - speed
						else
							tempRotY = tempRotY + speed
						end
					elseif (getCommandState("element_move_backward")) then
						if rotFlipped then
							tempRotY = tempRotY + speed
						else
							tempRotY = tempRotY - speed
						end
					end

					-- not sure why, maybe rotation conversion has singularity
					if tempRotY > 90 or tempRotY < -90 then
						rotFlipped = not rotFlipped
					end

					-- pitch
					if (getCommandState("element_move_upwards")) then
						tempRotX = tempRotX + speed
					elseif (getCommandState("element_move_downwards")) then
						tempRotX = tempRotX - speed
					end

					-- spin
					if (getCommandState("element_move_right")) then
						tempRotZ = tempRotZ + speed
					elseif (getCommandState("element_move_left")) then
						tempRotZ = tempRotZ - speed
					end

					-- conversion back to YXZ order
					tempRotX, tempRotY, tempRotZ = convertRotationToMTA(math.rad(tempRotX), math.rad(tempRotY), math.rad(tempRotZ))

					-- check if rotation changed
					if (not (tempRotX == rotX and tempRotY == rotY and tempRotZ == rotZ)) then
						setElementRotation(selectedElement, tempRotX, tempRotY, tempRotZ)
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
	end
end

local function rotateWithMouseWheel(key, keyState)
	if rotationless or (isCursorShowing() and exports.editor_gui:guiGetMouseOverElement()) then
		return
	end
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

	rotX, rotY, rotZ = getElementRotation(selectedElement)
	if (getElementType(selectedElement) == "vehicle" or getElementType(selectedElement) == "object") then
		rotZ = rotZ + speed
		setElementRotation(selectedElement, rotX, rotY, rotZ)
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

		if (getElementType(element) == "vehicle") or (getElementType(element) == "object") then
			rotX, rotY, rotZ = getElementRotation(element)
		elseif (getElementType(element) == "player") or (getElementType(element) == "ped") then
			rotX, rotY, rotZ = 0,0,getPedRotation ( element )
		end

		minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(element)
		enable()
		return true
	else
		return false
	end
end

function detachElement()
	if (selectedElement) then
		disable()

		-- sync position/rotation
		posX, posY, posZ = getElementPosition(selectedElement)
		triggerServerEvent("syncProperty", getLocalPlayer(), "position", {posX, posY, posZ}, exports.edf:edfGetAncestor(selectedElement))
		if hasRotation[getElementType(selectedElement)] then
			rotX, rotY, rotZ = getElementRotation(selectedElement)
	        	triggerServerEvent("syncProperty", getLocalPlayer(), "rotation", {rotX, rotY, rotZ}, exports.edf:edfGetAncestor(selectedElement))
		end
		selectedElement = nil
		posX, posY, posZ = nil, nil, nil
		rotX, rotY, rotZ = nil, nil, nil, nil
		minX, minY, minZ, maxX, maxY, maxZ = nil, nil, nil, nil, nil, nil
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

function toggleAxesLock ( bool )
	lockToAxes = bool
	return true
end

function enable()
	bindControl("quick_rotate_increase", "down", rotateWithMouseWheel) --rotate left
	bindControl("quick_rotate_decrease", "down", rotateWithMouseWheel) --rotate right
	addEventHandler("onClientRender", root, onClientRender_keyboard)
end

function disable()
	unbindControl("quick_rotate_increase", "down", rotateWithMouseWheel) --rotate left
	unbindControl("quick_rotate_decrease", "down", rotateWithMouseWheel) --rotate right
	removeEventHandler("onClientRender", root, onClientRender_keyboard)
end

function setMovementType(movementType)
	call(getResourceFromName("editor_main"), "setMovementType", movementType)
end
