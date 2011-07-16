local root = getRootElement()
local MAX_DIST = 300
local color = {255, 0, 0}
local blips = {}
local resourceRoot = getResourceRootElement(getThisResource())

function onPlayerSpawn_blips(spawnpoint)
	addBlip(source)
end

function onPlayerQuit_blips()
	removeBlip(source)
end

function onPlayerWasted_blips(totalammo, killer, killerweapon)
	removeBlip(source)
end

addEventHandler("onPlayerSpawn", root, onPlayerSpawn_blips)
addEventHandler("onPlayerQuit", root, onPlayerQuit_blips)
addEventHandler("onPlayerWasted", root, onPlayerWasted_blips)

function addBlip(player)
	if (blips[player]) then
		destroyElement(blips[player])
		blips[player] = nil
	end
	local r, g, b = color[1], color[2], color[3]
	local team = getPlayerTeam(player)
	if (team) then
		local a, b, c = getTeamColor(team)
		-- sometimes it says team arg is invalid for some reason.. so in that case let's set the default colors
		r = a or color[1]
		g = b or color[2]
		b = c or color[3]
	end
	blips[player] = createBlip(0, 0, 0, 0, 2, r, g, b, 255, 0, MAX_DIST)
	attachElements(blips[player], player)
end

function removeBlip(player)
	if (blips[player]) then
		destroyElement(blips[player])
		blips[player] = nil
	end
end
