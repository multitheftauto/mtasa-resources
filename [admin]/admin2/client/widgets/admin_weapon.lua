--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\main\admin_weapon.lua
*
*	Original File by jlillis
*
**************************************]]
local DEFAULT_AMMO_AMOUNT = 300

aWeapon = {
    Form = nil,
    weapons = {}
}

function aWeapon.Show(player)
    if (aWeapon.Form == nil) then
        local x, y = guiGetScreenSize()
        aWeapon.Form = guiCreateWindow(x / 2 - 140, y / 2 - 140, 280, 280, "Player Weapon Select", false)
        guiSetAlpha(aWeapon.Form, 1)
        guiSetProperty(aWeapon.Form, 'AlwaysOnTop', 'True')
        aWeapon.Label =
            guiCreateLabel(0.03, 0.09, 0.94, 0.07, "Select a weapon from the list or enter the id", true, aWeapon.Form)
        guiLabelSetHorizontalAlign(aWeapon.Label, "center")
        guiLabelSetColor(aWeapon.Label, 255, 0, 0)
        
        aWeapon.Edit = guiCreateEdit(0.03, 0.18, 0.70, 0.09, '', true, aWeapon.Form)
        guiCreateInnerImage("client\\images\\search.png", aWeapon.Edit)

        aWeapon.Groups = guiCreateCheckBox(0.03, 0.90, 0.70, 0.09, "Sort by groups", false, true, aWeapon.Form)
        if (aGetSetting("weaponsGroup")) then
            guiCheckBoxSetSelected(aWeapon.Groups, true)
        end

        aWeapon.List = guiCreateGridList(0.03, 0.27, 0.70, 0.625, true, aWeapon.Form)
        guiGridListAddColumn(aWeapon.List, "ID", 0.20)
        guiGridListAddColumn(aWeapon.List, "", 0.75)

        aWeapon.ID = guiCreateEdit(0.75, 0.18, 0.27, 0.09, "0", true, aWeapon.Form)
        guiEditSetMaxLength(aWeapon.ID, 3)

        Weapon.AmmoLabel =
            guiCreateLabel(0.75, 0.45, 0.27, 0.07, "Ammo:", true, aWeapon.Form)
        guiSetFont(Weapon.AmmoLabel, "default-bold-small")
        aWeapon.Ammo = guiCreateEdit(0.75, 0.53, 0.27, 0.09, DEFAULT_AMMO_AMOUNT, true, aWeapon.Form)

        aWeapon.Accept = guiCreateButton(0.75, 0.28, 0.27, 0.09, "Select", true, aWeapon.Form, "giveweapon")
        aWeapon.Cancel = guiCreateButton(0.75, 0.88, 0.27, 0.09, "Cancel", true, aWeapon.Form)

        aWeapon.Load()
        aWeapon.Refresh()

        addEventHandler("onClientGUIClick", aWeapon.Form, aWeapon.onClick)
        addEventHandler("onClientGUIDoubleClick", aWeapon.Form, aWeapon.onDoubleClick)
        addEventHandler("onClientGUIChanged", aWeapon.Form, aWeapon.onGUIChange)

        --Register With Admin Form
        aRegister("PlayerWeapon", aWeapon.Form, aWeapon.Show, aWeapon.Close)
    end

    aWeapon.Select = player
    guiSetVisible(aWeapon.Form, true)
    guiBringToFront(aWeapon.Form)
end

function aWeapon.Close(destroy)
    if (destroy) then
        aWeapon.weapons = {}
        if (aWeapon.Form) then
            removeEventHandler("onClientGUIClick", aWeapon.Form, aWeapon.onClick)
            removeEventHandler("onClientGUIDoubleClick", aWeapon.Form, aWeapon.onDoubleClick)
            destroyElement(aWeapon.Form)
            aWeapon.Form = nil
        end
    else
        guiSetVisible(aWeapon.Form, false)
    end
end

function aWeapon.onDoubleClick(button)
    if (button == "left") then
        if (source == aWeapon.List) then
            if (guiGridListGetSelectedItem(aWeapon.List) ~= -1) then
                local id = tonumber(guiGridListGetItemText(aWeapon.List, guiGridListGetSelectedItem(aWeapon.List), 1))
                local ammo = tonumber(guiGetText(aWeapon.Ammo)) or DEFAULT_AMMO_AMOUNT
                triggerServerEvent("aPlayer", localPlayer, aWeapon.Select, "giveweapon", id, ammo)
                aWeapon.Close(false)
            end
        end
    end
