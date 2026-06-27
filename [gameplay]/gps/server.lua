local allowedRPC = {
	calculatePathByCoords = true,
	calculatePathByNodeIDs = true,
	spawnPlayer = true
}

addEvent('onServerCall', true)
addEventHandler('onServerCall', root,
	function(fnName, ...)
		if allowedRPC[fnName] then
			_G[fnName](...)
		end
	end
)

addEvent('onServerCallback', true)
addEventHandler('onServerCallback', root,
	function(crID, fnName, ...)
		if allowedRPC[fnName] then
			triggerClientEvent(source, 'onServerCallbackReply', resourceRoot, crID, _G[fnName](...))
		end
	end
)

local function sendSettingsToClient(player)
	local target = player or root
    local mode = get("routeMode") or "client"
    triggerClientEvent(target, "onClientReceiveGPSSetting", resourceRoot, mode)
end

addEventHandler("onResourceStart", resourceRoot, function()
    sendSettingsToClient()
end)

addEventHandler("onPlayerJoin", root, function()
    sendSettingsToClient(source)
end)
