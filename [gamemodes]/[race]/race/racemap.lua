g_MapObjAttrs = {
	spawnpoint = { 'position', 'rotation', 'vehicle', 'paintjob', 'upgrades' },
	checkpoint = { 'id', 'nextid', 'position', 'size', 'color', 'type', 'vehicle', 'paintjob', 'upgrades' },
	object = { 'position', 'rotation', 'model' },
	pickup = { 'position', 'type', 'vehicle', 'paintjob', 'upgrades', 'respawn' }
}
g_MapSettingNames = table.create(
	{'time', 'weather', 'respawn', 'respawntime', 'duration', 'skins', 'bikehats', 'bikehatchance', 'carhats', 'carhatchance',
	 'hairstyles', 'glasses', 'glasseschance', 'shirts', 'trousers', 'shoes',
	 'ghostmode', 'vehicleweapons', 'autopimp', 'firewater', 'classicchangez', 'hunterminigun'},
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
		local meta = xmlLoadFile(':' .. getResourceName(res) .. '/' .. 'meta.xml')
		if not meta then
			outputDebugString('Error while loading ' .. getResourceName(res) .. ': no meta.xml', 2)
			return false
		end
		local infoNode = xmlFindChild(meta, 'info', 0)
		local info = infoNode and xmlNodeGetAttributes ( infoNode ) or {}
		local filename = xmlNodeGetAttribute(xmlFindChild(meta, 'map', 0), 'src')
		local mapNode = xmlLoadFile(':' .. getResourceName(res) .. '/' .. filename)
		local def = xmlNodeGetAttribute(mapNode,"edf:definitions")
		xmlUnloadFile(meta)
		xmlUnloadFile(mapNode)
		local map = setmetatable({ res = res, resname = getResourceName(res), mod = "map", info = info, def = def }, RaceElementMap)
		return map
	end
	local meta = xmlLoadFile(':' .. getResourceName(res) .. '/' .. 'meta.xml')
	if not meta then
		outputDebugString('Error while loading ' .. getResourceName(res) .. ': no meta.xml', 2)
		return false
	end
    local infoNode = xmlFindChild(meta, 'info', 0)
    local info = infoNode and xmlNodeGetAttributes ( infoNode ) or {}
	local racenode = xmlFindChild(meta, 'race', 0)
	local file = racenode and xmlNodeGetAttribute(racenode, 'src')
	xmlUnloadFile(meta)
	if not file then
		outputDebugString('Error while loading ' .. getResourceName(res) .. ': no <race /> node in meta.xml', 2)
		return false
	end

	local xml = xmlLoadFile(':' .. getResourceName(res) .. '/' .. file)
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
	if self.xml then
		xmlUnloadFile(self.xml)
		self.xml = nil
	end
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
	if type(val) ~= 'string' then
		return val
	end
	if #val == 0 then
		return false
	end
	val = table.maptry(val:split(' '), tonumber) or val
	if type(val) == 'table' and #val == 1 then
		val = val[1]
	end
	return val
end


-----------------------------
-- Deathmatch specific (DP2)

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
	if type(val) ~= 'string' then
		return val
	end
	if #val == 0 then
		return false
	end
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
-- Element Map specific (1.0)

function RaceElementMap:__index(k)
	if RaceElementMap[k] then
		return RaceElementMap[k]
	end
	if g_MapSettingNames[k] then
		return get(self.resname .. '.' .. k)
	end
	return get(k)
end

function RaceElementMap:isDMFormat()
	return true
end

function RaceElementMap:isRaceFormat()
	return false
end

function RaceElementMap:getAll(name, type)
	local result = {}
	-- Block out specific stuff
	if name == "object" then
		return {}
	elseif name == "pickup" then
		return self:getAll("racepickup",name)
	end
	local resourceRoot = getResourceRootElement(self.res)
	for i,element in ipairs(getElementsByType(name, resourceRoot)) do
		result[i] = {}
		result[i].id = getElementID(element) or i
		attrs =	g_MapObjAttrs[type or name]
		for _,attr in ipairs(attrs) do
			local val = getElementData(element, attr)
			if attr == "rotation" then
				val = { tonumber(getElementData(element, "rotX")) or 0, tonumber(getElementData(element, "rotY")) or 0, tonumber(val or getElementData(element, "rotZ")) or 0 }
			elseif attr == "position" then
				val = val or { tonumber(getElementData(element, "posX")), tonumber(getElementData(element, "posY")), tonumber(getElementData(element, "posZ")) }
			elseif val then
				val = DMRaceMapObject.parseValue(result[i], val)
			end
			if val == "" then
				val = nil
			end
			result[i][attr] = val
		end
	end
	return result
end

function RaceElementMap:unload()
	return false
end
