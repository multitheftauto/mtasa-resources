g_in_test = false
local g_restoreEDF
local thisRoot = getResourceRootElement(getThisResource())
local root = getRootElement()
local g_default_spawnmaponstart,g_default_spawnmapondeath,g_defaultwelcometextonstart,g_mapstophandled
local restoreGUIOnMapStop, restoreGUIOnGamemodeMapStop, startGamemodeOnStop
local freeroamRes = getResourceFromName "freeroam"
local TEST_RESOURCE = "editor_test"
local fileTypes = { "script","map","file","config","html" } 
local specialFileTypes = { "script","file","config","html" }

loadedMap = false
addEvent ( "openResource", true )
addEvent ( "saveResource", true )
addEvent ( "testResource", true )
addEvent ( "newResource", true )
addEvent ( "quickSaveResource", true )

---
addEventHandler ( "onResourceStart", thisResourceRoot,
	function()
		destroyElement( rootElement )
	end
)

addEventHandler ( "onResourceStop", thisResourceRoot,
	function()
		if ( loadedMap ) then
			local currentMap = getResourceFromName ( loadedMap )
			loadedMap = false
		end
	end
)

---
addEventHandler("newResource", rootElement,
	function()
		editor_gui.outputMessage (getPlayerName(client).." started a new map.", root,255,0,0)
		if ( loadedMap ) then
			local currentMap = getResourceFromName ( loadedMap )
			stopResource ( currentMap )
			loadedMap = false
		end
		destroyElement(root)
		passDefaultMapSettings()
		triggerClientEvent ( source, "saveloadtest_return", source, "new", true )
	end
)

---
addEventHandler ( "openResource", rootElement,
	function ( resourceName )
		--need to clear undo/redo history!
		local returnValue
		local map = getResourceFromName ( resourceName )
		if ( map ) then
			--
			destroyElement(root)
			elementProperties = {}
			local maps = getResourceFiles ( map, "map" )
			for key,mapPath in ipairs(maps) do
				local mapNode = xmlLoadFile ( mapPath, map )

				local usedDefinitions = xmlNodeGetAttribute(mapNode, "edf:definitions")
				if usedDefinitions then
					-- The map specifies a set of EDF to load
					local loadedDefinitions = edf.edfGetLoadedEDFResources()
					local usedDefinitions = split(usedDefinitions, 44)
					-- Load the neccessary definitions
					for k,defName in ipairs(usedDefinitions) do
						local definition = getResourceFromName(defName)
						if ( definition ) and ( getResourceState(definition) ~= 'running' ) then
							blockMapManager ( definition ) --Stop mapmanager from treating this like a game.  LIFE IS NOT A GAME.
							edf.edfStartResource(definition)
							table.insert (allEDF.addedEDF, defName )
							local key = table.find(allEDF.availEDF,defName)
							if key then
								table.remove ( allEDF.availEDF, key )
								break
							end
						end
					end
					triggerClientEvent('syncEDFDefinitions', rootElement, allEDF)
				end

				local mapElement = loadMapData ( mapNode, thisResourceRoot, false )
				flattenTree ( mapElement, thisDynamicRoot )
				destroyElement ( mapElement )
			end
			
			loadedMap = resourceName 
			passNewMapSettings()
			returnValue = true
			editor_gui.outputMessage ( tostring(getPlayerName ( source )).." opened map "..tostring(resourceName)..".", root,255,0,0)
		else
			returnValue = false
		end
		triggerClientEvent ( source, "saveloadtest_return", source, "open", returnValue )
	end
)



