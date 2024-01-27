--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_chat.lua
*
*	Original File by Nico834
*
**************************************]]

local chatMessages = {}
local chatTimeouts = {}

addEventHandler("onResourceStart", resourceRoot,
    function()
        for k, v in pairs(getElementsByType("player")) do
            chatMessages[v] = {}
        end
    end
)

addEventHandler("onPlayerJoin", root,
    function()
        chatMessages[source] = {}
    end
)

addEventHandler("onPlayerQuit", root,
    function()
        chatMessages[source] = nil
        chatTimeouts[source] = nil
    end
)

function onChatHandler(messageContent, messageType)
    if messageType ~= 0 then
        return
    end

    table.insert(chatMessages[source], {messageContent, getRealTime().timestamp})

    if not getConfig("isChatEnabled") then
        return
    end

    cancelEvent()

    if getConfig("antiSpamEnabled") then
        if getConfig("antiSpamTimeout") > 0 then
            if chatTimeouts[source] then
                if chatTimeouts[source] - getRealTime().timestamp <= 0 then
                    chatTimeouts[source] = nil
                else
                    outputChatBox("You need to wait " .. math.ceil(chatTimeouts[source] - getRealTime().timestamp) .. " seconds before sending an another message.", source, 255, 0, 0)
                    return
                end
            end
        end

        local lastMessage = getMessageLast(source)

        if getConfig("antiSpamRepeat") then
            if lastMessage and type(lastMessage) == "table" then
                local lastMessageContent = lastMessage[1]

                if lastMessageContent then
                    if lastMessageContent == messageContent then
                        outputChatBox("Stop repeating yourself!", source, 255, 0, 0)
                        return
                    end
                end
            end
        end

        if lastMessage and type(lastMessage) == "table" then
            local lastMessageTime = lastMessage[2]

            if lastMessageTime then
                if math.abs(getRealTime().timestamp - lastMessageTime) < getConfig("antiSpamDelay") then
                    if getConfig("antiSpamTimeout") > 0 then
                        outputChatBox("Your message has been marked as spam. You need to wait " .. getConfig("antiSpamTimeout") .. " seconds before sending an another message.", source, 255, 0, 0)
                        chatTimeouts[source] = getRealTime().timestamp + getConfig("antiSpamTimeout")
                    else
                        outputChatBox("Your message has been marked as spam.", source, 255, 0, 0)
                    end

                    return
                end
            end
        end
    end

    local playerName = getPlayerName(source)
    local playerNameColor = {197, 232, 242}

    if not getConfig("isCustomColorsEnabled") then
        messageContent = messageContent:gsub("#%x%x%x%x%x%x", "")
    end

    if getConfig("isPlayercolorsEnabled") then
        playerNameColor = {getPlayerNametagColor(source)}
        playerNameColor = string.format("#%02X%02X%02X", playerNameColor[1], playerNameColor[2], playerNameColor[3])
    else
        playerNameColor = string.format("#%02X%02X%02X", playerNameColor[1], playerNameColor[2], playerNameColor[3])
    end

    messageContent = string.format("%s%s: #ffffff%s", playerNameColor, playerName, messageContent)
    messageContent = messageContent:gsub("%s+", " ")

    outputChatBox(messageContent, root, 255, 255, 255, true)
    outputServerLog(messageContent:gsub("#%x%x%x%x%x%x", ""))
end

addEventHandler("onPlayerChat", root, onChatHandler)

function getConfig(configName)
    local configData = get(configName)

    if configData then
        return getConfigType(configData)
    end

    return false
end

function getConfigType(configData)
    if tonumber(configData) then
        return tonumber(configData)
    elseif configData == "true" then
        return true
    end

    return false
end

function getMessageLog(playerElement)
    if playerElement and isElement(playerElement) then
        if chatMessages[playerElement] then
            return chatMessages[playerElement]
        end

        return false
    end
end

function getMessageLast(playerElement)
    if playerElement and isElement(playerElement) then
        if chatMessages[playerElement] then
            return chatMessages[playerElement][#chatMessages[playerElement]]
        end

        return false
    end
end