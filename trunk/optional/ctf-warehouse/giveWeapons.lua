-- giveWeaponsOnSpawn for CTF: CS Italy by Ratt

function giveWeaponsOnSpawn (  )
	giveWeapon ( source, 31, 120 ) -- Gives the M4 weapon with 120 ammo
    	giveWeapon ( source, 24, 56 ) -- Gives the Desert Eagle weapon with 56 ammo
end
addEventHandler ( "onPlayerSpawn", getRootElement(), giveWeaponsOnSpawn )