-- #######################################
-- ## Project: Glue						##
-- ## Author: MTA contributors			##
-- ## Version: 1.3.1					##
-- #######################################

local vehicleAttachLock = {}

function isVehicleAttachLocked(vehicleElement)
	local vehicleAttachLocked = vehicleAttachLock[vehicleElement]

	return vehicleAttachLocked
end

function onServerVehicleToggleAttachLock()
	local vehicleToToggleLock = canPlayerToggleVehicleAttachLock(client)

	if (not vehicleToToggleLock) then
		return false
	end

	local vehicleLockState = isVehicleAttachLocked(vehicleToToggleLock)
	local vehicleLockStateNew = (not vehicleLockState)
	local vehicleLockStateMessage = "You have toggled "..(vehicleLockStateNew and "#00ff00on" or "#ff0000off").."#ffffff vehicle attachment lock."

	vehicleAttachLock[vehicleToToggleLock] = vehicleLockStateNew
	sendGlueMessage(vehicleLockStateMessage, client, "**")
end
addEvent("onServerVehicleToggleAttachLock", true)
addEventHandler("onServerVehicleToggleAttachLock", root, onServerVehicleToggleAttachLock)

local function notifyAboutVehicleAttachLock(pPed)
	local playerType = isElementType(pPed, "player")

	if (not playerType) then
		return false
	end

	local vehicleDriver = getVehicleController(source)
	local vehicleDriverMatching = (vehicleDriver == pPed)

	if (not vehicleDriverMatching) then
		return false
	end

	local vehicleAttachLocked = isVehicleAttachLocked(source)

	if (not vehicleAttachLocked) then
		return false
	end

	local vehicleAttachPlayerAllowed = findInTable(GLUE_ALLOWED_ELEMENTS, "player")
	local vehicleAttachVehicleAllowed = findInTable(GLUE_ALLOWED_ELEMENTS, "vehicle")
	local vehicleAttachPlayerHint = (vehicleAttachPlayerAllowed and "players can't glue to it" or "")
	local vehicleAttachVehicleHint = (vehicleAttachVehicleAllowed and "can't be glued to other vehicles" or "")
	local vehicleAttachSeparator = (vehicleAttachPlayerAllowed and vehicleAttachVehicleAllowed) and "/" or ""
	local vehicleAttachDescription = (vehicleAttachPlayerAllowed or vehicleAttachVehicleAllowed) and " ("..vehicleAttachPlayerHint..vehicleAttachSeparator..vehicleAttachVehicleHint..")" or ""

	local vehicleLockMessage = "Your vehicle is attach-locked"..vehicleAttachDescription..". Press '"..GLUE_MESSAGE_HIGHLIGHT_COLOR..GLUE_ATTACH_TOGGLE_KEY.."#ffffff' to unlock it."

	sendGlueMessage(vehicleLockMessage, pPed, "**")
end
if (GLUE_ALLOW_ATTACH_TOGGLING) then
	addEventHandler("onVehicleEnter", root, notifyAboutVehicleAttachLock)
end

local function clearVehicleAttachLock()
	vehicleAttachLock[source] = nil
end
if (GLUE_ALLOW_ATTACH_TOGGLING) then
	addEventHandler("onElementDestroy", root, clearVehicleAttachLock)
end