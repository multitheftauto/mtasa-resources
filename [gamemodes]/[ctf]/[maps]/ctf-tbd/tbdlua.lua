function giveWeaponsOnSpawn ( spawnpoint, team )
	giveWeapon ( source, 4, 1 ) -- Gives the bleh weapon with 1 ammo
	giveWeapon ( source, 23, 80 ) --
	giveWeapon ( source, 30, 500 ) --
	giveWeapon ( source, 28, 700 ) --
end
addEventHandler ( "onPlayerSpawn", getRootElement(), giveWeaponsOnSpawn )
