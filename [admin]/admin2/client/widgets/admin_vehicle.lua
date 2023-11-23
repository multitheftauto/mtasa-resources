--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\main\admin_weapon.lua
*
*	Original File by jlillis
*
**************************************]]
aVehicle = {
    Form = nil,
    vehicles = {}
}

function aVehicle.Show(player)
    if (aVehicle.Form == nil) then
        local x, y = guiGetScreenSize()
        aVehicle.Form = guiCreateWindow(x / 2 - 140, y / 2 - 140, 280, 280, "Player Vehicle Select", false)
        guiSetAlpha(aVehicle.Form, 1)
        guiSetProperty(aVehicle.Form, 'AlwaysOnTop', 'True')
        aVehicle.Label =
            guiCreateLabel(0.03, 0.09, 0.94, 0.07, "Select a vehicle from the list or enter the id", true, aVehicle.Form)
        guiLabelSetHorizontalAlign(aVehicle.Label, "center")
        guiLabelSetColor(aVehicle.Label, 255, 0, 0)

        aVehicle.Edit = guiCreateEdit(0.03, 0.18, 0.70, 0.09, '', true, aVehicle.Form)
        guiCreateInnerImage("client\\images\\search.png", aVehicle.Edit)

        aVehicle.Groups = guiCreateCheckBox(0.03, 0.90, 0.70, 0.09, "Sort by groups", false, true, aVehicle.Form)
        if (aGetSetting("vehiclesGroup")) then
            guiCheckBoxSetSelected(aVehicle.Groups, true)
        end

        aVehicle.List = guiCreateGridList(0.03, 0.27, 0.70, 0.625, true, aVehicle.Form)
        guiGridListAddColumn(aVehicle.List, "ID", 0.20)
        guiGridListAddColumn(aVehicle.List, "", 0.75)

        aVehicle.ID = guiCreateEdit(0.75, 0.18, 0.27, 0.09, "0", true, aVehicle.Form)
        guiEditSetMaxLength(aVehicle.ID, 3)

        aVehicle.Accept = guiCreateButton(0.75, 0.28, 0.27, 0.09, "Select", true, aVehicle.Form, "givevehicle")
        aVehicle.Cancel = guiCreateButton(0.75, 0.88, 0.27, 0.09, "Cancel", true, aVehicle.Form)

        aVehicle.Load()
        aVehicle.Refresh()

        addEventHandler("onClientGUIClick", aVehicle.Form, aVehicle.onClick)
        addEventHandler("onClientGUIDoubleClick", aVehicle.Form, aVehicle.onDoubleClick)
        addEventHandler("onClientGUIChanged", aVehicle.Form, aVehicle.onGUIChange)
        --Register With Admin Form
        aRegister("PlayerVehicle", aVehicle.Form, aVehicle.Show, aVehicle.Close)
    end

    aVehicle.Select = player
    guiSetVisible(aVehicle.Form, true)
    guiBringToFront(aVehicle.Form)
end

function aVehicle.Close(destroy)
    if (destroy) then
        aVehicle.vehicles = {}
        if (aVehicle.Form) then
            removeEventHandler("onClientGUIClick", aVehicle.Form, aVehicle.onClick)
            removeEventHandler("onClientGUIDoubleClick", aVehicle.Form, aVehicle.onDoubleClick)
            destroyElement(aVehicle.Form)
            aVehicle.Form = nil
        end
    else
        guiSetVisible(aVehicle.Form, false)
    end
end

function aVehicle.onDoubleClick(button)
    if (button == "left") then
        if (source == aVehicle.List) then
            if (guiGridListGetSelectedItem(aVehicle.List) ~= -1) then
                local id = tonumber(guiGridListGetItemText(aVehicle.List, guiGridListGetSelectedItem(aVehicle.List), 1))
                triggerServerEvent("aPlayer", localPlayer, aVehicle.Select, "givevehicle", id)
                aVehicle.Close(false)
            end
        end
    end
end

function aVehicle.onGUIChange()
    if (source == aVehicle.Edit) then
        aVehicle.Refresh()
    end
end

