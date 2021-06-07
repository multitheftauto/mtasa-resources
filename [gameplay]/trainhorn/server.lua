local spam = {}

function syncHorn()
	local vehicle = getPedOccupiedVehicle(client)
	if vehicle and getVehicleType(vehicle) == "Train" and getVehicleController(vehicle) == client then
		if spam[client] and getTickCount() - spam[client] < 5000 then return end
		local x, y, z = getElementPosition(client)
		local nearbyPlayers = getElementsWithinRange(x, y, z, 250, "player")
		spam[client] = getTickCount()

		triggerClientEvent(nearbyPlayers, "onPlaySyncedHorn", client, vehicle, x, y, z)
	end
end
addEvent("onSyncHorn", true)
addEventHandler("onSyncHorn", root, syncHorn)

function quitHandler()
	spam[source] = nil
end
addEventHandler("onPlayerQuit", root, quitHandler)
