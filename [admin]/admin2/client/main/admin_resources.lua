--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\main\admin_resources.lua
*
*	Original File by lil_Toady
*	Contributed: ccw
*
**************************************]]
aResourcesTab = {
    LogLines = 1,
    Resources = {},
    List = {},
    Current = nil
}

addEvent("aClientResourceStart", true)
addEvent("aClientResourceStop", true)

function aResourcesTab.Create(tab)
    aResourcesTab.Tab = tab

    aResourcesTab.Panel = guiCreateTabPanel(0.01, 0.02, 0.98, 0.96, true, tab)
    aResourcesTab.MainTab = guiCreateTab("Main", aResourcesTab.Panel)

    aResourcesTab.Filter = guiCreateEdit(0.01, 0.01, 0.22, 0.04, "", true, aResourcesTab.MainTab)
    guiHandleInput(aResourcesTab.Filter)
    guiCreateInnerImage("client\\images\\search.png", aResourcesTab.Filter)

    aResourcesTab.View = guiCreateComboBox(0.23, 0.01, 0.13, 0.35, "All", true, aResourcesTab.MainTab)
    aResourcesTab.ResourceList = guiCreateGridList(0.01, 0.07, 0.35, 0.86, true, aResourcesTab.MainTab)
    guiGridListAddColumn(aResourcesTab.ResourceList, "Resource", 0.60)
    guiGridListAddColumn(aResourcesTab.ResourceList, "State", 0.25)
    aResourcesTab.Context = guiCreateContextMenu(aResourcesTab.ResourceList)
    aResourcesTab.ContextStart = guiContextMenuAddItem(aResourcesTab.Context, "Start")
    aResourcesTab.ContextRestart = guiContextMenuAddItem(aResourcesTab.Context, "Restart")
    aResourcesTab.ContextStop = guiContextMenuAddItem(aResourcesTab.Context, "Stop")

    aResourcesTab.ResourceRefresh =
        guiCreateButton(0.01, 0.94, 0.35, 0.04, "Refresh list", true, aResourcesTab.MainTab, "listresources")
    aResourcesTab.ResourceStart = guiCreateButton(0.79, 0.02, 0.20, 0.04, "Start", true, aResourcesTab.MainTab, "start")
    aResourcesTab.ResourceRestart =
        guiCreateButton(0.79, 0.07, 0.20, 0.04, "Restart", true, aResourcesTab.MainTab, "restart")
    aResourcesTab.ResourceStop = guiCreateButton(0.79, 0.12, 0.20, 0.04, "Stop", true, aResourcesTab.MainTab, "stop")
    guiCreateHeader(0.38, 0.03, 0.20, 0.04, "Resource info:", true, aResourcesTab.MainTab)
    aResourcesTab.Name = guiCreateLabel(0.39, 0.07, 0.40, 0.04, "Name: -", true, aResourcesTab.MainTab)
    aResourcesTab.Type = guiCreateLabel(0.39, 0.11, 0.40, 0.04, "Type: -", true, aResourcesTab.MainTab)
    aResourcesTab.Author = guiCreateLabel(0.39, 0.15, 0.40, 0.04, "Author: -", true, aResourcesTab.MainTab)
    aResourcesTab.Version = guiCreateLabel(0.39, 0.19, 0.40, 0.04, "Version: -", true, aResourcesTab.MainTab)
    aResourcesTab.Description = guiCreateLabel(0.39, 0.23, 0.60, 0.10, "Description: -", true, aResourcesTab.MainTab)
    guiLabelSetHorizontalAlign(aResourcesTab.Description, "left", true)
    guiCreateHeader(0.38, 0.32, 0.20, 0.04, "Resource settings:", true, aResourcesTab.MainTab)
    aResourcesTab.Settings = guiCreateGridList(0.38, 0.36, 0.61, 0.38, true, aResourcesTab.MainTab)
    guiGridListAddColumn(aResourcesTab.Settings, "Name", 0.44)
    guiGridListAddColumn(aResourcesTab.Settings, "Current", 0.24)
    guiGridListAddColumn(aResourcesTab.Settings, "Default", 0.24)
    guiGridListSetSortingEnabled(aResourcesTab.Settings, false)
    guiCreateHeader(0.38, 0.75, 0.20, 0.04, "Execute code:", true, aResourcesTab.MainTab)
    aResourcesTab.Command = guiCreateMemo(0.38, 0.80, 0.50, 0.18, "", true, aResourcesTab.MainTab)
    guiHandleInput(aResourcesTab.Command)
    aResourcesTab.ExecuteClient =
        guiCreateButton(0.89, 0.80, 0.10, 0.04, "Client", true, aResourcesTab.MainTab, "execute")
    aResourcesTab.ExecuteServer =
        guiCreateButton(0.89, 0.85, 0.10, 0.04, "Server", true, aResourcesTab.MainTab, "execute")
    aResourcesTab.ExecuteAdvanced =
        guiCreateLabel(0.2, 0.4, 1.0, 0.50, "For advanced users only.", true, aResourcesTab.Command)
    guiLabelSetColor(aResourcesTab.ExecuteAdvanced, 255, 0, 0)

    -- EVENTS
    addEventHandler(EVENT_SYNC, root, aResourcesTab.onClientSync)
    addEventHandler("onClientGUIClick", aResourcesTab.Context, aResourcesTab.onContextClick)
    addEventHandler("onClientGUIClick", aResourcesTab.MainTab, aResourcesTab.onClientClick)
    addEventHandler("onClientGUIDoubleClick", aResourcesTab.Settings, aResourcesTab.onClientDoubleClick)
    addEventHandler("onClientGUIComboBoxAccepted", aResourcesTab.View, aResourcesTab.onClientClick)
    addEventHandler("onClientGUIChanged", aResourcesTab.Filter, aResourcesTab.onEditFilter)
    addEventHandler("aClientResourceStart", root, aResourcesTab.onClientResourceStart)
    addEventHandler("aClientResourceStop", root, aResourcesTab.onClientResourceStop)

    if (hasPermissionTo("command.listresources")) then
        sync(SYNC_RESOURCES)
    end
