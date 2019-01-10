--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_report.lua
*
*	Original File by lil_Toady
*
**************************************]]
aReport = {
    Form = nil
}

function aReport.Open()
    if (not aReport.Form) then
        local x, y = guiGetScreenSize()
        aReport.Form = guiCreateWindow(x / 2 - 150, y / 2 - 150, 300, 300, "Contact Admin", false)
        guiCreateLabel(0.05, 0.11, 0.20, 0.09, "Category:", true, aReport.Form)
        guiCreateLabel(0.05, 0.21, 0.20, 0.09, "Subject:", true, aReport.Form)
        guiCreateLabel(0.05, 0.30, 0.20, 0.07, "Message:", true, aReport.Form)
        aReport.Categories = guiCreateComboBox(0.30, 0.10, 0.65, 0.4, "Question", true, aReport.Form)
        guiComboBoxAddItem(aReport.Categories, "Question")
        guiComboBoxAddItem(aReport.Categories, "Suggestion")
        guiComboBoxAddItem(aReport.Categories, "Abuse")
        guiComboBoxAddItem(aReport.Categories, "Player")
        guiComboBoxAddItem(aReport.Categories, "Other")
        aReport.Subject = guiCreateEdit(0.30, 0.20, 0.65, 0.09, "", true, aReport.Form)
        guiHandleInput(aReport.Subject)
        aReport.Message = guiCreateMemo(0.05, 0.38, 0.90, 0.45, "", true, aReport.Form)
        guiHandleInput(aReport.Message)
        aReport.Accept = guiCreateButton(0.40, 0.88, 0.25, 0.09, "Send", true, aReport.Form)
        aReport.Cancel = guiCreateButton(0.70, 0.88, 0.25, 0.09, "Cancel", true, aReport.Form)

        addEventHandler("onClientGUIClick", aReport.Form, aClientReportClick)
    end
    guiBringToFront(aReport.Form)
    showCursor(true)
end
addCommandHandler("report", aReport.Open)

function aReport.CloseCursor()
    guiSetInputEnabled(false)
    showCursor(false)
end

function aReport.Close(closeCursor)
    if (aReport.Form) then
        removeEventHandler("onClientGUIClick", aReport.Form, aClientReportClick)
        destroyElement(aReport.Form)
        aReport.Form = nil

        if closeCursor then
            aReport.CloseCursor()
        end
    end
end

function aClientReportClick(button)
    if (button == "left") then
        if (source == aReport.Accept) then
            if ((string.len(guiGetText(aReport.Subject)) < 1) or (string.len(guiGetText(aReport.Message)) < 5)) then
                messageBox("Subject/Message missing or too short.", MB_ERROR)
            else
                local tableOut = {}
                tableOut.category = aReport.Categories:getItemText(aReport.Categories.selected)
                tableOut.subject = guiGetText(aReport.Subject)
                tableOut.message = guiGetText(aReport.Message)
                triggerServerEvent("aMessage", localPlayer, "new", tableOut)
                
                -- Hide report window, but don't hide cursor
                aReport.Close(false)
                
                -- Show messageBox and pause
                messageBox("Your message has been submited and will be processed as soon as possible.", MB_INFO)
                
                -- hide the cursor now that the messageBox window has been done
                aReport.CloseCursor()

                -- setTimer(aMessageBox.Close, 3000, 1, true)
            end
        elseif (source == aReport.Subject) then
            guiSetInputEnabled(true)
        elseif (source == aReport.Message) then
            guiSetInputEnabled(true)
        elseif (source == aReport.Cancel) then
            aReport.Close(true)
        end
    end
end
