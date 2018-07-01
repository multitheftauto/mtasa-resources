-- giveWeaponsOnSpawn for CTF: Bombsite Italy by Ratt

function giveWeaponsOnSpawn ( spawnpoint, team )
	giveWeapon ( source, 24, 112 ) -- Gives the Desert Eagle weapon with 112 ammo
	giveWeapon ( source, 25, 56 ) -- Gives the Desert Eagle weapon with 112 ammo
end
addEventHandler ( "onPlayerSpawn", getRootElement(), giveWeaponsOnSpawn )

function mapLoadTimeWeather (  )
	setTime ( 00, 0 )
	setWeather ( 11 )
end
addEventHandler ( "onResourceStart", getResourceRootElement(getThisResource()),mapLoadTimeWeather )
