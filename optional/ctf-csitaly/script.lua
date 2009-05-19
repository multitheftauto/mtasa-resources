-- giveWeaponsOnSpawn for CTF: CS Italy by Ratt

function init (  )
	giveWeapon ( source, 30, 120 ) -- Gives the AK47 weapon with 120 ammo
    giveWeapon ( source, 24, 56 ) -- Gives the Desert Eagle weapon with 56 ammo
	
	createWater ( 685, -2420, 105, 700, -2420, 105, 685, -2350, 105, 700, -2350, 105 )
end
addEventHandler ( "onPlayerSpawn", getRootElement(), init )