end

function aResourcesTab.onContextClick(button)
    local translator = {
        [aResourcesTab.ContextStart] = aResourcesTab.ResourceStart,
        [aResourcesTab.ContextRestart] = aResourcesTab.ResourceRestart,
        [aResourcesTab.ContextStop] = aResourcesTab.ResourceStop
    }
    if (translator[source]) then
        source = translator[source]
        aResourcesTab.onClientClick(button)
    end
end

local timerSpam
function aResourcesTab.onEditFilter()
    if isTimer(timerSpam) then
        killTimer(timerSpam) 
    end
    timerSpam = setTimer(aResourcesTab.ApplyFilter, 200, 1)
end

function aResourcesTab.ApplyFilter(filter)
    local type = guiComboBoxGetItemText(aResourcesTab.View, guiComboBoxGetSelected(aResourcesTab.View))
    if type == "All" then
        type = nil
    end
    aResourcesTab.listResources(type)
end

function aResourcesTab.onClientClick(button)
    if (button == "left") then
        if
            ((source == aResourcesTab.ResourceStart) or (source == aResourcesTab.ResourceRestart) or
                (source == aResourcesTab.ResourceStop))
         then
            if (guiGridListGetSelectedItem(aResourcesTab.ResourceList) == -1) then
                messageBox("No resource selected!", MB_ERROR, MB_OK)
            else
                local name =
                    guiGridListGetItemText(
                    aResourcesTab.ResourceList,
                    guiGridListGetSelectedItem(aResourcesTab.ResourceList),
                    1
                )
                if (source == aResourcesTab.ResourceStart) then
                    triggerServerEvent("aResource", getLocalPlayer(), name, "start")
                elseif (source == aResourcesTab.ResourceRestart) then
                    triggerServerEvent("aResource", getLocalPlayer(), name, "restart")
                elseif (source == aResourcesTab.ResourceStop) then
                    triggerServerEvent("aResource", getLocalPlayer(), name, "stop")
                end
            end
        elseif (source == aResourcesTab.ResourceList) then
            if (guiGridListGetSelectedItem(aResourcesTab.ResourceList) ~= -1) then
                local name =
                    guiGridListGetItemText(
                    aResourcesTab.ResourceList,
                    guiGridListGetSelectedItem(aResourcesTab.ResourceList),
                    1
                )
                local info = aResourcesTab.Resources[name]
                if (info) then
                    aResourcesTab.Current = name
                    guiSetText(aResourcesTab.Name, "Name: " .. (info.name or name))
                    guiSetText(aResourcesTab.Type, "Type: " .. (info.type or "Unknown"))
                    guiSetText(aResourcesTab.Author, "Author: " .. (info.author or "Unknown"))
                    guiSetText(aResourcesTab.Version, "Version: " .. (info.version or "Unknown"))
                    guiSetText(aResourcesTab.Description, "Description: " .. (info.description or "None"))
                    if (info.settings) then
                        aResourcesTab.listSettings(info.settings)
                    end
                else
                    sync(SYNC_RESOURCE, name)
                end
            else
                aResourcesTab.Current = nil
                guiSetText(aResourcesTab.Name, "Name: -")
                guiSetText(aResourcesTab.Type, "Type: -")
                guiSetText(aResourcesTab.Author, "Author: -")
                guiSetText(aResourcesTab.Version, "Version: -")
                guiSetText(aResourcesTab.Description, "Description: -")
                guiGridListClear(aResourcesTab.Settings)
            end
        elseif (source == aResourcesTab.ResourceRefresh) then
            guiGridListClear(aResourcesTab.ResourceList)
            sync(SYNC_RESOURCES)
        elseif (source == aResourcesTab.ExecuteClient) then
            local code = guiGetText(aResourcesTab.Command)
            if ((code) and (code ~= "")) then
                local results = {pcall(assert(loadstring("return " .. code)))}
                if (results[1]) then
                    for i = 2, #results do
                        local value = results[i]
                        local type = type(value)
                        if (isElement(type)) then
                            type = getElementType(value)
                        end
                        outputChatBox((i - 1) .. ": " .. tostring(value) .. "[" .. type .. "]", 10, 220, 10)
                    end
                else
                    outputChatBox("Error: " .. tostring(results[2]), 220, 10, 10)
                end
            end
        elseif (source == aResourcesTab.ExecuteServer) then
            local code = guiGetText(aResourcesTab.Command)
            if ((code) and (code ~= "")) then
                triggerServerEvent("aExecute", getLocalPlayer(), code, true)
            end
        elseif (source == aResourcesTab.Command) then
            guiSetVisible(aResourcesTab.ExecuteAdvanced, false)
        elseif (source == aResourcesTab.ExecuteAdvanced) then
            guiSetVisible(aResourcesTab.ExecuteAdvanced, false)
        elseif source == aResourcesTab.View then
            local type = guiComboBoxGetItemText(source, source.selected)
            if type == "All" then
                type = nil
            end
            aResourcesTab.listResources(type)
        end
    end
