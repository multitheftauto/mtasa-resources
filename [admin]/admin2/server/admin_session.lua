--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_session.lua
*
*	Original File by lil_Toady
*
**************************************]]
local aSessions = {}

addCommandHandler(
    "adminpanel",
    function(player)
        if (hasObjectPermissionTo(player, "general.adminpanel")) then
            triggerClientEvent(player, "aClientAdminMenu", root)
            aPlayers[player]["chat"] = true
        end
    end
)

addEventHandler(
    "onPlayerLogin",
    root,
    function(previous, account, auto)
        if (hasObjectPermissionTo(source, "general.adminpanel")) then
            if (aPlayers[source]["aLoaded"]) then
                triggerEvent(EVENT_SESSION, source, SESSION_UPDATE)
            end
        end
    end
)

addEvent(EVENT_SESSION, true)
addEventHandler(
    EVENT_SESSION,
    root,
    function(type)
        if (type == SESSION_START) then
            if (aPlayers[client]) then
                aPlayers[client]["aLoaded"] = true
            end
        end
        if (type == SESSION_UPDATE or type == SESSION_START) then
            if (hasObjectPermissionTo(client, "general.adminpanel")) then
                local tableOut = {}
                local account = "user." .. getAccountName(getPlayerAccount(client))
                for gi, group in ipairs(aclGroupList()) do
                    for oi, object in ipairs(aclGroupListObjects(group)) do
                        if ((object == account) or (object == "user.*")) then
                            for ai, acl in ipairs(aclGroupListACL(group)) do
                                local rights = table.iadd(aclListRights(acl, "command"), aclListRights(acl, "general"))
                                for ri, right in ipairs(rights) do
                                    local access = aclGetRight(acl, right)
                                    if (access) then
                                        tableOut[right] = true
                                    end
                                end
                            end
                            break
                        end
                    end
                end
                triggerClientEvent(client, EVENT_SESSION, client, tableOut)
            end
        end
    end
)
