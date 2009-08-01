---------------------------------------------------------------------
--private variables
---------------------------------------------------------------------

local edf = {}
local edfStarted = {}
local thisResource = getThisResource()
local rootElement = getRootElement()
createResourceCallInterface("mapmanager")
addEvent"onElementPropertyChanged"

local DUMMY_ID = 3003
local DUMMY_DIMENSION = -99
local DUMMY_INTERIOR = 14

-- basic types list
local basicTypes = {
	"object","vehicle","pickup","marker","blip","colshape","radararea","ped","water"
}

-- basic types lookup table
local isBasic = {}
for k, theType in ipairs(basicTypes) do
	isBasic[theType] = true
end

-- basic element create functions table (cdata holds creation parameters)
local edfCreateBasic = {
	object = function(cdata)
		return createObject(cdata.model, cdata.position[1], cdata.position[2], cdata.position[3], cdata.rotation[1], cdata.rotation[2], cdata.rotation[3])
	end,
	vehicle = function(cdata)
		local vehicle = createVehicle(cdata.model, cdata.position[1], cdata.position[2], cdata.position[3], cdata.rotation[1], cdata.rotation[2], cdata.rotation[3], cdata.plate)
		if cdata.color then
			setVehicleColor ( vehicle, cdata.color[1], cdata.color[2], cdata.color[3], cdata.color[4] )
		end
		if cdata.upgrades then
			for i, upgrade in ipairs(cdata.upgrades) do
				addVehicleUpgrade(vehicle, upgrade)
			end
		end
		return vehicle
	end,
	marker = function(cdata)
		local r,g,b,a = getColorFromString(cdata.color)
		if r then cdata.colorR = r; cdata.colorG = g; cdata.colorB = b; cdata.colorA = a end
		return createMarker(cdata.position[1], cdata.position[2], cdata.position[3], cdata.type, cdata.size, cdata.colorR, cdata.colorG, cdata.colorB, cdata.colorA)
	end,
	pickup = function(cdata)
		local pType, pAmount, pAmmo
		if cdata.type == "health" then
			pType = 0
			pAmount = cdata.amount
		elseif cdata.type == "armor" then
			pType = 1
			pAmount = cdata.amount
		else
			pType = 2
			pAmount = tonumber(cdata.type)
			pAmmo = cdata.amount
		end
		
		local pickup
		if pAmmo then
			pickup = createPickup(cdata.position[1], cdata.position[2], cdata.position[3], pType, pAmount, cdata.respawn, pAmmo)
		else
			pickup = createPickup(cdata.position[1], cdata.position[2], cdata.position[3], pType, pAmount, cdata.respawn)
		end
		
		--! workaround
		setElementData(pickup, "edf:p:amount", pAmount)
		setElementData(pickup, "edf:p:respawn", cdata.respawn)
		
		return pickup
	end,
	blip = function(cdata)
		local r,g,b,a = getColorFromString(cdata.color)
		if r then cdata.colorR = r; cdata.colorG = g; cdata.colorB = b; cdata.colorA = a end
		return createBlip(cdata.position[1], cdata.position[2], cdata.position[3], cdata.icon, cdata.size, cdata.colorR, cdata.colorG, cdata.colorB, cdata.colorA)
	end,
	radararea = function(cdata)
		local r,g,b,a = getColorFromString(cdata.color)
		if r then cdata.colorR = r; cdata.colorG = g; cdata.colorB = b; cdata.colorA = a end
		return createRadarArea(cdata.posX, cdata.posY, cdata.sizeX, cdata.sizeY, cdata.colorR, cdata.colorG, cdata.colorB, cdata.colorA)
	end,
	colshape = function(cdata)
		if cdata.type == "sphere" then
			return createColSphere(cdata.position[1], cdata.position[2], cdata.position[3], cdata.radius)
		elseif cdata.type == "tube" then
			return createColTube(cdata.position[1], cdata.position[2], cdata.position[3], cdata.radius, cdata.height)
		elseif cdata.type == "rectangle" then
			return createColRectangle(cdata.position[1], cdata.position[2], cdata.position[3], cdata.width, cdata.depth)
		elseif cdata.type == "cube" or cdata.type == "cuboid" then
			return createColCube(cdata.position[1], cdata.position[2], cdata.position[3], cdata.width, cdata.depth, cdata.height)
		end
	end,
	ped = function(cdata)
		local ped = createPed ( cdata.model, cdata.position[1], cdata.position[2], cdata.position[3] )
		setPedRotation ( ped, (cdata.rotZ or 0) )
		return ped
	end,
	water = function(cdata)
		return createWater ( 
			cdata.position[1] - cdata.sizeX/2, cdata.position[2] - cdata.sizeY/2, cdata.position[3],
			cdata.position[1] + cdata.sizeX/2, cdata.position[2] - cdata.sizeY/2, cdata.position[3],
			cdata.position[1] - cdata.sizeX/2, cdata.position[2] + cdata.sizeY/2, cdata.position[3],
			cdata.position[1] + cdata.sizeX/2, cdata.position[2] + cdata.sizeY/2, cdata.position[3]
		)
	end,
}

-- table to keep track of created representations
local createdRepresentations = {}

-- EDF events
addEvent("onEDFLoad")
addEvent("onEDFUnload")

