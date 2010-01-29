local cachedGamemodeList
local recacheInterval = 5000 --ms
local lastRecacheTime = 0


function getCachedGamemodeList()
	if getTickCount() - lastRecacheTime > recacheInterval then
		cachedGamemodeList = getGamemodes()
		lastRecacheTime = getTickCount()
	end
	return cachedGamemodeList
end
