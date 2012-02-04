local sx, sy = guiGetScreenSize()

CURVE = 45							--45
NODE_LOSTDISTANCE = 100
NODE_LOSTTIME = 10000
CONTROLS = {"vehicle_left","vehicle_right","brake_reverse","accelerate","handbrake","horn"}

addEventHandler ( "onClientResourceStart", getResourceRootElement(), 
	function()
		triggerServerEvent("onPlayerFinishedDownloadTraffic", _local)
		outputChatBox("Press X to warp you in the next traffic vehicle", 0, 255, 0)
	end
)

-- Process all peds
addEventHandler ( "onClientPreRender", _root, function ()
	-- Only in this resource and only streamed in
	for i, ped in ipairs ( getElementsByType ( "ped", getResourceRootElement(), true ) ) do
		if _peds[ped] and _peds[ped].parked ~= true then
			local veh = getElementParent(ped)
			local sync = isElementSyncer(veh)
			if _peds[ped].sync == sync then
				if sync then
					pedProcessSyncer(ped)
				else
					pedProcess(ped)
				end
			elseif sync then
				-- _peds[ped] = getElementData(veh,"trafficSettings")
				local node = pathsNodeFindClosest(getElementPosition(veh))
				local next = getNode(getElementData(veh, "next")) or pedGetNextNode(ped, node)
				pedFormQueue(ped, next, node)
				pedProcessSyncer(ped)
				-- if DEBUG then
					-- outputDebugString("syncerChange node = "..tostring(node.id).." next = "..tostring(next.id))
				-- end
			-- elseif not sync then
				-- triggerServerEvent("onSyncerLost", veh)
			end
			_peds[ped].sync = sync
		end
	end
end )

-- addEvent ( "onSyncerChange", true )
-- addEventHandler ( "onSyncerChange", _root, 
	-- function (node, next)
		-- local ped = getVehicleController(source)
		-- if _peds[ped] then
			-- if DEBUG then
				-- outputDebugString("onSyncerChange client end: node = "..tostring(node).." next = "..tostring(next))
			-- end
			-- pedInitialize(ped, node, next)
			-- local node = pathsNodeFindClosest(getElementPosition(source))
			-- local next = pedGetNextNode(ped, node, node)
			-- pedFormQueue(ped, next, node)
			-- pedProcessSyncer(ped)
		-- end
	-- end 
-- )

-- addEventHandler ( "onClientPlayerQuit", _root, function ()
	-- for i, ped in ipairs ( getElementsByType ( "ped", getResourceRootElement(), true ) ) do
		-- if ( _peds[ped] ) then
			-- local veh = getElementParent(ped)
			-- if isElementSyncer(veh) then
				-- triggerServerEvent("onSyncerChange", veh, _peds[ped].queue[1].id, _peds[ped].queue[2].id)
				-- if DEBUG then
					-- outputDebugString("onSyncerChange client start on quit")
				-- end
			-- end
		-- end
	-- end
-- end )

addEvent ( VEH_CREATED, true )
addEventHandler ( VEH_CREATED, _root, function ( node, next )
	if not _peds[source] then
		pedInitialize ( source, node, next )
	end
end )

addEventHandler ( "onClientElementDestroy", getResourceRootElement(), function()
	if ( _peds[source] ) then
		_peds[source] = nil
	end
end )

