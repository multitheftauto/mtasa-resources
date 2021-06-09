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
        aPermissions.Form = guiCreateWindow(x / 2 - 130, y / 2 - 125, 260, 250, ("Manage %s's permissions"):format(getPlayerName(player)), false)
        guiSetAlpha(aPermissions.Form, 1)
        
        aPermissions.Label = guiCreateLabel(0.03, 0.09, 0.94, 0.07, "Use double-click to change the current state", true, aPermissions.Form)
        guiLabelSetHorizontalAlign(aPermissions.Label, "center")

        aPermissions.List = guiCreateGridList(0.03, 0.18, 0.94, 0.70, true, aPermissions.Form)
        guiGridListAddColumn(aPermissions.List, "ACL Group", 0.65)
        guiGridListAddColumn(aPermissions.List, "Has?", 0.2)

        aPermissions.Update = guiCreateButton(0.03, 0.88, 0.47, 0.09, "Refresh", true, aPermissions.Form)
        aPermissions.Hide = guiCreateButton(0.5, 0.88, 0.47, 0.09, "Close", true, aPermissions.Form)
        
        addEventHandler('aPermissionsSync', localPlayer, aPermissions.onSync)
        addEventHandler('aOnPermissionsChange', localPlayer, aPermissions.Refresh)
        addEventHandler("onClientGUIClick", aPermissions.Form, aPermissions.onClick)
        addEventHandler("onClientGUIDoubleClick", aPermissions.Form, aPermissions.onDoubleClick)
        
        --Register With Admin Form
        aRegister("PlayerPermissions", aPermissions.Form, aPermissions.Show, aPermissions.Close)
    end
    aPermissions.SelectedPlayer = player
    aPermissions.Refresh()
    guiSetVisible(aPermissions.Form, true)
    guiBringToFront(aPermissions.Form)
end

function aPermissions.onSync(targetPlayer, permissions)
    if (targetPlayer == aPermissions.SelectedPlayer) then
        guiGridListClear(aPermissions.List)
        for group, state in pairs(permissions) do
            local row = guiGridListAddRow(aPermissions.List)
            guiGridListSetItemText(aPermissions.List, row, 1, group, false, false)
            guiGridListSetItemText(aPermissions.List, row, 2, state and 'Yes' or 'No', false, false)
            guiGridListSetItemData(aPermissions.List, row, 1, group)
            guiGridListSetItemData(aPermissions.List, row, 2, state)
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
        end
    end
end

function aPermissions.onDoubleClick(button)
    if (button == 'left') then
        local player = aPermissions.SelectedPlayer
        if isElement(player) then
            local selectedItem = guiGridListGetSelectedItem(aPermissions.List)
            if (selectedItem > -1) then
                local selectedGroup = guiGridListGetItemData(aPermissions.List, selectedItem, 1)
                local currentState = guiGridListGetItemData(aPermissions.List, selectedItem, 2)
                local confirmStr
                if currentState then
                    confirmStr = ('Are you sure you want to remove "%s" from the "%s" group?'):format(getPlayerName(player), selectedGroup)
                else
                    confirmStr = ('Are you sure you want to add "%s" to the "%s" group?'):format(getPlayerName(player), selectedGroup)
                end
                aMessageBox ( "question", confirmStr, "updatePlayerACLGroup", player, selectedGroup, not currentState )
            end
        else
            aPermissions.Close(false)
            messageBox("Player not found!", MB_WARNING)
        end
    end
end

function aPermissions.PerformAction(player, groupName, newState)
    local playerAccount = player and aPlayers[player] and aPlayers[player]['accountname']
    if playerAccount and (playerAccount ~= 'guest') then
        triggerServerEvent('aAdmin', localPlayer, newState and 'acladd' or 'aclremove', 'object', groupName, 'user.'..playerAccount, true)
    end
end

function aPermissions.Refresh()
    local player = aPermissions.SelectedPlayer
    if isElement(player) and (aPermissions.List) then
        guiGridListClear(aPermissions.List)
        triggerServerEvent('aAdmin', localPlayer, "sync", "playeraclgroups", player)
    end
end
