function debugMessage(message, consoleOnly)
	if (settings.dbg) then
		message = "SERVER debug: " .. message
		outputConsole(message)
		if (not consoleOnly) then
			--outputServerLog(message)
			outputDebugString(message)
		end
	end
end
