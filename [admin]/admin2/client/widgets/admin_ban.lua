--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_ban.lua
*
*	Original File by lil_Toady
*
**************************************]]
aBan = {
    Form = nil,
    defaultDurations = {
        {"1 second", 1},
        {"1 hour", 60 * 60},
        {"1 day", 60 * 60 * 24},
        {"1 week", 60 * 60 * 24 * 7},
        {"Permanent", 0}
    },
    playerName = nil
}

function aBan.Show(player)
    if not aBan.Form then
        aBan.Create()
    end
    
    -- If a player was selected, auto-fill the form with the player's info
    if player then
        aBan.playerName = getPlayerName(player)
        guiSetText(aBan.Form, "Ban player "..aBan.playerName)
        guiSetText(aBan.SerialEditBox, aPlayers[player].serial)
        guiSetEnabled(aBan.SerialEditBox, false)
        guiSetText(aBan.IPEditBox, aPlayers[player].ip)
        guiSetEnabled(aBan.IPEditBox, false)
    end

    addEventHandler("onClientGUIClick", aBan.Form, aBan.onClick)
    addEventHandler("onClientGUIFocus", aBan.Form, aBan.onFocus)
    addEventHandler("onClientGUIBlur", aBan.Form, aBan.onBlur)
    guiSetVisible(aBan.Form, true)
    guiBringToFront(aBan.Form)
end

function aBan.Close(destroy)
    if destroy then
        destroyElement(aBan.Form)
        aBan.Form = nil
    else
        removeEventHandler("onClientGUIClick", aBan.Form, aBan.onClick)
        guiSetVisible(aBan.Form, false)
        aBan.Reset()
    end
    aBan.playerName = nil
end

function aBan.Create()
    local sx, sy = guiGetScreenSize()
    aBan.Form = guiCreateWindow(sx / 2 - 200, sy / 2 - 170, 400, 340, "Add ban", false)
    aBan.ReasonLabel = guiCreateLabel(50, 40, 300, 20, "Ban reason (required):", false, aBan.Form)
    aBan.ReasonEditBox = guiCreateEdit(50, 70, 300, 30, "Enter ban reason...", false, aBan.Form)
    aBan.ReasonEditBoxRecievedInput = false
    aBan.DurationLabel = guiCreateLabel(50, 110, 300, 20, "Ban duration (required):", false, aBan.Form)
    aBan.DurationComboBox = guiCreateComboBox(50, 140, 300, 100, "Select ban duration...", false, aBan.Form)
    for i=1, #aBan.defaultDurations do
        guiComboBoxAddItem(aBan.DurationComboBox, aBan.defaultDurations[i][1])
    end
    aBan.IdentifiersLabel = guiCreateLabel(50, 180, 300, 20, "Select identifiers to use (select at least 1):", false, aBan.Form)
    aBan.IPCheckBox = guiCreateCheckBox(70, 210, 125, 30, "Use IP address", true, false, aBan.Form)
    aBan.IPEditBox = guiCreateEdit(200, 210, 150, 30, "Enter IP address...", false, aBan.Form)
    aBan.IPEditBoxRecievedInput = false
    aBan.SerialCheckBox = guiCreateCheckBox(70, 250, 125, 30, "Use MTA serial", true, false, aBan.Form)
    aBan.SerialEditBox = guiCreateEdit(200, 250, 150, 30, "Enter MTA serial...", false, aBan.Form)
    guiEditSetMaxLength(aBan.SerialEditBox, 32)
    aBan.SerialEditBoxRecievedInput = false
    aBan.SubmitButton = guiCreateButton(130, 290, 60, 40, "Submit", false, aBan.Form)
    aBan.CancelButton = guiCreateButton(210, 290, 60, 40, "Cancel", false, aBan.Form)
    aRegister("Ban", aBan.Form, aBan.Show, aBan.Close)
    guiSetVisible(aBan.Form, false)
end

function aBan.Reset()
    guiSetText(aBan.Form, "Add ban")
    guiSetText(aBan.ReasonEditBox, "Enter ban reason...")
    aBan.ReasonEditBoxRecievedInput = false
    guiCheckBoxSetSelected(aBan.IPCheckBox, true)
    guiSetText(aBan.IPEditBox, "Enter IP address")
    guiSetEnabled(aBan.IPEditBox, true)
    aBan.IPEditBoxRecievedInput = false
    guiCheckBoxSetSelected(aBan.SerialCheckBox, true)
    guiSetText(aBan.SerialEditBox, "Enter MTA serial...")
    guiSetEnabled(aBan.SerialEditBox, true)
    aBan.SerialEditBoxRecievedInput = false
end

