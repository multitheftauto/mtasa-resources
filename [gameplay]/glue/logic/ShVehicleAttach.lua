-- #######################################
-- ## Project: Glue						##
-- ## Author: MTA contributors			##
-- ## Version: 1.3.1					##
-- #######################################

function canPlayerAttachElementToVehicle(playerElement, attachElement, attachToElement)
	local playerType = isElementType(playerElement, "player")

	if (not playerType) then
		return false
	end

	local playerDead = isPedDead(playerElement)

	if (playerDead) then
		return false
	end

	local allowedElementToAttach, allowedElementType = isElementType(attachElement, GLUE_ALLOWED_ELEMENTS)

	if (not allowedElementToAttach) then
		return false
	end

	local attachToElementVehicleType = isElementType(attachToElement, "vehicle")

	if (not attachToElementVehicleType) then
		return false
	end

	local attachToElementVehicleExploded = isVehicleBlown(attachToElement)

	if (attachToElementVehicleExploded) then
		return false
	end

	local attachElementPlayer = (allowedElementType == "player")
	local attachElementVehicle = (allowedElementType == "vehicle")
	local playerVehicle = getPedOccupiedVehicle(playerElement)

	if (attachElementPlayer) then
		local elementPlayerSelfAttach = (playerElement == attachElement)

		if (not elementPlayerSelfAttach) then
			return false
		end

		if (playerVehicle) then
			return false
		end

		local attachPlayerPosX, attachPlayerPosY, attachPlayerPosZ = getElementPosition(attachElement)
		local attachToVehiclePosX, attachToVehiclePosY, attachToVehiclePosZ = getElementPosition(attachToElement)
		local attachPlayerDistance = getDistanceBetweenPoints3D(attachToVehiclePosX, attachToVehiclePosY, attachToVehiclePosZ, attachPlayerPosX, attachPlayerPosY, attachPlayerPosZ)
		local attachPlayerCloseEnough = (attachPlayerDistance <= GLUE_ATTACH_PLAYER_MAX_DISTANCE)

		if (not attachPlayerCloseEnough) then
			return false
		end

		local attachPlayerInterior = getElementInterior(attachElement)
		local attachPlayerDimension = getElementDimension(attachElement)
		local attachToVehicleInterior = getElementInterior(attachToElement)
		local attachToVehicleDimension = getElementDimension(attachToElement)
		local attachPlayerWorldMatching = (attachPlayerInterior == attachToVehicleInterior) and (attachPlayerDimension == attachToVehicleDimension)

		if (not attachPlayerWorldMatching) then
			return false
		end

		if (IS_SERVER) then
			local vehicleAttachLocked = isVehicleAttachLocked(attachToElement)

			if (vehicleAttachLocked) then
				local vehicleAttachLockMessage = "The vehicle you are trying to glue is attach locked."

				sendGlueMessage(vehicleAttachLockMessage, playerElement, "**")

				return false
			end
		end

		return true
	end

	if (attachElementVehicle) then
		local vehicleAttachDifferent = (attachElement ~= attachToElement)

		if (not vehicleAttachDifferent) then
			return false
		end

		local vehicleAttachElementExploded = isVehicleBlown(attachElement)

		if (vehicleAttachElementExploded) then
			return false
		end

		local vehicleAttachedElement = getAttachedVehicle(attachToElement)

		if (vehicleAttachedElement) then
			return false
		end

		local vehicleAttachToType = getVehicleType(attachToElement)
		local vehicleAttachToHelicopter = (vehicleAttachToType == "Helicopter")

		if (not vehicleAttachToHelicopter) then
			local vehicleAttachElementController = getVehicleController(attachElement)
			local vehicleAttachElementDriver = (playerElement == vehicleAttachElementController)

			if (not vehicleAttachElementDriver) then
				return false
			end
		end

		local attachVehiclePosX, attachVehiclePosY, attachVehiclePosZ = getElementPosition(attachElement)
		local attachToVehiclePosX, attachToVehiclePosY, attachToVehiclePosZ = getElementPosition(attachToElement)
		local attachVehicleDistance = getDistanceBetweenPoints3D(attachToVehiclePosX, attachToVehiclePosY, attachToVehiclePosZ, attachVehiclePosX, attachVehiclePosY, attachVehiclePosZ)
		local attachVehicleCloseEnough = (attachVehicleDistance <= GLUE_ATTACH_VEHICLE_MAX_DISTANCE)

		if (not attachVehicleCloseEnough) then
			return false
		end

		local attachVehicleInterior = getElementInterior(attachElement)
		local attachVehicleDimension = getElementDimension(attachElement)
		local attachToVehicleInterior = getElementInterior(attachToElement)
		local attachToVehicleDimension = getElementDimension(attachToElement)
		local attachVehicleWorldMatching = (attachVehicleInterior == attachToVehicleInterior) and (attachVehicleDimension == attachToVehicleDimension)

		if (not attachVehicleWorldMatching) then
			return false
		end

		local vehicleModel = getElementModel(attachElement)
		local vehicleModelType = getVehicleType(attachElement)
		local vehicleModelAllowed = GLUE_VEHICLE_TYPES[vehicleModelType] or GLUE_VEHICLE_WHITELIST[vehicleModel]

		if (not vehicleModelAllowed) then
			local vehicleModelMessage = "This vehicle model or type can't be attached."

			sendGlueMessage(vehicleModelMessage, playerElement, "**")

			return false
		end

		if (IS_SERVER) then
			local vehicleAttachLocked = isVehicleAttachLocked(attachElement)
			local vehicleAttachToLocked = isVehicleAttachLocked(attachToElement)

			if (vehicleAttachLocked or vehicleAttachToLocked) then
				local vehicleAttachLockMessage = "The vehicle you are in/nearby is attach locked and can't be glued."

				sendGlueMessage(vehicleAttachLockMessage, playerElement, "**")

				return false
			end
		end
	end

	return true
