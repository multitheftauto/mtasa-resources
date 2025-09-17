-- #######################################
-- ## Project: Internet radio			##
-- ## Authors: MTA contributors			##
-- ## Version: 1.0						##
-- #######################################

local isServer = (not triggerServerEvent)
local playerDelays = {}

function verifyRadioStreamURL(streamURL)
	local urlType = type(streamURL)
	local urlString = (urlType == "string")

	if (not urlString) then
		return false
	end

	local urlLength = utf8.len(streamURL)
	local urlValidLength = (urlLength <= RADIO_STREAM_URL_MAX_LENGTH)

	if (not urlValidLength) then
		return false
	end

	local urlHttp = utf8.find(streamURL, "http")

	if (not urlHttp) then
		return false
	end

	if (not RADIO_ALLOW_CUSTOM_URLS) then
		local allowedStreamURL = false

		for stationID = 1, #RADIO_STATIONS do
			local stationData = RADIO_STATIONS[stationID]
			local stationStreamURL = stationData[2]
			local matchingStreamURL = (stationStreamURL == streamURL)

			if (matchingStreamURL) then
				allowedStreamURL = true
				break
			end
		end

		if (not allowedStreamURL) then
			return false, "SPEAKER: Custom URLs are not allowed."
		end
	end

	return true
end

function getPlayerFromPartialName(partialName)
	if (not partialName) then
		return false
	end

	local playerFromName = getPlayerFromName(partialName)

	if (playerFromName) then
		return playerFromName
	end

	local playersTable = getElementsByType("player")
	local partialNameLower = string.lower(partialName)

	for playerID = 1, #playersTable do
		local playerElement = playersTable[playerID]
		local playerName = getPlayerName(playerElement)
		local playerNameLower = string.lower(playerName)
		local playerNameWithoutColor = string.gsub(playerNameLower, "#%x%x%x%x%x%x", "")
		local playerFound = string.find(playerNameWithoutColor, partialNameLower, 1, true)

		if (playerFound) then
			return playerElement
		end
	end

	return false
end

function removeHex(stringToRemoveHexFrom)
	local removedHex = string.gsub(stringToRemoveHexFrom, "#%x%x%x%x%x%x", "")

	return removedHex
end

function getOrSetPlayerDelay(playerElement, delayID, delayTime)
	local validElement = isElement(playerElement)

	if (not validElement) then
		return false
	end

	local elementType = getElementType(playerElement)
	local playerType = (elementType == "player")

	if (not playerType) then
		return false
	end

	local playerDelayData = playerDelays[playerElement]

	if (not playerDelayData) then
		playerDelays[playerElement] = {}
		playerDelayData = playerDelays[playerElement]
	end

	local activeDelay = playerDelayData[delayID]
	local timeNow = getTickCount()

	if (activeDelay) then
		local delayPassed = (timeNow > activeDelay)

		if (not delayPassed) then
			return false
		end
	end

	local delayEndTime = (timeNow + delayTime)

	playerDelayData[delayID] = delayEndTime

	return true
end

function clearPlayersDelay()
	playerDelays[source] = nil
end
addEventHandler(isServer and "onPlayerQuit" or "onClientPlayerQuit", root, clearPlayersDelay)