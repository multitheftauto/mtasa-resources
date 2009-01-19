local localPlayer = getLocalPlayer()

local driveby_state = true

local function switchSlot()
        if ( not driveby_state ) then return end
	if isPedInVehicle( localPlayer ) then
		if getPedWeapon( localPlayer ) == 0 then
			setPedWeaponSlot( localPlayer, 4 )
		else
			setPedWeaponSlot( localPlayer, 0 )
		end
	end
end
bindKey( "mouse2", "down", switchSlot )

local function hideWeapon( player )
	setPedWeaponSlot( localPlayer, 0 )
end
addEventHandler( "onClientPlayerVehicleEnter", localPlayer, hideWeapon )

function toggleDriveby ( cmd, state )
  local _state = false
  outputChatBox ( "state: " .. tostring ( state ) )
  if ( state and tonumber(state) == 1 ) then _state = true end
  driveby_state = _state
end
addCommandHandler ( "toggledriveby", toggleDriveby, state )