local isServer = (not triggerServerEvent)
local supermansData = {}

SUPERMAN_USE_ELEMENT_DATA = false -- decides whether script will use built-in MTA data system (setElementData) or custom one, shipped with superman resource

-- in general element data is bad, and shouldn't be used, hence it should be set to false, unless you want to have backwards compatibility

SUPERMAN_ALLOWED_DATA_KEYS = {
	[SUPERMAN_FLY_DATA_KEY] = true,
	[SUPERMAN_TAKE_OFF_DATA_KEY] = true,
}

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

	local dataKeyType = type(dataKey)
	local dataKeyString = (dataKeyType == "string")

	if (not dataKeyString) then
		return false
	end

	local allowedDataKey = SUPERMAN_ALLOWED_DATA_KEYS[dataKey]

	if (not allowedDataKey) then
		return false
	end

	if (SUPERMAN_USE_ELEMENT_DATA) then
		return getElementData(playerElement, dataKey)
	end

	local supermanData = supermansData[playerElement]

	if (not supermanData) then
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

	if (SUPERMAN_USE_ELEMENT_DATA) then
		local oldElementData = getElementData(playerElement, dataKey)
		local updateElementData = (oldElementData ~= dataValue)

		if (updateElementData) then
			local syncElementData = (isServer or not isServer and localPlayer == playerElement)

			return setElementData(playerElement, dataKey, dataValue, syncElementData)
		end

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

		triggerEvent(isServer and "onSupermanDataChange" or "onClientSupermanDataChange", playerElement, dataKey, oldDataValue, dataValue)

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

local function onClientServerPlayerQuitClearSupermanData()
	supermansData[source] = nil
end
if (not SUPERMAN_USE_ELEMENT_DATA) then addEventHandler(isServer and "onPlayerQuit" or "onClientPlayerQuit", root, onClientServerPlayerQuitClearSupermanData) end