-- ( xxxx |client) by: Markland aka DarkChemical


-- ** Data ** --
local climbers = {}
local climbs = {}

local anim = anims




addEvent("onClientPedLadderClimbingStart")
addEvent("onClientPedLadderClimbingStop")
addEvent("onClientPedLadderClimbingStep")

addEvent("onClientRecieveLadderClimbingReady", true)
addEvent("onClientRecievePedLadderClimbingState", true)
addEvent("onClientRecieveLadderState", true)


function getLineUnitScale3D(sx, sy, sz, ex, ey, ez, m)
	local m = m or 1
	local sx, sy, sz, ex, ey, ez = tonumber(sx) or 0, tonumber(sy) or 0, tonumber(sz) or 0, tonumber(ex) or 0, tonumber(ey) or 0, tonumber(ez) or 0
	local ax, ay, az = ex-sx, ey-sy, ez-sz
	local d = getDistanceBetweenPoints3D(0, 0, 0, ax, ay, az)
	if d == 0 or not d then return 0, 0, 0 end
	local dx, dy, dz = ax/d, ay/d, az/d
	return dx*m, dy*m, dz*m
end

function getPointPositionOnLine3D(px, py, pz, sx, sy, sz, tx, ty, tz)
	local st = getDistanceBetweenPoints3D(sx, sy, sz, tx, ty, tz)
	local sp = getDistanceBetweenPoints3D(sx, sy, sz, px, py, pz)
	local tp = getDistanceBetweenPoints3D(tx, ty, tz, px, py, pz)
	local atp = math.acos((sp^2+st^2-tp^2)/(2*sp*st))
	local sd = sp*math.cos(atp)
	if sd>st or sd<0 then
		if tp<sp then
			return tx, ty, tz
		else
			return sx, sy, sz
		end
	else
		local x, y, z = getLineUnitScale3D(sx, sy, sz, tx, ty, tz, sd)
		return sx+x, sy+y, sz+z
	end
end


function getPointDistanceFromLine3D(px, py, pz, sx, sy, sz, tx, ty, tz)
	local st = getDistanceBetweenPoints3D(sx, sy, sz, tx, ty, tz)
	local sp = getDistanceBetweenPoints3D(sx, sy, sz, px, py, pz)
	local tp = getDistanceBetweenPoints3D(tx, ty, tz, px, py, pz)
	local atp = math.acos((sp^2+st^2-tp^2)/(2*sp*st))
	local sd = sp*math.cos(atp)
	if sd>st or sd<0 then
		return tp<sp and tp or sp
	else
		return (sp^2-sd^2)^.5
	end
end


function getPointDistanceFromLadder(px, py, pz, sx, sy, sz, tx, ty, tz)
	local st = getDistanceBetweenPoints3D(sx, sy, sz, tx, ty, tz)
	local sp = getDistanceBetweenPoints3D(sx, sy, sz, px, py, pz)
	local tp = getDistanceBetweenPoints3D(tx, ty, tz, px, py, pz)
	local atp = math.acos((sp^2+st^2-tp^2)/(2*sp*st))
	local sd = sp*math.cos(atp)
	if sd>st or sd<0 then
		return tp<sp and tp or sp, tp<sp and 1 or 0
	else
		return (sp^2-sd^2)^.5, sd/st
	end
end


local minus
do
	local abs = math.abs
	-- calculate and return the distance unit2 
	-- needs to move to reach unit1
	function minus(unit1, unit2)
		local phi = abs(unit2-unit1) % 360
		local sign = 1
		-- used to calculate sign
		if not ((unit1-unit2 >= 0 and unit1-unit2 <= 180)
		or (unit1-unit2 <= -180 and unit1-unit2 >= -360)) then
			sign = -1
		end
		if phi > 180 then
			result = 360-phi
		else
			result = phi
		end

		return result*sign
	end
end






function isPedClimbingLadder(ped)
    local data = climbers[ped]
    return data and true or false
end

function getPedClimbingLadder(ped)
    local data = climbers[ped]
    if not data then return false end
    return data.surface, data.climb, data.state
end

function getPedsOnLadder(surface)
    local peds = {}
    for ped, data in pairs(climbers) do
        if surface==nil then
            peds[ped] = data.surface
        elseif surface==data.surface then
            peds[ped] = data.climb
        end
    end
    return peds
end

function isPedLadderClimbingEnabled(ped)
    local eType = ped and isElement(ped) and getElementType(ped)
    assert(eType=="ped" or eType=="player") -- isPed
    if climbers[ped]==false then return false end
    return climbers[ped]==nil or (climbers[ped] and true)
end

