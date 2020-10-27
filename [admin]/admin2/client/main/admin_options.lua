--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\main\admin_options.lua
*
*	Original File by lil_Toady
*
**************************************]]
aOptionsTab = {}

function aOptionsTab.Create(tab)
    aOptionsTab.Tab = tab

    guiCreateHeader(0.03, 0.05, 0.10, 0.05, "Main:", true, aOptionsTab.Tab)
    aOptionsTab.AdminChatOutput =
        guiCreateCheckBox(0.05, 0.1, 0.47, 0.04, "Output admin messages to chat box", aGetSetting("adminChatOutput"), true, aOptionsTab.Tab)
    aOptionsTab.AdminChatSound =
        guiCreateCheckBox(0.05, 0.15, 0.47, 0.04, "Play sound on incoming admin chat message", aGetSetting("adminChatSound"), true, aOptionsTab.Tab)

    --guiCreateHeader(0.03, 0.30, 0.47, 0.04, "Appearance:", true, aOptionsTab.Tab)
    guiCreateHeader(0.63, 0.05, 0.10, 0.05, "Account:", true, aOptionsTab.Tab)
    aOptionsTab.AutoLogin =
        guiCreateCheckBox(0.65, 0.10, 0.47, 0.04, "Auto-login by serial", false, true, aOptionsTab.Tab)
    guiCreateHeader(0.63, 0.15, 0.25, 0.05, "Change Password:", true, aOptionsTab.Tab)
    guiCreateLabel(0.65, 0.20, 0.15, 0.05, "Old password:", true, aOptionsTab.Tab)
    guiCreateLabel(0.65, 0.25, 0.15, 0.05, "New password:", true, aOptionsTab.Tab)
    guiCreateLabel(0.65, 0.30, 0.15, 0.05, "Confirm:", true, aOptionsTab.Tab)
    aOptionsTab.PasswordOld = guiCreateEdit(0.80, 0.20, 0.15, 0.045, "", true, aOptionsTab.Tab)
    aOptionsTab.PasswordNew = guiCreateEdit(0.80, 0.25, 0.15, 0.045, "", true, aOptionsTab.Tab)
    aOptionsTab.PasswordConfirm = guiCreateEdit(0.80, 0.30, 0.15, 0.045, "", true, aOptionsTab.Tab)
    guiEditSetMasked(aOptionsTab.PasswordOld, true)
    guiEditSetMasked(aOptionsTab.PasswordNew, true)
    guiEditSetMasked(aOptionsTab.PasswordConfirm, true)
    aOptionsTab.PasswordChange = guiCreateButton(0.85, 0.35, 0.10, 0.04, "Accept", true, aOptionsTab.Tab)
    guiCreateHeader(0.03, 0.65, 0.20, 0.055, "Performance:", true, aOptionsTab.Tab)
    guiCreateStaticImage(0.03, 0.69, 0.94, 0.0025, "client\\images\\dot.png", true, aOptionsTab.Tab)
    guiCreateLabel(0.05, 0.71, 0.20, 0.055, "Performance priority:", true, aOptionsTab.Tab)
    guiCreateLabel(0.11, 0.76, 0.10, 0.05, "Memory", true, aOptionsTab.Tab)
    guiCreateLabel(0.11, 0.81, 0.10, 0.05, "Auto", true, aOptionsTab.Tab)
    guiCreateLabel(0.11, 0.86, 0.10, 0.05, "Speed", true, aOptionsTab.Tab)
    aOptionsTab.PerformanceRAM = guiCreateRadioButton(0.07, 0.75, 0.05, 0.055, "", true, aOptionsTab.Tab)
    aOptionsTab.PerformanceAuto = guiCreateRadioButton(0.07, 0.80, 0.05, 0.055, "", true, aOptionsTab.Tab)
    aOptionsTab.PerformanceCPU = guiCreateRadioButton(0.07, 0.85, 0.05, 0.055, "", true, aOptionsTab.Tab)
    if (aGetSetting("performance") == "RAM") then
        guiRadioButtonSetSelected(aOptionsTab.PerformanceRAM, true)
    elseif (aGetSetting("performance") == "CPU") then
        guiRadioButtonSetSelected(aOptionsTab.PerformanceCPU, true)
    else
        guiRadioButtonSetSelected(aOptionsTab.PerformanceAuto, true)
    end
    aOptionsTab.PerformanceAdvanced = guiCreateButton(0.05, 0.91, 0.11, 0.04, "Advanced", true, aOptionsTab.Tab)
    aPerformance()
    guiCreateLabel(0.70, 0.90, 0.19, 0.055, "Refresh Delay(MS):", true, aOptionsTab.Tab)
    aOptionsTab.RefreshDelay = guiCreateEdit(0.89, 0.90, 0.08, 0.045, "50", true, aOptionsTab.Tab)

    if (tonumber(aGetSetting("adminChatLines"))) then
        guiSetText(aOptionsTab.AdminChatLines, aGetSetting("adminChatLines"))
    end
    if ((tonumber(aGetSetting("refreshDelay"))) and (tonumber(aGetSetting("refreshDelay")) >= 50)) then
        guiSetText(aOptionsTab.RefreshDelay, aGetSetting("refreshDelay"))
    end

    addEventHandler("onClientGUIClick", aOptionsTab.Tab, aOptionsTab.onClientClick)
    addEventHandler("aClientResourceStop", getResourceRootElement(), aOptionsTab.onClientResourceStop)
    addEventHandler("onClientGUIScroll", aOptionsTab.Tab, aOptionsTab.onClientScroll)
    addEventHandler("onClientGUITabSwitched", aOptionsTab.Tab, aOptionsTab.onTabSwitched, false)