end

function aResourcesTab.onClientDoubleClick(button)
    if (button == "left") then
        if (source == aResourcesTab.Settings) then
            local settings = aResourcesTab.Settings
            if (source ~= settings) then
                return
            end
            local row = guiGridListGetSelectedItem(settings)
            if (row ~= -1) then
                local name = tostring(guiGridListGetItemData(settings, row, 1))
                local data = aResourcesTab.Resources[aResourcesTab.Current].settings[name]
                local friendlyname = data.friendlyname or name
                local current = data.current or ""
                local newValue = inputBox(
                    "Change setting",
                    "Enter new value for '" .. friendlyname .. "'",
                    tostring(current),
                    'triggerServerEvent ( "aResource", getLocalPlayer(), "' ..
                        aResourcesTab.Current .. '", "setsetting", { name = "' .. name .. '", value = $value } )'
                )
                triggerServerEvent ( "aResource", getLocalPlayer(), aResourcesTab.Current, "setsetting", name, newValue)
            end
        end
    end
end

function aResourcesTab.onClientSync(type, data)
    if (type == SYNC_RESOURCES) then
        aResourcesTab.List = data
        aResourcesTab.listResources()
        guiComboBoxClear(aResourcesTab.View)
        guiComboBoxAddItem(aResourcesTab.View, "All")
        for group, list in pairs(data) do
            guiComboBoxAddItem(aResourcesTab.View, group)
        end
    elseif (type == SYNC_RESOURCE) then
        aResourcesTab.Resources[data.name] = data.info
        guiSetText(aResourcesTab.Name, "Name: " .. (data.info.name or data.name))
        guiSetText(aResourcesTab.Type, "Type: " .. (data.info.type or "Unknown"))
        guiSetText(aResourcesTab.Author, "Author: " .. (data.info.author or "Unknown"))
        guiSetText(aResourcesTab.Version, "Version: " .. (data.info.version or "Unknown"))
        guiSetText(aResourcesTab.Description, "Description: " .. (data.info.description or "None"))
        aResourcesTab.listSettings(data.info.settings)
        aResourcesTab.Current = data.name
    end
