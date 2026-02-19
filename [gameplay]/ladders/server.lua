-- ( xxxx |server) by: Markland aka
local readyPlayers = {}
local climbers = {}
local climbs = climbs
local anims = anims

addEvent("onLadderAdd")
addEvent("onLadderRemove")
addEvent("onLadderClimbingStart")
addEvent("onLadderClimbingStop")
addEvent("onPedLadderClimbingStart")
addEvent("onPedLadderClimbingStop")
addEvent("onPedLadderClimbingStep")
addEvent("onPlayerRequestLadderClimbingReady", true)
addEvent("onPlayerReportLadderClimbingState", true)


function setPedClimbingLadder(ped, surface, ladder, pos)
    local eType = ped and isElement(ped) and getElementType(ped)
    assert(eType=="ped" or eType=="player") -- isPed
    if surface==false then
        local event = climbers[ped]
        climbers[ped] = nil
        triggerClientEvent("onClientRecievePedLadderClimbingState", ped, climbers[ped], true)
        if event then triggerEvent("onLadderClimbingStop", isElement(surface) and surface or root, surface, ladder, ped) end
        if event then triggerEvent("onPedLadderClimbingStop", ped, surface, ladder, event.position) end
        return true
    end
    if climbers[ped]==false then return false end
	local surfaceData = climbs[surface]
    assert(surfaceData)
    if surfaceData then
        local l = surfaceData[ladder]
        if l and l.enabled~=false then
            pos = pos or 0
            pos = pos<0 and 0 or pos>1 and 1 or pos
            local data = {
                surface = surface,
                climb = ladder,
                position = pos,
            }
			data.state = math.random()>0.5 and "climb_r" or "climb_l"
			data.prog = anims[data.state].anim_start
            local event = not climbers[ped]
            climbers[ped] = data
            triggerClientEvent("onClientRecievePedLadderClimbingState", ped, climbers[ped], true)
            if event then triggerEvent("onLadderClimbingStart", isElement(surface) and surface or root, surface, ladder, ped, data.state) end
            if event then triggerEvent("onPedLadderClimbingStart", ped, surface, ladder, data.state) end
            return true
        end
    end
    return false
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

function setPedLadderClimbingEnabled(ped, enabled)
    local eType = ped and isElement(ped) and getElementType(ped)
    assert(eType=="ped" or eType=="player") -- isPed
    if enabled==true then
        if climbers[ped]==false then
            climbers[ped] = nil
            triggerClientEvent("onClientRecievePedLadderClimbingState", ped, nil, true)
        end
        return true
    elseif enabled==false then
        if climbers[ped]~=false then climbers[ped]=false triggerClientEvent("onClientRecievePedLadderClimbingState", ped, climbers[ped], true) end
        return true
    end
    return false
end

function isPedLadderClimbingEnabled(ped)
    local eType = ped and isElement(ped) and getElementType(ped)
    assert(eType=="ped" or eType=="player") -- isPed
    if climbers[ped]==false then return false end
    return climbers[ped]==nil or (climbers[ped] and true)
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

function getLadderClosestToPosition(px, py, pz)
    for i, v in pairs{px, py, pz} do
        assert(v==v and type(v)=="number")
    end
	local climbData, climbSurface, climbID, climbD, climbP, climbSize
	for surface, surfaceData in pairs(climbs) do
		for climb, l in pairs(surfaceData) do
			local sx, sy, sz, tx, ty, tz, rx, ry, rz, d, r = l.sx, l.sy, l.sz, l.tx, l.ty, l.tz, l.rx, l.ry, l.rz, l.d, l.r
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

function setLadderEnabled(surface, ladder, active)
	local surfaceData = climbs[surface]
    assert(surfaceData)
    if ladder==true or ladder==false then
        for i, l in pairs(surfaceData) do
            l.enabled = ladder
        end
        triggerClientEvent("onClientRecieveLadderState", root, surface, nil, {enabled=ladder})
    elseif ladder then
        local l = surfaceData[ladder]
        if l and (active==true or active==false) then
            local was = l.enabled
            l.enabled = active
            if active~=was then triggerClientEvent("onClientRecieveLadderState", root, surface, ladder, l) end
            return true 
        end
    end
    return false
