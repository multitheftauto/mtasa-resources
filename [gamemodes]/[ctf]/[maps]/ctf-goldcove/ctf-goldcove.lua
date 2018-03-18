function onResourceStart( resourcename )
	if ( resourcename == getThisResource () ) then
		createPickup ( 2514.5061035156, 6305.181640625, 5.0202980041504, 2, 34, 120000, 15 )
		createPickup ( 2491.2346191406, 6230.4038085938, 11.139559745789, 2, 29, 60000, 60 )
		createPickup ( 2405.9069824219, 6250.0205078125, 20.469413757324, 2, 29, 60000, 60 )
		createPickup ( 2302.94921875, 6354.419921875, 14.974449157715, 2, 23, 60000, 100 )
		createPickup ( 2263.3723144531, 6305.6982421875, 8.7897481918335, 2, 24, 60000, 50 )
		createPickup ( 2468.2373046875, 6182.1215820313, 17.950647354126, 2, 23, 60000, 100 )
		createPickup ( 2428.9958496094, 6190.1997070313, 10.169717788696, 2, 24, 60000, 50 )
		setTime( 07, 00 )
		setTimer( setTime, 610000, 0, 07, 00 )
	end
end

function onPlayerSpawn ()
	giveWeapon ( source, 6, 1 )
	giveWeapon ( source, 22, 10000 )
	giveWeapon ( source, 22, 10000, true )
	giveWeapon ( source, 25, 50 )
	giveWeapon ( source, 30, 60 )
	giveWeapon ( source, 18, 2 )
end

addEventHandler ( "onResourceStart", getRootElement(), onResourceStart )
addEventHandler ( "onPlayerSpawn", getRootElement(), onPlayerSpawn )
