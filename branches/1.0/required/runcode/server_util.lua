local rootElement = getRootElement()

function outputConsoleR(message, toElement)
	if toElement == false then
		outputServerLog(message)
	else
		toElement = toElement or rootElement
		outputConsole(message, toElement)
		if toElement == rootElement then
			outputServerLog(message)
		end
	end
end

function outputChatBoxR(message, toElement, forceLog)
	if toElement == false then
		outputServerLog(message)
	else
		toElement = toElement or rootElement
		outputChatBox(message, toElement, 250, 200, 200)
		if toElement == rootElement or forceLog then
			outputServerLog(message)
		end
	end
end

-- dump the element tree
function map(element, outputTo, level)
	level = level or 0
	element = element or getRootElement()
	local indent = string.rep('  ', level)
	local eType = getElementType(element)
	local eID = getElementID(element)
	local eChildren = getElementChildren(element)
	
	local tagStart = '<'..eType
	if eID then
		tagStart = tagStart..' id="'..eID..'"'
	end
	for dataField, dataValue in pairs(getAllElementData(element)) do
		tagStart = tagStart..' '..dataField..'="'..tostring(dataValue)..'"'
	end
	
	if #eChildren < 1 then
		outputConsoleR(indent..tagStart..'"/>', outputTo)
	else
		outputConsoleR(indent..tagStart..'">', outputTo)
		for k, child in ipairs(eChildren) do
			map(child, outputTo, level+1)
		end
		outputConsoleR(indent..'</'..eType..'>', outputTo)
	end
end