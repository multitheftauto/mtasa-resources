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
    Form = nil
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
        aTeam.NameLabel = guiCreateLabel(0.55, 0.19, 0.42, 0.07, "Team Name:", true, aTeam.Form)
        aTeam.Color = guiCreateLabel(0.55, 0.37, 0.42, 0.11, "Color:", true, aTeam.Form)
        guiCreateColorPicker(0.70, 0.37, 0.27, 0.11, 255, 0, 0, true, aTeam.Form)
        aTeam.R = guiCreateLabel(0.70, 0.37, 0.42, 0.11, "R:", true, aTeam.Form)
        aTeam.G = guiCreateLabel(0.70, 0.48, 0.42, 0.11, "G:", true, aTeam.Form)
        aTeam.B = guiCreateLabel(0.70, 0.59, 0.42, 0.11, "B:", true, aTeam.Form)
        aTeam.Name = guiCreateEdit(0.55, 0.26, 0.42, 0.10, "", true, aTeam.Form)
        aTeam.Red = guiCreateEdit(0.80, 0.36, 0.15, 0.10, "0", true, aTeam.Form)
        aTeam.Green = guiCreateEdit(0.80, 0.47, 0.15, 0.10, "0", true, aTeam.Form)
        aTeam.Blue = guiCreateEdit(0.80, 0.58, 0.15, 0.10, "0", true, aTeam.Form)
        aTeam.Create = guiCreateButton(0.55, 0.73, 0.20, 0.09, "Create", true, aTeam.Form, "createteam")
        aTeam.Cancel = guiCreateButton(0.77, 0.73, 0.20, 0.09, "Cancel", true, aTeam.Form)
        aTeam.Accept = guiCreateButton(0.55, 0.88, 0.20, 0.09, "Select", true, aTeam.Form)
        aTeam.Hide = guiCreateButton(0.77, 0.88, 0.20, 0.09, "Close", true, aTeam.Form)

        addEventHandler("onClientGUIClick", aTeam.Form, aTeam.onClick)
        addEventHandler("onClientGUIDoubleClick", aTeam.Form, aTeam.onDoubleClick)
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
            destroyElement(aTeam.Form)
            aTeam.Form = nil
        end
    else
        guiSetVisible(aTeam.Form, false)
    end
end

function aTeam.onDoubleClick(button)
    if (button == "left") then
        if (source == aTeam.List) then
            if (guiGridListGetSelectedItem(aTeam.List) ~= -1) then
                local team = guiGridListGetItemText(aTeam.List, guiGridListGetSelectedItem(aTeam.List), 1)
                triggerServerEvent("aPlayer", getLocalPlayer(), getSelectedPlayer(), "setteam", getTeamFromName(team))
                aPlayerTeamClose(false)
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
                    triggerServerEvent("aTeam", getLocalPlayer(), "destroyteam", team)
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
                triggerServerEvent(
                    "aTeam",
                    getLocalPlayer(),
                    "createteam",
                    team,
                    guiGetText(aTeam.Red),
                    guiGetText(aTeam.Green),
                    guiGetText(aTeam.Blue)
                )
                aTeam.ShowNew(false)
            end
            setTimer(aTeam.Refresh, 2000, 1)
        elseif (source == aTeam.Name) then
            guiSetInputEnabled(true)
        elseif (source == aTeam.Cancel) then
            aTeam.ShowNew(false)
        elseif (source == aTeam.Accept) then
            if (guiGridListGetSelectedItem(aTeam.List) == -1) then
                messageBox("No team selected!", MB_WARNING)
            else
                local team = guiGridListGetItemData(aTeam.List, guiGridListGetSelectedItem(aTeam.List), 1)
                triggerServerEvent("aPlayer", getLocalPlayer(), getSelectedPlayer(), "setteam", team)
                guiSetVisible(aTeam.Form, false)
            end
        elseif (source == aTeam.Hide) then
            aTeam.Close(false)
        end
    end
end

function aTeam.ShowNew(bool)
    guiSetVisible(aTeam.New, not bool)
    guiSetVisible(aTeam.Delete, not bool)
    guiSetVisible(aTeam.NameLabel, bool)
    guiSetVisible(aTeam.Name, bool)
    guiSetVisible(aTeam.Color, bool)
    guiSetVisible(aTeam.R, bool)
    guiSetVisible(aTeam.G, bool)
    guiSetVisible(aTeam.B, bool)
    guiSetVisible(aTeam.Red, bool)
    guiSetVisible(aTeam.Green, bool)
    guiSetVisible(aTeam.Blue, bool)
    guiSetVisible(aTeam.Create, bool)
    guiSetVisible(aTeam.Cancel, bool)
end

function aTeam.Refresh()
    if (aTeam.List) then
        guiGridListClear(aTeam.List)
        for id, team in ipairs(getElementsByType("team")) do
            local row = guiGridListAddRow(aTeam.List)
            local r, g, b = getTeamColor(team)
            guiGridListSetItemText(aTeam.List, row, 1, getTeamName(team), false, false)
            guiGridListSetItemColor(aTeam.List, row, 1, r, g, b)
            guiGridListSetItemData(aTeam.List, row, 1, team)
        end
    end
end
