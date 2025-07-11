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
	scale = function(element) return edf.edfGetElementScale(element) end,
	dimension = function(element) return getElementData(element, "me:dimension") or 0 end,
	interior = function(element) return edf.edfGetElementInterior(element) end,
	alpha = function(element) return edf.edfGetElementAlpha(element) end,
	parent = function(element) return getElementData(element, "me:parent") end,
}

--!Need to write a decent algorithm to handle parents.
function dumpMap ( xml, save, baseElement )
	baseElement = baseElement or mapContainer
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

	-- Loverly hack for race checkpoint scale
	if usedResources['race'] then
		usedResources['editor_main'] = true
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

function dumpNodes ( xmlNode, elementTable, elementChildren )
	for i, element in ipairs(elementTable) do
		local elementNode = createElementAttributesForSaving(xmlNode, element)
		dumpNodes ( elementNode, elementChildren[element], elementChildren )
	end
end

local function syncMapMinVersion(mapXml)
	local metaFile = xmlLoadFile("meta.xml")

	if not metaFile then
		return false
	end

	local editorMinVer = xmlFindChild(metaFile, "min_mta_version", 0)

	if editorMinVer then
		local mapVersionNode = xmlFindChild(mapXml, "min_mta_version", 0) or xmlCreateChild(mapXml, "min_mta_version")

		if mapVersionNode then
			local clientMinVer = xmlNodeGetAttribute(editorMinVer, "client")
			local serverMinVer = xmlNodeGetAttribute(editorMinVer, "server")

			if clientMinVer then
				xmlNodeSetAttribute(mapVersionNode, "client", clientMinVer)
			end

			if serverMinVer then
				xmlNodeSetAttribute(mapVersionNode, "server", serverMinVer)
			end
		end
	end

	xmlUnloadFile(metaFile)

	return true
end

function dumpMeta ( xml, extraNodes, resource, filename, test )
	if not resource then
		return false
	end

	dimension = dimension or 0
	extraNodes = extraNodes or {}

	-- Fetch min_mta_version from editor_main meta.xml

	syncMapMinVersion(xml)

	--Add OOP support
	--[[local oopNode = xmlCreateChild(xml, "oop")
	xmlNodeSetValue(oopNode, "true")]]

	--[[ info tag ]]--
	local infoNode = xmlCreateChild(xml, "info")

	local info = {}
	info.author = currentMapSettings.metaAuthor
	info.type = "map"
	info.gamemodes = table.concat(currentMapSettings.addedGamemodes or {},",")
	info.name = currentMapSettings.metaName
	info.description = currentMapSettings.metaDescription
	info.version = currentMapSettings.metaVersion
	if test then
		info["edf:represent"] = "false"
	end
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
	settings["#locked_time"] = toJSON(currentMapSettings.locked_time or mapSettingDefaults.locked_time)
	settings["#useLODs"] = toJSON(currentMapSettings.useLODs or mapSettingDefaults.useLODs)
	settings["#minplayers"] = toJSON(currentMapSettings.minplayers or mapSettingDefaults.minplayers)
	settings["#maxplayers"] = toJSON(currentMapSettings.maxplayers or mapSettingDefaults.maxplayers)

	-- Add any gamemode settings to the info table
	if ( currentMapSettings.gamemodeSettings and #currentMapSettings.gamemodeSettings > 0 ) then

		for row, value in pairs(currentMapSettings.gamemodeSettings) do
			local data = currentMapSettings.rowData[row].internalName
			settings['#'..data] = toJSON(value)
		end
	else -- Try currentMapSettings.newSettings
		for row, value in pairs(currentMapSettings.newSettings or {}) do
			settings['#'..row] = toJSON(value)
		end
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

	--Add the mapEditorScriptingExtension scripts to meta
	local scriptName = "mapEditorScriptingExtension_s.lua"
	local foundScriptInMeta = false
	for i, child in ipairs(xmlNodeGetChildren(xml)) do
		if (xmlNodeGetAttribute(child, "src") == scriptName) then
			foundScriptInMeta = true
			break
		end
	end
	if (not foundScriptInMeta) then
		local scriptNode = xmlCreateChild(xml, "script")
		xmlNodeSetAttribute(scriptNode, "src", scriptName)
		xmlNodeSetAttribute(scriptNode, "type", "server")
	end
	fileCopy("server/"..scriptName, ":"..getResourceName(resource).."/"..scriptName, true)

	scriptName = "mapEditorScriptingExtension_c.lua"
	foundScriptInMeta = false
	for i, child in ipairs(xmlNodeGetChildren(xml)) do
		if (xmlNodeGetAttribute(child, "src") == scriptName) then
			foundScriptInMeta = true
			break
		end
	end
	if (not foundScriptInMeta) then
		local scriptNode = xmlCreateChild(xml, "script")
		xmlNodeSetAttribute(scriptNode, "src", scriptName)
		xmlNodeSetAttribute(scriptNode, "type", "client")
		xmlNodeSetAttribute(scriptNode, "validate", "false")
	end
	fileCopy("client/"..scriptName, ":"..getResourceName(resource).."/"..scriptName, true)

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
