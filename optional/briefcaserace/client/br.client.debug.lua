function debugMessage(message)
	message = "CLIENT Debug: " .. message
	outputConsole(message)
	--outputServerLog(message)
	outputDebugString(message)
end
