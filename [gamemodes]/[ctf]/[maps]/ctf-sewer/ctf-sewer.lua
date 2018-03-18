-- CTF-Sewer script by jhxp , contains parts of two scripts:
-- giveWeaponsOnSpawn for CTF: CS Italy by Ratt
-- assault (respawning vehicles) by driver2


function giveWeaponsOnSpawn ( spawnpont, team )
    giveWeapon ( source, 22, 224 ) -- Gives Colt45 with 224 ammo
	giveWeapon ( source, 29, 450 ) -- Gives MP5 with 450 ammo
end
addEventHandler ( "onPlayerSpawn", getRootElement(), giveWeaponsOnSpawn )

--[[
####

Vehicle respawn

####

function respawnAllVehicles()
	respawnVehicleTimers = {}
	local vehicles = getElementsByType("vehicle", mapRoot)
	for k,v in ipairs(vehicles) do
		respawnVehicle(v)
	end
end
]]


function respawnVehicle(vehicle)
	if (isElement(vehicle) == false) then return end
	if (getElementData(vehicle,"noRespawn") == true) then return end
	posX = getElementData(vehicle,"posX")
	posY = getElementData(vehicle,"posY")
	posZ = getElementData(vehicle,"posZ")
	rotX = getElementData(vehicle,"rotX")
	rotY = getElementData(vehicle,"rotY")
	rotZ = getElementData(vehicle,"rotZ")
	spawnVehicle ( vehicle, posX, posY, posZ, rotX, rotY, rotZ )

end
--[[
function onVehicleExit()
	if (isVehicleEmpty(source) == true) then
		respawnVehicleTimers[source] = setTimer(respawnVehicle,30000,1,source)
	end
end
function onVehicleEnter()
	if (respawnVehicleTimers[source] ~= nil) then
		killTimer(respawnVehicleTimers[source])
		respawnVehicleTimers[source] = nil
	end
end
]]

function onVehicleExplode()
	setTimer(respawnVehicle,15000,1,source)
end

--[[
function isVehicleEmpty( vehicle )
	local max = getVehicleMaxPassengers( vehicle )
	local empty = true
	local i = 0
	while (i < max) do
		if (getVehicleOccupant( vehicle, i ) ~= false) then
			empty = false
		end
		i = i + 1
	end
	return empty
end
]]

--addEventHandler ( "onVehicleEnter", getRootElement(), onVehicleEnter )
--addEventHandler ( "onVehicleExit", getRootElement(), onVehicleExit )
addEventHandler ( "onVehicleExplode", getRootElement(), onVehicleExplode )
