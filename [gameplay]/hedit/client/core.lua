--
--	CLIENTSIDE RESOURCE START PROCEDURE
--
local function resourceStart()
	--Load the clientside configuration file, or create a new one if it does not exist.
	local rootNode = xmlLoadFile(client_config_file) or xmlCreateFile(client_config_file, "config")
	
	--Ensure all important setting nodes exist.
	for settingKey, defaultValue in pairs(setting) do
		if not xmlFindChild(rootNode, settingKey, 0) then
			local newNode = xmlCreateChild(rootNode, settingKey)
			xmlNodeSetValue(newNode, tostring(defaultValue))
		end
	end
	
	--Remove deprecated/unused setting nodes.
	for _, subNode in ipairs(xmlNodeGetChildren(rootNode)) do
		local nodeName = xmlNodeGetName(subNode)
		if not setting[nodeName] then
			xmlDestroyNode(subNode)
		end
	end
	
	xmlSaveFile(rootNode)
	xmlUnloadFile(rootNode)

	--Cache the client-side handling saves.
	cacheClientSaves()

	--Query the server for admin rights.
	triggerServerEvent("requestRights", root)
	
	--Build the GUI.
	startBuilding()
end
addEventHandler("onClientResourceStart", resourceRoot, resourceStart)

--
--	CLIENTSIDE RESOURCE STOP PROCEDURE
--
local function resourceStop()
	--Unload the clientside configuration file.
	xmlUnloadFile(client_handling_file)
end
addEventHandler("onClientResourceStop", resourceRoot, resourceStop)