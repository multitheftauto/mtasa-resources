--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_ban.lua
*
*	Original File by lil_Toady
*
**************************************]] -- LuaFormatter off
aHandleBans = {}

local defaultDurations = {
    {'Days', 86400},
    {'Hours', 3600},
    {'Mins', 60},
}

local predefinedDurations = {
    {'1 min', 60},
    {'1 hour', 3600},
    {'12 hours', 7200},
    {'Permanent', 0},
}
-- LuaFormatter on

function aHandleBans.Show(title, name, reason, serial, ip)
    if (aHandleBans.Form == nil) then
        local sW, sH = guiGetScreenSize()
        local w, h = 357, 282

        aHandleBans.Form = guiCreateWindow((sW - w) / 2, (sH - h) / 2, w, h, 'ban player', false)
        guiWindowSetSizable(aHandleBans.Form, false)
        guiSetAlpha(aHandleBans.Form, 1)

        local y = 25

        aHandleBans.NameAndReasonlabel = guiCreateLabel(28, y, 301, 20, 'Enter the ban name and reason', false, aHandleBans.Form)
        guiLabelSetHorizontalAlign(aHandleBans.NameAndReasonlabel, 'center', false)

        y = y + 20

        aHandleBans.NameEdit = guiCreateEdit(28, y, 110, 22, '', false, aHandleBans.Form)
        aHandleBans.ReasonEdit = guiCreateEdit(143, y, 186, 22, '', false, aHandleBans.Form)

        y = y + 30

        aHandleBans.SerialCheckBox = guiCreateCheckBox(28, y, 301, 15, '', true, false, aHandleBans.Form)

        y = y + 20

        aHandleBans.IPCheckBox = guiCreateCheckBox(28, y, 301, 15, '', true, false, aHandleBans.Form)

        y = y + 25
        aHandleBans.Duration = {}

        aHandleBans.Duration.Background = guiCreateButton(27, y, 302, 120, '', false, aHandleBans.Form)
        guiSetProperty(aHandleBans.Duration.Background, 'MousePassThroughEnabled', 'True')

        aHandleBans.Duration.Label = guiCreateLabel(9, 10, 66, 20, 'Duration:', false, aHandleBans.Duration.Background)
        aHandleBans.Duration.ScrollPane = guiCreateScrollPane(75, 10, 217, 180, false, aHandleBans.Duration.Background)

        do
            local y2 = 0
            aHandleBans.Duration.CustomRadioButton = guiCreateRadioButton(0, y2, 65, 20, 'Custom:', false, aHandleBans.Duration.ScrollPane)

            aHandleBans.Duration.CustomEdit = guiCreateEdit(80, y2, 50, 22, '', false, aHandleBans.Duration.ScrollPane)
            guiSetProperty(aHandleBans.Duration.CustomEdit, 'ValidationString', '[0-9]*')

            aHandleBans.Duration.CustomComboBox = guiCreateComboBox(130, y2, 70, 80, defaultDurations[1][1], false, aHandleBans.Duration.ScrollPane)

            for _, v in ipairs(defaultDurations) do
                guiComboBoxAddItem(aHandleBans.Duration.CustomComboBox, v[1])
            end

            aHandleBans.Duration.Predefined = {}

            for k, v in pairs(predefinedDurations) do
                y2 = y2 + 20
                aHandleBans.Duration.Predefined[k] = guiCreateRadioButton(0, y2, 100, 20, v[1], false, aHandleBans.Duration.ScrollPane)
            end
        end

        y = y + 130

        local buttonW = 50
        aHandleBans.ConfirmButton = guiCreateButton((w / 2) - buttonW - 5, y, buttonW, 20, 'Ok', false, aHandleBans.Form)
        aHandleBans.CancelButton = guiCreateButton((w / 2) + 5, y, buttonW, 20, 'Cancel', false, aHandleBans.Form)

        addEventHandler('onClientGUIClick', aHandleBans.Form, aHandleBans.OnClick)

        -- Register With Admin Form
        aRegister('BanDetails', aHandleBans.Form, aHandleBans.Show, aHandleBans.Close)
    end

    aHandleBans.SelectedIP = ip
    aHandleBans.SelectedSerial = serial

    guiCheckBoxSetSelected(aHandleBans.SerialCheckBox, true)
    guiCheckBoxSetSelected(aHandleBans.IPCheckBox, true)

    guiRadioButtonSetSelected(aHandleBans.Duration.CustomRadioButton, true)
    guiSetVisible(aHandleBans.Duration.CustomEdit, true)
    guiSetVisible(aHandleBans.Duration.CustomComboBox, true)

    guiSetText(aHandleBans.Form, title)
    guiSetText(aHandleBans.NameEdit, name)
    guiSetText(aHandleBans.ReasonEdit, reason)
    guiSetText(aHandleBans.SerialCheckBox, 'Serial: ' .. serial)
    guiSetText(aHandleBans.IPCheckBox, 'IP: ' .. ip)

    guiSetVisible(aHandleBans.Form, true)
    guiBringToFront(aHandleBans.Form)

    return true
