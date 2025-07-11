local EVENT_HANDLERS = {}

function createEventHandlerContainerForResource(resource)
	EVENT_HANDLERS[resource] = {}
end

function createAddEventHandlerFunctionForResource(resource)
	return (function(eventName,attachedTo,handlerFunction,getPropagated)
			if type(eventName)=="string" and isElement(attachedTo) and type(handlerFunction) == "function" then
				if getPropagated == nil or type(getPropagated) ~= "boolean" then
					getPropagated = true
				end

				if addEventHandler(eventName,attachedTo,handlerFunction,getPropagated) then
					table.insert(EVENT_HANDLERS[resource],{eventName,attachedTo,handlerFunction})
					return true
				end
			end

			return false
		end)
end

function createRemoveEventHandlerFunctionForResource(resource)
	return (function(eventName,attachedTo,handlerFunction)
			if type(eventName)=="string" and isElement(attachedTo) and type(handlerFunction) == "function" then
				for index,eventData in ipairs(EVENT_HANDLERS[resource]) do
					if eventData[1] == eventName and eventData[2] == attachedTo and eventData[3] == handlerFunction then
						if removeEventHandler(unpack(eventData)) then
							table.remove(EVENT_HANDLERS[resource],index)
							return true
						end
					end
				end
			end

			return false
		end)
end

function cleanEventHandlerContainerForResource(resource)
	for index,eventData in ipairs(EVENT_HANDLERS[resource]) do
		if isElement(eventData[2]) then
			removeEventHandler(unpack(eventData))
		end
	end

	EVENT_HANDLERS[resource] = nil
end
