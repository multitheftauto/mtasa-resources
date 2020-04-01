--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_messagebox.lua
*
*	Original File by lil_Toady
*
**************************************]]
MB_WARNING = 1
MB_ERROR = 2
MB_QUESTION = 3
MB_INFO = 4

MB_YESNO = 1
MB_OK = 2

aMessageBox = {
    type = {"Warning", "Error", "Question", "Info"},
    Thread = nil,
    Result = false
}

addEvent(EVENT_MESSAGE_BOX, true)

function messageBox(message, icon, type)
    if (message) then
        return aMessageBox.Show(message, icon or MB_INFO, type or MB_OK)
    end
    return false
end

addEventHandler(EVENT_MESSAGE_BOX, getLocalPlayer(), messageBox)

function aMessageBox.Show(message, icon, type)
    local x, y = guiGetScreenSize()
    if (aMessageBox.Form == nil) then
        aMessageBox.Form = guiCreateWindow(x / 2 - 150, y / 2 - 64, 300, 110, "", false)
        guiWindowSetSizable(aMessageBox.Form, false)
        aMessageBox.Warning =
            guiCreateStaticImage(10, 32, 60, 60, "client\\images\\warning.png", false, aMessageBox.Form)
        aMessageBox.Question =
            guiCreateStaticImage(10, 32, 60, 60, "client\\images\\question.png", false, aMessageBox.Form)
        aMessageBox.Error = guiCreateStaticImage(10, 32, 60, 60, "client\\images\\error.png", false, aMessageBox.Form)
        aMessageBox.Info = guiCreateStaticImage(10, 32, 60, 60, "client\\images\\info.png", false, aMessageBox.Form)
        aMessageBox.Label = guiCreateLabel(100, 32, 180, 16, "", false, aMessageBox.Form)
        guiLabelSetHorizontalAlign(aMessageBox.Label, "center")
        aMessageBox.Yes = guiCreateButton(120, 70, 55, 17, "Yes", false, aMessageBox.Form)
        aMessageBox.No = guiCreateButton(180, 70, 55, 17, "No", false, aMessageBox.Form)
        aMessageBox.Ok = guiCreateButton(160, 70, 55, 17, "Ok", false, aMessageBox.Form)
        guiSetProperty(aMessageBox.Form, "AlwaysOnTop", "true")

        bindKey("enter", "down", aMessageBox.Accept, true)
        bindKey("y", "down", aMessageBox.Accept, true)
        bindKey("n", "down", aMessageBox.Accept, false)
        addEventHandler("onClientGUIClick", aMessageBox.Yes, aMessageBox.onClick)
        addEventHandler("onClientGUIClick", aMessageBox.No, aMessageBox.onClick)
        addEventHandler("onClientGUIClick", aMessageBox.Ok, aMessageBox.onClick)

        --Register With Admin Form
        aRegister("MessageBox", aMessageBox.Form, aMessageBox.Show, aMessageBox.Close)
    end

    guiSetText(aMessageBox.Form, aMessageBox.type[type])
    guiSetText(aMessageBox.Label, tostring(message))
    local width = guiLabelGetTextExtent(aMessageBox.Label)
    if (width > 180) then
        guiSetSize(aMessageBox.Form, 100 + width + 20, 110, false)
        guiSetSize(aMessageBox.Label, width, 16, false)
    else
        guiSetSize(aMessageBox.Form, 300, 110, false)
        guiSetSize(aMessageBox.Label, 180, 16, false)
    end
    local sx, sy = guiGetSize(aMessageBox.Form, false)
    guiSetPosition(aMessageBox.Ok, sx / 2 - 22, 70, false)
    guiSetPosition(aMessageBox.Form, x / 2 - sx / 2, y / 2 - sy / 2, false)
    guiSetVisible(aMessageBox.Form, true)
    guiBringToFront(aMessageBox.Form)

    guiSetVisible(aMessageBox.Warning, icon == MB_WARNING)
    guiSetVisible(aMessageBox.Question, icon == MB_QUESTION)
    guiSetVisible(aMessageBox.Error, icon == MB_ERROR)
    guiSetVisible(aMessageBox.Info, icon == MB_INFO)

    --guiSetVisible ( aInputForm, false )

    if (type == MB_YESNO) then
        guiSetVisible(aMessageBox.Yes, true)
        guiSetVisible(aMessageBox.No, true)
        guiSetVisible(aMessageBox.Ok, false)
    else
        guiSetPosition(aMessageBox.Ok, sx / 2 - 22, 70, false)
        guiSetVisible(aMessageBox.Ok, true)
        guiSetVisible(aMessageBox.Yes, false)
        guiSetVisible(aMessageBox.No, false)
    end

    aMessageBox.Thread = sourceCoroutine
    aMessageBox.Result = false
    coroutine.yield()
    aMessageBox.Thread = nil
    return aMessageBox.Result
end

function aMessageBox.Close(destroy)
    if (aMessageBox.Form) then
        if (destroy) then
            unbindKey("enter", "down", aMessageBox.Accept)
            unbindKey("n", "down", aMessageBox.Accept)
            destroyElement(aMessageBox.Form)
            aMessageBox.Form = nil
        else
            guiSetVisible(aMessageBox.Form, false)
        end
        if (aMessageBox.Thread) then
            coroutine.resume(aMessageBox.Thread)
        end
    end
end

function aMessageBox.Accept(key, state, result)
    if (guiGetVisible(aMessageBox.Form)) then
        aMessageBox.Result = result
        aMessageBox.Close(false)
    end
end

function aMessageBox.onClick(button)
    if (button == "left") then
        if (source == aMessageBox.No) then
            aMessageBox.Result = false
            aMessageBox.Close(false)
        elseif ((source == aMessageBox.Yes) or (source == aMessageBox.Ok)) then
            aMessageBox.Result = true
            aMessageBox.Close(false)
        end
    end
end
