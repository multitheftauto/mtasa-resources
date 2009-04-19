function isTimer(timer)
	return table.find(getTimers(), timer) ~= false
end


local _isPlayerDead = isPedDead
function isPedDead(player)
	return _isPlayerDead(player) or isPlayerTerminated(player)
end

function isPlayerTerminated(player)
	local x, y, z = getElementPosition(player)
	return (math.floor(x) == 132 and math.floor(y) == -68) or (math.abs(x) < 2 and math.abs(y) < 2 and z < 1)
end

function errMsg(msg, player)
	outputChatBox(msg, player or g_Root, 255, 0, 0)
end

function table.find(t, ...)
	local args = { ... }
	if #args == 0 then
		for k,v in pairs(t) do
			if v then
				return k
			end
		end
		return false
	end
	
	local value = table.remove(args)
	if value == '[nil]' then
		value = nil
	end
	for k,v in pairs(t) do
		for i,index in ipairs(args) do
			if type(index) == 'function' then
				v = index(v)
			else
				if index == '[last]' then
					index = #v
				end
				v = v[index]
			end
		end
		if v == value then
			return k
		end
	end
	return false
end

function string:split(separator)
	if separator == '.' then
		separator = '%.'
	end
	local result = {}
	for part in self:gmatch('(.-)' .. separator) do
		result[#result+1] = part
	end
	result[#result+1] = self:match('.*' .. separator .. '(.*)$') or self
	return result
end

function table.each(t, index, callback, ...)
	local args = { ... }
	if type(index) == 'function' then
		table.insert(args, 1, callback)
		callback = index
		index = false
	end
	for k,v in pairs(t) do
		callback(index and v[index] or v, unpack(args))
	end
	return t
end

function table.removevalue(t, val)
	for i,v in ipairs(t) do
		if v == val then
			table.remove(t, i)
			return i
		end
	end
	return false
end
