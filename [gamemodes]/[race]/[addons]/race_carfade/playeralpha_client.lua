local playerAlpha = {}
playerAlpha.players = {}

function playerAlpha.updatePlayer(player)
	assert(isElement(player) and getElementType(player) == "player", "Argument #1 must be a player element.")
	playerAlpha.players[player] = tonumber(getElementData(player, "race.alpha")) or 255
end

function playerAlpha.initialize()
	for _, player in ipairs(getElementsByType("player")) do
		playerAlpha.updatePlayer(player)
	end
end
playerAlpha.initialize()

addEventHandler("onClientElementDataChange", root,
	function(changedKey)
		if getElementType(source) == "player" and changedKey == "race.alpha" then
			playerAlpha.updatePlayer(source)
		end
	end
)

addEventHandler("onClientPlayerQuit", root,
	function()
		playerAlpha.players[source] = nil
	end
)

function getPlayerMaxAlpha(player)
	return playerAlpha.players[player] or 255
end
