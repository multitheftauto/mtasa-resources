--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_vehicle_upgrades.lua
*
*	Original File by lil_Toady
*
**************************************]]
aVehicleUpgrades = {
    Form = nil,
    Upgrades = {},
    Names = {},
    Last = nil
}

function aVehicleUpgrades.Open(player, vehicle)
    if (not aVehicleUpgrades.Form) then
        local x, y = guiGetScreenSize()
        aVehicleUpgrades.Form = guiCreateWindow(x / 2 - 300, y / 2 - 150, 600, 450, "Vehicle Customizations", false)

        aVehicleUpgrades.Names = {}
        local node = xmlLoadFile("conf\\upgrades.xml")
        if (node) then
            local upgrades = 0
            while (xmlFindChild(node, "upgrade", upgrades) ~= false) do
                local upgrade = xmlFindChild(node, "upgrade", upgrades)
                local id = tonumber(xmlNodeGetAttribute(upgrade, "id"))
                local name = xmlNodeGetAttribute(upgrade, "name")
                aVehicleUpgrades.Names[id] = name
                upgrades = upgrades + 1
            end
        end

        local c = 1
        for i = 1, 17 do
            if (i ~= 12) then
                guiCreateLabel(
                    0.05,
                    0.05 * (c + 1),
                    0.15,
                    0.05,
                    getVehicleUpgradeSlotName(i - 1) .. ":",
                    true,
                    aVehicleUpgrades.Form
                )
                aVehicleUpgrades.Upgrades[c] = {}
                aVehicleUpgrades.Upgrades[c].id = i - 1
                aVehicleUpgrades.Upgrades[c].combo =
                    guiCreateComboBox(0.25, 0.05 * (c + 1), 0.27, 0.248, "None", true, aVehicleUpgrades.Form)
                aVehicleUpgrades.Upgrades[c].label =
                    guiCreateLabel(0.54, 0.05 * (c + 1), 0.05, 0.07, "(0)", true, aVehicleUpgrades.Form)
                c = c + 1
            end
        end

        aVehicleUpgrades.UpgradeAll = guiCreateButton(0.04, 0.92, 0.15, 0.05, "Upgrade all", true, aVehicleUpgrades.Form)
        aVehicleUpgrades.RemoveAll = guiCreateButton(0.20, 0.92, 0.15, 0.05, "Remove All", true, aVehicleUpgrades.Form)
        aVehicleUpgrades.Upgrade = guiCreateButton(0.375, 0.92, 0.20, 0.05, "Upgrade", true, aVehicleUpgrades.Form)

        guiCreateStaticImage(0.60, 0.10, 0.002, 0.80, "client\\images\\dot.png", true, aVehicleUpgrades.Form)

        guiCreateLabel(0.63, 0.10, 0.15, 0.05, "Paint job:", true, aVehicleUpgrades.Form)
        aVehicleUpgrades.Paintjob = guiCreateComboBox(0.79, 0.10, 0.09, 0.25, "0", true, aVehicleUpgrades.Form)
        for i=0,3 do
            iprint(i, guiComboBoxAddItem(aVehicleUpgrades.Paintjob, tostring(i)))
        end

        aVehicleUpgrades.PaintjobSet = guiCreateButton(0.90, 0.10, 0.07, 0.048, "Set", true, aVehicleUpgrades.Form)
        guiCreateLabel(0.63, 0.15, 0.15, 0.05, "Vehicle Color:", true, aVehicleUpgrades.Form)
        guiCreateLabel(0.63, 0.20, 0.15, 0.05, "Color1:", true, aVehicleUpgrades.Form)
        guiCreateLabel(0.63, 0.25, 0.15, 0.05, "Color2:", true, aVehicleUpgrades.Form)
        guiCreateLabel(0.63, 0.30, 0.15, 0.05, "Color3:", true, aVehicleUpgrades.Form)
        guiCreateLabel(0.63, 0.35, 0.15, 0.05, "Color4:", true, aVehicleUpgrades.Form)
        aVehicleUpgrades.Color1 = guiCreateEdit(0.79, 0.20, 0.09, 0.048, "0", true, aVehicleUpgrades.Form)
        guiEditSetMaxLength(aVehicleUpgrades.Color1, 3)
        aVehicleUpgrades.Color2 = guiCreateEdit(0.79, 0.25, 0.09, 0.048, "0", true, aVehicleUpgrades.Form)
        guiEditSetMaxLength(aVehicleUpgrades.Color2, 3)
        aVehicleUpgrades.Color3 = guiCreateEdit(0.79, 0.30, 0.09, 0.048, "0", true, aVehicleUpgrades.Form)
        guiEditSetMaxLength(aVehicleUpgrades.Color3, 3)
        aVehicleUpgrades.Color4 = guiCreateEdit(0.79, 0.35, 0.09, 0.048, "0", true, aVehicleUpgrades.Form)
        guiEditSetMaxLength(aVehicleUpgrades.Color4, 3)
        guiCreateLabel(0.90, 0.20, 0.08, 0.05, "(0-126)", true, aVehicleUpgrades.Form)
        guiCreateLabel(0.90, 0.25, 0.08, 0.05, "(0-126)", true, aVehicleUpgrades.Form)
        guiCreateLabel(0.90, 0.30, 0.08, 0.05, "(0-126)", true, aVehicleUpgrades.Form)
        guiCreateLabel(0.90, 0.35, 0.08, 0.05, "(0-126)", true, aVehicleUpgrades.Form)
        aVehicleUpgrades.ColorScheme = guiCreateButton(0.63, 0.41, 0.20, 0.05, "View color IDs", true, aVehicleUpgrades.Form)
        aVehicleUpgrades.ColorSet = guiCreateButton(0.84, 0.41, 0.14, 0.05, "Set", true, aVehicleUpgrades.Form)
        aVehicleUpgrades.UpgradeNames =
            guiCreateCheckBox(0.63, 0.60, 0.30, 0.04, "Show upgrade names", false, true, aVehicleUpgrades.Form)
        if (aGetSetting("aVehicleUpgrades.UpgradeNames")) then
            guiCheckBoxSetSelected(aVehicleUpgrades.UpgradeNames, true)
        end
        aVehicleUpgrades.Close = guiCreateButton(0.86, 0.92, 0.19, 0.05, "Close", true, aVehicleUpgrades.Form)

        aVehicleUpgrades.ColorForm = guiCreateWindow(x / 2 - 280, y / 2 - 150, 540, 215, "Vehicle Color Scheme", false)
        guiCreateStaticImage(0.01, 0.08, 0.98, 0.80, "client\\images\\colorscheme.png", true, aVehicleUpgrades.ColorForm)
        aVehicleUpgrades.ColorClose = guiCreateButton(0.86, 0.86, 0.19, 0.15, "Close", true, aVehicleUpgrades.ColorForm)
        guiSetVisible(aVehicleUpgrades.ColorForm, false)
        guiSetVisible(aVehicleUpgrades.Form, false)

        addEventHandler("onClientGUIClick", aVehicleUpgrades.Form, aVehicleUpgrades.onClick)
        addEventHandler("onClientGUIClick", aVehicleUpgrades.ColorClose, aVehicleUpgrades.onClick)
        --Register With Admin Form
        aRegister("VehicleCustomize", aVehicleUpgrades.Form, aVehicleUpgrades.Customize, aVehicleUpgrades.CustomizeClose)
    end
    if (vehicle) then
        local update = true
        if (isElement(aVehicleUpgrades.Last)) then
            if (getElementModel(aVehicleUpgrades.Last) == getElementModel(vehicle)) then
                update = false
            end
        end
        guiSetText(aVehicleUpgrades.Form, "Vehicle Customizations (" .. tostring(getVehicleName(vehicle)) .. ")")
        aVehicleUpgrades.Last = vehicle
        if (update) then
            aVehicleUpgrades.CheckUpgrades(vehicle)
        end
        aVehicleUpgrades.CheckCurrentUpgrades(vehicle)
        aVehicleUpgrades.CustomizeVehicle = vehicle
        aVehicleUpgrades.CustomizePlayer = player
        guiSetVisible(aVehicleUpgrades.Form, true)
        guiBringToFront(aVehicleUpgrades.Form)
    end
