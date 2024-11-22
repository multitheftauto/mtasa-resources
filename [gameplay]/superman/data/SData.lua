local supermanReceivers = {}

local function tableToElementsArray(tableWithElements)
	local arrayTable = {}
	local elementID = 0

	for elementReference, _ in pairs(tableWithElements) do
		local validElement = isElement(elementReference)

		if (validElement) then
			local newElementID = (elementID + 1)

			arrayTable[elementID] = elementReference
			elementID = newElementID
		end
	end

	return arrayTable
end

local function canElementDataBeChanged(clientElement, sourceElement, dataKey, newValue)
	local matchingPlayer = (clientElement == sourceElement)

	if (not matchingPlayer) then
		return false
	end

	local supermanDataKey = SUPERMAN_ALLOWED_DATA_KEYS[dataKey]

	if (not supermanDataKey) then
		return true
	end

	local newValueDataType = type(newValue)
	local newValueBool = (newValueDataType == "boolean")

	return newValueBool
end

local function onServerSupermanSetData(dataKey, dataValue)
	if (not client) then
		return false
	end

	setSupermanData(client, dataKey, dataValue)
end
if (not SUPERMAN_USE_ELEMENT_DATA) then
	addEvent("onServerSupermanSetData", true)
	addEventHandler("onServerSupermanSetData", root, onServerSupermanSetData)
end

local function onElementDataChangeSuperman(dataKey, oldValue, newValue)
	if (not client) then
		return false
	end

	local allowElementDataChange = canElementDataBeChanged(client, source, dataKey, newValue)

	if (not allowElementDataChange) then
		local removeChangedData = (oldValue == nil)

		if (removeChangedData) then
			removeElementData(source, dataKey)
		else
			setElementData(source, dataKey, oldValue)
		end
	end
end
if (SUPERMAN_USE_ELEMENT_DATA) then addEventHandler("onElementDataChange", root, onElementDataChangeSuperman) end

local function onPlayerResourceStartSyncSuperman(startedResource)
	local matchingResource = (startedResource == resource)

	if (not matchingResource) then
		return false
	end

	local supermansData = getSupermansData()

	triggerClientEvent(source, "onClientSupermanSync", source, supermansData)
	supermanReceivers[source] = true
end
if (not SUPERMAN_USE_ELEMENT_DATA) then addEventHandler("onPlayerResourceStart", root, onPlayerResourceStartSyncSuperman) end

local function onResourceStopClearSupermanElementData()
	local playersTable = getElementsByType("player")

	for playerID = 1, #playersTable do
		local playerElement = playersTable[playerID]

		for dataKey, _ in pairs(SUPERMAN_ALLOWED_DATA_KEYS) do
			removeElementData(playerElement, dataKey)
		end
	end
end
if (SUPERMAN_USE_ELEMENT_DATA) then addEventHandler("onResourceStop", resourceRoot, onResourceStopClearSupermanElementData) end

local function onPlayerQuitClearSupermanReceiver()
	supermanReceivers[source] = nil
end
if (not SUPERMAN_USE_ELEMENT_DATA) then addEventHandler("onPlayerQuit", root, onPlayerQuitClearSupermanReceiver) end

function getSupermanReceivers()
	local supermanListeners = tableToElementsArray(supermanReceivers)

	return supermanListeners
end