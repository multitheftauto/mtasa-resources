-- #######################################
-- ## Project: Internet radio			##
-- ## Authors: MTA contributors			##
-- ## Version: 1.0						##
-- #######################################

local playerSpeakers = {}

function setPlayerSpeakerData(playerElement, speakerData)
	local validElement = isElement(playerElement)

	if (not validElement) then
		return false
	end

	playerSpeakers[playerElement] = speakerData
	triggerClientEvent(root, "onClientCreateSpeaker", playerElement, speakerData)

	return true
end

function getPlayerSpeakerData(playerElement)
	local validElement = isElement(playerElement)

	if (not validElement) then
		return false
	end

	local playerSpeakerData = playerSpeakers[playerElement]

	return playerSpeakerData
end

function clearPlayerSpeaker(playerOrSpeaker)
	for playerElement, speakerData in pairs(playerSpeakers) do
		local speakerBox = speakerData.speakerBox
		local matchingElement = (playerElement == playerOrSpeaker) or (speakerBox == playerOrSpeaker)

		if (matchingElement) then
			local boxElement = isElement(speakerBox)

			if (boxElement) then
				destroyElement(speakerBox)
			end

			playerSpeakers[playerElement] = nil

			return true
		end
	end

	return false
end

function onServerCreateSpeaker(streamURL)
	if (not client) then
		return false
	end

	local createDelayPassed = getOrSetPlayerDelay(client, "create_speaker", RADIO_CREATE_SPEAKER_DELAY)

	if (not createDelayPassed) then
		return false
	end

	local validStreamURL = verifyRadioStreamURL(streamURL)

	if (not validStreamURL) then
		return false
	end

	local playerSpeakerData = getPlayerSpeakerData(client)

	if (playerSpeakerData) then
		local speakerBox = playerSpeakerData.speakerBox
		local speakerElement = isElement(speakerBox)

		if (speakerElement) then
			destroyElement(speakerBox)
		end
	end

	local playerPosX, playerPosY, playerPosZ = getElementPosition(client)
	local playerInterior = getElementInterior(client)
	local playerDimension = getElementDimension(client)

	local boxPosX, boxPosY, boxPosZ = (playerPosX - 0.5), (playerPosY + 0.5), (playerPosZ - 1)
	local boxRotX, boxRotY, boxRotZ = 0, 0, 0
	local boxLowLOD = false
	local boxElement = createObject(RADIO_BOX_MODEL, boxPosX, boxPosY, boxPosZ, boxRotX, boxRotY, boxRotZ, boxLowLOD)

	setElementInterior(boxElement, playerInterior)
	setElementDimension(boxElement, playerDimension)
	setElementCollisionsEnabled(boxElement, false)

	local playerVehicle = isPedInVehicle(client) and getPedOccupiedVehicle(client)

	if (playerVehicle) then
		attachElements(boxElement, playerVehicle, -0.7, -1.5, -0.1, 0, 90, 0)
	end

	local speakerData = {
		speakerBox = boxElement,
		speakerStreamURL = streamURL,
		speakerSoundMaxDistance = RADIO_MAX_SOUND_DISTANCE,
		speakerPaused = false,
	}

	setPlayerSpeakerData(client, speakerData)
end
addEvent("onServerCreateSpeaker", true)
addEventHandler("onServerCreateSpeaker", root, onServerCreateSpeaker)

function onServerToggleSpeaker()
	if (not client) then
		return false
	end

	local toggleDelayPassed = getOrSetPlayerDelay(client, "toggle_speaker", RADIO_TOGGLE_SPEAKER_DELAY)

	if (not toggleDelayPassed) then
		return false
	end

	local playerSpeakerData = getPlayerSpeakerData(client)

	if (not playerSpeakerData) then
		return false
	end

	local speakerPaused = playerSpeakerData.speakerPaused
	local pauseNewState = (not speakerPaused)

	playerSpeakerData.speakerPaused = pauseNewState
	triggerClientEvent(root, "onClientToggleSpeaker", client, pauseNewState)
end
addEvent("onServerToggleSpeaker", true)
addEventHandler("onServerToggleSpeaker", root, onServerToggleSpeaker)

function onServerDestroySpeaker()
	if (not client) then
		return false
	end

	local destroyDelayPassed = getOrSetPlayerDelay(client, "destroy_speaker", RADIO_DESTROY_SPEAKER_DELAY)

	if (not destroyDelayPassed) then
		return false
	end

	local playerSpeakerData = getPlayerSpeakerData(client)

	if (not playerSpeakerData) then
		return false
	end

	local speakerBox = playerSpeakerData.speakerBox
	local speakerElement = isElement(speakerBox)

	if (speakerElement) then
		destroyElement(speakerBox)
	end
end
addEvent("onServerDestroySpeaker", true)
addEventHandler("onServerDestroySpeaker", root, onServerDestroySpeaker)

function syncSpeakers(startedResource)
	local matchingResource = (startedResource == resource)

	if (not matchingResource) then
		return false
	end

	triggerClientEvent(source, "onClientSyncSpeakers", source, playerSpeakers)
end
addEventHandler("onPlayerResourceStart", root, syncSpeakers)

function clearSpeakersOnDestroyQuit()
	clearPlayerSpeaker(source)
end
addEventHandler("onPlayerQuit", root, clearSpeakersOnDestroyQuit)
addEventHandler("onElementDestroy", resourceRoot, clearSpeakersOnDestroyQuit)

function destroyAttachedRadioOnVehicleExplodeOrDestroy()
	local validElement = isElement(source)

	if (not validElement) then
		return false
	end

	local elementType = getElementType(source)
	local vehicleType = (elementType == "vehicle")

	if (not vehicleType) then
		return false
	end

	local attachedElements = getAttachedElements(source)

	for attachedID = 1, #attachedElements do
		local attachedElement = attachedElements[attachedID]
		local attachedElementType = getElementType(attachedElement)
		local attachedElementObject = (attachedElementType == "object")

		if (attachedElementObject) then
			clearPlayerSpeaker(attachedElement)
		end
	end
end

if (RADIO_DESTROY_ON_VEHICLE_EXPLODE) then
	addEventHandler("onVehicleExplode", root, destroyAttachedRadioOnVehicleExplodeOrDestroy)
end

if (RADIO_DESTROY_ON_VEHICLE_DESTROY) then
	addEventHandler("onElementDestroy", root, destroyAttachedRadioOnVehicleExplodeOrDestroy)
end