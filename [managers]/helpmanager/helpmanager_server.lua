
function showHelp(element)
	return triggerClientEvent(element, "doShowHelp", root)
end

function hideHelp(element)
	return triggerClientEvent(element, "doHideHelp", root)
end
