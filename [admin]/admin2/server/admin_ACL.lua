--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_acl.lua
*
*	Original File by lil_Toady
*
**************************************]]
function aSetupACL()
    outputDebugString("Verifying ACL...")

    local temp = {}
    local node = xmlLoadFile("conf\\ACL.xml")

    if (not node) then
        outputDebugString("Vanila ACL not found! Please reinstall the admin resource")
        return false
    end

    local acls = 0
    local aclNode = xmlFindChild(node, "acl", acls)
    while (aclNode) do
        local aclName = xmlNodeGetAttribute(aclNode, "name")

        if (aclName) then
            local list = {}
            local rights = 0
            local rightNode = xmlFindChild(aclNode, "right", rights)
            while (rightNode) do
                local rightName = xmlNodeGetAttribute(rightNode, "name")
                local rightAccess = xmlNodeGetAttribute(rightNode, "access") == "true"
                if (rightName) then
                    list[rightName] = rightAccess
                end
                rights = rights + 1
                rightNode = xmlFindChild(aclNode, "right", rights)
            end
            temp[aclName] = list
        end

        acls = acls + 1
        aclNode = xmlFindChild(node, "acl", acls)
    end

    local new = false
    local admins = false
    for i, acl in ipairs(aclList()) do
        local updated = 0

        local list = {}
        for j, right in ipairs(aclListRights(acl)) do
            list[right] = aclGetRight(acl, right)
        end

        local check = temp[aclGetName(acl)] or temp["Default"]
        if string.sub(aclGetName(acl), 1, 8) ~= "autoACL_" then
            for right, access in pairs(check) do
                if (list[right] == nil) then
                    aclSetRight(acl, right, access)
                    updated = updated + 1
                end
            end
        end

        if (not admins) then
            admins = aclGetRight(acl, "general.adminpanel")
        end

        if (updated > 0) then
            new = true
            outputDebugString("Updated " .. updated .. " entries in ACL '" .. aclGetName(acl) .. "'")
        end
    end

    if (not admins) then
        outputDebugString("No ACL groups are able to use admin panel")
    elseif (not new) then
        outputDebugString("No ACL changes required")
    end

    return true
end

addEventHandler(
    "onDebugMessage",
    root,
    function(message, level, file, line)
        if ((level == 2) and (string.match(message, "Access denied @ '%w+'"))) then
            local func = string.sub(string.match(message, "'%w+'"), 2, -2)
        -- make request here
        end
    end
)

function aclGetAccountGroups(account, ignoreall)
    local acc = getAccountName(account)
    if (not acc) then
        return false
    end
    local res = {}
    acc = "user." .. acc
    local all = "user.*"
    for ig, group in ipairs(aclGroupList()) do
        for io, object in ipairs(aclGroupListObjects(group)) do
            if ((acc == object) or ((not ignoreall) and (all == object))) then
                table.insert(res, aclGroupGetName(group))
                break
            end
        end
    end
    return res
end

function getResourceSettings(resName, bCountOnly)
    local allowedAccess = {["*"] = true, ["#"] = true, ["@"] = true}
    local allowedTypes = {["boolean"] = true, ["number"] = true, ["string"] = true, ["table"] = true}
    local count = 0

    local rawsettings = get(resName .. ".")
    if (not rawsettings) then
        return {}, count
    end
    local settings = {}

    for rawname, value in pairs(rawsettings) do
        if (allowedTypes[type(value)]) then
            if allowedAccess[string.sub(rawname, 1, 1)] then
                count = count + 1
                local temp = string.gsub(rawname, "[%*%#%@](.*)", "%1")
                local name = string.gsub(temp, resName .. "%.(.*)", "%1")
                local bIsDefault = (temp == name)
                if (not settings[name]) then
                    settings[name] = {}
                end
                if bIsDefault then
                    settings[name].default = value
                else
                    settings[name].current = value
                end
            end
        end
    end

    if (bCountOnly) then
        return {}, count
    end

    local tableOut = {}
    for name, value in pairs(settings) do
        if (value.default) then
            tableOut[name] = {}
            tableOut[name].default = value.default
            tableOut[name].current = value.current
            if value.current == nil then
                tableOut[name].current = value.default
            end
            tableOut[name].friendlyname = get(resName .. "." .. name .. ".friendlyname")
            tableOut[name].group = get(resName .. "." .. name .. ".group")
            tableOut[name].accept = get(resName .. "." .. name .. ".accept")
            tableOut[name].examples = get(resName .. "." .. name .. ".examples")
            tableOut[name].desc = get(resName .. "." .. name .. ".desc")
        end
    end
    return tableOut, count
