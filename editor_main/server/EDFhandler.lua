local clientGUILoaded = {} --We dont want to trigger client events if they havent downloaded client scripts yet
loadedEDF = {}

addEventHandler ( "onResourceStart", resourceRoot,
	function(resource)
		if getResourceState( edf.res ) == "running" then
			local definitionsList = edf.edfGetLoadedEDFResources()
			for index, resource2 in ipairs(definitionsList) do
				registerEDF( resource2 )
			end
		end

		if resource == thisResource then
			if not hasObjectPermissionTo(thisResource, "general.ModifyOtherObjects") then
				outputChatBox("** WARNING: Resource editor_main hasn't access to the ModifyOtherObjects ACL right. ",
				              root, 255, 50, 50)
				outputChatBox("** You won't be able to work with maps or EDFs unless you change it!",
				              root, 255, 50, 50)
				outputDebugString("** Resource editor_main hasn't access to the ModifyOtherObjects ACL right. ",
				                  2, 255, 50, 50)
				outputDebugString("** You won't be able to work with maps or EDFs unless you change it!",
				                  2, 255, 50, 50)
			end
		end
	end
)

function registerEDF( resource )
	--ignore edf
	if resource == edf.res then
		return
	end
	loadedEDF[resource] = edf.edfGetDefinition(resource)
	for i, player in ipairs(getElementsByType"player") do
		if clientGUILoaded[player] then
			triggerClientEvent ( player, "doLoadEDF", root, loadedEDF[resource], getResourceName ( resource ) )
		end
	end
end
addEventHandler ( "onEDFLoad", root, registerEDF)

addEventHandler ( "onEDFUnload", root,
	function ( resource )
		if not loadedEDF[resource] then return end -- Only unload if the EDF has been loaded
		loadedEDF[resource] = nil
		for i, player in ipairs(getElementsByType"player") do
			if clientGUILoaded[player] then
				triggerClientEvent ( player, "doUnloadEDF", root, getResourceName ( resource ) )
			end
		end
	end
)

local function sendEDF()
	clientGUILoaded[source] = true
	for resource, resourceDefinition in pairs(loadedEDF) do
		triggerClientEvent ( source, "doLoadEDF", root, resourceDefinition, getResourceName ( resource ) )
	end
end
addEventHandler ( "onClientGUILoaded", root, sendEDF)
addEventHandler ( "onClientRequestEDF", root, sendEDF)