function aVehicle.onClick(button)
    if (button == "left") then
        if (source == aVehicle.Accept) then
            if (tonumber(guiGetText(aVehicle.ID))) then
                triggerServerEvent("aPlayer", localPlayer, aVehicle.Select, "givevehicle", tonumber(guiGetText(aVehicle.ID)))
                aVehicle.Close(false)
            else
                if (guiGridListGetSelectedItem(aVehicle.List) ~= -1) then
                    local id = tonumber(guiGridListGetItemText(aVehicle.List, guiGridListGetSelectedItem(aVehicle.List), 1))
                    guiSetVisible(aVehicle.Form, false)
                    triggerServerEvent("aPlayer", localPlayer, aVehicle.Select, "givevehicle", id)
                else
                    messageBox("No vehicle selected!", MB_ERROR, MB_OK)
                end
            end
        elseif (source == aVehicle.List) then
            if (guiGridListGetSelectedItem(aVehicle.List) ~= -1) then
                local id = guiGridListGetItemText(aVehicle.List, guiGridListGetSelectedItem(aVehicle.List), 1)
                guiSetText(aVehicle.ID, id)
            end
        elseif (source == aVehicle.Cancel) then
            aVehicle.Close(false)
        elseif (source == aVehicle.Groups) then
            aVehicle.Refresh()
        end
    end
end

function aVehicle.Load()
    local table = {}
    local node = xmlLoadFile("conf\\vehicles.xml")
    if (node) then
        local groups = 0
        while (xmlFindChild(node, "group", groups) ~= false) do
            local group = xmlFindChild(node, "group", groups)
            local groupn = xmlNodeGetAttribute(group, "name")
            table[groupn] = {}
            local vehicles = 0
            while (xmlFindChild(group, "vehicle", vehicles) ~= false) do
                local vehicle = xmlFindChild(group, "vehicle", vehicles)
                local id = #table[groupn] + 1
                table[groupn][id] = {}
                table[groupn][id]["id"] = xmlNodeGetAttribute(vehicle, "id")
                table[groupn][id]["name"] = xmlNodeGetAttribute(vehicle, "name")
                vehicles = vehicles + 1
            end
            groups = groups + 1
        end
    end
    aVehicle.vehicles = table
end

function aVehicle.Refresh()
    local groups = guiCheckBoxGetSelected(aVehicle.Groups)
    local filter = guiGetText(aVehicle.Edit):lower()
    local sortDirection = guiGetProperty(aVehicle.List, "SortDirection")
    aSetSetting("vehiclesGroup", groups)
    guiGridListClear(aVehicle.List)
    guiSetProperty(aVehicle.List, "SortDirection", "None")
    if (groups) then
        local vehicles = {}
        for name, group in pairs(aVehicle.vehicles) do
            for _, vehicle in ipairs(group) do
                if vehicle.id:find(filter) or vehicle.name:lower():find(filter) then
                    if (not vehicles[name]) then
                        vehicles[name] = {}
                    end
                    table.insert(vehicles[name], vehicle)
                end
            end
        end
        for name, group in pairs(vehicles) do
            local row = guiGridListAddRow(aVehicle.List)
            guiGridListSetItemText(aVehicle.List, row, 2, name, true, false)
            for id, vehicle in ipairs(group) do
                guiGridListAddRow(aVehicle.List, vehicle.id, vehicle.name)
            end
        end
        guiGridListSetSortingEnabled(aVehicle.List, false)
    else
        local vehicles = {}
        for name, group in pairs(aVehicle.vehicles) do
            for id, vehicle in pairs(group) do
                vehicles[vehicle.id] = vehicle.name
            end
        end
        for model, vehicleName in pairs(vehicles) do
            if model:find(filter) or vehicleName:lower():find(filter:lower()) then
                local row = guiGridListAddRow(aVehicle.List)
                guiGridListSetItemText(aVehicle.List, row, 1, model, false, true)
                guiGridListSetItemText(aVehicle.List, row, 2, vehicleName, false, false)
            end
        end
        guiGridListSetSortingEnabled(aVehicle.List, true)
        guiSetProperty(aVehicle.List, "SortDirection", sortDirection)
    end
end
