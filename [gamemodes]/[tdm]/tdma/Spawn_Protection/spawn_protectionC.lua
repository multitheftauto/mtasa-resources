function playerDamageTaken ( attacker, weapon, bodypart )
	local sp = getElementData( localPlayer, "tdma.sp" )
	if ( sp == "y" ) then
		cancelEvent()
	end
end
addEventHandler ( "onClientPlayerDamage", localPlayer, playerDamageTaken )
