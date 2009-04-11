g_MapObjAttrs = {
	spawnpoint = { 'position', 'rotation', 'vehicle', 'paintjob', 'upgrades' },
	checkpoint = { 'id', 'nextid', 'position', 'size', 'color', 'type', 'vehicle', 'paintjob', 'upgrades' },
	object = { 'position', 'rotation', 'model' },
	pickup = { 'position', 'type', 'vehicle', 'paintjob', 'upgrades' }
}
g_MapSettingNames = table.create(
	{'time', 'weather', 'respawn', 'respawntime', 'duration', 'skins', 'bikehats', 'bikehatchance', 'carhats', 'carhatchance',
	 'hairstyles', 'glasses', 'glasseschance', 'shirts', 'trousers', 'shoes',
	 'ghostmode', 'vehicleweapons', 'autopimp', 'firewater', 'cachemodels'},
	true
)


-----------------------------
-- Shared

RaceMap = {}
RaceElementMap = {}

function RaceMap:__index(k)
	if RaceMap[k] then
		return RaceMap[k]
	end
	local result = xmlNodeGetAttribute(self.xml, k)
	if result then
		result = RaceMapObject:parseValue(result)
		self[k] = result
		return result
	end
	result = xmlFindChild(self.xml, k, 0)
	if result then
		result = self:createRaceMapObject(result, k)
		self[k] = result
		return result
	end
end

function RaceMap.load(res)
	--Check if there are any .<map/>'s by using the real element system first
	local resourceRoot = getResourceRootElement(res)
	if #getElementsByType("spawnpoint",resourceRoot) > 0 then 
		--Spawnpoints are contained within the MTA map, therefore lets assume only MTA maps were used (removes general.ModifyOtherObjects dependency)
		local map = setmetatable({ res = res, resname = getResourceName(res), mod = "map" }, RaceElementMap)
		map.info = map
		return map
	end
	local meta = xmlLoadFile('meta.xml', res)
	if not meta then
		outputDebugString('Error while loading ' .. getResourceName(res) .. ': no meta.xml', 2)
		return false
	end
    local infoNode = xmlFindChild(meta, 'info', 0)
    local info = infoNode and xmlNodeGetAttributes ( infoNode ) or {}
	local racenode = xmlFindChild(meta, 'race', 0) or xmlFindChild(meta, 'map', 0)
	local file = racenode and xmlNodeGetAttribute(racenode, 'src')
	xmlUnloadFile(meta)
	if not file then
		outputDebugString('Error while loading ' .. getResourceName(res) .. ': no <race /> or <map /> node in meta.xml', 2)
		return false
	end
	
	local xml = xmlLoadFile(file, res)
	if not xml then
		outputDebugString('Error opening ' .. file, 2)
		return false
	end
	local map = setmetatable({ res = res, resname = getResourceName(res), file = file, xml = xml, info = info }, RaceMap)
	if map:isRaceFormat() then
		setmetatable(map, RaceRaceMap)
	elseif map:isDMFormat() then
		setmetatable(map, DMRaceMap)
	end
	return map
end

function RaceMap:isRaceFormat()
	return self.mod == 'race'
end

function RaceMap:isDMFormat()
	return self.mod == 'deathmatch'
end

function RaceMap:getAll(name, ...)
	local i = 0
	local result = {}
	local node = xmlFindChild(self.xml, name, 0)
	local attrs = g_MapObjAttrs[name] or { ... }
	local obj
	local id
	while node do
		i = i + 1
		obj = self:createRaceMapObject(node, name)
		result[i] = {}
		result[i].id = obj.id or i
		for _,attr in ipairs(attrs) do
			result[i][attr] = obj[attr]
		end
		node = xmlFindChild(self.xml, name, i)
	end
	return result
end

function RaceMap:createRaceMapObject(node, objtype)
	return setmetatable({ map = self, node = node, objtype = objtype }, RaceMapObject)
end

RaceMapObject = {}
function RaceMapObject:__index(k)
	if RaceMapObject[k] then
		return RaceMapObject[k]
	end
	local val = xmlNodeGetAttribute(self.node, k)
	if val then
		self[k] = self:parseValue(val)
		return self[k]
	end
	val = xmlFindChild(self.node, k, 0)
	if val then
		self[k] = self:parseValue(xmlNodeGetValue(val))
		return self[k]
	end
end

function RaceMapObject:parseValue(val)
	val = table.maptry(val:split(' '), tonumber) or val
	if type(val) == 'table' and #val == 1 then
		val = val[1]
	end
	return val
end

function RaceMap:save()
	xmlSaveFile(self.xml)
end

function RaceMap:unload()
	xmlUnloadFile(self.xml)
	self.xml = nil
end


-----------------------------
-- Race specific

RaceRaceMap = setmetatable({}, RaceMap)
function RaceRaceMap:__index(k)
	local result = rawget(RaceRaceMap, k) or getmetatable(RaceRaceMap).__index(self, k)
	if result or k == 'options' then
		return result
	end
	if g_MapSettingNames[k] then
		local result = get(self.resname .. '.' .. k)
		if result then
			return result
		end
	end
	return self.options and self.options[k]
end

function RaceRaceMap:createRaceMapObject(node, objtype)
	return setmetatable({ map = self, node = node, objtype = objtype }, RaceRaceMapObject)
end

RaceRaceMapObject = setmetatable({}, RaceMapObject)
function RaceRaceMapObject:__index(k)
	local result = rawget(RaceRaceMapObject, k) or getmetatable(RaceRaceMapObject).__index(self, k)
	if self.objtype == 'object' and k == 'rotation' then
		table.map(result, math.deg)
		local temp = result[1]
		result[1] = result[3]
		result[3] = temp
	elseif self.objtype == 'checkpoint' and k == 'type' and result == 'corona' then
		result = 'ring'
	end
	return result