end

function aOptionsTab.onClientClick(button)
    if (button == "left") then
        if (source == aOptionsTab.PerformanceCPU) then
            for id, element in ipairs(getElementChildren(aPerformanceForm)) do
                if (getElementType(element) == "gui-checkbox") then
                    guiCheckBoxSetSelected(element, false)
                end
            end
        elseif (source == aOptionsTab.PerformanceRAM) then
            for id, element in ipairs(getElementChildren(aPerformanceForm)) do
                if (getElementType(element) == "gui-checkbox") then
                    guiCheckBoxSetSelected(element, true)
                end
            end
        elseif (source == aOptionsTab.PerformanceAdvanced) then
            aPerformance()
        elseif (source == aOptionsTab.AutoLogin) then
            triggerServerEvent("aAdmin", getLocalPlayer(), "autologin", guiCheckBoxGetSelected(aOptionsTab.AutoLogin))
        elseif (source == aOptionsTab.PasswordOld) then
            guiSetInputEnabled(true)
        elseif (source == aOptionsTab.PasswordNew) then
            guiSetInputEnabled(true)
        elseif (source == aOptionsTab.PasswordConfirm) then
            guiSetInputEnabled(true)
        elseif (source == aOptionsTab.PasswordChange) then
            local passwordNew, passwordConf =
                guiGetText(aOptionsTab.PasswordNew),
                guiGetText(aOptionsTab.PasswordConfirm)
            if (passwordNew == "") then
                messageBox("Enter the new password", MB_ERROR, MB_OK)
            elseif (passwordConf == "") then
                messageBox("Confirm the new password", MB_ERROR, MB_OK)
            elseif (string.len(passwordNew) < 4) then
                messageBox("The new password must be at least 4 characters long", MB_ERROR, MB_OK)
            elseif (passwordNew ~= passwordConf) then
                messageBox("Confirmed password doesn't match", MB_ERROR, MB_OK)
            else
                triggerServerEvent(
                    "aAdmin",
                    getLocalPlayer(),
                    "password",
                    guiGetText(aOptionsTab.PasswordOld),
                    passwordNew,
                    passwordConf
                )
            end
        elseif (source == aOptionsTab.AdminChatOutput) then
            aSetSetting("adminChatOutput", guiCheckBoxGetSelected(aOptionsTab.AdminChatOutput))
        elseif (source == aOptionsTab.AdminChatSound) then
            aSetSetting("adminChatSound", guiCheckBoxGetSelected(aOptionsTab.AdminChatSound))
        end
    end
end

function aOptionsTab.onClientResourceStop()
    aSetSetting("adminChatOutput", guiCheckBoxGetSelected(aOptionsTab.AdminChatOutput))
    aSetSetting("adminChatSound", guiCheckBoxGetSelected(aOptionsTab.AdminChatSound))
    aSetSetting("adminChatLines", guiGetText(aOptionsTab.AdminChatLines))
    aSetSetting("refreshDelay", guiGetText(aOptionsTab.RefreshDelay))

    if (guiRadioButtonGetSelected(aOptionsTab.PerformanceRAM)) then
        aSetSetting("performance", "RAM")
    elseif (guiRadioButtonGetSelected(aOptionsTab.PerformanceCPU)) then
        aSetSetting("performance", "CPU")
    else
        aSetSetting("performance", "Auto")
    end
end

function aOptionsTab.onClientScroll(element)
    if (source == aOptionsTab.MouseSense) then
        guiSetText(
            aOptionsTab.MouseSenseCur,
            "Cursor sensivity: (" .. string.sub(guiScrollBarGetScrollPosition(source) / 50, 0, 4) .. ")"
        )
    end
end

function aOptionsTab.onTabSwitched()
    -- Refresh checkbox status (in case settings were changed in the options tab)
    guiCheckBoxSetSelected(aChatTab.AdminChatSound, aGetSetting("adminChatSound"))
    guiCheckBoxSetSelected(aChatTab.AdminChatOutput, aGetSetting("adminChatOutput"))
end
