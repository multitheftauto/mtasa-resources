--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_stats.lua
*
*	Original File by lil_Toady
*
**************************************]]
aVehicle = {
    Form = nil,
    Upgrades = {},
    Names = {},
    Last = nil
}

function aVehicle.Open(vehicle)
    if (not aVehicle.Form) then
        local x, y = guiGetScreenSize()
        aVehicle.Form = guiCreateWindow(x / 2 - 300, y / 2 - 150, 600, 450, "Vehicle Customizations", false)

        aVehicle.Names = {}
        local node = xmlLoadFile("conf\\upgrades.xml")
        if (node) then
            local upgrades = 0
            while (xmlFindChild(node, "upgrade", upgrades) ~= false) do
                local upgrade = xmlFindChild(node, "upgrade", upgrades)
                local id = tonumber(xmlNodeGetAttribute(upgrade, "id"))
                local name = xmlNodeGetAttribute(upgrade, "name")
                aVehicle.Names[id] = name
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
                    aVehicle.Form
                )
                aVehicle.Upgrades[c] = {}
                aVehicle.Upgrades[c].id = i - 1
                aVehicle.Upgrades[c].combo =
                    guiCreateComboBox(0.25, 0.05 * (c + 1), 0.27, 0.248, "None", true, aVehicle.Form)
                aVehicle.Upgrades[c].label =
                    guiCreateLabel(0.54, 0.05 * (c + 1), 0.05, 0.07, "(0)", true, aVehicle.Form)
                c = c + 1
            end
        end

        aVehicle.UpgradeAll = guiCreateButton(0.04, 0.92, 0.15, 0.05, "Total pimp", true, aVehicle.Form)
        aVehicle.RemoveAll = guiCreateButton(0.20, 0.92, 0.15, 0.05, "Remove All", true, aVehicle.Form)
        aVehicle.Upgrade = guiCreateButton(0.375, 0.92, 0.20, 0.05, "Pimp", true, aVehicle.Form)

        guiCreateStaticImage(0.60, 0.10, 0.002, 0.80, "client\\images\\dot.png", true, aVehicle.Form)

        guiCreateLabel(0.63, 0.10, 0.15, 0.05, "Paint job:", true, aVehicle.Form)
        aVehicle.Paintjob = guiCreateEdit(0.79, 0.10, 0.09, 0.048, "0", true, aVehicle.Form)
        aVehicle.PaintjobDrop =
            guiCreateStaticImage(0.845, 0.10, 0.035, 0.048, "client\\images\\dropdown.png", true, aVehicle.Form)
        aVehicle.PaintjobList = guiCreateGridList(0.79, 0.10, 0.09, 0.25, true, aVehicle.Form)
        guiEditSetReadOnly(aVehicle.Paintjob, true)
        guiGridListAddColumn(aVehicle.PaintjobList, "", 0.65)
        guiSetVisible(aVehicle.PaintjobList, false)

        for i = 0, 3 do
            guiGridListSetItemText(
                aVehicle.PaintjobList,
                guiGridListAddRow(aVehicle.PaintjobList),
                1,
                tostring(i),
                false,
                false
            )
        end

        aVehicle.PaintjobSet = guiCreateButton(0.90, 0.10, 0.07, 0.048, "Set", true, aVehicle.Form)
        guiCreateLabel(0.63, 0.15, 0.15, 0.05, "Vehicle Color:", true, aVehicle.Form)
        guiCreateLabel(0.63, 0.20, 0.15, 0.05, "Color1:", true, aVehicle.Form)
        guiCreateLabel(0.63, 0.25, 0.15, 0.05, "Color2:", true, aVehicle.Form)
        guiCreateLabel(0.63, 0.30, 0.15, 0.05, "Color3:", true, aVehicle.Form)
        guiCreateLabel(0.63, 0.35, 0.15, 0.05, "Color4:", true, aVehicle.Form)
        aVehicle.Color1 = guiCreateEdit(0.79, 0.20, 0.09, 0.048, "0", true, aVehicle.Form)
        guiEditSetMaxLength(aVehicle.Color1, 3)
        aVehicle.Color2 = guiCreateEdit(0.79, 0.25, 0.09, 0.048, "0", true, aVehicle.Form)
        guiEditSetMaxLength(aVehicle.Color2, 3)
        aVehicle.Color3 = guiCreateEdit(0.79, 0.30, 0.09, 0.048, "0", true, aVehicle.Form)
        guiEditSetMaxLength(aVehicle.Color3, 3)
        aVehicle.Color4 = guiCreateEdit(0.79, 0.35, 0.09, 0.048, "0", true, aVehicle.Form)
        guiEditSetMaxLength(aVehicle.Color4, 3)
        guiCreateLabel(0.90, 0.20, 0.08, 0.05, "(0-126)", true, aVehicle.Form)
        guiCreateLabel(0.90, 0.25, 0.08, 0.05, "(0-126)", true, aVehicle.Form)
        guiCreateLabel(0.90, 0.30, 0.08, 0.05, "(0-126)", true, aVehicle.Form)
        guiCreateLabel(0.90, 0.35, 0.08, 0.05, "(0-126)", true, aVehicle.Form)
        aVehicle.ColorScheme = guiCreateButton(0.63, 0.41, 0.20, 0.05, "View color IDs", true, aVehicle.Form)
        aVehicle.ColorSet = guiCreateButton(0.84, 0.41, 0.14, 0.05, "Set", true, aVehicle.Form)
        aVehicle.UpgradeNames =
            guiCreateCheckBox(0.63, 0.60, 0.30, 0.04, "Show upgrade names", false, true, aVehicle.Form)
        if (aGetSetting("aVehicleUpgradeNames")) then
            guiCheckBoxSetSelected(aVehicle.UpgradeNames, true)
        end
        aVehicle.Close = guiCreateButton(0.86, 0.92, 0.19, 0.05, "Close", true, aVehicle.Form)

        aVehicle.ColorForm = guiCreateWindow(x / 2 - 280, y / 2 - 150, 540, 215, "Vehicle Color Scheme", false)
        guiCreateStaticImage(0.01, 0.08, 0.98, 0.80, "client\\images\\colorscheme.png", true, aVehicle.ColorForm)
        aVehicle.ColorClose = guiCreateButton(0.86, 0.86, 0.19, 0.15, "Close", true, aVehicle.ColorForm)
        guiSetVisible(aVehicle.ColorForm, false)
        guiSetVisible(aVehicle.Form, false)

        addEventHandler("onClientGUIClick", aVehicle.Form, aVehicle.onClick)
        addEventHandler("onClientGUIClick", aVehicle.ColorClose, aVehicle.onClick)
        --Register With Admin Form
        aRegister("VehicleCustomize", aVehicle.Form, aVehicle.Customize, aVehicle.CustomizeClose)
    end
    if (vehicle) then
        local update = true
        if (isElement(aVehicle.Last)) then
            if (getElementModel(aVehicle.Last) == getElementModel(vehicle)) then
                update = false
            end
        end
        guiSetText(aVehicle.Form, "Vehicle Customizations (" .. tostring(getVehicleName(vehicle)) .. ")")
        aVehicle.Last = vehicle
        if (update) then
            aVehicle.CheckUpgrades(vehicle)
        end
        aVehicle.CheckCurrentUpgrades(vehicle)
        guiSetVisible(aVehicle.Form, true)
        guiBringToFront(aVehicle.Form)
    end
