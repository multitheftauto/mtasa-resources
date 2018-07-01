-- This script calls the sever whenever the checkElement is shot at. It can also package multiple shots and send them as one event to save bandwidth.
-- This event should be added for one client only, or the server will recieve the same damage event from multiple clients.
-- How event packaging works: On event, wait MAX_WAIT_TIME. If nothing happens in that time, send. On next event, 1) cancel old wait time if exists, 2) if number of packaged events equals MAX_SEND_AMOUNT, send, otherwise wait again.
-- Note: packaging has been disabled since it delays too much

local MAX_SEND_AMOUNT = 1 -- max number of events that can be packaged into a send -- (disabled)
--local MAX_SEND_AMOUNT = 4 -- max number of events that can be packaged into a send
local MAX_WAIT_TIME = 100 -- max delay (ms) between two events for them to be part of a single send package (can't be less than 50ms)

local root = getRootElement()
local checkElement = false

local waitTimer = nil
local numWaiting = 0

function onClientPlayerWeaponFireAtVehicle(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
	--if (hitElement and getElementType(hitElement) == "vehicle") then
	if (checkElement and hitElement and hitElement == checkElement) then
		if (waitTimer) then
			killTimer(waitTimer)
			waitTimer = nil
		end
		if (numWaiting == MAX_SEND_AMOUNT-1) then
--debugMessage("client - triggering onVehicleDamageFromWeapon, " .. numWaiting .. " events packed")
			-- max send amount reached, send now
			triggerServerEvent("onVehicleDamageFromWeapon", hitElement)
			numWaiting = 0
		else
			-- send in MAX_WAIT_TIME ms (unless pre-empted by another event)
			waitTimer = setTimer(sendEvent, MAX_WAIT_TIME, 1, hitElement)
			numWaiting = numWaiting + 1
		end
	end
end

function sendEvent(hitElement)
--debugMessage("client - triggering onVehicleDamageFromWeapon, " .. numWaiting .. " events packed")
	triggerServerEvent("onVehicleDamageFromWeapon", hitElement)
	waitTimer = nil
	numWaiting = 0
end


-- adds vehicle weapon damage for local player's car
function addVehicleWeaponDamageEvent(vehicle)
	checkElement = vehicle
	addEventHandler("onClientPlayerWeaponFire", root, onClientPlayerWeaponFireAtVehicle)
end

function removeVehicleWeaponDamageEvent()
	removeEventHandler("onClientPlayerWeaponFire", root, onClientPlayerWeaponFireAtVehicle)
	checkElement = false
end
