local rootElement = getRootElement()
local WAIT_LOAD_INTERVAL = 100 --ms

function makeElementStatic(element)
	if getElementType(element) == "vehicle" then
		triggerClientEvent(rootElement, "doSetVehicleStatic", element)
	elseif getElementType(element) == "ped" then
		triggerClientEvent(rootElement, "doSetPedStatic", element)
	else
		for i, child in ipairs(getElementChildren(element)) do
			makeElementStatic(child)
		end
	end
end

function setupNewElement(element, creatorResource, creatorClient, attachLater,shortcut,selectionSubmode)
	selectionSubmode = selectionSubmode or 1
	setElementParent(element, thisDynamicRoot)
	setElementDimension ( element, getWorkingDimension() )
	makeElementStatic( element )
	assignID ( element )
	triggerEvent ( "onElementCreate_undoredo", element )
	if attachLater then
		setTimer(triggerClientEvent, WAIT_LOAD_INTERVAL, 1, creatorClient, "doSelectElement", element, selectionSubmode, shortcut )
	end
	justCreated[element] = true --mark it so undoredo ignores first placement
	
	triggerEvent("onElementCreate", element)
	triggerClientEvent(rootElement, "onClientElementCreate", element)
end

addEventHandler ( "doCreateElement", rootElement,
	function ( elementType, resourceName, parameters, attachLater, shortcut )
		parameters = parameters or {}
		
		local creatorResource = getResourceFromName( resourceName )
		local edfElement = edf.edfCreateElement (
			elementType,
			creatorResource,
			parameters,
			true --editor mode
		)
		
		if edfElement then
			outputDebugString ( "Created '"..elementType..":"..tostring(edfElement).."' from '"..resourceName.."'" )
			setupNewElement(edfElement, creatorResource, client, attachLater, shortcut)
		else
			outputDebugString ( "Failed to create '"..elementType.."' from '"..resourceName.."'" )
		end
	end
)

addEventHandler ( "doCloneElement", rootElement,
	function (attachMode,creator)
		if creator then
			edf.edfSetCreatorResource(source,creator)
		end
		local clone = edf.edfCloneElement(source,true)
		
		if clone then
			outputDebugString ( "Cloned '"..getElementType(source).."'." )
			setupNewElement(clone, creator or edf.edfGetCreatorResource(source), client, true, false, attachMode)
			setLockedElement(source, nil)
		else
			outputDebugString ( "Failed to clone '"..getElementType(source).."'" )
		end
	end
)

addEventHandler ( "doDestroyElement", rootElement,
	function (forced)
		local locked = getLockedElement(client)
		if forced or locked == source then
			outputDebugString ( "Deleted '"..getElementType(source).."'." )
			
			if locked then
				setLockedElement(client, nil)
			end
			
			triggerEvent("onElementDestroy", source)
			triggerClientEvent(rootElement, "onClientElementDestroyed", source)
			
			triggerEvent ( "onElementDestroy_undoredo", source )
		end
	end
)
