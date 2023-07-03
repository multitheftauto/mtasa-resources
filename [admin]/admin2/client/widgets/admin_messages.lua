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

addEvent("aMessage", true)

function aMessages.Open()
    if (not aMessages.Form) then
        local x, y = guiGetScreenSize()
        aMessages.Form = guiCreateWindow(x / 2 - 350, y / 2 - 300, 700, 600, "View Messages", false)

        aMessages.List = guiCreateGridList(0.02, 0.07, 0.35, 0.83, true, aMessages.Form)
        guiGridListSetSortingEnabled(aMessages.List, false)
        guiGridListAddColumn(aMessages.List, "Subject", 0.60)
        guiGridListAddColumn(aMessages.List, "Date", 0.28)
        aMessages.Delete = guiCreateButton(0.84, 0.07, 0.15, 0.055, "Delete", true, aMessages.Form)
        aMessages.Refresh = guiCreateButton(0.02, 0.92, 0.35, 0.055, "Refresh", true, aMessages.Form)
        aMessages.Exit = guiCreateButton(0.84, 0.92, 0.15, 0.055, "Close", true, aMessages.Form)

        aMessages.Author = guiCreateLabel(0.41, 0.10, 0.55, 0.54, "Author: -", true, aMessages.Form)
        aMessages.Subject = guiCreateLabel(0.41, 0.15, 0.55, 0.54, "Subject: -", true, aMessages.Form)
        aMessages.Category = guiCreateLabel(0.41, 0.20, 0.55, 0.54, "Category: -", true, aMessages.Form)
        aMessages.Date = guiCreateLabel(0.41, 0.25, 0.55, 0.54, "Date: -", true, aMessages.Form)
        aMessages.Text = guiCreateMemo(0.41, 0.30, 0.64, 0.60, "", true, aMessages.Form)
        guiMemoSetReadOnly(aMessages.Text, true)

        --Register With Admin Form
        aRegister("Messages", aMessages.Form, aMessages.Open, aMessages.Close)
    end

    addEventHandler("aMessage", root, aMessages.onSync)
    addEventHandler("onClientGUIClick", aMessages.Form, aMessages.onClick)

    guiSetVisible(aMessages.Form, true)
    guiBringToFront(aMessages.Form)
    triggerServerEvent("aMessage", localPlayer, "get")
end

function aMessages.Close(destroy)
    if (aMessages.Form) then
        removeEventHandler("aMessage", root, aMessages.onSync)
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
        aMessages.Messages = data

        local list = aMessages.List
        local selected = guiGridListGetSelectedItem(list)
        guiGridListClear(list)
        for user, messages in pairs(storage) do
            local row = guiGridListAddRow(list)
            guiGridListSetItemText(list, row, 1, tostring(user), true, false)

            for i, message in ipairs(messages) do
                row = guiGridListAddRow(list)
                guiGridListSetItemText(list, row, 1, message.subject, false, false)
                guiGridListSetItemData(list, row, 1, message.id)
                guiGridListSetItemText(list, row, 2, message.time, false, false)
                if (not message.read) then
                    guiGridListSetItemColor(list, row, 1, 255, 50, 50)
                    guiGridListSetItemColor(list, row, 2, 255, 50, 50)
                end
            end
        end
        guiGridListSetSelectedItem(list, selected, 1)
    end
end

function aMessages.View(id)
    if (id) then
        local message = aMessages.Messages[id]
        
        guiSetText(aMessages.Author, "Author: "..message.author)
        guiSetText(aMessages.Subject, "Subject: "..message.subject)
        guiSetText(aMessages.Category, "Category: "..message.category)
        guiSetText(aMessages.Date, "Date: "..message.time)
        guiSetText(aMessages.Text, message.text)
        
        if (not message.read) then
            triggerServerEvent("aMessage", localPlayer, "read", id)
        end
    else
        guiSetText(aMessages.Author, "Author: -")
        guiSetText(aMessages.Subject, "Subject: -")
        guiSetText(aMessages.Category, "Category: -")
        guiSetText(aMessages.Date, "Date: -")
        guiSetText(aMessages.Text, "")
    end
end

function aMessages.onClick(button)
    if (button == "left") then
        if (source == aMessages.Exit) then
            aMessages.Close()
        elseif (source == aMessages.Refresh) then
            triggerServerEvent("aMessage", localPlayer, "get")
        elseif (source == aMessages.List) then
            local row = guiGridListGetSelectedItem(aMessages.List)
            if (row == -1) then
                aMessages.View(false)
            else
                local id = guiGridListGetItemData(aMessages.List, row, 1)
                aMessages.View(id)
            end
        elseif (source == aMessages.Delete) then
            local row = guiGridListGetSelectedItem(aMessages.List)
            if (row == -1) then
                messageBox("No message selected!", MB_WARNING, MB_OK)
            else
                local id = guiGridListGetItemData(aMessages.List, row, 1)
                local confirm = messageBox("Are you sure you want to delete this message?", MB_QUESTION, MB_YESNO)
                if (confirm) then
                    aMessages.View(false)
                    triggerServerEvent("aMessage", localPlayer, "delete", {id, aMessages.Messages[id]})
                end
            end
        end
    end
end
