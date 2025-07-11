function addResourceMap ( resource, filename, dimension )
	if not resource then return false end
	local currentFiles = getResourceFiles ( resource, "map" )
	for k,path in ipairs(currentFiles) do
		if path == filename then
			return false
		end
	end
	--
	local newMap = xmlCreateFile ( ':' .. getResourceName(resource) .. '/' .. filename, "map" )
	xmlSaveFile ( newMap )
	return newMap
end

function insertResourceFile ( resource, path, filetype )
	local metaNode = xmlLoadFile ( ':' .. getResourceName(resource) .. '/' .. "meta.xml" )
    local node = xmlCreateChild ( metaNode, filetype )
    xmlNodeSetAttribute ( node, "src", path )
	xmlSaveFile ( metaNode )
	xmlUnloadFile ( metaNode )
end

function removeResourceFile ( resource, path, filetype )
	local metaNode = xmlLoadFile ( ':' .. getResourceName(resource) .. '/' .. "meta.xml" )
	local i = 0
	while xmlFindChild ( metaNode, filetype, i ) ~= false do
		local node = xmlFindChild ( metaNode, filetype, i )
		local src = xmlNodeGetAttribute ( node, "src" )
		if src == path then
			xmlDestroyNode ( node )
		end
		i = i + 1
	end
	xmlSaveFile ( metaNode )
	xmlUnloadFile ( metaNode )
	return fileDelete ( ':' .. getResourceName(resource) .. '/' .. path )
end

local quickRemove = { map=true, setting=true, settings=true }

function clearResourceMeta ( resource, quick ) --removes settings and info nodes
	local metaNode = xmlLoadFile ( ':' .. getResourceName(resource) .. '/' .. "meta.xml" )
	while true do
		local infoNode = xmlFindChild(metaNode, "info", 0)
		if infoNode then
			--Remove the resource info from memory before removing from xml
			local attributes = xmlNodeGetAttributes ( infoNode )
			for attributesName in pairs(attributes) do
				setResourceInfo ( resource, attributesName, nil )
			end
			xmlDestroyNode(infoNode)
		else
			break
		end
	end
	--Destroy leftover OOP nodes
	while true do
		local oopNode = xmlFindChild(metaNode, 'oop', 0)
		if oopNode then
			xmlDestroyNode(oopNode)
		else
			break
		end
	end
	--Destroy any other nodes
	local nodes = xmlNodeGetChildren ( metaNode )
	for key, node in ipairs(nodes) do
		if quick then
			local name = xmlNodeGetAttribute ( node, "src" ) or ""
			local nodeName = xmlNodeGetName ( node )
			if ( quickRemove [ nodeName ] or nodeName == "script" and name:find ( "mapEditorScriptingExtension" ) ) then
				xmlDestroyNode ( node )
			end
		else
			xmlDestroyNode ( node )
		end
	end
	xmlSaveFile ( metaNode )
	xmlUnloadFile ( metaNode )
	return true
end

function getResourceFiles ( resource, fileType )
	local resourceExists = false
	for i, res in ipairs(getResources()) do
		if ( res == resource) then
			resourceExists = true
			break
		end
	end
	if (not resourceExists) then return false, "no resource" end
	resource = getResourceName(resource)
	if (not resource) then return false, "no resource" end
	local meta = xmlLoadFile ( ':' .. resource .. '/' .. "meta.xml" )
	if not meta then return false, "no meta" end
	local files = {}
	local fileAttributes = {}
	local i = 0
	while xmlFindChild ( meta, fileType, i ) ~= false do
		local node = xmlFindChild ( meta, fileType, i )
		local file = xmlNodeGetAttribute ( node, "src" )
		local otherAttributes = xmlNodeGetAttributes ( node )
		otherAttributes.src = nil
		if fileAttributes[file] then
			outputDebugString("getResourceFiles: Found duplicate meta entry in '".. resource .."' (".. fileType .. " - ".. file .. ")")
		else
			fileAttributes[file] = otherAttributes
			table.insert ( files, file )
		end
		i = i + 1
	end
	xmlUnloadFile ( meta )
	return files,fileAttributes
