-- #######################################
-- ## Project: Superman					##
-- ## Authors: MTA contributors			##
-- ## Version: 3.0						##
-- #######################################

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

function getSupermanReceivers()
	local supermanListeners = tableToElementsArray(supermanReceivers)

	return supermanListeners
end

function onServerSupermanSetData(dataKey, dataValue)
	if (not client) then
		return false
	end

	setSupermanData(client, dataKey, dataValue)
end
addEvent("onServerSupermanSetData", true)
addEventHandler("onServerSupermanSetData", root, onServerSupermanSetData)

function onPlayerResourceStartSyncSuperman(startedResource)
	local matchingResource = (startedResource == resource)

	if (not matchingResource) then
		return false
	end

	local supermansData = getSupermansData()

	triggerClientEvent(source, "onClientSupermanSync", source, supermansData)
	supermanReceivers[source] = true
end
addEventHandler("onPlayerResourceStart", root, onPlayerResourceStartSyncSuperman)

function onPlayerQuitClearSupermanReceiver()
	supermanReceivers[source] = nil
end
addEventHandler("onPlayerQuit", root, onPlayerQuitClearSupermanReceiver)