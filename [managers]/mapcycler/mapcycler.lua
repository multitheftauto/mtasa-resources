rootElement = getRootElement()
local thisResourceRoot = getResourceRootElement(getThisResource())

local cycleMode
local cyclerFunction

addEventHandler("onResourceStart", thisResourceRoot,
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

addEvent "onRoundFinished"

remainingRounds = 0

function roundCounter()
	remainingRounds = remainingRounds - 1
	if remainingRounds == 0 then
		cyclerFunction()
	end
end

function outputCycler(message, toElement)
	local r, g, b = getColorFromString(string.upper(get("color")))
	outputChatBox(message, toElement or getRootElement(), r, g, b)
end

function outputCyclerDebugString(debugString, debugLevel)
	outputDebugString("Map cycler: "..debugString, debugLevel)
end