end

function aVehicleUpgrades.CustomizeClose(destroy)
    if (destroy) then
        if (aVehicleUpgrades.Form) then
            removeEventHandler("onClientGUIClick", aVehicleUpgradesForm, aClientVehicleClick)
            removeEventHandler("onClientGUIDoubleClick", aVehicleUpgradesForm, aClientVehicleDoubleClick)
            removeEventHandler("onClientGUIClick", aVehicleUpgrades.ColorClose, aClientVehicleClick)
            destroyElement(aVehicleUpgrades.Form)
            destroyElement(aVehicleUpgrades.ColorForm)
            aVehicleUpgrades.CustomizePlayer = nil
            aVehicleUpgrades.CustomizeVehicle = nil
            aVehicleUpgradesForm = nil
            aVehicleUpgrades.Upgrades = {}
        end
    else
        guiSetVisible(aVehicleUpgrades.Form, false)
        guiSetVisible(aVehicleUpgrades.ColorForm, false)
    end
end

function aVehicleUpgrades.CheckUpgrades(vehicle)
    if (vehicle) then
        for slot, v in ipairs(aVehicleUpgrades.Upgrades) do
            guiComboBoxClear(aVehicleUpgrades.Upgrades[slot].combo)
            local row = guiComboBoxAddItem(aVehicleUpgrades.Upgrades[slot].combo, "None")

            local upgrades = getVehicleCompatibleUpgrades(vehicle, aVehicleUpgrades.Upgrades[slot].id)
            guiSetText(aVehicleUpgrades.Upgrades[slot].label, "(" .. #upgrades .. ")")
            guiSetText(aVehicleUpgrades.Upgrades[slot].combo, "None")
            if (getVehicleUpgradeOnSlot(vehicle, aVehicleUpgrades.Upgrades[slot].id) > 0) then
                if (guiCheckBoxGetSelected(aVehicleUpgrades.UpgradeNames)) then
                    guiSetText(
                        aVehicleUpgrades.Upgrades[slot].combo,
                        tostring(aVehicleUpgrades.Names[getVehicleUpgradeOnSlot(vehicle, aVehicleUpgrades.Upgrades[slot].id)])
                    )
                else
                    guiSetText(
                        aVehicleUpgrades.Upgrades[slot].combo,
                        tostring(getVehicleUpgradeOnSlot(vehicle, aVehicleUpgrades.Upgrades[slot].id))
                    )
                end
            end
            for i, upgrade in ipairs(upgrades) do
                if (guiCheckBoxGetSelected(aVehicleUpgrades.UpgradeNames)) then
                    guiComboBoxAddItem(aVehicleUpgrades.Upgrades[slot].combo, tostring(aVehicleUpgrades.Names[tonumber(upgrade)]))
                else
                    guiComboBoxAddItem(aVehicleUpgrades.Upgrades[slot].combo, tostring(upgrade))
                end
            end
        end
    end
end

function aVehicleUpgrades.CheckCurrentUpgrades(vehicle)
    if (vehicle) then
        for slot, v in ipairs(aVehicleUpgrades.Upgrades) do
            if (getVehicleUpgradeOnSlot(vehicle, aVehicleUpgrades.Upgrades[slot].id) > 0) then
                if (guiCheckBoxGetSelected(aVehicleUpgrades.UpgradeNames)) then
                    guiSetText(
                        aVehicleUpgrades.Upgrades[slot].combo,
                        tostring(aVehicleUpgrades.Names[getVehicleUpgradeOnSlot(vehicle, aVehicleUpgrades.Upgrades[slot].id)])
                    )
                else
                    guiSetText(
                        aVehicleUpgrades.Upgrades[slot].combo,
                        tostring(getVehicleUpgradeOnSlot(vehicle, aVehicleUpgrades.Upgrades[slot].id))
                    )
                end
            else
                guiSetText(aVehicleUpgrades.Upgrades[slot].combo, "")
            end
        end
    end
end

function aGetVehicleUpgradeFromName(uname)
    for id, name in pairs(aVehicleUpgrades.Names) do
        if (name == uname) then
            return id
        end
    end
    return false
end

function aVehicleUpgrades.onClick(button, state)
    if (button == "left") then
        if (source == aVehicleUpgrades.Close) then
            aVehicleUpgrades.CustomizeClose(false)
        elseif (source == aVehicleUpgrades.ColorClose) then
            guiSetVisible(aVehicleUpgrades.ColorForm, false)
        elseif (source == aVehicleUpgrades.ColorSet) then
            triggerServerEvent(
                "aVehicle",
                getLocalPlayer(),
                aVehicleUpgrades.CustomizePlayer,
                "setcolor",
                {
                    guiGetText(aVehicleUpgrades.Color1),
                    guiGetText(aVehicleUpgrades.Color2),
                    guiGetText(aVehicleUpgrades.Color3),
                    guiGetText(aVehicleUpgrades.Color4)
                }
            )
        elseif (source == aVehicleUpgrades.ColorScheme) then
            guiSetVisible(aVehicleUpgrades.ColorForm, true)
            guiBringToFront(aVehicleUpgrades.ColorForm)
        elseif (source == aVehicleUpgrades.UpgradeAll) then
            triggerServerEvent("aVehicle", getLocalPlayer(), aVehicleUpgrades.CustomizePlayer, "customize", {"all"})
            setTimer(aVehicleUpgrades.CheckCurrentUpgrades, 2000, 1, aVehicleUpgrades.CustomizeVehicle)
        elseif (source == aVehicleUpgrades.RemoveAll) then
            triggerServerEvent("aVehicle", getLocalPlayer(), aVehicleUpgrades.CustomizePlayer, "customize", {"remove"})
            setTimer(aVehicleUpgrades.CheckCurrentUpgrades, 2000, 1, aVehicleUpgrades.CustomizeVehicle)
        elseif (source == aVehicleUpgrades.PaintjobSet) then
            triggerServerEvent(
                "aVehicle",
                getLocalPlayer(),
                aVehicleUpgrades.CustomizePlayer,
                "setpaintjob",
                tonumber(guiComboBoxGetItemText(aVehicleUpgrades.Paintjob, guiComboBoxGetSelected(aVehicleUpgrades.Paintjob)))
            )
        elseif (source == aVehicleUpgrades.UpgradeNames) then
            aVehicleUpgrades.CheckUpgrades(aVehicleUpgrades.CustomizeVehicle)
            aSetSetting("aVehicleUpgrades.UpgradeNames", guiCheckBoxGetSelected(aVehicleUpgrades.UpgradeNames))
        elseif (source == aVehicleUpgrades.Upgrade) then
            local tableOut = {}
            for id, element in ipairs(aVehicleUpgrades.Upgrades) do
                local upgrade = guiComboBoxGetItemText(element.combo, guiComboBoxGetSelected(element.combo))
                if (upgrade) and (upgrade ~= "") then
                    if (guiCheckBoxGetSelected(aVehicleUpgrades.UpgradeNames)) then
                        local upgrade = aGetVehicleUpgradeFromName(upgrade)
                        if (upgrade) then
                            table.insert(tableOut, upgrade)
                        end
                    else
                        table.insert(tableOut, tonumber(upgrade))
                    end
                end
            end
            triggerServerEvent("aVehicle", getLocalPlayer(), aVehicleUpgrades.CustomizePlayer, "customize", tableOut)
            setTimer(aVehicleUpgrades.CheckCurrentUpgrades, 2000, 1, aVehicleUpgrades.CustomizeVehicle)
        end
    end
end
