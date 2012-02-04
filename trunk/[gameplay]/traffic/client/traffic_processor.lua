_peds = {}

MAX_NODES = 5
MAX_QUEUE = 7
DISTANCE_NODEREMOVE = 6
CURVE_INTERPOLATION = 45

function pedInitialize ( ped, node, next )
	_peds[ped] = {}
	_peds[ped].panic = false
	_peds[ped].sync = false
	_peds[ped].queue = {}
	_peds[ped].nodes = {}
	_peds[ped].controls = {}
	_peds[ped].stopStartTime = 0
	_peds[ped].findNodeStartTime = getTickCount()
	_peds[ped].collideStartTimeFront = 0
	_peds[ped].collideStartTimeBack = 0
	
	_peds[ped].debug = {}
	
	if node and next then
		pedFormQueue ( ped, getNode ( next ), getNode ( node ) )
	end

	-- _peds[ped].processed = false
end

function pedFormQueue ( ped, node, prev )
	_peds[ped].nodes = {}
	
	for i, marker in ipairs(_peds[ped].debug) do
		destroyElement(marker)
	end
	_peds[ped].debug = {}

	table.insert (_peds[ped].nodes, table.deepcopy(getNode(node.id)))
	for i = 1, MAX_NODES do
		local next = pedGetNextNode(ped, node, prev)
		table.insert (_peds[ped].nodes, table.deepcopy(next))
		prev = node
		node = next
		if i >= MAX_NODES-1 and table.size(pathsNodeGetNeighbours(node.id)) > 2 then
			i = i - 2
		end
	end
	
	for i, node in ipairs ( _peds[ped].nodes ) do
		if DEBUG then
			table.insert ( _peds[ped].debug, createMarker ( node.x, node.y, node.z, "corona", 1, 255, 255, 0, 255 ) )
		end
		if _peds[ped].nodes[i+1] then
			local next = _peds[ped].nodes[i+1]
			local orot = (360 - math.deg(math.atan2((next.x - node.x), (next.y - node.y)))) % 360
			local ox, oy = calcNodeLaneOffset(next, orot, node)
			_peds[ped].nodes[i].x, _peds[ped].nodes[i].y = node.x + ox, node.y + oy
		end
	end

	pedInterpolate(ped)
	
	_peds[ped].findNodeStartTime = getTickCount()
	-- for i, v in ipairs ( _peds[ped].nodes ) do
		-- table.insert ( _peds[ped].debug, createMarker ( v.x, v.y, v.z, "corona", 1, 255, 0, 0, 255 ) )
	-- end
	-- _peds[ped].queue = table.deepcopy(_peds[ped].nodes)
end

function pedInterpolate ( ped )
	_peds[ped].queue = {}

	-- local angles = {}
	for i = 1, #_peds[ped].nodes do
		table.insert (_peds[ped].queue, _peds[ped].nodes[i])
		if i <= #_peds[ped].nodes - 2 then
			local angle = math.abs( 	math.abs(math.deg(math.atan2(_peds[ped].nodes[i+2].y - _peds[ped].nodes[i+1].y, _peds[ped].nodes[i+2].x - _peds[ped].nodes[i+1].x))) - 
										math.abs(math.deg(math.atan2(_peds[ped].nodes[i+1].y - _peds[ped].nodes[i].y, _peds[ped].nodes[i+1].x - _peds[ped].nodes[i].x)))
									)
			if angle > CURVE_INTERPOLATION then
				-- table.insert(angles, angle)
				local queue = {}
				for j = i, i+2 do
					table.insert(queue, _peds[ped].nodes[j])
				end
				table.remove(_peds[ped].nodes, i)
				
				local interpolation = Interpolation.Bezier (unpack(queue))
				
				for i = 0, MAX_QUEUE do
					local node = interpolation:evalRational(i/MAX_QUEUE, {1,2.5,1})
					table.insert ( _peds[ped].queue, node)
					if DEBUG then
						table.insert ( _peds[ped].debug, createMarker ( node.x, node.y, node.z, "corona", 1, 0, 0, 255, 255 ) )
					end
				end
			end
		end
	end
	-- if #angles > 0 then
		-- outputDebugString("angles: "..table.concat(angles,", "))
	-- end
	
	if ( DEBUG ) then
		-- var_dump(_peds[ped].queue)
		-- for i, v in ipairs ( _peds[ped].queue ) do
			-- table.insert ( _peds[ped].debug, createMarker ( v.x, v.y, v.z, "corona", 1, 0, 0, 255, 255 ) )
		-- end
		
		for i, v in ipairs ( _peds[ped].nodes ) do
			table.insert ( _peds[ped].debug, createMarker ( v.x, v.y, v.z, "corona", 1, 255, 0, 0, 255 ) )
		end
	end
end

function pedGetNextNode ( ped, node, prev )
	return pathsFindNextNode(node.id, prev and prev.id)
	-- local neighbours = pathsNodeGetNeighbours ( node.id )
	-- local rand = arrayGetRandom ( neighbours, prev and prev.id )
	-- return getNode ( rand )
end

function pedGetTargetNode ( ped )
	local nodes = _peds[ped].nodes
	local target = _peds[ped].queue[1]

	if ( not target ) then return end
	local x, y, z = getElementPosition ( getElementParent ( ped ) )
	if ( getDistanceBetweenPoints2D ( x, y, target.x, target.y ) < DISTANCE_NODEREMOVE ) then
		_peds[ped].findNodeStartTime = getTickCount()
		table.remove(_peds[ped].queue, 1)
		if #_peds[ped].queue == 1 then
			-- outputDebugString("form new queue")
			pedFormQueue(ped, nodes[#nodes], nodes[#nodes-1])
		end
	end
	return target
end

function pedGetCurrentNode ( ped )
	local queue = _peds[ped].queue
	return queue[_peds[ped].current]
end

function arrayGetRandom ( array, ignored )
	local temp = {}
	for k, v in pairs ( array ) do
		if ( k ~= ignored ) then
			table.insert ( temp, k )
		end
	end
	if ( #temp > 0 ) then
		return temp[math.random(1,#temp)]
	else
		-- outputDebugString("return "..tostring(ignored))
		return ignored
	end
end

function getVehicleSpeed ( vehicle )
	local x, y, z = getElementVelocity ( vehicle )
	if ( not x or not y or not z ) then
		return 0
	end
	return math.sqrt( x ^ 2 + y ^ 2 + z ^ 2 ) * 100
end