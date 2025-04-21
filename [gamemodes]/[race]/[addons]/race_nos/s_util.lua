
g_Root = getRootElement()
g_ResRoot = getResourceRootElement(getThisResource())

function table.size(tab)
	local size = 0
	for i,v in pairs(tab) do
		size = size + 1
	end
	return size
end

function string:split(sep)
	if #self == 0 then
		return {}
	end
	sep = sep or ' '
	local result = {}
	local from = 1
	local to
	repeat
		to = self:find(sep, from, true) or (#self + 1)
		result[#result+1] = self:sub(from, to - 1)
		from = to + 1
	until from == #self + 2
	return result
end


function toboolean(var)
	if type(var) == "string" then
		return (var == "true")
	end
	if type(var) == "number" then
		return (var == 1)
	end
	return not not var
end