function pedProcessSyncer ( ped )

	local vehicle = getElementParent ( ped )
	
	if not vehicle then
		return
	end

	-- if DEBUG then
		-- _peds[ped].processed = true
	-- end

	local next = pedGetTargetNode ( ped )
	if not next then return end
	if _peds[ped].parked then
		next = _peds[ped].parked
	end
	local x, y, z = getElementPosition ( vehicle )
	local nx, ny, nz = next.x, next.y, next.z
	
	if DEBUG then
		dxDrawLine3D ( x, y, z, nx, ny, nz, tocolor ( 255, 0, 255, 255 ), 10 )
	end
	
	local stop
	local controls = {}
	local limit = SPEED_LIMIT[_peds[ped].nodes[1].type]
	local rot = ( 360 - math.deg ( math.atan2 ( ( nx - x ), ( ny - y ) ) ) ) % 360
	local _, _, vrot = getElementRotation ( vehicle )
	local vrot = vrot or 0
	local trot = ( rot - vrot ) % 360
	if ( _peds[ped].panic ) then
		limit = limit + PANIC_SPEED
	end
	if _peds[ped].queue[1].flags then
		if _peds[ped].queue[1].flags.highway then
			limit = limit + HIGHWAY_SPEED
		end
		if _peds[ped].queue[1].flags.parking then
			_peds[ped].parked = _peds[ped].queue[1]
			stop = true
			limit = 1
		end
	end
	local distance = getDistanceBetweenPoints3D(x, y, z, nx, ny, nz)
	_peds[ped].distance = math.floor(distance)
	if distance > NODE_LOSTDISTANCE or NODE_LOSTTIME < getTickCount() - _peds[ped].findNodeStartTime then
		local node = pathsNodeFindClosest(x, y, z)
		pedFormQueue(ped, node, pedGetNextNode(ped, node))
		return
	end
	local accuracy = distance < 7 and 20 or 6
	if ( trot > -accuracy and trot < accuracy ) then
		controls["vehicle_left"] = false
		controls["vehicle_right"] = false
	elseif ( trot <= 360 and trot >= 180 ) then
		limit = SPEED_TURNING[_peds[ped].nodes[1].type]
		controls["vehicle_left"] = false
		controls["vehicle_right"] = true
	elseif ( trot >= 0 and trot <= 180 ) then
		limit = SPEED_TURNING[_peds[ped].nodes[1].type]
		controls["vehicle_right"] = false
		controls["vehicle_left"] = true
	end
	if ( getVehicleSpeed ( vehicle ) > limit ) then
		controls["accelerate"] = false
		-- outputChatBox("limit: "..limit)
	else
		controls["brake_reverse"] = false
		controls["accelerate"] = true
	end
	
	local horn = false
	
	local sightLength = math.pow(getVehicleSpeed(vehicle)/10, 2)
	sightLength = sightLength < 4 and 4 or sightLength
	sightLength = sightLength > 30 and 30 or sightLength
	
	if 1500 > getTickCount() - _peds[ped].stopStartTime then
		sightLength = _peds[ped].stopLength or sightLength
	end
	
	local matrix = getElementMatrix(vehicle)
	
	-- dxDrawLine3D( matrix[4][1], matrix[4][2], matrix[4][3], matrix[4][1] + matrix[1][1], matrix[4][2] + matrix[2][1], matrix[4][3] + matrix[3][1], tocolor ( 0, 255, 0), 3)
	-- dxDrawLine3D( matrix[4][1], matrix[4][2], matrix[4][3], matrix[4][1] + matrix[1][2], matrix[4][2] + matrix[2][2], matrix[4][3] + matrix[3][2], tocolor ( 0, 255, 0), 3)
	-- dxDrawLine3D( matrix[4][1], matrix[4][2], matrix[4][3], matrix[4][1] + matrix[1][3], matrix[4][2] + matrix[2][3], matrix[4][3] + matrix[3][3], tocolor ( 0, 255, 0), 3)
	
	local distanceToGround = getElementDistanceFromCentreOfMassToBaseOfModel(vehicle) - 0.25 
	local tx, ty, tz
	local process = {}
	local sideLineDistance = getVehicleType(vehicle) == "Bike" and 0.5 or 1
	for i=-sideLineDistance, sideLineDistance, 0.5 do
		for j=-distanceToGround, distanceToGround, distanceToGround do
			x, y, z = getMatrixOffsets(matrix, i, 0, j)
			tx, ty, tz = getMatrixOffsets(matrix, i, sightLength, j)
			local _, _, _, _, elem = processLineOfSight( x, y, z, tx, ty, tz, true, true, true, true, true, true, true, true, vehicle )
			table.insert(process, elem)
			if DEBUG then
				dxDrawLine3D( x, y, z, tx, ty, tz, tocolor ( 255, 255, 255), 3)
			end
		end
	end
	
	local hitElement = process[1]
	-- for _,elem in ipairs(process) do
		-- if elem then
			-- hitElement = elem
			-- break
		-- end
	-- end
	
	if hitElement then
		stop = not _peds[ped].panic
		horn = HORN_ENABLED
		-- outputChatBox(tostring(seeElement).." "..getElementType(seeElement))
		if getElementType(hitElement) == "vehicle" then
			stop = getVehicleController(hitElement)
			-- if _peds[occupant] then
				-- if next.leftlanes == 2 or next.rightlanes == 2 then
					-- lane = 0
					-- nextlanes = 5
					-- stop = false
				-- end
			-- end
		end
	else
		HORN_STARTTIME[ped] = getTickCount()
	end
	
	if ( stop ) then
		_peds[ped].stopStartTime = getTickCount()
		_peds[ped].stopLength = sightLength
		controls["accelerate"] = false
		-- controls["vehicle_left"] = false
		-- controls["vehicle_right"] = false
		controls["vehicle_left"] = controls["vehicle_right"]
		controls["vehicle_right"] = controls["vehicle_left"]
		if getVehicleSpeed( vehicle ) < 3 then
			controls["brake_reverse"] = false
		else
			controls["brake_reverse"] = true
		end
		controls["handbrake"] = true
		if horn then
			controls["horn"] = true
			if not HORN_STARTTIME[ped] then
				HORN_STARTTIME[ped] = getTickCount()
			end
			if HORN_TIME <= getTickCount() - HORN_STARTTIME[ped] then
				controls["horn"] = true
				HORN_STARTTIME[ped] = getTickCount()
			elseif HORN_TIME <= getTickCount() - HORN_STARTTIME[ped] + 500 then
				controls["horn"] = false
			end
		end
		if not HORN_STARTTIMELONG[ped] then
			HORN_STARTTIMELONG[ped] = getTickCount()
		end
		if 3*HORN_TIME <= getTickCount() - HORN_STARTTIMELONG[ped] then
			HORN_STARTTIMELONG[ped] = getTickCount()
		elseif 3*HORN_TIME <= getTickCount() - HORN_STARTTIMELONG[ped] + 1000 then
			-- outputChatBox("drive backwards")
			controls["handbrake"] = false
			controls["brake_reverse"] = true
		end
	else
		controls["brake_reverse"] = false
		controls["handbrake"] = false
		controls["horn"] = false
	end
	local naechsteKurve, kommendeKurve = 0, 0
	if #_peds[ped].queue >= 3 then
		naechsteKurve = math.abs( math.deg(math.atan2(_peds[ped].queue[3].y - _peds[ped].queue[2].y, _peds[ped].queue[3].x - _peds[ped].queue[2].x)) - math.deg(math.atan2(_peds[ped].queue[2].y - _peds[ped].queue[1].y, _peds[ped].queue[2].x - _peds[ped].queue[1].x)) )
		if #_peds[ped].queue >= 4 then
			kommendeKurve = math.abs( math.deg(math.atan2(_peds[ped].queue[4].y - _peds[ped].queue[3].y, _peds[ped].queue[4].x - _peds[ped].queue[3].x)) - math.deg(math.atan2(_peds[ped].queue[3].y - _peds[ped].queue[2].y, _peds[ped].queue[3].x - _peds[ped].queue[2].x)) )
		end
	end
	-- if not _peds[ped].queue[1].neighbours or kommendeKurve > CURVE or naechsteKurve > CURVE then
	if not _peds[ped].queue[1].nbs or kommendeKurve > CURVE or naechsteKurve > CURVE then
		if ( getVehicleSpeed ( vehicle ) > 35 ) then
			controls["brake_reverse"] = true
			controls["accelerate"] = false
		elseif ( getVehicleSpeed ( vehicle ) > 20 ) then
			controls["brake_reverse"] = false
			controls["accelerate"] = false
		end
	end
	
	sightLength = getVehicleType(vehicle) == "Bike" and 2 or 4
	sideLineDistance = getVehicleType(vehicle) == "Bike" and 0 or 1
	for i=-sideLineDistance, sideLineDistance, 0.5 do
		x, y, z = getMatrixOffsets(matrix, i, 0, 0)
		tx, ty, tz = getMatrixOffsets(matrix, i, sightLength, 0)
		local collideGTABuilding = processLineOfSight( x, y, z, tx, ty, tz, true, false, false, true, false, false, false, true, vehicle )
		if DEBUG then
			dxDrawLine3D( x, y, z, tx, ty, tz, tocolor ( 255, 0, 0), 3)
		end
		if collideGTABuilding then
			if getVehicleOccupant(vehicle,1) then
				dxDrawText ( "COLLIDE FRONT", sx - 200, sy/2 - 15, sx - 200, sy/2 - 15, tocolor(255,0,0), 2 )
			end
			_peds[ped].collideStartTimeFront = getTickCount()
			break
		end
	end
	if 750 >= getTickCount() - _peds[ped].collideStartTimeFront then
		controls["accelerate"] = false
		controls["brake_reverse"] = getVehicleSpeed ( vehicle ) < 10 and true or getVehicleSpeed ( vehicle ) > 15 and true or false
		controls["vehicle_left"] = controls["vehicle_right"]
		controls["vehicle_right"] = controls["vehicle_left"]
	end
	
	for i=-sideLineDistance, sideLineDistance, 0.5 do
		x, y, z = getMatrixOffsets(matrix, i, 0, 0)
		tx, ty, tz = getMatrixOffsets(matrix, i, -sightLength, 0)
		local collideGTABuilding = processLineOfSight( x, y, z, tx, ty, tz, true, false, false, true, false, false, false, true, vehicle )
		if DEBUG then
			dxDrawLine3D( x, y, z, tx, ty, tz, tocolor ( 255, 0, 0), 3)
		end
		if collideGTABuilding then
			if getVehicleOccupant(vehicle,1) then
				dxDrawText ( "COLLIDE BACK", sx - 200, sy/2 - 5, sx - 200, sy/2 - 5, tocolor(255,0,0), 2 )
			end
			_peds[ped].collideStartTimeBack = getTickCount()
			break
		end
	end
	if 750 >= getTickCount() - _peds[ped].collideStartTimeBack then
		controls["accelerate"] = getVehicleSpeed ( vehicle ) < 10 and true or getVehicleSpeed ( vehicle ) > 15 and true or false
		controls["brake_reverse"] = false
		controls["vehicle_left"] = controls["vehicle_right"]
		controls["vehicle_right"] = controls["vehicle_left"]
	end
	
	sightLength = sightLength/2
	sideLineDistance = sideLineDistance*2
	for i=-sideLineDistance, sideLineDistance, 1 do
		x, y, z = getMatrixOffsets(matrix, 0, i, 0)
		tx, ty, tz = getMatrixOffsets(matrix, sightLength, i, 0)
		local collideGTABuilding = processLineOfSight( x, y, z, tx, ty, tz, true, false, false, true, false, false, false, true, vehicle )
		if DEBUG then
			dxDrawLine3D( x, y, z, tx, ty, tz, tocolor ( 255, 0, 0), 3)
		end
		if collideGTABuilding then
			if getVehicleOccupant(vehicle,1) then
				dxDrawText ( "COLLIDE RIGHT", sx - 200, sy/2 + 5, sx - 200, sy/2 + 5, tocolor(255,0,0), 2 )
			end
			controls["vehicle_left"] = true
			controls["vehicle_right"] = false
			break
		end
	end
	
	for i=-sideLineDistance, sideLineDistance, 1 do
		x, y, z = getMatrixOffsets(matrix, 0, i, 0)
		tx, ty, tz = getMatrixOffsets(matrix, -sightLength, i, 0)
		local collideGTABuilding = processLineOfSight( x, y, z, tx, ty, tz, true, false, false, true, false, false, false, true, vehicle )
		if DEBUG then
			dxDrawLine3D( x, y, z, tx, ty, tz, tocolor ( 255, 0, 0), 3)
		end
		if collideGTABuilding then
			if getVehicleOccupant(vehicle,1) then
				dxDrawText ( "COLLIDE LEFT", sx - 200, sy/2 + 15, sx - 200, sy/2 + 15, tocolor(255,0,0), 2 )
			end
			controls["vehicle_left"] = false
			controls["vehicle_right"] = true
			break
		end
	end
	
	setElementData(vehicle, "next", next.id)
	
	if _peds[ped].parked and distance < 3 then
		for control in pairs(controls) do
			controls[control] = false
		end
		controls["handbrake"] = true
		setVehicleEngineState(vehicle, false)
		_peds[ped].parked = true
	end
	
	for control, state in pairs(controls) do
		if _peds[ped].controls[control] ~= state then
			setPedControlState(ped, control, state)
			setElementData(vehicle, control, state)
		end
	end
	
	_peds[ped].controls = controls
	-- setElementData(vehicle, "trafficSettings", _peds[ped])