end

function aVehicle.CustomizeClose(destroy)
    if (destroy) then
        if (aVehicle.Form) then
            removeEventHandler("onClientGUIClick", aVehicleForm, aClientVehicleClick)
            removeEventHandler("onClientGUIDoubleClick", aVehicleForm, aClientVehicleDoubleClick)
            removeEventHandler("onClientGUIClick", aVehicleColorClose, aClientVehicleClick)
            destroyElement(aVehicle.Form)
            destroyElement(aVehicle.ColorForm)
            aVehicleCustomizePlayer = nil
            aVehicleCustomizeVehicle = nil
            aVehicleForm = nil
            aVehicleUpgrades = {}
        end
    else
        guiSetVisible(aVehicle.Form, false)
        guiSetVisible(aVehicle.ColorForm, false)
    end
end

function aVehicle.CheckUpgrades(vehicle)
    if (vehicle) then
        for slot, v in ipairs(aVehicle.Upgrades) do
            guiComboBoxClear(aVehicle.Upgrades[slot].combo)
            local row = guiComboBoxAddItem(aVehicle.Upgrades[slot].combo, "None")

            local upgrades = getVehicleCompatibleUpgrades(vehicle, aVehicle.Upgrades[slot].id)
            guiSetText(aVehicle.Upgrades[slot].label, "(" .. #upgrades .. ")")
            guiSetText(aVehicle.Upgrades[slot].combo, "None")
            if (getVehicleUpgradeOnSlot(vehicle, aVehicle.Upgrades[slot].id) > 0) then
                if (guiCheckBoxGetSelected(aVehicle.UpgradeNames)) then
                    guiSetText(
                        aVehicle.Upgrades[slot].combo,
                        tostring(aUpgradeNames[getVehicleUpgradeOnSlot(vehicle, aVehicle.Upgrades[slot].id)])
                    )
                else
                    guiSetText(
                        aVehicle.Upgrades[slot].combo,
                        tostring(getVehicleUpgradeOnSlot(vehicle, aVehicle.Upgrades[slot].id))
                    )
                end
            end
            for i, upgrade in ipairs(upgrades) do
                if (guiCheckBoxGetSelected(aVehicle.UpgradeNames)) then
                    guiComboBoxAddItem(aVehicle.Upgrades[slot].combo, tostring(aVehicle.Names[tonumber(upgrade)]))
                else
                    guiComboBoxAddItem(aVehicle.Upgrades[slot].combo, tostring(upgrade))
                end
            end
        end
    end
end

function aVehicle.CheckCurrentUpgrades(vehicle)
    if (vehicle) then
        for slot, v in ipairs(aVehicle.Upgrades) do
            if (getVehicleUpgradeOnSlot(vehicle, aVehicle.Upgrades[slot].id) > 0) then
                if (guiCheckBoxGetSelected(aVehicle.UpgradeNames)) then
                    guiSetText(
                        aVehicle.Upgrades[slot].combo,
                        tostring(aVehicle.Names[getVehicleUpgradeOnSlot(vehicle, aVehicle.Upgrades[slot].id)])
                    )
                else
                    guiSetText(
                        aVehicle.Upgrades[slot].combo,
                        tostring(getVehicleUpgradeOnSlot(vehicle, aVehicle.Upgrades[slot].id))
                    )
                end
            else
                guiSetText(aVehicle.Upgrades[slot].combo, "")
            end
        end
    end
end

function aGetVehicleUpgradeFromName(uname)
    for id, name in pairs(aVehicle.Names) do
        if (name == uname) then
            return id
        end
    end
    return false
end

function aVehicle.onClick(button, state)
    if (source ~= aVehiclePaintjobList) then
        guiSetVisible(aVehiclePaintjobList, false)
    end
    if (button == "left") then
        if (source == aVehiclePaintjob) then
            guiBringToFront(aVehiclePaintjobDrop)
        elseif (source == aVehicleClose) then
            aVehicleCustomizeClose(false)
        elseif (source == aVehicleColorClose) then
            guiSetVisible(aVehicleColorForm, false)
        elseif (source == aVehicleColorSet) then
            triggerServerEvent(
                "aVehicle",
                getLocalPlayer(),
                aVehicleCustomizePlayer,
                "setcolor",
                {
                    guiGetText(aVehicleColor1),
                    guiGetText(aVehicleColor2),
                    guiGetText(aVehicleColor3),
                    guiGetText(aVehicleColor4)
                }
            )
        elseif (source == aVehicleColorScheme) then
            guiSetVisible(aVehicleColorForm, true)
            guiBringToFront(aVehicleColorForm)
        elseif (source == aVehicleUpgradeAll) then
            triggerServerEvent("aVehicle", getLocalPlayer(), aVehicleCustomizePlayer, "customize", {"all"})
            setTimer(aVehicleCheckCurrentUpgrades, 2000, 1, aVehicleCustomizeVehicle)
        elseif (source == aVehicleRemoveAll) then
            triggerServerEvent("aVehicle", getLocalPlayer(), aVehicleCustomizePlayer, "customize", {"remove"})
            setTimer(aVehicleCheckCurrentUpgrades, 2000, 1, aVehicleCustomizeVehicle)
        elseif (source == aVehiclePaintjobSet) then
            triggerServerEvent(
                "aVehicle",
                getLocalPlayer(),
                aVehicleCustomizePlayer,
                "setpaintjob",
                tonumber(guiGetText(aVehiclePaintjob))
            )
        elseif (source == aVehiclePaintjobDrop) then
            guiSetVisible(aVehiclePaintjobList, true)
            guiBringToFront(aVehiclePaintjobList)
        elseif (source == aVehicleUpgradeNames) then
            aVehicleCheckUpgrades(aVehicleCustomizeVehicle)
            aSetSetting("aVehicleUpgradeNames", guiCheckBoxGetSelected(aVehicleUpgradeNames))
        elseif (source == aVehicleUpgrade) then
            local tableOut = {}
            for id, element in ipairs(aVehicleUpgrades) do
                local upgrade = guiGetText(element.edit)
                if (upgrade) and (upgrade ~= "") then
                    if (guiCheckBoxGetSelected(aVehicleUpgradeNames)) then
                        local upgrade = aGetVehicleUpgradeFromName(upgrade)
                        if (upgrade) then
                            table.insert(tableOut, upgrade)
                        end
                    else
                        table.insert(tableOut, tonumber(upgrade))
                    end
                end
            end
            triggerServerEvent("aVehicle", getLocalPlayer(), aVehicleCustomizePlayer, "customize", tableOut)
            setTimer(aVehicleCheckCurrentUpgrades, 2000, 1, aVehicleCustomizeVehicle)
        end
    end
end
