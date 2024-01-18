--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_team.lua
*
*	Original File by lil_Toady
*
**************************************]]
aTeam = {
    Form = nil,
    NewVisible = false
}

function aTeam.Show()
    if (not aTeam.Form) then
        local x, y = guiGetScreenSize()
        aTeam.Form = guiCreateWindow(x / 2 - 150, y / 2 - 125, 300, 250, "Player Team Management", false)
        aTeam.Label =
            guiCreateLabel(0.03, 0.09, 0.94, 0.07, "Select a team from the list or create a new one", true, aTeam.Form)
        guiLabelSetHorizontalAlign(aTeam.Label, "center")
        guiLabelSetColor(aTeam.Label, 255, 0, 0)
        aTeam.List = guiCreateGridList(0.03, 0.18, 0.50, 0.71, true, aTeam.Form)
        guiGridListAddColumn(aTeam.List, "Teams", 0.85)
        aTeam.Update = guiCreateButton(0.03, 0.90, 0.50, 0.08, "Refresh", true, aTeam.Form)
        aTeam.New = guiCreateButton(0.55, 0.18, 0.42, 0.09, "New Team", true, aTeam.Form, "createteam")
        aTeam.Delete = guiCreateButton(0.55, 0.28, 0.42, 0.09, "Delete Team", true, aTeam.Form, "destroyteam")
        aTeam.NameLabel = guiCreateLabel(0.55, 0.19, 0.42, 0.07, "New Team Name:", true, aTeam.Form)
        aTeam.Name = guiCreateEdit(0.55, 0.26, 0.42, 0.10, "", true, aTeam.Form)
        guiHandleInput(aTeam.Name)
        aTeam.Color = guiCreateColorPicker(0.553, 0.37, 0.41, 0.11, 255, 0, 0, true, aTeam.Form)
        aTeam.Create = guiCreateButton(0.55, 0.50, 0.20, 0.09, "Create", true, aTeam.Form, "createteam")
        aTeam.Cancel = guiCreateButton(0.77, 0.50, 0.20, 0.09, "Cancel", true, aTeam.Form)
        aTeam.Accept = guiCreateButton(0.55, 0.88, 0.20, 0.09, "Select", true, aTeam.Form)
        aTeam.Hide = guiCreateButton(0.77, 0.88, 0.20, 0.09, "Close", true, aTeam.Form)

        addEventHandler("onClientGUIClick", aTeam.Form, aTeam.onClick)
        addEventHandler("onClientGUIDoubleClick", aTeam.Form, aTeam.onDoubleClick)
        addEventHandler("onClientGUIFocus", guiRoot, aTeam.onGUIFocus)
        --Register With Admin Form
        aRegister("PlayerTeam", aTeam.Form, aTeam.Show, aTeam.Close)
    end
    aTeam.Refresh()
    aTeam.ShowNew(false)
    guiSetVisible(aTeam.Form, true)
    guiBringToFront(aTeam.Form)
end

function aTeam.Close(destroy)
    guiSetInputEnabled(false)
    if (destroy) then
        if (aTeam.Form) then
            removeEventHandler("onClientGUIClick", aTeam.Form, aTeam.onClick)
            removeEventHandler("onClientGUIDoubleClick", aTeam.Form, aTeam.onDoubleClick)
            removeEventHandler("onClientGUIFocus", guiRoot, aTeam.onGUIFocus)
            destroyElement(aTeam.Form)
            aTeam.Form = nil
        end
    else
        guiSetVisible(aTeam.Form, false)
        guiSetText(aTeam.Name, "")
        guiColorPickerSetColor(aTeam.Color)
    end
end

function aTeam.onDoubleClick(button)
    if (button == "left") then
        if (source == aTeam.List) then
            if (guiGridListGetSelectedItem(aTeam.List) ~= -1) then
                local team = guiGridListGetItemText(aTeam.List, guiGridListGetSelectedItem(aTeam.List), 1)
                triggerServerEvent("aPlayer", localPlayer, getSelectedPlayer(), "setteam", getTeamFromName(team))
                aTeam.Close(false)
            end
        end
    end
