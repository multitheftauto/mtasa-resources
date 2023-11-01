--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_ban_details.lua
*
**************************************]]
aBanDetails = {
    Form = nil,
    banID = nil
}

function aBanDetails.Show(banID, showUnban)
    if not aBanDetails.Form then
        aBanDetails.Create()
    end
    
    aBanDetails.banID = banID
    local data = aBansTab.List[banID]
    guiSetText(aBanDetails.NickText, "Player name: "..(data.nick or "Unknown"))
    guiSetText(aBanDetails.IPText, "IP: "..(data.ip or "None"))
    guiSetText(aBanDetails.SerialText, "Serial: "..(data.serial or "None"))
    guiSetText(aBanDetails.ReasonText, "Reason: "..(data.reason or "None"))
    guiSetText(aBanDetails.AdminText, "Responsible admin: "..(data.banner or "Unknown"))
    if data.unban then
        guiSetText(aBanDetails.ExpireText, "Expire time: "..formatDate("m/d/y h:m", nil, data.unban))
    else
        guiSetText(aBanDetails.ExpireText, "Expire time: Never")
    end

    addEventHandler("onClientGUIClick", aBanDetails.Form, aBanDetails.onClick)
    guiSetVisible(aBanDetails.Form, true)

    -- Toggle visibilty of certain elements if this is being opened as a confimration dialog for unban action
    if showUnban then
        guiSetText(aBanDetails.ConfirmationText, "Are you sure you want to remove this ban?")
        guiSetVisible(aBanDetails.CloseButton, false)
        guiSetVisible(aBanDetails.SubmitButton, true)
        guiSetVisible(aBanDetails.CancelButton, true)
    end
    guiBringToFront(aBanDetails.Form)
end

function aBanDetails.Close(destroy)
    if destroy then
        destroyElement(aBanDetails.Form)
        aBanDetails.Form = nil
    else
        removeEventHandler("onClientGUIClick", aBanDetails.Form, aBanDetails.onClick)
        guiSetVisible(aBanDetails.Form, false)
        aBanDetails.Reset()
    end
    aBanDetails.banID = nil
end

function aBanDetails.Create()
    local sx, sy = guiGetScreenSize()
    aBanDetails.Form = guiCreateWindow(sx / 2 - 175, sy / 2 - 135, 350, 250, "Ban Details", false)
    aBanDetails.ConfirmationText = guiCreateLabel(25, 40, 300, 20, "Ban details:", false, aBanDetails.Form)
    aBanDetails.NickText = guiCreateLabel(50, 70, 300, 20, "Player name: Unknown", false, aBanDetails.Form)
    aBanDetails.IPText = guiCreateLabel(50, 90, 300, 20, "IP: None", false, aBanDetails.Form)
    aBanDetails.SerialText = guiCreateLabel(50, 110, 300, 20, "Serial: None", false, aBanDetails.Form)
    aBanDetails.ReasonText = guiCreateLabel(50, 130, 300, 20, "Reason: None", false, aBanDetails.Form)
    aBanDetails.AdminText = guiCreateLabel(50, 150, 300, 20, "Responsible admin: Unknown", false, aBanDetails.Form)
    aBanDetails.ExpireText = guiCreateLabel(50, 170, 300, 20, "Expire time: Never", false, aBanDetails.Form)

    aBanDetails.SubmitButton = guiCreateButton(105, 200, 60, 40, "Submit", false, aBanDetails.Form)
    aBanDetails.CancelButton = guiCreateButton(185, 200, 60, 40, "Cancel", false, aBanDetails.Form)
    aBanDetails.CloseButton = guiCreateButton(145, 200, 60, 40, "Close", false, aBanDetails.Form)
    guiSetVisible(aBanDetails.CloseButton, true)
    guiSetVisible(aBanDetails.SubmitButton, false)
    guiSetVisible(aBanDetails.CancelButton, false)
    aRegister("Ban Details", aBanDetails.Form, aBanDetails.Show, aBanDetails.Close)
    guiSetVisible(aBanDetails.Form, false)
end

function aBanDetails.Reset()
    guiSetText(aBanDetails.Form, "Ban Details")
    guiSetText(aBanDetails.ConfirmationText, "Ban details:")
    guiSetText(aBanDetails.NickText, "Player name: Unknown")
    guiSetText(aBanDetails.IPText, "IP: None")
    guiSetText(aBanDetails.SerialText, "Serial: None")
    guiSetText(aBanDetails.ReasonText, "Reason: None")
    guiSetText(aBanDetails.AdminText, "Responsible admin: Unknown")
    guiSetText(aBanDetails.ExpireText, "Expire time: Never")
    guiSetVisible(aBanDetails.CloseButton, true)
    guiSetVisible(aBanDetails.SubmitButton, false)
    guiSetVisible(aBanDetails.CancelButton, false)
end

function aBanDetails.onClick(button, state)
    if not (button == "left" and state == "up") then
        return
    end

    -- Handle cancel button first
    if source == aBanDetails.CancelButton or source == aBanDetails.CloseButton then
        aBanDetails.Close()
        return
    end

    if source == aBanDetails.SubmitButton then
        triggerServerEvent(EVENT_BAN, localPlayer, "unban", aBanDetails.banID)
        return
    end
end