end

function RaceRaceMapObject:parseValue(val)
	val = table.maptry(val:split(' '), tonumber) or val
	if type(val) == 'table' and #val == 1 then
		val = val[1]
	end
	return val
end


-----------------------------
-- Deathmatch specific

DMRaceMap = setmetatable({}, RaceMap)
function DMRaceMap:__index(k)
	if g_MapSettingNames[k] then
		local result = get(self.resname .. '.' .. k)
		return result and DMRaceMapObject:parseValue(result)
	end
	return rawget(DMRaceMap, k) or getmetatable(DMRaceMap).__index(self, k)
end

function DMRaceMap:createRaceMapObject(node, objtype)
	return setmetatable({ map = self, node = node, objtype = objtype }, DMRaceMapObject)
end

DMRaceMapObject = setmetatable({}, RaceMapObject)
function DMRaceMapObject:__index(k)
	local result = rawget(DMRaceMapObject, k) or getmetatable(DMRaceMapObject).__index(self, k)
	if result then
		return result
	end
	if k == 'position' then
		return table.maptry({ self.posX, self.posY, self.posZ }, tonumber)
	elseif k == 'rotation' then
		return table.maptry({ self.rotX, self.rotY, self.rotZ }, tonumber)
	end
end

function DMRaceMapObject:parseValue(val)
	local r, g, b = getColorFromString(val)
	if r then
		return { r, g, b }
	end
	val = table.maptry(val:split(','), tonumber) or val
	if type(val) == 'table' and #val == 1 then
		val = val[1]
	end
	return val
end

-----------------------------
-- Conversion

function RaceRaceMap:convert()
	local meta = xmlLoadFile('meta.xml', self.res)
	if not meta then
		return false
	end
	if self.meta then
		local infoNode = xmlFindChild(meta, 'info', 0)
		for _,infoAttr in ipairs({'author', 'description', 'version'}) do
			xmlNodeSetAttribute(infoNode, infoAttr, self.meta[infoAttr])
		end
		xmlDestroyNode(self.meta.node)
	end
	
	if self.options then
		local settingsNode = xmlCreateChild(meta, 'settings')
		local settingNode
		for option,_ in pairs(g_MapSettingNames) do
			if self[option] then
				settingNode = xmlCreateChild(settingsNode, 'setting')
				xmlNodeSetAttribute(settingNode, 'name', '#' .. option)
				xmlNodeSetAttribute(settingNode, 'value', self.options[option])
			end
		end
		xmlDestroyNode(self.options.node)
	end
	
	xmlSaveFile(meta)
	xmlUnloadFile(meta)
	
	local i, node, obj, val
	local splitAttrs = {
		position = { 'posX', 'posY', 'posZ' },
		rotation = { 'rotX', 'rotY', 'rotZ' }
	}
	for objType,attrs in pairs(g_MapObjAttrs) do
		i = 0
		while true do
			node = xmlFindChild(self.xml, objType, i)
			if not node then
				break
			end
			xmlNodeSetAttribute(node, 'name', nil)
			obj = self:createRaceMapObject(node, objType)
			for _,attr in ipairs(attrs) do
				val = obj[attr]
				if val then
					if splitAttrs[attr] and type(val) == 'table' and #splitAttrs[attr] == #val then
						for i,splitattr in ipairs(splitAttrs[attr]) do
							xmlNodeSetAttribute(node, splitattr, val[i])
						end
					else
						if type(val) == 'table' then
							if attr == 'color' then
								val = getStringFromColor(unpack(val))
							else
								val = table.concat(val, ',')
							end
						end
						xmlNodeSetAttribute(node, attr, val)
					end
					xmlDestroyNode(xmlFindChild(node, attr, 0))
				end
			end
			xmlNodeSetAttribute(node, 'id', objType .. (i+1))
			if objType == 'checkpoint' then
				xmlNodeSetAttribute(node, 'nextid', 'checkpoint' .. (i+2))
			end
			i = i + 1
		end
		if objType == 'checkpoint' and i > 0 then
			xmlNodeSetAttribute(xmlFindChild(self.xml, 'checkpoint', i-1), 'nextid', nil)
		end
	end
	xmlNodeSetAttribute(self.xml, 'mod', 'deathmatch')
	setmetatable(self, DMRaceMap)
end


-----------------------------
-- Element Map specific

function RaceElementMap:__index(k)
	if RaceElementMap[k] then
		return RaceElementMap[k]
	else
		return get(k)
	end
end

function RaceElementMap:isDMFormat()
	return true
end

function RaceElementMap:isRaceFormat()
	return false
end

function RaceElementMap:getAll(name,type)
	local result = {}
	--Block out specific stuff
	if name == "object" then 
		return {} 
	elseif name == "pickup" then
		return self:getAll("racepickup",name)
	end
	local resourceRoot = getResourceRootElement(self.res)
	for i,element in ipairs(getElementsByType(name,resourceRoot)) do
		result[i] = {}
		result[i].id = getElementID(element) or i
		attrs =	g_MapObjAttrs[type or name]
		for _,attr in ipairs(attrs) do
			result[i][attr] = getElementData(element,attr)
			if attr == "rotation" then
				result[i][attr] = result[i][attr] or getElementData(element,"rotZ")
			elseif attr == "position" then
				result[i][attr] = result[i][attr] or {tonumber(getElementData(element,"posX")), tonumber(getElementData(element,"posY")), tonumber(getElementData(element,"posZ"))}
			end
		end
	end
	return result
end

function RaceElementMap:unload() return false end
