local blipContainer

local defaultColor     = {0,255,0}
local playerBlips      = {}

function prepareBlips()
	-- Create a container for the blips, so they won't be listed as map objects
	blipContainer = createElement("blipContainer")
	setElementParent(blipContainer,root)

	-- Now create a blip for everyone on the server
	createAllPlayerBlips()
end
addEventHandler("onResourceStart",resourceRoot,function() setTimer(prepareBlips,1000,1) end)

function createAllPlayerBlips()
	for index,player in ipairs(getElementsByType("player")) do
		createPlayerBlip(player)
	end
end

function checkColor(c)
	return c and type(c)=="number" and c >= 0 and c <= 255
end

function createPlayerBlip(player,size,r,g,b,a)
	if blipContainer and isElement(player) and getElementType(player)=="player" and not playerBlips[player] then
		size = size and tonumber(size) or 2

		local colorR, colorG, colorB, colorA

		if checkColor(r) and checkColor(g) and checkColor(b) then
			colorR, colorG, colorB = r, g, b
		else
			colorR, colorG, colorB = getPlayerNametagColor(player)
		end

		colorA = colorA and tonumber(colorA) or 255

		local blip = createBlipAttachedTo(player,0,size,colorR,colorG,colorB,colorA)
			setElementParent(blip,blipContainer)

		addEventHandler("onElementDestroy",blip,handleBlipDestruction)

		playerBlips[player] = blip

		return blip
	end

	return false
end

function destroyPlayerBlip(player)
	if isElement(player) and getElementType(player)=="player" and playerBlips[player] then
		setElementData(playerBlips[player],"forcedestruction",true,false)
		return destroyElement(playerBlips[player])
	end

	return false
end

function getPlayerBlip(player)
	if isElement(player) and getElementType(player)=="player" and playerBlips[player] then
		return playerBlips[player]
	end

	return false
end

function getPlayerBlipColor(player)
	if isElement(player) and getElementType(player)=="player" and playerBlips[player] then
		return getBlipColor(playerBlips[player])
	end

	return false
end

function getPlayerBlipSize(player)
	if isElement(player) and getElementType(player)=="player" and playerBlips[player] then
		return getBlipSize(playerBlips[player])
	end

	return false
end

function setPlayerBlipColor(player,r,g,b,a)
	if isElement(player) and getElementType(player)=="player" and playerBlips[player] and checkColor(r) and checkColor(g) and checkColor(b) then
		a = a and tonumber(a) or 255
		return setBlipColor(playerBlips[player],r,g,b,a)
	end

	return false
end

function setPlayerBlipSize(player,size)
	if isElement(player) and getElementType(player)=="player" and playerBlips[player] and size and type(size)=="number" and size > 0 then
		return setBlipSize(playerBlips[player], size)
	end

	return false
end

function handleBlipDestruction()
	for player,blip in pairs(playerBlips) do
		if source == blip then
			playerBlips[player] = nil
			return
		end
	end
end

function blipCreate()
	createPlayerBlip(source)
end
addEventHandler("onPlayerSpawn",root,blipCreate)

function blipDestroy()
	destroyPlayerBlip(source)
end
addEventHandler("onPlayerQuit",root,blipDestroy)
addEventHandler("onPlayerWasted",root,blipDestroy)