function aBan.onClick(button, state)
    if not (button == "left" and state == "up") then
        return
    end

    -- Handle cancel button first
    if source == aBan.CancelButton then
        aBan.Close()
        return
    end

    -- Toggle IP/serial fields based on corresponding checkboxes
    if source == aBan.IPCheckBox and (not aBan.playerName) then
        guiSetEnabled(aBan.IPEditBox, guiCheckBoxGetSelected(source))
        return
    elseif source == aBan.SerialCheckBox and (not aBan.playerName) then
        guiSetEnabled(aBan.SerialEditBox, guiCheckBoxGetSelected(source))
        return
    end

    -- Handle submit button
    if source == aBan.SubmitButton then
        aBan.verifyForm()
        return
    end
end

function aBan.onFocus()
    -- Clear reason/IP/serial edit boxes on first click
    if source == aBan.ReasonEditBox then
        if not aBan.ReasonEditBoxRecievedInput then
            guiSetText(aBan.ReasonEditBox, "")
            aBan.ReasonEditBoxRecievedInput = true
        end
    elseif source == aBan.IPEditBox then
        if not aBan.IPEditBoxRecievedInput then
            guiSetText(aBan.IPEditBox, "")
            aBan.IPEditBoxRecievedInput = true
        end
    elseif source == aBan.SerialEditBox then
        if not aBan.SerialEditBoxRecievedInput then
            guiSetText(aBan.SerialEditBox, "")
            aBan.SerialEditBoxRecievedInput = true
        end
    end
end

function aBan.onBlur()
    -- Reset default text of reason/IP/serial edit boxes if they lose focus with no input
    if source == aBan.ReasonEditBox then
        if guiGetText(source) == "" then
            guiSetText(aBan.ReasonEditBox, "Enter ban reason...")
            aBan.ReasonEditBoxRecievedInput = false
        end
    elseif source == aBan.IPEditBox then
        if guiGetText(source) == "" then
            guiSetText(aBan.IPEditBox, "Enter IP address...")
            aBan.IPEditBoxRecievedInput = false
        end
    elseif source == aBan.SerialEditBox then
        if guiGetText(source) == "" then
            guiSetText(aBan.SerialEditBox, "Enter MTA serial...")
            aBan.SerialEditBoxRecievedInput = false
        end
    end
end

function aBan.verifyForm()
    -- Verify ban reason
    local banReason = guiGetText(aBan.ReasonEditBox)
    if guiGetText == "" or (not aBan.ReasonEditBoxRecievedInput) then
        messageBox("No ban reason provided.", MB_ERROR, MB_OK)
        return
    end

    -- Verify ban duration
    local banDurationSelection = guiComboBoxGetSelected(aBan.DurationComboBox)
    if banDurationSelection == -1 then
        messageBox("No ban duration provided.", MB_ERROR, MB_OK)
        return
    end
    banDurationSelection = banDurationSelection + 1 -- ComboBox item indices starts at 0 instead of one
    -- Verify ban IP
    local banIP = ""
    if guiCheckBoxGetSelected(aBan.IPCheckBox) then
        banIP = guiGetText(aBan.IPEditBox)
        if banIP == "" or (not aBan.IPEditBoxRecievedInput) then
            if not aBan.playerName then
                messageBox("No IP address provided.", MB_ERROR, MB_OK)
            end
        end
    end

    -- Verify ban serial
    local banSerial = ""
    if guiCheckBoxGetSelected(aBan.SerialCheckBox) then
        banSerial = guiGetText(aBan.SerialEditBox)
        if banSerial== "" or (not aBan.IPEditBoxRecievedInput) or #banSerial ~= 32 then
            if not aBan.playerName then
                messageBox("Invalid MTA serial provided.", MB_ERROR, MB_OK)
            end
        end
    end

    -- Show confirmation dialog
    local confirmationMessage
    if aBan.playerName then
        confirmationMessage = "Are you sure you want to ban "..aBan.playerName.."?"
    else
        confirmationMessage = "Are you sure you want to add this ban?\nIP = "..(banIP ~= "" and banIP or "None").."\nSerial = "..(banSerial ~= "" and banSerial or "None")
    end
    iprint(banDurationSelection)
    iprint(banDurationSelection, aBan.defaultDurations[banDurationSelection][2])
    if messageBox(confirmationMessage, MB_QUESTION, MB_YESNO) then
        -- Build ban request "packet" and send to server
        local data = {
            player = getPlayerFromName(aBan.playerName),
            playerName = aBan.playerName,
            ip = banIP,
            serial = banSerial,
            reason = banReason,
            duration = aBan.defaultDurations[banDurationSelection][2]
        }
        triggerServerEvent('aBans', localPlayer, "ban", data)
    end
end
