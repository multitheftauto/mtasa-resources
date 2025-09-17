-- #######################################
-- ## Project: Glue						##
-- ## Author: MTA contributors			##
-- ## Version: 1.3.1					##
-- #######################################

local playerDelays = {}

function getOrSetPlayerDelay(playerElement, delayID, delayTime)
	local playerType = isElementType(playerElement, "player")

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