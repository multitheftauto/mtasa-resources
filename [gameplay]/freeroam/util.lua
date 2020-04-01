addEvent('onClientCall', true)
addEventHandler('onClientCall',resourceRoot,
	function(fnName, ...)
		local fn = _G
		local path = fnName:split('.')
		for i,pathpart in ipairs(path) do
			fn = fn[pathpart]
		end
		fn(...)
	end,
	false
)

function setCameraPlayerMode()
	local r
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle then
		local rx, ry, rz = getElementRotation(vehicle)
		r = rz
	else
		r = getPedRotation(localPlayer)
	end
	local x, y, z = getElementPosition(localPlayer)
	setCameraMatrix(x - 4*math.cos(math.rad(r + 90)), y - 4*math.sin(math.rad(r + 90)), z + 1, x, y, z + 1)
	setTimer(setCameraTarget, 100, 1, localPlayer)
end

function getPlayerOccupiedSeat(player)
	local vehicle = getPedOccupiedVehicle(player)
	if not vehicle then
		return false
	end
	for i=0,getVehicleMaxPassengers(vehicle) do
		if getVehicleOccupant(vehicle, i) == player then
			return i
		end
	end
	return false
end

local _isPedDead = isPedDead
function isPedDead(player)
	return _isPedDead(player) or isPlayerTerminated(player)
end

function isPlayerTerminated(player)
	local x, y, z = getElementPosition(player)
	return (math.floor(x) == 132 and math.floor(y) == -68) or (math.abs(x) < 2 and math.abs(y) < 2 and z < 1)
end

function isPlayerMoving(p)
	if isElement(p) and getElementType(p) == "player" then
		return Vector3(getElementVelocity(p)).length ~= 0
	end
	return false
end

function table.find(t, ...)
	local args = { ... }
	if #args == 0 then
		for k,v in pairs(t) do
			if v then
				return k
			end
		end
		return false
	end

	local value = table.remove(args)
	if value == '[nil]' then
		value = nil
	end
	for k,v in pairs(t) do
		for i,index in ipairs(args) do
			if type(index) == 'function' then
				v = index(v)
			else
				if index == '[last]' then
					index = #v
				end
				v = v[index]
			end
		end
		if v == value then
			return k
		end
	end
	return false
end

