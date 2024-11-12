local Superman = {}

--
-- Start/stop functions
--
function Superman.Start()
	local self = Superman

	addEvent("superman:start", true)
	addEvent("superman:stop", true)

	addEventHandler("superman:start", root, self.clientStart)
	addEventHandler("superman:stop", root, self.clientStop)
	addEventHandler("onPlayerJoin", root, Superman.setStateOff)
	addEventHandler("onPlayerVehicleEnter", root, self.enterVehicle)
end
addEventHandler("onResourceStart", resourceRoot, Superman.Start, false)

function Superman.clientStart()
	setElementData(client, "superman:flying", true)
end

function Superman.clientStop()
	setElementData(client, "superman:flying", false)
end

function Superman.setStateOff(state)
	triggerClientEvent("setPlayerFlyingC", source, false)
	setElementData(source or client, "superman:flying", false)
end

function Superman.setStateOn(state)
	triggerClientEvent("setPlayerFlyingC", source, true)
	setElementData(source or client, "superman:flying", true)
end

function cancelAirkill()
	if getElementData(source, "superman:flying") or getElementData(source, "superman:takingOff") then
		cancelEvent()
	end
end
addEventHandler("onPlayerStealthKill", root, cancelAirkill)

-- Fix for players glitching other players' vehicles by warping into them while superman is active, causing them to flinch into air and get stuck.
function Superman.enterVehicle()
	if getElementData(source, "superman:flying") or getElementData(source, "superman:takingOff") then
		removePedFromVehicle(source)
		local x, y, z = getElementPosition(source)
		setElementPosition(source, x, y, z)
	end
end