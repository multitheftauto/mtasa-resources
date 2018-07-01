function isPlayerAllowedToDoEditorAction(player,action)
	if isElement(player) and getElementType(player)=="player" and action and type(action)=="string" then
--		return hasObjectPermissionTo(player,"resource.editor."..action,false)
		return hasObjectPermissionTo(player,"resource.editor."..action)
	end

	return false
end

function table.subtract(t1, t2)
	local find, remove = table.find, table.remove
	for i=#t1,1,-1 do
		if find(t2, t1[i]) then
			remove(t1, i)
		end
	end
	return t1
end

function table.deepcopy(t)
	local known = {}
	local function _deepcopy(t)
		local result = {}
		for k,v in pairs(t) do
			if type(v) == 'table' then
				if not known[v] then
					known[v] = _deepcopy(v)
				end
				result[k] = known[v]
			else
				result[k] = v
			end
		end
		return result
	end
	return _deepcopy(t)
end

function table.each(t, callback, ...)
	for k,v in pairs(t) do
		callback(v, ...)
	end
	return t
end

function table.find(t, ...)
	local args = { ... }
	if #args == 0 then
		for k,v in pairs(t) do
			if v then
				return k, v
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
			return k, t[k]
		end
	end
	return false
end

function table.filter(t, callback, cmpval)
	if cmpval == nil then
		cmpval = true
	end
	local k, v
	local remove = table.remove
	while true do
		k, v = next(t, k)
		if not k then
			break
		end
		if callback(v) ~= cmpval then
			remove(t, k)
		end
	end
	return t
end

function table.map(t, callback, ...)
	for k,v in ipairs(t) do
		t[k] = callback(v, ...)
	end
	return t
end

function table.shallowcopy(t)
	local result = {}
	for k,v in pairs(t) do
		result[k] = v
	end
	return result
end


--------------------------------------------------------------------------------
-- Coroutines
--------------------------------------------------------------------------------
-- Make sure errors inside coroutines get printed somewhere
_coroutine_resume = coroutine.resume
function coroutine.resume(...)
	local state,result = _coroutine_resume(...)
	if not state then
		outputDebugString( tostring(result), 1 )	-- Output error message
	end
	return state,result
end
