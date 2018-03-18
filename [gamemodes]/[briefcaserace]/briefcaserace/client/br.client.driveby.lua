addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()),
function (resource)
	exports.realdriveby:setDriverDrivebyAbility()
	exports.realdriveby:setPassengerDrivebyAbility(22, 28, 29, 32)
end
)

--[[
local lastSeat = 0

function toggleDriveBy()
		-- check if guy is in vehicle
		if (not isPedInVehicle(localPlayer)) then
			return
		end
		-- check if guy is passenger
		if (lastSeat == 0) then
			return
		end
		-- check if guy has ammo for slot 4 weapon
		if (getPedTotalAmmo(localPlayer, 4) == 0) then
			return
		end
		-- Stolen from wiki --
		----------------------
        -- we check if local player isn't currently doing a gang driveby
        if not isPedDoingGangDriveby ( getLocalPlayer () ) then
                -- if he got driveby mode off, turn it on
                setPedWeaponSlot ( getLocalPlayer (), 4 )
                setPedDoingGangDriveby ( getLocalPlayer (), true )
        else
                -- otherwise, turn it off
                setPedWeaponSlot ( getLocalPlayer (), 0 )
                setPedDoingGangDriveby ( getLocalPlayer (), false )
        end
		----------------------
end

bindKey("mouse2", "down", toggleDriveBy)

addEventHandler("onClientPlayerVehicleEnter", localPlayer,
function (veh, seat)
	lastSeat = seat
end
)
]]
