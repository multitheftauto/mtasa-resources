-- #######################################
-- ## Project: Glue						##
-- ## Author: MTA contributors			##
-- ## Version: 1.3.1					##
-- #######################################

local attachSyncTimer = false
local attachSyncCorrection = {}

local function correctAttachedPlayersPosition()
	local attachVehiclesPosition = {}

	for attachedPlayer, attachedToVehicle in pairs(attachSyncCorrection) do
		local playerAttachedVehicleElement = isElement(attachedToVehicle)
		local playerAttachedVehicleValid = false

		if (playerAttachedVehicleElement) then
			local playerAttachedToVehicle = getElementAttachedTo(attachedPlayer)
			local playerAttachedVehicleMatching = (playerAttachedToVehicle and playerAttachedToVehicle == attachedToVehicle)

			playerAttachedVehicleValid = playerAttachedVehicleMatching
		end

		if (playerAttachedVehicleValid) then
			local attachVehiclePosition = attachVehiclesPosition[attachedToVehicle]

			if (not attachVehiclePosition) then
				local attachVehiclePosX, attachVehiclePosY, attachVehiclePosZ = getElementPosition(attachedToVehicle)
				local attachVehiclePositionData = {
					attachVehiclePosX,
					attachVehiclePosY,
					attachVehiclePosZ,
				}

				attachVehiclesPosition[attachedToVehicle] = attachVehiclePositionData
				attachVehiclePosition = attachVehiclesPosition[attachedToVehicle]
			end

			local attachPositionWarp = false -- warp will reset player animations, we don't want that
			local attachPosX, attachPosY, attachPosZ = attachVehiclePosition[1], attachVehiclePosition[2], attachVehiclePosition[3]

			setElementPosition(attachedPlayer, attachPosX, attachPosY, attachPosZ, attachPositionWarp)
		else
			attachSyncCorrection[attachedPlayer] = nil
		end
	end

	handleCorrectionSyncTimer()

	return true
end

function handleCorrectionSyncTimer()
	if (not GLUE_SYNC_CORRECTION) then
		return false
	end

	local toggleOn = next(attachSyncCorrection)

	if (toggleOn) then

		if (attachSyncTimer) then
			return false
		end

		attachSyncTimer = setTimer(correctAttachedPlayersPosition, GLUE_SYNC_CORRECTION_INTERVAL, 0)

		return true
	end

	if (not toggleOn) then

		if (not attachSyncTimer) then
			return false
		end

		killTimer(attachSyncTimer)
		attachSyncTimer = false

		return true
	end
end

function setGlueSyncCorrectionForPlayer(playerElement, attachVehicle)
	local playerType = isElementType(playerElement, "player")

	if (not playerType) then
		return false
	end

	local attachSyncState = (attachVehicle or nil)

	attachSyncCorrection[playerElement] = attachSyncState
	handleCorrectionSyncTimer()

	return true
end

local function clearSyncCorrectionData()
	attachSyncCorrection[source] = nil
end
addEventHandler("onPlayerQuit", root, clearSyncCorrectionData)