end

function aHandleBans.OnClick()
    local elemType = getElementType(source)

    if (source == aHandleBans.CancelButton) then
        aHandleBans.Close()

    elseif (source == aHandleBans.ConfirmButton) then
        aHandleBans.AddBan()

    elseif (elemType == 'gui-radiobutton') then
        guiSetVisible(aHandleBans.Duration.CustomEdit, source == aHandleBans.Duration.CustomRadioButton)
        guiSetVisible(aHandleBans.Duration.CustomComboBox, source == aHandleBans.Duration.CustomRadioButton)

    elseif (elemType == 'gui-checkbox') then
        local color = 'FFFFFFFF'
        local alpha = 1

        if (not guiCheckBoxGetSelected(aHandleBans.SerialCheckBox)) and (not guiCheckBoxGetSelected(aHandleBans.IPCheckBox)) then
            color = 'FFFF0000'
            alpha = 0.8
        end

        for _, elem in pairs({aHandleBans.SerialCheckBox, aHandleBans.IPCheckBox}) do
            for _, property in pairs({'NormalTextColour', 'HoverTextColour'}) do
                guiSetProperty(elem, property, color)
                guiSetAlpha(elem, alpha)
            end
        end
    end
end

function aHandleBans.AddBan()
    if (not isElement(aHandleBans.Form)) or (not guiGetVisible(aHandleBans.Form)) then
        return false
    end

    local data = {}

    data.name = guiGetText(aHandleBans.NameEdit)
    data.reason = guiGetText(aHandleBans.ReasonEdit)
    data.duration = aHandleBans.GetBanDuration()

    data.serial = guiCheckBoxGetSelected(aHandleBans.SerialCheckBox) and aHandleBans.SelectedSerial
    data.ip = guiCheckBoxGetSelected(aHandleBans.IPCheckBox) and aHandleBans.SelectedIP

    if (utf8.len(data.name) == 0) then
        outputChatBox('Invalid name.', 255, 0, 0)
        return false
    end

    if (not data.duration) then
        outputChatBox('Invalid duration.', 255, 0, 0)
        return false
    end

    if (not data.serial) and (not data.ip) then
        outputChatBox('Invalid ban type.', 255, 0, 0)
        return false
    end

    triggerServerEvent('aBans', localPlayer, 'ban', data)

    return true
end

function aHandleBans.GetBanDuration()
    if guiRadioButtonGetSelected(aHandleBans.Duration.CustomRadioButton) then
        local duration = tonumber(guiGetText(aHandleBans.Duration.CustomEdit))
        local selectedDuration = guiComboBoxGetItemText(aHandleBans.Duration.CustomComboBox, guiComboBoxGetSelected(aHandleBans.Duration.CustomComboBox))

        if duration then
            for _, v in pairs(defaultDurations) do
                if (v[1] == selectedDuration) then
                    return duration * v[2]
                end
            end
        end
    else
        for k, v in pairs(aHandleBans.Duration.Predefined) do
            if guiRadioButtonGetSelected(v) then
                return predefinedDurations[k] and predefinedDurations[k][2]
            end
        end
    end

    return false
end

function aHandleBans.Close(destroy)
    if destroy then
        if isElement(aHandleBans.Form) then
            destroyElement(aHandleBans.Form)
        end
        aHandleBans.Form = nil
    else
        guiSetVisible(aHandleBans.Form, false)
    end
