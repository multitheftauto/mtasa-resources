local rootElement = getRootElement()

function runString (commandstring, outputTo, source)
	me = source
	local sourceName = source and getPlayerName(source) or "Console"

	outputChatBoxR(sourceName.." executed command: "..commandstring, outputTo, true)
	local notReturned
	--First we test with return
	local commandFunction,errorMsg = loadstring("return "..commandstring)
	if errorMsg then
		--It failed.  Lets try without "return"
		commandFunction, errorMsg = loadstring(commandstring)
	end
	if errorMsg then
		--It still failed.  Print the error message and stop the function
		outputChatBoxR("Error: "..errorMsg, outputTo)
		return
	end
	--Finally, lets execute our function
	local results = { pcall(commandFunction) }
	if not results[1] then
		--It failed.
		outputChatBoxR("Error: "..results[2], outputTo)
		return
	end

	local resultsString = ""
	local first = true
	for i = 2, #results do
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

	if #results > 1 then
		outputChatBoxR("Command results: " ..resultsString)
		return
	end

	outputChatBoxR("Command executed!")
end

-- run command
addCommandHandler("run",
	function (player, command, ...)
		local commandstring = table.concat({...}, " ")
		return runString(commandstring, rootElement, player)
	end
)

-- silent run command
addCommandHandler("srun",
	function (player, command, ...)
		local commandstring = table.concat({...}, " ")
		return runString(commandstring, player, player)
	end
)

-- clientside run command
addCommandHandler("crun",
	function (player, command, ...)
		local commandstring = table.concat({...}, " ")
		if player then
			outputChatBoxR(getPlayerName(player) .. " executed client-side command: " .. commandstring, false)
			return triggerClientEvent(player, "doCrun", rootElement, commandstring)
		else
			return runString(commandstring, false, false)
		end
	end
)

-- http interface run export
function httpRun(commandstring)
	if not user then outputDebugString ( "httpRun can only be called via http", 2 ) return end

	-- check acl permission
	local accName = getAccountName(user)
	local objectName = "user." .. accName

	if(not hasObjectPermissionTo(objectName, "command.srun", false)) then
		outputServerLog(getAccountName(user) .. " from " .. hostname .. " attempted to execute Lua code with missing acl permission (command.srun)")
		return "Error: Permission denied"
	end

	local notReturned
	--First we test with return
	local commandFunction,errorMsg = loadstring("return "..commandstring)
	if errorMsg then
		--It failed.  Lets try without "return"
		notReturned = true
		commandFunction, errorMsg = loadstring(commandstring)
	end
	if errorMsg then
		--It still failed.  Print the error message and stop the function
		return "Error: "..errorMsg
	end
	--Finally, lets execute our function
	local results = { pcall(commandFunction) }
	if not results[1] then
		--It failed.
		return "Error: "..results[2]
	end

	outputChatBoxR("[HTTP] " .. accName .. " from " .. hostname .. " executed command: " .. commandstring, false)

	if not notReturned then
		local resultsString = ""
		local first = true
		for i = 2, #results do
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
		return "Command results: "..resultsString
	end
	return "Command executed!"
end
