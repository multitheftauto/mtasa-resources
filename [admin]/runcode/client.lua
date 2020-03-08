me = localPlayer

-- Primary functionality
local function runString (commandstring)
	outputChatBoxR("Executing client-side command: "..commandstring)
	local notReturned
	--First we test with return
	local commandFunction,errorMsg = loadstring("return "..commandstring)
	if errorMsg then
		--It failed.  Lets try without "return"
		commandFunction, errorMsg = loadstring(commandstring)
	end
	if errorMsg then
		--It still failed.  Print the error message and stop the function
		outputChatBoxR("Error: "..errorMsg)
		return
	end
	--Finally, lets execute our function
	local results = { pcall(commandFunction) }
	if not results[1] then
		--It failed.
		outputChatBoxR("Error: "..results[2])
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

addEvent("doCrun", true)
addEventHandler("doCrun", root, runString)

-- Variable watching feature
local watchFuncs = {}
local watchKeys = {}
local watchFunc_G = function(k)
	return _G[k]
end

local function watchRender()
	local sw, y = guiGetScreenSize()
	for _, key in ipairs(watchKeys) do
		y = y - 20
		local text = tostring(watchFuncs[key](key))
		dxDrawText(key .. ": " .. text, sw - 200, y)
	end
end

local function watch(key, v)
	-- Error checking
	if type(v) ~= "string" and type(v) ~= "function" and type(v) ~= "nil" then
		error("Unexpected watch value of type " .. type(v) .. " for key " .. key)
		return
	end

	-- Remove if missing value
	if not v then
		watchFuncs[key] = nil

		table.remove(watchKeys, table.find(watchKeys, key))
		table.sort(watchKeys)

		-- Remove event handler if we have no keys left
		if #watchKeys == 0 then
			removeEventHandler("onClientRender", root, watchRender)
		end

		return
	end

	-- Set watchFunc as global watcher, if v is string
	if type(v) == "string" then
		watchFunc[key] = watchFunc_G
	elseif type(v) == "function" then
		watchFunc[key] = v
	else
		assert(false, "never reached")
	end

	table.insert(watchKeys, key)
	table.sort(watchKeys)

	-- Add event handler if this is our first key
	if #watchKeys == 1 then
		addEventHandler("onClientRender", root, watchRender)
	end
end

runcode = {
	me = localPlayer,
	watch = watch
}
