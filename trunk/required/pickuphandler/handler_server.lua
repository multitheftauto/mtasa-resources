addEventHandler ( "onPickupHit", root, 
	function ( player )
		if ( not isPlayerInVehicle ( player ) ) then
			if ( getPickupType ( source ) == 2 ) then
				local p_weapon = getPickupWeapon ( source )
				local weapon = getPlayerWeapon ( player ) --Save some bandwidth if they have this weapon already
				local p_slot = getSlotFromWeapon ( p_weapon )
				if p_slot ~= 0 and p_slot ~= 12 and weapon ~= p_weapon then
					triggerClientEvent ( player, "ph_onClientPickupHit", source )
					cancelEvent ()
				end
			end
		end
	end 
)

addEvent ( "ph_onPlayerPickupAccept", true )
addEventHandler ( "ph_onPlayerPickupAccept", root,
	function ( player )
		usePickup ( source, player )
		playSoundFrontEnd ( player, 18 )
	end 
)