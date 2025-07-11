g_in_test = false
local g_restoreEDF, dumpTimer
local g_default_spawnmaponstart,g_default_spawnmapondeath,g_defaultwelcometextonstart
local restoreGUIOnMapStop, restoreGUIOnGamemodeMapStop, startGamemodeOnStop
local freeroamRes = getResourceFromName "freeroam"
local TEST_RESOURCE = "editor_test"
local DUMP_RESOURCE = "editor_dump"
local dumpInterval = get("dumpSaveInterval") and tonumber(get("dumpSaveInterval"))*1000 or 60000
local fileTypes = { "script","map","file","config","html" }
local specialFileTypes = { "script","file","config","html" }
local DESTROYED_ELEMENT_DIMENSION = getWorkingDimension() + 1

---
local openResourceCoroutine
local openingResource
local openingResourceName
local openingOnStart
local openingSource
local openingStartTick
local openingMapElement
local openingMapName
---
local quickSaveCoroutine
local saveResourceCoroutine
---
local lastTestGamemodeName

loadedMap = false
addEvent ( "onNewMap" )
addEvent ( "onMapOpened" )
addEvent ( "openResource", true )
addEvent ( "saveResource", true )
addEvent ( "testResource", true )
addEvent ( "newResource", true )
addEvent ( "quickSaveResource", true )

addEventHandler ( "onResourceStart", resourceRoot,
	function()
		refreshResources(false)
		setOcclusionsEnabled ( false )
		restoreAllWorldModels ( )
		destroyElement( root )
		mapContainer = createElement("mapContainer")
		setTimer(startUp, 1000, 1)
	end
)

function startUp()
	enabled = getBool("enableDumpSave", true)
	if ( enabled ) then
		if ( not openResource(DUMP_RESOURCE, true) ) then
			outputConsole("Could not open dump. Creating new dump.")
			saveResource(DUMP_RESOURCE, false)
		else
			if #getElementsByType("player") > 0 then
				editor_gui.outputMessage("On-Exit-Save has loaded the most recent backup of the previously loaded map. Use 'new' to start a new map.", root, 255, 255, 0, 20000)
			else
				addEventHandler("onPlayerJoin", root, onJoin)
			end
		end
		dumpTimer = setTimer(maybeDumpSave, dumpInterval, 0)
	end
	for i,player in ipairs(getElementsByType("player")) do
		local account = getPlayerAccount(player)
		if account then
			local accountName = getAccountName(account)
			local adminGroups = split(get("admingroup") or "Admin",string.byte(','))
			for _,name in ipairs(adminGroups) do
				local group = aclGetGroup(name)
				if group then
					for i2,obj in ipairs(aclGroupListObjects(group)) do
						if obj == 'user.' .. accountName or obj == 'user.*' then
							triggerClientEvent(player, "enableServerSettings", player, enabled, dumpInterval/1000)
						end
					end
				end
			end
		end
	end
end

addCommandHandler("savedump",
	function()
		dumpSave()
	end
)

function onJoin()
	editor_gui.outputMessage("On-Exit-Save has loaded the most recent backup of the previously loaded map. Use 'new' to start a new map.", source, 255, 255, 0, 20000)
	removeEventHandler("onPlayerJoin", root, onJoin)
end

addEventHandler("newResource", root,
	function()
		if ( client and not isPlayerAllowedToDoEditorAction(client, "newMap") ) then
			editor_gui.outputMessage ("You don't have permissions to start a new map!", client,255,0,0)
			return
		end
		if ( isEditorSaving() or isEditorOpeningResource() ) then
			editor_gui.outputMessage ("Cannot create a new map while another is being saved or loaded", client, 255, 0, 0)
			return
		end

		if ( loadedMap ) then
			local currentMap = getResourceFromName ( loadedMap )
			if ( currentMap ) then
				stopResource ( currentMap )
				loadedMap = DUMP_RESOURCE
			end
		end
		for index, child in ipairs(getElementChildren(mapContainer)) do
			destroyElement(child)
		end
		restoreAllWorldModels ( )
		passDefaultMapSettings()
		triggerClientEvent ( source, "saveloadtest_return", source, "new", true )
		triggerEvent("onNewMap", resourceRoot)
		dumpSave()
		editor_gui.outputMessage(getPlayerName(client).." started a new map.", root, 255, 0, 0)

		actionList = {}
		currentActionIndex = 0

		lastTestGamemodeName = nil
	end
)

