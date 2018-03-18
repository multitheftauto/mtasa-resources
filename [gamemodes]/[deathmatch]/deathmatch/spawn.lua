local stats = {
	[69]=900,
	[70]=999,
	[71]=999,
	[72]=999,
	[73]=900,
	[74]=999,
	[75]=900,
	[76]=999,
	[77]=999,
	[78]=999,
	[79]=999,
	[160]=999,
	[225]=999,
	[229]=999,
	[230]=999
}

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
	camX,camY,camZ = 0,0,0
	for i,spawnpoint in ipairs(g_Spawnpoints) do
		camX,camY,camZ = camX + getElementData(spawnpoint,"posX"), camY + getElementData(spawnpoint,"posY"), camZ + getElementData(spawnpoint,"posZ")
	end
	camX,camY,camZ = camX/#g_Spawnpoints, camY/#g_Spawnpoints, camZ/#g_Spawnpoints + 30
	--Use a random spawnpoint as the target
	lookX,lookY,lookZ = getElementData(g_Spawnpoints[1],"posX"), getElementData(g_Spawnpoints[1],"posY"), getElementData(g_Spawnpoints[1],"posZ")
	for i,player in ipairs(getElementsByType"player") do
		setCameraMatrix ( player, camX,camY,camZ,lookX,lookY,lookZ )
	end
	setTimer ( spawnAllPlayers, delay, 1 )
end

function processPlayerSpawn ( player )
	player = player or source
	if not isElement(player) then return end
	setStats ( player )
	if not getElementData ( player, "Score" ) then
		setElementData ( player, "Score", 0 )
	end
	currentSpawnKey = currentSpawnKey + 1
	currentSpawnKey = g_Spawnpoints[currentSpawnKey] and currentSpawnKey or 1
	exports.spawnmanager:spawnPlayerAtSpawnpoint ( player, g_Spawnpoints[currentSpawnKey] )
	for weapon,ammo in pairs(g_Weapons) do
		giveWeapon ( player, weapon, ammo, true )
	end
	fadeCamera(player,true)
	setCameraTarget(player,player)

	-- Remove the respawn timer
	for i, timer in ipairs(mapTimers) do
		if (timer == sourceTimer) then
			table.remove(mapTimers, i)
			break
		end
	end
end
addEventHandler ( "onPlayerJoin", g_Root, processPlayerSpawn )

function setStats ( player )
	for statID,value in pairs(stats) do
		setPedStat ( player, statID, value )
	end
end
