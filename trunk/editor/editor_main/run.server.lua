local rR, rG, rB = 100, 100, 250
local rootElement = getRootElement()

local function npack(...)
   return {_n=select('#',...);...}
end

local function srun (commandstring)
	return pcall(loadstring(commandstring))
end

local function run (commandstring)
	outputChatBox("Executing command:" .. commandstring, rootElement, rR, rG, rB)
	local results = npack( srun(commandstring) )
	if results[1] == true then
		local resultsString = ""
		local first = true
		for i=2, results._n do
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
		outputChatBox("Command executed! Results: " .. resultsString, rootElement, rR, rG, rB)
	else
		outputChatBox("Error executing command: " .. results[2], rootElement, rR, rG, rB)
	end
end

addCommandHandler("runm",
	function (player, command, ...)
		run("return " .. table.concat({...}," "))
	end
)

addCommandHandler("srunm",
	function (player, command, ...)
		srun("return " .. table.concat({...}," "))
	end
)

function httpRun(commandstring)
	return srun("return " .. commandstring)
end

--Tree map utility function--
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

function dumpupgrades()
	local XML = xmlCreateFile("upgrades.xml", "upgrades")
	local contents = "\n"
	local cachedtables = {}
	for ID=400,611 do
		local v = createVehicle(ID,0,0,3)
		if v then
			contents = contents .. "compatibleUpgrades["..ID.."]={}\n"
			for slot=0,16 do
				local upgradetable = getVehicleCompatibleUpgrades(v,slot)
				if #upgradetable > 0 then
					local tableid = table.concat(upgradetable,',')
					if cachedtables[tableid] then
						contents = contents.."\tcompatibleUpgrades["..ID.."]["..slot.."]=compatibleUpgrades["..cachedtables[tableid][1].."]["..cachedtables[tableid][2].."]\n"
					else
						cachedtables[tableid] = {ID,slot}
						contents = contents.."\tcompatibleUpgrades["..ID.."]["..slot.."]={"..tableid.."}\n"
					end
				end
				contents = contents.."\n"
			end
			destroyElement(v)
		end
	end
	xmlNodeSetValue(XML, contents)
	local result = xmlSaveFile(XML)
	xmlUnloadFile(XML)
	return result
end

--#2533--
function testLuaFunctionToJS()
	return function() print("test") end
end

function testLuaCoroutineToJS()
	return {coroutine.create(function() print("hi") end)}
end

function testTimerToJS()
	return setTimer(outputChatBox, 10000, 1, "timer ended")
end