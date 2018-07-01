--[[Specifications for MTASA Deathmatch-type gamemodes

After having some deep thoughts about it, I'm fairly confident we should do them as following:

There should be three new, or reworked gamemodes, replacing modes like tdma and cdm, and to some extent freeroam.
Short list and description of these gamemodes:
- deathmatch - a new gamemode, it doesn't have a counterpart in current or previous sets of resources/gamemodes.
The aim of this mode is simple - no teams, free for all, whoever hits the fraglimit, or has the most frags by the time map ends, wins.
This Gamemode is meant for relatively smaller servers (up to 16 players), but if proper maps are made and used, could be more as well. Should be mostly a foot-based gamemode with pickups, utilising custom maps scheme the most.

- team deathmatch - this should obviously replace tdma, either it should be an 'updated tdma', or rewritten from scratch.
Aim of the mode - there is a number of teams, depending on the map loaded; a team is considered a winner when either it has the most frags after the time for map runs out, or if it hits the fraglimit as the first team - depending on gamemode settings.

- some yet unnamed, freeroaming deathmatch gamemode - could be based on fmjdm and in some parts on freeroam; should replace cdm. As the name implies, it's a freeroaming gamemode, similar to classic mtavc's gamemodes, or sa-mp's lvdm. Made mostly for bigger servers (16+ players), should utilise vehicles more/much more than modes mentioned above. Could be also used to replace the popular freeroam gamemode with it.


The reason to have them split into several gamemodes rather than keeping them into one is to keep it simplified, make it easy to differentiate between these modes in server browser, or when looking for maps for one.]]
do
        local random = math.random

        function table.shuffle(t)
                local n = #t

                while n > 1 do
                        local k = random(n)
                        n = n - 1
                        t[n], t[k] = t[k], t[n]
                end

                return t
        end
end

local currentSpawnKey = 0
local g_Spawnpoints

function processSpawnStart()
	--Grab our spawnpoints
	g_Spawnpoints = getElementsByType("spawnpoint", g_MapRoot or g_Root )
	--Randomize our spawnpoint order
	table.shuffle(g_Spawnpoints)
	for i,player in ipairs(getElementsByType"player") do
		setCameraMatrix ( player, -2377, -1636, 700, 0, 0, 720 )
		fadeCamera(player, true )
		exports.teammanager:handlePlayer ( player, teams, "Team Deathmatch" )
	end
end

function processPlayerSpawn ( player )
	player = player or source
	if not getElementData ( player, "Score" ) then
		setElementData ( player, "Score", 0 )
	end
	currentSpawnKey = currentSpawnKey + 1
	currentSpawnKey = g_Spawnpoints[currentSpawnKey] and currentSpawnKey or 1
	if (not exports.spawnmanager:spawnPlayerAtSpawnpoint ( player, g_Spawnpoints[currentSpawnKey] )) then
		outputDebugString("Player " .. tostring(getPlayerName(player)) .. " Did not spawn due to a spawnmanager error.")
	else
		outputDebugString("Player " .. tostring(getPlayerName(player)) .. " Spawned.")
	end
	giveWeapon ( player, 22, 100, true )
	fadeCamera(player,true)
	setCameraTarget(player,player)

end


addCommandHandler ( "kill", killPed )