end

do
    local props = ladderProperties
    function setLadderProperties(surface, ladder, properties)
        local surfaceData = climbs[surface]
        assert(surfaceData)
        local p = {}
        if ladder then
            local l = surfaceData[ladder]
            if l then
                for i, v in pairs(props) do
                    if properties[i]~=nil then
                        p[i] = properties[i]
                        if v==0 then assert(p[i]==nil or (p[i]==p[i] and (type(p[i])=="number" and p[i]>-1/0 and p[i]<1/0))) end
                        if v==true or v==false then assert(p[i]==true or p[i]==false) end
                    end
                end
                for i, v in pairs(p) do l[i] = v end
                triggerClientEvent("onClientRecieveLadderState", root, surface, ladder, l)
                return true 
            end
        end
        return false
    end

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

function addLadder(surface, sx, sy, sz, tx, ty, tz, rx, ry, rz, d, jumping, inside, sliding, water, exitShift)
	local surfaceData = climbs[surface]
    assert(surfaceData)
    local l = {sx=sx , sy=sy, sz=sz, tx=tx, ty=ty, tz=tz, rx=rx, ry=ry, rz=rz, d=d, water=water, sliding=sliding, inside=inside, jumping=jumping, enabled=true, shift_exit=shift}
    l.dx, l.dy, l.dz = tx-sx, ty-sy, tz-sz
    ladder = #surfaceData+1
    if surfaceData[ladder]~=nil then return end
    surfaceData[ladder] = l
    triggerClientEvent("onClientRecieveLadderState", root, surface, ladder, l)
    triggerEvent("onLadderAdd", isElement(surface) and surface or root, surface, ladder)
    return ladder
end

function removeLadder(surface, ladder)
	local surfaceData = climbs[surface]
    assert(surfaceData)
    if ladder==nil then
        climbs[surface] = nil
        triggerClientEvent("onClientRecieveLadderState", root, surface, true, nil)
        triggerEvent("onLadderRemove", isElement(surface) and surface or root, surface, nil)
    elseif surfaceData[ladder] then
        surfaceData[ladder] = nil
        triggerClientEvent("onClientRecieveLadderState", root, surface, ladder, nil)
        triggerEvent("onLadderRemove", isElement(surface) and surface or root, surface, ladder)
        return true
    end
    return false
end


addDebugHook("preFunction", function(sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ped) -- just to deal with freeroam
	if sourceResource~=resource and climbers[ped] then
		return "skip"
	end
end, {"setPedAnimation"})

addEventHandler("onPlayerRequestLadderClimbingReady", root, function()
    local player = client
    if readyPlayers[player] then return end --? kick player???
    readyPlayers[player] = true
    triggerClientEvent(player, "onClientRecieveLadderClimbingReady", player, climbs, climbers)
end)

addEventHandler("onPlayerReportLadderClimbingState", root, function(climbSurface, ladder, position, step, time, direction, dir_next, angle)
    local player, ped = client, source
    if getElementType(ped)=="player" and player~=ped then kickPlayer(player, "Ladder Inc.") end
    assert(readyPlayers[player])
    local data = climbers[ped]
    if climbSurface==false then
        local event = data and true
        if data then
            climbers[ped] = nil
            data = nil
        end
        if event then triggerEvent("onLadderClimbingStop", isElement(climbSurface) and climbSurface or root, climbSurface, ladder, ped) end
        if event then triggerEvent("onPedLadderClimbingStop", ped, climbSurface, ladder, position) end
        return triggerClientEvent("onClientRecievePedLadderClimbingState", ped, data or nil)
    end
    if data and (climbSurface==1 or climbSurface==-1) and ladder==nil then
        data.dir_next = climbSurface
        if event then triggerEvent("onPedLadderClimbingStep", ped, data.surface, data.climb) end
        return triggerClientEvent("onClientRecievePedLadderClimbingState", ped, climbSurface)
    end 
    local surfaceData = climbs[climbSurface]
    local l = surfaceData and surfaceData[ladder]
    for i, v in pairs{position, time, direction, dir_next, angle} do
        assert(v==nil or (v==v and (type(v)=="number" and v>-1/0 and v<1/0)))
    end
    if not (surfaceData and l) then
        return
    end
    local event = not data
    if not data then
        -- create climb
        climbers[ped] = {}
        data = climbers[ped]
    end
    data.surface = climbSurface
    data.climb = ladder
    data.state = step
    data.dir = direction
    data.dir_next = dir_next
    data.final_angle = angle
    data.prog = time
    data.position = position
    if event then triggerEvent("onLadderClimbingStart", isElement(climbSurface) and climbSurface or root, climbSurface, ladder, ped, step) end
    if event then triggerEvent("onPedLadderClimbingStart", ped, climbSurface, ladder, step) end
    triggerClientEvent("onClientRecievePedLadderClimbingState", ped, data or nil)
end)




