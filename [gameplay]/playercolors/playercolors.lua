local lowerBound, upperBound = unpack(get("color_range"))

function randomizePlayerColor(player)
	player = player or source
	local r, g, b = math.random(lowerBound, upperBound), math.random(lowerBound, upperBound), math.random(lowerBound, upperBound)
	setPlayerNametagColor(player, r, g, b)
end
addEventHandler("onPlayerJoin", root, randomizePlayerColor)

local function randomizeAllPlayerColors()
	for _, player in ipairs(getElementsByType("player")) do
		randomizePlayerColor(player)
	end
end
addEventHandler("onResourceStart", resourceRoot, randomizeAllPlayerColors)
addEventHandler("onGamemodeMapStart", root, randomizeAllPlayerColors) -- mapmanager resets player colors to white when the map ends

getPlayerColor = getPlayerNametagColor
getPlayerColour = getPlayerNametagColor