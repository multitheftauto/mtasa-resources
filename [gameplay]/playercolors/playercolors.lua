local lowerBound, upperBound = unpack(get("color_range"))
local usedColors = {}

local function generateColor()
	local r, g, b
	repeat
		r = math.random(lowerBound, upperBound)
		g = math.random(lowerBound, upperBound)
		b = math.random(lowerBound, upperBound)
	until (r + g + b) > 200
	return r, g, b
end

local function colorToKey(r, g, b)
	return r .. "," .. g .. "," .. b
end

local function randomizePlayerColor(player)
	player = player or source
	if not isElement(player) then return end

	local r, g, b, key
	for i = 1, 10 do
		r, g, b = generateColor()
		key = colorToKey(r, g, b)
		if not usedColors[key] then
			break
		end
	end

	local oldR, oldG, oldB = getPlayerNametagColor(player)
	if oldR then
		usedColors[colorToKey(oldR, oldG, oldB)] = nil
	end

	setPlayerNametagColor(player, r, g, b)
	usedColors[key] = true
end

addEventHandler("onPlayerJoin", root, randomizePlayerColor)

local function setAllPlayerColors()
	usedColors = {}
	for _, player in ipairs(getElementsByType("player")) do
		randomizePlayerColor(player)
	end
end

addEventHandler("onGamemodeMapStart", root, setAllPlayerColors)
addEventHandler("onResourceStart", resourceRoot, setAllPlayerColors)

addEventHandler("onPlayerQuit", root,
	function()
		local r, g, b = getPlayerNametagColor(source)
		if r then
			usedColors[colorToKey(r, g, b)] = nil
		end
	end
)
