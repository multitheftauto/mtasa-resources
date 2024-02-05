local screenX, screenY = guiGetScreenSize()

local messageBoxWindows = {}
local messageBoxCallbacks = {}

function messageBeep(soundType, soundVolume)
    if not soundType or type(soundType) ~= "string" then
        error("Bad argument @ 'messageBeep' [Expected string at argument 1, got " .. type(soundType) .. "]")
    end

    soundType = utf8.upper(soundType)

    if not messageSounds[soundType] then
        error("Bad argument @ 'messageBeep' [Invalid type at argument 1, got '" .. tostring(soundType) .. "']")
    end

    if not soundVolume or soundVolume > 1 or type(soundVolume) ~= "number" then
        soundVolume = 1
    end

    local soundID = messageSounds[soundType].soundID
    local soundElement = playSoundFrontEnd(soundID)

    if soundElement and isElement(soundElement) then
        setSoundVolume(soundElement, soundVolume)
    end

    return soundElement
end

function messageClick()
    local elementParent = getElementParent(source)

    if elementParent then
        local elementBox = messageBoxWindows[elementParent]
        
        if elementBox then
            local elementCallback = messageBoxCallbacks[elementParent][1]
            local elementCallbackSource = messageBoxCallbacks[elementParent][2]
            local elementCallbackResult = guiGetText(source)

            elementCallbackResult = utf8.upper(elementCallbackResult)

            if elementCallback and type(elementCallback) == "string" then
                if elementCallbackSource and getResourceState(elementCallbackSource) == "running" then
                    call(elementCallbackSource, elementCallback, elementCallbackResult)
                end
            end

            destroyElement(elementParent)

            messageBoxWindows[elementParent] = nil
            messageBoxCallbacks[elementParent] = nil
        end
    end
end

function messageClickEx()
    local elementParent = getElementParent(source)

    if elementParent then
        local elementBox = messageBoxWindows[elementParent]

        if elementBox then
            destroyElement(elementParent)
            messageBoxWindows[elementParent] = nil
        end
    end
end

