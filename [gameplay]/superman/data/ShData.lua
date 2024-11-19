-- #######################################
-- ## Project: Superman					##
-- ## Authors: MTA contributors			##
-- ## Version: 3.0						##
-- #######################################

local isServer = (not triggerServerEvent)
local supermansData = {}

function getSupermanData(playerElement, dataKey)
	local validElement = isElement(playerElement)

	if (not validElement) then
		return false
	end

	local elementType = getElementType(playerElement)
	local playerType = (elementType == "player")

	if (not playerType) then
		return false
	end

	local supermanData = supermansData[playerElement]

	if (not supermanData) then
		return false
	end

	local dataKeyType = type(dataKey)
	local dataKeyString = (dataKeyType == "string")

	if (not dataKeyString) then
		return false
	end

	local allowedDataKey = SUPERMAN_ALLOWED_DATA_KEYS[dataKey]

	if (not allowedDataKey) then
		return false
	end

	local playerSupermanData = supermanData[dataKey]

	return playerSupermanData
end

function setSupermanData(playerElement, dataKey, dataValue)
	local validElement = isElement(playerElement)

	if (not validElement) then
		return false
	end

	local elementType = getElementType(playerElement)
	local playerType = (elementType == "player")

	if (not playerType) then
		return false
	end

	local dataKeyType = type(dataKey)
	local dataKeyString = (dataKeyType == "string")

	if (not dataKeyString) then
		return false
	end

	local allowedDataKey = SUPERMAN_ALLOWED_DATA_KEYS[dataKey]

	if (not allowedDataKey) then
		return false
	end

	local dataValueType = type(dataValue)
	local dataValueBool = (dataValueType == "boolean")

	if (not dataValueBool) then
		return false
	end

	local supermanData = supermansData[playerElement]

	if (not supermanData) then
		supermansData[playerElement] = {}
		supermanData = supermansData[playerElement]
	end

	local oldDataValue = supermanData[dataKey]
	local updateDataValue = (oldDataValue ~= dataValue)

	if (not updateDataValue) then
		return false
	end

	supermanData[dataKey] = dataValue

	if (isServer) then
		local supermanListeners = getSupermanReceivers()

		triggerClientEvent(supermanListeners, "onClientSupermanSetData", playerElement, dataKey, dataValue)
	else
		local syncToServer = (playerElement == localPlayer)

		triggerEvent("onClientSupermanDataChange", playerElement, dataKey, oldDataValue, dataValue)

		if (syncToServer) then
			triggerServerEvent("onServerSupermanSetData", localPlayer, dataKey, dataValue)
		end
	end

	return true
end

function getSupermansData()
	return supermansData
end

function syncSupermansData(supermansServerData)
	supermansData = supermansServerData
end

function onClientServerPlayerQuitClearSupermanData()
	supermansData[source] = nil
end
addEventHandler(isServer and "onPlayerQuit" or "onClientPlayerQuit", root, onClientServerPlayerQuitClearSupermanData)