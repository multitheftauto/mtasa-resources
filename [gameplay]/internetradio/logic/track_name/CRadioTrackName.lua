-- #######################################
-- ## Project: Internet radio			##
-- ## Authors: MTA contributors			##
-- ## Version: 1.0						##
-- #######################################

local trackNameColorCoded = false
local speakerTrackRender = false
local fontHeight = dxGetFontHeight(RADIO_TRACK_SCALE, RADIO_TRACK_FONT)

NEARBY_SPEAKERS = {}

local function toggleSpeakerTrackRender()
	local toggleOn = next(NEARBY_SPEAKERS)

	if (toggleOn) then
		if (speakerTrackRender) then
			return false
		end

		addEventHandler("onClientRender", root, onClientRenderRadioTrackName)
		speakerTrackRender = true

		return true
	end

	if (not toggleOn) then
		if (not speakerTrackRender) then
			return false
		end

		removeEventHandler("onClientRender", root, onClientRenderRadioTrackName)
		speakerTrackRender = false

		return true
	end
end

local function getSpeakerTrackName(streamSound)
	local validElement = isElement(streamSound)

	if (not validElement) then
		return false
	end

	local elementType = getElementType(streamSound)
	local soundType = (elementType == "sound")

	if (not soundType) then
		return false
	end

	local streamMetaTags = getSoundMetaTags(streamSound)

	if (not streamMetaTags) then
		return false
	end

	local streamTitle = streamMetaTags.stream_title
	local streamTrackTitle = streamMetaTags.title
	local trackName = (streamTitle or streamTrackTitle)

	return trackName
end

function checkForNearbySpeakers()
	local playerX, playerY, playerZ = getElementPosition(localPlayer)
	local playerInterior = getElementInterior(localPlayer)
	local playerDimension = getElementDimension(localPlayer)
	local searchRange = RADIO_MAX_SOUND_DISTANCE
	local nearbyObjects = getElementsWithinRange(playerX, playerY, playerZ, searchRange, "object", playerInterior, playerDimension)

	NEARBY_SPEAKERS = {}

	for objectID = 1, #nearbyObjects do
		local nearbyObject = nearbyObjects[objectID]
		local _, speakerSound, speakerDummy, speakerOwner = isObjectSpeaker(nearbyObject)
		local trackName = getSpeakerTrackName(speakerSound)

		if (speakerDummy and trackName) then
			NEARBY_SPEAKERS[speakerDummy] = {trackName, speakerOwner}
		end
	end

	toggleSpeakerTrackRender()
end
setTimer(checkForNearbySpeakers, 1000, 0)

function onClientRenderRadioTrackName()
	local cameraX, cameraY, cameraZ = getCameraMatrix()

	for nearbySpeaker, speakerData in pairs(NEARBY_SPEAKERS) do
		local speakerX, speakerY, speakerZ = getElementPosition(nearbySpeaker)
		local distanceToSpeaker = getDistanceBetweenPoints3D(speakerX, speakerY, speakerZ, cameraX, cameraY, cameraZ)
		local closeToSpeaker = (distanceToSpeaker <= RADIO_MAX_SOUND_DISTANCE)

		if (closeToSpeaker) then
			local speakerOffsetZ = (speakerZ + 1)
			local screenX, screenY = getScreenFromWorldPosition(speakerX, speakerY, speakerOffsetZ, 0, false)

			if (screenX and screenY) then
				local trackName = speakerData[1]
				local displaySpeakerOwner = getKeyState(RADIO_SHOW_SPEAKER_OWNER_KEY)

				if (displaySpeakerOwner) then
					local speakerOwner = speakerData[2]
					local speakerName = getPlayerName(speakerOwner)
					local speakerPlayerName = removeHex(speakerName)

					trackName = "(Owner: "..speakerPlayerName..") "..trackName
				end

				local textWidth = dxGetTextWidth(trackName, RADIO_TRACK_SCALE, RADIO_TRACK_FONT, trackNameColorCoded)
				local textPosX = (screenX - textWidth / 2)
				local textBackgroundPosX = (textPosX - 5)
				local textBackgroundPosY = (textWidth + 8)

				dxDrawRectangle(textBackgroundPosX, screenY, textBackgroundPosY, fontHeight, RADIO_TRACK_BACKGROUND_COLOR, false)
				dxDrawText(trackName, textPosX, screenY, textPosX, screenY, RADIO_TRACK_COLOR, RADIO_TRACK_SCALE, "default-bold")
			end
		end
	end
end