local loadedPlayers = {}

addEventHandler("onPlayerResourceStart", root, function (startedResource)
	if startedResource ~= resource then return end
	if loadedPlayers[source] then return end
	
	loadedPlayers[source] = true
	if not getPlayerTeam(source) then --Check if its not playing
		exports.freecam:setPlayerFreecamEnabled(source) -- Start spectating
	end
	addEventHandler("onElementDataChange", source, protectPlayerElementData)
end)

addEventHandler("onPlayerQuit", root, function ()
	if loadedPlayers[source] then
		loadedPlayers[source] = nil
	end
	removeEventHandler("onElementDataChange", source, protectPlayerElementData)
end)

function getLoadedPlayers ()
	local players = {}
	for player, _ in pairs(loadedPlayers) do
		table.insert(players, player)
	end
	return players
end