function handleOpenResource()
	local status = coroutine.status(openResourceCoroutine)
	if ( status == "suspended" ) then
		coroutine.resume(openResourceCoroutine)
	elseif ( status == "dead" ) then
		destroyElement ( openingMapElement )
		loadedMap = openingResourceName
		passNewMapSettings()
		if ( not openingOnStart ) then
			local playerName = "No longer connected player"
			if (isElement(openingSource)) then
				triggerClientEvent ( openingSource, "saveloadtest_return", openingSource, "open", true )
				playerName = getPlayerName ( openingSource )
			end
			local outputStr = playerName.." opened map "..tostring(openingResourceName)..". (opening took "..math.floor(getTickCount() - openingStartTick).." ms)"
			editor_gui.outputMessage ( outputStr, root, 255, 0, 0 )
			outputConsole ( outputStr )
			dumpSave()
		else
			loadedMap = openingMapName
			outputConsole ( "Loaded map in "..math.floor(getTickCount()-openingStartTick).." ms" )
		end

		-- Make sure all just loaded objects have collisions so they can be seleted
		for i, obj in pairs(getElementsByType("object")) do
			setElementCollisionsEnabled(obj, true)
		end

		actionList = {}
		currentActionIndex = 0

		lastTestGamemodeName = nil

		triggerEvent("onMapOpened", mapContainer, openingResource)
		flattenTreeRuns = 0
		triggerClientEvent(root, "saveLoadProgressBar", root, true)

		openResourceCoroutine = nil
		openingResource       = nil
		openingResourceName   = nil
		openingOnStart        = nil
		openingSource         = nil
		openingMapElement     = nil
		openingMapName        = nil
		return
	end
	setTimer(handleOpenResource,50,1)
end

function isEditorOpeningResource()
	return openingResource and true
end

function isEditorSaving()
	if ( quickSaveCoroutine or saveResourceCoroutine ) then
		return true
	end
	return false
end