addEventHandler("onResourceStart", rootElement,
	function (resource)
		--stop here if the resource disables edf checking
		if getResourceInfo(resource,"edf:represent") == "false" then
			return
		end
		
		if mapmanager.isMap(resource) then
			outputDebugString('Going to represent map ' .. getResourceName(resource),0,180,180,255)
			-- if it's a map, represent it
			local startedResourceRoot = getResourceRootElement(resource)
			local startedResourceMaps = getElementChildren(startedResourceRoot)
			local gamemodes = mapmanager.getGamemodesCompatibleWithMap(resource)
			
			for i,gamemode in ipairs(gamemodes) do
				if edf[gamemode] then
					for k, map in ipairs(startedResourceMaps) do
						local mapElements = getElementChildren(map)
						for k, element in ipairs(mapElements) do
							edfRepresentElement(element, gamemode)
						end
					end
				end
			end
		else
			if edfStarted[resource] then return end
			local resourcename = getResourceName(resource)
			
			-- otherwise it may contain an edf definition
			local def = edfLoadDefinition(resource)
			-- stop here if it couldn't be loaded
			if not def then return end
			if edfStarted[resource] == false then
				edfStarted[resource] = true
			end
			-- Notify that the load has been successful
			outputDebugString("Loaded definitions for '"..resourcename.."'.",0,180,180,255)
		end
	end
)

addEventHandler("onResourceStop", rootElement,
	function (resource)
		if edfStarted[resource] then return end
		edfUnloadDefinition(resource)
		if createdRepresentations[resource] then
			for k, element in ipairs(createdRepresentations[resource]) do
				if isElement(element) then destroyElement(element) end
			end
			createdRepresentations[resource] = nil
		end
	end
)

---------------------------------------------------------------------
--public functions
---------------------------------------------------------------------

function edfStartResource ( resource )
	if not getResourceName(resource) or getResourceState ( resource ) == "running" then
		return false
	end
	edfStarted[resource] = false
	return startResource ( resource,false,false,true,false,false,false,false,false,true)
end

function edfStopResource ( resource )
	if not getResourceName(resource) or getResourceState ( resource ) ~= "running" then
		return false
	end
	edfStarted[resource] = nil
	return stopResource ( resource )
end

--Loads [fromResource]'s definition to edf[inResource] (alreadyLoaded is for circular-inclusion protection purposes)
function edfLoadDefinition(fromResource, inResource, alreadyLoaded)
	local fromResourceName = getResourceName(fromResource)
	
	--get the EDF filename
	local definitionName = getResourceInfo(fromResource, "edf:definition")
	if not definitionName then
		return false
	end
	--try to load it
	local definitionRoot = xmlLoadFile(':' .. getResourceName(fromResource) .. '/' .. definitionName)
	if not definitionRoot then
		outputDebugString(fromResourceName .. ': couldn\'t load edf file', 1)
		return false
	end
	
	--if we weren't told where to load it, it's in the def for the same resource we loaded it from
	if not inResource then inResource = fromResource end
	
	--create a new table if there is no definition loaded
	edf[inResource] = edf[inResource] or {}
	local definition = edf[inResource]
	
	--store the definition name
	edf[inResource].definitionName = xmlNodeGetAttribute(definitionRoot,"name")
	
	createdRepresentations[inResource] = {}
	
	--load all extended resources to be used as a base, and avoid circular extension
	local extends = xmlNodeGetAttribute(definitionRoot,"extends")
	if extends then
		--get all extended resource names separated by commas
		extends = split(extends,44)
		
		alreadyLoaded = alreadyLoaded or {}
		alreadyLoaded[fromResourceName] = true
		
		--for each resource it extends
		for k, extendedResourceName in ipairs(extends) do
			-- ignore it if it's the base definition, as it's always loaded
			if extendedResourceName ~= getResourceName(thisResource) then
				if alreadyLoaded[extendedResourceName] then
					outputDebugString("You can't extend resource '"..extendedResourceName.."'s EDF with '"..fromResourceName.."' twice.",2)
				else
					--if there's no circular extensions, load the def
					alreadyLoaded[extendedResourceName] = true
					local extendedResource = getResourceFromName(extendedResourceName)
					edfLoadDefinition(extendedResource, fromResource, alreadyLoaded)
				end
			end
		end
	end
	
	local i
	
	definition.elements = {}
	--this loop stores node data and parents for every element in the loaded EDF definition
	i = 0
	repeat
		--try to get a new node until we go out of range
		local node = xmlFindChild(definitionRoot, "element", i)
		if not node then break end

		--check the element has a defined type name
		local name = xmlNodeGetAttribute(node,"name")
		if name then
			--create a new data table if there wasn't one already
			definition.elements[name] = definition.elements[name] or {}
			--add the node data to the type definition
			edfAddElementNodeData(node,inResource)
			--add the node parents to the type definition
			edfAddElementNodeParents(node,inResource)
		end
		
		i = i + 1
	until false
	
	--this loop stores the children data for every element in the EDF
	i = 0
	repeat
		--try to get a new node until we go out of range
		local node = xmlFindChild(definitionRoot,"element",i)
		if not node then break end
		
		--check the element has a defined type name
		local name = xmlNodeGetAttribute(node,"name")
		if name then
			--add the children data to the type definition
			edfAddElementNodeChildren(node,inResource)
		end
		
		i = i + 1
	until false
	
	definition.settings = {}
	i = 0
	repeat
		--try to get a new node until we go out of range
		local node = xmlFindChild(definitionRoot,"setting",i)
		if not node then break end
		
		--check the element has a defined type name
		local name = xmlNodeGetAttribute(node,"name")
		if name then
			--add the children data to the type definition
			edfAddSettingNodeData(node,inResource)
		end
		
		i = i + 1
	until false
	
	i = 0
	local serverScripts,clientScripts = {},{}
	repeat
		--try to get a new node until we go out of range
		local node = xmlFindChild(definitionRoot,"script",i)
		if not node then break end
		
		--check the element has a defined type name
		local name = xmlNodeGetAttribute(node,"src")
		if name then
			if xmlNodeGetAttribute(node,"type") == "client" then
				table.insert(clientScripts,name)
			else
				table.insert(serverScripts,name)
			end
		end			
		i = i + 1
	until false
	readScripts(serverScripts,clientScripts,fromResource)
	--if we've reached this point, trigger the load event
	local triggerFrom = rootElement
	if getResourceState(fromResource) == "running" then
		triggerFrom = getResourceRootElement(fromResource)
	end
	triggerEvent("onEDFLoad",triggerFrom,fromResource)
	
	xmlUnloadFile(definitionRoot)

	return true
