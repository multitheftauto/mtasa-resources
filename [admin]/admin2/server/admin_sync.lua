--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_sync.lua
*
*	Original File by lil_Toady
*
**************************************]]

local function hasClientPermissionTo(strRight)
    if client and not hasObjectPermissionTo(client, strRight) then
        outputServerLog( ( "[ADMIN SECURITY]: Player %s [%s %s] attempted to perform admin data sync without proper rights (%s)" ):format( client.name, client.ip, client.serial, strRight ) )
        return false
    end
    return true
end

addEvent(EVENT_SYNC, true)
addEventHandler(
    EVENT_SYNC,
    root,
    function(type, data)

        if not hasClientPermissionTo("general.adminpanel") then
            return
        end

        local tableOut = {}
        local theSource = root

        if (type == SYNC_PLAYER) then

            if (not isElement(data)) then
                return
            end

            if not hasClientPermissionTo( "general.tab_players" ) then
                return
            end

            aPlayers[client]["sync"] = data
            tableOut["mute"] = isPlayerMuted(data)
            tableOut["freeze"] = isElementFrozen(data)
            tableOut["money"] = getPlayerMoney(data)
            tableOut["version"] = getPlayerVersion(data)
            local account = getPlayerAccount(data)
            tableOut["account"] = getAccountName(account)
            if (not isGuestAccount(account)) then
                local groups = aclGetAccountGroups(account)
                if (#groups > 0) then
                    tableOut["groups"] = table.concat(table.reverse(groups), ", ")
                end
            end
            tableOut["account"] = getAccountName(account)
            theSource = data

        elseif (type == SYNC_PLAYERS) then
            for id, player in ipairs(getElementsByType("player")) do
                tableOut[player] = {}
                tableOut[player].ip = getPlayerIP(player)
                tableOut[player].account = getAccountName(getPlayerAccount(player))
                tableOut[player].serial = getPlayerSerial(player)
                tableOut[player].country = aPlayers[player]["country"]
                tableOut[player].countryname = aPlayers[player]["countryname"]
            end

        elseif (type == SYNC_PLAYERACL) then
            -- Not called by client-side
            if client then
                return
            end

            local player = data
            if isElement(player) then
                theSource = player
                local ignoredGroups = {
                    ['Everyone'] = true,
                    ['autoGroup_irc'] = true,
                }
                for _, v in ipairs(aclGroupList()) do
                    local groupName = aclGroupGetName(v)
                    if (not ignoredGroups[groupName]) then
                        tableOut[groupName] = isObjectInACLGroup('user.'..getAccountName(getPlayerAccount(player)), v)
                    end
                end
            end

        elseif (type == SYNC_RESOURCES) then
            if not hasClientPermissionTo("command.listresources") then
                return
            end

            tableOut = {}
            local resourceTable = getResources()
            for id, resource in ipairs(resourceTable) do
                local name = getResourceName(resource)
                local state = getResourceState(resource)
                local group = getResourceInfo(resource, "type") or "misc"
                if (not tableOut[group]) then
                    tableOut[group] = {}
                end
                table.insert(tableOut[group], {name = name, state = state})
            end

        elseif (type == SYNC_RESOURCE) then
            if not hasClientPermissionTo("command.listresources") then
                return
            end

            local resource = getResourceFromName(data)
            tableOut.name = data
            tableOut.info = {}
            if (resource) then
                tableOut.info.name = getResourceInfo(resource, "name") or nil
                tableOut.info.type = getResourceInfo(resource, "type") or nil
                tableOut.info.author = getResourceInfo(resource, "author") or nil
                tableOut.info.version = getResourceInfo(resource, "version") or nil
                tableOut.info.description = getResourceInfo(resource, "description") or nil
                tableOut.info.settings = getResourceSettings(data, false)
            end

        elseif (type == SYNC_ADMINS) then
            if not hasClientPermissionTo("general.tab_adminchat") then
                return
            end

            for id, player in ipairs(aPlayers) do
                tableOut[player] = {}
                tableOut[player]["admin"] = hasObjectPermissionTo(player, "general.adminpanel")
                if (tableOut[player]["admin"]) then
                    tableOut[player]["chat"] = aPlayers[player]["chat"]
                end
                tableOut[player]["groups"] = "None"
                local account = getPlayerAccount(player)
                if (isGuestAccount(account)) then
                    tableOut[player]["groups"] = "Not logged in"
                else
                    local groups = aclGetAccountGroups(account)
                    if (#groups <= 0) then
                        tableOut[player]["groups"] = "None"
                    else
                        tableOut[player]["groups"] = unpack(groups)
                    end
                end
            end

        elseif (type == SYNC_SERVER) then
            if not hasClientPermissionTo("general.tab_server") then
                return
            end

            tableOut["name"] = getServerName()
            tableOut["players"] = getMaxPlayers()
            tableOut["game"] = getGameType()
            tableOut["map"] = getMapName()
            tableOut["password"] = getServerPassword()

        elseif (type == SYNC_BAN) then
            if client then
                return
            end
            tableOut = data

        elseif (type == SYNC_BANS) then
            if not hasClientPermissionTo("general.tab_bans") then
                return
            end

            for id, ban in pairs(getBansList()) do
                tableOut[id] = getBanData(ban)
            end

        elseif (type == SYNC_MESSAGES) then
            if not hasClientPermissionTo( "command.listmessages" ) then
                return
            end

            local unread, total = 0, 0
            for id, msg in ipairs(aReports) do
                if (not msg.read) then
                    unread = unread + 1
                end
                total = total + 1
            end
            tableOut["unread"] = unread
            tableOut["total"] = total
        end
        triggerClientEvent(client or source, EVENT_SYNC, theSource, type, tableOut)
    end
)

function requestSync(player, type, data)
    triggerEvent(EVENT_SYNC, player, type, data)
end

addEvent("onPlayerFrozen", false)
addEvent("onPlayerMoneyChange", false)
addEventHandler(
    "onResourceStart",
    resourceRoot,
    function()
        setTimer(
            function()
                for player, data in pairs(aPlayers) do
                    local prev

                    local money = getPlayerMoney(player)
                    prev = data.money or 0
                    if (money ~= prev) then
                        triggerEvent("onPlayerMoneyChange", player, prev, money)
                        aPlayers[player].money = money
                    end

                    local frozen = isElementFrozen(player)
                    prev = data.frozen or false
                    if (frozen ~= prev) then
                        triggerEvent("onPlayerFrozen", player, frozen)
                        aPlayers[player].frozen = frozen
                    end

                    local muted = isPlayerMuted(player)
                    prev = data.muted or false
                    if (muted ~= prev) then
                        aPlayers[player].muted = muted
                    end
                end
            end,
            1500,
            0
        )
    end
)

addEventHandler(
    "onPlayerMoneyChange",
    root,
    function(prev, new)
        for player, data in pairs(aPlayers) do
            if (data.sync == source) then
                triggerClientEvent(player, EVENT_SYNC, source, SYNC_PLAYER, {["money"] = new})
            end
        end
    end
)

addEventHandler(
    "onPlayerFrozen",
    root,
    function(state)
        for player, data in pairs(aPlayers) do
            if (data.sync == source) then
                triggerClientEvent(player, EVENT_SYNC, source, SYNC_PLAYER, {["freeze"] = state})
            end
        end
    end
)

addEventHandler(
    "onPlayerMute",
    root,
    function()
        for player, data in pairs(aPlayers) do
            if (data.sync == source) then
                triggerClientEvent(player, EVENT_SYNC, source, SYNC_PLAYER, {["mute"] = true})
            end
        end
    end
)

addEventHandler(
    "onPlayerUnmute",
    root,
    function()
        for player, data in pairs(aPlayers) do
            if (data.sync == source) then
                triggerClientEvent(player, EVENT_SYNC, source, SYNC_PLAYER, {["mute"] = false})
            end
        end
    end
)
