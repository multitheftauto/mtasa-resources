setWaveHeight(0)
function giveWeaponsOnSpawn ( spawnpoint, team )
	giveWeapon ( source, 4, 1 ) -- Gives the bleh weapon with 1 ammo
	giveWeapon ( source, 23, 80 ) --
	giveWeapon ( source, 30, 500 ) --
	giveWeapon ( source, 28, 700 ) --

end
addEventHandler ( "onPlayerSpawn", getRootElement(), giveWeaponsOnSpawn )

function mapLoadChatBoxOutput (  )
      outputChatBox ( "CTF-Canals by Iggy", root, 255, 255, 255 )
	setTime ( 00, 0 )
	setWeather ( 11 )
end
