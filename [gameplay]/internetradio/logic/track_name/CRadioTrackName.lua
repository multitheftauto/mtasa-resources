-- #######################################
-- ## Project: Internet radio			##
-- ## Authors: MTA contributors			##
-- ## Version: 1.0						##
-- #######################################

local trackNameColorCoded = false
local speakerTrackRender = false
local fontHeight = dxGetFontHeight(RADIO_TRACK_SCALE, RADIO_TRACK_FONT)

local getElementPosition = getElementPosition
local getElementInterior = getElementInterior
local getElementDimension = getElementDimension
local getElementsWithinRange = getElementsWithinRange
local getScreenFromWorldPosition = getScreenFromWorldPosition
local getTickCount = getTickCount
local getKeyState = getKeyState
local getCameraMatrix = getCameraMatrix
local guiGetScreenSize = guiGetScreenSize
local isElement = isElement
local getElementType = getElementType
local getSoundMetaTags = getSoundMetaTags
local getPlayerName = getPlayerName
local dxGetTextWidth = dxGetTextWidth
local dxDrawRectangle = dxDrawRectangle
local dxDrawText = dxDrawText
local setTimer = setTimer
local killTimer = killTimer
local isTimer = isTimer

local NEARBY_SPEAKERS = {}

local lastKeyCheck = 0
local KEY_CHECK_MS = 200
local cachedShowOwner = false

-- Screen projections are only valid for the camera and screen state
-- they were computed with, so keep the last camera and screen size and
-- refresh labels only when one of them or the label anchor changes.
local lastCameraX, lastCameraY, lastCameraZ = 0, 0, 0
local lastCameraLX, lastCameraLY, lastCameraLZ = 0, 0, 0
local lastCameraRoll, lastCameraFOV = 0, 0
local lastScreenWidth, lastScreenHeight = 0, 0

local nearbySpeakersTimer = false

local startNearbySpeakersTimer
local stopNearbySpeakersTimer

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

		if (speakerDummy and isElement(speakerDummy) and trackName) then
			local ownerName = getPlayerName(speakerOwner)
			local cleanOwnerName = (type(ownerName) == "string") and removeHex(ownerName) or "unknown"
			local ownerTrackName = "(Owner: " .. cleanOwnerName .. ") " .. trackName
			local textWidth = dxGetTextWidth(trackName, RADIO_TRACK_SCALE, RADIO_TRACK_FONT, trackNameColorCoded)
			local ownerTextWidth = dxGetTextWidth(ownerTrackName, RADIO_TRACK_SCALE, RADIO_TRACK_FONT, trackNameColorCoded)
			local speakerDummyX, speakerDummyY, speakerDummyZ = getElementPosition(speakerDummy)

			newNearby[speakerDummy] = {
				trackName = trackName,
				ownerTrackName = ownerTrackName,
				textWidth = textWidth,
				ownerTextWidth = ownerTextWidth,
				wx = speakerDummyX,
				wy = speakerDummyY,
				wz = speakerDummyZ,
			}
		end
	end

	NEARBY_SPEAKERS = newNearby
	toggleSpeakerTrackRender()

	if (hasAnySpeakers()) then
		startNearbySpeakersTimer()
	else
		stopNearbySpeakersTimer()
	end
end

startNearbySpeakersTimer = function()
	if (nearbySpeakersTimer and isTimer(nearbySpeakersTimer)) then
		return false
	end

	nearbySpeakersTimer = setTimer(checkForNearbySpeakers, 1000, 0)

	return true
end

stopNearbySpeakersTimer = function()
	if (nearbySpeakersTimer and isTimer(nearbySpeakersTimer)) then
		killTimer(nearbySpeakersTimer)
	end

	nearbySpeakersTimer = false
end

-- Called when speakers are created or synced, so a new speaker gets its
-- track name right away instead of on the next timed scan.
function requestNearbySpeakersScan()
	if (not hasAnySpeakers()) then
		stopNearbySpeakersTimer()

		return false
	end

	startNearbySpeakersTimer()
	checkForNearbySpeakers()

	return true
end

function onClientRenderRadioTrackName()
	local now = getTickCount()

	local cameraX, cameraY, cameraZ, cameraLX, cameraLY, cameraLZ, cameraRoll, cameraFOV = getCameraMatrix()
	local cameraChanged = (cameraX ~= lastCameraX) or (cameraY ~= lastCameraY) or (cameraZ ~= lastCameraZ)
		or (cameraLX ~= lastCameraLX) or (cameraLY ~= lastCameraLY) or (cameraLZ ~= lastCameraLZ)
		or (cameraRoll ~= lastCameraRoll) or (cameraFOV ~= lastCameraFOV)

	if (cameraChanged) then
		lastCameraX, lastCameraY, lastCameraZ = cameraX, cameraY, cameraZ
		lastCameraLX, lastCameraLY, lastCameraLZ = cameraLX, cameraLY, cameraLZ
		lastCameraRoll, lastCameraFOV = cameraRoll, cameraFOV
	end

	local screenWidth, screenHeight = guiGetScreenSize()
	local screenChanged = (screenWidth ~= lastScreenWidth) or (screenHeight ~= lastScreenHeight)

	if (screenChanged) then
		lastScreenWidth, lastScreenHeight = screenWidth, screenHeight
	end

	if (now - lastKeyCheck >= KEY_CHECK_MS) then
		cachedShowOwner = getKeyState(RADIO_SHOW_SPEAKER_OWNER_KEY)
		lastKeyCheck = now
	end

	local deadSpeakers = false

	for speakerDummy, sd in pairs(NEARBY_SPEAKERS) do
		if (not isElement(speakerDummy)) then
			deadSpeakers = deadSpeakers or {}
			deadSpeakers[#deadSpeakers + 1] = speakerDummy
		else
			-- Off-screen projections return false and must not count as
			-- missing, or they would be recomputed while nothing changed.
			local speakerDummyX, speakerDummyY, speakerDummyZ = getElementPosition(speakerDummy)
			local anchorMoved = (speakerDummyX ~= sd.wx) or (speakerDummyY ~= sd.wy) or (speakerDummyZ ~= sd.wz)

			if (cameraChanged or screenChanged or anchorMoved or sd.screenX == nil) then
				sd.wx, sd.wy, sd.wz = speakerDummyX, speakerDummyY, speakerDummyZ
				sd.screenX, sd.screenY = getScreenFromWorldPosition(sd.wx, sd.wy, sd.wz + 1, 0, false)
			end

			if (sd.screenX and sd.screenY) then
				local trackName, textWidth

				if (cachedShowOwner) then
					trackName = sd.ownerTrackName
					textWidth = sd.ownerTextWidth
				else
					trackName = sd.trackName
					textWidth = sd.textWidth
				end

				local textPosX = (sd.screenX - textWidth / 2)

				dxDrawRectangle(textPosX - 5, sd.screenY, textWidth + 8, fontHeight, RADIO_TRACK_BACKGROUND_COLOR, false)
				dxDrawText(trackName, textPosX, sd.screenY, textPosX, sd.screenY, RADIO_TRACK_COLOR, RADIO_TRACK_SCALE, RADIO_TRACK_FONT)
			end
		end
	end

	if (deadSpeakers) then
		for _, speakerDummy in ipairs(deadSpeakers) do
			removeNearbySpeaker(speakerDummy)
		end
	end
end

addEventHandler("onClientResourceStop", resourceRoot, function()
	stopNearbySpeakersTimer()

	NEARBY_SPEAKERS = {}
	toggleSpeakerTrackRender()
end, false)