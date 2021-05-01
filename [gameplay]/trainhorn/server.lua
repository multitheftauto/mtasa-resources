function syncHorn(trainDriver, train)

	local x, y, z = getElementPosition(trainDriver)
	local nearbyPlayers = getElementsWithinRange(x, y, z, 250, "player")

	for _, p in ipairs(nearbyPlayers) do
		triggerClientEvent(p, "onPlaySyncedHorn", p, train, x, y, z)
	end
end
addEvent("onSyncHorn", true)
addEventHandler("onSyncHorn", resourceRoot, syncHorn)