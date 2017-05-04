
function Player:hasIPBAccess()
    return self:hasPermissionTo(g_Settings["AccessRightName"], false)
end

function onIPBCommand(player)
    if not player:hasIPBAccess() then
        return player:outputChat("* You have no permission for this command", 255, 100, 100, true)
    end

    if isListening(player) then
        -- Ignore multiple triggers for this command
        return
    end

    player:triggerEvent("ipb.accessControl", player, true)
end
addCommandHandler("perfbrowse", onIPBCommand)
addCommandHandler("ipb", onIPBCommand)

addEventHandler("onPlayerLogout", root,
    function ()
        if isListening(source) and not source:hasIPBAccess() then
            removeListener(source)
            source:triggerEvent("ipb.accessControl", source, true)
        end
    end
)
