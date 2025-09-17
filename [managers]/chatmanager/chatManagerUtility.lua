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

function removeStringHEX(stringText)
	local stringSavedLength

	repeat
		stringSavedLength = utf8.len(stringText)
		stringText = string.gsub(stringText, "#%x%x%x%x%x%x", "")
	until utf8.len(stringText) == stringSavedLength

	return stringText
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
addEventHandler("onPlayerQuit", root, clearPlayersDelay)