end

--Unloads [resource]'s definition
function edfUnloadDefinition(resource)
	--Destroy the actual custom elements
	if not edf[resource] then return false end
	for elementName,dataTable in pairs(edf[resource].elements) do
		for i,element in ipairs(getElementsByType(elementName)) do
			if edfGetCreatorResource(element) == resource then
				destroyElement( element )
			end
		end
	end
	edf[resource] = nil
	
	triggerEvent("onEDFUnload",rootElement,resource)
	
	return true
end

--Represents an [element] according to its definition in edf[resource].elements
function edfRepresentElement(theElement, resource, parentData, editorMode, restricted)
	local elementType = getElementType(theElement)
	
	-- make elementDefinition point to the element's definition
	local elementDefinition = edf[resource]["elements"][elementType]
	
	-- quit if that resource doesn't have a representation for it
	if not elementDefinition then
		outputDebugString('No definition for ' .. elementType)
		return false
	end
	
	-- if a creator resource doesn't exist, set it as the new resource
	local resourceName = getElementData( theElement, "edf:creator" )
	if not resourceName then
		setElementData ( theElement, "edf:creator", getResourceName(resource) )
	end
	
	-- don't represent it if that'd make it go over the instance limit
	local limit = elementDefinition.limit
	if limit and #getElementsByType(elementType) > limit then
		outputDebugString("'"..elementType.."' limit exceeded, not representing.",2)
		return false
	end
	
	-- check all defined fields for validity and stores them in a parent data table
	local parentData = parentData or {}
	for dataField, dataDefinition in pairs(elementDefinition.data) do
		local checkedData = edfCheckElementData(theElement, dataField, dataDefinition)
		if checkedData == nil then
			outputDebugString('Failed validation for ' .. elementType .. '!' .. dataField)
			return false
		end
		
		parentData[dataField] = checkedData
	end
	
	-- get the position and rotation
	parentData.position = parentData.position or { edfGetElementPosition(theElement) }
	if not parentData.position[1] then
		parentData.position = {0,0,0}
	end
	
	parentData.rotation = parentData.rotation or { edfGetElementRotation(theElement) }
	if not parentData.rotation[1] then
		parentData.rotation = {0,0,0}
	end
	
	--ensure a dimension & interior is set
	parentData.dimension = parentData.dimension or 0
	parentData.interior = parentData.interior or 0
	
	setElementDimension ( theElement, parentData.dimension )

	-- if there are children,
	if #elementDefinition.children > 0 then
		-- determine if the element children will be glued together
		-- (always glue them if we're on editor mode)
		
		glued = elementDefinition.glued or editorMode
		
		local dummyElement
		
		if glued then
			dummyElement = createObject(
				DUMMY_ID,
				parentData.position[1],
				parentData.position[2],
				parentData.position[3],
				parentData.rotation[1],
				parentData.rotation[2],
				parentData.rotation[3]
			)
			-- setObjectScale(dummyElement,0)
			setElementDimension(dummyElement, parentData.dimension)
			setElementInterior(dummyElement, parentData.interior)
			
			setElementParent(dummyElement, theElement)
			setElementData(dummyElement, "edf:rep", true)
			setElementData(dummyElement, "edf:dummy", true)
			setElementData(theElement, "edf:handle", dummyElement)
			table.insert(createdRepresentations[resource], dummyElement)
			--
			triggerClientEvent ( "hideDummy", dummyElement )
		end
		
		-- for each child,
		for index, definedChild in ipairs(elementDefinition.children) do
			local component, componentHandle
			local inherited = {}
			-- skip editor-only reps if not in editor mode
			if editorMode then
				-- if it is a basic type,
				if isBasic[definedChild.type] then
					-- we'll build a new table with this child's data
					local childData = {}
					-- for each defined datafield and its value,
					for dataField, dataValue in pairs(definedChild.data) do
						-- if it has to be inherited,
						if
							type(dataValue) == "string" and
							string.sub(dataValue,1,1) == '!' and
							string.sub(dataValue, -1) == '!'
						then
							inherited[string.sub(dataValue,2,-2)] = dataField
							-- get it from the parent data table
							local parentDataField = string.sub(dataValue,2,-2)
							dataValue = parentData[parentDataField]
							
						-- if it is a position or rotation, add the parent's
						elseif
							dataField == "position" or dataField == "rotation"
						then
							local newCoord = {}
							for i, value in ipairs(dataValue) do
								newCoord[i] = value + parentData[dataField][i]
							end
							dataValue = newCoord
						end
						
						childData[dataField] = dataValue
					end
					
					-- create our basic element
					component = edfCreateBasic[definedChild.type](childData)

					componentHandle = component
					
					setElementInterior(component, parentData.interior)
					setElementDimension(component, parentData.dimension)
					
				-- if it is a custom type,
				else
					-- build a restriction table if we don't have one,
					restricted = restricted or {}
					-- and mark our current type as restricted
					restricted[elementType] = true
					
					-- if the type was restricted, warn and don't do anything
					if restricted[definedChild.type] then
						outputDebugString("Circular inclusion in element '"..elementType.."': you can't include the type '"..definedChild.type.."' again.",2)
					else
						component = createElement(definedChild.type)
					
						-- we'll build a new table with this element's data,
						-- based on that of its parent
						local subParentData = parentData
						-- for each defined datafield and its value,
						for dataField, dataValue in pairs(definedChild.data) do
							-- if it has to be inherited,
							if
								type(dataValue) == "string" and
								string.sub(dataValue,1,1) == '!' and
								string.sub(dataValue, -1) == '!'
							then
								inherited[string.sub(dataValue,2,-2)] = true
								-- get it from the parent data table
								local parentDataField = string.sub(dataValue,2,-2)
								dataValue = parentData[parentDataField]
							end
							subParentData[dataField] = dataField
						end
						
						component = edfRepresentElement(component, resource, subParentData, editorMode, restricted)
						componentHandle = edfGetHandle(component)
					end
				end
				
				if component then
					setElementData (component,"edf:inherited",inherited)
					setElementParent(component, theElement)
					setElementData(component, "edf:rep", true)

					if glued then
						local offset = definedChild.data.position or {0,0,0}
						attachElements(componentHandle, dummyElement, unpack(offset))
					end
					table.insert(createdRepresentations[resource],component)
				end
			end
		end --for loop
	end --if check
	
	return theElement
end

--Creates an [elementType] element as defined in [fromResource] and represents it
function edfCreateElement(elementType, fromResource, parametersTable, editorMode)
	local theElement
	
	if not edf[fromResource] then
		outputDebugString("edfCreateElement: Resource '"..getResourceName(fromResource).."'s definition isn't loaded.",1)
		return false
	end
	
	if not edf[fromResource]["elements"][elementType] then
		outputDebugString("edfCreateElement: Resource '"..getResourceName(fromResource).."' doesn't define type '"..elementType.."'.",1)
		return false
	end
	
	parametersTable = parametersTable or {}
	parametersTable.position = parametersTable.position or {0,0,0}
	parametersTable.rotation = parametersTable.rotation or {0,0,0}
	parametersTable.interior = parametersTable.interior or 0
	parametersTable.dimension = parametersTable.dimension or 0

	if isBasic[elementType] then
		local childData = {}
		for property, propertyData in pairs(edf[fromResource]["elements"][elementType].data) do
			--try to get the given value in target datatype
			if convert[propertyData.datatype] then
				parametersTable[property] = convert[propertyData.datatype](parametersTable[property])
			end
			--store the value, or its default
			childData[property] = parametersTable[property] or propertyData.default
		end

		theElement = edfCreateBasic[elementType](childData)
		
		setElementInterior(theElement, parametersTable.interior)
		setElementDimension(theElement, parametersTable.dimension)
		
		-- setElementData if it is not an edf property
		for dataField, dataValue in pairs(parametersTable) do
			if not edf[fromResource]["elements"][elementType].data[dataField] then
				setElementData(theElement, dataField, dataValue)
			end
		end
	else
		local newElement = createElement(elementType)
		if not newElement then
			return false
		end
				
		for dataField, dataValue in pairs(parametersTable) do
			if dataField == "position" then
				edfSetElementPosition(newElement, dataValue[1], dataValue[2], dataValue[3])
			elseif dataField == "rotation" then
				edfSetElementRotation(newElement, dataValue[1], dataValue[2], dataValue[3])
			else
				setElementData(newElement, dataField, dataValue)
			end
		end
		
		theElement = edfRepresentElement(newElement, fromResource, parametersTable, editorMode)
		if not theElement then
			destroyElement(newElement)
			return false
		end
	end

	setElementData(theElement, "edf:creator", getResourceName(fromResource))
	
	return theElement
end

function edfCloneElement(theElement, editorMode )
	if not isElement(theElement) then
		outputDebugString("edfCloneElement: Invalid element specified.",1)
		return false
	end
	local creatorResource = edfGetCreatorResource(theElement)
	local elementType = getElementType(theElement)
	
	if not edf[creatorResource] then
		outputDebugString("edfCreateElement: Resource '"..getResourceName(fromResource).."'s definition isn't loaded.",1)
		return false
	end
	
	if not edf[creatorResource]["elements"][elementType] then
		outputDebugString("edfCreateElement: Resource '"..getResourceName(fromResource).."' doesn't define type '"..elementType.."'.",1)
		return false
	end
	
	parametersTable = {}
	parametersTable.position = {edfGetElementPosition(theElement)} or {0,0,0}
	parametersTable.rotation = {edfGetElementRotation(theElement)} or {0,0,0}
	parametersTable.interior = edfGetElementInterior(theElement) or 0
	parametersTable.dimension = edfGetElementDimension(theElement) or 0
	
	if isBasic[elementType] then
		local childData = {}
		for property, propertyData in pairs(edf[creatorResource]["elements"][elementType].data) do
			--try to get the given value in target datatype
			if convert[propertyData.datatype] then
				parametersTable[property] = convert[propertyData.datatype](parametersTable[property])
			end
			--store the value, or its default
			childData[property] = parametersTable[property] or propertyData.default
		end
		
		theElement = cloneElement(theElement)
		
		setElementInterior(theElement, parametersTable.interior)
		setElementDimension(theElement, parametersTable.dimension)
	else
		local newElement = cloneElement(theElement)
		if not newElement then
			return false
		end
		
		for dataField, dataValue in pairs(parametersTable) do
			if dataField == "position" then
				edfSetElementPosition(newElement, dataValue[1], dataValue[2], dataValue[3])
			elseif dataField == "rotation" then
				edfSetElementRotation(newElement, dataValue[1], dataValue[2], dataValue[3])
			else
				setElementData(newElement, dataField, dataValue)
			end
		end
		
		theElement = edfRepresentElement(newElement, creatorResource, parametersTable, editorMode)
		if not theElement then
			destroyElement(newElement)
			return false
		end
	end

	setElementData(theElement, "edf:creator", getResourceName(creatorResource))
	
	return theElement
end

--Updates an [element]'s visual representation according to element data changes
function edfUpdateRepresentation(theElement, resource, editorMode)
	if not edf[resource] then
		return false
	end
	for i, child in ipairs(getElementChildren(theElement)) do
		--destroy all reps
		if edfGetParent(child) == theElement then
			destroyElement(child)
		end
	end
	--represent it again
	edfRepresentElement(theElement, resource, false, editorMode)
end

--Returns a list of resources whose defs are loaded
function edfGetLoadedEDFResources()
	local loadedDefinitions = {}
	for resource in pairs(edf) do
		table.insert(loadedDefinitions, resource)
	end
	
	return loadedDefinitions
end

--Returns a full def for a resource
function edfGetDefinition(fromResource)
	if edf[fromResource] == nil then
		outputDebugString("edfGetDefinition: The definition from resource '"..tostring(getResourceName(fromResource)).."' isn't loaded.",1)
		return false
	else
		return edf[fromResource]
	end
end

--Returns whether a resource has a definition or not
function edfHasDefinition(resource)
	if getResourceInfo(resource, "edf:definition") then
		return true
	else
		return false
	end
end

--Returns a custom element's invisible handle
function edfGetHandle( edfElement )
	return getElementData(edfElement, "edf:handle") or false
end

--Returns whether or not an element is part of an edf element's representation
function edfIsRepresentation( elem )
	return getElementData(elem, "edf:rep")
end

--Returns an element's EDF parent
function edfGetParent( repPart )
	if getElementData(repPart, "edf:rep") then
		return getElementParent(repPart)
	else
		return repPart
	end
end

--Returns an element's EDF ancestor
function edfGetAncestor( repPart )
	if getElementData(repPart, "edf:rep") then
		return edfGetAncestor( getElementParent(repPart) )
	else
		return repPart
	end
end

--Returns a custom element's creator resource
function edfGetCreatorResource( edfElement )
	local resourceName = getElementData( edfElement, "edf:creator" )
	if resourceName then
		return getResourceFromName( resourceName )
	else
		return thisResource
	end
end

--Forcefully sets the creator
function edfSetCreatorResource( edfElement, creator )
	return setElementData( edfElement, "edf:creator", getResourceName(creator) )
end

--Returns an element's position, or its posX/Y/Z element data, or false
function edfGetElementPosition(element)
	local px, py, pz
	if isBasic[getElementType(element)] then
		px, py, pz = getElementPosition(element)
	else
		local handle = edfGetHandle(element)
		if handle then
			px, py, pz = getElementPosition(handle)
		else
			px = tonumber(getElementData(element,"posX"))
			py = tonumber(getElementData(element,"posY"))
			pz = tonumber(getElementData(element,"posZ"))
		end
	end
	
	if px and py and pz then
		return px, py, pz
	else
		return false
	end
end

--Returns an element's rotation, or its rotX/Y/Z element data, or false
function edfGetElementRotation(element)
	local etype = getElementType(element)
	local rx, ry, rz
	if etype == "object" then
		rx, ry, rz = getObjectRotation(element)
	elseif etype == "vehicle" then
		rx, ry, rz = getVehicleRotation(element)
	elseif etype == "player" or etype == "ped" then
		rx = 0
		ry = 0
		rz = getPedRotation(element)
	else
		local handle = edfGetHandle(element)
		if handle then
			rx, ry, rz = getObjectRotation(handle)
		else
			rx = tonumber(getElementData(element,"rotX"))
			ry = tonumber(getElementData(element,"rotY"))
			rz = tonumber(getElementData(element,"rotZ"))
		end
	end
	
	if rx and ry and rz then
		return rx, ry, rz
	else
		return false
	end
end

--Sets an element's position, or its posX/Y/Z element data
function edfSetElementPosition(element, px, py, pz)
	if isBasic[getElementType(element)] then
		if setElementPosition(element, px, py, pz) then
			triggerEvent ( "onElementPropertyChanged", element, "position" )
			return true
		end
	else
		local handle = edfGetHandle(element)
		if handle then
			if setElementPosition(handle, px, py, pz) then
				triggerEvent ( "onElementPropertyChanged", element, "position" )
			end
		else
			setElementData(element, "posX", px or 0)
			setElementData(element, "posY", py or 0)
			setElementData(element, "posZ", pz or 0)
			triggerEvent ( "onElementPropertyChanged", element, "position" )
			return true
		end
	end
end

--Sets an element's rotation, or its rotX/Y/Z element data
function edfSetElementRotation(element, rx, ry, rz)
	local etype = getElementType(element)
	if etype == "object" then
		return setObjectRotation(element, rx, ry, rz)
	elseif etype == "vehicle" then
		return setVehicleRotation(element, rx, ry, rz)
	elseif etype == "player" or etype == "ped" then
		return setPedRotation(element, rz)
	else
		local handle = edfGetHandle(element)
		if handle then
			return setObjectRotation(handle, rx, ry, rz)
		else
			setElementData(element, "rotX", rx or 0)
			setElementData(element, "rotY", ry or 0)
			setElementData(element, "rotZ", rz or 0)
			return true
		end
	end
end

function edfGetElementInterior(element)
	return getElementInterior(element) or tonumber(getElementData(element, "interior")) or 0
end

function edfSetElementInterior(element, interior)
	setElementInterior(element, interior)
	if getElementChildrenCount( element ) > 0 then
		for k, child in ipairs( getElementChildren( element ) ) do
			if edfGetParent(child) == edfGetParent(element) then
				edfSetElementInterior( child, interior )
			end
		end
	end
	return true
end

function edfGetElementDimension(element)
	return getElementDimension(element) or tonumber(getElementData(element, "dimension")) or 0
end

function edfSetElementDimension(element, dimension)
	setElementDimension(element, dimension)
	if getElementChildrenCount( element ) > 0 then
		for k, child in ipairs( getElementChildren( element ) ) do
			if edfGetParent(child) == edfGetParent(element) then
				edfSetElementDimension( child, dimension )
			end
		end
	end
	return true
end

function edfSetElementProperty(element, property, value)
	--Set the value for any representations
	edfSetElementPropertyForRepresentations(element,property,value)
	
	local elementType = getElementType(element)
	-- if our property is an entity attribute we have access to, set it
	if propertySetters[elementType] and propertySetters[elementType][property] then
		local wasSet = propertySetters[elementType][property](element, value)
		-- don't do anything else if this failed
		if not wasSet then
			return false
		end
	end
	setElementData(element, property, value)
	triggerEvent ( "onElementPropertyChanged", element, property )
	return true
end

function edfSetElementPropertyForRepresentations(element,property,value)
	--Check if the property is inherited to reps
	for k,child in ipairs(getElementChildren(element)) do
		if edfGetAncestor(child) == element then --Check that the child is a representation of the element
			local inherited = getElementData(child,"edf:inherited") 
			if inherited then
				--Check that the property is inherited to this child
				if inherited[property] then
					local elementType = getElementType(child)
					local dataField = inherited[property]
					if propertySetters[elementType] and propertySetters[elementType][dataField] then
						propertySetters[elementType][dataField](child, value)
					else --If this representation inherits data from another element
						edfSetElementPropertyForRepresentations(child,dataField,value)
					end
				end
			end
		end
	end
end

function edfGetElementProperty(element, property)
	local elementType = getElementType(element)
	-- if our property is an entity attribute we have access to, get it
	if propertyGetters[elementType] and propertyGetters[elementType][property] then
		return propertyGetters[elementType][property](element)
	else
		return getElementData(element, property, value)
	end
end

---------------------------------------------------------------------
--private functions
---------------------------------------------------------------------

--Stores [node]'s data for an EDF element type in edf[resource]["elements"][type]
function edfAddElementNodeData(node, resource)
	-- get the element type name
	local name = xmlNodeGetAttribute(node,"name")
	
	local typeDefinition = edf[resource]["elements"][name]
	
	-- update the type instance limit
	typeDefinition.limit = tonumber(xmlNodeGetAttribute(node,"limit"))
								or typeDefinition.limit
	-- update the type friendly name
	typeDefinition.friendlyname = xmlNodeGetAttribute(node,"friendlyname")
									   or typeDefinition.friendlyname
	-- update the type description
	typeDefinition.description = xmlNodeGetAttribute(node,"description")
									   or typeDefinition.description
	-- update the type icon
	typeDefinition.icon = xmlNodeGetAttribute(node,"icon")
									   or typeDefinition.icon
									   
	--update the name of the parent
	typeDefinition.parentName = xmlNodeGetAttribute(node,"parentName")
									   or typeDefinition.parentName
									   
	--update the description of the parent
	typeDefinition.parentDescription = xmlNodeGetAttribute(node,"parentDescription")
									   or typeDefinition.parentDescription
									   
	--update the type shortcut
	typeDefinition.shortcut = xmlNodeGetAttribute(node,"shortcut")
									   or typeDefinition.shortcut	
	local isValidShortcut
	-- update the type createable state
  -- If the "createable" attribute is not present, xmlNodeGetAttribute returns nil and then
  -- it defaults to true. If it's present, xmlNodeGetAttribute returns a string and then the
  -- value in that string is returned by convert.boolean().
	typeDefinition.createable = convert.boolean(xmlNodeGetAttribute(node,"createable") or true)
									   or typeDefinition.createable
	-- update the type glue state
	typeDefinition.glued = convert.boolean(xmlNodeGetAttribute(node,"glued"))
								or typeDefinition.glued
	
	-- declare the data fields table for this type
	typeDefinition.data = typeDefinition.data or {}
	-- make dataFields a reference to it to keep it short
	local dataFields = typeDefinition.data
	
	-- this loop adds all data fields to the definition table for our type
	local j = 0
	repeat
		-- try to get a new data node until we go out of range
		local subnode = xmlFindChild(node,"data",j)
		if not subnode then break end
		
		-- get the data field's name
		local dname = xmlNodeGetAttribute(subnode,"name")
		if dname then
			if string.lower(dname) == "id" then
				outputDebugString("ID is not an allowed data field name.",2)
			else
				-- create the data fields table if there isn't one already
				dataFields[dname] = dataFields[dname] or {}

				-- Keep the index that it had in the edf
				dataFields[dname].index = j

				-- update the data field's datatype
				dataFields[dname].datatype = xmlNodeGetAttribute(subnode,"type")
										 or dataFields[dname].datatype

				local validValues = gettok(dataFields[dname].datatype, 2, 58)
				if validValues then
					dataFields[dname].validvalues = split(validValues, 44)
					dataFields[dname].datatype = gettok(dataFields[dname].datatype, 1, 58)
				else
					dataFields[dname].validvalues = nil
				end

				-- update the data field's default value
				--local convertFunction = convert[dataFields[dname].datatype] or convert.string
				dataFields[dname].default = xmlNodeGetAttribute(subnode,"default")
											or dataFields[dname].default
				-- convert the default value to the datafield's type if a conversion function exists
				if convert[dataFields[dname].datatype] then
					dataFields[dname].default = convert[dataFields[dname].datatype](dataFields[dname].default,
					                                                                dataFields[dname].validvalues)
				end
				-- update the data field description
				dataFields[dname].description = xmlNodeGetAttribute(subnode,"description")
												 or dataFields[dname].description
				-- update the required flag (default: true)
				local requiredAttribute = xmlNodeGetAttribute(subnode,"required")
				if requiredAttribute then
					dataFields[dname].required = convert.boolean(requiredAttribute)
				else
					dataFields[dname].required = dataFields[dname].required or true
				end
				if dname == typeDefinition.shortcut then
					isValidShortcut = true
				end
			end
		end
		j = j + 1
	until false
	if not isValidShortcut then
		typeDefinition.shortcut = nil
	end
	
	return true
end

--Stores all children data for an EDF element in edf[resource]["elements"][type]
function edfAddElementNodeChildren(node, resource)
	-- get the element type name
	local name = xmlNodeGetAttribute(node,"name")
	
	-- declare the children table for this type
	edf[resource]["elements"][name].children = edf[resource]["elements"][name].children or {}
	-- make childrenTable a reference to it to keep it short
	local childrenTable = edf[resource]["elements"][name].children
	
	-- for each basic type that could be used as a children,
	for typeName, typeDefinition in pairs(edf[thisResource]["elements"]) do
		local k = 0
		repeat
			--try to get a new node until we go out of range
			local subnode = xmlFindChild(node,typeName,k)
			if not subnode then break end
			
			-- create a child table
			local child = {}
			child.type = typeName
			child.editorOnly = convert.boolean(xmlNodeGetAttribute(subnode, "editorOnly"))
			child.data = {}
			
			-- make dataFields point to the data fields from the typedef to keep it short
			local dataFields = typeDefinition.data

			-- add the "offset" data for this child
			child.data = edfGetChildData(subnode, dataFields)
			-- if it was successful, insert it
			if child.data then
				table.insert(childrenTable, child)
			end
			k = k + 1
		until false
	end
	
	-- for each known custom element type that could be used as a children,
	for typeName, typeDefinition in pairs(edf[resource]["elements"]) do
		local k = 0
		repeat
			--try to get a new node until we go out of range
			local subnode = xmlFindChild(node,typeName,k)
			if not subnode then break end
			
			-- create a child table
			local child = {}
			child.type = typeName
			child.data = {}
			
			-- make dataFields point to the data fields from the typedef to keep it short
			local dataFields = typeDefinition.data

			-- add the "offset" data for this child
			child.data = edfGetChildData(subnode, dataFields)
			-- if it was successful, insert it
			if child.data then
				table.insert(childrenTable, child)
			end
			k = k + 1
		until false
	end
	
	return true
end

--Stores allowed parents for an EDF element in edf[resource]["elements"][type]
function edfAddElementNodeParents(node, resource)
	-- get the element type name
	local name = xmlNodeGetAttribute(node,"name")
	
	-- declare the parents table for this type
	edf[resource]["elements"][name].parents = edf[resource]["elements"][name].parents or {}
	-- make parentsTable a reference to it to keep it short
	local parentsTable = edf[resource]["elements"][name].parents
	
	-- for each parent tag,
	local k = 0
	repeat
		--try to get a new node until we go out of range
		local subnode = xmlFindChild(node,"parent",k)
		if not subnode then break end
		
		local parentType = xmlNodeGetAttribute(subnode, "type")
		if parentType then
			table.insert(parentsTable, parentType)
		end
		--If there was a name & description specified, add it if it doesnt exist
		edf[resource]["elements"][name].parentName = edf[resource]["elements"][name].parentName or xmlNodeGetAttribute(subnode, "name")
		edf[resource]["elements"][name].parentDescription = edf[resource]["elements"][name].parentDescription or xmlNodeGetAttribute(subnode, "description")
		k = k + 1
	until false
	
	return true
end

--Stores [node]'s data for an EDF setting in edf[resource]["settings"][name]
function edfAddSettingNodeData(node, resource)
	-- get the element type name
	local name = xmlNodeGetAttribute(node,"name")
	
	edf[resource]["settings"][name] = edf[resource]["settings"][name] or {}
	local settingDefinition = edf[resource]["settings"][name]
	
	-- update the setting description
	settingDefinition.description = xmlNodeGetAttribute(node,"description")
								or settingDefinition.description
	-- update the setting friendly name
	settingDefinition.friendlyname = xmlNodeGetAttribute(node,"friendlyname")
								or settingDefinition.friendlyname
	-- update the setting type
	settingDefinition.datatype = xmlNodeGetAttribute(node,"type")
								or settingDefinition.datatype
	-- update the setting default
	local defaultAttribute = xmlNodeGetAttribute(node,"default")
	if defaultAttribute then
		local dataType = settingDefinition.datatype
		local token = gettok ( settingDefinition.datatype,1,58 )
		local token2 = gettok ( settingDefinition.datatype,2,58 ) or token
		local validvalues
		if token == "element" then
			dataType = token
			validvalues = split(token2,44)
		elseif token == "selection" then
			dataType = token
			validvalues = split(token2,44)
		end
		settingDefinition.default = convert[dataType](defaultAttribute,validvalues)
	else
		settingDefinition.default = nil
	end
	
	-- update the setting required flag
	local requiredAttribute = xmlNodeGetAttribute(node,"required")
	if requiredAttribute then
		settingDefinition.required = convert.boolean(requiredAttribute)
	else
		settingDefinition.required = dataFields[dname].required or true
	end

	return true
end

--Reads data for an EDF child from its xmlnode, using dataFields as the definition
function edfGetChildData(node, dataFields)
	local childData = {}

	for dataField, fieldProperties in pairs(dataFields) do
		local datatype = fieldProperties.datatype
		
		-- if we don't have a conversion function for this datatype, default to string
		if not convert[datatype] then
			datatype = "string"
		end
		
		-- get the default value
		local default = fieldProperties.default

		-- get the actual value (make it nil, not false, if not present)
		local value
		if dataField == "position" then
			value = {}
			value[1] = xmlNodeGetAttribute(node, "posX") or 0
			value[2] = xmlNodeGetAttribute(node, "posY") or 0
			value[3] = xmlNodeGetAttribute(node, "posZ") or 0
		elseif dataField == "rotation" then
			value = {}
			value[1] = xmlNodeGetAttribute(node, "rotX") or 0
			value[2] = xmlNodeGetAttribute(node, "rotY") or 0
			value[3] = xmlNodeGetAttribute(node, "rotZ") or 0
		else
			value = xmlNodeGetAttribute(node, dataField) or nil
			if value then
				-- if it isn't prefixed and suffixed with !s
				-- (that is, it won't be inherited from the parent element), convert it
				if string.sub(value,1,1) ~= '!' or string.sub(value, -1) ~= '!' then
					value = convert[datatype](value, elementType)
				end
			end
		end

		if value ~= nil then
			-- if we could convert it, just store the value
			childData[dataField] = value
		elseif default then
			-- if we couldn't, but there is a default, use it
			childData[dataField] = default
		elseif fieldProperties.required then
			-- if valid and default weren't valid and it's required, we have to stop here
			outputDebugString("Value of required attribute '"..dataField.."' doesn't match its type ('"..datatype.."'), and there's no valid default.",1)
			return false
		end
	end

	return childData
end

--Checks element data for conformity with its type spec
function edfCheckElementData(theElement, dataField, dataDefinition)
	local theData = getElementData(theElement, dataField)

	if dataField == 'position' 
		or dataField == 'rotation' 
		or gettok ( dataDefinition.datatype,1,58 ) == "element"
		or gettok ( dataDefinition.datatype,1,58 ) == "selection" then
		-- Position and rotation are not single strings with a special format that needs checking
		return false
	elseif not theData then
		-- if there is no data, set it to default
		theData = dataDefinition.default
	else
		-- if there is data, we're checking the type matches
		local correctType = dataDefinition.datatype
		-- if we don't have a conversion function for this datatype, default to string
		if not convert[correctType] then
			correctType = "string"
		end
		
		local convertedValue = convert[correctType](theData)
		
		-- if the attribute has an invalid type,
		if convertedValue == nil then
			-- output a warning
			local warning = "Attribute '"..dataField.."' has an invalid type in element '"..getElementType(theElement).."': should be '"..correctType.."'."
			outputDebugString(warning,2)
			-- and set it to default
			theData = dataDefinition.default
		else
			theData = convertedValue
		end
	end

	-- if there is still no data (because it wasnt set and there was no default)
	if not theData then  --Make an exception for booleans
		if ( ( dataDefinition.datatype ~= "boolean" )  and ( theData ~= nil ) ) then --If its not a boolean&nil
			-- prepare a warning message
			local errstring = "Attribute '"..dataField.."' missing in element '"..getElementType(theElement).."'."
			-- if the attribute is required,
			if dataDefinition.required then
				--then it is an error and we have to stop here
				outputDebugString(errstring,1)
				return nil
			else
				--else, just warn about it
				outputDebugString(errstring,2)
			end
		end
	end
	
	-- we set the new element data in case we have changed it
	setElementData(theElement, dataField, theData)

	return theData
end

-- Returns the appropiate resource for an element type
function edfGetResourceForElementType(elementType)
	local res = nil

	for resource, data in pairs(edf) do
		if resource ~= thisResource then
			for name, _ in pairs(data.elements) do
				if name == elementType then
					res = resource
					break
				end
			end

			if res then break end
		end
	end

	return res
end