end

function canPlayerDetachElementFromVehicle(playerElement, detachElement)
	local playerType = isElementType(playerElement, "player")

	if (not playerType) then
		return false
	end

	local playerDead = isPedDead(playerElement)

	if (playerDead) then
		return false
	end

	local allowedElement, allowedElementType = isElementType(detachElement, GLUE_ALLOWED_ELEMENTS)

	if (not allowedElement) then
		return false
	end

	local attachToElement = getElementAttachedTo(detachElement)

	if (not attachToElement) then
		return false
	end

	local detachElementPlayerType = (allowedElementType == "player")
	local detachElementVehicleType = (allowedElementType == "vehicle")

	if (detachElementPlayerType) then
		local elementPlayerSelfDetach = (playerElement == detachElement)

		if (not elementPlayerSelfDetach) then
			return false
		end
	end

	if (detachElementVehicleType) then
		local detachVehicleExploded = isVehicleBlown(detachElement)

		if (detachVehicleExploded) then
			return false
		end

		local vehicleAttachToType = getVehicleType(attachToElement)
		local vehicleAttachToHelicopter = (vehicleAttachToType == "Helicopter")

		if (not vehicleAttachToHelicopter) then
			local vehicleController = getVehicleController(detachElement)
			local vehicleDetachToDriver = (playerElement == vehicleController)

			if (not vehicleDetachToDriver) then
				return false
			end
		end
	end

	local playerAttachDetachDelayPassed = getOrSetPlayerDelay(playerElement, "attachDetach", GLUE_ATTACH_DETACH_DELAY)

	if (not playerAttachDetachDelayPassed) then
		return false
	end

	return true, attachToElement
end

function canPlayerDetachElementsFromVehicle(playerElement)
	if (not GLUE_ALLOW_DETACHING_ELEMENTS) then
		return false
	end

	local playerType = isElementType(playerElement, "player")

	if (not playerType) then
		return false
	end

	local playerDead = isPedDead(playerElement)

	if (playerDead) then
		return false
	end

	local playerVehicle = getPedOccupiedVehicle(playerElement)

	if (not playerVehicle) then
		return false
	end

	local playerVehicleDriver = getVehicleController(playerVehicle)
	local playerVehicleDriverMatching = (playerElement == playerVehicleDriver)

	if (not playerVehicleDriverMatching) then
		return false
	end

	local playerDetachAllDelayPassed = getOrSetPlayerDelay(playerElement, "detachAll", GLUE_DETACH_ELEMENTS_DELAY)

	if (not playerDetachAllDelayPassed) then
		return false
	end

	if (IS_SERVER) then
		local detachedElementCount = detachAttachedVehicleElements(playerVehicle)

		if (detachedElementCount) then
			local detachAllMessage = "You have detached ("..GLUE_MESSAGE_HIGHLIGHT_COLOR..detachedElementCount.."#ffffff) elements attached to your vehicle."

			sendGlueMessage(detachAllMessage, playerElement, "**")
		end
	end

	return true
