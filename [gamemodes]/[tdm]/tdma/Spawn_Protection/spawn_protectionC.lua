function playerDamageTaken ( attacker, weapon, bodypart )
	local sp = getElementData( getLocalPlayer(), "tdma.sp" )
	if ( sp == "y" ) then
		cancelEvent()
	end
end
addEventHandler ( "onClientPlayerDamage", getLocalPlayer(), playerDamageTaken )