function getLadderPositionFromData(surface, ladder, l)
	local l = l or climbs[surface] and climbs[climbs][ladder]
	local sx, sy, sz, tx, ty, tz, rx, ry, rz, d = l.sx, l.sy, l.sz, l.tx, l.ty, l.tz, l.rx, l.ry, l.rz, l.d
	if isElement(surface) then
		local m = createMatrix(surface)
		sx, sy, sz = getPositionFromMatrixOffset(m, sx, sy, sz)
		tx, ty, tz = getPositionFromMatrixOffset(m, tx, ty, tz)
		rx, ry, rz = getRotationFromMatrix(getMatrixFromOffset(m, 0, 0, 0, rx, ry, rz))
	end
	return sx, sy, sz, tx, ty, tz, rx, ry, rz, d
end

function getLadderClosestToPosition(px, py, pz)
    for i, v in pairs{px, py, pz} do
        assert(v==v and type(v)=="number")
    end
	local climbData, climbSurface, climbID, climbD, climbP, climbSize
	for surface, surfaceData in pairs(climbs) do
		for climb, l in pairs(surfaceData) do
			local sx, sy, sz, tx, ty, tz, rx, ry, rz, d = getLadderPositionFromData(surface, ladder, l)
			local dist = ((tx-sx)^2+(ty-sy)^2+(tz-sz)^2)^.5+10
			if ((tx-px)^2+(ty-py)^2+(tz-pz)^2)^.5<dist or ((px-sx)^2+(py-sy)^2+(pz-sz)^2)^.5<dist then
				local dist, p = getPointDistanceFromLadder(px, py, pz, sx, sy, sz, tx, ty, tz)
				if (climbD==nil or dist<climbD) then
					climbData, climbD, climbP = l, dist, p
					climbSurface, climbID = surface, climb
					local dx, dy, dz = tx-sx, ty-sy, tz-sz
					climbSize = ((dx)^2+(dy)^2+(dz)^2)^.5
				end
			end
		end
	end
    return climbSurface, climbID, climbD
end