end

local aACLFunctions = {
    [ACL_GROUPS] = function(action, name)
        if (action == ACL_ADD) then
            if (name and type(name) == "string") then
                if (aclCreateGroup(name)) then
                    messageBox(client, "Successfully create group '" .. name .. "'", MB_INFO)
                else
                    messageBox(client, "Failed to create group '" .. name .. "'", MB_INFO)
                end
            end
            messageBox(client, "Invalid group name", MB_INFO)
        elseif (action == ACL_REMOVE) then
            if (name and type(name) == "string") then
                if (aclDestroyGroup(name)) then
                    messageBox(client, "Successfully removed group '" .. name .. "'", MB_INFO)
                else
                    messageBox(client, "Failed to removed group '" .. name .. "'", MB_INFO)
                end
            end
            messageBox(client, "Invalid group name", MB_INFO)
        end
        local data = {}
        for id, group in ipairs(aclGroupList()) do
            table.insert(data, aclGroupGetName(group))
        end
        triggerClientEvent(client, EVENT_ACL, client, ACL_GROUPS, data)
    end,
    [ACL_USERS] = function()
    end,
    [ACL_RESOURCES] = function()
    end,
    [ACL_ACL] = function(action, group)
        if (action == ACL_ADD) then
        elseif (action == ACL_REMOVE) then
        end
        local data = {}
        for id, acl in ipairs(aclGroupListACL(aclGetGroup(group))) do
            local storage = {}
            for i, right in ipairs(aclListRights(acl)) do
                storage[right] = aclGetRight(acl, right)
            end
            data[aclGetName(acl)] = storage
        end
        triggerClientEvent(client, EVENT_ACL, client, ACL_ACL, group, data)
    end
}
addEvent(EVENT_ACL, true)
addEventHandler(
    EVENT_ACL,
    root,
    function(action, ...)
        aACLFunctions[action](...)
    end
)

