local COMMAND_HANDLERS = {}

function createCommandHandlerContainerForResource(resource)
	COMMAND_HANDLERS[resource] = {}
end

function createAddCommandHandlerFunctionForResource(resource)
	return (function(commandName,handlerFunction,restricted,caseSensitive)
			if type(commandName) == "string" and type(handlerFunction) == "function" then
				local args

				if isClient() then
					if type(restricted) == "boolean" then
						caseSensitive = restricted
					else
						caseSensitive = true
					end

					args = {commandName, handlerFunction, caseSensitive}
				else
					if type(restricted) ~= "boolean" then
						restricted = false
					end

					if type(caseSensitive) ~= "boolean" then
						caseSensitive = true
					end

					args = {commandName, handlerFunction, restricted, caseSensitive}
				end

				if addCommandHandler(unpack(args)) then
					table.insert(COMMAND_HANDLERS[resource],args)
					return true
				end
			end

			return false
		end)
end

function createRemoveCommandHandlerFunctionForResource(resource)
	return (function(commandName,handlerFunction)
			local success = false

			if type(commandName)=="string" and type(handlerFunction) == "function" then
				for index,commandData in ipairs(COMMAND_HANDLERS[resource]) do
					if commandData[1] == commandName and (not commandData[2] or commandData[2] == handlerFunction) then
						if removeCommandHandler(unpack(commandData)) then
							table.remove(COMMAND_HANDLERS[resource],index)
							success = true
						end
					end
				end
			end

			return success
		end)
end

function cleanCommandHandlerContainerForResource(resource)
	for index,commandData in ipairs(COMMAND_HANDLERS[resource]) do
		removeCommandHandler(unpack(commandData))
	end

	COMMAND_HANDLERS[resource] = nil
end
