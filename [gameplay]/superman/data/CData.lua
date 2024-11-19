local function onClientSupermanSync(supermanServerData)
	syncSupermansData(supermanServerData)
end
addEvent("onClientSupermanSync", true)
addEventHandler("onClientSupermanSync", localPlayer, onClientSupermanSync)

local function onClientSupermanSetData(dataKey, dataValue)
	setSupermanData(source, dataKey, dataValue)
end
addEvent("onClientSupermanSetData", true)
addEventHandler("onClientSupermanSetData", root, onClientSupermanSetData)