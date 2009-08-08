function debugMessage(message)
	if (settings.dbg) then
		message = "br.server debug: " .. message
		outputConsole(message)
		--outputServerLog(message)
		outputDebugString(message)
	end
end
