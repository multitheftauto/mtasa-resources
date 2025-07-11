local KEY_BINDS = {}

function createKeyBindContainerForResource(resource)
	KEY_BINDS[resource] = {}
end

function createBindKeyFunctionForResource(resource)
	return (function(...)
			local args = {...}

			if isClient() then
				local key             = table.remove(args,1)
				local keyState        = table.remove(args,1)
				local handlerFunction = table.remove(args,1)
				local arguments       = args

				if type(key) ~= "string" or type(keyState) ~= "string" or (type(handlerFunction) ~= "string" and type(handlerFunction) ~= "function") then
					return false
				end

				args = {key, keyState, handlerFunction, unpack(arguments)}
			else
				local thePlayer       = table.remove(args,1)
				local key             = table.remove(args,1)
				local keyState        = table.remove(args,1)
				local handlerFunction = table.remove(args,1)
				local arguments       = args

				if not isElement(thePlayer) or getElementType(thePlayer) ~= "player" or type(key) ~= "string" or type(keyState) ~= "string" or (type(handlerFunction) ~= "string" and type(handlerFunction) ~= "function") then
					return false
				end

				args = {thePlayer, key, keyState, handlerFunction, unpack(arguments)}
			end

			if bindKey(unpack(args)) then
				table.insert(KEY_BINDS[resource],args)
				return true
			end

			return false
		end)
end

function createUnbindKeyFunctionForResource(resource)
	return (function(...)
			local args = {...}

			local isClient = isClient()

			if isClient then
				local key             = table.remove(args,1)
				local keyState        = table.remove(args,1)
				local handlerFunction = table.remove(args,1)

				if type(key) ~= "string" then
					return false
				end

				keyState        = type(keyState) == "string" and keyState or nil
				handlerFunction = (type(handlerFunction) == "string" or type(handlerFunction) == "function") and handlerFunction or nil

				args = {key, keyState, handlerFunction}
			else
				local thePlayer       = table.remove(args,1)
				local key             = table.remove(args,1)
				local keyState        = table.remove(args,1)
				local handlerFunction = table.remove(args,1)

				if not isElement(thePlayer) or getElementType(thePlayer) ~= "player" or type(key) ~= "string" then
					return false
				end

				keyState        = type(keyState) == "string" and keyState or nil
				handlerFunction = (type(handlerFunction) == "string" or type(handlerFunction) == "function") and handlerFunction or nil

				args = {thePlayer, key, keyState, handlerFunction}
			end

			local success = false

			for index,keyData in ipairs(KEY_BINDS[resource]) do
				if (isClient and keyData[1] == args[1] and (not args[2] or args[2] == keyData[2]) and (not args[3] or args[3] == keyData[3]))
				or (not isClient and keyData[1] == args[1] and keyData[2] == args[2] and (not args[3] or args[3] == keyData[3]) and (not args[4] or args[4] == keyData[4]))
				then
					if unbindKey(unpack(keyData)) then
						table.remove(KEY_BINDS[resource],index)
						success = true
					end
				end
			end

			return success
		end)
end

function cleanKeyBindContainerForResource(resource)
	for index,keyData in ipairs(KEY_BINDS[resource]) do
		unbindKey(unpack(keyData))
	end

	KEY_BINDS[resource] = nil
end
