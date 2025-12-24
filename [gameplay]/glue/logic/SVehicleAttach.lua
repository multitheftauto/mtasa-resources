-- #######################################
-- ## Project: Glue						##
-- ## Author: MTA contributors			##
-- ## Version: 1.3.1					##
-- #######################################

local function performAttachDetachTasksForPlayer(playerElement, attachTo)
	local playerType = isElementType(playerElement, "player")

	if (not playerType) then
		return false
	end

	setGlueSyncCorrectionForPlayer(playerElement, attachTo)
	triggerClientEvent(playerElement, "onClientAttachStateChanged", playerElement, attachTo)

	return true
end

local function processAttachData(attachData)
	local attachDataTable = typeCheck(attachData, "table")

	if (not attachDataTable) then
		return false
	end

	local attachDataSize = (#attachData)
	local attachDataSizeMatching = (attachDataSize == GLUE_CLIENT_ATTACH_DATA_SIZE)

	if (not attachDataSizeMatching) then
		return false
	end

	for attachDataID = 1, attachDataSize do
		local attachDataValue = attachData[attachDataID]
		local attachDataNumber = typeCheck(attachDataValue, "number")

		if (not attachDataNumber) then
			return false
		end
	end

	return true
end

local function adjustPlayerWeaponSlot(clientElement, attachElement, playerWeaponSlot)
	local playerMatching = (clientElement == attachElement)

	if (not playerMatching) then
		return false
	end

	local playerWeaponSlotNumber = typeCheck(playerWeaponSlot, "number")

	if (not playerWeaponSlotNumber) then
		return false
	end

	local playerWeaponSlotValid = GLUE_WEAPON_SLOTS[playerWeaponSlot]

	if (not playerWeaponSlotValid) then
		return false
	end

	local playerWeaponSlotNow = getPedWeaponSlot(clientElement)
	local playerWeaponSlotNeedsUpdate = (playerWeaponSlotNow ~= playerWeaponSlot)

	if (playerWeaponSlotNeedsUpdate) then
		setPedWeaponSlot(clientElement, playerWeaponSlot)

		return true
	end

	return false
end

function detachAttachedVehicleElements(vehicleElement, skipGlueTasks)
	local vehicleType = isElementType(vehicleElement, "vehicle")

	if (not vehicleType) then
		return false
	end

	local vehicleAttachedElements = getAttachedElements(vehicleElement)
	local vehicleDetachedElementCount = false

	for attachedElementID = 1, #vehicleAttachedElements do
		local vehicleAttachedElement = vehicleAttachedElements[attachedElementID]
		local vehicleAttachedElementShouldDetach = isElementType(vehicleAttachedElement, GLUE_ALLOWED_ELEMENTS)

		if (vehicleAttachedElementShouldDetach) then
			local vehicleElementDetached = detachElements(vehicleAttachedElement, vehicleElement)

			if (vehicleElementDetached) then
				local vehicleDetachedElementCountNew = (vehicleDetachedElementCount or 0) + 1

				vehicleDetachedElementCount = vehicleDetachedElementCountNew

				if (not skipGlueTasks) then
					performAttachDetachTasksForPlayer(vehicleAttachedElement, false)
				end
			end
		end
	end

	return vehicleDetachedElementCount
end

function onServerVehicleAttachElement(attachElement, attachToElement, attachData, playerWeaponSlot)
	local canAttachElement = canPlayerAttachElementToVehicle(client, attachElement, attachToElement)

	if (not canAttachElement) then
		return false
	end

	local attachDataProcessed = processAttachData(attachData)

	if (not attachDataProcessed) then
		return false
	end

	local attachX, attachY, attachZ = attachData[1], attachData[2], attachData[3]
	local attachRX, attachRY, attachRZ = attachData[4], attachData[5], attachData[6]
	local attachedElement = attachElements(attachElement, attachToElement, attachX, attachY, attachZ, attachRX, attachRY, attachRZ)

	if (attachedElement) then
		adjustPlayerWeaponSlot(client, attachElement, playerWeaponSlot)
		performAttachDetachTasksForPlayer(attachElement, attachToElement)
	end
end
addEvent("onServerVehicleAttachElement", true)
addEventHandler("onServerVehicleAttachElement", root, onServerVehicleAttachElement)

function onServerVehicleDetachElement(detachElement)
	local canDetachElement, detachFromElement = canPlayerDetachElementFromVehicle(client, detachElement)

	if (not canDetachElement) then
		return false
	end

	local detachedElement = detachElements(detachElement, detachFromElement)

	if (detachedElement) then
		performAttachDetachTasksForPlayer(detachElement, false)
	end
end
addEvent("onServerVehicleDetachElement", true)
addEventHandler("onServerVehicleDetachElement", root, onServerVehicleDetachElement)

function onServerVehicleDetachElements()
	local vehicleToDetachElements = canPlayerDetachElementsFromVehicle(client)

	if (not vehicleToDetachElements) then
		return false
	end

	detachAttachedVehicleElements(vehicleToDetachElements)
end
addEvent("onServerVehicleDetachElements", true)
addEventHandler("onServerVehicleDetachElements", root, onServerVehicleDetachElements)

local function detachElementsOnVehicleDestroy()
	detachAttachedVehicleElements(source)
end
addEventHandler("onElementDestroy", root, detachElementsOnVehicleDestroy)

local function detachElementsOnVehicleExplode()
	detachAttachedVehicleElements(source)
end
if (GLUE_DETACH_ON_VEHICLE_EXPLOSION) then
	addEventHandler("onVehicleExplode", root, detachElementsOnVehicleExplode)
end

local function detachElementsOnResourceStop()
	local vehiclesTable = getElementsByType("vehicle")

	for vehicleID = 1, #vehiclesTable do
		local vehicleElement = vehiclesTable[vehicleID]

		detachAttachedVehicleElements(vehicleElement, true)
	end
end
addEventHandler("onResourceStop", resourceRoot, detachElementsOnResourceStop)

local function detachElementsOnDeath()
	local attachToElement = getElementAttachedTo(source)

	if (not attachToElement) then
		return false
	end

	detachElements(source, attachToElement)
	performAttachDetachTasksForPlayer(source, false)
end

do
	for glueElementTypeID = 1, #GLUE_ALLOWED_ELEMENTS do
		local glueElementType = GLUE_ALLOWED_ELEMENTS[glueElementTypeID]
		local glueDetachEvent = GLUE_ELEMENT_TYPES_AND_EVENTS[glueElementType]

		if (glueDetachEvent) then
			addEventHandler(glueDetachEvent, root, detachElementsOnDeath)
		end
	end
end