end

function aTeam.onClick(button)
    if (button == "left") then
        if (source == aTeam.New) then
            aTeam.ShowNew(true)
        elseif (source == aTeam.Update) then
            aTeam.Refresh()
        elseif (source == aTeam.Delete) then
            if (guiGridListGetSelectedItem(aTeam.List) == -1) then
                messageBox("No team selected!", MB_WARNING)
            else
                local team = guiGridListGetItemData(aTeam.List, guiGridListGetSelectedItem(aTeam.List), 1)
                if (messageBox('Are you sure to delete "' .. getTeamName(team) .. '"?', MB_QUESTION, MB_YESNO)) then
                    triggerServerEvent("aTeam", localPlayer, "destroyteam", team)
                end
            end
            setTimer(aTeam.Refresh, 2000, 1)
        elseif (source == aTeam.Create) then
            local team = guiGetText(aTeam.Name)
            if ((team == nil) or (team == false) or (team == "")) then
                messageBox("Enter the team name!", MB_WARNING)
            elseif (getTeamFromName(team)) then
                messageBox("A team with this name already exists", MB_ERROR)
            else
                local r, g, b = guiColorPickerGetColor(aTeam.Color)
                triggerServerEvent(
                    "aTeam",
                    localPlayer,
                    "createteam",
                    team,
                    r,
                    g,
                    b
                )
                aTeam.ShowNew(false)
                guiSetText(aTeam.Name, "")
                guiColorPickerSetColor(aTeam.Color)
            end
            setTimer(aTeam.Refresh, 2000, 1)
        elseif (source == aTeam.Cancel) then
            aTeam.ShowNew(false)
            guiSetText(aTeam.Name, "")
            guiColorPickerSetColor(aTeam.Color)
        elseif (source == aTeam.Accept) then
            if (guiGridListGetSelectedItem(aTeam.List) == -1) then
                messageBox("No team selected!", MB_WARNING)
            else
                local team = guiGridListGetItemData(aTeam.List, guiGridListGetSelectedItem(aTeam.List), 1)
                triggerServerEvent("aPlayer", localPlayer, getSelectedPlayer(), "setteam", team)
                aTeam.Close(false)
            end
        elseif (source == aTeam.Hide) then
            aTeam.Close(false)
        end
    end
end

function aTeam.ShowNew(bool)
    aTeam.NewVisible = bool
    guiSetVisible(aTeam.New, not bool)
    guiSetVisible(aTeam.Delete, not bool)
    guiSetVisible(aTeam.NameLabel, bool)
    guiSetVisible(aTeam.Name, bool)
    guiSetVisible(aTeam.Color, bool)
    guiSetVisible(aTeam.Create, bool)
    guiSetVisible(aTeam.Cancel, bool)
end

function aTeam.onGUIFocus()
    if (aTeam.NewVisible) then
        if (source == aTeam.Form or getElementParent(source) == aTeam.Form or source == aColor.Form or getElementParent(source) == aColor.Form) then
            guiSetVisible(aTeam.Color, true)
            return
        end
    end
    guiSetVisible(aTeam.Color, false)
end

function aTeam.Refresh()
    if (aTeam.List) then
        local sortDirection = guiGetProperty(aTeam.List, "SortDirection")
        guiGridListClear(aTeam.List)
        guiSetProperty(aTeam.List, "SortDirection", "None")
        for id, team in ipairs(getElementsByType("team")) do
            local row = guiGridListAddRow(aTeam.List, getTeamName(team))
            local r, g, b = getTeamColor(team)
            guiGridListSetItemColor(aTeam.List, row, 1, r, g, b)
            guiGridListSetItemData(aTeam.List, row, 1, team)
        end
        guiSetProperty(aTeam.List, "SortDirection", sortDirection)
    end
end
