-- #######################################
-- ## Project: Internet radio			##
-- ## Authors: MTA contributors			##
-- ## Version: 1.0						##
-- #######################################

local speakerSounds = {}
local playerSpeakers = {}
-- Maps box/dummy elements to their owning player for cleanup lookups.
local speakerReverseMap = {}
local speakerVolumeSyncTimer = false

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

	local playerElement = speakerReverseMap[speakerElement]

	if (playerElement) then
		toggleSpeakerSounds(playerElement, toggleOn)

		return true
	end

	return false
end

local function getLocalSpeakerVolume()
	local speakerVolume = guiScrollBarGetScrollPosition(RADIO_GUI["Volume"])
	local speakerVolumeValue = (speakerVolume/100)

	return speakerVolumeValue
end

local function syncSpeakerVolume()
	local speakerVolume = getLocalSpeakerVolume()

	triggerServerEvent("onServerSetSpeakerVolume", localPlayer, speakerVolume)
	speakerVolumeSyncTimer = false

	return true
end

local function requestSpeakerVolumeSync()
	local speakerVolume = getLocalSpeakerVolume()

	setPlayerSpeakerVolume(localPlayer, speakerVolume) -- set volume locally so localPlayer could adjust it without any delay (this will be sanity corrected by server later on)

	if (speakerVolumeSyncTimer) then
		resetTimer(speakerVolumeSyncTimer)
	else
		local speakerTimerInterval = (RADIO_VOLUME_DELAY + 50) -- extra time to let server catch up

		speakerVolumeSyncTimer = setTimer(syncSpeakerVolume, speakerTimerInterval, 1)
	end

	return true
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
		speakerSounds[playerElement] = nil
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
		local speakerVolume = speakerData.speakerVolume
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
		setSoundVolume(speakerNewSound, speakerVolume)
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
	local speakerVolume = getLocalSpeakerVolume()

	if (not streamURL) then
		local textToDisplay = errorCode or "SPEAKER: Invalid URL, please check your input!"

		outputChatBox(textToDisplay, 255, 0, 0)

		return false
	end

	local createDelayPassed = getOrSetPlayerDelay(localPlayer, "create_speaker", RADIO_CREATE_SPEAKER_DELAY)

	if (not createDelayPassed) then
		return false
	end

	triggerServerEvent("onServerCreateSpeaker", localPlayer, streamURL, speakerVolume)
end

function onClientGUIScrollVolume()
	requestSpeakerVolumeSync()
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
	local speakerDummy = createObject(RADIO_DUMMY_MODEL, 0, 0, 3)

	if (not isElement(speakerDummy)) then
		return false
	end

	local existingData = playerSpeakers[playerElement]

	-- Clean up reverse map entries from the previous speaker before
	-- replacing them, so a later destruction of the old elements does
	-- not accidentally target the new speaker.
	if (existingData) then
		local oldBox = existingData.speakerBox
		local oldDummy = existingData.speakerDummy

		if (oldBox) then
			speakerReverseMap[oldBox] = nil
		end

		if (oldDummy) then
			speakerReverseMap[oldDummy] = nil
			removeNearbySpeaker(oldDummy)
			existingData.speakerDummy = nil

			if (isElement(oldDummy)) then
				destroyElement(oldDummy)
			end
		end
	end

	speakerData.speakerDummy = speakerDummy
	playerSpeakers[playerElement] = speakerData
	speakerReverseMap[speakerDummy] = playerElement

	if (speakerBox and isElement(speakerBox)) then
		speakerReverseMap[speakerBox] = playerElement
	end

	toggleSpeakerSounds(playerElement, true)

	setElementAlpha(speakerDummy, 0)
	setElementCollisionsEnabled(speakerDummy, false)

	if (speakerBox and isElement(speakerBox)) then
		local speakerBoxDimension = getElementDimension(speakerBox)
		setElementDimension(speakerDummy, speakerBoxDimension)
		attachElements(speakerDummy, speakerBox, -0.32, -0.22, 0.8)
	end

	return true
end

function setPlayerSpeakerVolume(playerElement, speakerVolume)
	local validElement = isElement(playerElement)
	local speakerSound = speakerSounds[playerElement]

	if (not validElement or not speakerSound) then
		return false
	end

	setSoundVolume(speakerSound, speakerVolume)

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
	local playerElement = speakerReverseMap[playerOrSpeaker]

	-- look up the owning player from the reverse map instead of
	-- scanning the entire playerSpeakers table.
	if (playerElement) then
		speakerReverseMap[playerOrSpeaker] = nil

		local speakerData = playerSpeakers[playerElement]

		if (speakerData) then
			local speakerBox = speakerData.speakerBox
			local speakerDummy = speakerData.speakerDummy

			if (speakerBox) then
				speakerReverseMap[speakerBox] = nil
			end

			if (speakerDummy) then
				speakerReverseMap[speakerDummy] = nil
				local speakerDummyElement = isElement(speakerDummy)

				removeNearbySpeaker(speakerDummy)

				if (speakerDummyElement) then
					destroyElement(speakerDummy)
				end
			end

			toggleSpeakerSounds(playerElement, false)
			playerSpeakers[playerElement] = nil

			return true
		end
	end

	for scanPlayer, speakerData in pairs(playerSpeakers) do
		local speakerBox = speakerData.speakerBox
		local speakerDummy = speakerData.speakerDummy
		local matchingElement = (scanPlayer == playerOrSpeaker) or (speakerBox == playerOrSpeaker) or (speakerDummy == playerOrSpeaker)

		if (matchingElement) then
			if (speakerBox) then
				speakerReverseMap[speakerBox] = nil
			end

			if (speakerDummy) then
				speakerReverseMap[speakerDummy] = nil
				local speakerDummyElement = isElement(speakerDummy)

				removeNearbySpeaker(speakerDummy)

				if (speakerDummyElement) then
					destroyElement(speakerDummy)
				end
			end

			toggleSpeakerSounds(scanPlayer, false)
			playerSpeakers[scanPlayer] = nil

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

