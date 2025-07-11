local SCRIPT_G = {}
local TEMP_SCRIPT_STORE = {}
local RESOURCE_SCRIPT_COUNT = {}
local REQUIRED_FILES = {}

function table.size(tab) local l = 0  for _ in pairs(tab) do l = l + 1 end  return l end

addEvent ("requestScriptDownloads", true)
addEventHandler ( "requestScriptDownloads", root,
	function(scriptInfo,resourceName)
		REQUIRED_FILES[resourceName] = {}
		TEMP_SCRIPT_STORE[resourceName] = {}
		local requiredFiles = REQUIRED_FILES[resourceName]
		RESOURCE_SCRIPT_COUNT[resourceName] = #scriptInfo
		for i,data in ipairs(scriptInfo) do
			--local file = xmlLoadFile ( "edfcache/"..resourceName.."/"..data.path )
			local file = false
			if not file then
				requiredFiles[i] = data.path --We preserve the index to maintain the order when sending to server and back to client
			else
				script = xmlNodeGetValue ( file )
				if md5(script) ~= data.md5 then
					requiredFiles[i] = data.path
				else
					TEMP_SCRIPT_STORE[resourceName][i] = script
				end
			end
		end
		--Do we have any required files?  If not we can just load them now
		if table.size(requiredFiles) ~= 0 then
			triggerServerEvent ( "requestSendScripts", root, requiredFiles, resourceName )
		else
			loadScripts ( resourceName )
		end
	end
)

function loadScripts ( resourceName )
	--First we check if we have all the scripts ready for this resource
	if table.size(TEMP_SCRIPT_STORE[resourceName]) ~= RESOURCE_SCRIPT_COUNT[resourceName] then return false end
	--We have all our scripts ready.  Lets load them
	for i,script in pairs(TEMP_SCRIPT_STORE[resourceName]) do
		if not SCRIPT_G[resourceName] then
			createEventHandlerContainerForResource(resourceName)
			createKeyBindContainerForResource(resourceName)
			createCommandHandlerContainerForResource(resourceName)
			SCRIPT_G[resourceName] = {addEventHandler = createAddEventHandlerFunctionForResource(resourceName), removeEventHandler = createRemoveEventHandlerFunctionForResource(resourceName),
										bindKey = createBindKeyFunctionForResource(resourceName), unbindKey = createUnbindKeyFunctionForResource(resourceName),
										addCommandHandler = createAddCommandHandlerFunctionForResource(resourceName), removeCommandHandler = createRemoveCommandHandlerFunctionForResource(resourceName)}
			setmetatable(SCRIPT_G[resourceName], { __index = _G })
		end
		local loadFunction, errorMsg = loadstring ( script )
		if errorMsg then
			outputDebugString ( "Error: "..resourceName.."/"..tostring(REQUIRED_FILES[resourceName][id])..": "..errorMsg  )
			return false
		end
		setfenv ( loadFunction, SCRIPT_G[resourceName] )()
		if type(SCRIPT_G[resourceName].onStart) == "function" then
			SCRIPT_G[resourceName].onStart()
		end
	end
	--The download process is finished, so lets get rid of our temporary caches
	TEMP_SCRIPT_STORE[resourceName] = nil
	RESOURCE_SCRIPT_COUNT[resourceName] = nil
	REQUIRED_FILES[resourceName] = nil
	return true
end

addEventHandler ( "onClientResourceStop", root,
	function(resource)
		local resourceName = getResourceName(resource)
		if SCRIPT_G[resourceName] then
			if type(SCRIPT_G[resourceName].onStop) == "function" then
				SCRIPT_G[resourceName].onStop()
			end
			cleanEventHandlerContainerForResource(resourceName)
			cleanKeyBindContainerForResource(resourceName)
			cleanCommandHandlerContainerForResource(resourceName)
			SCRIPT_G[resourceName] = nil --Unload our script
		end
	end
)

addEvent ("downloadScript", true)
addEventHandler ( "downloadScript", root,
	function (script, id, resourceName)
		TEMP_SCRIPT_STORE[resourceName][id] = script
		local path = REQUIRED_FILES[resourceName][id]
		--Lets cache our newly downloaded script
		local file = xmlCreateFile ( "edfcache/"..resourceName.."/"..path, "script" )
		if file then
			xmlNodeSetValue ( file, script )
			xmlSaveFile ( file )
			xmlUnloadFile ( file )
		end
		loadScripts ( resourceName ) --Attempt to load all scripts at this point
	end
)
