local playersInBasicTest = {}

addEvent("onBasicTestStart", true)
addEventHandler("onBasicTestStart", root, function()
	if client and client ~= source then
		return
	end
	playersInBasicTest[source] = true
end)

addEvent("onBasicTestEnd", true)
addEventHandler("onBasicTestEnd", root, function()
	if client and client ~= source then
		return
	end
	playersInBasicTest[source] = nil
end)

addEventHandler("onPlayerQuit", root, function()
	playersInBasicTest[source] = nil
end)

addDebugHook("preFunction", function(sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ...)
	if functionName == "blowVehicle" then
		for player, _ in pairs(playersInBasicTest) do
			if isElement(player) then
				return "skip"
			end
		end
	end
end, {"blowVehicle"})