end

function aResourcesTab.listResources(type)
    local resources = aResourcesTab.ResourceList
    guiGridListClear(resources)
    local temp = {}
    if (type) then
        temp = aResourcesTab.List[type]
    else
        for group, list in pairs(aResourcesTab.List) do
            for id, resource in ipairs(list) do
                table.insert(temp, resource)
            end
        end
    end
    table.sort(
        temp,
        function(a, b)
            return a.name < b.name
        end
    )
    local filter = guiGetText(aResourcesTab.Filter)
    if (filter == '') then
        filter = nil
    end
    for id, resource in ipairs(temp) do
        if (filter and resource.name:lower():find(filter:lower())) or (not filter) then
            local row = guiGridListAddRow(resources)
            guiGridListSetItemText(resources, row, 1, resource.name, false, false)
            guiGridListSetItemText(resources, row, 2, resource.state, false, false)
        end
    end
end

function aResourcesTab.listSettings(settings)
    local list = aResourcesTab.Settings
    guiGridListClear(list)
    local groups = {}
    local groupnameList = {}
    for name, value in pairs(settings) do
        local groupname = settings[name].group or " "
        if not groups[groupname] then
            groups[groupname] = {}
            table.insert(groupnameList, groupname)
        end
        table.insert(groups[groupname], name)
    end
    -- sort groupnames
    table.sort(
        groupnameList,
        function(a, b)
            return (a < b)
        end
    )
    -- for each group
    for _, groupname in ipairs(groupnameList) do
        local namesList = groups[groupname]
        -- sort names
        table.sort(
            namesList,
            function(a, b)
                return (a < b)
            end
        )
        -- Add to gridlist using sorted names
        local row = guiGridListAddRow(list)
        guiGridListSetItemText(
            list,
            row,
            1,
            string.sub(groupname, 1, 1) == "_" and string.sub(groupname, 2) or groupname,
            true,
            false
        )
        for i, name in ipairs(namesList) do
            local value = settings[name]
            row = guiGridListAddRow(list)
            guiGridListSetItemText(list, row, 1, tostring(value.friendlyname or name), false, false)
            guiGridListSetItemText(list, row, 2, tostring(value.current), false, false)
            guiGridListSetItemText(list, row, 3, tostring(value.default), false, false)
            guiGridListSetItemData(list, row, 1, tostring(name))
        end
    end
end

function aResourcesTab.onClientResourceStart(resource)
    local id = 0
    while (id <= guiGridListGetRowCount(aResourcesTab.ResourceList)) do
        if (guiGridListGetItemText(aResourcesTab.ResourceList, id, 1) == resource) then
            guiGridListSetItemText(aResourcesTab.ResourceList, id, 2, "running", false, false)
        end
        id = id + 1
    end
end

function aResourcesTab.onClientResourceStop(resource)
    local id = 0
    while (id <= guiGridListGetRowCount(aResourcesTab.ResourceList)) do
        if (guiGridListGetItemText(aResourcesTab.ResourceList, id, 1) == resource) then
            guiGridListSetItemText(aResourcesTab.ResourceList, id, 2, "loaded", false, false)
        end
        id = id + 1
    end
end
