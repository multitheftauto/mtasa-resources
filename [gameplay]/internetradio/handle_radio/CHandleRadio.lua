-- #######################################
-- ## Project: Internet radio			##
-- ## Authors: MTA contributors			##
-- ## Version: 1.0						##
-- #######################################

local speakerSounds = {}
local playerSpeakers = {}

local function getStreamURLFromEdit()
	local streamURL = guiGetText(RADIO_GUI["Stream URL edit"])
	local validStreamURL, errorCode = verifyRadioStreamURL(streamURL)

	if (not validStreamURL) then
		return false, errorCode
	end

	return streamURL
end

local function handleSpeakerOnStreamInOut(speakerElement, toggleOn)
	local validElement = isElement(speakerElement)

	if (not validElement) then
		return false
	end

	local elementType = getElementType(speakerElement)
	local objectType = (elementType == "object")

	if (not objectType) then
		return false
	end

	for playerElement, speakerData in pairs(playerSpeakers) do
		local speakerBox = speakerData.speakerBox
		local matchingElement = (speakerBox == speakerElement)

		if (matchingElement) then
			toggleSpeakerSounds(playerElement, toggleOn)

			return true
		end
	end

	return false
end

function loadRadioStations()
	for stationID = 1, #RADIO_STATIONS do
		local radioStationData = RADIO_STATIONS[stationID]
		local radioStation = radioStationData[1]
		local radioStationURL = radioStationData[2]
		local radioStationRow = guiGridListAddRow(RADIO_GUI["Stream URLs gridlist"])

		guiGridListSetItemText(RADIO_GUI["Stream URLs gridlist"], radioStationRow, RADIO_GUI["Radio station URL column"], radioStation, false, false)
		guiGridListSetItemData(RADIO_GUI["Stream URLs gridlist"], radioStationRow, RADIO_GUI["Radio station URL column"], radioStationURL)
	end

	return true
end

function toggleSpeakerSounds(playerElement, toggleOn)
	local speakerSound = speakerSounds[playerElement]
	local speakerSoundElement = isElement(speakerSound)

	if (speakerSoundElement) then
		destroyElement(speakerSound)
	end

	local allowRemoteSpeakers = getRadioSetting("allowRemoteSpeakers")

	if (not allowRemoteSpeakers) then
		local remoteSpeaker = (playerElement ~= localPlayer)

		if (remoteSpeaker) then
			toggleOn = false
		end
	end

	if (toggleOn) then
		local speakerData = getPlayerSpeakerData(playerElement)

		if (not speakerData) then
			return false
		end

		local speakerBox = speakerData.speakerBox
		local speakerBoxPosX, speakerBoxPosY, speakerBoxPosZ = getElementPosition(speakerBox)
		local speakerInterior = getElementInterior(speakerBox)
		local speakerDimension = getElementDimension(speakerBox)
		local speakerSoundMaxDistance = speakerData.speakerSoundMaxDistance
		local speakerStreamURL = speakerData.speakerStreamURL
		local speakerNewSound = playSound3D(speakerStreamURL, speakerBoxPosX, speakerBoxPosY, speakerBoxPosZ, true, false)

		if (not speakerNewSound) then
			return false
		end

		local speakerPaused = speakerData.speakerPaused

		speakerSounds[playerElement] = speakerNewSound

		setElementInterior(speakerNewSound, speakerInterior)
		setElementDimension(speakerNewSound, speakerDimension)

		setSoundPaused(speakerNewSound, speakerPaused)
		setSoundMaxDistance(speakerNewSound, speakerSoundMaxDistance)
		setSoundVolume(speakerNewSound, 1)
		attachElements(speakerNewSound, speakerBox)
	end

	if (not toggleOn) then
		speakerSounds[playerElement] = nil
	end

	return true
end

function onClientGUIClickLoadStationStreamURL()
	local selectedRow, selectedColumn = guiGridListGetSelectedItem(source)
	local stationStreamURL = guiGridListGetItemData(source, selectedRow, selectedColumn)

	if (not stationStreamURL) then
		return false
	end

	guiSetText(RADIO_GUI["Stream URL edit"], stationStreamURL)
end

function onClientGUIClickCreateSpeaker()
	local streamURL, errorCode = getStreamURLFromEdit()

	if (not streamURL) then
		local textToDisplay = errorCode or "SPEAKER: Invalid URL, please check your input!"

		outputChatBox(textToDisplay, 255, 0, 0)

		return false
	end

	local createDelayPassed = getOrSetPlayerDelay(localPlayer, "create_speaker", RADIO_CREATE_SPEAKER_DELAY)

	if (not createDelayPassed) then
		return false
	end

	triggerServerEvent("onServerCreateSpeaker", localPlayer, streamURL)
end

