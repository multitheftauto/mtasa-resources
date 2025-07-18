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

addEventHandler("onVehicleExplode", root, function()
	for player in pairs(playersInBasicTest) do
		if isElement(player) then
			local vehicle = getPedOccupiedVehicle(player)
			if vehicle == source then
				cancelEvent()
			end
		end
	end
end)