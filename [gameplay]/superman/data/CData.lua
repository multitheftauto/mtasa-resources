local function onClientSupermanSync(supermanServerData)
	syncSupermansData(supermanServerData)
end
if (not SUPERMAN_USE_ELEMENT_DATA) then
	addEvent("onClientSupermanSync", true)
	addEventHandler("onClientSupermanSync", localPlayer, onClientSupermanSync)
end

local function onClientSupermanSetData(dataKey, dataValue)
	setSupermanData(source, dataKey, dataValue)
end
if (not SUPERMAN_USE_ELEMENT_DATA) then
	addEvent("onClientSupermanSetData", true)
	addEventHandler("onClientSupermanSetData", root, onClientSupermanSetData)
end