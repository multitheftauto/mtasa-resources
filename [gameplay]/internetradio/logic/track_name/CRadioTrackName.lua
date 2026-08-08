-- #######################################
-- ## Project: Internet radio			##
-- ## Authors: MTA contributors			##
-- ## Version: 1.0						##
-- #######################################

local trackNameColorCoded = false
local speakerTrackRender = false
local fontHeight = dxGetFontHeight(RADIO_TRACK_SCALE, RADIO_TRACK_FONT)

NEARBY_SPEAKERS = {}

local lastKeyCheck = 0
local KEY_CHECK_MS = 200
local cachedShowOwner = false
local nearbySpeakersTimer = nil

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

-- Exposed globally so clearPlayerSpeaker in CHandleRadio.lua can trigger
-- render-handler teardown when the last speaker is removed.
function removeNearbySpeaker(speakerDummy)
	if (not speakerDummy) then
		return
	end

	NEARBY_SPEAKERS[speakerDummy] = nil
	toggleSpeakerTrackRender()
end

local function getSpeakerTrackName(streamSound)
	if (not isElement(streamSound)) then
		return false
	end

	if (getElementType(streamSound) ~= "sound") then
		return false
	end

	local streamMetaTags = getSoundMetaTags(streamSound)

	if (not streamMetaTags) then
		return false
	end

	return streamMetaTags.stream_title or streamMetaTags.title
end

function checkForNearbySpeakers()
	local playerX, playerY, playerZ = getElementPosition(localPlayer)
	local playerInterior = getElementInterior(localPlayer)
	local playerDimension = getElementDimension(localPlayer)
	local nearbyObjects = getElementsWithinRange(playerX, playerY, playerZ, RADIO_MAX_SOUND_DISTANCE, "object", playerInterior, playerDimension)

	local newNearby = {}

	for objectID = 1, #nearbyObjects do
		local nearbyObject = nearbyObjects[objectID]
		local _, speakerSound, speakerDummy, speakerOwner = isObjectSpeaker(nearbyObject)
		local trackName = getSpeakerTrackName(speakerSound)

		if (speakerDummy and trackName) then
			local ownerName = getPlayerName(speakerOwner)
			local cleanOwnerName = (type(ownerName) == "string") and removeHex(ownerName) or "unknown"
			local ownerTrackName = "(Owner: " .. cleanOwnerName .. ") " .. trackName
			local textWidth = dxGetTextWidth(trackName, RADIO_TRACK_SCALE, RADIO_TRACK_FONT, trackNameColorCoded)
			local ownerTextWidth = dxGetTextWidth(ownerTrackName, RADIO_TRACK_SCALE, RADIO_TRACK_FONT, trackNameColorCoded)

			newNearby[speakerDummy] = {
				trackName = trackName,
				ownerTrackName = ownerTrackName,
				textWidth = textWidth,
				ownerTextWidth = ownerTextWidth,
			}
		end
	end

	NEARBY_SPEAKERS = newNearby
	toggleSpeakerTrackRender()
end
nearbySpeakersTimer = setTimer(checkForNearbySpeakers, 1000, 0)

function onClientRenderRadioTrackName()
	local now = getTickCount()

	if (now - lastKeyCheck >= KEY_CHECK_MS) then
		cachedShowOwner = getKeyState(RADIO_SHOW_SPEAKER_OWNER_KEY)
		lastKeyCheck = now
	end

	for speakerDummy, sd in pairs(NEARBY_SPEAKERS) do
		local wx, wy, wz = getElementPosition(speakerDummy)
		local sx, sy = getScreenFromWorldPosition(wx, wy, wz + 1, 0, false)

		if (sx and sy) then
			local trackName, textWidth

			if (cachedShowOwner) then
				trackName = sd.ownerTrackName
				textWidth = sd.ownerTextWidth
			else
				trackName = sd.trackName
				textWidth = sd.textWidth
			end

			local textPosX = (sx - textWidth / 2)

			dxDrawRectangle(textPosX - 5, sy, textWidth + 8, fontHeight, RADIO_TRACK_BACKGROUND_COLOR, false)
			dxDrawText(trackName, textPosX, sy, textPosX, sy, RADIO_TRACK_COLOR, RADIO_TRACK_SCALE, "default-bold")
		end
	end
end

addEventHandler("onClientResourceStop", resourceRoot, function()
	if (nearbySpeakersTimer and isTimer(nearbySpeakersTimer)) then
		killTimer(nearbySpeakersTimer)
		nearbySpeakersTimer = nil
	end

	NEARBY_SPEAKERS = {}
	toggleSpeakerTrackRender()
end, false)