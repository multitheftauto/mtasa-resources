local timers = {} -- timers for existing pickups

local function onDeathPickupHit ( player, matchingDimension )
	if matchingDimension then
		killTimer ( timers[source] )
		timers[source] = nil
		removeEventHandler ( "onPickupHit", source, onDeathPickupHit )
		local weapid = getPickupWeapon ( source )
		local weapammo = getPickupAmmo ( source )
		destroyElement ( source )
		giveWeapon ( player, weapid, weapammo, false )
	end
end

local function destroyDeathPickup ( pickup )
	timers[pickup] = nil
	removeEventHandler ( "onPickupHit", pickup, onDeathPickupHit )
	destroyElement ( pickup )
end

addEventHandler ( "onPlayerWasted", getRootElement (),
	function ( source_ammo, killer, killer_weapon, bodypart )
		local pX, pY, pZ = getElementPosition ( source )
		local timeout = get("timeout")

		if get("only_current") then
			local source_weapon = getPedWeapon ( source )
			if ( source_weapon and source_weapon ~= 0 and source_ammo ) then
				local pickup = createPickup ( pX, pY, pZ, 2, source_weapon, timeout, source_ammo )
				addEventHandler ( "onPickupHit", pickup, onDeathPickupHit )
				timers[pickup] = setTimer ( destroyDeathPickup, timeout, 1, pickup )
			end
		else
			local droppedWeapons = {}
			for slot=0, 12 do
				local ammo = getPedTotalAmmo(source, slot)
				if (getPedWeapon(source, slot) ~= 0) then
					local weapon = getPedWeapon(source, slot)
					local ammo = getPedTotalAmmo(source, slot)
					table.insert(droppedWeapons, {weapon, ammo})
				end
			end
			DropAllWeapons(droppedWeapons)
		end
	end
)

function DropAllWeapons ( droppedWeapons )
	local radius = get("radius")
	local numberDropped = #droppedWeapons
	for i, t in ipairs(droppedWeapons) do
		local pX, pY, pZ = getElementPosition ( source )
		local x = pX + radius * math.cos((i-1) * 2 * math.pi / numberDropped)
		local y = pY + radius * math.sin((i-1) * 2 * math.pi / numberDropped)
		local timeout = get("timeout")
		local pickup = createPickup(x, y, pZ, 2, t[1], timeout, t[2])
		addEventHandler ( "onPickupHit", pickup, onDeathPickupHit )
		timers[pickup] = setTimer ( destroyDeathPickup, timeout, 1, pickup )
	end
end
