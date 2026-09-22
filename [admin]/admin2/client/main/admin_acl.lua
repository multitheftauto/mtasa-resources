--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\main\admin_acl.lua
*
*	Original File by lil_Toady
*
**************************************]]
aAclTab = {
    Cache = {
        Groups = {},
        ACL = {},
        Users = {},
        Resources = {},
    }
}

addEvent(EVENT_ACL, true)

function aAclTab.Create(tab)
    aAclTab.Tab = tab

    aAclTab.GroupSearch = guiCreateEdit(0.01, 0.02, 0.20, 0.04, "", true, tab)
    guiCreateInnerImage("client\\images\\search.png", aAclTab.GroupSearch)

    aAclTab.Groups = guiCreateGridList(0.01, 0.07, 0.20, 0.50, true, tab)
    guiGridListSetSortingEnabled(aAclTab.Groups, false)
    guiGridListAddColumn(aAclTab.Groups, "Groups", 0.85)

    aAclTab.Panel = guiCreateTabPanel(0.22, 0.07, 0.76, 0.91, true, tab)

    -- users tab
    aAclTab.UsersTab = guiCreateTab("Users", aAclTab.Panel)

    aAclTab.Users = guiCreateGridList(0.01, 0.07, 0.98, 0.91, true, aAclTab.UsersTab)
    guiGridListAddColumn(aAclTab.Users, "Name", 1)
    aAclTab.UsersSearch = guiCreateEdit(0.01, 0.0125, 0.3, 0.05, "", true, aAclTab.UsersTab)
    guiCreateInnerImage("client\\images\\search.png", aAclTab.UsersSearch)
    guiHandleInput(aAclTab.UsersSearch)

    aAclTab.UsersButton_AddUser = guiCreateButton(0.55, 0.0125, 0.2, 0.05, "Add User", true, aAclTab.UsersTab)
    aAclTab.UsersButton_RemoveUser = guiCreateButton(0.775, 0.0125, 0.2, 0.05, "Remove User", true, aAclTab.UsersTab)

    -- resources tab
    aAclTab.ResourcesTab = guiCreateTab("Resources", aAclTab.Panel)

    aAclTab.Resources = guiCreateGridList(0.01, 0.07, 0.98, 0.91, true, aAclTab.ResourcesTab)
    guiGridListAddColumn(aAclTab.Resources, "Name", 1)
    aAclTab.ResourcesSearch = guiCreateEdit(0.01, 0.0125, 0.3, 0.05, "", true, aAclTab.ResourcesTab)
    guiCreateInnerImage("client\\images\\search.png", aAclTab.ResourcesSearch)
    guiHandleInput(aAclTab.ResourcesSearch)

    aAclTab.ResourcesButton_AddResource = guiCreateButton(0.55, 0.0125, 0.2, 0.05, "Add Resource", true, aAclTab.ResourcesTab)
    aAclTab.ResourcesButton_RemoveResource = guiCreateButton(0.775, 0.0125, 0.2, 0.05, "Remove Resource", true, aAclTab.ResourcesTab)

    -- rights tab
    aAclTab.RightsTab = guiCreateTab("Rights", aAclTab.Panel)
    aAclTab.RightsACL = guiCreateComboBox(0.01, 0.0125, 0.35, 0.3, "Select ACL", true, aAclTab.RightsTab)
    aAclTab.RightsSearch = guiCreateEdit(0.38, 0.0125, 0.60, 0.05, "", true, aAclTab.RightsTab)
    guiCreateInnerImage("client\\images\\search.png", aAclTab.RightsSearch)
    guiHandleInput(aAclTab.RightsSearch)
    aAclTab.Rights = guiCreateGridList(0.01, 0.08, 0.98, 0.78, true, aAclTab.RightsTab)
    guiGridListAddColumn(aAclTab.Rights, "Right", 0.75)
    guiGridListAddColumn(aAclTab.Rights, "Access", 0.18)
    aAclTab.AddRight = guiCreateButton(0.01, 0.89, 0.23, 0.07, "Add Right", true, aAclTab.RightsTab)
    aAclTab.AllowRight = guiCreateButton(0.26, 0.89, 0.23, 0.07, "Allow", true, aAclTab.RightsTab)
    aAclTab.DenyRight = guiCreateButton(0.51, 0.89, 0.23, 0.07, "Deny", true, aAclTab.RightsTab)
    aAclTab.RemoveRight = guiCreateButton(0.76, 0.89, 0.23, 0.07, "Remove Right", true, aAclTab.RightsTab)

    -- access matrix tab
    aAclTab.AccessTab = guiCreateTab("Access Matrix", aAclTab.Panel)
    aAclTab.AccessSearch = guiCreateEdit(0.01, 0.0125, 0.3, 0.05, "", true, aAclTab.AccessTab)
    guiCreateInnerImage("client\\images\\search.png", aAclTab.AccessSearch)
    guiHandleInput(aAclTab.AccessSearch)
    aAclTab.ViewTypes = guiCreateComboBox(0.69, 0.0075, 0.3, 0.3, "Commands", true, aAclTab.AccessTab)
    guiComboBoxAddItem(aAclTab.ViewTypes, "Commands")
    guiComboBoxSetSelected(aAclTab.ViewTypes, 1)
    guiComboBoxAddItem(aAclTab.ViewTypes, "Functions")
    guiComboBoxAddItem(aAclTab.ViewTypes, "General")

    aAclTab.Access = guiCreateGridList(0.01, 0.07, 0.98, 0.91, true, aAclTab.AccessTab)

    triggerServerEvent(EVENT_ACL, localPlayer, ACL_GROUPS)

    addEventHandler("onClientGUIComboBoxAccepted", aAclTab.RightsACL, aAclTab.RefreshRightsList)
    addEventHandler("onClientGUIChanged", aAclTab.RightsSearch, aAclTab.RefreshRightsList)
    addEventHandler(EVENT_ACL, localPlayer, aAclTab.onSync)
    addEventHandler("onClientGUIClick", aAclTab.Tab, aAclTab.onClick)
    addEventHandler("onClientGUIChanged", aAclTab.AccessSearch, aAclTab.onChanged)
    addEventHandler("onClientGUIChanged", aAclTab.UsersSearch, aAclTab.onChanged)
    addEventHandler('onClientGUIChanged', aAclTab.ResourcesSearch, aAclTab.onChanged)
