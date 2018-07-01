local rootElement = getRootElement()

function showHelp(element)
	return triggerClientEvent(element, "doShowHelp", rootElement)
end

function hideHelp(element)
	return triggerClientEvent(element, "doHideHelp", rootElement)
end