end

function aWeapon.onGUIChange()
    if (source == aWeapon.Edit) then
        aWeapon.Refresh()
    end
end

function aWeapon.onClick(button)
    if (button == "left") then
        if (source == aWeapon.Accept) then
            if (tonumber(guiGetText(aWeapon.ID))) then
                local ammo = tonumber(guiGetText(aWeapon.Ammo)) or DEFAULT_AMMO_AMOUNT
                triggerServerEvent("aPlayer", localPlayer, aWeapon.Select, "giveweapon", tonumber(guiGetText(aWeapon.ID)), ammo)
                aWeapon.Close(false)
            else
                if (guiGridListGetSelectedItem(aWeapon.List) ~= -1) then
                    local id = tonumber(guiGridListGetItemText(aWeapon.List, guiGridListGetSelectedItem(aWeapon.List), 1))
                    local ammo = tonumber(guiGetText(aWeapon.Ammo)) or DEFAULT_AMMO_AMOUNT
                    guiSetVisible(aWeapon.Form, false)
                    triggerServerEvent("aPlayer", localPlayer, aWeapon.Select, "giveweapon", id, ammo)
                else
                    messageBox("No weapon selected!", MB_ERROR, MB_OK)
                end
            end
        elseif (source == aWeapon.List) then
            if (guiGridListGetSelectedItem(aWeapon.List) ~= -1) then
                local id = guiGridListGetItemText(aWeapon.List, guiGridListGetSelectedItem(aWeapon.List), 1)
                guiSetText(aWeapon.ID, id)
            end
        elseif (source == aWeapon.Cancel) then
            aWeapon.Close(false)
        elseif (source == aWeapon.Groups) then
            aWeapon.Refresh()
        end
    end
end

function aWeapon.Load()
    local table = {}
    local node = xmlLoadFile("conf\\weapons.xml")
    if (node) then
        local groups = 0
        while (xmlFindChild(node, "group", groups) ~= false) do
            local group = xmlFindChild(node, "group", groups)
            local groupn = xmlNodeGetAttribute(group, "name")
            table[groupn] = {}
            local weapons = 0
            while (xmlFindChild(group, "weapon", weapons) ~= false) do
                local weapon = xmlFindChild(group, "weapon", weapons)
                local id = #table[groupn] + 1
                table[groupn][id] = {}
                table[groupn][id]["id"] = xmlNodeGetAttribute(weapon, "id")
                table[groupn][id]["name"] = xmlNodeGetAttribute(weapon, "name")
                weapons = weapons + 1
            end
            groups = groups + 1
        end
    end
    aWeapon.weapons = table
end

function aWeapon.Refresh()
    local groups = guiCheckBoxGetSelected(aWeapon.Groups)
    local filter = guiGetText(aWeapon.Edit):lower()
    local sortDirection = guiGetProperty(aWeapon.List, "SortDirection")
    aSetSetting("weaponsGroup", groups)
    guiGridListClear(aWeapon.List)
    guiSetProperty(aWeapon.List, "SortDirection", "None")
    if (groups) then
        local weapons = {}
        for name, group in pairs(aWeapon.weapons) do
            for _, vehicle in ipairs(group) do
                if vehicle.id:find(filter) or vehicle.name:lower():find(filter) then
                    if (not weapons[name]) then
                        weapons[name] = {}
                    end
                    table.insert(weapons[name], vehicle)
                end
            end
        end
        for name, group in pairs(weapons) do
            local row = guiGridListAddRow(aWeapon.List)
            guiGridListSetItemText(aWeapon.List, row, 2, name, true, false)
            for id, weapon in ipairs(group) do
                guiGridListAddRow(aWeapon.List, weapon.id, weapon.name)
            end
        end
        guiGridListSetSortingEnabled(aWeapon.List, false)
    else
        local weapons = {}
        for name, group in pairs(aWeapon.weapons) do
            for id, weapon in pairs(group) do
                weapons[weapon.id] = weapon.name
            end
        end
        for id, weaponName in pairs(weapons) do
            if id:find(filter) or weaponName:lower():find(filter) then
                local row = guiGridListAddRow(aWeapon.List)
                guiGridListSetItemText(aWeapon.List, row, 1, id, false, true)
                guiGridListSetItemText(aWeapon.List, row, 2, weaponName, false, false)
            end
        end
        guiGridListSetSortingEnabled(aWeapon.List, true)
        guiSetProperty(aWeapon.List, "SortDirection", sortDirection)
    end
end
