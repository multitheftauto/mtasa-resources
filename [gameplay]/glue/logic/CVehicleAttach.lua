-- #######################################
-- ## Project: Glue						##
-- ## Author: MTA contributors			##
-- ## Version: 1.3.1					##
-- #######################################

local glueHintsDisplayed = false

local function handleGlueAttachAndDetach()
	local playerVehicle = getPedOccupiedVehicle(localPlayer)

	if (playerVehicle) then
		local playerVehicleToDetach = playerVehicle
		local playerVehicleHelicopter = isVehicleHelicopter(playerVehicle)
		local playerVehicleAttachedVehicle = getAttachedVehicle(playerVehicle)

		if (playerVehicleAttachedVehicle) then
			playerVehicleToDetach = playerVehicleAttachedVehicle
		end

		if (playerVehicleToDetach) then
			local playerVehicleCanDetach = canPlayerDetachElementFromVehicle(localPlayer, playerVehicleToDetach)

			if (playerVehicleCanDetach) then
				triggerServerEvent("onServerVehicleDetachElement", localPlayer, playerVehicleToDetach)

				return true
			end
		end

		local vehicleNearby = getNearestVehicleFromVehicle(playerVehicle)

		if (not vehicleNearby) then
			return false
		end

		local playerVehicleAttach = (playerVehicleHelicopter and vehicleNearby or playerVehicle)
		local playerVehicleAttachTo = (playerVehicleHelicopter and playerVehicle or vehicleNearby)
		local playerCanAttachVehicleToVehicle = canPlayerAttachElementToVehicle(localPlayer, playerVehicleAttach, playerVehicleAttachTo)

		if (not playerCanAttachVehicleToVehicle) then
			return false
		end

		local vehicleAttachX, vehicleAttachY, vehicleAttachZ, vehicleAttachRX, vehicleAttachRY, vehicleAttachRZ = getVehicleAttachData(playerVehicleAttach, playerVehicleAttachTo)

		if (playerVehicleHelicopter) then
			local helicopterAttachX = GLUE_ATTACH_HELICOPTER_OFFSETS[1]
			local helicopterAttachY = GLUE_ATTACH_HELICOPTER_OFFSETS[2]
			local helicopterAttachZ = GLUE_ATTACH_HELICOPTER_OFFSETS[3]
			local helicopterAttachRX = GLUE_ATTACH_HELICOPTER_OFFSETS[4]
			local helicopterAttachRY = GLUE_ATTACH_HELICOPTER_OFFSETS[5]
			local helicopterAttachRZ = GLUE_ATTACH_HELICOPTER_OFFSETS[6]

			vehicleAttachX, vehicleAttachY, vehicleAttachZ = helicopterAttachX, helicopterAttachY, helicopterAttachZ
			vehicleAttachRX, vehicleAttachRY, vehicleAttachRZ = helicopterAttachRX, helicopterAttachRY, helicopterAttachRZ
		end

		local vehicleAttachData = {vehicleAttachX, vehicleAttachY, vehicleAttachZ, vehicleAttachRX, vehicleAttachRY, vehicleAttachRZ}

		triggerServerEvent("onServerVehicleAttachElement", localPlayer, playerVehicleAttach, playerVehicleAttachTo, vehicleAttachData)

		return false
	end

	if (not playerVehicle) then
		local playerAttachedTo = getElementAttachedTo(localPlayer)

		if (playerAttachedTo) then
			local playerCanDetach = canPlayerDetachElementFromVehicle(localPlayer, localPlayer)

			if (not playerCanDetach) then
				return false
			end

			triggerServerEvent("onServerVehicleDetachElement", localPlayer, localPlayer)

			return true
		end

		local playerContactElement = getPedContactElement(localPlayer)
		local playerContactVehicle = isElementType(playerContactElement, "vehicle")

		if (not playerContactVehicle) then
			return false
		end

		local playerCanAttach = canPlayerAttachElementToVehicle(localPlayer, localPlayer, playerContactElement)

		if (not playerCanAttach) then
			return false
		end

		local playerX, playerY, playerZ = getElementPosition(localPlayer)
		local playerVehicleMatrix = getElementMatrix(playerContactElement)
		local playerPosition = {playerX, playerY, playerZ}
		local playerAttachX, playerAttachY, playerAttachZ = getOffsetFromXYZ(playerVehicleMatrix, playerPosition)
		local playerAttachRX, playerAttachRY, playerAttachRZ = 0, 0, 0
		local playerAttachData = {playerAttachX, playerAttachY, playerAttachZ, playerAttachRX, playerAttachRY, playerAttachRZ}
		local playerWeaponSlot = getPedWeaponSlot(localPlayer)

		triggerServerEvent("onServerVehicleAttachElement", localPlayer, localPlayer, playerContactElement, playerAttachData, playerWeaponSlot)
	end
end
bindKey(GLUE_ATTACH_DETACH_KEY, "down", handleGlueAttachAndDetach)