end

local fileTypes = { "script","file","config","html" }
function copyResourceFiles ( fromResource, targetResource )
	local targetPaths = {}
	local copiedFiles = {}
	for i, fileType in ipairs(fileTypes) do
		targetPaths[fileType] = {}
		local paths, attr = getResourceFiles(fromResource, fileType)
		if paths then
			for j,filePath in ipairs(paths) do
				local copyPath, copyTarget = ":" .. getResourceName(fromResource) .. "/" .. filePath, ":" .. getResourceName(targetResource) .. "/" .. filePath
				if fileExists(copyTarget) then
					outputDebugString("copyResourceFiles: File '".. copyTarget .."' has duplicate meta entries, cannot overwrite.")
				else
					fileCopy ( copyPath, copyTarget, false )
					local data = attr[filePath]
					data.src = filePath
					table.insert ( targetPaths[fileType], data )
				end
			end
		else
			outputDebugString("copyResourceFiles: getResourceFiles returned "..tostring(paths).." and "..tostring(attr).." for "..tostring(fromResource).." and "..tostring(fileType))
		end
	end
	--Return a table of new target paths
	return targetPaths
end

local function recursiveDimensionSet(baseElement, dimension)
	for i, element in ipairs(getElementChildren(baseElement)) do
		recursiveDimensionSet(element, dimension)
	end
	setElementDimension(baseElement, dimension)
end

function flattenTree ( baseElement, newParent, newEditorParent, resourceTable )
	local tick = getTickCount()
	resourceTable = resourceTable or {}

	for i, element in ipairs(getElementChildren(baseElement)) do
		flattenTreeRuns = ( flattenTreeRuns or 0 ) + 1
		local elementType = getElementType(element)
		if (elementType == "vehicle" and getVehicleType(element) == "Train") then
			setTrainDerailed(element, true)
			local x, y, z = getElementPosition(element)
			setElementPosition(element, x, y, z)
		end
		if not resourceTable[elementType] then
			resourceTable[elementType] = edf.edfGetResourceForElementType(elementType)
		end

		if resourceTable[elementType] and not edf.edfIsRepresentation(element) then
			local fromResource = resourceTable[elementType]
			local edfElements = loadedEDF[fromResource].elements
			local elementID = getElementID(element)
			local elementDimension = edf.edfGetElementDimension(element) or 0

			local creationParameters = {}
			for dataField, dataDefinition in pairs(edfElements[elementType].data) do
				local propertyData = edf.edfGetElementProperty(element, dataField)
				if propertyData then
					creationParameters[dataField] = propertyData
				elseif dataDefinition.required then
					creationParameters[dataField] = dataDefinition.default
				end
			end
			creationParameters.position = {edf.edfGetElementPosition(element)}
			creationParameters.rotation = {edf.edfGetElementRotation(element)}
			creationParameters.scale = edf.edfGetElementScale(element)
			creationParameters.interior = edf.edfGetElementInterior(element) or nil
			creationParameters.alpha = edf.edfGetElementAlpha(element) or 255

			local editorElement = edf.edfRepresentElement(element, fromResource, creationParameters, true)
			if newEditorParent then
				setElementData(editorElement, "me:parent", newEditorParent)
			end
			assignID(editorElement)
			setElementParent(editorElement, newParent)
			recursiveDimensionSet(editorElement, getWorkingDimension())
			makeElementStatic(editorElement)

			setElementData(editorElement, "me:dimension", elementDimension)

			flattenTree ( element, newParent, editorElement, resourceTable )
		end

		if getTickCount() >= tick + 500 or ( DEBUG_LOADSAVE and i < 40 ) then
			triggerClientEvent(root, "saveLoadProgressBar", root, flattenTreeRuns)
			coroutine.yield()
			tick = getTickCount()
		end
	end
	return true
end