addEventHandler("onPlayerQuit", root, function()
    readyPlayers[source] = nil
    climbers[source] = nil
end)

addEventHandler("onElementDestroy", root, function()
    readyPlayers[source] = nil
    climbers[source] = nil
end)

do
    local elements = {}
    function updateElementModes(element, model)
        local info = model and (ladderModels[model] or ladderModels[getVehicleNameFromModel(model)])
        local data = climbs[element]
        --iprint(element, model, info and true, data and true, climbs[element])
        if data then
            climbs[element] = nil
        end
        if info then 
            climbs[element] = table.load({}, info, true)
        end
        if data or info then triggerClientEvent("onClientRecieveLadderState", root, element, true, climbs[element]) end
        --
    end

    function watcher(element)
        updateElementModes(element, getElementModel(element))
        addEventHandler("onElementModelChange", element, function(_, model)
            updateElementModes(element, model)
        end, false, "high")
    end
end

addDebugHook("postFunction", function(sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ...)
end, {"createVehicle", "Vehicle", "createObject", "Object"})


addEventHandler("onResourceStart", resourceRoot, function() -- onVehicleCreate
	local index = {vehicle=-1, object=-1}
	local elements = {}
	addDebugHook("postFunction", function(sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ...)
		index.vehicle = index.vehicle+1 
		local element = getElementByIndex("vehicle", index.vehicle, sourceResource)
		if elements[element] then
			local vehicles = getElementsByType("vehicle", root)
			element = vehicles[#vehicles]
		end
		if element and elements[element]==nil then
			elements[element] = "vehicle"
            watcher(element)
		else
			for i, element in pairs(getElementsByType("vehicle", root)) do
				if element and elements[element]==nil then
					elements[element] = "vehicle"
                    watcher(element)
					break
				end
			end
		end
	end, {"createVehicle", "Vehicle", "cloneElement"})
	for i, element in pairs(getElementsByType("vehicle", root)) do
		index.vehicle = index.vehicle+1
		elements[element] = "vehicle"
        watcher(element)
	end
	addDebugHook("postFunction", function(sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ...)
		index.object = index.object+1 
		local element = getElementByIndex("object", index.object)
		if elements[element] then
			local vehicles = getElementsByType("object", root)
			element = vehicles[#vehicles]
		end
		if element and elements[element]==nil then
			elements[element] = "object"
            watcher(element)
		else
			for i, element in pairs(getElementsByType("object", root)) do
				if element and elements[element]==nil then
					elements[element] = "object"
                    watcher(element)
					break
				end
			end
		end
	end, {"createObject", "Object", "cloneElement"})
	for i, element in pairs(getElementsByType("object", root)) do
		index.object = index.object+1
		elements[element] = "object"
        watcher(element)
	end
	addDebugHook("postEvent", function(sourceResource, eventName, eventSource, eventClient, luaFilename, luaLineNumber, ...)
        --iprint("DDS", eventSource, elements[eventSource])
		if elements[eventSource] then
            local eType = elements[eventSource]
			elements[eventSource] = nil
			index[eType] = index[eType]-1
            updateElementModes(eventSource, nil)
		return end
	end, {"onElementDestroy", Destroy})
end, false)















