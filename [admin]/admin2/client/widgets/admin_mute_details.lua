--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_mute_details.lua
*
*	Original File by omar-o22
*
**************************************]]
aMuteDetails = {
    Form = nil,
    Serial = nil
}

function aMuteDetails.Show(Serial, showUnmtue)
    if not aMuteDetails.Form then
        aMuteDetails.Create()
    end
    
    aMuteDetails.Serial = Serial
    local data = aMuteTab.List[Serial]

    guiSetText(aMuteDetails.NickText, "Player name: "..(data.name or "Unknown"))
    guiSetText(aMuteDetails.SerialText, "Serial: "..(Serial or "None"))
    guiSetText(aMuteDetails.ReasonText, "Reason: "..(data.reason or "None"))
    guiSetText(aMuteDetails.AdminText, "Responsible admin: "..(data.admin or "Unknown"))
    local time
    if time == 0 then
        time = "Permanent"
    else
        time = secondsToTimeDesc(data.time / 1000)
    end
    guiSetText(aMuteDetails.DurationText, "Duration: "..time)

    addEventHandler("onClientGUIClick", aMuteDetails.Form, aMuteDetails.onClick)
    guiSetVisible(aMuteDetails.Form, true)

    -- Toggle visibilty of certain elements if this is being opened as a confimration dialog for unmute action
    if showUnmtue then
        guiSetText(aMuteDetails.ConfirmationText, "Are you sure you want to remove this mute?")
        guiSetVisible(aMuteDetails.CloseButton, false)
        guiSetVisible(aMuteDetails.SubmitButton, true)
        guiSetVisible(aMuteDetails.CancelButton, true)
    end
    guiBringToFront(aMuteDetails.Form)
end

function aMuteDetails.Close(destroy)
    if destroy then
        destroyElement(aMuteDetails.Form)
        aMuteDetails.Form = nil
    else
        removeEventHandler("onClientGUIClick", aMuteDetails.Form, aMuteDetails.onClick)
        guiSetVisible(aMuteDetails.Form, false)
        aMuteDetails.Reset()
    end
    aMuteDetails.Serial = nil
end

function aMuteDetails.Create()
    local sx, sy = guiGetScreenSize()
    aMuteDetails.Form = guiCreateWindow(sx / 2 - 175, sy / 2 - 135, 350, 250, "Mute Details", false)
    aMuteDetails.ConfirmationText = guiCreateLabel(25, 40, 300, 20, "Mute details:", false, aMuteDetails.Form)
    aMuteDetails.NickText = guiCreateLabel(50, 70, 300, 20, "Player name: Unknown", false, aMuteDetails.Form)
    aMuteDetails.SerialText = guiCreateLabel(50, 90, 300, 20, "Serial: None", false, aMuteDetails.Form)
    aMuteDetails.ReasonText = guiCreateLabel(50, 110, 300, 20, "Reason: None", false, aMuteDetails.Form)
    aMuteDetails.AdminText = guiCreateLabel(50, 130, 300, 20, "Responsible admin: Unknown", false, aMuteDetails.Form)
    aMuteDetails.DurationText = guiCreateLabel(50, 150, 300, 20, "Duration: Never", false, aMuteDetails.Form)

    aMuteDetails.SubmitButton = guiCreateButton(105, 200, 60, 40, "Submit", false, aMuteDetails.Form)
    aMuteDetails.CancelButton = guiCreateButton(185, 200, 60, 40, "Cancel", false, aMuteDetails.Form)
    aMuteDetails.CloseButton = guiCreateButton(145, 200, 60, 40, "Close", false, aMuteDetails.Form)
    guiSetVisible(aMuteDetails.CloseButton, true)
    guiSetVisible(aMuteDetails.SubmitButton, false)
    guiSetVisible(aMuteDetails.CancelButton, false)
    aRegister("Mute Details", aMuteDetails.Form, aMuteDetails.Show, aMuteDetails.Close)
    guiSetVisible(aMuteDetails.Form, false)
end

function aMuteDetails.Reset()
    guiSetText(aMuteDetails.Form, "Mute Details")
    guiSetText(aMuteDetails.ConfirmationText, "Mute details:")
    guiSetText(aMuteDetails.NickText, "Player name: Unknown")
    guiSetText(aMuteDetails.SerialText, "Serial: None")
    guiSetText(aMuteDetails.ReasonText, "Reason: None")
    guiSetText(aMuteDetails.AdminText, "Responsible admin: Unknown")
    guiSetText(aMuteDetails.DurationText, "Duration: Never")
    guiSetVisible(aMuteDetails.CloseButton, true)
    guiSetVisible(aMuteDetails.SubmitButton, false)
    guiSetVisible(aMuteDetails.CancelButton, false)
end

function aMuteDetails.onClick(button, state)
    if not (button == "left" and state == "up") then
        return
    end

    -- Handle cancel button first
    if source == aMuteDetails.CancelButton or source == aMuteDetails.CloseButton then
        aMuteDetails.Close()
        return
    end

    if source == aMuteDetails.SubmitButton then        
        triggerServerEvent(EVENT_MUTE, localPlayer, "unmute", {serial = aMuteDetails.Serial})
        aMuteDetails.Close()
        sync(SYNC_MUTES)
        return
    end
end