function messageBox(messageTitle, messageContent, messageCallback, messageIcon, messageButton, messageButtonDefault, messageSound, messageSoundVolume)
    if not messageTitle or type(messageTitle) ~= "string" then
        error("Bad argument @ 'messageBox' [Expected string at argument 1, got " .. type(messageTitle) .. "]")
    end

    messageTitle = utf8.upper(messageTitle)

    if not messageContent or type(messageContent) ~= "string" then
        error("Bad argument @ 'messageBox' [Expected string at argument 2, got " .. type(messageContent) .. "]")
    end

    if not messageIcon or type(messageIcon) ~= "string" then
        messageIcon = "INFO"
    end

    messageIcon = utf8.upper(messageIcon)

    if not messageIcons[messageIcon] then
        error("Bad argument @ 'messageBox' [Invalid type at argument 4, got '" .. tostring(messageIcon) .. "']")
    end

    if not messageButton or type(messageButton) ~= "string" then
       messageButton = "OK"
    end

    messageButton = utf8.upper(messageButton)

    if not messageButtons[messageButton] then
        error("Bad argument @ 'messageBox' [Invalid type at argument 5, got '" .. tostring(messageButton) .. "']")
    end

    if messageButtonDefault then
        if type(messageButtonDefault) ~= "number" then
            error("Bad argument @ 'messageBox' [Expected number at argument 6, got " .. type(messageButtonDefault) .. "]")
        elseif #messageButtons[messageButton] < messageButtonDefault then
            error("Bad argument @ 'messageBox' [Invalid default at argument 6, " .. messageButton .. " only have " .. tostring(#messageButtons[messageButon]) .. " buttons.]")
        end
    else
        messageButtonDefault = 1
    end

    if messageSound then
        if type(messageSound) ~= "string" then
            error("Bad argument @ 'messageBox' [Expected string at argument 7, got " .. type(messageSound) .. "]")
        elseif not messageSounds[messageSound] then
            error("Bad argument @ 'messageBox' [Invalid type at argument 7, got '" .. messageSound .. "']")
        end
    else
        messageSound = messageIcon
    end

    if messageSoundVolume then
        if type(messageSoundVolume) ~= "number" then
            error("Bad argument @ 'messageBox' [Expected number at argument 8, got " .. type(messageSoundVolume) .. "]")
        elseif messageSoundVolume > 1 or messageSoundVolume < 1 then
            error("Bad argument @ 'messageBox' [Invalid volume at argument 8, got '" .. tostring(messageSoundVolume) .. "']")
        end
    else
        messageSoundVolume = 1
    end

    messageBeep(messageSound, messageSoundVolume)

    local messageWindowWidth = 400
    local messageWindowHeight = 200

    local messageWindowPosX = (screenX - messageWindowWidth) / 2
    local messageWindowPosY = (screenY - messageWindowHeight) / 2
    local messageWindowElement = guiCreateWindow(messageWindowPosX, messageWindowPosY, messageWindowWidth, messageWindowHeight, messageTitle)

    guiWindowSetSizable(messageWindowElement, false)

    local messageIconWidth = 42
    local messageIconHeight = 42
    
    local messageIconPosX = (messageWindowWidth - messageIconWidth) / 8
    local messageIconPosY = (messageWindowHeight - messageIconHeight) / 2

    guiCreateStaticImage(messageIconPosX, messageIconPosY, messageIconWidth, messageIconHeight, messageIcons[messageIcon].iconPath, false, messageWindowElement)

    local messageCaptionWidth = messageWindowWidth - (messageIconPosX + messageIconWidth + 10 + 5)
    local messageCaptionHeight = 16

    local messageContentWidth = messageWindowWidth - (messageIconPosX + messageIconWidth + 10 + 5)
    local messageContentHeight = 18

    local messageCaptionPosX = messageIconPosX + messageIconWidth + 10
    local messageCaptionPosY = messageIconPosY + (messageIconHeight - messageCaptionHeight - messageContentHeight) / 2
    local messageCaptionElement = guiCreateLabel(messageCaptionPosX, messageCaptionPosY, messageCaptionWidth, messageCaptionHeight, messageIcons[messageIcon].iconCaption, false, messageWindowElement)

    guiSetFont(messageCaptionElement, "default-bold-small")

    local messageContentPosX = messageIconPosX + messageIconWidth + 10
    local messageContentPosY = messageIconPosY + (messageIconHeight - messageContentHeight) - 5
    local messageContentElement = guiCreateLabel(messageContentPosX, messageContentPosY, messageContentWidth, messageContentHeight * 4  , messageContent, false, messageWindowElement)

    guiLabelSetHorizontalAlign(messageContentElement, "left", true)

    local messageButtonWidth = 50
    local messageButtonHeight = 30

    local messageButtonPosX = (messageWindowWidth - 5) - (messageButtonWidth + 5) * #messageButtons[messageButton]
    local messageButtonPosY = (messageWindowHeight - 10) - messageButtonHeight

    for i, v in ipairs(messageButtons[messageButton]) do
        local messageButtonElement = guiCreateButton(messageButtonPosX, messageButtonPosY, messageButtonWidth, messageButtonHeight, v, false, messageWindowElement)

        if i == messageButtonDefault then
            guiSetFont(messageButtonElement, "default-bold-small")
        end

        addEventHandler("onClientGUIClick", messageButtonElement, messageClick, false)
        messageButtonPosX = messageButtonPosX + messageButtonWidth + 5
    end

    messageBoxWindows[messageWindowElement] = {messageTitle, messageContent, messageIcon, messageButton}
    messageBoxCallbacks[messageWindowElement] = {messageCallback, sourceResource}
end

function messageBoxEx(messageTitle, messageContent, messageIcon, messageButton, messageButtonDefault, messageSound, messageSoundVolume)
    if not messageTitle or type(messageTitle) ~= "string" then
        error("Bad argument @ 'messageBoxEx' [Expected string at argument 1, got " .. type(messageTitle) .. "]")
    end

    messageTitle = utf8.upper(messageTitle)

    if not messageContent or type(messageContent) ~= "string" then
        error("Bad argument @ 'messageBoxEx' [Expected string at argument 2, got " .. type(messageContent) .. "]")
    end

    if not messageIcon or type(messageIcon) ~= "string" then
        messageIcon = "INFO"
    end

    messageIcon = utf8.upper(messageIcon)

    if not messageIcons[messageIcon] then
        error("Bad argument @ 'messageBoxEx' [Invalid type at argument 3, got '" .. tostring(messageIcon) .. "']")
    end

    if not messageButton or type(messageButton) ~= "string" then
       messageButton = "OK"
    end

    messageButton = utf8.upper(messageButton)

    if not messageButtons[messageButton] then
        error("Bad argument @ 'messageBoxEx' [Invalid type at argument 4, got '" .. tostring(messageButton) .. "']")
    end

    if messageButtonDefault then
        if type(messageButtonDefault) ~= "number" then
            error("Bad argument @ 'messageBoxEx' [Expected number at argument 5, got " .. type(messageButtonDefault) .. "]")
        elseif #messageButtons[messageButton] < messageButtonDefault then
            error("Bad argument @ 'messageBoxEx' [Invalid default at argument 5, " .. messageButton .. " only have " .. tostring(#messageButtons[messageButon]) .. " buttons.]")
        end
    else
        messageButtonDefault = 1
    end

    if messageSound then
        if type(messageSound) ~= "string" then
            error("Bad argument @ 'messageBoxEx' [Expected string at argument 6, got " .. type(messageSound) .. "]")
        elseif not messageSounds[messageSound] then
            error("Bad argument @ 'messageBoxEx' [Invalid type at argument 6, got '" .. messageSound .. "']")
        end
    else
        messageSound = messageIcon
    end

    if messageSoundVolume then
        if type(messageSoundVolume) ~= "number" then
            error("Bad argument @ 'messageBoxEx' [Expected number at argument 7, got " .. type(messageSoundVolume) .. "]")
        elseif messageSoundVolume > 1 or messageSoundVolume < 1 then
            error("Bad argument @ 'messageBoxEx' [Invalid volume at argument 7, got '" .. tostring(messageSoundVolume) .. "']")
        end
    else
        messageSoundVolume = 1
    end

    messageBeep(messageSound, messageSoundVolume)

    local messageWindowWidth = 400
    local messageWindowHeight = 200

    local messageWindowPosX = (screenX - messageWindowWidth) / 2
    local messageWindowPosY = (screenY - messageWindowHeight) / 2
    local messageWindowElement = guiCreateWindow(messageWindowPosX, messageWindowPosY, messageWindowWidth, messageWindowHeight, messageTitle)

    guiWindowSetSizable(messageWindowElement, false)

    local messageIconWidth = 42
    local messageIconHeight = 42
    
    local messageIconPosX = (messageWindowWidth - messageIconWidth) / 8
    local messageIconPosY = (messageWindowHeight - messageIconHeight) / 2

    guiCreateStaticImage(messageIconPosX, messageIconPosY, messageIconWidth, messageIconHeight, messageIcons[messageIcon].iconPath, false, messageWindowElement)

    local messageCaptionWidth = messageWindowWidth - (messageIconPosX + messageIconWidth + 10 + 5)
    local messageCaptionHeight = 16

    local messageContentWidth = messageWindowWidth - (messageIconPosX + messageIconWidth + 10 + 5)
    local messageContentHeight = 18

    local messageCaptionPosX = messageIconPosX + messageIconWidth + 10
    local messageCaptionPosY = messageIconPosY + (messageIconHeight - messageCaptionHeight - messageContentHeight) / 2
    local messageCaptionElement = guiCreateLabel(messageCaptionPosX, messageCaptionPosY, messageCaptionWidth, messageCaptionHeight, messageIcons[messageIcon].iconCaption, false, messageWindowElement)

    guiSetFont(messageCaptionElement, "default-bold-small")

    local messageContentPosX = messageIconPosX + messageIconWidth + 10
    local messageContentPosY = messageIconPosY + (messageIconHeight - messageContentHeight) - 5
    local messageContentElement = guiCreateLabel(messageContentPosX, messageContentPosY, messageContentWidth, messageContentHeight * 4  , messageContent, false, messageWindowElement)

    guiLabelSetHorizontalAlign(messageContentElement, "left", true)

    local messageButtonWidth = 50
    local messageButtonHeight = 30

    local messageButtonPosX = (messageWindowWidth - 5) - (messageButtonWidth + 5) * #messageButtons[messageButton]
    local messageButtonPosY = (messageWindowHeight - 10) - messageButtonHeight
    local messageButtonElements = {}

    for i, v in ipairs(messageButtons[messageButton]) do
        local messageButtonElement = guiCreateButton(messageButtonPosX, messageButtonPosY, messageButtonWidth, messageButtonHeight, v, false, messageWindowElement)

        if i == messageButtonDefault then
            guiSetFont(messageButtonElement, "default-bold-small")
        end

        addEventHandler("onClientGUIClick", messageButtonElement, messageClickEx, false)
        messageButtonElements[i] = messageButtonElement
        messageButtonPosX = messageButtonPosX + messageButtonWidth + 5
    end

    messageBoxWindows[messageWindowElement] = {messageTitle, messageContent, messageIcon, messageButton}

    return messageButtonElements[1], messageButtonElements[2], messageButtonElements[3]
end