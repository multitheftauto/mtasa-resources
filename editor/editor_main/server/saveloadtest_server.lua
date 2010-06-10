g_in_test = false
local g_restoreEDF, dumpTimer
local thisRoot = getResourceRootElement(getThisResource())
local root = getRootElement()
local g_default_spawnmaponstart,g_default_spawnmapondeath,g_defaultwelcometextonstart
local restoreGUIOnMapStop, restoreGUIOnGamemodeMapStop, startGamemodeOnStop
local freeroamRes = getResourceFromName "freeroam"
local TEST_RESOURCE = "editor_test"
local DUMP_RESOURCE = "editor_dump"
local dumpInterval = get("dumpSaveInterval") and tonumber(get("dumpSaveInterval"))*1000 or 60000
local fileTypes = { "script","map","file","config","html" } 
local specialFileTypes = { "script","file","config","html" }

loadedMap = false
addEvent ( "onNewMap" )
addEvent ( "onMapOpened" )
addEvent ( "openResource", true )
addEvent ( "saveResource", true )
addEvent ( "testResource", true )
addEvent ( "newResource", true )
addEvent ( "quickSaveResource", true )

---
addEventHandler ( "onResourceStart", thisResourceRoot,
	function()
		destroyElement( rootElement )
		setTimer(startUp, 1000, 1)
	end
)

function startUp()
	enabled = getBool("enableDumpSave", true)
	if enabled then
		if not openResource(DUMP_RESOURCE, true) then
			outputDebugString("cant open dump, create new dump")
			saveResource(DUMP_RESOURCE, true)
		else
			if #getElementsByType("player") > 0 then
				editor_gui.outputMessage("On-Exit-Save has loaded the most recent backup of the previously loaded map. Use 'new' to start a new map.", root, 255, 255, 0, 20000)
			else
				addEventHandler("onPlayerJoin", rootElement, onJoin)
			end
		end
		dumpTimer = setTimer(dumpSave, dumpInterval, 0)
	end
	for i,player in ipairs(getElementsByType("player")) do
		local account = getPlayerAccount(player)
		if account then
			local accountName = getAccountName(account)
			local adminGroups = split(get("admingroup") or "Admin",string.byte(','))
			for _,name in ipairs(adminGroups) do
				local group = aclGetGroup(name)
				if group then
					for i,obj in ipairs(aclGroupListObjects(group)) do
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
	removeEventHandler("onPlayerJoin", rootElement, onJoin)
end

---
addEventHandler("newResource", rootElement,
	function()
		editor_gui.outputMessage (getPlayerName(client).." started a new map.", root,255,0,0)
		if ( loadedMap ) then
			local currentMap = getResourceFromName ( loadedMap )
			stopResource ( currentMap )
			loadedMap = DUMP_RESOURCE
		end
		destroyElement(root)
		passDefaultMapSettings()
		triggerClientEvent ( source, "saveloadtest_return", source, "new", true )
		triggerEvent("onNewMap", thisResourceRoot)
		dumpSave()
	end
)

---
function openResource( resourceName, onStart )
	--need to clear undo/redo history!
	local returnValue
	local map = getResourceFromName ( resourceName )
	if ( map ) then
		--
		destroyElement(root)
		local maps = getResourceFiles ( map, "map" )
		local mapName = DUMP_RESOURCE
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
				reloadEDFDefinitions(newEDF)
			end

			local mapElement = loadMapData ( mapNode, thisResourceRoot, false )
			flattenTree ( mapElement, thisDynamicRoot )
			destroyElement ( mapElement )
			mapName = string.sub(mapPath, 1, -5)
			xmlUnloadFile ( mapNode )
		end
		
		loadedMap = resourceName 
		passNewMapSettings()
		returnValue = true
		if not onStart then
			editor_gui.outputMessage ( tostring(getPlayerName ( source )).." opened map "..tostring(resourceName)..".", root,255,0,0)
		else
			loadedMap = mapName
		end
		triggerEvent("onMapOpened", thisResourceRoot, map)
	else
		returnValue = false
	end
	if onStart then
		return returnValue
	else
		triggerClientEvent ( source, "saveloadtest_return", source, "open", returnValue )
		dumpSave()
	end
