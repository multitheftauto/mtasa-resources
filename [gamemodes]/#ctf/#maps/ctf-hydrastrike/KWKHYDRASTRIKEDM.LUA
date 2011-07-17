function onPlayerSpawn ()
	giveWeapon ( source, 16, 5 )
	giveWeapon ( source, 25, 100 )
	giveWeapon ( source, 28, 500, true )
	giveWeapon ( source, 35, 1 )
	giveWeapon ( source, 44, 1 )
	giveWeapon ( source, 31, 500 )
end

addEventHandler ( "onResourceStart", getRootElement(), onResourceStart )
addEventHandler ( "onPlayerSpawn", getRootElement(), onPlayerSpawn )