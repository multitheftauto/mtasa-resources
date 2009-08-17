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

local function spawnAllPlayers()
	for i,player in ipairs(getElementsByType"player") do
		processPlayerSpawn ( player )
	end
end

function processSpawnStart(delay)
	currentSpawnKey = 0
	--Grab our spawnpoints
	g_Spawnpoints = getElementsByType("spawnpoint", g_MapRoot or g_Root )
	--Randomize our spawnpoint order
	table.shuffle(g_Spawnpoints)
	--Calculate our camera position, by grabbing an average spawnpoint position
	local camX,camY,camZ = 0,0,0
	for i,spawnpoint in ipairs(g_Spawnpoints) do
		camX,camY,camZ = camX + getElementData(spawnpoint,"posX"), camY + getElementData(spawnpoint,"posY"), camZ + getElementData(spawnpoint,"posZ")
	end
	camX,camY,camZ = camX/#g_Spawnpoints, camY/#g_Spawnpoints, camZ/#g_Spawnpoints + 30
	--Use a random spawnpoint as the target
	local lookX,lookY,lookZ = getElementData(g_Spawnpoints[1],"posX"), getElementData(g_Spawnpoints[1],"posY"), getElementData(g_Spawnpoints[1],"posZ")
	for i,player in ipairs(getElementsByType"player") do
		setCameraMatrix ( player, camX,camY,camZ,lookX,lookY,lookZ )
	end
	setTimer ( spawnAllPlayers, delay, 1 )
end

function processPlayerSpawn ( player )
	player = player or source
	if not isElement(player) then return end
	if not getElementData ( player, "Score" ) then
		setElementData ( player, "Score", 0 )
	end
	currentSpawnKey = currentSpawnKey + 1
	currentSpawnKey = g_Spawnpoints[currentSpawnKey] and currentSpawnKey or 1
	exports.spawnmanager:spawnPlayerAtSpawnpoint ( player, g_Spawnpoints[currentSpawnKey] )
	giveWeapon ( player, 22, 100, true )
	fadeCamera(player,true)
	setCameraTarget(player,player)
end
addEventHandler ( "onPlayerJoin", g_Root, processPlayerSpawn )

addCommandHandler ( "kill", killPed )
