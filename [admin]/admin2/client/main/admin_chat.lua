--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\main\admin_chat.lua
*
*	Original File by lil_Toady
*
**************************************]]
aChatTab = {
    LastSync = 0
}

addEvent("aClientAdminChat", true)

function aChatTab.Create(tab)
    aChatTab.Tab = tab

    aChatTab.AdminChat = guiCreateMemo(0.01, 0.02, 0.78, 0.89, "", true, tab)
    guiSetProperty(aChatTab.AdminChat, "ReadOnly", "true")
    aChatTab.AdminPlayers = guiCreateGridList(0.80, 0.02, 0.19, 0.8, true, tab)
    guiGridListAddColumn(aChatTab.AdminPlayers, "Admins", 0.90)
    aChatTab.AdminChatSound = guiCreateCheckBox(0.81, 0.83, 0.18, 0.04, "Play Sound", aGetSetting("adminChatSound"), true, tab)
    aChatTab.AdminChatOutput = guiCreateCheckBox(0.81, 0.87, 0.18, 0.04, "Output", aGetSetting("adminChatOutput"), true, tab)
    aChatTab.AdminText = guiCreateEdit(0.01, 0.92, 0.78, 0.06, "", true, tab)
    aChatTab.AdminSay = guiCreateButton(0.80, 0.92, 0.19, 0.06, "Say", true, tab)

    addEventHandler("aClientAdminChat", root, aChatTab.onClientAdminChat)
    addEventHandler("aClientPlayerJoin", root, aChatTab.onClientPlayerJoin)
    addEventHandler("onClientPlayerQuit", root, aChatTab.onClientPlayerQuit)
    addEventHandler("onClientGUIClick", aChatTab.Tab, aChatTab.onClientClick)
    addEventHandler("onClientGUIAccepted", aChatTab.AdminText, aChatTab.onClientGUIAccepted)
    addEventHandler(EVENT_SYNC, root, aChatTab.onClientSync)
    addEventHandler("onAdminRefresh", aChatTab.Tab, aChatTab.onRefresh)
    addEventHandler("onClientGUITabSwitched", aChatTab.Tab, aChatTab.onTabSwitched, false)
end

function aChatTab.onClientClick(button)
    guiSetInputEnabled(false)
    if (button == "left") then
        if (source == aChatTab.AdminSay) then
            local message = guiGetText(aChatTab.AdminText)
            if ((message) and (message ~= "")) then
                if (gettok(message, 1, 32) == "/clear") then
                    guiSetText(aChatTab.AdminChat, "")
                else
                    triggerServerEvent("aAdminChat", getLocalPlayer(), message)
                end
                guiSetText(aChatTab.AdminText, "")
            end
        elseif (source == aChatTab.AdminText) then
            guiSetInputEnabled(true)
        elseif (source == aChatTab.AdminChatOutput) then
            aSetSetting("adminChatOutput", guiCheckBoxGetSelected(aChatTab.AdminChatOutput))
        elseif (source == aChatTab.AdminChatSound) then
            aSetSetting("adminChatSound", guiCheckBoxGetSelected(aChatTab.AdminChatSound))
        end
    end
end

function aChatTab.onClientSync(type, table)
    if (type == SYNC_ADMINS) then
        --if ( guiGridListGetRowCount ( aChatTab.AdminPlayers ) > 0 ) then guiGridListClear ( aChatTab.AdminPlayers ) end
        for id, player in ipairs(getElementsByType("player")) do
            if (not table[player] or not table[player]["admin"]) and (player == getLocalPlayer()) then
                -- aAdminDestroy()
                return
            else
                aPlayers[player]["groups"] = table[player]["groups"]
                if (table[player]["chat"]) then
                    local list = aChatTab.AdminPlayers
                    local id = 0
                    local exists = false
                    while (id <= guiGridListGetRowCount(list)) do
                        if (guiGridListGetItemData(list, id, 1) == player) then
                            exists = true
                        end
                        id = id + 1
                    end
                    if (not exists) then
                        local row = guiGridListAddRow(list)
                        guiGridListSetItemData(list, row, 1, source)
                        guiGridListSetItemText(list, row, 1, getPlayerName(player), false, false)
                    end
                end
            end
        end
    end
end

function aChatTab.onClientPlayerJoin(ip, username, serial, admin, country, countryname)
    local list = aChatTab.AdminPlayers
    if (admin) then
        local row = guiGridListAddRow(list)
        guiGridListSetItemData(list, row, 1, source)
        guiGridListSetItemText(list, row, 1, getPlayerName(source), false, false)
    end
end

function aChatTab.onClientPlayerQuit()
    if (aPlayers[source]["admin"]) then
        local list = aChatTab.AdminPlayers
        local id = 0
        while (id <= guiGridListGetRowCount(list)) do
            if (guiGridListGetItemData(list, id, 1) == source) then
                guiGridListRemoveRow(list, id)
            end
            id = id + 1
        end
    end
end

function aChatTab.onClientGUIAccepted(element)
    local message = guiGetText(aChatTab.AdminText)
    if ((message) and (message ~= "")) then
        if (gettok(message, 1, 32) == "/clear") then
            guiSetText(aChatTab.AdminChat, "")
        else
            triggerServerEvent("aAdminChat", getLocalPlayer(), message)
        end
        guiSetText(aChatTab.AdminText, "")
    end
end

function aChatTab.onClientAdminChat(message)
    local chat = guiGetText(aChatTab.AdminChat)
    guiSetText(aChatTab.AdminChat, (chat ~= "\n" and chat or "") .. getPlayerName(source) .. ": " .. message)
    guiSetProperty(aChatTab.AdminChat, "CaratIndex", tostring(string.len(chat)))
    if (aGetSetting("adminChatOutput")) then
        outputChatBox("ADMIN> " .. getPlayerName(source) .. ": " .. message, 255, 0, 0)
    end
    if ((aGetSetting("adminChatSound")) and (source ~= getLocalPlayer())) then
        playSoundFrontEnd(13)
    end
end

function aChatTab.onRefresh()
    if (getTickCount() >= aChatTab.LastSync) then
        sync(SYNC_ADMINS)
        aChatTab.LastSync = getTickCount() + 15000
    end
end

function aChatTab.onTabSwitched()
    -- Refresh checkbox status (in case settings were changed in the options tab)
    guiCheckBoxSetSelected(aChatTab.AdminChatSound, aGetSetting("adminChatSound"))
    guiCheckBoxSetSelected(aChatTab.AdminChatOutput, aGetSetting("adminChatOutput"))
end
