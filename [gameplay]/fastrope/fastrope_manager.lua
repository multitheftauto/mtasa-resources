local fastropes = {}
local count = 0
addEvent("onFastRopeDestroy")
addEvent("onFastRopeCreate")
addEvent("onPlayerFastRope")
function disableAnims ()
	setPedAnimation(client)
end
addEvent("frope_animoff", true)
addEventHandler("frope_animoff", resourceRoot, disableAnims)

local function destroyFastRope ( id )
	local heli = fastropes[id].heli
	if ( heli ) then
		setElementFrozen(heli, false)
	end

	triggerEvent ( "onFastRopeDestroy", getRootElement(), id, heli )
	fastropes[id] = nil
end
function createFastRope(player,x,y,z,time)
	if ( player and x and y and z and getElementType(player) == "player" ) then
		fastropes[count] = {}
		fastropes[count]["x"] = x
		fastropes[count]["y"] = y
		fastropes[count]["z"] = z
		fastropes[count]["time"] = time
		fastropes[count]["expiretime"] = time + getTickCount()
		fastropes[count]["heli"] = nil
		setTimer(destroyFastRope, time, 1, count)
		triggerClientEvent("frope_createFastRope", getRootElement(), x, y, z, time)
		setTimer(addPlayerToFastRope, 1000, 1, player, count)
		triggerEvent ( "onFastRopeCreate", getRootElement(), count, fastropes[count][heli] )
		count = count + 1
		return count - 1
	end
	return false
end
function createFastRopeOnHeli(player, heli, side, time, offset)
	local dump, x, y, z
	if ( player and heli and getElementType(player) == "player" and getElementType(heli) == "vehicle" ) then
		if ( time == nil ) then
			time = 3000
		end
		if ( side == nil ) then
			side = "left"
		end
		if ( offset == nil ) then
			offset = 0.8
		end
		local vx, vy, vz = getElementVelocity(heli)
		if ( vx > 0.1 or vy > 0.1 ) then
			return false
		end
		local helix, heliy, heliz = getElementPosition(heli)
		dump,dump,prot = getElementRotation(heli)
		local offsetRot = math.rad(prot)
		z = heliz - 0.5
		if ( side == "left" ) then
			x = helix - offset * math.cos(offsetRot)
			y = heliy - offset * math.sin(offsetRot)
		end
		if ( side == "right" ) then
			x = helix + offset * math.cos(offsetRot)
			y = heliy + offset * math.sin(offsetRot)
		end
		fastropes[count] = {}
		fastropes[count]["x"] = x
		fastropes[count]["y"] = y
		fastropes[count]["z"] = z
		fastropes[count]["time"] = time
		fastropes[count]["expiretime"] = time + getTickCount()
		fastropes[count]["heli"] = heli
		setElementFrozen(heli, true)
		triggerClientEvent("frope_createFastRope", getRootElement(), x, y, z, time)
		setTimer(destroyFastRope, time, 1, count)
		-- testing code
		--setTimer(addPlayerToFastRope, 1000, 1, player, count)
		-- end testing code
		triggerEvent ( "onFastRopeCreate", getRootElement(), count, fastropes[count][heli] )
		count = count + 1
		return count - 1
	end
	return false
end

local function frope_playerjoin ( )
	for k,v in ipairs(fastropes) do
		local time = v.expiretime - getTickCount()
		if ( time > 0 ) then
			triggerClientEvent(source, "frope_createFastRope", source, v.x, v.y, v.z, v.expiretime - getTickCount())
		else
			fastropes[count] = nil
		end
	end
end
addEventHandler("onPlayerJoin", getRootElement(), frope_playerjoin)

function addPlayerToFastRope(player, id)
	if (fastropes[id] == nil) then
		return false
	end
	if ( getPedOccupiedVehicle(player) ) then
		if ( getPedOccupiedVehicleSeat ( player ) == 0 ) then
			return false
		end
		removePedFromVehicle(player)
	end
	setElementPosition(player, fastropes[id].x, fastropes[id].y, fastropes[id].z - 1)
	setPedAnimation(player, "ped", "abseil", -1, false, true, false, true)
	triggerClientEvent(player, "frope_smartAnimBreak", player, fastropes[id].x,fastropes[id].y,fastropes[id].z)
	triggerEvent ( "onPlayerFastRope", player, id, fastropes[id][heli] )
	return true
end

function hasFastRopeExpired ( id )
	if (fastropes[id] == nil ) then
		return true
	else
		return false
	end
end