function getLadders(surface)
    local ladders = {}
    if surface==nil then
        for i, data in pairs(climbs) do
            if data then
                ladders[#ladders+1] = i
            end
        end
    elseif climbs[surface] then
        for i, data in pairs(climbs[surface]) do
            if data then
                ladders[#ladders+1] = i
            end
        end
    end
    return ladders
end

do
    local props = ladderProperties
    function getLadderProperties(surface, ladder)
        local surfaceData = climbs[surface]
        if ladder then
            local l = surfaceData[ladder]
            if l then
                local p = {}
                for i, v in pairs(props) do
                    if l[i]==nil then
                        p[i] = v
                    else
                        p[i] = l[i]
                    end
                end
                return p
            end
        end
        return false
    end
end









local remover = {}
local badWalkingStates = {
    sprint = true,
    climb = true,
    --crawl = true,
    --crouch = true,
    --fall = true,
    jump = true,
}
local badTasks = {
    "TASK_SIMPLE_USE_GUN",
    --"TASK_SIMPLE_SWIM",
    "TASK_SIMPLE_JETPACK",
    "TASK_SIMPLE_CHOKING",
    "TASK_SIMPLE_FIGHT",
    "TASK_SIMPLE_NAMED_ANIM",
    "TASK_COMPLEX_ENTER_CAR_AS_DRIVER",
    "TASK_COMPLEX_ENTER_CAR_AS_PASSENGER",
    "TASK_SIMPLE_CAR_GET_IN",
    "TASK_SIMPLE_GO_TO_POINT",
    "TASK_SIMPLE_CAR_OPEN_DOOR_FROM_OUTSIDE",
    "TASK_SIMPLE_CAR_ALIGN",
    "TASK_SIMPLE_CAR_CLOSE_DOOR_FROM_INSIDE",
    "TASK_SIMPLE_CAR_SHUFFLE",
    "TASK_SIMPLE_ACHIEVE_HEADING",
}
function isBusy(ped)
    if isPedInVehicle(ped) then return true end
    for i, task in pairs(badTasks) do
        if isPedDoingTask(ped, task) then return true, "task" end
    end
    local move = getPedMoveState(ped)
    if badWalkingStates[move] then return true, "move" end
    if move=="fall" then
        local x, y, z = getElementVelocity(ped)
        if z<-0.1 then return true, "move" end
    end
    return false
end


local cooldown = 0
if testing then
	bindKey("r", "down", function()
		local m = getElementMatrix(localPlayer)
		local x, y, z = getElementPosition(localPlayer)
		local _, _, r = getElementRotation(localPlayer, "ZXY")
		local deci = 1000
		x, y, z, r = math.floor(x*deci)/deci, math.floor(y*deci)/deci, math.floor(z*deci)/deci, math.floor(r*deci)/deci
		texter = {"{sx=", x, " , sy=", y, ", sz=", z, ", tx=", x, ", ty=", y, ", tz=", z, ", rx=0, ry=0, rz=", r, ", d=1, shift_exit=nil, water=nil, sliding=nil, inside=nil, jumping=nil, enabled=nil},"}
		local text = ""
		for i=1, #texter do
			local t = texter[i]
			text = text..tostring(t)
		end
		setClipboard(text)
	end)
end


bindKey("enter_exit", "down", function(key, key_state)
	local tick = getTickCount()
	if tick-cooldown<500 then return end
	cooldown = tick
	local ped = localPlayer
	if climbers[ped] then
		local data = climbers[ped]
		local state = anim[data.state]
		if state and not state.anim_hold then return end
		if data.dir then return end
		local block, anim, time, loop, updatePosition, interuptable, fLF, blendTime = "BSKTBALL", "BBall_idle2_O", 0, false, false, false, true, 600
		setPedAnimation(ped, block, anim, time, loop, updatePosition, interuptable, fLF, blendTime)
		data.state = "fall"
		data.prog = 0
		triggerServerEvent("onPlayerReportLadderClimbingState", ped, data.surface, data.climb, data.position, data.state, data.prog, data.dir, data.dir_next, data.final_angle)
		return
	elseif climbers[ped]==false then
		return
	end
	local m = Matrix(Vector3(getElementPosition(ped)), Vector3(getElementRotation(ped)))
	m.position = m.position+m.forward*0.3+m.up*-0.0
	local px, py, pz = m.position.x, m.position.y, m.position.z
	local climbData, climbSurface, climbID, climbD, climbP, climbSize
	for surface, surfaceData in pairs(climbs) do
		for climb, l in pairs(surfaceData) do
			local sx, sy, sz, tx, ty, tz, rx, ry, rz, d = getLadderPositionFromData(surface, climb, l)
			local dist = ((tx-sx)^2+(ty-sy)^2+(tz-sz)^2)^.5+10
			if l.enabled~=false and (((tx-px)^2+(ty-py)^2+(tz-pz)^2)^.5<dist or ((px-sx)^2+(py-sy)^2+(pz-sz)^2)^.5<dist) then
				local dist, p = getPointDistanceFromLadder(px, py, pz, sx, sy, sz, tx, ty, tz)
				--print(dist, p, dist<d, d)
				if dist<d and (climbD==nil or dist<climbD) then
					climbData, climbD, climbP = l, dist, p
					climbSurface, climbID = surface, climb
					local dx, dy, dz = tx-sx, ty-sy, tz-sz
					climbSize = ((dx)^2+(dy)^2+(dz)^2)^.5
				end
			end
			--{sx=-1618.73, sy=-84, sz=1.96, tx=-1618, ty=-84, tz=12.5, rx=0, ry=0, rz=-135, d=.5, r=90, anim="ladder"},
		end
	end
	if climbID then
		local l = climbs[climbSurface][climbID]
		local sx, sy, sz, tx, ty, tz, rx, ry, rz, d = getLadderPositionFromData(climbSurface, climbID, l)
		local dx, dy, dz = tx-sx, ty-sy, tz-sz
		local size = ((dx)^2+(dy)^2+(dz)^2)^.5
		--print(climbID, climbD, climbP)
		local data = {
			surface = climbSurface,
			climb = climbID,
			position = climbP,
			isLocal = true,
		}
		local busy, busyT = isBusy(ped)
		local x, y, z = getElementRotation(ped)
		local rot = minus(rz, z)
		--print("ROT", rot, size-climbP*size)
		if busy and busyT~="move" then
			return
		elseif isPedDoingTask(ped, "TASK_SIMPLE_SWIM") then
			data.state = math.random()>0.5 and "climb_r" or "climb_l"
			data.prog = anim[data.state].anim_start
		elseif size-climbP*size<1 then
			data.dir = -1
			data.position = (size+(0.1))/size
			if rot>0 then
				data.state = "align_l"
				local t = anim[data.state].climb_angle[2][2]
				local rot = math.abs(rot)
				data.prog = t*(rot/180)
			else
				data.state = "align_r"
				local t = anim[data.state].climb_angle[2][2]
				local rot = math.abs(rot)
				data.prog = t*(rot/180)
			end
		elseif l.inside and (rot>130 or rot<-130) then
			local px, py, pz = getElementPosition(ped)
			local p = data.position
			local x, y, z, d = sx+dx*p, sy+dy*p, sz+dz*p
			d = getDistanceBetweenPoints3D(px, py, pz, x, y, z)
			if d<0.3 then return false end
			local r = (( 360 - math.deg ( math.atan2 ( ( px - x ), ( py - y ) ) ) ) % 360)-180
			if math.abs(minus(rz, r))<120 then return end
			data.state = "switch"
			data.prog = anim[data.state].anim_start
		elseif busyT=="move" then
			data.state = math.random()>0.5 and "climb_r" or "climb_l"
			data.prog = anim[data.state].anim_start
		elseif rot>0 then
			data.state = "enter_l"
			local t = anim[data.state].climb_angle[2][2]
			local rot = math.abs(rot)
			if rot>90 then return end
			rot = rot>90 and 90 or rot
			data.prog = t*(1-rot/90)
		else
			data.state = "enter_r"
			local t = anim[data.state].climb_angle[2][2]
			local rot = math.abs(rot)
			if rot>90 then return end
			rot = rot>90 and 90 or rot
			data.prog = t*(1-rot/90)
		end
		climbers[ped] = data
		local state = anim[data.state]
		if state.blend then
			local f = ((data.dir or 0)>0 and state.anim_start or state.anim_end)
			if f and state.reverse then f = state.anim_duration-f end
			setPedAnimation(ped, state.block, state.anim, -1, false, true, false, false, state.blend, false)
			setPedAnimationSpeed(ped, state.anim, 0)
			setPedAnimationProgress(ped, state.anim, state.anim_frame or (f/state.anim_duration))
		end
		triggerServerEvent("onPlayerReportLadderClimbingState", ped, data.surface, data.climb, data.position, data.state, data.prog, data.dir, data.dir_next, data.final_angle)
	end
end)

bindKey("jump", "down", function()
	local tick = getTickCount()
	if tick-cooldown<500 then return end
	cooldown = tick
	local ped = localPlayer
	local data = climbers[ped]
	if isControlEnabled("jump") and data then
		if data.dir then return end
		local surface = climbs[data.surface]
		local l = surface[data.climb]
		local sx, sy, sz, tx, ty, tz, rx, ry, rz, d = getLadderPositionFromData(data.surface, data.climb, l)
		if l.jumping==false then return end
		if getPedMoveState(ped)~="fall" then return false end
		local x, y, z = getElementRotation(getCamera())
		local dir = 0
		local left, right
		if isControlEnabled("left") then for key in pairs(getBoundKeys("left")) do if getKeyState(key) then left=true break end end end
		if isControlEnabled("right") then for key in pairs(getBoundKeys("right")) do if getKeyState(key) then right=true break end end end
		if left and right then
			dir = 180
		elseif left or right then
			local rot = minus(z, rz)
			rot = rot+(left and 90 or -90)
			if rot<0 then rot = 360+rot end
			dir = rot<90 and 90 or rot>270 and 270 or rot
		else
			local rot = minus(z, rz)
			if rot<0 then rot = 360+rot end
			if rot<80 or rot>280 then
				dir = 180
			else
				dir = rot<90 and 90 or rot>270 and 270 or rot
			end
		end
		data.final_angle = dir
		local state = anim[data.state]
		if state and not state.anim_hold then return end
		local p = math.abs(data.prog-state.anim_hold)
		if p>200 then return end
		data.dir = -1
		data.next = "leap"
		triggerServerEvent("onPlayerReportLadderClimbingState", ped, data.surface, data.climb, data.position, data.state, data.prog, data.dir, data.dir_next, data.final_angle)
		return
	end
end)

bindKey("crouch", "both", function(key, state)
	local tick = getTickCount()
	if tick-cooldown<500 then return end
	cooldown = tick
	local ped = localPlayer
	local data = climbers[ped]
	if isControlEnabled("crouch") and data and state=="down" then
		if data.dir then return end
		local surface = climbs[data.surface]
		local l = surface[data.climb]
		if l.sliding==false then return end
		if getPedMoveState(ped)~="fall" then return false end
		local state = anim[data.state]
		if state and not state.anim_hold then return end
		local p = math.abs(data.prog-state.anim_hold)
		if p>200 then return end
		data.dir = -1
		data.state = data.state=="climb_l" and "slide_l" or "slide_r"
		triggerServerEvent("onPlayerReportLadderClimbingState", ped, data.surface, data.climb, data.position, data.state, data.prog, data.dir, data.dir_next, data.final_angle)
		return
	elseif data and state=="up" then
		if data.state~="slide" then return end
		if data.next then return end
		local surface = climbs[data.surface]
		local l = surface[data.climb]
		local sx, sy, sz, tx, ty, tz, rx, ry, rz, d = getLadderPositionFromData(data.surface, data.climb, l)
		if data.position*getDistanceBetweenPoints3D(sx, sy, sz, tx, ty, tz)<1.5 then return end
		data.dir = -1
		data.next = "climb_r"
		data.dir_next = nil
		triggerServerEvent("onPlayerReportLadderClimbingState", ped, data.surface, data.climb, data.position, data.state, data.prog, data.dir, data.dir_next, data.final_angle)
	end
end)
addEventHandler("onClientPedLadderClimbingStep", localPlayer, function(state)
	if state~="slide" then return end
	local data = climbers[localPlayer]
	if data then
		if getPedControlState("crouch") then return end
		if data.state~="slide" then return end
		if data.next then return end
		local surface = climbs[data.surface]
		local l = surface[data.climb]
		local sx, sy, sz, tx, ty, tz, rx, ry, rz, d = getLadderPositionFromData(data.surface, data.climb, l)
		if data.position*getDistanceBetweenPoints3D(sx, sy, sz, tx, ty, tz)<1.5 then return end
		data.dir = -1
		data.next = "climb_r"
		data.dir_next = nil
		triggerServerEvent("onPlayerReportLadderClimbingState", localPlayer, data.surface, data.climb, data.position, data.state, data.prog, data.dir, data.dir_next, data.final_angle)
	end
end, false)

bindKey("sprint", "down", function()
	local tick = getTickCount()
	if tick-cooldown<500 then return end
	cooldown = tick
	local ped = localPlayer
	local data = climbers[ped]
	if isControlEnabled("sprint") and data then
		if data.dir then return end
		local surface = climbs[data.surface]
		local l = surface[data.climb]
		if l.inside~=true then return end
		local sx, sy, sz, tx, ty, tz, rx, ry, rz, d = getLadderPositionFromData(data.surface, data.climb, l)
		local dx, dy, dz = tx-sx, ty-sy, tz-sz
		local p = data.position
		do -- check clear
			local x, y, z = sx+dx*p, sy+dy*p, sz+dz*p
			local m = Matrix(Vector3(x, y, z), Vector3(rx, ry, rz))
			m.position = m.position+m.forward*1.2+m.up*0.0
			local sx, sy, sz = m.position.x, m.position.y, m.position.z
			m.position = m.position+m.up*2
			local tx, ty, tz = m.position.x, m.position.y, m.position.z
			local clear = isLineOfSightClear(sx, sy, sz, tx, ty, tz, true, true, false, true, true, true, false)
			local color = clear and tocolor(0, 200, 0, 100) or tocolor(255, 0, 0, 100)
			--dxDrawLine3D(sx, sy, sz, tx, ty, tz, color)
			if not clear then return end
		end
		local state = anim[data.state]
		if state and not state.anim_hold then return end
		local p = math.abs(data.prog-state.anim_hold)
		if p>200 then return end
		data.dir = 1
		data.next = "kick"
		triggerServerEvent("onPlayerReportLadderClimbingState", ped, data.surface, data.climb, data.position, data.state, data.prog, data.dir, data.dir_next, data.final_angle)
		return
	end
end)

function getValueAtTime(time, info)
	local time_s, time_e, value_s, value_e = 0, 0, 0, 0
	local data = info[1]
	if data then
		if data[3] and time>=data[2] then
			time_s, time_e, value_s, value_e = data[2], data[3], data[1], data[1]
		else
			time_s, time_e, value_s, value_e = 0, data[2], 0, data[1]
		end
	end
	for i=2, #info do
		data = info[i]
		if time<time_e then break end
		if data[3] then
			if time<data[2] then
				time_s, time_e, value_s, value_e = time_e, data[2], value_e, data[1]
			else
				time_s, time_e, value_s, value_e = data[2], data[3], data[1], data[1]
			end
		else
			time_s, time_e, value_s, value_e = time_e, data[2], value_e, data[1]
		end
	end
	if value_s==value_e then return value_s end
	if time_e==time_s then return (time_s-time)>0 and value_e or value_s end
	local p = (time-time_s)/(time_e-time_s)
	p = p>1 and 1 or p
	return value_s+(value_e-value_s)*p
end

local progz = 0
function processLadders(tick)
	if testing then
		local ped = localPlayer
		local state = anim[testing]
		if state then
			local dir = 0+getPedAnalogControlState(ped, "forwards")+-getPedAnalogControlState(ped, "backwards")
			progz = progz+dir
			if progz>state.anim_duration then progz = state.anim_duration end
			if progz<0 then progz = 0 end
			local prog = progz/state.anim_duration
			if not (setPedAnimationSpeed(ped, state.anim, 0) and setPedAnimationProgress(ped, state.anim, prog)) then
				setPedAnimation(ped, state.block, state.anim, -1, false, false, false, false, 0, false)
				setPedAnimationSpeed(ped, state.anim, 0)
				setPedAnimationProgress(ped, state.anim, prog)
			end
			setPedRotation(ped, 0)
			local px, py, pz = getElementPosition(ped)
			local tx, ty, tz = getElementBonePosition(ped, 0)
			local value = math.floor((tz-pz)*1000)/1000
			local value = math.floor((tx-px)*1000)/1000
			local value = math.floor((ty-py)*1000)/1000
			iprint("V:", progz, value)
			return
		end
		for surface, surfaceData in pairs(climbs) do
			for climb, l in pairs(surfaceData) do
				local sx, sy, sz, tx, ty, tz, rx, ry, rz, d = getLadderPositionFromData(surface, ladder, l)
				dxDrawLine3D(sx, sy, sz, tx, ty, tz, tocolor(0, 200, 200, 100))
			end
		end
	end
	local prog = tick*getGameSpeed()
	if prog>50 then prog = 50 end
	for ped, data in pairs(climbers) do
		if data then
			local isSyncer = ped==localPlayer or isElementSyncer(ped)
			local first = isSyncer and not data.isSyncer
			data.isSyncer = isSyncer
			local prog = prog
			local surface = climbs[data.surface]
			local l = surface[data.climb]
			local p = data.position
			local sx, sy, sz, tx, ty, tz, rx, ry, rz, d = getLadderPositionFromData(data.surface, data.climb, l)
			local dx, dy, dz = tx-sx, ty-sy, tz-sz
			local dist_down, dist_up
			do
				data.position = p
				local x, y, z = sx+dx*p, sy+dy*p, sz+dz*p
				--dxDrawLine3D(x, y, z, sx, sy, sz, tocolor(255, 0, 0, 200), 1.2)
				local hit, hx, hy, hz = processLineOfSight(x, y, z, sx-dx, sy-dy, sz-dz, true, true, false, true, true, true, false, true, isElement(data.surface) and data.surface or false)
				dist_down = l.dynamic and hx and (getDistanceBetweenPoints3D(x, y, z, hx, hy, hz)-1.05) or getDistanceBetweenPoints3D(x, y, z, sx, sy, sz)
				local hit, hx, hy, hz = processLineOfSight(x, y, z, tx, ty, tz, true, true, false, true, true, true, false, true, isElement(data.surface) and data.surface or false)
				dist_up = l.dynamic and hx and getDistanceBetweenPoints3D(x, y, z, hx, hy, hz) or getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)
			end
			local size = ((dx)^2+(dy)^2+(dz)^2)^.5
			local state = anim[data.state]
			local move = 0
			local skip
			if data.x==nil and isElement(data.surface) then setElementCollidableWith(ped, data.surface, false) end
			if data.isSyncer or data.isLocal then
				local px, py, pz = getElementPosition(ped)
				if l.enabled==false or isPedDead(ped) or getElementHealth(ped)==0 or (data.x and getDistanceBetweenPoints3D(data.x, data.y, data.z, getElementPosition(ped))>2) then
					remover[#remover+1] = ped
					prog = 0
					skip = true
				end
			end
			if not state then print(data.state) end
			prog = prog*state.speed
			while prog~=0 do
				local move_s = getValueAtTime(data.prog, state.climb_move)
				local dir = state.dir or data.dir or (state.anim_hold and data.prog>state.anim_hold and -1) or 1
				if data.dir or not state.anim_hold then
					data.prog, prog = data.prog+prog*dir, 0
					if dir<0 and data.prog<=state.anim_start then
						data.prog, prog, data.next = state.anim_start, state.anim_start-data.prog, data.next or state.climb_down
					elseif dir>0 and data.prog>=state.anim_end then
						data.prog, prog, data.next = state.anim_end, data.prog-state.anim_end, data.next or state.climb_up
					else
						data.next = data.next or (dir>0 and state.climb_up) or (dir<0 and state.climb_down)
					end
				elseif state.anim_hold then
					local p = math.abs(data.prog-state.anim_hold)
					if p<=prog then
						if data.prog~=state.anim_hold then triggerEvent("onClientPedLadderClimbingStep", ped, data.state) end
						data.prog, prog = state.anim_hold, prog-p
					else
						data.prog, prog = data.prog+prog*dir, 0
					end
					if (isSyncer or data.isLocal) and data.dir==nil and data.dir_next==nil and p<100 then
						local dir = state.dir or (0+getPedAnalogControlState(ped, "forwards")+-getPedAnalogControlState(ped, "backwards"))
						if dir==0 then
							prog = 0
						else
							if data.isLocal then data.dir_next = dir<0 and -1 or 1 else prog = 0 end
							if isSyncer then triggerServerEvent("onPlayerReportLadderClimbingState", ped, data.dir_next) end
						end
					else
						prog = 0
					end
				end
				local move_e = getValueAtTime(data.prog, state.climb_move)
				move, move_s = move+(move_e-move_s), move_e
				if state.anim_hold and data.prog==state.anim_hold then
					if data.dir_next then
						data.dir, data.dir_next = data.dir_next, nil
						local d = (p*size)
						if data.dir>0 then
							if size-d<(state.up_turn or 3) then
								data.next = state.climb_up
								local anim = anim[data.next]
								if anim.edge_dist then
									p, move = (size-anim.edge_dist-(getValueAtTime(state.anim_end, state.climb_move)-move_s))/size, 0
								end
							else
								data.next = state.climb_next or false
							end
						elseif data.dir<0 then
							if dist_down<(state.down_turn or 0.91) then
								if l.water then
									data.next = "fall2"
								else 
									data.next = state.climb_down or false
									local anim = anim[data.next]
									if anim.edge_dist then
										p, move = p+(anim.edge_dist-dist_down)/size, 0
									end
								end
							else
								data.next = state.climb_next or false
							end
						end
					end
				end
				p = p+move/size
				
				if (dir>0 and data.prog==state.anim_end) or (dir<0 and data.prog==state.anim_start) then
					local anim = anim[data.next or state.climb_next]
					if anim then
						prog = prog*(anim.speed/state.speed)
						data.state = data.next
						state = anim
						data.next = nil
						data.prog = dir<0 and state.anim_end or state.anim_start
						if state.anim_hold then data.dir = nil end
						if isSyncer then triggerServerEvent("onPlayerReportLadderClimbingState", ped, data.surface, data.climb, p, data.state, data.prog, data.dir, data.dir_next, data.final_angle) end
					else
						remover[#remover+1] = ped
						--if isSyncer then triggerServerEvent("onPlayerReportLadderClimbingState", ped, false) end
						break
					end
				end

				local fade = ((dir>0 and state.anim_end-data.prog) or (dir<0 and data.prog-state.anim_start) or 0)/state.speed
				if fade>0 and fade<=(state.anim_fade or 0) then
					local anim = anim[data.next or state.climb_next]
					local f = anim and (dir>0 and anim.anim_start or anim.anim_end)
					if f and anim.reverse then f = anim.anim_duration-f end
					if anim and not (setPedAnimationSpeed(ped, anim.anim, 0) and setPedAnimationProgress(ped, anim.anim, anim.anim_frame or (f/anim.anim_duration))) then
						setPedAnimation(ped, anim.block, anim.anim, -1, false, true, false, false, fade, false)
						setPedAnimationSpeed(ped, anim.anim, 0)
						setPedAnimationProgress(ped, anim.anim, anim.anim_frame or (f/anim.anim_duration))
					end
				end
			end

			local stream = isElementStreamedIn(ped)
			local rot = 0
			if stream then
				local a = state.straight and 0 or math.deg(math.atan2((dx^2+dy^2)^.5, dz))
				setElementBoneRotation(ped, 0, 0, 90, a+(state.climb_roll and getValueAtTime(data.prog, state.climb_roll) or 0))
				updateElementRpHAnim(ped)
				if state.climb_angle then
					if data.final_angle then
						local angle = {}
						for i=1, #state.climb_angle do
							angle[i] = state.climb_angle[i]
						end
						local a = angle[state.reverse and 1 or #angle]
						angle[state.reverse and 1 or #angle] = {data.final_angle, a[2], a[3]}
						rot = getValueAtTime(data.prog, angle) or rot
					else
						rot = getValueAtTime(data.prog, state.climb_angle) or rot
					end
				end
			end
			
			--if move<0 then print(math.floor(size*p*10), state.anim, math.floor(move*100)/100) end
			local steps = math.floor(size/.73)
			local step = (p*steps)
			if step>steps-2 then
				if step>steps then step = steps end
				step = 5+1-(steps-step)/2
			elseif step>1 then
				step=2+(step-1)%2
			elseif step<1 then
				step=step+1
			end
			stepProg = step%1
			step = math.floor(step)
			--local p = p>1 and 1 or p<0 and 0 or p
			data.position = p
			local x, y, z = sx+dx*p, sy+dy*p, sz+dz*p
			if state.climb_adjust then
				local r = math.rad(rz)
				local d = getValueAtTime(data.prog, state.climb_adjust)
				x, y, z = x-math.sin(r)*d, y+math.cos(r)*d, z
			else
				data.upper = nil
			end
			do -- anim
				local prog = state.anim_frame or (data.prog/state.anim_duration)
				if state.reverse then prog = 1-prog end
				if not (setPedAnimationSpeed(ped, state.anim, 0) and setPedAnimationProgress(ped, state.anim, prog)) then
					setPedAnimation(ped, state.block, state.anim, -1, false, true, false, false, 0, false)
					setPedAnimationSpeed(ped, state.anim, 0)
					setPedAnimationProgress(ped, state.anim, prog)
				end
			end
			if stream then
				local px, py, pz = getElementPosition(ped)
				local tx, ty, tz = getElementBoneMatrix(ped, 0)
				tx, ty, tz = tx[4][1], tx[4][2], tx[4][3]
				x, y, z = x-(tx-px), y-(ty-py), z-(tz-pz)
			end
			if skip then
				data.x, data.y, data.z = nil
			elseif state.velocity then
				if l.shift_exit and not (state and state.shift_exit==false) and data.shifted==nil then
					local r = math.rad(rz)
					local d = l.shift_exit
					x, y, z = x-math.sin(r)*d, y+math.cos(r)*d, z
					setElementPosition(ped, x, y, z, false)
					data.shifted = true
				elseif not (l.shift_exit or data.shifted) then
					data.shifted = true
					if isElement(data.surface) then setElementCollidableWith(ped, data.surface, true) end
				end
				local v = state.velocity
				setElementRotation(ped, 0, 0, 360-(rz+rot), "ZXY")
				setPedRotation(ped, (rz+rot), true)
				local x, y, z = getElementVelocity(ped)
				local r = math.rad(rz+(data.final_angle or rot))
				local d = -0.08
				local d = move*1
				local ox, oy, oz = v.x, v.y, v.z
				local x, y, z = x-math.sin(r)*d*ox, y+math.cos(r)*d*oy, z+d*oz
				setElementVelocity(ped, x, y, z)
				data.x, data.y, data.z = nil
			else
				setElementPosition(ped, x, y, z, false)
				data.x, data.y, data.z = getElementPosition(ped)
				setElementVelocity(ped, 0, 0, 0)
				setElementRotation(ped, 0, 0, 360-(rz+rot), "ZXY")
				setPedRotation(ped, (rz+rot), true)
			end
			
			--print("JJJJ", move, p, step, stepProg)
		end
	end
	for i=1, #remover do
		removeClimber(remover[i])
		remover[i] = nil
	end
end

function removeClimber(ped)
	local data = climbers[ped]
	if data then
		local surface = climbs[data.surface]
		local l = surface[data.climb]
		local p = data.position
		local state = anim[data.state]
		local sx, sy, sz, tx, ty, tz, rx, ry, rz, d = getLadderPositionFromData(data.surface, data.climb, l)
		if l.shift_exit and not (state and state.shift_exit==false) and data.shifted==nil then
			local r = math.rad(rz)
			local d = l.shift_exit
			local x, y, z = getElementPosition(ped)
			x, y, z = x-math.sin(r)*d, y+math.cos(r)*d, z
			setElementPosition(ped, x, y, z, false)
		end
		climbers[ped] = nil
		if isElement(data.surface) then setElementCollidableWith(ped, data.surface, true) end
		local block, anim, time, loop, updatePosition, interuptable, fLF, blendTime = "BSKTBALL", "BBall_idle2_O", 0, false, false, false, true, 200
		setPedAnimation(ped, block, anim, time, loop, updatePosition, interuptable, fLF, blendTime, false)
		--setElementVelocity(ped, 0, 0, 0)
		if data.isSyncer then triggerServerEvent("onPlayerReportLadderClimbingState", ped, false) end
		triggerEvent("onClientPedLadderClimbingStop", ped)
	end
end

addEventHandler("onClientResourceStop", resourceRoot, function()
	local removes = {}
	for ped in pairs(climbers) do
		removes[#removes+1] = ped
	end
	for i=1, #removes do
		removeClimber(removes[i])
	end
end)

local ready
addEventHandler("onClientRecieveLadderClimbingReady", localPlayer, function(a, b)
	if ready then print("What the actual F!!!???") return end
	ready = true
	climbs, climbers = a, b
	if climbers[localPlayer] then climbers[localPlayer].isLocal = true end
	addEventHandler("onClientPreRender", root, processLadders, false, "high")
	addEventHandler("onClientRecievePedLadderClimbingState", root, function(info, forced)
		local ped = source
		if ped==localPlayer and not forced then return end
		local data = climbers[ped]
		
		if info==1 or info==-1 then
			if data then
				data.dir_next = info
				return
			end
		elseif info then
			climbers[ped] = info
			if ped==localPlayer then climbers[ped].isLocal = true end
			if not data then
				triggerEvent("onClientPedLadderClimbingStart", ped, info.state)
			end
		else
			if data then
				removeClimber(ped)
			end
			if info==false then climbers[ped] = false end
		end
	end)
	addEventHandler("onClientRecieveLadderState", root, function(surface, climb, data)
		if climb==nil then
			local surfaceData = climbs[surface]
			local l = surfaceData and surfaceData[climb]
			if l then
				for i, data in pairs(surfaceData) do
					if data.enabled~=nil then l.enabled = data.enabled end
					if data.water~=nil then l.water = data.water end
					if data.jumping~=nil then l.jumping = data.jumping end
					if data.inside~=nil then l.inside = data.inside end
					if data.sliding~=nil then l.sliding = data.sliding end
					if data.dynamic~=nil then l.dynamic = data.dynamic end
					if data.shift_exit~=nil then l.shift_exit = data.shift_exit end
					if data.d~=nil then l.d = data.d end
				end
			end
		elseif climb==true then -- add/edit
			climbs[surface] = data
		elseif climb then -- change
			surfaceData[climb] = data
		end
	end)
	if testing then
		for surface, surfaceData in pairs(climbs) do
			for climb, l in pairs(surfaceData) do
				local sx, sy, sz = l.sx, l.sy, l.sz
				createBlip(sx, sy, sz, 0, 2, 255, 0, 0, 255, 0, 99999.0)
			end
		end
	end

end)



addEventHandler("onClientPlayerQuit", root, function()
    climbers[source] = nil
end)

addEventHandler("onClientElementDestroy", root, function()
    climbers[source] = nil
end)

triggerServerEvent("onPlayerRequestLadderClimbingReady", localPlayer)

































