-- #######################################
-- ## Project: Glue						##
-- ## Author: MTA contributors			##
-- ## Version: 1.3.1					##
-- #######################################

function typeCheck(pData, ...)
	local dataType = type(pData)

	if (not ...) then
		return dataType
	end

	local dataTypes = {...}

	for typeID = 1, #dataTypes do
		local allowedType = dataTypes[typeID]
		local matchingType = (dataType == allowedType)

		if (matchingType) then
			return true
		end
	end

	return false, dataType
end

function isElementType(pElement, ...)
	local validElement = isElement(pElement)

	if (not validElement) then
		return false
	end

	local elementType = getElementType(pElement)
	local elementsType = typeCheck(...)
	local elementTable = (elementsType == "table")
	local elementTypes = (elementTable and ... or {...})

	for elementTypeID = 1, #elementTypes do
		local allowedElementType = elementTypes[elementTypeID]
		local matchingElementType = (elementType == allowedElementType)

		if (matchingElementType) then
			return true, elementType
		end
	end

	return false, elementType
end

function findInTable(luaTable, searchFor)
	for dataID = 1, #luaTable do
		local tableData = luaTable[dataID]
		local tableDataMatching = (tableData == searchFor)

		if (tableDataMatching) then
			return true
		end
	end

	return false
end

function sendGlueMessage(glueMessage, glueMessageReceiver, glueMessagePrefix)
	local glueMessageHasText = (glueMessage and glueMessage ~= "")

	if (not glueMessageHasText) then
		return false
	end

	local glueMessageFormatted = GLUE_MESSAGE_PREFIX_COLOR..(glueMessagePrefix or GLUE_MESSAGE_PREFIX).." #ffffff"..glueMessage

	if (IS_SERVER) then
		outputChatBox(glueMessageFormatted, glueMessageReceiver, 255, 255, 255, true)

		return true
	end

	outputChatBox(glueMessageFormatted, 255, 255, 255, true)

	return true
end