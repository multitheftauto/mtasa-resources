local function runString (commandstring)
	outputChatBoxR("Executing client-side command: "..commandstring)
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
		outputChatBoxR("Command results: "..resultsString)
	else
		outputChatBoxR("Error: "..results[2])
	end
end

addEvent("doCrun", true)
addEventHandler("doCrun", getRootElement(), runString)