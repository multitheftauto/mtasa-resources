local WAIT_LOAD_INTERVAL = 100 --ms

function makeElementStatic(element)
	if getElementType(element) == "vehicle" then
		triggerClientEvent(root, "doSetVehicleStatic", element)
	elseif getElementType(element) == "ped" then
		triggerClientEvent(root, "doSetPedStatic", element)
	else
		for i, child in ipairs(getElementChildren(element)) do
			makeElementStatic(child)
		end
	end
end

function setupNewElement(element, creatorResource, creatorClient, attachLater,shortcut,selectionSubmode)
	selectionSubmode = selectionSubmode or 1
	setElementParent(element, mapContainer)
	setElementDimension ( element, getWorkingDimension() )
	makeElementStatic( element )
	assignID ( element )
	triggerEvent ( "onElementCreate_undoredo", element )
	if attachLater then
		setTimer(triggerClientEvent, WAIT_LOAD_INTERVAL, 1, creatorClient, "doSelectElement", element, selectionSubmode, shortcut )
	end
	justCreated[element] = true --mark it so undoredo ignores first placement

	triggerEvent("onElementCreate", element)
	triggerClientEvent(root, "onClientElementCreate", element)
end

addEventHandler ( "doCreateElement", root,
	function ( elementType, resourceName, parameters, attachLater, shortcut )
		if client and not isPlayerAllowedToDoEditorAction(client,"createElement") then
			editor_gui.outputMessage ("You don't have permissions to create a new element!", client,255,0,0)
			return
		end

		parameters = parameters or {}

		local creatorResource = getResourceFromName( resourceName )
		local edfElement = edf.edfCreateElement (
			elementType,
			client,
			creatorResource,
			parameters,
			true --editor mode
		)

		if edfElement then
			outputConsole ( "Created '"..elementType..":"..tostring(edfElement).."' from '"..resourceName.."'" )
			setupNewElement(edfElement, creatorResource, client, attachLater, shortcut)
		else
			outputDebugString ( "Failed to create '"..elementType.."' from '"..resourceName.."'" )
		end
	end
)

addEventHandler ( "doCloneElement", root,
	function (attachMode,creator)
		if client and not isPlayerAllowedToDoEditorAction(client,"createElement") then
			editor_gui.outputMessage ("You don't have permissions to clone an element!", client,255,0,0)
			return
		end

		if creator then
			edf.edfSetCreatorResource(source,creator)
		end
		local clone = edf.edfCloneElement(source,true)

		if clone then
			outputConsole ( "Cloned '"..getElementType(source).."'." )
			setupNewElement(clone, creator or edf.edfGetCreatorResource(source), client, true, false, attachMode)
			setLockedElement(source, nil)
		else
			outputDebugString ( "Failed to clone '"..getElementType(source).."'" )
		end
	end
)

addEventHandler ( "doDestroyElement", root,
	function (forced)
		if client and not isPlayerAllowedToDoEditorAction(client,"deleteElement") then
			editor_gui.outputMessage ("You don't have permissions to delete an element!", client,255,0,0)
			return
		elseif client and client ~= edf.edfGetCreatorClient(source) and not isPlayerAllowedToDoEditorAction(client,"deleteOtherElement") then
			editor_gui.outputMessage ("You don't have permissions to delete someone else's element!", client,255,0,0)
			return
		end

		local locked = getLockedElement(client)
		if forced or locked == source then
			outputConsole ( "Deleted '"..getElementType(source).."'." )

			if locked then
				setLockedElement(client, nil)
			end

			triggerEvent("onElementDestroy", source)
			triggerClientEvent(root, "onClientElementDestroyed", source)

			triggerEvent ( "onElementDestroy_undoredo", source )
		end
	end
)