end

aAclTab.SyncFunctions = {
    [ACL_GROUPS] = function(data)
        guiGridListClear(aAclTab.Groups)
        for id, group in ipairs(data) do
            aAclTab.Cache.Groups[group] = false
            local row = guiGridListAddRow(aAclTab.Groups)
            guiGridListSetItemText(aAclTab.Groups, row, 1, group, false, false)
        end
    end,
    [ACL_ACL] = function(group, data)
        aAclTab.Cache.Groups[group] = {}
        for acl, rights in pairs(data) do
            table.insert(aAclTab.Cache.Groups[group], acl)
            aAclTab.Cache.ACL[acl] = rights
        end
        aAclTab.RefreshAccess()
        aAclTab.RefreshRightsACL()
    end,
    [ACL_USERS] = function(group, data)
        guiGridListClear(aAclTab.Users)
        aAclTab.Cache.Users[group] = {}

        for id,object in ipairs(data) do
            local obj = object:gsub('user.','')
            table.insert(aAclTab.Cache.Users[group], obj)
        end

        aAclTab.RefreshUsersList()
    end,
    [ACL_RESOURCES] = function(group, data)
        guiGridListClear(aAclTab.Resources)
        aAclTab.Cache.Resources[group] = {}

        for id,object in ipairs(data) do
            local obj = object:gsub('resource.','')
            table.insert(aAclTab.Cache.Resources[group], obj)
        end

        aAclTab.RefreshResourcesList()
    end
}

function aAclTab.onSync(action, ...)
    aAclTab.SyncFunctions[action](...)
end

