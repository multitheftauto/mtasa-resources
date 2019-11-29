--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_vehicle_customization.lua
*
*	Original File by lil_Toady
*
**************************************]]
aVehicleCustomization = {
    Form = nil,
    Upgrades = {},
    Names = {},
    Last = nil
}

function aVehicleCustomization.Open(vehicle)
    if (not aVehicleCustomization.Form) then
        local x, y = guiGetScreenSize()
        aVehicleCustomization.Form = guiCreateWindow(x / 2 - 300, y / 2 - 150, 600, 450, "Vehicle Customizations", false)

        aVehicleCustomization.Names = {}
        local node = xmlLoadFile("conf\\upgrades.xml")
        if (node) then
            local upgrades = 0
            while (xmlFindChild(node, "upgrade", upgrades) ~= false) do
                local upgrade = xmlFindChild(node, "upgrade", upgrades)
                local id = tonumber(xmlNodeGetAttribute(upgrade, "id"))
                local name = xmlNodeGetAttribute(upgrade, "name")
                aVehicleCustomization.Names[id] = name
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
                    aVehicleCustomization.Form
                )
                aVehicleCustomization.Upgrades[c] = {}
                aVehicleCustomization.Upgrades[c].id = i - 1
                aVehicleCustomization.Upgrades[c].combo =
                    guiCreateComboBox(0.25, 0.05 * (c + 1), 0.27, 0.248, "None", true, aVehicleCustomization.Form)
                aVehicleCustomization.Upgrades[c].label =
                    guiCreateLabel(0.54, 0.05 * (c + 1), 0.05, 0.07, "(0)", true, aVehicleCustomization.Form)
                c = c + 1
            end
        end

        aVehicleCustomization.UpgradeAll = guiCreateButton(0.04, 0.92, 0.15, 0.05, "Total pimp", true, aVehicleCustomization.Form)
        aVehicleCustomization.RemoveAll = guiCreateButton(0.20, 0.92, 0.15, 0.05, "Remove All", true, aVehicleCustomization.Form)
        aVehicleCustomization.Upgrade = guiCreateButton(0.375, 0.92, 0.20, 0.05, "Pimp", true, aVehicleCustomization.Form)

        guiCreateStaticImage(0.60, 0.10, 0.002, 0.80, "client\\images\\dot.png", true, aVehicleCustomization.Form)

        guiCreateLabel(0.63, 0.10, 0.15, 0.05, "Paint job:", true, aVehicleCustomization.Form)
        aVehicleCustomization.Paintjob = guiCreateEdit(0.79, 0.10, 0.09, 0.048, "0", true, aVehicleCustomization.Form)
        aVehicleCustomization.PaintjobDrop =
            guiCreateStaticImage(0.845, 0.10, 0.035, 0.048, "client\\images\\dropdown.png", true, aVehicleCustomization.Form)
        aVehicleCustomization.PaintjobList = guiCreateGridList(0.79, 0.10, 0.09, 0.25, true, aVehicleCustomization.Form)
        guiEditSetReadOnly(aVehicleCustomization.Paintjob, true)
        guiGridListAddColumn(aVehicleCustomization.PaintjobList, "", 0.65)
        guiSetVisible(aVehicleCustomization.PaintjobList, false)

        for i = 0, 3 do
            guiGridListSetItemText(
                aVehicleCustomization.PaintjobList,
                guiGridListAddRow(aVehicleCustomization.PaintjobList),
                1,
                tostring(i),
                false,
                false
            )
        end

        aVehicleCustomization.PaintjobSet = guiCreateButton(0.90, 0.10, 0.07, 0.048, "Set", true, aVehicleCustomization.Form)
        guiCreateLabel(0.63, 0.15, 0.15, 0.05, "Vehicle Color:", true, aVehicleCustomization.Form)
        guiCreateLabel(0.63, 0.20, 0.15, 0.05, "Color1:", true, aVehicleCustomization.Form)
        guiCreateLabel(0.63, 0.25, 0.15, 0.05, "Color2:", true, aVehicleCustomization.Form)
        guiCreateLabel(0.63, 0.30, 0.15, 0.05, "Color3:", true, aVehicleCustomization.Form)
        guiCreateLabel(0.63, 0.35, 0.15, 0.05, "Color4:", true, aVehicleCustomization.Form)
        aVehicleCustomization.Color1 = guiCreateEdit(0.79, 0.20, 0.09, 0.048, "0", true, aVehicleCustomization.Form)
        guiEditSetMaxLength(aVehicleCustomization.Color1, 3)
        aVehicleCustomization.Color2 = guiCreateEdit(0.79, 0.25, 0.09, 0.048, "0", true, aVehicleCustomization.Form)
        guiEditSetMaxLength(aVehicleCustomization.Color2, 3)
        aVehicleCustomization.Color3 = guiCreateEdit(0.79, 0.30, 0.09, 0.048, "0", true, aVehicleCustomization.Form)
        guiEditSetMaxLength(aVehicleCustomization.Color3, 3)
        aVehicleCustomization.Color4 = guiCreateEdit(0.79, 0.35, 0.09, 0.048, "0", true, aVehicleCustomization.Form)
        guiEditSetMaxLength(aVehicleCustomization.Color4, 3)
        guiCreateLabel(0.90, 0.20, 0.08, 0.05, "(0-126)", true, aVehicleCustomization.Form)
        guiCreateLabel(0.90, 0.25, 0.08, 0.05, "(0-126)", true, aVehicleCustomization.Form)
        guiCreateLabel(0.90, 0.30, 0.08, 0.05, "(0-126)", true, aVehicleCustomization.Form)
        guiCreateLabel(0.90, 0.35, 0.08, 0.05, "(0-126)", true, aVehicleCustomization.Form)
        aVehicleCustomization.ColorScheme = guiCreateButton(0.63, 0.41, 0.20, 0.05, "View color IDs", true, aVehicleCustomization.Form)
        aVehicleCustomization.ColorSet = guiCreateButton(0.84, 0.41, 0.14, 0.05, "Set", true, aVehicleCustomization.Form)
        aVehicleCustomization.UpgradeNames =
            guiCreateCheckBox(0.63, 0.60, 0.30, 0.04, "Show upgrade names", false, true, aVehicleCustomization.Form)
        if (aGetSetting("aVehicleCustomizationUpgradeNames")) then
            guiCheckBoxSetSelected(aVehicleCustomization.UpgradeNames, true)
        end
        aVehicleCustomization.Close = guiCreateButton(0.86, 0.92, 0.19, 0.05, "Close", true, aVehicleCustomization.Form)

        aVehicleCustomization.ColorForm = guiCreateWindow(x / 2 - 280, y / 2 - 150, 540, 215, "Vehicle Color Scheme", false)
        guiCreateStaticImage(0.01, 0.08, 0.98, 0.80, "client\\images\\colorscheme.png", true, aVehicleCustomization.ColorForm)
        aVehicleCustomization.ColorClose = guiCreateButton(0.86, 0.86, 0.19, 0.15, "Close", true, aVehicleCustomization.ColorForm)
        guiSetVisible(aVehicleCustomization.ColorForm, false)
        guiSetVisible(aVehicleCustomization.Form, false)

        addEventHandler("onClientGUIClick", aVehicleCustomization.Form, aVehicleCustomization.onClick)
        addEventHandler("onClientGUIClick", aVehicleCustomization.ColorClose, aVehicleCustomization.onClick)
        --Register With Admin Form
        aRegister("VehicleCustomize", aVehicleCustomization.Form, aVehicleCustomization.Customize, aVehicleCustomization.CustomizeClose)
    end
    if (vehicle) then
        local update = true
        if (isElement(aVehicleCustomization.Last)) then
            if (getElementModel(aVehicleCustomization.Last) == getElementModel(vehicle)) then
                update = false
            end
        end
        guiSetText(aVehicleCustomization.Form, "Vehicle Customizations (" .. tostring(getVehicleName(vehicle)) .. ")")
        aVehicleCustomization.Last = vehicle
        if (update) then
            aVehicleCustomization.CheckUpgrades(vehicle)
        end
        aVehicleCustomization.CheckCurrentUpgrades(vehicle)
        guiSetVisible(aVehicleCustomization.Form, true)
        guiBringToFront(aVehicleCustomization.Form)
    end
