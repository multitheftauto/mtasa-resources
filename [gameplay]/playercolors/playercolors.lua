local lowerBound, upperBound = unpack(get("color_range"))

function randomizePlayerColor(player)
	player = player or source
	local r, g, b = math.random(lowerBound, upperBound), math.random(lowerBound, upperBound), math.random(lowerBound, upperBound)
	setPlayerNametagColor(player, r, g, b)
end
addEventHandler("onPlayerJoin", root, randomizePlayerColor)

local function setAllPlayerColors()
	for _, player in ipairs(getElementsByType("player")) do
		if eventName == "onResourceStop" then
			setPlayerNametagColor(player, false)
		else
			randomizePlayerColor(player)
		end
	end
end
addEventHandler("onResourceStart", resourceRoot, setAllPlayerColors)
addEventHandler("onGamemodeMapStart", root, setAllPlayerColors) -- mapmanager resets player colors to white when the map ends
addEventHandler("onResourceStop", resourceRoot, setAllPlayerColors)

getPlayerColor = getPlayerNametagColor
getPlayerColour = getPlayerNametagColor
