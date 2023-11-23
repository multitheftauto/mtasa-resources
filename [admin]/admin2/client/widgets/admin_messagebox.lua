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

addEventHandler(EVENT_MESSAGE_BOX, localPlayer, messageBox)

function aMessageBox.Show(message, icon, type)
    local x, y = guiGetScreenSize()
    if (aMessageBox.Form == nil) then
        aMessageBox.Form = guiCreateWindow(x / 2 - 200, y / 2 - 75, 400, 150, "", false)
        guiWindowSetSizable(aMessageBox.Form, false)
        guiWindowSetMovable(aMessageBox.Form, false)
        aMessageBox.Warning =
            guiCreateStaticImage(10, 32, 60, 60, "client\\images\\warning.png", false, aMessageBox.Form)
        aMessageBox.Question =
            guiCreateStaticImage(10, 32, 60, 60, "client\\images\\question.png", false, aMessageBox.Form)
        aMessageBox.Error = guiCreateStaticImage(10, 32, 60, 60, "client\\images\\error.png", false, aMessageBox.Form)
        aMessageBox.Info = guiCreateStaticImage(10, 32, 60, 60, "client\\images\\info.png", false, aMessageBox.Form)
        aMessageBox.Label = guiCreateLabel(100, 32, 290, 60, "", false, aMessageBox.Form)
        guiLabelSetHorizontalAlign(aMessageBox.Label, "center", true)
        aMessageBox.Yes = guiCreateButton(110, 100, 80, 20, "Yes", false, aMessageBox.Form)
        aMessageBox.No = guiCreateButton(210, 100, 80, 20, "No", false, aMessageBox.Form)
        aMessageBox.Ok = guiCreateButton(160, 100, 80, 20, "Ok", false, aMessageBox.Form)
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

    local mbX, mbY = guiGetSize(aMessageBox.Form, false)
    
    guiSetPosition(aMessageBox.Form, x / 2 - mbX / 2, y / 2 - mbY / 2, false)
    guiSetVisible(aMessageBox.Form, true)
    guiBringToFront(aMessageBox.Form)
    guiFocus(aMessageBox.Form)

    guiSetVisible(aMessageBox.Warning, icon == MB_WARNING)
    guiSetVisible(aMessageBox.Question, icon == MB_QUESTION)
    guiSetVisible(aMessageBox.Error, icon == MB_ERROR)
    guiSetVisible(aMessageBox.Info, icon == MB_INFO)

    --guiSetVisible ( aInputForm, false )

    if (type == MB_YESNO) then
        guiSetPosition(aMessageBox.Yes, mbX / 2 - 50, 100, false)
        guiSetPosition(aMessageBox.No, mbX / 2 + 50, 100, false)
        guiSetVisible(aMessageBox.Yes, true)
        guiSetVisible(aMessageBox.No, true)
        guiSetVisible(aMessageBox.Ok, false)
    else
        guiSetPosition(aMessageBox.Ok, mbX / 2 - 50, 100, false)
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