end
addEventHandler ( "openResource", rootElement, openResource )



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
	local metaNode = xmlLoadFile ( ':' .. getResourceName(resource) .. '/' .. "meta.xml" )
	dumpMeta ( metaNode, metaNodes, resource, resourceName..".map", test )
	xmlUnloadFile ( metaNode )
	if ( test ) then return returnValue end
	if returnValue then
		loadedMap = resourceName
		editor_gui.outputMessage (getPlayerName(source).." saved to map resource \""..resourceName.."\".", root,255,0,0)
	end
	triggerClientEvent ( client, "saveloadtest_return", client, "save", returnValue, resourceName )
	dumpSave()
	return returnValue
end
addEventHandler ( "saveResource", rootElement, saveResource )

function quickSave(saveAs, dump)
	if loadedMap then
		local resource = getResourceFromName ( dump and DUMP_RESOURCE or loadedMap )
		local mapTable = getResourceFiles ( resource,"map" )
		if not mapTable then
			triggerClientEvent ( client, "saveloadtest_return", client, "save", false, loadedMap,
			"Could not overwrite resource, the target resource may be corrupt." )
			return
		end
		for key,mapPath in ipairs(mapTable) do
			if not removeResourceFile ( resource,mapPath,"map" ) then
				triggerClientEvent ( client, "saveloadtest_return", client, "save", false, loadedMap,
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
		local metaNode = xmlLoadFile ( ':' .. getResourceName(resource) .. '/' .. "meta.xml" )
		dumpMeta ( metaNode, {}, resource, loadedMap..".map" )
		xmlUnloadFile ( metaNode )
		if not dump and loadedMap == DUMP_RESOURCE then
			editor_gui.loadsave_getResources("saveAs",source)
			return
		end
 		if saveAs then
 			triggerClientEvent ( client, "saveloadtest_return", client, "save", true )
 		end
		if not dump then
			editor_gui.outputMessage (getPlayerName(client).." saved the map.", root,255,0,0)
			dumpSave()
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
		if getResourceState(freeroamRes) ~= "running" and not startResource ( freeroamRes, true ) then
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
		if getResourceState(freeroamRes) ~= "running" and not startResource ( freeroamRes, true ) then
			restoreSettings()
			triggerClientEvent ( root, "saveloadtest_return", client, "test", false, false, 
			"'editor_main' may lack sufficient ACL previlages to start/stop resources! (4)" )
			return false
		end
		if getResourceState(testMap) ~= "running" and not startResource ( testMap, true ) then
			triggerClientEvent ( root, "saveloadtest_return", client, "test", false, false, 
			"'editor_main' may lack sufficient ACL previlages to start/stop resources! (5)" )
			return false
		end
		g_in_test = "map"
	end
	dumpSave()
	for i,player in ipairs(getElementsByType"player") do
		setElementDimension ( player, 0 )
	end
	setElementData ( thisRoot, "g_in_test", true )
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
	stopResource ( freeroamRes )
	disablePickups(true)
	local testRes = getResourceFromName(TEST_RESOURCE)
	--Restore settings to how they were before the test
	restoreSettings()
	if g_in_test == "gamemode" then
		local gamemode = mapmanager.getRunningGamemode()
		if not ( addEventHandler ( "onResourceStop", getResourceRootElement(gamemode), restoreGUIOnMapStop ) ) then
			addEventHandler ( "onResourceStop", getResourceRootElement(testRes), restoreGUIOnMapStop )
		end
		mapmanager.stopGamemode()
	else
		addEventHandler ( "onResourceStop", getResourceRootElement(testRes), restoreGUIOnMapStop )
		resetMapInfo()
	end
	stopResource ( testRes )
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
		setTimer(startResource, 50, 1, g_restoreEDF, false, false, true, false, false, false, false, false, true)
		g_restoreEDF = nil
	end
	setTimer(triggerClientEvent, 50, 1, getRootElement(), "resumeGUI", getRootElement())
	setElementData ( thisRoot, "g_in_test", nil )
	removeEventHandler ( "onResourceStop", source, restoreGUIOnMapStop )
end

-- dump settings
function dumpSave()
	if getBool("enableDumpSave", true) and not getElementData(thisRoot, "g_in_test") then
		quickSave(false,true)
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
			dumpTimer = setTimer(dumpSave, dumpInterval, 0)
		end
		if enabled ~= getBool("enableDumpSave", true) then
			set("enableDumpSave", tostring(enabled))
			if enabled then
				dumpTimer = setTimer(dumpSave, dumpInterval, 0)
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
