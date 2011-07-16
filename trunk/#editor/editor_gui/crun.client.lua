local rR, rG, rB = 100, 250, 100

local function npack(...)
   return {_n=select('#',...);...}
end

local function crun(commandstring)
	outputChatBox("Executing client command:" .. commandstring, rR, rG, rB)
	local results = npack( assert(loadstring(commandstring))() )
	local resultsString = ""
	local first = true
	for i=1, results._n do
		local result = results[i]
		if first then
			first = false
		else
			resultsString = resultsString..", "
		end
		local resultType = type(result)
		if resultType == "userdata" and isElement(result) then
			resultType = "element:"..getElementType(result)
		end
		resultsString = resultsString..tostring(result).." ["..resultType.."]"
	end
	outputChatBox("Command executed! Results: " ..resultsString, rR, rG, rB)
	return unpack(results)
end

addCommandHandler("crung",
	function (command, ...)
		crun("return "..table.concat({...}, " "))
	end
)

function map(element, level)
	level = level or 0
	element = element or getRootElement()
	local indent = string.rep('  ', level)
	local eType = getElementType(element)
	local eID = getElementID(element) or ""
	local eChildren = getElementChildren(element)
	if #eChildren < 1 then
		outputConsole(indent..'<'..eType..' id="'..eID..'"/>')
	else
		outputConsole(indent..'<'..eType..' id="'..eID..'">')
		for k, child in ipairs(eChildren) do map(child, level+1) end
		outputConsole(indent..'</'..eType..'>')
	end
end