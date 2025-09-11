local playerDelays = {}

---@diagnostic disable: undefined-global

function getPlayerNickname(playerElement)
	local playerName = getPlayerName(playerElement)

	if (CHAT_MANAGER_REMOVE_HEX) then
		local playerNickname = string.gsub(playerName, "#%x%x%x%x%x%x","")

		return playerNickname
	end

	return playerName
end

function removeStringHEX(stringToRemoveHEX)
	local stringSavedLength = false
	local stringLengthMatching = false

	while (not stringLengthMatching) do
		stringSavedLength = utf8.len(stringToRemoveHEX)
		stringToRemoveHEX = string.gsub(stringToRemoveHEX, "#%x%x%x%x%x%x", "")

		local stringLengthNow = utf8.len(stringToRemoveHEX)

		stringLengthMatching = (stringLengthNow == stringSavedLength)
	end

	return stringToRemoveHEX
end

function getOrSetPlayerDelay(playerElement, delayID, delayTime)
	local playerType = isElement(playerElement)

	if (not playerType) then
		return false
	end

	local playerDelayData = playerDelays[playerElement]

	if (not playerDelayData) then
		playerDelays[playerElement] = {}
		playerDelayData = playerDelays[playerElement]
	end

	local timeNow = getTickCount()
	local playerActiveDelay = playerDelayData[delayID]

	if (playerActiveDelay) then
		local playerDelayPassed = (timeNow > playerActiveDelay)

		if (not playerDelayPassed) then
			return false
		end
	end

	local playerDelayNewTime = (timeNow + delayTime)

	playerDelayData[delayID] = playerDelayNewTime

	return true
end

local function clearPlayersDelay()
	playerDelays[source] = nil
end
addEventHandler(IS_SERVER and "onPlayerQuit" or "onClientPlayerQuit", root, clearPlayersDelay)