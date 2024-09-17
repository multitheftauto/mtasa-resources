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

function clearPlayerSpeaker(playerOrSpeaker, forceDestroy)
	for playerElement, speakerData in pairs(playerSpeakers) do
		local speakerBox = speakerData.speakerBox
		local matchingElement = (playerElement == playerOrSpeaker) or (speakerBox == playerOrSpeaker)

		if (matchingElement) then

			if (forceDestroy) then
				local boxElement = isElement(speakerBox)

				if (boxElement) then
					destroyElement(speakerBox)
				end
			end

			playerSpeakers[playerElement] = nil

			return true
		end
	end

	return false
end

function isObjectSpeaker(objectElement)
	local validElement = isElement(objectElement)

	if (not validElement) then
		return false
	end

	for playerElement, speakerData in pairs(playerSpeakers) do
		local speakerBox = speakerData.speakerBox
		local matchingElement = (speakerBox == objectElement)

		if (matchingElement) then
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

	clearPlayerSpeaker(client, true)

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

	clearPlayerSpeaker(client, true)
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

function clearSpeakerOnPlayerQuit()
	clearPlayerSpeaker(source, true)
end
addEventHandler("onPlayerQuit", root, clearSpeakerOnPlayerQuit)

function clearSpeakerOnElementDestroy()
	clearPlayerSpeaker(source, false)
end
addEventHandler("onElementDestroy", resourceRoot, clearSpeakerOnElementDestroy)

function destroySpeakerAdminCommand(playerElement, _, targetPlayer)
	local hasPlayerRightToDestroySpeaker = hasObjectPermissionTo(playerElement, RADIO_DESTROY_SPEAKER_ACCESS_RIGHT, false)

	if (not hasPlayerRightToDestroySpeaker) then
		outputChatBox("#ff8800[Speakers]: #ffffffYou have no access to #ff8800/"..RADIO_DESTROY_SPEAKER_COMMAND, playerElement, 255, 255, 255, true)

		return false
	end

	if (not targetPlayer) then
		outputChatBox("#ff8800[Speakers]: #ffffffSyntax: #ff8800/"..RADIO_DESTROY_SPEAKER_COMMAND.." <playerName>", playerElement, 255, 255, 255, true)

		return false
	end

	local playerFromName = getPlayerFromPartialName(targetPlayer)

	if (not playerFromName) then
		outputChatBox("#ff8800[Speakers]: #ffffffPlayer #ff8800"..targetPlayer.." #ffffffnot found.", playerElement, 255, 255, 255, true)

		return false
	end

	local speakerFound = clearPlayerSpeaker(playerFromName, true)
	local speakerDestroyed = (speakerFound and "Successfully destroyed #ff8800"..targetPlayer.."#ffffff speaker." or "Player #ff8800"..targetPlayer.."#ffffff has no speaker.")
	local speakerDestroyedMessage = "#ff8800[Speakers]: #ffffff"..speakerDestroyed

	outputChatBox(speakerDestroyedMessage, playerElement, 255, 255, 255, true)
end
addCommandHandler(RADIO_DESTROY_SPEAKER_COMMAND, destroySpeakerAdminCommand)

function destroySpeakersInRangeAdminCommand(playerElement, _, searchRange)
	local hasPlayerRightToDestroySpeaker = hasObjectPermissionTo(playerElement, RADIO_DESTROY_SPEAKERS_IN_RANGE_ACCESS_RIGHT, false)

	if (not hasPlayerRightToDestroySpeaker) then
		outputChatBox("#ff8800[Speakers]: #ffffffYou have no access to #ff8800/"..RADIO_DESTROY_SPEAKERS_IN_RANGE_COMMAND, playerElement, 255, 255, 255, true)

		return false
	end

	local speakerSearchRange = tonumber(searchRange)
	local validSearchRange = (speakerSearchRange and speakerSearchRange > 0)

	if (not speakerSearchRange or not validSearchRange) then
		outputChatBox("#ff8800[Speakers]: #ffffffSyntax: #ff8800/"..RADIO_DESTROY_SPEAKERS_IN_RANGE_COMMAND.." <searchRange>", playerElement, 255, 255, 255, true)

		return false
	end

	local objectsTable = getElementsByType("object", resourceRoot)
	local playerInterior = getElementInterior(playerElement)
	local playerDimension = getElementDimension(playerElement)
	local playerX, playerY, playerZ = getElementPosition(playerElement)
	local totalDestroyedSpeakers = 0

	for objectID = 1, #objectsTable do
		local objectElement = objectsTable[objectID]
		local objectSpeaker = isObjectSpeaker(objectElement)

		if (objectSpeaker) then
			local speakerInterior = getElementInterior(objectElement)
			local speakerDimension = getElementDimension(objectElement)
			local matchingInterior = (speakerInterior == playerInterior)
			local matchingDimension = (speakerDimension == playerDimension)

			if (matchingInterior and matchingDimension) then
				local speakerX, speakerY, speakerZ = getElementPosition(objectElement)
				local distanceToSpeaker = getDistanceBetweenPoints3D(playerX, playerY, playerZ, speakerX, speakerY, speakerZ)
				local speakerInDistance = (distanceToSpeaker <= speakerSearchRange)

				if (speakerInDistance) then
					local speakerDestroyed = clearPlayerSpeaker(objectElement, true)

					if (speakerDestroyed) then
						local newCountOfDestroyedSpeakers = (totalDestroyedSpeakers + 1)

						totalDestroyedSpeakers = newCountOfDestroyedSpeakers
					end
				end
			end
		end
	end

	outputChatBox("#ff8800[Speakers]: #ffffffDestroyed #ff8800"..totalDestroyedSpeakers.."#ffffff total speakers in range of #ff8800"..speakerSearchRange, playerElement, 255, 255, 255, true)
end
addCommandHandler(RADIO_DESTROY_SPEAKERS_IN_RANGE_COMMAND, destroySpeakersInRangeAdminCommand)

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
			local speakerFound = clearPlayerSpeaker(attachedElement, true)

			if (speakerFound) then
				break
			end
		end
	end
end

if (RADIO_DESTROY_ON_VEHICLE_EXPLODE) then
	addEventHandler("onVehicleExplode", root, destroyAttachedRadioOnVehicleExplodeOrDestroy)
end

if (RADIO_DESTROY_ON_VEHICLE_DESTROY) then
	addEventHandler("onElementDestroy", root, destroyAttachedRadioOnVehicleExplodeOrDestroy)
end