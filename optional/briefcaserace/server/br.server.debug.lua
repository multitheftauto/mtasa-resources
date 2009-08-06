function debugMessage(message)
	message = "SERVER Debug: " .. message
	outputConsole(message)
	--outputServerLog(message)
	outputDebugString(message)
end
