-- This script catches vehicle damage-by-weapon events from the client and triggers the onVehicleNonWeaponDamage event when for vehicle damage that wasn't done by a weapon.
-- How it works: after receiving damage-by-weapon event, wait MAX_IGNORE_TIME. If onVehicleDamage is triggered in that time, ignore the event.
--    This is a hacky way to ignore vehicle damage done by weapons, but should be good enough for our purposes.

local vehiclesJustRepaired = {}
local JUST_REPAIRED_TIMEOUT = 1000

local MAX_IGNORE_TIME = 500
local MAX_IGNORE_LOSS = 305

local root = getRootElement()

local lastWeaponDamageTick = 0

addEvent("onVehicleDamageFromWeapon", true) -- triggered by client, caught here
addEvent("onVehicleNonWeaponDamage", false) -- triggered here, caught by server.game

-- d event
addEventHandler("onVehicleDamage", root,
function (loss)
	local curTick = getTickCount()
	if (vehiclesJustRepaired[source]) then
		debugMessage("Vehicle damage detected (" .. loss .. ") but vehicle was just repaired - ignoring. [" .. curTick .. "]")
	elseif (curTick - lastWeaponDamageTick < MAX_IGNORE_TIME and loss < MAX_IGNORE_LOSS) then
		debugMessage("Vehicle damage detected (" .. loss .. ") but is probably from weapon - ignoring. [" .. curTick .. "]")
	else
		debugMessage("Vehicle damage detected (" .. loss .. "), triggering onVehicleNonWeaponDamage. [" .. curTick .. "]", true)
		-- trigger vehicle damage event
		triggerEvent("onVehicleNonWeaponDamage", source, loss)
	end
end
)

-- wd event
addEventHandler("onVehicleDamageFromWeapon", root,
function ()
	debugMessage("Vehicle damage FROM WEAPON detected [" .. getTickCount() .. "]", true)
	lastWeaponDamageTick = getTickCount()
end
)

function notifyOfVehicleHealthIncrease(vehicle)
	vehiclesJustRepaired[vehicle] = true
	setTimer(removeVehicleFromTable, JUST_REPAIRED_TIMEOUT, 1, vehicle)
end

function removeVehicleFromTable(vehicle)
	vehiclesJustRepaired[vehicle] = nil
end
