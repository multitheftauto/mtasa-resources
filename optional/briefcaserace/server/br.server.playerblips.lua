-- messily modified version of playerblips
root = getRootElement ()
MAX_DIST = 300
color = { 255, 0, 0 }
blips = {}
resourceRoot = getResourceRootElement ( getThisResource () )

function onResourceStart ( resource )
  	for id, player in ipairs( getElementsByType ( "player" ) ) do
		if (not isPedDead(player)) then
			local r, g, b = color[1], color[2], color[3]
			local team = getPlayerTeam(player)
			if (team) then
				r, g, b = getTeamColor(team)
			end
			blips[player] = createBlipAttachedTo ( player, 0, 2, r, g, b, 255, 0, MAX_DIST )
		end
	end
end

function onPlayerSpawn ( spawnpoint )
	local r, g, b = color[1], color[2], color[3]
	local team = getPlayerTeam(source)
	if (team) then
		r, g, b = getTeamColor(team)
	end
	createBlipAttachedTo ( source, 0, 2, r, g, b, 255, 0, MAX_DIST )
end

function onPlayerQuit ()
	if (blips[source]) then
		destroyElement(blips[source])
		blips[source] = nil
	end
end

function onPlayerWasted ( totalammo, killer, killerweapon )
	if (blips[source]) then
		destroyElement(blips[source])
		blips[source] = nil
	end
end

addEventHandler ( "onResourceStart", resourceRoot, onResourceStart )
addEventHandler ( "onPlayerSpawn", root, onPlayerSpawn )
addEventHandler ( "onPlayerQuit", root, onPlayerQuit )
addEventHandler ( "onPlayerWasted", root, onPlayerWasted )