function aAclTab.onClick(key, state)
    if (key ~= "left") or (state ~= "up") then
        return
    end

    if (source == aAclTab.Groups) then
        aAclTab.RefreshAccess()
        aAclTab.RefreshRightsACL()
        aAclTab.RefreshUsersList()
        aAclTab.RefreshResourcesList()
    elseif (source == aAclTab.AddRight or source == aAclTab.AllowRight or source == aAclTab.DenyRight or source == aAclTab.RemoveRight) then
        aAclTab.EditRight(source)
    elseif (source == aAclTab.ViewTypes) then
        aAclTab.RefreshAccess()
    elseif (source == aAclTab.UsersButton_RemoveUser) then
        local selected = guiGridListGetSelectedItem(aAclTab.Users)

        if (selected ~= -1) then
            local object = guiGridListGetItemText(aAclTab.Users, selected, 1)
            local selectedGroup = guiGridListGetSelectedItem(aAclTab.Groups)
            local group = guiGridListGetItemText(aAclTab.Groups, selectedGroup, 1)

            local result = messageBox("Are you sure you want to remove the user '"..object.."' from the '"..group.."' ACL group?", MB_QUESTION, MB_YESNO)

            if (result) then
                triggerServerEvent(EVENT_ACL, localPlayer, ACL_USERS, ACL_REMOVE, group, 'user.'..object)

                aAclTab.Cache.Users[group] = nil
                aAclTab.RefreshUsersList()
            end
        else
            messageBox("No user selected!", MB_ERROR, MB_OK)
        end
    elseif (source == aAclTab.UsersButton_AddUser) then
        local selected = guiGridListGetSelectedItem(aAclTab.Groups)

        if (selected ~= -1) then
            local nick = inputBox("Add user", "Enter user account name")

            if (nick) then
                local group = guiGridListGetItemText(aAclTab.Groups, selected, 1)
                triggerServerEvent(EVENT_ACL, localPlayer, ACL_USERS, ACL_ADD, group, nick)

                aAclTab.Cache.Users[group] = nil
                aAclTab.RefreshUsersList()
            end
        else
            messageBox("No group selected!", MB_ERROR, MB_OK)
        end
    elseif (source == aAclTab.ResourcesButton_AddResource) then
        local selected = guiGridListGetSelectedItem(aAclTab.Groups)

        if (selected ~= -1) then
            local name = inputBox("Add resource", "Enter resource name")

            if (name) then
                local group = guiGridListGetItemText(aAclTab.Groups, selected, 1)
                triggerServerEvent(EVENT_ACL, localPlayer, ACL_RESOURCES, ACL_ADD, group, name)

                aAclTab.Cache.Resources[group] = nil
                aAclTab.RefreshResourcesList()
            end
        else
            messageBox("No group selected!", MB_ERROR, MB_OK)
        end
    elseif (source == aAclTab.ResourcesButton_RemoveResource) then
        local selected = guiGridListGetSelectedItem(aAclTab.Resources)

        if (selected ~= -1) then
            local object = guiGridListGetItemText(aAclTab.Resources, selected, 1)
            local selectedGroup = guiGridListGetSelectedItem(aAclTab.Groups)
            local group = guiGridListGetItemText(aAclTab.Groups, selectedGroup, 1)

            local result = messageBox("Are you sure you want to remove the resource '"..object.."' from the '"..group.."' ACL group?", MB_QUESTION, MB_YESNO)

            if (result) then
                triggerServerEvent(EVENT_ACL, localPlayer, ACL_RESOURCES, ACL_REMOVE, group, 'resource.'..object)

                aAclTab.Cache.Resources[group] = nil
                aAclTab.RefreshResourcesList()
            end
        else
            messageBox("No resource selected!", MB_ERROR, MB_OK)
        end
    end
end

function aAclTab.onChanged()
    if (source == aAclTab.AccessSearch) then
        aAclTab.RefreshAccess()
    elseif (source == aAclTab.UsersSearch) then
        aAclTab.RefreshUsersList()
    elseif (source == aAclTab.ResourcesSearch) then
        aAclTab.RefreshResourcesList()
    end
end

