--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_mute.lua
*
*	Original File by omar-o22
*
**************************************]]
aMute = {
    defaultDurations = {
        {"1 minute", 60},
        {"1 hour", 60 * 60},
        {"1 day", 60 * 60 * 24},
        {"1 week", 60 * 60 * 24 * 7},
        {"Permanent", 0},   -- HARDCODED AS SECOND LAST IN THIS TABLE, DO NOT MOVE
        {"Custom", 0}       -- HARDCODED AS LAST LAST IN THIS TABLE, DO NOT MOVE
    },
}

function aMute.Show(player)
    if (not aMuteForm) then
        aMute.Create()
    end

	if (player) then
        aMute.playerName = getPlayerName(player)
        guiSetText(aMute.Form, "Mute player "..aMute.playerName)
    end

    addEventHandler("onClientGUIClick", aMute.Form, aMute.onClick)
    addEventHandler("onClientGUIFocus", aMute.Form, aMute.onFocus)
    addEventHandler("onClientGUIBlur", aMute.Form, aMute.onBlur)
end

function aMute.Close(destroy)
    if (destroy) then
        destroyElement(aMute.Form)
        aMute.Form = nil
    else
        removeEventHandler("onClientGUIClick", aMute.Form, aMute.onClick)
        guiSetVisible(aMute.Form, false)
        aMute.Reset()
    end
    aMute.playerName = nil
end

function aMute.Create()
    local sx, sy = guiGetScreenSize()

    aMute.Form = guiCreateWindow((sx - 350) / 2, (sy - 270) / 2, 350, 270, "Mute player", false)
    aMute.ReasonLabel = guiCreateLabel(25, 40, 300, 20, "Mute reason (required):", false, aMute.Form)
    aMute.ReasonEditBox = guiCreateEdit(25, 65, 300, 30, "Enter mute reason...", false, aMute.Form)
    aMute.ReasonEditBoxRecievedInput = false
    aMute.DurationLabel = guiCreateLabel(25, 110, 300, 20, "Mute duration (required):", false, aMute.Form)
    aMute.DurationComboBox = guiCreateComboBox(25, 140, 300, 100, "Select mute duration...", false, aMute.Form)
    for i=1, #aMute.defaultDurations do
        guiComboBoxAddItem(aMute.DurationComboBox, aMute.defaultDurations[i][1])
    end
    aMute.DurationEditBox = guiCreateEdit(25, 175, 300, 30, "Duration (seconds)...", false, aMute.Form)
    aMute.DurationEditBoxRecievedInput = false
    guiSetEnabled(aMute.DurationEditBox, false)

    aMute.SubmitButton = guiCreateButton(70, 222, 100, 30, "Submit", false, aMute.Form)
    aMute.CancelButton = guiCreateButton(180, 222, 100, 30, "Cancel", false, aMute.Form)
    aRegister("mute", aMute.Form, aMute.Show, aMute.Close)
end

function aMute.Reset()
    guiSetText(aMute.Form, "Mute player")
    guiSetText(aMute.ReasonEditBox, "Enter mute reason...")
    aMute.ReasonEditBoxRecievedInput = false
    guiComboBoxSetSelected(aMute.DurationComboBox, -1)
    guiSetText(aMute.DurationEditBox, "Duration (seconds)...")
    guiSetEnabled(aMute.DurationEditBox, false)
    aMute.DurationEditBoxRecievedInput = false
end

function aMute.onClick(button, state)
    if not (button == "left" and state == "up") then
        return
    end

    -- Handle cancel button first
    if source == aMute.CancelButton then
        aMute.Close()
        return
    end

    -- Autofill and enable/disable duration editbox based on choice
    if source == aMute.DurationComboBox then
        local selected = guiComboBoxGetSelected(aMute.DurationComboBox)
        if selected == -1 then
            return
        elseif selected == #aMute.defaultDurations - 2 then
            -- Second-last option is permanent duration - clear and disable edit box
            guiSetText(aMute.DurationEditBox, "0")
            guiSetEnabled(aMute.DurationEditBox, false)
        elseif selected == #aMute.defaultDurations - 1 then
            -- Last option (should) be custom duration - enable duration edit box
            guiSetText(aMute.DurationEditBox, "Duration (seconds)...")
            guiSetEnabled(aMute.DurationEditBox, true)
            aMute.DurationEditBoxRecievedInput = false
        else
            guiSetText(aMute.DurationEditBox, aMute.defaultDurations[selected + 1][2])
            guiSetEnabled(aMute.DurationEditBox, false)
        end
        return
    end

    -- Handle submit button
    if source == aMute.SubmitButton then
        aMute.verifyForm()
        return
    end
end

function aMute.onFocus()
    -- Clear reason/duration edit boxes on first click
    if source == aMute.ReasonEditBox then
        if not aMute.ReasonEditBoxRecievedInput then
            guiSetText(aMute.ReasonEditBox, "")
            aMute.ReasonEditBoxRecievedInput = true
        end
    elseif source == aMute.DurationEditBox then
        if not aMute.DurationEditBoxRecievedInput then
            guiSetText(aMute.DurationEditBox, "")
            aMute.DurationEditBoxRecievedInput = true
        end
    end
end

function aMute.onBlur()
    -- Reset default text of reason/duration edit boxes if they lose focus with no input
    if source == aMute.ReasonEditBox then
        if guiGetText(source) == "" then
            guiSetText(aMute.ReasonEditBox, "Enter mute reason...")
            aMute.ReasonEditBoxRecievedInput = false
        end
    elseif source == aMute.DurationEditBox then
        if guiGetText(source) == "" and (guiComboBoxGetSelected(aMute.DurationComboBox) == #aMute.defaultDurations - 1) then
            guiSetText(aMute.DurationEditBox, "Duration (seconds)...")
            aMute.DurationEditBoxRecievedInput = false
        end
    end
end

function aMute.verifyForm()
    -- Verify mute reason
    local muteReason = guiGetText(aMute.ReasonEditBox)
    if muteReason == "" or (not aMute.ReasonEditBoxRecievedInput) then
        messageBox("No mute reason provided.", MB_ERROR, MB_OK)
        return
    end

    -- Verify mute duration
    local muteDuration
    local durationSelection = guiComboBoxGetSelected(aMute.DurationComboBox)
    if durationSelection == -1 then
        messageBox("No mute duration provided.", MB_ERROR, MB_OK)
        return
    end
    durationSelection = durationSelection + 1 -- ComboBox item indices starts at 0 instead of one
    if durationSelection == #aMute.defaultDurations then
        muteDuration = guiGetText(aMute.DurationEditBox)
        muteDuration = tonumber(muteDuration)
        if not muteDuration or muteDuration <= 0 then
            messageBox("Invalid mute duration provided.", MB_ERROR, MB_OK)
            return
        end
    else
        muteDuration = aMute.defaultDurations[durationSelection][2]
    end

    -- Build mute request "packet" and send to server
    local actualPlayer -- Actual player may be offline
    if aMute.playerName then
        actualPlayer = getPlayerFromName(aMute.playerName)
    end
    local data = {
        playerName = aMute.playerName,
        reason = muteReason,
        duration = muteDuration
    }

    triggerServerEvent(
        "aPlayer",
        localPlayer,
        actualPlayer,
        "mute",
        data
    )
    aMute.Close()
end