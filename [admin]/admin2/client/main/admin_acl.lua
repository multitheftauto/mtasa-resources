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
        ACL = {}
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
    tab = aAclTab.UsersTab

    -- resources tab
    aAclTab.ResourcesTab = guiCreateTab("Resources", aAclTab.Panel)
    tab = aAclTab.ResourcesTab

    -- rights tab
    aAclTab.RightsTab = guiCreateTab("Rights", aAclTab.Panel)
    tab = aAclTab.RightsTab

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

    triggerServerEvent(EVENT_ACL, getLocalPlayer(), ACL_GROUPS)

    addEventHandler(EVENT_ACL, getLocalPlayer(), aAclTab.onSync)
    addEventHandler("onClientGUIClick", aAclTab.Tab, aAclTab.onClick)
    addEventHandler("onClientGUIChanged", aAclTab.AccessSearch, aAclTab.onChanged)
end

aAclTab.SyncFunctions = {
    [ACL_GROUPS] = function(data)
        guiGridListClear(aAclTab.Groups)
        for id, group in ipairs(data) do
            aAclTab.Cache.Groups[group] = {}
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
    end
}

function aAclTab.onSync(action, ...)
    aAclTab.SyncFunctions[action](...)
end

function aAclTab.onClick(key, state)
    if (key ~= "left") then
        return
    end
    if (source == aAclTab.Groups or source == aAclTab.ViewTypes) then
        aAclTab.RefreshAccess()
    end
end

function aAclTab.onChanged()
    if (source == aAclTab.AccessSearch) then
        aAclTab.RefreshAccess()
    end
end

function aAclTab.GetViewedRight()
    local temp = {Commands = "command", General = "general", Functions = "function"}
    return temp[guiComboBoxGetItemText(aAclTab.ViewTypes, guiComboBoxGetSelected(aAclTab.ViewTypes))]
end

function aAclTab.RefreshAccess()
    guiSetVisible(aAclTab.RightsTab, false)
    local selected = guiGridListGetSelectedItem(aAclTab.Groups)
    if (selected ~= -1) then
        local group = guiGridListGetItemText(aAclTab.Groups, selected, 1)
        local cache = aAclTab.Cache.Groups[group]
        if (#cache > 0) then
            local list = aAclTab.Access
            aAclTab.ClearAccess()
            local temp = {}
            local strip = aAclTab.GetViewedRight()
            local names = guiGridListAddColumn(list, strip, 0.35)
            local strip = strip .. "."
            local search = string.lower(guiGetText(aAclTab.AccessSearch))
            if (search == "") then
                search = false
            end
            for i, acl in ipairs(cache) do
                if (acl == group) then
                    guiSetVisible(aAclTab.RightsTab, true)
                end
                local rights = aAclTab.Cache.ACL[acl]
                local column = guiGridListAddColumn(list, acl, 0.10)
                for right, access in pairs(rights) do
                    local name, found = string.gsub(right, strip, "")
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
            triggerServerEvent(EVENT_ACL, getLocalPlayer(), ACL_ACL, ACL_GET, group)
        end
    end
end

function aAclTab.ClearAccess()
    guiGridListClear(aAclTab.Access)
    for i = 1, guiGridListGetColumnCount(aAclTab.Access) do
        guiGridListRemoveColumn(aAclTab.Access, 1)
    end
end
