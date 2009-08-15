local DESTROYED_ELEMENT_DIMENSION = getWorkingDimension() + 1
function toAttribute(value)
	if type(value) == "table" then
		if type(value[1]) == "table" then --Assume its a camera type
			return table.concat(value[1], ',')..","..table.concat(value[2], ',')
		else
			return table.concat(value, ',')
		end
	elseif isElement(value) then
		return getElementID(value)
	else
		return tostring(value)
	end
end

local specialSyncers = {
	position = function() end,
	rotation = function() end,
	dimension = function(element) return 0 end,
	interior = function(element) return edf.edfGetElementInterior(element) end,
	parent = function(element) return getElementData(element, "me:parent") end,
}

--!Need to write a decent algorithm to handle parents.
function dumpMap ( xml, save, baseElement )
	baseElement = baseElement or thisDynamicRoot
	local elementChildren = {}
	local rootElements = {}
	local usedResources = {}

	for i, element in ipairs(getElementChildren(baseElement)) do  --Find parents to start with
		--ignore representations and destroyed elements
		if not edf.edfIsRepresentation(element) and getElementDimension(element) ~= DESTROYED_ELEMENT_DIMENSION then
			local parent = getElementData ( element, "me:parent" )
			if not parent or getElementType(parent) == "map" then
				table.insert ( rootElements, element )
				elementChildren[element] = elementChildren[element] or {}
			else
				elementChildren[element] = elementChildren[element] or {}
				elementChildren[parent] = elementChildren[parent] or {}
				table.insert ( elementChildren[parent], element )
			end

			local creatorResource = getResourceName(edf.edfGetCreatorResource(element))
			usedResources[creatorResource] = true
		end
	end

	-- Save in the map node the used definitions
	local usedDefinitions = ""
	for resource in pairs(usedResources) do
		usedDefinitions = usedDefinitions .. resource .. ","
	end
	if usedDefinitions ~= "" then
		usedDefinitions = string.sub(usedDefinitions, 1, #usedDefinitions - 1)
		xmlNodeSetAttribute(xml, "edf:definitions", usedDefinitions)
	end

	dumpNodes ( xml, rootElements, elementChildren )
	if save then
		return xmlSaveFile(xml)
	end
end

function dumpNodes ( xml, elementTable, elementChildren )
	for i, element in ipairs(elementTable) do
		-- create element subnode
		local elementNode = xmlCreateChild(xml, getElementType(element))
		--add an ID attribute first off
		xmlNodeSetAttribute(elementNode, "id", getElementID(element))
		--dump raw properties from the getters
		for dataField in pairs(loadedEDF[edf.edfGetCreatorResource(element)].elements[getElementType(element)].data) do
			local value
			if specialSyncers[dataField] then
				value = specialSyncers[dataField](element)
			else
				value = edf.edfGetElementProperty(element, dataField)
			end
			if type(value) == "number" or type(value) == "string" then
				xmlNodeSetAttribute(elementNode, dataField, value )
			end
		end
		-- dump properties to attributes
		for dataName, dataValue in orderedPairs(getMapElementData(element)) do
			if dataName == "position" then
				xmlNodeSetAttribute(elementNode, "posX", toAttribute(dataValue[1]))
				xmlNodeSetAttribute(elementNode, "posY", toAttribute(dataValue[2]))
				xmlNodeSetAttribute(elementNode, "posZ", toAttribute(dataValue[3]))
			elseif dataName == "rotation" then
				xmlNodeSetAttribute(elementNode, "rotX", toAttribute(dataValue[1]))
				xmlNodeSetAttribute(elementNode, "rotY", toAttribute(dataValue[2]))
				xmlNodeSetAttribute(elementNode, "rotZ", toAttribute(dataValue[3]))
			elseif not specialSyncers[dataName] or dataValue ~= getWorkingDimension() then
				xmlNodeSetAttribute(elementNode, dataName, toAttribute(dataValue))
			end
		end
		dumpNodes ( elementNode, elementChildren[element], elementChildren )
	end
end

function dumpMeta ( xml, extraNodes, resource, filename )
	if not resource then return false end
	dimension = dimension or 0
	extraNodes = extraNodes or {}
	--[[ info tag ]]--
	local infoNode = xmlCreateChild(xml, "info")
	
	local info = {}
	info.author = currentMapSettings.metaAuthor
	info.type = "map"
	info.gamemodes = table.concat(currentMapSettings.addedGamemodes or {},",")
	info.name = currentMapSettings.metaName
	info.description = currentMapSettings.metaDescription
	info.version = currentMapSettings.metaVersion
	for attributeName, attributeValue in pairs(info) do
		if attributeValue ~= "" then
			xmlNodeSetAttribute(infoNode, attributeName, attributeValue)
			setResourceInfo ( resource, attributeName, attributeValue )
		end
	end
	
	--Add the actual map
	local mapNode = xmlCreateChild ( xml, "map" )
	xmlNodeSetAttribute ( mapNode, "src", filename )
	xmlNodeSetAttribute ( mapNode, "dimension", tostring(dimension) )
	
	--[[ mapmanager settings ]]--
	local settings = {}
	settings["#time"] = (currentMapSettings.timeHour or mapSettingDefaults.timeHour)..":"..(currentMapSettings.timeMinute or mapSettingDefaults.timeMinute)
	settings["#gamespeed"] = toJSON(currentMapSettings.gamespeed or mapSettingDefaults.gamespeed)
	settings["#gravity"] = toJSON(tonumber(currentMapSettings.gravity or mapSettingDefaults.gravity)) --!FIXME
	settings["#weather"] = toJSON(currentMapSettings.weather or mapSettingDefaults.weather)
	settings["#waveheight"] = toJSON(currentMapSettings.waveheight or mapSettingDefaults.waveheight)
	settings["#locked_time"] = toJSON(currentMapSettings.lockTime or mapSettingDefaults.lockTime)
	settings["#minplayers"] = toJSON(currentMapSettings.minPlayers or mapSettingDefaults.minPlayers)
	settings["#maxplayers"] = toJSON(currentMapSettings.maxPlayers or mapSettingDefaults.maxPlayers)
	
	--add any gamemode settings to the info table
	for row, value in pairs(currentMapSettings.gamemodeSettings or {}) do
		local data = currentMapSettings.rowData[row].internalName
		settings['#'..data] = toJSON(value)
	end
	
	--get the settings node or create one if it doesn't exist
	local settingsNode = xmlCreateChild(xml, "settings")
	
	--dump the settings there
	for settingName, settingValue in pairs(settings) do
		local settingNode = xmlCreateChild(settingsNode, "setting")
		xmlNodeSetAttribute(settingNode, "name", settingName)
		xmlNodeSetAttribute(settingNode, "value", settingValue)
	end
	
	--Add any copied files to meta as well
	for fileType,files in pairs(extraNodes) do
		for key,attr in ipairs(files) do
			local fileNode = xmlCreateChild(xml,fileType)
			for attributeName,attributeValue in orderedPairs(attr) do
				xmlNodeSetAttribute(fileNode, attributeName, attributeValue)
			end
		end
	end

	return xmlSaveFile(xml)
end

local illegalPrefixes = { ["me"]=true,["edf"]=true }
function getMapElementData ( element )
	local elementData = getAllElementData ( element )
	for dataName,dataValue in pairs(elementData) do
		local prefix = dataName:match('^(.-):')
		if prefix and illegalPrefixes[prefix] then
			elementData[dataName] = nil
		end
	end
	return elementData
end
