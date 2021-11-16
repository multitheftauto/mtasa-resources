local pickupTimers = {}
local expireTime = get("timeout")
local onlyCurrentWeapon = get("only_current")
local dropRadius = get("radius")

local function destroyDeathPickup(pickupElement)
	if isElement(pickupElement) then
		destroyElement(pickupElement)
	end
end

local function dropAllWeapons(posX, posY, posZ, droppedWeapons)
	local weaponsCount = #droppedWeapons

	for wID = 1, weaponsCount do
		local weaponData = droppedWeapons[wID]
		local weaponID = weaponData[1]
		local weaponAmmo = weaponData[2]
		local pickupX = posX + dropRadius * math.cos((wID - 1) * 2 * math.pi/weaponsCount)
		local pickupY = posY + dropRadius * math.sin((wID - 1) * 2 * math.pi/weaponsCount)
		local pickupElement = createPickup(pickupX, pickupY, posZ, 2, weaponID, expireTime, weaponAmmo)

		pickupTimers[pickupElement] = setTimer(destroyDeathPickup, expireTime, 1, pickupElement)
	end
end

function onDeathPickupHit(playerElement)
	cancelEvent()
	giveWeapon(playerElement, getPickupWeapon(source), getPickupAmmo(source), false)
	destroyDeathPickup(source)
end
addEventHandler("onPickupHit", resourceRoot, onDeathPickupHit)

function onPlayerWasted()
	local posX, posY, posZ = getElementPosition(source)

	if onlyCurrentWeapon then
		local playerWeapon = getPedWeapon(source)
		local validWeapon = playerWeapon and playerWeapon ~= 0

		if validWeapon then
			local totalAmmo = getPedTotalAmmo(source)
			local pickupElement = createPickup(posX, posY, posZ, 2, playerWeapon, expireTime, totalAmmo)

			pickupTimers[pickupElement] = setTimer(destroyDeathPickup, expireTime, 1, pickupElement)
		end
	else
		local droppedWeapons = {}

		for weaponSlot = 0, 12 do
			local playerWeapon = getPedWeapon(source, weaponSlot)
			local validWeapon = playerWeapon ~= 0

			if validWeapon then
				local ammoInSlot = getPedTotalAmmo(source, weaponSlot)

				droppedWeapons[#droppedWeapons + 1] = {playerWeapon, ammoInSlot}
			end
		end

		dropAllWeapons(posX, posY, posZ, droppedWeapons)
	end
end
addEventHandler("onPlayerWasted", root, onPlayerWasted)

function onElementDestroyPickup()
	local validElement = isElement(source)

	if validElement then
		local pickupType = getElementType(source) == "pickup"

		if pickupType then
			local pickupTimer = pickupTimers[source]

			if pickupTimer then
				killTimer(pickupTimer)
				pickupTimers[source] = nil
			end
		end
	end
end
addEventHandler("onElementDestroy", resourceRoot, onElementDestroyPickup)

function onSettingChange(settingName, _, newValue)
	local expireSetting = settingName == "*deathpickups.timeout"

	if expireSetting then
		expireTime = fromJSON(newValue)
	end

	local weaponSetting = settingName == "*deathpickups.only_current"

	if weaponSetting then
		onlyCurrentWeapon = fromJSON(newValue)
	end

	local radiusSetting = settingName == "*deathpickups.radius"

	if radiusSetting then
		dropRadius = fromJSON(newValue)
	end
end
addEventHandler("onSettingChange", resourceRoot, onSettingChange)