function aAclTab.GetViewedRight()
    local temp = {Commands = "command", General = "general", Functions = "function"}
    return temp[guiComboBoxGetItemText(aAclTab.ViewTypes, guiComboBoxGetSelected(aAclTab.ViewTypes))]
end

function aAclTab.RefreshAccess()
    aAclTab.ClearAccess()
    local selected = guiGridListGetSelectedItem(aAclTab.Groups)
    if (selected ~= -1) then
        local group = guiGridListGetItemText(aAclTab.Groups, selected, 1)
        local cache = aAclTab.Cache.Groups[group]
        if (cache) then
            local list = aAclTab.Access
            local temp = {}
            local strip = aAclTab.GetViewedRight()
            local names = guiGridListAddColumn(list, strip, 0.35)
            local strip2 = strip .. "."
            local search = string.lower(guiGetText(aAclTab.AccessSearch))
            if (search == "") then
                search = false
            end
            for i, acl in ipairs(cache) do
                local rights = aAclTab.Cache.ACL[acl]
                local column = guiGridListAddColumn(list, acl, 0.10)
                for right, access in pairs(rights) do
                    local name, found = string.gsub(right, strip2, "")
                    if ((found ~= 0) and ((not search) or (string.find(string.lower(name), search)))) then
                        local row = temp[name]
                        if (not row) then
                            row = guiGridListAddRow(list)
                            guiGridListSetItemText(list, row, names, name, false, false)
                            temp[name] = row
                        end
                        guiGridListSetItemText(list, row, column, tostring(access), false, false)
                    end
                end
            end
            -- post processing
            local columns = guiGridListGetColumnCount(list)
            for i = 0, guiGridListGetRowCount(list) do
                local access = false
                for j = 2, columns do
                    local text = guiGridListGetItemText(list, i, j)
                    if (text == "") then
                        guiGridListSetItemText(list, i, j, "false", false, false)
                        --guiGridListSetItemColor ( list, i, j, 255, 50, 50 )
                        guiGridListSetItemColor(list, i, j, 75, 75, 75)
                    elseif (text == "true") then
                        access = true
                        --guiGridListSetItemColor ( list, i, j, 50, 255, 50 )
                        guiGridListSetItemColor(list, i, j, 255, 255, 255)
                    else
                        --guiGridListSetItemColor ( list, i, j, 255, 50, 50 )
                        guiGridListSetItemColor(list, i, j, 75, 75, 75)
                    end
                end
                if (access) then
                    --guiGridListSetItemColor ( list, i, 1, 50, 255, 50 )
                    guiGridListSetItemColor(list, i, 1, 255, 255, 255)
                else
                    --guiGridListSetItemColor ( list, i, 1, 255, 50, 50 )
                    guiGridListSetItemColor(list, i, 1, 75, 75, 75)
                end
            end
        else
            triggerServerEvent(EVENT_ACL, localPlayer, ACL_ACL, ACL_GET, group)
        end
    end
end

function aAclTab.ClearAccess()
    guiGridListClear(aAclTab.Access)
    for i = 1, guiGridListGetColumnCount(aAclTab.Access) do
        guiGridListRemoveColumn(aAclTab.Access, 1)
    end
end

