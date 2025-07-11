allEDF = {}

addEventHandler ( "onClientGUILoaded", root,
	function()
		triggerClientEvent ( client, "syncEDFDefinitions", client, allEDF )
	end
)

function setClientAddedEDFs(resources)
	table.map(resources, getResourceName)
	-- move superfluous resources to available list
	for i=#allEDF.addedEDF,1,-1 do
		if not table.find(resources, allEDF.addedEDF[i]) then
			table.insert(allEDF.availEDF, allEDF.addedEDF[i])
			table.remove(allEDF.addedEDF, i)
		end
	end
	-- remove added resources from available list
	table.subtract(allEDF.availEDF, resources)
	-- set added list
	allEDF.addedEDF = resources
	triggerClientEvent('syncEDFDefinitions', root, allEDF)
end

function addClientEDFs(edfsToAdd)
	for i,edfToAdd in ipairs(edfsToAdd) do
		edfToAdd = getResourceName(edfToAdd)
		for j,availResName in ipairs(allEDF.availEDF) do
			if availResName == edfToAdd then
				table.remove(allEDF.availEDF, j)
				table.insert(allEDF.addedEDF, edfToAdd)
				break
			end
		end
	end
	triggerClientEvent('syncEDFDefinitions', root, allEDF)
end

function removeClientEDFs(edfsToRemove)
	for i,edfToRemove in ipairs(edfsToRemove) do
		edfToRemove = getResourceName(edfToRemove)
		for j,addedResName in ipairs(allEDF.addedEDF) do
			if addedResName == edfToRemove then
				table.remove(allEDF.addedEDF, j)
				table.insert(allEDF.availEDF, edfToRemove)
				break
			end
		end
	end
	triggerClientEvent('syncEDFDefinitions', root, allEDF)
end

function getClientAvailableEDFs()
	return table.map(table.shallowcopy(allEDF.availEDF), getResourceFromName)
end

function getClientAddedEDFs()
	return table.map(table.shallowcopy(allEDF.addedEDF), getResourceFromName)
end

addEventHandler ( "onResourceStart", resourceRoot,
	function ()
		if getResourceState( edf.res ) == "running" then
			loadedDefs = edf.edfGetLoadedEDFResources()
			--get EDF defs
			local resources = getResources()
			allEDF.availEDF = {}
			allEDF.addedEDF = {}
			for k,v in ipairs(resources) do
				if v ~= edf.res and v ~= getThisResource() and edf.edfHasDefinition(v) then
					local loaded = false
					for k2, loadedResource in pairs(loadedDefs) do
						if v == loadedResource then
							loaded = true
							break
						end
					end
					if ( loaded ) then
						table.insert ( allEDF.addedEDF, getResourceName ( v ) )
					else
						table.insert ( allEDF.availEDF, getResourceName ( v ) )
					end
				end
			end
		end
	end
)

function reloadEDFDefinitions(newEDF,noOutput)
	if client and not isPlayerAllowedToDoEditorAction(client,"definitions") then
		editor_gui.outputMessage ("You don't have permissions to change the map definitions!", client,255,0,0)
		triggerClientEvent(client, 'syncEDFDefinitions', root, allEDF)
		return
	end

	if client and not noOutput then
		editor_gui.outputMessage ( getPlayerName(client).." updated the loaded definitions.", root, 255, 255, 0 )
	end
	loadedDefs = edf.edfGetLoadedEDFResources()
	--load new defs
	for k,resourceName in ipairs(newEDF.addedEDF) do
		--check if the resource is loaded already
		local resource = getResourceFromName ( resourceName )
		if resource then
			local loaded = false
			for k2, loadedResource in ipairs(loadedDefs) do
				if loadedResource == resource then
					loaded = true
					break
				end
			end
			if loaded == false then
				outputServerLog ( "loading "..resourceName.." def." )
				outputConsole ( "loading "..resourceName.." def." )
				--Only accept server config files and general files (for edf icons)
				-- startResource ( getResourceFromName(resourceName),false,true,false,false,false,false,false,true)
				blockMapManager ( resource ) --Stop mapmanager from treating this like a game.  LIFE IS NOT A GAME.
				edf.edfStartResource ( resource )
			end
		else
			if resourceName ~= "editor_main" then
				table.remove(newEDF.addedEDF, k)
			end
		end
	end
	--unload defs
	for k, resourceName in ipairs(newEDF.availEDF) do
		if resourceName ~= "editor_main" then
			local resource = getResourceFromName ( resourceName )
			if resource then
				local loaded = false
				for k2, loadedResource in ipairs(loadedDefs) do
					if loadedResource == resource then
						loaded = true
						break
					end
				end
				if loaded == true then
					outputServerLog ( "unloading "..resourceName.." def." )
					outputConsole ( "unloading "..resourceName.." def." )
					-- stopResource ( getResourceFromName(resourceName) )
					edf.edfStopResource ( resource )
				end
			else
				table.remove(newEDF.availEDF, k)
			end
		end
	end
	allEDF = newEDF
	triggerClientEvent('syncEDFDefinitions', root, allEDF)
end
addEvent ( "reloadEDFDefinitions", true )
addEventHandler ( "reloadEDFDefinitions", root, reloadEDFDefinitions )

addEventHandler ( "onResourceStop",resourceRoot,
	function()
		if not allEDF then return end --allEDF is cleared when the editor is stopped (prevent a debug error)
		for i, resourceName in ipairs(allEDF.addedEDF) do
			local resource = getResourceFromName(resourceName)
			if resource and getResourceState ( resource ) == "running" then
				stopResource ( resource )
			end
		end
	end
)

local gamemodeToCancel
addEventHandler ( "onGamemodeStart", root,
	function ( resource )
		if resource == gamemodeToCancel then
			cancelEvent(true)
			gamemodeToCancel = nil
		end
	end
)

function blockMapManager ( resource )
	if mapmanager.isGamemode(resource) then
		gamemodeToCancel = resource
	else
		gamemodeToCancel = nil
	end
end