end

function pedProcess(ped)
	for i, control in pairs(CONTROLS) do
		setPedControlState(ped, control, getElementData(getElementParent(ped), control))
	end
end

addEventHandler ( "onClientPlayerWeaponFire", _root, function()
	local px, py, pz = getElementPosition ( source )
	for i, ped in ipairs ( getElementsByType ( "ped", getResourceRootElement() ) ) do
		if ( _peds[ped] ) then
			local x, y, z = getElementPosition ( ped )
			if ( getDistanceBetweenPoints3D ( x, y, z, px, py, pz ) <= PANIC_DIST ) then
				if ( not _peds[ped].panic ) then
					_peds[ped].panic = true
					setTimer ( pedStopPanic, PANIC_TIME, 1, ped )
				end
			end
		end
	end
end )

function pedStopPanic ( ped )
	_peds[ped].panic = false
end

-- SHOWNODES = 70

addEventHandler ( "onClientRender", _root, function()
	-- if SHOWNODES then
		-- local x,y,z = getElementPosition ( _local )
		-- local areaID = getAreaFromPos(x,y,z)
		-- for _, node in pairs (AREA_PATHS[areaID]) do
			-- if getDistanceBetweenPoints3D ( node.x, node.y, node.z, x,y,z ) < SHOWNODES then
				-- -- dxDrawLine3D( node.x, node.y, node.z, node.x, node.y, node.z+2, tocolor ( 255, 0, 0), 3)
				-- local dx, dy = getScreenFromWorldPosition ( node.x, node.y, node.z )
				-- if ( dx and dy ) then
					-- -- var_dump(node)
					-- local neighbours = ""
					-- for i,v in pairs(node.neighbours) do
						-- neighbours = neighbours..tostring(i).."("..tostring(v)..")"..", "
					-- end
					-- dxDrawText ( 
						-- "node: "..tostring(node.id)..
						-- "\nlanes: "..tostring(node.leftlanes).." "..tostring(node.rightlanes)..
						-- "\nneighbours: "..tostring(neighbours)..
						-- "\nwidth: "..tostring(node.width)..
						-- "\nflags: "..tostring(node.flags and table.concatIndex(node.flags)),
						-- dx, dy, dx, dy, tocolor ( 255, 255, 255, 255 ), 1.2, "default", "center" )
				-- end
			-- end
		-- end
	-- end
	if DEBUG then
		local px, py, pz = getElementPosition ( _local )
		local sx, sy = guiGetScreenSize()
		local count = 0
		local count_synced, count_local = 0, 0
		for i, ped in ipairs ( getElementsByType ( "ped", getResourceRootElement() ) ) do
			if ( _peds[ped] ) then
				local veh = getElementParent ( ped )
				if ( getElementType ( veh ) == "vehicle" ) then
					local x, y, z = getElementPosition ( veh )
					local areaID = getAreaFromPos ( x, y, z )
					count = count + 1
					local dist = getDistanceBetweenPoints3D ( x, y, z, px, py, pz )
					if ( dist < SYNC_DIST ) then
						count_synced = count_synced + 1
						if ( isElementOnScreen ( ped ) ) then
							local dx, dy = getScreenFromWorldPosition ( x, y, z + 1 )
							if ( dx and dy ) then
								local next = _peds[ped].next
								local next_id = "None"
								if ( next ) then next_id = next.id end
								local node = _peds[ped].node
								local node_id = "None"
								if ( node ) then node_id = node.id end
								dxDrawText ( 
									"area: "..areaID..
									"\nzonename: "..tostring(getZoneName(x,y,z)).." ("..tostring(getZoneName(x,y,z,true))..")"..
									"\nspeed: "..math.floor(getVehicleSpeed(veh))..
									"\nqueue: "..tostring(#_peds[ped].queue)..
									"\nparked: "..tostring ( _peds[ped].parked )..
									"\nangle: "..tostring(#_peds[ped].queue >= 3 and math.floor(math.abs(math.abs(math.deg(math.atan2(_peds[ped].queue[3].y - _peds[ped].queue[2].y, _peds[ped].queue[3].x - _peds[ped].queue[2].x))) - math.abs(math.deg(math.atan2(_peds[ped].queue[2].y - _peds[ped].queue[1].y, _peds[ped].queue[2].x - _peds[ped].queue[1].x))))) )..
									"\nneighbours: "..tostring(#_peds[ped].queue > 0 and _peds[ped].queue[1].id and table.size(pathsNodeGetNeighbours(_peds[ped].queue[1].id)))..
									"\nflags: "..tostring(#_peds[ped].queue > 0 and _peds[ped].queue[1].flags and table.concatIndex(_peds[ped].queue[1].flags))..
									"\ndistance: "..tostring (_peds[ped].distance)..
									"\nsyncer: "..tostring(getElementData(veh,"syncer"))..
									"\nyou sync: "..tostring(isElementSyncer(veh)),
									dx, dy, dx, dy, tocolor ( 255, 255, 255, 255 ), 1.2, "default", "center" )
							end
						end
					end
					if isElementSyncer(veh) then
						count_local = count_local + 1
					end
				end
			end
		end
		local areaID = getAreaFromPos ( px, py, pz )
		dxDrawText(
			"Count: "..tostring(count)..
			"\nSynced: "..tostring(count_synced)..
			"\nSynced by me: "..tostring(count_local)..
			"\nServer by me: "..tostring(getElementData(_local, "vehiclecount"))..
			"\nArea ID 256: "..tostring(areaID)..
			"\nArea ID 64: "..tostring(math.floor((py+3000)/750)*8+math.floor((px+3000)/750)),
			sx - 200, sy / 3 * 2, sx - 200, sy / 3 * 2, tocolor ( 255, 255, 255, 255 ), 1.5 )
		-- areas grid

		if ( isPlayerMapVisible() ) then
			local start = sx / 2 - sy / 2
			local width = sy / ( 6000 / AREA_WIDTH )
			for i = 1, ( ( 6000 / AREA_HEIGHT ) - 1 ) do
				dxDrawLine ( start + i * width, 0, start + i * width, sy, tocolor ( 0, 0, 255, 200 ) )
				dxDrawLine ( start, i * width, start + sy, i * width, tocolor ( 0, 0, 255, 200 ) )
			end
		end
	end
end )

addCommandHandler("shownodes", function(cmd,dist)
		dist = tonumber(dist)
		if dist then
			SHOWNODES = dist
		else
			SHOWNODES = false
		end
	end
)

addCommandHandler("nb", function()
		local node = pathsNodeFindClosest(getElementPosition(_local))
		var_dump(pathsNodeGetNeighbours(node.id,true))
	end
)

addCommandHandler("dist", function()
		local node = pathsNodeFindClosest(getElementPosition(_local))
		outputChatBox("dist to node "..tostring(node.id)..": "..tostring(getDistanceBetweenPoints3D(node.x,node.y,node.z,getElementPosition(_local))))
	end
)

addCommandHandler("pos", function()
		local node = pathsNodeFindClosest(getElementPosition(_local))
		outputChatBox("node "..tostring(node.id)..": " )
	end
)


SHOWALLNODES = 70

addEventHandler ( "onClientRender", _root, 
	function()
		if SHOWALLNODES then
			local x,y,z = getElementPosition ( _local )
			local areaID = math.floor((y+3000)/750)*8+math.floor((x+3000)/750)
			local areaIDVeh = getAreaFromPos ( x, y, z )
			-- outputChatBox(tostring(areaID))
			if not areaID then return end
			
			-- for _, node in pairs (AREA_PATHS[areaIDVeh]) do
				-- -- outputChatBox(tostring(getDistanceBetweenPoints3D ( node.x, node.y, node.z, x,y,z )))
				-- if getDistanceBetweenPoints3D ( node.x, node.y, node.z, x,y,z ) < SHOWALLNODES then
					-- -- dxDrawLine3D( node.x, node.y, node.z, node.x, node.y, node.z+2, tocolor ( 255, 0, 0), 3)
					-- local dx, dy = getScreenFromWorldPosition ( node.x, node.y, node.z )
					-- if ( dx and dy ) then
						-- -- var_dump(node)
						-- local neighbours = ""
						-- for i,v in pairs(node.neighbours) do
							-- neighbours = neighbours..tostring(i).."("..tostring(v)..")"..", "
						-- end
						-- dxDrawText ( 
							-- "node: "..tostring(node.id)..
							-- "\nneighbours: "..tostring(neighbours)..
							-- "\nwidth: "..tostring(node.width)..
							-- "\nlanes: "..tostring(node.leftlanes).." "..tostring(node.rightlanes)..
							-- "\nflags: "..tostring(node.flags and table.concatIndex(node.flags)),
							-- dx, dy, dx, dy, tocolor ( 255, 0, 0, 255 ), 1.2, "default", "center" )
					-- end
				-- end
			-- end
			
			if AREA_PATHS_ALL then
				for _, node in pairs (AREA_PATHS_ALL[areaID].veh) do
					-- outputChatBox(tostring(getDistanceBetweenPoints3D ( node.x, node.y, node.z, x,y,z )))
					if getDistanceBetweenPoints3D ( node.x, node.y, node.z, x,y,z ) < SHOWALLNODES then
						-- dxDrawLine3D( node.x, node.y, node.z, node.x, node.y, node.z+2, tocolor ( 255, 0, 0), 3)
						local dx, dy = getScreenFromWorldPosition ( node.x, node.y, node.z )
						if ( dx and dy ) then
							-- var_dump(node)
							local neighbours = ""
							for i,v in pairs(node.nbs) do
								neighbours = neighbours..tostring(i).."("..tostring(v)..")"..", "
							end
							--[[
							dxDrawText ( 
								"node: "..tostring(node.id)..
								"\nneighbours: "..tostring(neighbours)..
								"\nnavinbs: "..tostring(table.concat(node.navinbs,", "))..
								"\nwidth: "..tostring(node.width)..
								"\nflags: "..tostring(node.flags and table.concatIndex(node.flags)),
								dx, dy, dx, dy, tocolor ( 255, 0, 0, 255 ), 1.2, "default", "center" )
								--]]
						end
					end
				end
				-- for _, node in pairs (AREA_PATHS_ALL[areaID].ped) do
					-- if getDistanceBetweenPoints3D ( node.x, node.y, node.z, x,y,z ) < SHOWALLNODES then
						-- -- dxDrawLine3D( node.x, node.y, node.z, node.x, node.y, node.z+2, tocolor ( 255, 0, 0), 3)
						-- local dx, dy = getScreenFromWorldPosition ( node.x, node.y, node.z )
						-- if ( dx and dy ) then
							-- -- var_dump(node)
							-- local neighbours = ""
							-- for i,v in pairs(node.nbs) do
								-- neighbours = neighbours..tostring(i).."("..tostring(v)..")"..", "
							-- end
							-- dxDrawText ( 
								-- "node: "..tostring(node.id)..
								-- "\nneighbours: "..tostring(neighbours)..
								-- "\nwidth: "..tostring(node.width)..
								-- "\ntype: "..tostring(node.type)..
								-- "\nflags: "..tostring(node.flags and table.concatIndex(node.flags)),
								-- dx, dy, dx, dy, tocolor ( 0, 255, 0, 255 ), 1.2, "default", "center" )
						-- end
					-- end
				-- end
				for _, node in pairs (AREA_PATHS_ALL[areaID].navi) do
					if getDistanceBetweenPoints2D ( node.x, node.y, x,y ) < SHOWALLNODES then
						-- dxDrawLine3D( node.x, node.y, node.z, node.x, node.y, node.z+2, tocolor ( 255, 0, 0), 3)
						-- local gz = getGroundPosition(node.x, node.y, z + 10)
						local next = AREA_PATHS_ALL[math.floor(node.nb/4095)].veh[node.nb]
						local dx, dy = getScreenFromWorldPosition ( node.x, node.y, next.z)
						if ( dx and dy ) then
							-- dxDrawLine3D(node.x, node.y, gz+0.5, node.x+(node.dirx/100), node.y+(node.diry/100), gz+0.5, tocolor (255,255,255), 3)
							
							--dxDrawLine3D(node.x, node.y, next.z+1, next.x, next.y, next.z+1, tocolor ( 255, 0, 255), 12)
							
							local lanes = tostring(node.leftlanes).." "..tostring(node.rightlanes)
							
							-- if node.dy > 0 then
								-- lanes = tostring(node.rightlanes).." "..tostring(node.leftlanes).." changed"
							-- end
							--[[
							dxDrawText (
								"node: "..tostring(node.id)..
								"\nattached to id: "..tostring(node.nb)..
								"\ndx,dy: "..tostring(node.dx).." "..tostring(node.dy)..
								"\nwidth: "..tostring(node.width)..
								"\nlanes: "..lanes..
								"\ntrafficLight: "..tostring(node.trafficlight),
								dx, dy, dx, dy, tocolor ( 0, 255, 0, 255 ), 1.2, "default", "center" )
								--]]
						end
					end
				end
			end
		end
	end
)

addCommandHandler("showallnodes", function(cmd,dist)
		dist = tonumber(dist)
		if dist then
			SHOWALLNODES = dist
		else
			SHOWALLNODES = false
		end
	end
)