local function handleGlueAttachLock()
	local canToggleVehicleAttachLock = canPlayerToggleVehicleAttachLock(localPlayer)

	if (canToggleVehicleAttachLock) then
		triggerServerEvent("onServerVehicleToggleAttachLock", localPlayer)
	end
end
if (GLUE_ALLOW_ATTACH_TOGGLING) then
	bindKey(GLUE_ATTACH_TOGGLE_KEY, "down", handleGlueAttachLock)
end

local function handleGlueDetachElements()
	local canDetachVehicleElements = canPlayerDetachElementsFromVehicle(localPlayer)

	if (canDetachVehicleElements) then
		triggerServerEvent("onServerVehicleDetachElements", localPlayer)
	end
end
if (GLUE_ALLOW_DETACHING_ELEMENTS) then
	bindKey(GLUE_DETACH_ELEMENTS_KEY, "down", handleGlueDetachElements)
end

local function toggleCombatControls(forcedState)
	for controlID = 1, #GLUE_PREVENT_CONTROLS_LIST do
		local controlName = GLUE_PREVENT_CONTROLS_LIST[controlID]
		local controlState = isControlEnabled(controlName)
		local controlStateNeedsUpdate = (controlState ~= forcedState)

		if (controlStateNeedsUpdate) then
			toggleControl(controlName, forcedState)
		end
	end

	return true
end

local function restoreCombatControlsOnEvent(vehicleElement)
	local playerAttachedTo = getElementAttachedTo(localPlayer)

	if (not playerAttachedTo) then
		return false
	end

	if (vehicleElement) then
		local playerAttachedElementMatching = (playerAttachedTo == vehicleElement)

		if (not playerAttachedElementMatching) then
			return false
		end
	end

	toggleCombatControls(true)

	return true
end

local function restoreCombatControlsOnVehicleDestroy()
	restoreCombatControlsOnEvent(source)
end
if (GLUE_PREVENT_CONTROLS) then
	addEventHandler("onClientElementDestroy", root, restoreCombatControlsOnVehicleDestroy)
end

local function restoreCombatControlsOnResourceStop()
	restoreCombatControlsOnEvent()
end
if (GLUE_PREVENT_CONTROLS) then
	addEventHandler("onClientResourceStop", root, restoreCombatControlsOnResourceStop)
end

local function displayGlueHintsOnVehicleEnter()
	if (glueHintsDisplayed) then
		return false
	end

	local glueHintCanAttachVehicle = findInTable(GLUE_ALLOWED_ELEMENTS, "vehicle")
	local glueHintCanAttachPlayer = findInTable(GLUE_ALLOWED_ELEMENTS, "player")

	if (not glueHintCanAttachVehicle and not glueHintCanAttachPlayer) then
		return false
	end

	local glueHintAttachVehicles = glueHintCanAttachVehicle and GLUE_MESSAGE_HIGHLIGHT_COLOR.."current/nearby vehicle#ffffff" or ""
	local glueHintAttachYourself = glueHintCanAttachPlayer and GLUE_MESSAGE_HIGHLIGHT_COLOR.."yourself#ffffff"..(glueHintCanAttachVehicle and " or " or "") or ""
	local glueHintAttachLock = (GLUE_ALLOW_ATTACH_TOGGLING and "#ffffff'"..GLUE_MESSAGE_HIGHLIGHT_COLOR..GLUE_ATTACH_TOGGLE_KEY.."#ffffff' is used to disable/enable attaching to your vehicle. " or "")
	local glueHintDetachElements = (GLUE_ALLOW_DETACHING_ELEMENTS and "#ffffff'"..GLUE_MESSAGE_HIGHLIGHT_COLOR..GLUE_DETACH_ELEMENTS_KEY.."#ffffff' to detach all currently attached elements." or "")

	local glueHintA = "Press '"..GLUE_MESSAGE_HIGHLIGHT_COLOR..GLUE_ATTACH_DETACH_KEY.."#ffffff' to attach "..glueHintAttachYourself..glueHintAttachVehicles.." to (nearby/current) vehicle."
	local glueHintB = glueHintAttachLock
	local glueHintC = glueHintDetachElements

	sendGlueMessage(glueHintA)
	sendGlueMessage(glueHintB, nil, "*")
	sendGlueMessage(glueHintC, nil, "*")

	glueHintsDisplayed = true
end
if (GLUE_SHOW_ONE_TIME_HINT) then
	addEventHandler("onClientPlayerVehicleEnter", localPlayer, displayGlueHintsOnVehicleEnter)
end

function onClientAttachStateChanged(playerAttached)
	if (not GLUE_PREVENT_CONTROLS) then
		return false
	end

	local toggleControlState = (not playerAttached)

	toggleCombatControls(toggleControlState)
end
addEvent("onClientAttachStateChanged", true)
addEventHandler("onClientAttachStateChanged", localPlayer, onClientAttachStateChanged)