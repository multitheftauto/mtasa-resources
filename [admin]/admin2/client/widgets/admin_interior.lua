--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_interior.lua
*
*	Original File by lil_Toady
*
**************************************]]
aInterior = {
    Form = nil,
    interiors = {}
}

function aInterior.Show(player)
    if (aInterior.Form == nil) then
        local x, y = guiGetScreenSize()
        aInterior.Form = guiCreateWindow(x / 2 - 110, y / 2 - 150, 220, 300, "Player Interior Management", false)
        guiSetAlpha(aInterior.Form, 1)
        guiSetProperty(aInterior.Form, 'AlwaysOnTop', 'True')
        aInterior.List = guiCreateGridList(0.03, 0.17, 0.94, 0.65, true, aInterior.Form)
        guiGridListAddColumn(aInterior.List, "World", 0.2)
        guiGridListAddColumn(aInterior.List, "Description", 0.75)
        aInterior.Edit = guiCreateEdit(0.03, 0.08, 0.94, 0.08, '', true, aInterior.Form)
        aInterior.Select = guiCreateButton(0.03, 0.82, 0.94, 0.075, "Select", true, aInterior.Form)
        aInterior.Cancel = guiCreateButton(0.03, 0.90, 0.94, 0.075, "Cancel", true, aInterior.Form)

        aInterior.Load()
        aInterior.Refresh()

        addEventHandler("onClientGUIDoubleClick", aInterior.Form, aInterior.onDoubleClick)
        addEventHandler("onClientGUIClick", aInterior.Form, aInterior.onClick)
        addEventHandler("onClientGUIChanged", aInterior.Form, aInterior.onGUIChange)

        --Register With Admin Form
        aRegister("PlayerInterior", aInterior.Form, aInterior.Show, aInterior.Close)
    end
    aInterior.SelectPointer = player
    guiSetVisible(aInterior.Form, true)
    guiBringToFront(aInterior.Form)
end

function aInterior.Close(destroy)
    if (destroy) then
        aInterior.interiors = {}
        if (aInterior.Form) then
            removeEventHandler("onClientGUIDoubleClick", aInterior.Form, aInterior.onDoubleClick)
            removeEventHandler("onClientGUIClick", aInterior.Form, aInterior.onClick)
            destroyElement(aInterior.Form)
            aInterior.Form = nil
        end
    else
        guiSetVisible(aInterior.Form, false)
    end
end

function aInterior.onDoubleClick(button)
    if (button == "left") then
        if (source == aInterior.List) then
            if (guiGridListGetSelectedItem(aInterior.List) ~= -1) then
                triggerServerEvent(
                    "aPlayer",
                    localPlayer,
                    aInterior.SelectPointer,
                    "setinterior",
                    guiGridListGetItemText(aInterior.List, guiGridListGetSelectedItem(aInterior.List), 2)
                )
                aInterior.Close(false)
            end
        end
    end
end

function aInterior.onGUIChange()
    aInterior.Refresh()
end

function aInterior.onClick(button)
    if (button == "left") then
        if (source == aInterior.Select) then
            if (guiGridListGetSelectedItem(aInterior.List) ~= -1) then
                triggerServerEvent(
                    "aPlayer",
                    localPlayer,
                    aInterior.SelectPointer,
                    "setinterior",
                    guiGridListGetItemText(aInterior.List, guiGridListGetSelectedItem(aInterior.List), 2)
                )
                guiSetVisible(aInterior.Form, false)
            end
        elseif (source == aInterior.Cancel) then
            aInterior.Close(false)
        end
    end
end

function aInterior.Load()
    local table = {}
    local node = xmlLoadFile("conf\\interiors.xml")
    if (node) then
        local interiors = 0
        while (xmlFindChild(node, "interior", interiors) ~= false) do
            local interior = xmlFindChild(node, "interior", interiors)
            local id = #table + 1
            table[id] = {}
            table[id]["id"] = xmlNodeGetAttribute(interior, "id")
            table[id]["world"] = xmlNodeGetAttribute(interior, "world")
            interiors = interiors + 1
        end
    end
    aInterior.interiors = table
end

function aInterior.Refresh()
    local filter = guiGetText(aInterior.Edit):lower()
    local sortDirection = guiGetProperty(aInterior.List, "SortDirection")
    guiGridListClear(aInterior.List)
    guiSetProperty(aInterior.List, "SortDirection", "None")
    for k, v in ipairs(aInterior.interiors) do
        if v.world:find(filter) or v.id:lower():find(filter) then
            local row = guiGridListAddRow(aInterior.List)
            guiGridListSetItemText(aInterior.List, row, 1, v.world, false, true)
            guiGridListSetItemText(aInterior.List, row, 2, v.id, false, false)
        end
    end
    guiSetProperty(aInterior.List, "SortDirection", sortDirection)
end