function openResource( resourceName, onStart )
	if ( isEditorOpeningResource() ) then
		return
	end

	if ( client and not isPlayerAllowedToDoEditorAction(client, "load") ) then
		editor_gui.outputMessage ("You don't have permissions to load another map!", client,255,0,0)
		return
	end

	if ( isEditorSaving() ) then
		editor_gui.outputMessage ("Cannot save while another save is in progress", client,255,0,0)
		return
	end

	--need to clear undo/redo history!
	local returnValue
	local map = getResourceFromName ( resourceName )
	if ( map ) then

		for index,child in ipairs(getElementChildren(mapContainer)) do
			destroyElement(child)
		end
		local maps, mapsErr = getResourceFiles ( map, "map" )
		local mapName = DUMP_RESOURCE

		if (not maps or #maps == 0) then
			if (openingSource) then
				triggerClientEvent ( openingSource, "saveloadtest_return", openingSource, "open", false )
			end
			editor_gui.outputMessage ( "Unable to open "..tostring(resourceName).." ("..tostring(mapsErr)..")", root, 255, 0, 0, 5000)
			return false
		end

		restoreAllWorldModels ( )
		openingOnStart      = onStart
		openingResourceName = resourceName
		openingSource       = source
		openingResource     = map
		openingStartTick    = getTickCount()

		editor_gui.outputMessage ( "Opening map "..tostring(openingResourceName).."...", root,0,0,255,600000)
		if (openingSource) then
			triggerClientEvent ( openingSource, "saveloadtest_return", openingSource, "open", true )
		end

		for key,mapPath in ipairs(maps) do
			local mapNode = xmlLoadFile ( ':' .. getResourceName(map) .. '/' .. mapPath )
			-- read the definitons that are used in the map
			local usedDefinitions = xmlNodeGetAttribute(mapNode, "edf:definitions")
			if usedDefinitions then
				local newEDF = allEDF
				-- define all EDFs as available
				for _, definition in ipairs(newEDF.addedEDF) do
					table.insert(newEDF.availEDF, definition)
				end
				-- The map specifies a set of EDF to load
				newEDF.addedEDF = split(usedDefinitions, 44)
				--  Remove the added EDFs from the available
				table.subtract(newEDF.availEDF, newEDF.addedEDF)
				-- Un/Load the neccessary definitions
				reloadEDFDefinitions(newEDF,true)
			end
			local mapElement = loadMapData ( mapNode, mapContainer, false )
			openingMapElement = mapElement
			-- Map may take a while to load so show loading bar
			if (#getElementChildren(mapElement) > 500) then
				triggerClientEvent(root, "saveLoadProgressBar", root, 0, #getElementChildren(mapElement))
			end
			for _, element in ipairs ( getElementChildren ( mapElement, "removeWorldObject" ) ) do
				local model = getElementData ( element, "model" )
				local lodModel = getElementData ( element, "lodModel" )
				local posX = getElementData ( element, "posX" )
				local posY = getElementData ( element, "posY" )
				local posZ = getElementData ( element, "posZ" )
				local interior = getElementData ( element, "interior" )
				local radius = getElementData ( element, "radius" )
				removeWorldModel ( model, radius, posX, posY, posZ, interior )
				removeWorldModel ( lodModel, radius, posX, posY, posZ, interior )
			end
			openResourceCoroutine = coroutine.create(flattenTree)
			setTimer(handleOpenResource,50,1)
			coroutine.resume(openResourceCoroutine,mapElement,mapContainer)
			xmlUnloadFile(mapNode)
		end

		returnValue = true
		if onStart then
			openingMapName = mapName
		end
	else
		returnValue = false
	end
	if onStart then
		return returnValue
	end
end
addEventHandler ( "openResource", root, openResource )

---Save

function saveResource(resourceName, test, directory)
	if ( client and not isPlayerAllowedToDoEditorAction(client, "saveAs") ) then
		editor_gui.outputMessage ("You don't have permissions to save the map!", client,255,0,0)
		return false
	end
	if ( isEditorOpeningResource() ) then
		triggerClientEvent ( client, "saveloadtest_return", client, "save", false, resourceName,
		"You cannot save while a map is being opened" )
		return false
	end
	if ( isEditorSaving() ) then
		triggerClientEvent ( client, "saveloadtest_return", client, "save", false, resourceName,
		"You cannot save while another save or load is in progress" )
		return false
	end
	saveOrganizationalDirectory ( directory )
	saveResourceCoroutine = coroutine.create(saveResourceCoroutineFunction)
	coroutine.resume(saveResourceCoroutine, resourceName, test, client, client)
end
addEventHandler ( "saveResource", root, saveResource )

function saveOrganizationalDirectory(directory)
	if (type(directory) ~= 'string') or (utf8.len(directory) == 0) then
		directory = 'none'
	else
		directory = '[' .. directory .. ']'
	end
	return set('*editor_main.mapResourceOrganizationalDirectory', directory)
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

function saveResourceCoroutineFunction ( resourceName, test, theSaver, client, gamemodeName )
	local iniTick = getTickCount()
	if ( loadedMap ) then
		if ( string.lower(loadedMap) == string.lower(resourceName) ) then
			saveResourceCoroutine = nil
			quickSave(true, false, client)
			return
		end
	end
	local resource = getResourceFromName ( resourceName )
	local metaNodes = {}
	if ( resource ) then
		--Clear out old files from the resource
		if (not mapmanager.isMap ( resource )) then
			if (client) then
				triggerClientEvent ( client, "saveloadtest_return", client, "save", false, resourceName,
				"You cannot overwrite non-map resources." )
			end
			saveResourceCoroutine = nil
			return false
		end
		backupMapFiles( resourceName )
		for i,fileType in ipairs(fileTypes) do
			local files, err = getResourceFiles(resource, fileType)
			if (err and err == "no meta") then
				triggerClientEvent ( client, "saveloadtest_return", client, "save", false, resourceName,
				"The target resource is damaged and has no meta.xml remove the resource and use refresh" )
				saveResourceCoroutine = nil
				return false
			end
			if (err and err == "no resource") then
				triggerClientEvent ( client, "saveloadtest_return", client, "save", false, resourceName,
				"The target resource doesn't exist" )
				refreshResources(false)
				saveResourceCoroutine = nil
				return false
			end
			if (not files) then
				triggerClientEvent ( client, "saveloadtest_return", client, "save", false, resourceName,
				"Could not overwrite resource, the target resource may be corrupt." )
				saveResourceCoroutine = nil
				return false
			end
			for j,filePath in ipairs(files) do
				if not removeResourceFile ( resource, filePath, fileType ) then
					triggerClientEvent ( client, "saveloadtest_return", client, "save", false, resourceName,
					"Could not overwrite resource.  The map resource may be in .zip format." )
					saveResourceCoroutine = nil
					return false
				end
			end
		end
	else
		local mapResourceOrganizationalDirectory = get("mapResourceOrganizationalDirectory") ~= "none" and get("mapResourceOrganizationalDirectory") or nil
		if mapResourceOrganizationalDirectory then
			if string.match(mapResourceOrganizationalDirectory,"%[(%a+)%]") then
				resource = createResource ( resourceName, mapResourceOrganizationalDirectory )
			else
				outputDebugString( "Invalid map base directory. Please enter a name with [brackets].", 2 )
				resource = createResource ( resourceName )
			end
		else
			resource = createResource ( resourceName )
		end
		if not resource then
			triggerClientEvent ( client, "saveloadtest_return", client, "save", false, resourceName,
			"Could not create resource.  The resource directory may exist already or be invalid" )
			saveResourceCoroutine = nil
			return
		end
	end
	if ( loadedMap ) and ( loadedMap ~= resourceName ) then
		metaNodes = copyResourceFiles ( getResourceFromName(loadedMap), resource )
	end
	local xmlNode = addResourceMap ( resource, resourceName..".map" )
	baseElement = mapContainer
	local elementChildren = {}
	local rootElements = {}
	local usedResources = {}
	local tick = getTickCount()
	local showSaveWarningOnce = false
	for i, element in ipairs(getElementChildren(baseElement)) do --Find parents to start with
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
		if (getTickCount() > tick + 200) or ( DEBUG_LOADSAVE and i < 40 ) then
			setTimer(function()
				if (coroutine.status(saveResourceCoroutine) == "suspended") then
					coroutine.resume(saveResourceCoroutine)
				elseif (coroutine.status(saveResourceCoroutine) == "dead") then
					saveResourceCoroutine = nil
				end
			end, 200, 1)
			if (not showSaveWarningOnce and iniTick < getTickCount() - 3000) then
				editor_gui.outputMessage("The map is being saved... (this could take a while)", root, 255, 0, 0)
				showSaveWarningOnce = true
			end
			coroutine.yield()
			tick = getTickCount()
		end
	end
	-- Loverly hack for race checkpoint scale
	if usedResources['race'] then
		usedResources['editor_main'] = true
	end
	-- Save in the map node the used definitions
	local usedDefinitions = ""
	for resource2 in pairs(usedResources) do
		usedDefinitions = usedDefinitions .. resource2 .. ","
	end
	if usedDefinitions ~= "" then
		usedDefinitions = string.sub(usedDefinitions, 1, #usedDefinitions - 1)
		xmlNodeSetAttribute(xmlNode, "edf:definitions", usedDefinitions)
	end
	tick = getTickCount()

	for i, element in ipairs(rootElements) do
		if (getTickCount() > tick + 200) or ( DEBUG_LOADSAVE and i < 40 ) then
			setTimer(function()
				if (coroutine.status(saveResourceCoroutine) == "suspended") then
					coroutine.resume(saveResourceCoroutine)
				elseif (coroutine.status(saveResourceCoroutine) == "dead") then
					saveResourceCoroutine = nil
				end
			end, 200, 1)
			coroutine.yield()
			tick = getTickCount()
		end
		local elementNode = createElementAttributesForSaving(xmlNode, element)
		dumpNodes ( elementNode, elementChildren[element], elementChildren )
	end

	local returnValue = xmlSaveFile(xmlNode)
	clearResourceMeta ( resource, true )
	local metaNode = xmlLoadFile ( ':' .. getResourceName(resource) .. '/' .. "meta.xml" )
	dumpMeta ( metaNode, metaNodes, resource, resourceName..".map", test )
	xmlUnloadFile ( metaNode )
	if ( test ) then
		saveResourceCoroutine = nil
		beginTest(client, gamemodeName)
		return returnValue
	end
	if ( returnValue ) then
		loadedMap = resourceName
		if (theSaver) then
			editor_gui.outputMessage ( getPlayerName(theSaver).." saved to map resource \""..resourceName.."\".", root, 255, 0, 0 )
		end
	end
	if ( theSaver ) then
		triggerClientEvent ( theSaver, "saveloadtest_return", theSaver, "save", returnValue, resourceName )
	end
	dumpSave()
	outputConsole("Full saving of map complete in "..math.floor(getTickCount() - iniTick).." ms")
	saveResourceCoroutine = nil
	return returnValue
end

function quickSave(saveAs, dump, fromSaveAs)
	if ( fromSaveAs ) then
		client = fromSaveAs
	end
	if ( client and not isPlayerAllowedToDoEditorAction(client, "save") ) then
		editor_gui.outputMessage("You don't have permissions to save the map!", client, 255, 0, 0)
		triggerClientEvent(client, "saveloadtest_return", client, "close", false)
		return
	end
	if ( isEditorSaving() ) then
		editor_gui.outputMessage("Cannot quick save while a save is in progress", client, 255, 0, 0)
		triggerClientEvent(client, "saveloadtest_return", client, "close", false)
		return
	end
	if ( isEditorOpeningResource() ) then
		editor_gui.outputMessage("Cannot quick save while a load is in progress", client, 255, 0, 0)
		triggerClientEvent(client, "saveloadtest_return", client, "close", false)
		return
	end
	quickSaveCoroutine = coroutine.create(quickSaveCoroutineFunction)
	coroutine.resume(quickSaveCoroutine, saveAs, dump, client)
end
addEventHandler("quickSaveResource", root, quickSave)

function quickSaveCoroutineFunction(saveAs, dump, client)
	doQuickSaveCoroutineFunction(saveAs, dump, client)
	lastTimeQuickSaveCompleted = getTickCount()
end

function doQuickSaveCoroutineFunction(saveAs, dump, client)
	if ( loadedMap ) then
		if not dump then
			backupMapFiles( loadedMap )
		end
		local tick = getTickCount()
		local iniTick = getTickCount()
		local resourceName = tostring(dump and DUMP_RESOURCE or loadedMap)
		local resource = getResourceFromName ( dump and DUMP_RESOURCE or loadedMap )
		local mapTable = getResourceFiles ( resource, "map" )
		if ( not mapTable ) then
			triggerClientEvent ( client, "saveloadtest_return", client, "save", false, loadedMap,
			"Could not overwrite resource, "..resourceName.." may be corrupt, consider deleting the resource." )
			quickSaveCoroutine = nil
			return false
		end
		for key, mapPath in ipairs(mapTable) do
			if ( not removeResourceFile ( resource, mapPath, "map" ) ) then
				triggerClientEvent ( client, "saveloadtest_return", client, "save", false, loadedMap,
				"Could not overwrite resource. The "..resourceName.." may be in .zip format." )
				quickSaveCoroutine = nil
				return false
			end
		end
		clearResourceMeta ( resource, true )
		local xmlNode = addResourceMap ( resource, loadedMap..".map" )
		if ( not xmlNode ) then
			triggerClientEvent ( client, "saveloadtest_return", client, "quickSave", false, loadedMap )
			quickSaveCoroutine = nil
			return false
		end

		baseElement = baseElement or mapContainer
		local elementChildren = {}
		local rootElements = {}
		local usedResources = {}
		local showSaveWarningOnce = false
		for i, element in ipairs(getElementChildren(baseElement)) do  --Find parents to start with
			if (getTickCount() > tick + 200) or ( DEBUG_LOADSAVE and i < 40 ) then
				setTimer(function()
					if (coroutine.status(quickSaveCoroutine) == "suspended") then
						coroutine.resume(quickSaveCoroutine)
					elseif (coroutine.status(quickSaveCoroutine) == "dead") then
						quickSaveCoroutine = nil
					end
				end, 200, 1)
				if (not showSaveWarningOnce and iniTick < getTickCount() - 3000) then
					editor_gui.outputMessage("The map is being saved... (this could take a while)", root,255,0,0)
					showSaveWarningOnce = true
				end
				coroutine.yield()
				tick = getTickCount()
			end
			-- Ignore representations and destroyed elements
			if ( not edf.edfIsRepresentation(element) and getElementDimension(element) ~= DESTROYED_ELEMENT_DIMENSION ) then
				local parent = getElementData ( element, "me:parent" )
				if ( not parent or getElementType(parent) == "map" ) then
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
		for resource2 in pairs(usedResources) do
			usedDefinitions = usedDefinitions .. resource2 .. ","
		end
		if ( usedDefinitions ~= "" ) then
			usedDefinitions = string.sub(usedDefinitions, 1, #usedDefinitions - 1)
			xmlNodeSetAttribute(xmlNode, "edf:definitions", usedDefinitions)
		end
		for i, element in ipairs(rootElements) do
			if (getTickCount() > tick + 200) or ( DEBUG_LOADSAVE and i < 40 ) then
				setTimer(function()
					if (coroutine.status(quickSaveCoroutine) == "suspended") then
						coroutine.resume(quickSaveCoroutine)
					elseif (coroutine.status(quickSaveCoroutine) == "dead") then
						quickSaveCoroutine = nil
					end
				end, 200, 1)
				if (not showSaveWarningOnce and iniTick < getTickCount() - 3000) then
					editor_gui.outputMessage("The map is being saved... (this could take a while)", root,255,0,0)
					showSaveWarningOnce = true
				end
				coroutine.yield()
				tick = getTickCount()
			end
			local elementNode = createElementAttributesForSaving(xmlNode, element)
			dumpNodes ( elementNode, elementChildren[element], elementChildren )
		end
		xmlSaveFile(xmlNode)
		xmlUnloadFile(xmlNode)
		local metaNode = xmlLoadFile ( ':' .. getResourceName(resource) .. '/' .. "meta.xml" )
		dumpMeta ( metaNode, {}, resource, loadedMap..".map" )
		xmlUnloadFile ( metaNode )
		if ( not dump and loadedMap == DUMP_RESOURCE ) then
			editor_gui.loadsave_getResources("saveAs", client)
			quickSaveCoroutine = nil
			return
		end
		if ( saveAs ) then
			triggerClientEvent ( client, "saveloadtest_return", client, "save", true )
		end
		if ( not dump ) then
			editor_gui.outputMessage (getPlayerName(client).." saved the map.", root,255,0,0)
			dumpSave()
		end
	else
		-- No map is loaded, if not caused by auto save, ask the client to save as
		if (client) then
			editor_gui.loadsave_getResources("saveAs", client)
		end
	end
	quickSaveCoroutine = nil
end

function createElementAttributesForSaving(xmlNode, element)
	-- Create element subnode
	local elementNode = xmlCreateChild(xmlNode, getElementType(element))
	-- Add an ID attribute first off
	xmlNodeSetAttribute(elementNode, "id", getElementID(element))
	-- Dump raw properties from the getters
	for dataField in pairs(loadedEDF[edf.edfGetCreatorResource(element)].elements[getElementType(element)].data) do
		if (dataField ~= "color1" and dataField ~= "color2" and dataField ~= "color3" and dataField ~= "color4") then
			local value
			if ( specialSyncers[dataField] ) then
				value = specialSyncers[dataField](element)
			else
				value = edf.edfGetElementProperty(element, dataField)
			end
			if type(value) == "number" or type(value) == "string" then
				xmlNodeSetAttribute(elementNode, dataField, value )
			end
		end
	end
	-- Dump properties to attributes
	local posSetX, posSetY, posSetZ = false, false, false
	for dataName, dataValue in orderedPairs(getMapElementData(element)) do
		if ( dataName == "position" ) then
			xmlNodeSetAttribute(elementNode, "posX", toAttribute(round(dataValue[1], 5)))
			xmlNodeSetAttribute(elementNode, "posY", toAttribute(round(dataValue[2], 5)))
			xmlNodeSetAttribute(elementNode, "posZ", toAttribute(round(dataValue[3], 5)))
			posSetX, posSetY, posSetZ = true, true, true
		elseif ( dataName == "rotation" ) then
			if dataValue[4] == "ZYX" then
				euler_ZYX_to_ZXY(dataValue)
			end
			xmlNodeSetAttribute(elementNode, "rotX", toAttribute(round(dataValue[1], 3)))
			xmlNodeSetAttribute(elementNode, "rotY", toAttribute(round(dataValue[2], 3)))
			xmlNodeSetAttribute(elementNode, "rotZ", toAttribute(round(dataValue[3], 3)))
		elseif ( dataName == "posX" or dataName == "posY" or dataName == "posZ") then
			xmlNodeSetAttribute(elementNode, dataName, toAttribute(round(dataValue, 5)))
			if (dataName == "posX") then
				posSetX = true
			elseif (dataName == "posY") then
				posSetY = true
			else
				posSetZ = true
			end
		elseif ( dataName == "rotX" or dataName == "rotY" or dataName == "rotZ") then
			xmlNodeSetAttribute(elementNode, dataName, toAttribute(round(dataValue, 3)))
		elseif ( dataName ~= "color1" and dataName ~= "color2" and dataName ~= "color3" and dataName ~= "color4" and ( not specialSyncers[dataName] or dataValue ~= getWorkingDimension() ) ) then
			xmlNodeSetAttribute(elementNode, dataName, toAttribute(dataValue))
		end
	end
	-- Ensure that the element has a position set, else the map file can't load
	-- This situation occurs when map is saved while someone is placing a new object.
	if (not posSetX or not posSetY or not posSetZ) then
		local x, y, z = getElementPosition(element)
		xmlNodeSetAttribute(elementNode, "posX", toAttribute(round(x, 5)))
		xmlNodeSetAttribute(elementNode, "posY", toAttribute(round(y, 5)))
		xmlNodeSetAttribute(elementNode, "posZ", toAttribute(round(z, 5)))
	end
	-- Save vehicle colors
	if ( getElementType(element) == "vehicle" ) then
		local vc = {getVehicleColor(element, true)}
		local colorString = vc[1]..","..vc[2]..","..vc[3]..","..vc[4]..","..vc[5]..","..vc[6]..","..vc[7]..","..vc[8]..","..vc[9]..","..vc[10]..","..vc[11]..","..vc[12]
		xmlNodeSetAttribute(elementNode, "color", toAttribute(colorString))
	end
	return elementNode
end

local testBackupNodes = {}
addEventHandler ( "testResource", root,
function (gamemodeName)
	if ( client and not isPlayerAllowedToDoEditorAction(client, "test") ) then
		editor_gui.outputMessage ("You don't have permissions to enable test mode!", client,255,0,0)
		return false
	end
	--Check if the freeroam resource exists
	if ( not freeroamRes ) then
		triggerClientEvent ( client, "saveloadtest_return", client, "test", false, false, "'freeroam' not found.  Test could not be started." )
		return false
	end
	g_restoreEDF = nil
	triggerClientEvent ( root, "suspendGUI", client )
	saveResourceCoroutine = coroutine.create(saveResourceCoroutineFunction)
	local success = coroutine.resume(saveResourceCoroutine, TEST_RESOURCE, true, nil, client, gamemodeName)
	if ( not success ) then
		triggerClientEvent ( root, "saveloadtest_return", client, "test", false, false,
		"Dummy 'editor_test' resource may be corrupted!" )
		return false
	end
end )

function beginTest(client,gamemodeName)
	if ( isEditorSaving() or isEditorOpeningResource() ) then
		triggerClientEvent ( client, "saveloadtest_return", client, "test", false, false,
		"Cannot begin test while a save or load is in progress" )
		return false
	end
	local testMap = getResourceFromName(TEST_RESOURCE)
	if ( not mapmanager.isMap(testMap) ) then
		triggerClientEvent ( client, "saveloadtest_return", client, "test", false, false,
		"Dummy 'editor_test' resource may be corrupted!" )
		return false
	end
	g_default_spawnmaponstart = get"freeroam.spawnmaponstart"
	g_default_spawnmapondeath = get"freeroam.spawnmapondeath"
	g_default_welcometextonstart = get"freeroam.welcometextonstart"
	resetMapInfo()
	setupMapSettings()
	disablePickups(false)

	if gamemodeName == nil then
		gamemodeName = lastTestGamemodeName
	end

	if ( gamemodeName ) then
		lastTestGamemodeName = gamemodeName
		set ( "*freeroam.spawnmapondeath", "false" )
		if getResourceState(freeroamRes) ~= "running" and not startResource ( freeroamRes, true ) then
			restoreSettings()
			triggerClientEvent ( root, "saveloadtest_return", client, "test", false, false,
			"'editor_main' may lack sufficient ACL privileges to start/stop resources! (1)" )
			return false
		end
		local gamemode = getResourceFromName(gamemodeName)
		if getResourceState ( gamemode ) == "running" and loadedEDF[gamemode] then
			g_restoreEDF = gamemode
			addEventHandler ( "onResourceStop", getResourceRootElement(gamemode), startGamemodeOnStop )
			if not stopResource ( gamemode ) then
				restoreSettings()
				g_restoreEDF = nil
				removeEventHandler ( "onResourceStop", getResourceRootElement(gamemode), startGamemodeOnStop )
				triggerClientEvent ( root, "saveloadtest_return", client, "test", false, false,
				"'editor_main' may lack sufficient ACL privileges to start/stop resources! (2)" )
				return false
			end
		else
			if not mapmanager.changeGamemode(gamemode,testMap) then
				restoreSettings()
				triggerClientEvent ( root, "saveloadtest_return", client, "test", false, false,
				"'editor_main' may lack sufficient ACL privileges to start/stop resources! (3)" )
				return false
			end
		end
		g_in_test = "gamemode"
	else
		if gamemodeName == false then
			lastTestGamemodeName = gamemodeName
		end
		if getResourceState(freeroamRes) ~= "running" and not startResource ( freeroamRes, true ) then
			restoreSettings()
			triggerClientEvent ( root, "saveloadtest_return", client, "test", false, false,
			"'editor_main' may lack sufficient ACL privileges to start/stop resources! (4)" )
			return false
		end
		if getResourceState(testMap) ~= "running" and not startResource ( testMap, true ) then
			triggerClientEvent ( root, "saveloadtest_return", client, "test", false, false,
			"'editor_main' may lack sufficient ACL privileges to start/stop resources! (5)" )
			return false
		end
		g_in_test = "map"
	end
	dumpSave()
	for i,player in ipairs(getElementsByType"player") do
		setElementDimension ( player, 0 )
	end
	setElementData ( resourceRoot, "g_in_test", true )
	set ( "*freeroam.welcometextonstart", "false" )
	set ( "*freeroam.spawnmaponstart", "false" )
	addEvent("onPollStart")
	addEventHandler("onPollStart", root, function()
		stopTest()
		cancelEvent()
	end)
end

function startGamemodeOnStop(resource)
	setTimer ( mapmanager.changeGamemode, 50, 1, resource, getResourceFromName(TEST_RESOURCE))
	removeEventHandler ( "onResourceStop", source, startGamemodeOnStop )
end

addEvent("stopTest", true)
function stopTest()
	if client and not isPlayerAllowedToDoEditorAction(client,"test") then
		editor_gui.outputMessage ("You don't have permissions to enable test mode!", client,255,0,0)
		return
	end

	stopResource ( freeroamRes )
	disablePickups(true)
	local testRes = getResourceFromName(TEST_RESOURCE)
	--Restore settings to how they were before the test
	restoreSettings()
	if g_in_test == "gamemode" then
		local gamemode = mapmanager.getRunningGamemode()
		if not gamemode or not ( addEventHandler ( "onResourceStop", getResourceRootElement(gamemode), restoreGUIOnMapStop ) ) then
			addEventHandler ( "onResourceStop", getResourceRootElement(testRes), restoreGUIOnMapStop )
		end
		mapmanager.stopGamemode()
	else
		if testRes then
			addEventHandler ( "onResourceStop", getResourceRootElement(testRes), restoreGUIOnMapStop )
		end
		resetMapInfo()
	end
	setupMapSettings()
	g_in_test = false
	stopResource ( testRes )

	for index,player in ipairs(getElementsByType("player")) do
		-- Respawn the player, to stop the player from dieing repeatedly if dead and possibly prevents other bugs
		local x,y,z = getElementPosition(player)
		setTimer(spawnPlayer,50,1,player,x,y,z,0,0,0,getWorkingDimension())
	end

	-- Send the map settings (delay is required to work probably because EDF not loaded) #7091
	setTimer(passNewMapSettings, 1000, 1)

	triggerEvent("editor.fullTestEnded", client or root)
end
addEventHandler("stopTest", root, stopTest)

function restoreSettings()
	set ( "*freeroam.spawnmaponstart", g_default_spawnmaponstart )
	set ( "*freeroam.spawnmapondeath", g_default_spawnmapondeath )
	set ( "*freeroam.welcometextonstart", g_default_welcometextonstart )
end

function restoreGUIOnMapStop(resource)
	if g_restoreEDF then
		--Start the edf resource again if it was stopped
		blockMapManager(g_restoreEDF) --Stop mapmanager from treating this like a game.  LIFE IS NOT A GAME.
		--setTimer(startResource, 50, 1, g_restoreEDF, false, false, true, false, false, false, false, false, true)
		setTimer(edf.edfStartResource,50,1,g_restoreEDF)
		g_restoreEDF = nil
	end
	setTimer(triggerClientEvent, 50, 1, root, "resumeGUI", root)
	setElementData ( resourceRoot, "g_in_test", nil )
	removeEventHandler ( "onResourceStop", source, restoreGUIOnMapStop )
end

-- dump settings
function dumpSave()
	if getBool("enableDumpSave", true) and not getElementData(resourceRoot, "g_in_test") and not isEditorOpeningResource() and not isEditorSaving() then
		quickSave(false,true)
	end
end

-- Only start autosave if its been at least 'dumpInterval' since previous save finished
function maybeDumpSave()
	if not lastTimeQuickSaveCompleted or getTickCount() - lastTimeQuickSaveCompleted >= dumpInterval * 0.9 then
		dumpSave()
	end
end

addEvent("dumpSaveSettings", true)
addEventHandler("dumpSaveSettings", root,
	function(enabled, interval)
		if tonumber(interval)*1000 ~= dumpInterval then
			if isTimer(dumpTimer) then
				killTimer(dumpTimer)
			end
			set("dumpSaveInterval", tostring(interval))
			dumpInterval = tonumber(interval)*1000
			dumpTimer = setTimer(maybeDumpSave, dumpInterval, 0)
		end
		if enabled ~= getBool("enableDumpSave", true) then
			set("enableDumpSave", tostring(enabled))
			if enabled then
				dumpTimer = setTimer(maybeDumpSave, dumpInterval, 0)
			elseif isTimer(dumpTimer) then
				killTimer(dumpTimer)
				dumpTimer = nil
			end
		end
	end
)

addEventHandler("onPlayerLogin", root,
	function(prevaccount, account)
		local accountName = getAccountName(account)
		local adminGroups = split(get("admingroup") or "Admin",string.byte(','))
		for _,name in ipairs(adminGroups) do
			local group = aclGetGroup(name)
			if group then
				for i,obj in ipairs(aclGroupListObjects(group)) do
					if obj == 'user.' .. accountName or obj == 'user.*' then
						triggerClientEvent(source, "enableServerSettings", source, getBool("enableDumpSave", true), dumpInterval/1000)
					end
				end
			end
		end
	end
)

function getBool(var,default)
	local result = get(var)
	if not result then
		return default
	end
	return result == 'true'
end

function round(num, idp)
	num = tonumber(num)
	if not num then
		return 0
	end
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end