end

function canPlayerToggleVehicleAttachLock(playerElement)
	if (not GLUE_ALLOW_ATTACH_TOGGLING) then
		return false
	end

	local playerType = isElementType(playerElement, "player")

	if (not playerType) then
		return false
	end

	local playerDead = isPedDead(playerElement)

	if (playerDead) then
		return false
	end

	local playerVehicle = getPedOccupiedVehicle(playerElement)

	if (not playerVehicle) then
		return false
	end

	local playerVehicleDriver = getVehicleController(playerVehicle)
	local playerVehicleDriverMatching = (playerElement == playerVehicleDriver)

	if (not playerVehicleDriverMatching) then
		return false
	end

	local playerAttachLockToggleDelayPassed = getOrSetPlayerDelay(playerElement, "attachLock", GLUE_ATTACH_TOGGLE_DELAY)

	if (not playerAttachLockToggleDelayPassed) then
		return false
	end

	return playerVehicle
end

function getAttachedVehicle(vehicleElement)
	local vehicleType = isElementType(vehicleElement, "vehicle")

	if (not vehicleType) then
		return false
	end

	local attachedElements = getAttachedElements(vehicleElement)

	for attachedElementID = 1, #attachedElements do
		local attachedElement = attachedElements[attachedElementID]
		local attachedElementVehicle = isElementType(attachedElement, "vehicle")

		if (attachedElementVehicle) then
			return attachedElement
		end
	end

	return false
end

function getNearestVehicleFromVehicle(vehicleElement)
	local vehicleType = isElementType(vehicleElement, "vehicle")

	if (not vehicleType) then
		return false
	end

	local vehicleX, vehicleY, vehicleZ = getElementPosition(vehicleElement)
	local vehicleInterior = getElementInterior(vehicleElement)
	local vehicleDimension = getElementDimension(vehicleElement)
	local vehiclesInRange = getElementsWithinRange(vehicleX, vehicleY, vehicleZ, GLUE_ATTACH_VEHICLE_MAX_DISTANCE, "vehicle", vehicleInterior, vehicleDimension)

	for vehicleID = 1, #vehiclesInRange do
		local vehicleNearby = vehiclesInRange[vehicleID]
		local vehicleDifferent = (vehicleElement ~= vehicleNearby)

		if (vehicleDifferent) then
			local vehicleExploded = isVehicleBlown(vehicleElement)

			if (not vehicleExploded) then
				return vehicleNearby
			end
		end
	end

	return false
end

function getVehicleAttachData(attachVehicle, attachToVehicle)
	local attachVehicleType = isElementType(attachVehicle, "vehicle")
	local attachToVehicleType = isElementType(attachToVehicle, "vehicle")

	if (not attachVehicleType or not attachToVehicleType) then
		return false
	end

	local vehicleStartRX, vehicleStartRY, vehicleStartRZ = getElementRotation(attachVehicle)
	local vehicleTargetRX, vehicleTargetRY, vehicleTargetRZ = getElementRotation(attachToVehicle)
	local vehicleRX = (vehicleStartRX - vehicleTargetRX)
	local vehicleRY = (vehicleStartRY - vehicleTargetRY)
	local vehicleRZ = (vehicleStartRZ - vehicleTargetRZ)

	if (GLUE_ATTACH_OVER_VEHICLE) then
		local vehicleOffsetTopX = GLUE_ATTACH_ON_TOP_OFFSETS[1]
		local vehicleOffsetTopY = GLUE_ATTACH_ON_TOP_OFFSETS[2]
		local vehicleOffsetTopZ = GLUE_ATTACH_ON_TOP_OFFSETS[3]

		return vehicleOffsetTopX, vehicleOffsetTopY, vehicleOffsetTopZ, vehicleRX, vehicleRY, vehicleRZ
	end

	local vehicleMatrix = getElementMatrix(attachToVehicle)
	local vehicleStartX, vehicleStartY, vehicleStartZ = getElementPosition(attachVehicle)
	local vehiclePosition = {vehicleStartX, vehicleStartY, vehicleStartZ}
	local vehicleAttachX, vehicleAttachY, vehicleAttachZ = getOffsetFromXYZ(vehicleMatrix, vehiclePosition)

	return vehicleAttachX, vehicleAttachY, vehicleAttachZ, vehicleRX, vehicleRY, vehicleRZ
end