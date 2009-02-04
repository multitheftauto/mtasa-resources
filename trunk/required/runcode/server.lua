local rootElement = getRootElement()

function runString (commandstring, outputTo, source)
	local sourceName
	if source then
		sourceName = getPlayerName(source)
	else
		sourceName = "Console"
	end
	outputChatBoxR(sourceName.." executed command: "..commandstring, outputTo)
	local results = npack(pcall(assert(loadstring(commandstring))))
	if results[1] == true then
		local resultsString = ""
		local first = true
		for i = 2, results._n do
			if first then
				first = false
			else
				resultsString = resultsString..", "
			end
			local resultType = type(results[i])
			if isElement(results[i]) then
				resultType = "element:"..getElementType(results[i])
			end
			resultsString = resultsString..tostring(results[i]).." ["..resultType.."]"
		end
		outputChatBoxR("Command results: "..resultsString, outputTo)
	else
		outputChatBoxR("Error: "..results[2], outputTo)
	end
end

-- run command
addCommandHandler("run",
	function (player, command, ...)
		local commandstring = "return "..table.concat({...}, " ")
		return runString(commandstring, rootElement, player)
	end
)

-- silent run command
addCommandHandler("srun",
	function (player, command, ...)
		local commandstring = "return "..table.concat({...}, " ")
		return runString(commandstring, player, player)
	end
)

-- clientside run command
addCommandHandler("crun",
	function (player, command, ...)
		local commandstring = "return "..table.concat({...}, " ")
		if player then
			return triggerClientEvent(player, "doCrun", rootElement, commandstring)
		else
			return runString(commandstring, false, false)
		end
	end
)

-- http interface run export
function httpRun(commandstring)
	return pcall(loadstring(commandstring))
end