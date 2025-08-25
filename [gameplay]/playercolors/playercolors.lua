local lowerBound, upperBound = unpack(get("color_range"))

local function randomizePlayerColor(player)
	player = player or source
	local r, g, b = math.random(lowerBound, upperBound), math.random(lowerBound, upperBound), math.random(lowerBound, upperBound)
	setPlayerNametagColor(player, r, g, b)
end
addEventHandler("onPlayerJoin", root, randomizePlayerColor)

local function setAllPlayerColors()
	for _, player in ipairs(getElementsByType("player")) do
		randomizePlayerColor(player)
	end
end
-- mapmanager resets player colors to white when the map ends
addEventHandler("onGamemodeMapStart", root, setAllPlayerColors)

local function handleResourceStartStop(res)
	if res == resource then
		setAllPlayerColors()
	end
end
addEventHandler("onResourceStart", root, handleResourceStartStop)
addEventHandler("onResourceStop", root, handleResourceStartStop)