function handleAllSpeakers(forceRecreate)
	for playerElement, speakerData in pairs(playerSpeakers) do
		local speakerBox = speakerData.speakerBox
		local speakerBoxStreamedIn = isElementStreamedIn(speakerBox)

		if (speakerBoxStreamedIn and (forceRecreate or not (isElement(speakerSounds[playerElement])))) then
			toggleSpeakerSounds(playerElement, true)
		end
	end

	return true
end

function onClientSyncSpeakers(activeSpeakers)
	-- Preserve speakerDummy references from entries the client already knows about,
	-- and create dummies for synced entries that lack them (server data has no dummies).
	-- Discard reverse map entries from the old playerSpeakers table,
	-- which is about to be replaced. Prevents stale entries from
	-- misdirecting future cleanup to entries that no longer exist.
	for playerElement, speakerData in pairs(playerSpeakers) do
		if (speakerData.speakerBox) then
			speakerReverseMap[speakerData.speakerBox] = nil
		end

		if (speakerData.speakerDummy) then
			speakerReverseMap[speakerData.speakerDummy] = nil
		end
	end

	for playerElement, speakerData in pairs(activeSpeakers) do
		local existingData = playerSpeakers[playerElement]
		local speakerBox = speakerData.speakerBox

		if (existingData and existingData.speakerDummy) then
			speakerData.speakerDummy = existingData.speakerDummy
		elseif (not speakerData.speakerDummy) then
			if (speakerBox and isElement(speakerBox)) then
				local speakerDummy = createObject(RADIO_DUMMY_MODEL, 0, 0, 3)

				if (isElement(speakerDummy)) then
					local speakerBoxDimension = getElementDimension(speakerBox)

					setElementAlpha(speakerDummy, 0)
					setElementCollisionsEnabled(speakerDummy, false)
					setElementDimension(speakerDummy, speakerBoxDimension)
					attachElements(speakerDummy, speakerBox, -0.32, -0.22, 0.8)
					speakerData.speakerDummy = speakerDummy
				end
			end
		end

		if (speakerData.speakerDummy) then
			speakerReverseMap[speakerData.speakerDummy] = playerElement
		end

		if (speakerBox and isElement(speakerBox)) then
			speakerReverseMap[speakerBox] = playerElement
		end
	end

	-- Stop sounds for speakers that are no longer in the sync data,
	-- so removed entries do not leave orphaned audio playing indefinitely.
	-- Also clean up dummies and track-name entries for orphaned speakers.
	for playerElement, speakerData in pairs(playerSpeakers) do
		if (not activeSpeakers[playerElement]) then
			toggleSpeakerSounds(playerElement, false)

			if (speakerData.speakerDummy) then
				removeNearbySpeaker(speakerData.speakerDummy)

				if (isElement(speakerData.speakerDummy)) then
					destroyElement(speakerData.speakerDummy)
				end
			end
		end
	end

	playerSpeakers = activeSpeakers
	handleAllSpeakers(true)
end
addEvent("onClientSyncSpeakers", true)
addEventHandler("onClientSyncSpeakers", root, onClientSyncSpeakers)

function onClientCreateSpeaker(speakerData)
	if (not speakerData) then
		return false
	end

	return setPlayerSpeakerData(source, speakerData)
end
addEvent("onClientCreateSpeaker", true)
addEventHandler("onClientCreateSpeaker", root, onClientCreateSpeaker)

function onClientSetSpeakerVolume(speakerVolume)
	setPlayerSpeakerVolume(source, speakerVolume)
end
addEvent("onClientSetSpeakerVolume", true)
addEventHandler("onClientSetSpeakerVolume", root, onClientSetSpeakerVolume)

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
	if (speakerReverseMap[source]) then
		clearPlayerSpeaker(source)
	end
end
addEventHandler("onClientElementDestroy", resourceRoot, clearSpeakersOnDestroyQuit)

function clearSpeakersOnPlayerQuit()
	clearPlayerSpeaker(source)
end
addEventHandler("onClientPlayerQuit", root, clearSpeakersOnPlayerQuit)

addEventHandler("onClientResourceStop", resourceRoot, function()
	if (speakerVolumeSyncTimer and isTimer(speakerVolumeSyncTimer)) then
		killTimer(speakerVolumeSyncTimer)
		speakerVolumeSyncTimer = false
	end

	local toClean = {}
	for playerElement, _ in pairs(playerSpeakers) do
		toClean[#toClean + 1] = playerElement
	end

	for _, playerElement in ipairs(toClean) do
		clearPlayerSpeaker(playerElement)
	end

	speakerSounds = {}
	speakerReverseMap = {}
end, false)