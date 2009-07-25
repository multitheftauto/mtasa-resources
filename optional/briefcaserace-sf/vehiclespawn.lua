local root = getRootElement ()
local resourceRoot = getResourceRootElement(getThisResource())
local blockedVehiclesIDs = {592, 577, 511, 548, 512, 593, 425, 417, 487, 553,
							488, 497, 563, 476, 447, 519, 460, 469, 513, 520,
							441, 464, 465, 501, 432}
local vehicleCreateTimes = {}
						
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

function onPlayerEnterVehicle_temp ( vehicle, seat, jackedPlayer )
    if ( isVehicleIDBlocked ( getElementModel ( vehicle ) ) ) then
		killPed ( source )
		destroyElement ( vehicle )
		outputChatBox ( "Vehicle not allowed", source )
	end
end

function consoleKill ( player, commandName )
	if ( player ) then
		killPed ( player )
	end
end

function consoleCreateVehicle ( player, commandName, first, second, third )
	if ( player ) then
		local allowed, timeLeft = canPlayerCreateVehicle ( player )
		if ( allowed ) then
			local id, x, y, z, r, d = 0, 0, 0, 0, 0, 5
			local plate = false
			r = getPedRotation ( player )
			x, y, z = getElementPosition ( player )
			x = x + ( ( math.cos ( math.rad ( r ) ) ) * d )
			y = y + ( ( math.sin ( math.rad ( r ) ) ) * d )
			if ( third ) then
				id = getVehicleModelFromName ( first .. " " .. second )
				plate = third
			elseif ( second ) then
				if ( getVehicleModelFromName ( first .. " " .. second ) ) then
					id = getVehicleModelFromName ( first .. " " .. second )
	     		else
	     			id = getVehicleModelFromName ( first )
					if ( not id ) then
						id = tonumber ( first )
					end
	     			plate = second
				end			
			else
				id = getVehicleModelFromName ( first )
				if ( not id ) then
					id = tonumber ( first )
				end
			end

			local punish = false

			if ( not isVehicleIDBlocked ( id ) ) then
				local vehicle
				if ( plate == false ) then
					vehicle = createVehicle ( id, x, y, z, 0, 0, r )
				else
					vehicle = createVehicle ( id, x, y, z, 0, 0, r, plate )
				end
		     	if ( vehicle ) then
		     	    toggleVehicleRespawn ( vehicle, true )
		     	    
		     	    table.insert(vehicleCreateTimes[player], getTickCount())
		     	    
		     	    if (punish) then
		     	    	warpPedIntoVehicle(player, vehicle)
						setVehicleFrozen(vehicle, true)
						setTimer(setVehicleFrozen, 10000, 1, vehicle, false)
		     	    end
		     	    
		     	else
				 	outputConsole ( "Failed to create vehicle.", player )
				end
			else
			    outputChatBox ( "Vehicle not allowed", player )
			end
		else
			outputChatBox("Wait " .. timeLeft/1000 .. " seconds.", player)
		end
	end
end


-- time penalty should really be a function of how frequently the vehicles were created..
function canPlayerCreateVehicle(player)
	local baseMinimumTime = 15000
	local timeLeft = 0
	local allowed = true
	local curTickCount = getTickCount()
	local lastIndex = #vehicleCreateTimes[player]
	local curIndex = lastIndex
	while (curIndex > 0 and allowed) do
		local dt = curTickCount - vehicleCreateTimes[player][curIndex]
--outputDebugString(curIndex .. " dt: " .. dt)
		local minimumTime = (lastIndex - curIndex + 1) * baseMinimumTime
--outputDebugString(curIndex .. " minT: " .. minimumTime)
		if (dt < minimumTime) then
--outputDebugString("  dt < minimumTime")
			allowed = false
			timeLeft = minimumTime - dt
		end
		curIndex = curIndex - 1
	end
	return allowed, timeLeft
end

function onResourceStart_temp(resource)
	for i,v in ipairs(getElementsByType("player")) do
		vehicleCreateTimes[v] = {}
	end
end

function onPlayerJoin_temp()
	vehicleCreateTimes[source] = {}
end

function onPlayerQuit_temp(reason)
	vehicleCreateTimes[source] = nil
end

addEventHandler ( "onPlayerEnterVehicle", root, onPlayerEnterVehicle_temp )
addEventHandler ( "onResourceStart", resourceRoot, onResourceStart_temp )
addEventHandler ( "onPlayerJoin", root, onPlayerJoin_temp )
addEventHandler ( "onPlayerQuit", root, onPlayerQuit_temp )

addCommandHandler ( "kill", consoleKill )
--addCommandHandler ( "createvehicle", consoleCreateVehicle )



addEventHandler("onResourceStart", getResourceRootElement(getThisResource()),
function (resource)
	for i,v in ipairs(getElementsByType("vehicle")) do
	    toggleVehicleRespawn(v, true)
	end
end
)