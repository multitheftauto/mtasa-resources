local cachedGamemodeList
local recacheInterval = 5000 --ms

local function recacheGamemodeList()
	cachedGamemodeList = getGamemodes()
end

addEventHandler("onResourceStart", getResourceRootElement(getThisResource()),
	function ()
		setTimer(recacheGamemodeList, recacheInterval,0)
	end
)

function getCachedGamemodeList()
	return cachedGamemodeList
end
