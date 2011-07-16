addEvent("onPlayerGarageEnter", true)

addEventHandler("onResourceStart", getResourceRootElement(),
function (resource)
	for i=0,49 do
		--outputChatBox("opening garage " .. i)
		if (not isGarageOpen(i)) then
			setGarageOpen(i, true)
		end
	end
end
)

addEventHandler("onPlayerGarageEnter", root,
function (vehicle)
	--outputChatBox("SERVER: SOMEONE ENTERED GARAGE WITH CAR")
	fixVehicle(vehicle)
	setVehicleColor(vehicle, math.random(0,126), math.random(0,126), math.random(0,126), math.random(0,126))
	notifyOfVehicleHealthIncrease(vehicle)
end
)