function onClientGUIClickToggleSpeaker()
	local playerSpeaker = getPlayerSpeakerData(localPlayer)

	if (not playerSpeaker) then
		return false
	end

	local toggleDelayPassed = getOrSetPlayerDelay(localPlayer, "toggle_speaker", RADIO_TOGGLE_SPEAKER_DELAY)

	if (not toggleDelayPassed) then
		return false
	end

	triggerServerEvent("onServerToggleSpeaker", localPlayer)
end

function onClientGUIClickDestroySpeaker()
	local playerSpeaker = getPlayerSpeakerData(localPlayer)

	if (not playerSpeaker) then
		return false
	end

	local destroyDelayPassed = getOrSetPlayerDelay(localPlayer, "destroy_speaker", RADIO_DESTROY_SPEAKER_DELAY)

	if (not destroyDelayPassed) then
		return false
	end

	triggerServerEvent("onServerDestroySpeaker", localPlayer)
end

function onClientGUIClickCloseRadioGUI()
	toggleRadioGUI()
end

function setPlayerSpeakerData(playerElement, speakerData)
	local validElement = isElement(playerElement)

	if (not validElement) then
		return false
	end

	local speakerBox = speakerData.speakerBox
	local speakerDummy = createObject(1337, 0, 0, 3)
	local speakerBoxDimension = getElementDimension(speakerBox)
	setElementDimension(speakerDummy, speakerBoxDimension)

	speakerData.speakerDummy = speakerDummy
	playerSpeakers[playerElement] = speakerData

	toggleSpeakerSounds(playerElement, true)

	setElementAlpha(speakerDummy, 0)
	setElementCollisionsEnabled(speakerDummy, false)
	attachElements(speakerDummy, speakerBox, -0.32, -0.22, 0.8)

	return true
end

function setPlayerSpeakerPaused(playerElement, pauseState)
	local playerSpeakerData = getPlayerSpeakerData(playerElement)

	if (not playerSpeakerData) then
		return false
	end

	local speakerSound = speakerSounds[playerElement]

	playerSpeakerData.speakerPaused = pauseState

	if (speakerSound) then
		local speakerPaused = isSoundPaused(speakerSound)
		local updatePauseState = (speakerPaused ~= pauseState)

		if (updatePauseState) then
			setSoundPaused(speakerSound, pauseState)
		end
	end

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
			local speakerDummy = speakerData.speakerDummy
			local speakerDummyElement = isElement(speakerDummy)

			NEARBY_SPEAKERS[speakerDummy] = nil

			if (speakerDummyElement) then
				destroyElement(speakerDummy)
			end

			toggleSpeakerSounds(playerElement, false)
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

		if (speakerData) then
			local speakerBox = speakerData.speakerBox
			local matchingElement = (speakerBox == objectElement)

			if (matchingElement) then
				local speakerSound = speakerSounds[playerElement]
				local speakerDummy = speakerData.speakerDummy

				return true, speakerSound, speakerDummy, playerElement
			end
		end
	end

	return false
end

function handleAllSpeakers()
	for playerElement, speakerData in pairs(playerSpeakers) do
		local speakerBox = speakerData.speakerBox
		local speakerBoxStreamedIn = isElementStreamedIn(speakerBox)

		if (speakerBoxStreamedIn) then
			toggleSpeakerSounds(playerElement, true)
		end
	end

	return true
end

function onClientSyncSpeakers(activeSpeakers)
	playerSpeakers = activeSpeakers
	handleAllSpeakers()
end
addEvent("onClientSyncSpeakers", true)
addEventHandler("onClientSyncSpeakers", root, onClientSyncSpeakers)

function onClientCreateSpeaker(speakerData)
	setPlayerSpeakerData(source, speakerData)
end
addEvent("onClientCreateSpeaker", true)
addEventHandler("onClientCreateSpeaker", root, onClientCreateSpeaker)

function onClientToggleSpeaker(pauseState)
	setPlayerSpeakerPaused(source, pauseState)
end
addEvent("onClientToggleSpeaker", true)
addEventHandler("onClientToggleSpeaker", root, onClientToggleSpeaker)

function toggleSpeakerOnStreamIn()
	handleSpeakerOnStreamInOut(source, true)
end
addEventHandler("onClientElementStreamIn", resourceRoot, toggleSpeakerOnStreamIn)

function toggleSpeakerOnStreamOut()
	handleSpeakerOnStreamInOut(source, false)
end
addEventHandler("onClientElementStreamOut", resourceRoot, toggleSpeakerOnStreamOut)

function clearSpeakersOnDestroyQuit()
	clearPlayerSpeaker(source)
end
addEventHandler("onClientPlayerQuit", root, clearSpeakersOnDestroyQuit)
addEventHandler("onClientElementDestroy", resourceRoot, clearSpeakersOnDestroyQuit)
