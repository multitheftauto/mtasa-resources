local root = getRootElement ()
local resourceRoot = getResourceRootElement(getThisResource())
local blockedVehiclesIDs = {592, 577, 511, 548, 512, 593, 425, 417, 487, 553,
							488, 497, 563, 476, 447, 519, 460, 469, 513, 520,
							441, 464, 465, 501, 432}

function isVehicleIDBlocked ( id )
	local blocked = false
	for k,v in ipairs ( blockedVehiclesIDs ) do
		if ( v == id ) then
		    blocked = true
		    break
		end
	end
	return blocked
end

addEventHandler("onVehicleStartEnter", root,
function (player, seat, jacked, door)
	if (isVehicleIDBlocked(getElementModel(source))) then
		-- blah blah blah
	end
end
)

addCommandHandler("kill",
function (player, commandName)
	if (player) then
		killPed(player)
	end
end
)

addEventHandler("onResourceStart", resourceRoot,
function (resource)
	for i,v in ipairs(getElementsByType("vehicle")) do
	    toggleVehicleRespawn(v, true)
	end
end
)