---Save
function saveResource ( resourceName, test )
	if ( loadedMap ) then
		if string.lower(loadedMap) == string.lower(resourceName) then
			quickSave(true)
			return
		end
	end
	local resource = getResourceFromName ( resourceName )
	local metaNodes = {}
	if ( resource ) then
		--Clear out old files from the resource
		if not mapmanager.isMap ( resource ) then
			triggerClientEvent ( client, "saveloadtest_return", client, "save", false, resourceName, 
			"You cannot overwrite non-map resources." )
			return			
		end
		for i,fileType in ipairs(fileTypes) do
			local files = getResourceFiles(resource,fileType)
			if not files then
				triggerClientEvent ( client, "saveloadtest_return", client, "save", false, resourceName,
				"Could not overwrite resource, the target resource may be corrupt." )
				return	
			end
			for j,filePath in ipairs(files) do
				if not removeResourceFile ( resource, filePath, fileType ) then
					triggerClientEvent ( client, "saveloadtest_return", client, "save", false, resourceName,
					"Could not overwrite resource.  The map resource may be in .zip format." )
					return
				end
			end
		end
	else
		resource = createResource ( resourceName )
		if not resource then
			triggerClientEvent ( client, "saveloadtest_return", client, "save", false, resourceName,
			"Could not create resource.  The resource directory may exist already or be invalid" )
			return
		end
	end
	if ( loadedMap ) and ( loadedMap ~= resourceName ) then
		metaNodes = copyResourceFiles ( getResourceFromName(loadedMap), resource )
	end
	local xmlNode = addResourceMap ( resource, resourceName..".map" )
	local returnValue = dumpMap ( xmlNode, true )
	clearResourceMeta ( resource, true )
	local metaNode = xmlLoadFile ( "meta.xml",resource )
	dumpMeta ( metaNode, metaNodes, resource, resourceName..".map" )
	xmlUnloadFile ( metaNode )
	if ( test ) then return returnValue end
	if returnValue then
		loadedMap = resourceName
		editor_gui.outputMessage (getPlayerName(source).." saved to map resource \""..resourceName.."\".", root,255,0,0)
	end
	triggerClientEvent ( client, "saveloadtest_return", client, "save", returnValue, resourceName )
	return returnValue
end
addEventHandler ( "saveResource", rootElement, saveResource )

function quickSave(saveAs)
	if loadedMap then
		local resource = getResourceFromName ( loadedMap )
		local mapTable = getResourceFiles ( resource,"map" )
		if not mapTable then
			triggerClientEvent ( client, "saveloadtest_return", client, "save", false, resourceName,
			"Could not overwrite resource, the target resource may be corrupt." )
			return	
		end
		for key,mapPath in ipairs(mapTable) do
			if not removeResourceFile ( resource,mapPath,"map" ) then
				triggerClientEvent ( client, "saveloadtest_return", client, "save", false, resourceName,
				"Could not overwrite resource.  The map resource may be in .zip format." )
				return
			end
		end
		clearResourceMeta ( resource, true )
		local xmlNode = addResourceMap ( resource, loadedMap..".map" )
		if not xmlNode then
			triggerClientEvent ( client, "saveloadtest_return", client, "quickSave", false, loadedMap )
			return
		end
		dumpMap ( xmlNode, true )
		xmlUnloadFile ( xmlNode )
		local metaNode = xmlLoadFile ( "meta.xml",resource )
		dumpMeta ( metaNode, {}, resource, loadedMap..".map" )
		xmlUnloadFile ( metaNode )
		editor_gui.outputMessage (getPlayerName(client).." saved the map.", root,255,0,0)
		if saveAs then
			triggerClientEvent ( client, "saveloadtest_return", client, "save", true )
		end
	else
		editor_gui.loadsave_getResources("saveAs",source)
	end
end
addEventHandler("quickSaveResource", rootElement, quickSave )


------TESTING
local testBackupNodes = {}
addEventHandler ( "testResource", root,
function (gamemodeName)
	--Check if the freeroam resource exists
	if not ( freeroamRes ) then
		triggerClientEvent ( client, "saveloadtest_return", client, "test", false, false, "'freeroam' not found.  Test could not be started." )
		return
	end
	g_restoreEDF = nil
	triggerClientEvent ( root, "suspendGUI", client )
	local success = saveResource ( TEST_RESOURCE, true )
	if ( success ) then
		beginTest(client,gamemodeName)
	else
		triggerClientEvent ( root, "saveloadtest_return", client, "test", false, false, 
		"Dummy 'editor_test' resource may be corrupted!" )
		return false	
	end
end )

