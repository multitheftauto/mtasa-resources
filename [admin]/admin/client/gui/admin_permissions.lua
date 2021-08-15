--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\gui\admin_permissions.lua
*
*	Original File by lil_Toady
*
**************************************]]
aPermissions = {
    Form = nil,
    SelectedPlayer = nil,
}

addEvent('aPermissionsSync', true)
addEvent('aOnPermissionsChange', true)

function aPermissions.Show(player)
    if (not aPermissions.Form) then
        local x, y = guiGetScreenSize()
        aPermissions.Form = guiCreateWindow(x / 2 - 200, y / 2 - 125, 400, 250, '', false)
        guiSetAlpha(aPermissions.Form, 1)
        
        aPermissions.LabelYourPerms = guiCreateLabel(0.03, 0.1, 0.35, 0.07, '', true, aPermissions.Form)
        aPermissions.PlayerGroups = guiCreateGridList(0.03, 0.18, 0.35, 0.68, true, aPermissions.Form)
        guiGridListAddColumn(aPermissions.PlayerGroups, "Group Name", 0.85)
        aPermissions.RemoveGroup = guiCreateButton(0.39, 0.18, 0.075, 0.68, '>\n>\n>', true, aPermissions.Form)
        guiSetEnabled(aPermissions.RemoveGroup, false)

        aPermissions.LabelAllPerms = guiCreateLabel(0.62, 0.1, 0.35, 0.07, "Available groups:", true, aPermissions.Form)
        aPermissions.AllGroups = guiCreateGridList(0.62, 0.18, 0.35, 0.68, true, aPermissions.Form)
        guiGridListAddColumn(aPermissions.AllGroups, "Group Name", 0.85)
        aPermissions.AddGroup = guiCreateButton(0.535, 0.18, 0.075, 0.68, '<\n<\n<', true, aPermissions.Form)
        guiSetEnabled(aPermissions.AddGroup, false)

        aPermissions.Update = guiCreateButton(0.03, 0.88, 0.435, 0.09, "Refresh", true, aPermissions.Form)
        aPermissions.Hide = guiCreateButton(0.535, 0.88, 0.435, 0.09, "Close", true, aPermissions.Form)
        
        addEventHandler('aPermissionsSync', localPlayer, aPermissions.onSync)
        addEventHandler('aOnPermissionsChange', localPlayer, aPermissions.Refresh)
        addEventHandler("onClientGUIClick", aPermissions.Form, aPermissions.onClick)
        
        --Register With Admin Form
        aRegister("PlayerPermissions", aPermissions.Form, aPermissions.Show, aPermissions.Close)
    end
    guiSetText(aPermissions.Form, ("Manage %s's permissions"):format(getPlayerName(player)))
    guiSetText(aPermissions.LabelYourPerms, ("%s's groups:"):format(getPlayerName(player)))
    aPermissions.SelectedPlayer = player
    aPermissions.Refresh()
    guiSetVisible(aPermissions.Form, true)
    guiBringToFront(aPermissions.Form)
end

function aPermissions.onSync(targetPlayer, permissions)
    if (targetPlayer == aPermissions.SelectedPlayer) then
        guiGridListClear(aPermissions.PlayerGroups)
        guiGridListClear(aPermissions.AllGroups)

        for group, state in pairs(permissions) do
            local gridlist = state and aPermissions.PlayerGroups or aPermissions.AllGroups
            guiGridListAddRow(gridlist, group)
        end
    end
end

function aPermissions.Close(destroy)
    if (destroy) then
        if (aPermissions.Form) then
            destroyElement(aPermissions.Form)
            aPermissions.Form = nil
            removeEventHandler('aPermissionsSync', localPlayer, aPermissions.onSync)
            removeEventHandler('aOnPermissionsChange', localPlayer, aPermissions.Refresh)
        end
    else
        guiSetVisible(aPermissions.Form, false)
    end
    aPermissions.SelectedPlayer = nil
end

function aPermissions.onClick(button)
    if (button == 'left') then
        if (source == aPermissions.Hide) then
            aPermissions.Close()
        elseif (source == aPermissions.Update) then
            aPermissions.Refresh()
        elseif (source == aPermissions.RemoveGroup) then
            aPermissions.ConfirmChange(false)
        elseif (source == aPermissions.AddGroup) then
            aPermissions.ConfirmChange(true)
        elseif (source == aPermissions.AllGroups) then
            guiSetEnabled(aPermissions.AddGroup, guiGridListGetSelectedItem(aPermissions.AllGroups) > -1)
        elseif (source == aPermissions.PlayerGroups) then
            guiSetEnabled(aPermissions.RemoveGroup, guiGridListGetSelectedItem(aPermissions.PlayerGroups) > -1)
        end
    end
end

function aPermissions.ConfirmChange(add)
    local player = aPermissions.SelectedPlayer

    if (not isElement(player)) then
        aPermissions.Close(false)
        messageBox("Player not found!", MB_WARNING)
        return
    end

    local gridlist = add and aPermissions.AllGroups or aPermissions.PlayerGroups
    
    local selected = guiGridListGetSelectedItem(gridlist)

    if (selected <= -1) then 
        return 
    end
    
    local groupName = guiGridListGetItemText(gridlist, selected, 1)

    local str = add and 'Are you sure you want to add "%s" to the "%s" group?' or 'Are you sure you want to remove "%s" from the "%s" group?'
    str = str:format(getPlayerName(player), groupName)

    return aMessageBox ( "question", str, "updatePlayerACLGroup", player, groupName, add)
end

function aPermissions.PerformAction(player, groupName, newState)
    local playerAccount = player and aPlayers[player] and aPlayers[player]['accountname']
    if playerAccount and (playerAccount ~= 'guest') then
        triggerServerEvent('aAdmin', localPlayer, newState and 'acladd' or 'aclremove', 'object', groupName, 'user.'..playerAccount, true)
    end
end

function aPermissions.Refresh()
    local player = aPermissions.SelectedPlayer
    if isElement(player) and aPermissions.PlayerGroups and aPermissions.AllGroups then
        guiGridListClear(aPermissions.PlayerGroups)
        guiGridListClear(aPermissions.AllGroups)
        triggerServerEvent('aAdmin', localPlayer, "sync", "playeraclgroups", player)
    end
end