function moo()
    local mdata = ""
    local mdata2 = ""
    if (action == "password") then
        action = nil
        if (not arg[1]) then
            outputChatBox("Error - Password missing.", source, 255, 0, 0)
        elseif (not arg[2]) then
            outputChatBox("Error - New password missing.", source, 255, 0, 0)
        elseif (not arg[3]) then
            outputChatBox("Error - Confirm password.", source, 255, 0, 0)
        elseif (tostring(arg[2]) ~= tostring(arg[3])) then
            outputChatBox("Error - Passwords do not match.", source, 255, 0, 0)
        else
            local account = getAccount(getPlayerUserName(source), tostring(arg[1]))
            if (account) then
                action = "password"
                setAccountPassword(account, arg[2])
                mdata = arg[2]
            else
                outputChatBox("Error - Invalid password.", source, 255, 0, 0)
            end
        end
    elseif (action == "autologin") then
    elseif (action == "sync") then
        local type = arg[1]
        local tableOut = {}
        if (type == "aclgroups") then
            tableOut["groups"] = {}
            for id, group in ipairs(aclGroupList()) do
                table.insert(tableOut["groups"], aclGroupGetName(group))
            end
            tableOut["acl"] = {}
            for id, acl in ipairs(aclList()) do
                table.insert(tableOut["acl"], aclGetName(acl))
            end
        elseif (type == "aclobjects") then
            local group = aclGetGroup(tostring(arg[2]))
            if (group) then
                tableOut["name"] = arg[2]
                tableOut["objects"] = aclGroupListObjects(group)
                tableOut["acl"] = {}
                for id, acl in ipairs(aclGroupListACL(group)) do
                    table.insert(tableOut["acl"], aclGetName(acl))
                end
            end
        elseif (type == "aclrights") then
            local acl = aclGet(tostring(arg[2]))
            if (acl) then
                tableOut["name"] = arg[2]
                tableOut["rights"] = {}
                for id, name in ipairs(aclListRights(acl)) do
                    tableOut["rights"][name] = aclGetRight(acl, name)
                end
            end
        end
        triggerClientEvent(source, "aAdminACL", root, type, tableOut)
    elseif (action == "aclcreate") then
        local name = arg[2]
        if ((name) and (string.len(name) >= 1)) then
            if (arg[1] == "group") then
                mdata = "Group " .. name
                if (not aclCreateGroup(name)) then
                    action = nil
                end
            elseif (arg[1] == "acl") then
                mdata = "ACL " .. name
                if (not aclCreate(name)) then
                    action = nil
                end
            end
            triggerEvent("aAdmin", source, "sync", "aclgroups")
        else
            outputChatBox("Error - Invalid " .. arg[1] .. " name", source, 255, 0, 0)
        end
    elseif (action == "acldestroy") then
        local name = arg[2]
        if (arg[1] == "group") then
            if (aclGetGroup(name)) then
                mdata = "Group " .. name
                aclDestroyGroup(aclGetGroup(name))
            else
                action = nil
            end
        elseif (arg[1] == "acl") then
            if (aclGet(name)) then
                mdata = "ACL " .. name
                aclDestroy(aclGet(name))
            else
                action = nil
            end
        end
        triggerEvent("aAdmin", source, "sync", "aclgroups")
    elseif (action == "acladd") then
        if (arg[3]) then
            action = action
            mdata = "Group '" .. arg[2] .. "'"
            if (arg[1] == "object") then
                local group = aclGetGroup(arg[2])
                local object = arg[3]
                if (not aclGroupAddObject(group, object)) then
                    action = nil
                    outputChatBox(
                        "Error adding object '" .. tostring(object) .. "' to group '" .. tostring(arg[2]) .. "'",
                        source,
                        255,
                        0,
                        0
                    )
                else
                    mdata2 = "Object '" .. arg[3] .. "'"
                    triggerEvent("aAdmin", source, "sync", "aclobjects", arg[2])
                end
            elseif (arg[1] == "acl") then
                local group = aclGetGroup(arg[2])
                local acl = aclGet(arg[3])
                if (not aclGroupAddACL(group, acl)) then
                    action = nil
                    outputChatBox(
                        "Error adding ACL '" .. tostring(arg[3]) .. "' to group '" .. tostring(arg[2]) .. "'",
                        source,
                        255,
                        0,
                        0
                    )
                else
                    mdata2 = "ACL '" .. arg[3] .. "'"
                    triggerEvent("aAdmin", source, "sync", "aclobjects", arg[2])
                end
            elseif (arg[1] == "right") then
                local acl = aclGet(arg[2])
                local right = arg[3]
            end
        else
            action = nil
        end
    elseif (action == "aclremove") then
        --action = nil
        if (arg[3]) then
            action = action
            mdata = "Group '" .. arg[2] .. "'"
            if (arg[1] == "object") then
                local group = aclGetGroup(arg[2])
                local object = arg[3]
                if (not aclGroupRemoveObject(group, object)) then
                    action = nil
                    outputChatBox(
                        "Error - object '" ..
                            tostring(object) .. "' does not exist in group '" .. tostring(arg[2]) .. "'",
                        source,
                        255,
                        0,
                        0
                    )
                else
                    mdata2 = "Object '" .. arg[3] .. "'"
                    triggerEvent("aAdmin", source, "sync", "aclobjects", arg[2])
                end
            elseif (arg[1] == "acl") then
                local group = aclGetGroup(arg[2])
                local acl = aclGet(arg[3])
                if (not aclGroupRemoveACL(group, acl)) then
                    action = nil
                    outputChatBox(
                        "Error - ACL '" .. tostring(arg[3]) .. "' does not exist in group '" .. tostring(arg[2]) .. "'",
                        source,
                        255,
                        0,
                        0
                    )
                else
                    mdata2 = "ACL '" .. arg[3] .. "'"
                    triggerEvent("aAdmin", source, "sync", "aclobjects", arg[2])
                end
            elseif (arg[1] == "right") then
                local acl = aclGet(arg[2])
                local right = arg[3]
                if (not aclRemoveRight(acl, right)) then
                    action = nil
                    outputChatBox(
                        "Error - right '" .. tostring(arg[3]) .. "' does not exist in ACL '" .. tostring(arg[2]) .. "'",
                        source,
                        255,
                        0,
                        0
                    )
                else
                    mdata = "ACL '" .. arg[2] .. "'"
                    mdata2 = "Right '" .. arg[3] .. "'"
                    triggerEvent("aAdmin", source, "sync", "aclrights", arg[2])
                end
            end
        else
            action = nil
        end
    end
    if (action ~= nil) then
        aAction("admin", action, source, false, mdata, mdata2)
    end
end
