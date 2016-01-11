local useTeams = get("use_team_colors")
local blipSize = get("blip_size")
local blipAlpha = get("blip_alpha")
local color = get("blip_color")
local colors = {}
local blip = {}

if (useTeams == "true") then
	useTeams = true
else
	useTeams = false
end

function createPlayerBlip(plr)
	if (not plr or not isElement(plr) or plr.type ~= "player") then return false end
	local r, g, b
	if useTeams and plr.team then
		r, g, b = plr.team:getColor()
	elseif (colors[plr]) then
		r, g, b = colors[plr][1], colors[plr][2], colors[plr][3]
	else
		r, g, b = color[1], color[2], color[3]
	end
	if (blip[plr]) then
		blip[plr]:setColor(r, g, b, blipAlpha)
	else
		blip[plr] = Blip.createAttachedTo(plr, 0, blipSize, r, g, b, blipAlpha)
	end
end

function setBlipColor(plr, _, r, g, b)
	if (useTeams) then return end
	if (tonumber(b)) then
		colors[plr] = {r, g, b}
		createPlayerBlip(plr)
	end
end
addCommandHandler("setblipcolor", setBlipColor)

function setBlipsColor(_, _, r, g, b)
	if (useTeams) then return end
	if (tonumber(b)) then
		color = {tonumber(r), tonumber(g), tonumber(b)}
		for i, plr in ipairs(Element.getAllByType("player")) do
			createPlayerBlip(plr)
		end
	end
end
addCommandHandler("setblipscolor", setBlipsColor)

function destroyPlayerBlip(plr)
	blip[plr]:destroy()
	blip[plr] = nil
	colors[plr] = nil
end

function destroyBlipForSource()
	destroyPlayerBlip(source)
end
addEventHandler("onPlayerQuit", root, destroyBlipForSource)
addEventHandler("onPlayerWasted", root, destroyBlipForSource)

function onPlayerSpawn()
	createPlayerBlip(source)
end
addEventHandler("onPlayerSpawn", root, onPlayerSpawn)

function onResourceStart()
	for i, plr in ipairs(Element.getAllByType("player")) do
		createPlayerBlip(plr)
	end
end
addEventHandler("onResourceStart", resourceRoot, onResourceStart)
