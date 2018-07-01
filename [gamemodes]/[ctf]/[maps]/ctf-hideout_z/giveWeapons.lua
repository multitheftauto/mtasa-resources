-- giveWeaponsOnSpawn for CTF: Hideout with zombies

function giveWeaponsOnSpawn (  )
	giveWeapon ( source, 25, 120 ) -- Gives the M4 weapon with 120 ammo
    	giveWeapon ( source, 24, 56 ) -- Gives the Desert Eagle weapon with 56 ammo
end
addEventHandler ( "onPlayerSpawn", getRootElement(), giveWeaponsOnSpawn )

function spawnWhenZombieKill(ammo,attacker)
    if attacker then
        if getElementType(attacker) == "ped" then
	        setTimer(respawnTheVictim,4500,1,source)
	    end
	end
end
addEventHandler("onPlayerWasted",getRootElement(),spawnWhenZombieKill)

function respawnTheVictim(player)
    local team = getPlayerTeam( player )
    local spawnpoints = getChildren ( team, "spawnpoint" )
	call(getResourceFromName("spawnmanager"), "spawnPlayerAtSpawnpoint", player, spawnpoints[ math.random( 1, #spawnpoints ) ] )
	--spawnPlayerAtSpawnpoint ( player, spawnpoints[ math.random( 1, #spawnpoints ) ] )
	local r,g,b = getTeamColor( team )
	setPlayerNametagColor ( player, r, g, b )
	setCameraTarget( player, player )
	toggleAllControls ( player, true, true, false )
end

function getChildren ( root, type )
	local elements = getElementsByType ( type )
	local result = {}
	for elementKey,elementValue in ipairs(elements) do
		if ( getElementParent( elementValue ) == root ) then
			result[ table.getn( result ) + 1 ] = elementValue
		end
	end
	return result
end
