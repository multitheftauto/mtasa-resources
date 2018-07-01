local interface_mt = {
	__index = function(t, k)
		t[k] = function(...) return call(t.res, k, ...) end
		return t[k]
	end
}

function createResourceCallInterface(resourceName)
	local res = getResourceFromName(resourceName)
	if res then
		_G[resourceName] = setmetatable({ res = res }, interface_mt)
	end
end
