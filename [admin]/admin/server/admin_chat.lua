--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_chat.lua
*
*	Original File by Nico834
*
**************************************]]

local chatConfig = {}
local chatMessages = {}
local chatTimeouts = {}

addEventHandler("onResourceStart", resourceRoot,
    function()
        local configFile = getResourceConfig("conf/chat.xml")
        local configData = xmlNodeGetChildren(configFile)

        for k, v in pairs(configData) do
            local configName = xmlNodeGetAttribute(v, "name")
            local configValue = xmlNodeGetAttribute(v, "value")

            chatConfig[configName] = autoType(configValue) or false
        end

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
        chatMessages[source] = {}
        chatTimeouts[source] = nil
    end
)

addEventHandler("onPlayerChat", root,
    function(messageContent, messageType)
        if messageType ~= 0 then
            return
        end

        cancelEvent()

        if utf8.len(messageContent) < 1 then
            outputChatBox("You can't send an empty message.", source, 255, 0, 0)
            return
        end

        if chatConfig.antiSpamEnabled then
            if chatConfig.antiSpamTimeout > 0 then
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
            local lastMessageTime = false
            local lastMessageContent = false

            if chatConfig.antiSpamRepeat then
                if lastMessage and type(lastMessage) == "table" then
                    lastMessageContent = lastMessage[1]

                    local contentStart, contentStartIndex = string.find(lastMessageContent, "#ffffff")
                    local contentTrim = string.sub(lastMessageContent, contentStartIndex + 1)

                    if contentTrim == messageContent then
                        outputChatBox("Stop repeating yourself!", source, 255, 0, 0)
                        return
                    end
                end
            end

            if lastMessage and type(lastMessage) == "table" then
                lastMessageTime = lastMessage[2]

                if math.abs(getRealTime().timestamp - lastMessageTime) < chatConfig.antiSpamDelay then
                    if chatConfig.antiSpamTimeout > 0 then
                        outputChatBox("Your message has been marked as spam. You need to wait " .. chatConfig.antiSpamTimeout .. " seconds before sending an another message.", source, 255, 0, 0)
                        chatTimeouts[source] = getRealTime().timestamp + chatConfig.antiSpamTimeout
                    else
                        outputChatBox("Your message has been marked as spam.", source, 255, 0, 0)
                    end

                    return
                end
            end
        end

        local playerName = getPlayerName(source)
        local playerNameColor = {}

        if not chatConfig.isCustomcolorsEnabled then
            messageContent = messageContent:gsub("#%x%x%x%x%x%x", "")
        end

        if chatConfig.isPlayercolorsEnabled then
            playerNameColor = {getPlayerNametagColor(source)}
            playerNameColor = string.format("#%02X%02X%02X", playerNameColor[1], playerNameColor[2], playerNameColor[3])

            messageContent = string.format("%s%s: #ffffff%s", playerNameColor, playerName, messageContent)
        else
            messageContent = string.format("#f0e2b8%s: #ffffff%s", playerName, messageContent)
        end

        messageContent = messageContent:gsub("%s+", " ")

        table.insert(chatMessages[source], {messageContent, getRealTime().timestamp})
        outputChatBox(messageContent, root, 255, 255, 255, true)
        outputServerLog(messageContent:gsub("#%x%x%x%x%x%x", ""))
    end
)

function autoType(inputString)
    if tonumber(inputString) then
        return tonumber(inputString)
    elseif inputString == "true" then
        return true
    else
        return false
    end
end

function getMessageLog(playerElement)
    if playerElement and isElement(playerElement) then
        if chatMessages[playerElement] then
            return chatMessages[playerElement]
        else
            return false
        end
    end
end

function getMessageLast(playerElement)
    if playerElement and isElement(playerElement) then
        if chatMessages[playerElement] then
            return chatMessages[playerElement][#chatMessages[playerElement]]
        else
            return false
        end
    end
end