function table.findall(t, ...)
	local args = { ... }
	local result = {}
	if #args == 0 then
		for k,v in pairs(t) do
			if v then
				result[#result+1] = k
			end
		end
		return result
	end

	local value = table.remove(args)
	if value == '[nil]' then
		value = nil
	end
	for k,v in pairs(t) do
		for i,index in ipairs(args) do
			if type(index) == 'function' then
				v = index(v)
			else
				if index == '[last]' then
					index = #v
				end
				v = v[index]
			end
		end
		if v == value then
			result[#result+1] = k
		end
	end
	return result
end

function table.removevalue(t, val)
	for i,v in ipairs(t) do
		if v == val then
			table.remove(t, i)
			return i
		end
	end
	return false
end

function table.merge(appendTo, ...)
	-- table.merge(targetTable, table1, table2, ...)
	-- Append the values of one or more tables to a target table.
	--
	-- In the arguments list, a table pointer can be followed by a
	-- numeric or textual key. In that case the values in the table
	-- will be assumed to be tables, and of each of these the value
	-- corresponding to the given key will be appended instead of the
	-- subtable itself.
	local appendval
	local args = { ... }
	for i,a in ipairs(args) do
		if type(a) == 'table' then
			for k,v in pairs(a) do
				if args[i+1] and type(args[i+1]) ~= 'table' then
					appendval = v[args[i+1]]
				else
					appendval = v
				end
				if appendval then
					if type(k) == 'number' then
						table.insert(appendTo, appendval)
					else
						appendTo[k] = appendval
					end
				end
			end
		end
	end
	return appendTo
end

function table.map(t, callback)
	for k,v in ipairs(t) do
		t[k] = callback(v)
	end
	return t
end

function table.flatten(t, result)
	if not result then
		result = {}
	end
	for k,v in ipairs(t) do
		if type(v) == 'table' then
			table.flatten(v, result)
		else
			table.insert(result, v)
		end
	end
	return result
end

function table.rep(value, times)
	local result = {}
	for i=1,times do
		table.insert(result, value)
	end
	return result
end

function table.each(t, index, callback, ...)
	local args = { ... }
	if type(index) == 'function' then
		table.insert(args, 1, callback)
		callback = index
		index = false
	end
	for k,v in pairs(t) do
		callback(index and v[index] or v, unpack(args))
	end
	return t
end

function string.split(str, delim)
	local startPos = 1
	local endPos = string.find(str, delim, 1, true)
	local result = {}
	while endPos do
		table.insert(result, string.sub(str, startPos, endPos-1))
		startPos = endPos + 1
		endPos = string.find(str, delim, startPos, true)
	end
	table.insert(result, string.sub(str, startPos))
	return result
end

function xmlToTable(xmlFile, leafAttrs)
	-- takes an xml file with <group>s of leaf nodes (groups may be nested),
	-- and returns it as a table of the form { 'group', name='groupname', children={ {'leafName', leafattr1='attr1', ...}, ... } }
	local xml = getResourceConfig(xmlFile)
	if not xml then
		outputChatBox(xmlFile .. ' could not be opened')
		return false
	end
	local result = {}
	_addXMLChildrenToTable(xml, xmlNodeGetAttribute(xml, 'type'), leafAttrs, result)
	xmlUnloadFile(xml)
	addTreeMetaInfo(result)
	return result
end

function _addXMLChildrenToTable(parentNode, leafName, leafAttrs, targetTable)
	local i = 0
	local groupNode = xmlFindChild(parentNode, 'group', 0)
	while groupNode do
		local group = {'group', name=xmlNodeGetAttribute(groupNode, 'name'), children={}}
		table.insert(targetTable, group)
		_addXMLChildrenToTable(groupNode, leafName, leafAttrs, group.children)
		i = i + 1
		groupNode = xmlFindChild(parentNode, 'group', i)
	end

	i = 0
	local leafNode = xmlFindChild(parentNode, leafName, 0)
	while leafNode do
		local leaf = {leafName}
		table.insert(targetTable, leaf)
		for k,attr in ipairs(leafAttrs) do
			leaf[attr] = ( attr == 'id' and tonumber(xmlNodeGetAttribute(leafNode, attr)) or xmlNodeGetAttribute(leafNode, attr) )
		end
		i = i + 1
		leafNode = xmlFindChild(parentNode, leafName, i)
	end
end

function followTreePath(root, ...)
	local item = root
	local path = table.flatten({...})
	for i,pathPart in ipairs(path) do
		if pathPart == '..' then
			item = item.parent
		else
			item = (item.children and item.children[pathPart]) or item[pathPart]
		end
		if not item then
			return false
		end
	end
	return item
end

function treePathToString(root, ...)
	local item = root
	local result = ''
	local path = table.flatten({...})
	if #path == 0 then
		return '/'
	end
	for i,pathPart in ipairs(path) do
		item = (item.children and item.children[pathPart]) or item[pathPart]
		if not item then
			return false
		end
		result = result .. '/' .. item.name
	end
	return result
end

function addTreeMetaInfo(targetTable, parentTable, depth)
	if not depth then
		depth = 1
	end
	local maxSubDepth = depth
	for k,v in pairs(targetTable) do
		if type(v) == 'table' then
			v.depth = depth
			v.parent = parentTable or targetTable
			v.siblings = targetTable
			if v.children then
				addTreeMetaInfo(v.children, v, depth+1)
				if v.maxSubDepth > maxSubDepth then
					maxSubDepth = v.maxSubDepth
				end
			end
		end
	end
	(parentTable or targetTable).maxSubDepth = maxSubDepth
end

function treeHasMetaInfo(tree)
	for k,v in pairs(tree) do
		if type(v) == 'table' then
			return v.depth and true or false
		end
	end
	return false
end

function applyToLeaves(t, callback)
	-- apply a callback function to leaves of a table created by xmlToTable()
	for i,item in ipairs(t) do
		if type(item) == 'table' then
			if item.children then
				applyToLeaves(item.children, callback)
			else
				callback(item)
			end
		end
	end
end
