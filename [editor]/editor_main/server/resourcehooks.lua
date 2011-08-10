function addResourceMap ( resource, filename, dimension )
	if not resource then return false end
	dimension = dimension or 0
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
	--Destroy any other nodes
	local nodes = xmlNodeGetChildren ( metaNode )
	for key, node in ipairs(nodes) do
		if quick then
			if quickRemove[xmlNodeGetName ( node )] then
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
	local meta = xmlLoadFile ( ':' .. getResourceName(resource) .. '/' .. "meta.xml" )
	if not meta then return false end
	local files = {}
	local fileAttributes = {}
	local i = 0
	while xmlFindChild ( meta, fileType, i ) ~= false do
		local node = xmlFindChild ( meta, fileType, i )
		local file = xmlNodeGetAttribute ( node, "src" )
		local otherAttributes = xmlNodeGetAttributes ( node )
		otherAttributes.src = nil
		fileAttributes[file] = otherAttributes
		table.insert ( files, file )
		i = i + 1
	end
	xmlUnloadFile ( meta )
	return files,fileAttributes
end

local fileTypes = { "script","file","config","html" } 
function copyResourceFiles ( fromResource, targetResource )
	local targetPaths = {}
	local copiedFiles = {}
	for i,fileType in ipairs(fileTypes) do
		targetPaths[fileType] = {}
		local paths,attr = getResourceFiles(fromResource,fileType)
		for j,filePath in ipairs(paths) do
			fileCopy ( filePath, fromResource, filePath, targetResource )
			local data = attr[filePath]
			data.src = filePath
			table.insert ( targetPaths[fileType], data )
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
	local resourceTable = resourceTable or {}

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
			creationParameters.interior = edf.edfGetElementInterior(element) or nil

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
		
		if getTickCount() >= tick + 500 then
			triggerClientEvent(root, "saveLoadProgressBar", root, flattenTreeRuns)
			coroutine.yield()
			tick = getTickCount()
		end
	end
	return true
end

function fileCopy ( path, fromResource, targetPath, targetResource )
	local sourceFile = fileOpen(':' .. getResourceName(fromResource) .. '/' .. path, true)
	if sourceFile then
		local readBuffer = 0
		local buffer
		local targetFile = fileCreate (':' .. getResourceName(targetResource) .. '/' .. targetPath)
		while not fileIsEOF(sourceFile) do
			buffer = fileRead(sourceFile, 500)
			readBuffer = readBuffer + 500
			fileWrite ( targetFile, buffer )
		end
		fileClose(sourceFile)
		fileClose(targetFile)
		return true
	else
		return false
	end
end
