local useTeams = true
local blipSize = 2
local blipAlpha = 255
local color = {0, 255, 0}
local colors = {}
local blip = {}

function createPlayerBlip(plr)
	if (not plr or plr.type ~= "player") then return false end
	local r, g, b
	if useTeams then
		r, g, b = plr.team:getColor()
	else
		if (colors[plr]) then
			r, g, b = colors[plr][1], colors[plr][2], colors[plr][3]
		else
			r, g, b = color[1], color[2], color[3]
		end
	end
	if (blip[plr]) then
		blip[plr]:setColor(r, g, b, blipAlpha)
	else
		blip[plr] = createBlipAttachedTo(plr, 0, blipSize, r, g, b, blipAlpha)
	end
end

function setBlipColor(plr, _, r, g, b)
	if (tonumber(b)) then
		if (not colors[plr]) then
			colors[plr] = {}
		end
		colors[plr] = {r, g, b}
		createPlayerBlip(plr)
	end
end
addCommandHandler("setblipcolor", setBlipColor)

function setBlipsColor(_, _, r, g, b)
	if (tonumber(b)) then
		color = {tonumber(r), tonumber(g), tonumber(b)}
		for _, v in pairs(Element.getAllByType("player")) do
			createPlayerBlip(v)
		end
	end
end
addCommandHandler("setblipscolor", setBlipsColor)

function destroyPlayerBlip(plr)
	blip[plr]:destroy()
	blip[plr] = nil
	if (colors[plr]) then
		colors[plr] = nil
	end
end

function onPlayerQuit()
	destroyPlayerBlip(source)
end
addEventHandler("onPlayerQuit", root, onPlayerQuit)

function onPlayerWasted()
	destroyPlayerBlip(source)
end
addEventHandler("onPlayerWasted", root, onPlayerWasted)

function onPlayerSpawn()
	createPlayerBlip(source)
end
addEventHandler("onPlayerSpawn", root, onPlayerSpawn)

function onResourceStart()
	for _, plr in pairs(Element.getAllByType("player")) do
		createPlayerBlip(plr)
	end
end
addEventHandler("onResourceStart", resourceRoot, onResourceStart)