function beginTest(client,gamemodeName)
	local testMap = getResourceFromName(TEST_RESOURCE)
	if not mapmanager.isMap(testMap) then
		triggerClientEvent ( client, "saveloadtest_return", client, "test", false, false, 
		"Dummy 'editor_test' resource may be corrupted!" )
		return false
	end
	g_default_spawnmaponstart = get"freeroam.spawnmaponstart"
	g_default_spawnmapondeath = get"freeroam.spawnmapondeath"
	g_default_welcometextonstart = get"freeroam.welcometextonstart"
	resetMapInfo()
	disablePickups(false)
	if ( gamemodeName ) then
		set ( "*freeroam.spawnmapondeath", "false" )
		if not startResource ( freeroamRes, true ) then
			restoreSettings()
			triggerClientEvent ( root, "saveloadtest_return", client, "test", false, false, 
			"'editor_main' may lack sufficient ACL previlages to start/stop resources! (1)" )
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
				"'editor_main' may lack sufficient ACL previlages to start/stop resources! (2)" )
				return false
			end
		else
			if not mapmanager.changeGamemode(gamemode,testMap) then
				restoreSettings()
				triggerClientEvent ( root, "saveloadtest_return", client, "test", false, false, 
				"'editor_main' may lack sufficient ACL previlages to start/stop resources! (3)" )
				return false
			end
		end
		g_in_test = "gamemode"
	else
		if not startResource ( freeroamRes, true ) then
			restoreSettings()
			triggerClientEvent ( root, "saveloadtest_return", client, "test", false, false, 
			"'editor_main' may lack sufficient ACL previlages to start/stop resources! (4)" )
			return false	
		end
		if not startResource ( testMap, true ) then
			triggerClientEvent ( root, "saveloadtest_return", client, "test", false, false, 
			"'editor_main' may lack sufficient ACL previlages to start/stop resources! (5)" )
			return false			
		end
		g_in_test = "map"
	end
	for i,player in ipairs(getElementsByType"player") do
		setElementDimension ( player, 0 )
	end
	setElementData ( thisRoot, "g_in_test", true )
	set ( "*freeroam.welcometextonstart", "false" )
	set ( "*freeroam.spawnmaponstart", "false" )
end

function startGamemodeOnStop(resource)
	setTimer ( mapmanager.changeGamemode, 50, 1, resource,getResourceFromName(TEST_RESOURCE))
	removeEventHandler ( "onResourceStop", source, startGamemodeOnStop )
end


addEvent ( "stopTest", true )
addEventHandler ( "stopTest",root,
	function()
		stopResource ( freeroamRes )
		disablePickups(true)
		local testRes = getResourceFromName(TEST_RESOURCE)
		--Restore settings to how they were before the test
		restoreSettings()
		if g_in_test == "gamemode" then
			local gamemode = mapmanager.getRunningGamemode ( )
			if not ( addEventHandler ( "onResourceStop", getResourceRootElement(gamemode), restoreGUIOnMapStop ) ) then
				addEventHandler ( "onResourceStop", getResourceRootElement(testRes), restoreGUIOnMapStop )
			end
			mapmanager.stopGamemode()
		else
			addEventHandler ( "onResourceStop", getResourceRootElement(testRes), restoreGUIOnMapStop )
			resetMapInfo()
		end
		stopResource ( testRes )
		for i,player in ipairs(getElementsByType"player") do
			spawnPlayer ( player, 2483, -1666, 21 )
			takeAllWeapons ( player )
			setElementDimension ( player, 65000 )
		end
		g_mapstophandled = g_mapstophandled or addEventHandler ( "onGamemodeMapStop", root, restoreGUIOnGamemodeMapStop )
	end
)

function restoreSettings()
	set ( "*freeroam.spawnmaponstart", g_default_spawnmaponstart )
	set ( "*freeroam.spawnmapondeath", g_default_spawnmapondeath )
	set ( "*freeroam.welcometextonstart", g_default_welcometextonstart )
end

function restoreGUIOnMapStop()
	if g_restoreEDF then
		--Start the edf resource again if it was stopped
		setTimer ( startResource, 50, 1, g_restoreEDF,false,false,true,false,false,false,false,false,true)
		g_restoreEDF = nil
	end
	triggerClientEvent ( getRootElement(), "resumeGUI", getRootElement() )
	setElementData ( thisRoot, "g_in_test", nil )
	removeEventHandler ( "onResourceStop", source, restoreGUIOnMapStop )
end

function restoreGUIOnGamemodeMapStop(gamemode)
	if loadedEDF[gamemode] then
		startResource ( gamemode,false,false,true,false,false,false,false,false,true)
	end
	triggerClientEvent ( getRootElement(), "resumeGUI", getRootElement() )
	setElementData ( thisRoot, "g_in_test", nil )
	removeEventHandler ( "onGamemodeMapStop", root, restoreGUIOnGamemodeMapStop )
	g_mapstophandled = nil
end