end

function aVehicleCustomization.CustomizeClose(destroy)
    if (destroy) then
        if (aVehicleCustomization.Form) then
            removeEventHandler("onClientGUIClick", aVehicleCustomizationForm, aClientVehicleClick)
            removeEventHandler("onClientGUIDoubleClick", aVehicleCustomizationForm, aClientVehicleDoubleClick)
            removeEventHandler("onClientGUIClick", aVehicleCustomizationColorClose, aClientVehicleClick)
            destroyElement(aVehicleCustomization.Form)
            destroyElement(aVehicleCustomization.ColorForm)
            aVehicleCustomizationCustomizePlayer = nil
            aVehicleCustomizationCustomizeVehicle = nil
            aVehicleCustomizationForm = nil
            aVehicleCustomizationUpgrades = {}
        end
    else
        guiSetVisible(aVehicleCustomization.Form, false)
        guiSetVisible(aVehicleCustomization.ColorForm, false)
    end
end

function aVehicleCustomization.CheckUpgrades(vehicle)
    if (vehicle) then
        for slot, v in ipairs(aVehicleCustomization.Upgrades) do
            guiComboBoxClear(aVehicleCustomization.Upgrades[slot].combo)
            local row = guiComboBoxAddItem(aVehicleCustomization.Upgrades[slot].combo, "None")

            local upgrades = getVehicleCompatibleUpgrades(vehicle, aVehicleCustomization.Upgrades[slot].id)
            guiSetText(aVehicleCustomization.Upgrades[slot].label, "(" .. #upgrades .. ")")
            guiSetText(aVehicleCustomization.Upgrades[slot].combo, "None")
            if (getVehicleUpgradeOnSlot(vehicle, aVehicleCustomization.Upgrades[slot].id) > 0) then
                if (guiCheckBoxGetSelected(aVehicleCustomization.UpgradeNames)) then
                    guiSetText(
                        aVehicleCustomization.Upgrades[slot].combo,
                        tostring(aUpgradeNames[getVehicleUpgradeOnSlot(vehicle, aVehicleCustomization.Upgrades[slot].id)])
                    )
                else
                    guiSetText(
                        aVehicleCustomization.Upgrades[slot].combo,
                        tostring(getVehicleUpgradeOnSlot(vehicle, aVehicleCustomization.Upgrades[slot].id))
                    )
                end
            end
            for i, upgrade in ipairs(upgrades) do
                if (guiCheckBoxGetSelected(aVehicleCustomization.UpgradeNames)) then
                    guiComboBoxAddItem(aVehicleCustomization.Upgrades[slot].combo, tostring(aVehicleCustomization.Names[tonumber(upgrade)]))
                else
                    guiComboBoxAddItem(aVehicleCustomization.Upgrades[slot].combo, tostring(upgrade))
                end
            end
        end
    end
end

function aVehicleCustomization.CheckCurrentUpgrades(vehicle)
    if (vehicle) then
        for slot, v in ipairs(aVehicleCustomization.Upgrades) do
            if (getVehicleUpgradeOnSlot(vehicle, aVehicleCustomization.Upgrades[slot].id) > 0) then
                if (guiCheckBoxGetSelected(aVehicleCustomization.UpgradeNames)) then
                    guiSetText(
                        aVehicleCustomization.Upgrades[slot].combo,
                        tostring(aVehicleCustomization.Names[getVehicleUpgradeOnSlot(vehicle, aVehicleCustomization.Upgrades[slot].id)])
                    )
                else
                    guiSetText(
                        aVehicleCustomization.Upgrades[slot].combo,
                        tostring(getVehicleUpgradeOnSlot(vehicle, aVehicleCustomization.Upgrades[slot].id))
                    )
                end
            else
                guiSetText(aVehicleCustomization.Upgrades[slot].combo, "")
            end
        end
    end
end

function aGetVehicleUpgradeFromName(uname)
    for id, name in pairs(aVehicleCustomization.Names) do
        if (name == uname) then
            return id
        end
    end
    return false
end

function aVehicleCustomization.onClick(button, state)
    if (source ~= aVehicleCustomizationPaintjobList) then
        guiSetVisible(aVehicleCustomizationPaintjobList, false)
    end
    if (button == "left") then
        if (source == aVehicleCustomizationPaintjob) then
            guiBringToFront(aVehicleCustomizationPaintjobDrop)
        elseif (source == aVehicleCustomizationClose) then
            aVehicleCustomizationCustomizeClose(false)
        elseif (source == aVehicleCustomizationColorClose) then
            guiSetVisible(aVehicleCustomizationColorForm, false)
        elseif (source == aVehicleCustomizationColorSet) then
            triggerServerEvent(
                "aVehicleCustomization",
                getLocalPlayer(),
                aVehicleCustomizationCustomizePlayer,
                "setcolor",
                {
                    guiGetText(aVehicleCustomizationColor1),
                    guiGetText(aVehicleCustomizationColor2),
                    guiGetText(aVehicleCustomizationColor3),
                    guiGetText(aVehicleCustomizationColor4)
                }
            )
        elseif (source == aVehicleCustomizationColorScheme) then
            guiSetVisible(aVehicleCustomizationColorForm, true)
            guiBringToFront(aVehicleCustomizationColorForm)
        elseif (source == aVehicleCustomizationUpgradeAll) then
            triggerServerEvent("aVehicleCustomization", getLocalPlayer(), aVehicleCustomizationCustomizePlayer, "customize", {"all"})
            setTimer(aVehicleCustomizationCheckCurrentUpgrades, 2000, 1, aVehicleCustomizationCustomizeVehicle)
        elseif (source == aVehicleCustomizationRemoveAll) then
            triggerServerEvent("aVehicleCustomization", getLocalPlayer(), aVehicleCustomizationCustomizePlayer, "customize", {"remove"})
            setTimer(aVehicleCustomizationCheckCurrentUpgrades, 2000, 1, aVehicleCustomizationCustomizeVehicle)
        elseif (source == aVehicleCustomizationPaintjobSet) then
            triggerServerEvent(
                "aVehicleCustomization",
                getLocalPlayer(),
                aVehicleCustomizationCustomizePlayer,
                "setpaintjob",
                tonumber(guiGetText(aVehicleCustomizationPaintjob))
            )
        elseif (source == aVehicleCustomizationPaintjobDrop) then
            guiSetVisible(aVehicleCustomizationPaintjobList, true)
            guiBringToFront(aVehicleCustomizationPaintjobList)
        elseif (source == aVehicleCustomizationUpgradeNames) then
            aVehicleCustomizationCheckUpgrades(aVehicleCustomizationCustomizeVehicle)
            aSetSetting("aVehicleCustomizationUpgradeNames", guiCheckBoxGetSelected(aVehicleCustomizationUpgradeNames))
        elseif (source == aVehicleCustomizationUpgrade) then
            local tableOut = {}
            for id, element in ipairs(aVehicleCustomizationUpgrades) do
                local upgrade = guiGetText(element.edit)
                if (upgrade) and (upgrade ~= "") then
                    if (guiCheckBoxGetSelected(aVehicleCustomizationUpgradeNames)) then
                        local upgrade = aGetVehicleUpgradeFromName(upgrade)
                        if (upgrade) then
                            table.insert(tableOut, upgrade)
                        end
                    else
                        table.insert(tableOut, tonumber(upgrade))
                    end
                end
            end
            triggerServerEvent("aVehicleCustomization", getLocalPlayer(), aVehicleCustomizationCustomizePlayer, "customize", tableOut)
            setTimer(aVehicleCustomizationCheckCurrentUpgrades, 2000, 1, aVehicleCustomizationCustomizeVehicle)
        end
    end
end
