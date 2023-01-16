local cycleMode
local cyclerFunction

addEventHandler("onResourceStart", resourceRoot,
	function()
		cycleMode = get("mode")
		local startFunction = _G["startCycler_"..cycleMode]
		if startFunction then
			startFunction()
		else
			error("Cycler mode '"..cycleMode.."' not supported.")
		end
		cyclerFunction = _G["cycleMap_"..cycleMode]
	end
)

addEvent("onRoundFinished")

remainingRounds = 0

function roundCounter()
	remainingRounds = remainingRounds - 1
	if remainingRounds == 0 then
		-- if no players are present, wait until a player joins to cycle
		if #getElementsByType("player") == 0 and (get("*hibernate_when_empty") == "true" or cycleMode == "vote") then
			addEventHandler("onPlayerJoin", root, cycleOnJoin)
			outputDebugString("mapcycler: server empty; hibernating until a player joins")
		else
			cyclerFunction()
		end
	end
end

function cycleOnJoin()
	cyclerFunction()
	removeEventHandler("onPlayerJoin", root, cycleOnJoin)
end

function outputCycler(message, toElement)
	local r, g, b = getColorFromString(string.upper(get("color")))
	outputChatBox(message, toElement or root, r, g, b)
end

function outputCyclerDebugString(debugString, debugLevel)
	outputDebugString("Map cycler: "..debugString, debugLevel)
end
