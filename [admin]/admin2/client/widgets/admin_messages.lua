--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_messages.lua
*
*	Original File by lil_Toady
*
**************************************]]
aMessages = {
    Form = nil,
    Messages = {}
}

function aMessages.Open()
    if (not aMessages.Form) then
        local x, y = guiGetScreenSize()
        aMessages.Form = guiCreateWindow(x / 2 - 250, y / 2 - 200, 500, 400, "View Messages", false)

        aMessages.List = guiCreateGridList(0.02, 0.07, 0.30, 0.83, true, aMessages.Form)
        guiGridListSetSortingEnabled(aMessages.List, false)
        guiGridListAddColumn(aMessages.List, "Subject", 0.60)
        guiGridListAddColumn(aMessages.List, "Date", 0.28)
        aMessages.Delete = guiCreateButton(0.84, 0.07, 0.15, 0.055, "Delete", true, aMessages.Form)
        aMessages.Refresh = guiCreateButton(0.02, 0.92, 0.30, 0.055, "Refresh", true, aMessages.Form)
        aMessages.Exit = guiCreateButton(0.84, 0.92, 0.15, 0.055, "Close", true, aMessages.Form)

        aMessages.Author = guiCreateLabel(0.36, 0.10, 0.50, 0.54, "Author: -", true, aMessages.Form)
        aMessages.Subject = guiCreateLabel(0.36, 0.15, 0.50, 0.54, "Subject: -", true, aMessages.Form)
        aMessages.Category = guiCreateLabel(0.36, 0.20, 0.50, 0.54, "Category: -", true, aMessages.Form)
        aMessages.Date = guiCreateLabel(0.36, 0.25, 0.50, 0.54, "Date: -", true, aMessages.Form)
        aMessages.Text = guiCreateMemo(0.36, 0.30, 0.59, 0.60, "", true, aMessages.Form)

        --Register With Admin Form
        aRegister("Messages", aMessages.Form, aMessages.Open, aMessages.Close)
    end

    addEventHandler("aMessage", getRootElement(), aMessages.onSync)
    addEventHandler("onClientGUIClick", aMessages.Form, aMessages.onClick)

    guiSetVisible(aMessages.Form, true)
    guiBringToFront(aMessages.Form)
    triggerServerEvent("aMessage", getLocalPlayer(), "get")
end

function aMessages.Close(destroy)
    if (aMessages.Form) then
        removeEventHandler("aMessage", getRootElement(), aMessages.onSync)
        removeEventHandler("onClientGUIClick", aMessages.Form, aMessages.onClick)
        if (destroy) then
            destroyElement(aMessages.Form)
            aMessages.Form = nil
        else
            guiSetVisible(aMessages.Form, false)
        end
    end
end

function aMessages.onSync(action, data)
    if (action == "get") then
        local storage = {}
        for id, message in ipairs(data) do
            if (not storage[message.author]) then
                storage[message.author] = {}
            end

            message.id = id
            table.insert(storage[message.author], message)
        end
        aMessages.Messages = storage

        local list = aMessages.List
        local id = 1
        guiGridListClear(aMessages.List)
        for user, messages in pairs(storage) do
            local row = guiGridListAddRow(list)
            guiGridListSetItemText(list, row, 1, tostring(user), true, false)

            for i, message in ipairs(messages) do
                local row = guiGridListAddRow(list)
                guiGridListSetItemText(list, row, 1, message.subject, false, false)
                guiGridListSetItemText(list, row, 2, message.time, false, false)
                if (not message.read) then
                    guiGridListSetItemColor(list, row, 1, 255, 50, 50)
                    guiGridListSetItemColor(list, row, 2, 255, 50, 50)
                end

                id = id + 1
            end
        end
    end
end

function aMessages.onClick(button)
    if (button == "left") then
        if (source == aMessages.Exit) then
            aMessages.Close()
        elseif (source == aMessages.Refresh) then
            triggerServerEvent("aMessage", getLocalPlayer(), "get")
        elseif (source == aMessages.Read) then
            local row = guiGridListGetSelectedItem(aMessages.List)
            if (row == -1) then
                messageBox("No message selected!", MB_WARNING, MB_OK)
            else
                local id = guiGridListGetItemText(aMessages.List, row, 1)
                aViewMessage(tonumber(id))
            end
        elseif (source == aMessages.Delete) then
            local row = guiGridListGetSelectedItem(aMessages.List)
            if (row == -1) then
                messageBox("No message selected!", MB_WARNING, MB_OK)
            else
                local id = guiGridListGetItemText(aMessages.List, row, 1)
                triggerServerEvent("aMessage", getLocalPlayer(), "delete", tonumber(id))
            end
        end
    end
end
