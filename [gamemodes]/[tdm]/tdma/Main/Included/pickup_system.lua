pickups = {}
pickups_count = 0
pickups_weapons = {"5", "9", "22", "23", "24", "25", "26", "27", "28", "29", "32", "30", "31", "33", "34", "16", "18"}
pickups_weaponsAmmo = {"1", "1", "50", "50", "50", "25", "15", "20", "150", "159", "135", "100", "100", "30", "25", "6", "6"}

function initPickupSystem (  )
	--outputDebugString ( "Parsing Random Pickups.. Okay lets do it!" )
	local i = 0
	local tblrandomPickup = getElementsByType ( "randomPickup" )
	if #tblrandomPickup > 0 then
		addEventHandler ( "onPlayerPickupHit", root, onPlayerPickupHit )
	end
	for k,v in ipairs(tblrandomPickup) do
		i = i + 1
		local x = getElementData ( v, "posX" )
		local y = getElementData ( v, "posY" )
		local z = getElementData ( v, "posZ" )
		local weaponid = getElementData ( v, "weaponmodel" )
		if ( weaponid == false ) then
			weaponid = "-1"
		end
		local weaponammo = getElementData ( v, "weaponammo" )
		if ( weaponammo == false ) then
			weaponammo = "-1"
		end
		pickups[i] = {}
		pickups[i]["x"] = x
		pickups[i]["y"] = y
		pickups[i]["z"] = z
		pickups[i]["id"] = i
		pickups[i]["weaponid"] = weaponid
		pickups[1]["weaponammo"] = weaponammo
		--outputDebugString ( "Got a random pickup @ " .. x .. " " .. y .. " " .. z .. ", now installing..." )
		--generatePickup ( i )
		setTimer ( generatePickup, math.random(30000, 120000), 1, i )
	end
	pickups_count = i
end

function generatePickup ( pID )
	local pType = math.random(0,8)

	if ( pType == 0 ) then
		--Health
		--createPickup ( float x, float y, float z, int type, int amount/weapon, [ int respawnTime = 30000, int ammo = 50 ] )
		thePickup = createPickup ( pickups[pID]["x"], pickups[pID]["y"], pickups[pID]["z"], 0, 100 )
		if ( thePickup ) then
			pickups[pID]["pID"] = thePickup
			pickups[pID]["pType"] = 0
			pickups[pID]["pAmount"] = 100
			pickups[pID]["pWeapon"] = 0
			pickups[pID]["pAmmo"] = 0
		else
			--outputDebugString ( "unable to create pickup ID " .. pID )
		end
	elseif ( pType == 1 ) then
		--Armor
		thePickup = createPickup ( pickups[pID]["x"], pickups[pID]["y"], pickups[pID]["z"], 1, 100 )
		if ( thePickup ) then
			pickups[pID]["pID"] = thePickup
			pickups[pID]["pType"] = 1
			pickups[pID]["pAmount"] = 100
			pickups[pID]["pWeapon"] = 0
			pickups[pID]["pAmmo"] = 0
		else
			--outputDebugString ( "unable to create pickup ID " .. pID )
		end
	elseif ( pType >= 2 ) then
		--Weapon
		if ( pickups[pID]["weaponid"] == "-1" ) then
			local randomID = math.random(1,#pickups_weapons)
			local idWeapon = pickups_weapons[randomID]
			local idAmmo = pickups_weaponsAmmo[randomID]
			thePickup = createPickup ( pickups[pID]["x"], pickups[pID]["y"], pickups[pID]["z"], 2, idWeapon, 30000, idAmmo  )
			if ( thePickup ) then
				pickups[pID]["pID"] = thePickup
				pickups[pID]["pType"] = 2
				pickups[pID]["pAmount"] = 0
				pickups[pID]["pWeapon"] = idWeapon
				pickups[pID]["pAmmo"] = idAmmo
			else
				--outputDebugString ( "unable to create pickup ID " .. pID )
			end
		else
			local idWeapon = pickups[pID]["weaponid"]
			local WeaponAmmo = pickups[pID]["weaponammo"]
			if ( WeaponAmmo == "-1" ) then
				local wFound = false
				local wFndCount = 0
				for k,v in ipairs(pickups_weapons) do
					wFndCount = wFndCount + 1
					if v == idWeapon then
						wFound = true
						WeaponAmmo = pickups_weaponsAmmo[wFndCount]
					end
				end
				if ( wFound == false ) then
					WeaponAmmo = 25
				end
			end
			thePickup = createPickup ( pickups[pID]["x"], pickups[pID]["y"], pickups[pID]["z"], 2, idWeapon, 30000, WeaponAmmo  )
			if ( thePickup ) then
				pickups[pID]["pID"] = thePickup
				pickups[pID]["pType"] = 2
				pickups[pID]["pAmount"] = 0
				pickups[pID]["pWeapon"] = idWeapon
				pickups[pID]["pAmmo"] = WeaponAmmo
			else
				--outputDebugString ( "unable to create pickup ID " .. pID )
			end
		end

	end
	--outputDebugString ( "Installed pickup ID " .. pID .. "[" .. tostring(thePickup) .. ", with a type of: " .. pType )
end

function onPlayerPickupHit ( hitPickup, matchingDimension )
local foundIt = false
	for k,v in ipairs(pickups) do
		if ( v["pID"] == hitPickup ) then
			foundIt = true
			cancelEvent()
			--outputDebugString ( "Found this pickup! - Weapon Model: " .. tostring(v["pWeapon"]) .. " Ammo: " .. tostring(v["pAmmo"]) .. " Type: " .. tostring(v["pType"]) )

			if ( v["pType"] == 0 ) then
				--Give player health
				setElementHealth ( source, 100 )
				updatePlayerInfoBar ( source, 5000, "You picked up 100 health points!" )
			elseif ( v["pType"] == 1 ) then
				--Give player armor
				setPedArmor ( source, 100 )
				updatePlayerInfoBar ( source, 5000, "You picked up 100 armor points!" )
			elseif ( v["pType"] == 2 ) then
				--Give player weapon & ammo
				giveWeapon ( source, v["pWeapon"], v["pAmmo"] )
				--outputDebugString ( "Giving weapon " .. v["pWeapon"] .. "[" .. getWeaponNameFromID(v["pWeapon"]) .. "] to a player, Function says the weapon is: " .. getPickupWeapon(hitPickup) )
				if ( tonumber(v["pWeapon"]) < 10 ) then
					updatePlayerInfoBar ( source, 5000, "You obtained a " .. getWeaponNameFromID(v["pWeapon"]) )
				else
					updatePlayerInfoBar ( source, 5000, "You obtained a " .. getWeaponNameFromID(v["pWeapon"]) .. " with " .. v["pAmmo"] .. " rounds" )
				end
			end

			destroyElement ( v["pID"] )
			setTimer ( generatePickup, math.random(30000, 120000), 1, v["id"] )

			--setTimer ( "generatePickup", 5000, 1, v["id"] )
			break
		end
	end

	--Stops crappy spawning of dual weapons that we seem to have at the moment.
	if ( foundIt == false ) then
		destroyElement ( hitPickup )
	end
end

function getRandomWeapon()
	local tableSize = #pickups_weapons
	local randomID = math.random(1,tableSize)
	local i = 0
	local returnValue = nil

	for k,v in ipairs(pickups_weapons) do
		i = i + 1
		if ( i == randomID ) then
			returnValue = v
		end
	end

	if ( returnValue ~= nil ) then
		return returnValue
	else
		return false
	end
end