function aAclTab.RefreshUsersList()
    local selected = guiGridListGetSelectedItem(aAclTab.Groups)

    if (selected ~= -1) then
        guiGridListClear(aAclTab.Users)

        local group = guiGridListGetItemText(aAclTab.Groups, selected, 1)
        local cache = aAclTab.Cache.Users[group]
        if (cache and #cache > 0) then
            local searchText = guiGetText(aAclTab.UsersSearch):lower()
            local search = searchText:gsub(' ','') ~= ''

            for i,user in ipairs(cache) do
                local row = guiGridListAddRow(aAclTab.Users)

                if ((search and (user:gsub('user.',''):lower():find(searchText, 1, true))) or not search) then
                    guiGridListSetItemText(aAclTab.Users, row, 1, user, false, false)
                end
            end
        else
            triggerServerEvent(EVENT_ACL, localPlayer, ACL_USERS,ACL_GET, group)
        end
    end
end

function aAclTab.RefreshResourcesList()
    local selected = guiGridListGetSelectedItem(aAclTab.Groups)

    if (selected ~= -1) then
        guiGridListClear(aAclTab.Resources)

        local group = guiGridListGetItemText(aAclTab.Groups, selected, 1)
        local cache = aAclTab.Cache.Resources[group]
        if (cache and #cache > 0) then
            local searchText = guiGetText(aAclTab.ResourcesSearch):lower()
            local search = searchText:gsub(' ','') ~= ''

            for i,resource in ipairs(cache) do
                local row = guiGridListAddRow(aAclTab.Resources)

                if ((search and (resource:gsub('resource.',''):lower():find(searchText, 1, true))) or not search) then
                    guiGridListSetItemText(aAclTab.Resources, row, 1, resource, false, false)
                end
            end
        else
            triggerServerEvent(EVENT_ACL, localPlayer, ACL_RESOURCES, ACL_GET, group)
        end
    end
end

function aAclTab.RefreshRightsACL()
    local previous = guiComboBoxGetItemText(aAclTab.RightsACL, guiComboBoxGetSelected(aAclTab.RightsACL))
    guiComboBoxClear(aAclTab.RightsACL)
    local selected = guiGridListGetSelectedItem(aAclTab.Groups)
    local group = selected ~= -1 and guiGridListGetItemText(aAclTab.Groups, selected, 1)
    local acls = aAclTab.Cache.Groups[group]
    if (acls) then
        table.sort(acls)
        for _, acl in ipairs(acls) do
            local item = guiComboBoxAddItem(aAclTab.RightsACL, acl)
            if (item == 0 or acl == previous) then
                guiComboBoxSetSelected(aAclTab.RightsACL, item)
            end
        end
    end
    aAclTab.RefreshRightsList()
end

function aAclTab.RefreshRightsList()
    guiGridListClear(aAclTab.Rights)
    local selected = guiComboBoxGetSelected(aAclTab.RightsACL)
    local acl = guiComboBoxGetItemText(aAclTab.RightsACL, selected)
    local search = guiGetText(aAclTab.RightsSearch):lower()
    for right, access in pairs(aAclTab.Cache.ACL[acl] or {}) do
        if (right:lower():find(search, 1, true)) then
            local row = guiGridListAddRow(aAclTab.Rights)
            guiGridListSetItemText(aAclTab.Rights, row, 1, right, false, false)
            guiGridListSetItemText(aAclTab.Rights, row, 2, tostring(access), false, false)
        end
    end
end

function aAclTab.EditRight(button)
    local selectedGroup = guiGridListGetSelectedItem(aAclTab.Groups)
    local selectedACL = guiComboBoxGetSelected(aAclTab.RightsACL)
    if (selectedGroup == -1 or selectedACL == -1) then
        messageBox("No ACL selected!", MB_ERROR, MB_OK)
        return
    end
    local group = guiGridListGetItemText(aAclTab.Groups, selectedGroup, 1)
    local acl = guiComboBoxGetItemText(aAclTab.RightsACL, selectedACL)
    local right
    local access = button == aAclTab.AllowRight
    local action = ACL_ADD
    if (button == aAclTab.AddRight) then
        right = inputBox("Add right (initially denied)", "Full right name (e.g. command.kick)")
        if (not right) then
            return
        end
    else
        local row = guiGridListGetSelectedItem(aAclTab.Rights)
        if (row == -1) then
            messageBox("No right selected!", MB_ERROR, MB_OK)
            return
        end
        right = guiGridListGetItemText(aAclTab.Rights, row, 1)
        if (button == aAclTab.RemoveRight) then
            action = ACL_REMOVE
        end
    end
    local operation = action == ACL_REMOVE and "Remove" or (access and "Allow" or "Deny")
    if (not messageBox(operation .. " '" .. right .. "' in ACL '" .. acl .. "'? This affects every group using this ACL.", MB_QUESTION, MB_YESNO)) then
        return
    end
    triggerServerEvent(EVENT_ACL, localPlayer, ACL_ACL, action, group, acl, right, access)
end