end

-- addEventHandler('onClientResourceStart', resourceRoot, function()
--     aHandleBans.Show('Add ban', 'iDz', 'teste', getPlayerSerial(), '192.168.0.1')
--     showCursor(true)
-- end)

-- function aBanDetails(ip)
--     if (aBanForm == nil) then
--         local x, y = guiGetScreenSize()
--         aBanForm = guiCreateWindow(x / 2 - 130, y / 2 - 150, 260, 300, "Ban Details", false)
--         aBanIP = guiCreateLabel(0.03, 0.10, 0.80, 0.09, "", true, aBanForm)
--         aBanNick = guiCreateLabel(0.03, 0.20, 0.80, 0.09, "", true, aBanForm)
--         aBanDate = guiCreateLabel(0.03, 0.30, 0.80, 0.09, "", true, aBanForm)
--         aBanTime = guiCreateLabel(0.03, 0.40, 0.80, 0.09, "", true, aBanForm)
--         aBanBanner = guiCreateLabel(0.03, 0.50, 0.80, 0.09, "", true, aBanForm)
--         aBanClose = guiCreateButton(0.80, 0.88, 0.17, 0.08, "Close", true, aBanForm)

--         guiSetVisible(aBanForm, false)
--         addEventHandler("onClientGUIClick", aBanForm, aClientBanClick)
--         --Register With Admin Form
--         aRegister("BanDetails", aBanForm, aBanDetails, aBanDetailsClose)
--     end
--     if (aBans["IP"][ip]) then
--         guiSetText(aBanIP, "IP: " .. ip)
--         guiSetText(aBanNick, "Nickname: " .. iif(aBans["IP"][ip]["nick"], aBans["IP"][ip]["nick"], "Unknown"))
--         guiSetText(aBanDate, "Date: " .. iif(aBans["IP"][ip]["date"], aBans["IP"][ip]["date"], "Unknown"))
--         guiSetText(aBanTime, "Time: " .. iif(aBans["IP"][ip]["time"], aBans["IP"][ip]["time"], "Unknown"))
--         guiSetText(aBanBanner, "Bant by: " .. iif(aBans["IP"][ip]["banner"], aBans["IP"][ip]["banner"], "Unknown"))
--         if (aBanReason) then
--             destroyElement(aBanReason)
--         end
--         aBanReason =
--             guiCreateLabel(
--             0.03,
--             0.60,
--             0.80,
--             0.30,
--             "Reason: " .. iif(aBans["IP"][ip]["reason"], aBans["IP"][ip]["reason"], "Unknown"),
--             true,
--             aBanForm
--         )
--         guiLabelSetHorizontalAlign(aBanReason, 4)
--         guiSetVisible(aBanForm, true)
--         guiBringToFront(aBanForm)
--     elseif (aBans["Serial"][ip]) then
--         guiSetText(aBanIP, "Serial: " .. ip)
--         guiSetText(aBanNick, "Nickname: " .. iif(aBans["Serial"][ip]["nick"], aBans["Serial"][ip]["nick"], "Unknown"))
--         guiSetText(aBanDate, "Date: " .. iif(aBans["Serial"][ip]["date"], aBans["Serial"][ip]["date"], "Unknown"))
--         guiSetText(aBanTime, "Time: " .. iif(aBans["Serial"][ip]["time"], aBans["Serial"][ip]["time"], "Unknown"))
--         guiSetText(
--             aBanBanner,
--             "Bant by: " .. iif(aBans["Serial"][ip]["banner"], aBans["Serial"][ip]["banner"], "Unknown")
--         )
--         if (aBanReason) then
--             destroyElement(aBanReason)
--         end
--         aBanReason =
--             guiCreateLabel(
--             0.03,
--             0.60,
--             0.80,
--             0.30,
--             "Reason: " .. iif(aBans["Serial"][ip]["reason"], aBans["Serial"][ip]["reason"], "Unknown"),
--             true,
--             aBanForm
--         )
--         guiLabelSetHorizontalAlign(aBanReason, 4)
--         guiSetVisible(aBanForm, true)
--         guiBringToFront(aBanForm)
--     end
-- end
