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
