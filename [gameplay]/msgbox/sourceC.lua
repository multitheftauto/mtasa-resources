local screenX, screenY = guiGetScreenSize()

local boxWidth = 350
local boxHeight = 175

local boxButtonsWidth = 75
local boxButtonsHeight = 30

local messageBoxElements = {}
local messageBoxTypes = {
    ["info"] = {
        boxCaption = "Information",
        boxSound = 11,
        boxIcon = "info.png"
    },
    ["question"] = {
        boxCaption = "Question",
        boxSound = 10,
        boxIcon = "question.png"
    },
    ["warning"] = {
        boxCaption = "Warning",
        boxSound = 40,
        boxIcon = "warning.png"
    },
    ["error"] = {
        boxCaption = "Error",
        boxSound = 101,
        boxIcon = "error.png"
    }
}

local messageBoxButtons = {
    ["ok"] = {
        [1] = "OK"
    },
    ["okcancel"] = {
        [1] = "OK",
        [2] = "Cancel"
    },
    ["retrycancel"] = {
        [1] = "Retry",
        [2] = "Cancel"
    },
    ["yesno"] = {
        [1] = "Yes",
        [2] = "No"
    },
    ["yesnocancel"] = {
        [1] = "Yes",
        [2] = "No",
        [3] = "Cancel"
    }
}

function createMessageBox(boxTitle, boxMessage, boxType, boxButtons)
    if not boxTitle or type(boxTitle) ~= "string" then
        error("Bad argument @ 'createMessageBox' [Expected string at argument 1, got " .. type(boxTitle) .. "]", 2)
        return
    end

    if not boxMessage or type(boxMessage) ~= "string" then
        error("Bad argument @ 'createMessageBox' [Expected string at argument 2, got " .. type(boxMessage) .. "]", 2)
        return
    end

    if not boxType or type(boxType) ~= "string" then
        error("Bad argument @ 'createMessageBox' [Expected string at argument 3, got " .. type(boxType) .. "]", 2)
        return
    end

    if not boxButtons or type(boxButtons) ~= "string" then
        boxButtons = "ok"
    end

    if not messageBoxTypes[boxType] then
        error("Bad argument @ 'createMessageBox' [Unknown messageBoxType at argument 3", 2)
        return
    end

    if not messageBoxButtons[boxButtons] then
        error("Bad argument @ 'createMessageBox' [Unknown messageBoxButtons at argument 4", 2)
        return
    end

    if messageBoxTypes[boxType].boxSound then
        playSoundFrontEnd(messageBoxTypes[boxType].boxSound)
    end

    local boxPosX = (screenX - boxWidth) / 2
    local boxPosY = (screenY - boxHeight) / 2
    local boxElement = guiCreateWindow(boxPosX, boxPosY, boxWidth, boxHeight, utf8.upper(boxTitle), false)
    guiWindowSetSizable(boxElement, false)

    local boxImageWidth = 42
    local boxImageHeight = 42

    local boxImagePosX = 30
    local boxImagePosY = 65

    local boxImageCenterX = boxImagePosX + boxImageWidth / 2
    local boxImageCenterY = boxImagePosY + boxImageHeight / 2
    local boxImage = guiCreateStaticImage(boxImagePosX, boxImagePosY, boxImageWidth, boxImageHeight, "files/" .. messageBoxTypes[boxType].boxIcon, false, boxElement)

    local boxCaptionWidth = boxWidth - (boxImagePosX + boxImageWidth)
    local boxCaptionHeight = 16

    local boxCaptionPosX = 10 + (boxImagePosX + boxImageWidth)
    local boxCaptionPosY = boxImageCenterY - dxGetFontHeight(1, "default-bold-small")
    local boxCaption = guiCreateLabel(boxCaptionPosX, boxCaptionPosY, boxCaptionWidth, boxCaptionHeight, messageBoxTypes[boxType].boxCaption, false, boxElement)
    guiSetFont(boxCaption, "default-bold-small")

    local boxLabelWidth = boxWidth - (boxImagePosX + boxImageWidth)
    local boxLabelHeight = 48

    local boxLabelPosX = 10 + (boxImagePosX + boxImageWidth)
    local boxLabelPosY = boxImageCenterY - 2.5
    local boxLabel = guiCreateLabel(boxLabelPosX, boxLabelPosY, boxLabelWidth, boxLabelHeight, boxMessage, false, boxElement)
    guiSetFont(boxCaption, "default")

    local boxButtonsPosX = boxWidth - (boxButtonsWidth + 5) * #messageBoxButtons[boxButtons]
    local boxButtonsPosY = boxHeight - boxButtonsHeight - 5
    local boxButtonsElements = {}

    for i = 1, #messageBoxButtons[boxButtons] do
        boxButtonsElements[i] = guiCreateButton(boxButtonsPosX, boxButtonsPosY, boxButtonsWidth, boxButtonsHeight, messageBoxButtons[boxButtons][i], false, boxElement)
        boxButtonsPosX = boxButtonsPosX + boxButtonsWidth + 5

        messageBoxElements[boxButtonsElements[i]] = boxElement
        addEventHandler("onClientGUIClick", boxButtonsElements[i], onButtonClick)
    end

    return boxButtonsElements[1], boxButtonsElements[2], boxButtonsElements[3]
end

function guiShowMessageBox(boxMessage, boxType, boxTitle, _, boxButtons)
    outputDebugString("Note that guiShowMessageBox is a deprecated function of msgbox. Please use the createMessageBox function in the future.", 2)
    createMessageBox(boxTitle, boxMessage, boxType, boxButtons)
end

function onButtonClick()
    if source ~= this then
        return
    end

    if messageBoxElements[source] then
        destroyElement(messageBoxElements[source])
    end
end