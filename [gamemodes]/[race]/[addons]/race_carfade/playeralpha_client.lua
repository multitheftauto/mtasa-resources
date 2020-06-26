local maximumAlphas = {}
maximumAlphas.players = {}
maximumAlphas.vehicles = {}

function maximumAlphas.updatePlayer(player)
	assert(isElement(player) and getElementType(player) == "player", "Argument #1 must be a player element.")
	maximumAlphas.players[player] = tonumber(getElementData(player, "race.alpha")) or nil
end

function maximumAlphas.updateVehicle(vehicle)
	assert(isElement(vehicle) and getElementType(vehicle) == "vehicle", "Argument #1 must be a vehicle element.")
	maximumAlphas.vehicles[vehicle] = isElement(vehicle) and tonumber(getElementData(vehicle, "race.alpha")) or nil
end

function maximumAlphas.initialize()
	for _, player in ipairs(getElementsByType("player")) do
		maximumAlphas.updatePlayer(player)
		local playerVehicle = getPedOccupiedVehicle(player)
		if playerVehicle then
			maximumAlphas.updateVehicle(playerVehicle)
		end
	end
end
maximumAlphas.initialize()

addEventHandler("onClientElementDataChange", root,
	function(changedKey)
		if changedKey == "race.alpha" then
			local sourceType = getElementType(source)
			if sourceType == "player" then
				maximumAlphas.updatePlayer(source)
			elseif sourceType == "vehicle" then
				maximumAlphas.updateVehicle(source)
			end
		end
	end
)

addEventHandler("onClientPlayerQuit", root,
	function()
		maximumAlphas.players[source] = nil
	end
)

addEventHandler("onClientElementDestroy", root,
	function()
		if getElementType(source) == "vehicle" then
			maximumAlphas.vehicles[source] = nil
		end
	end
)

function getPlayerMaxAlpha(player)
	return maximumAlphas.players[player] or 255
end

function getVehicleMaxAlpha(vehicle)
	return maximumAlphas.vehicles[vehicle] or 255
end
