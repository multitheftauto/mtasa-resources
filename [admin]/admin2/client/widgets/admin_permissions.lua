--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_permissions.lua
*
*	Original File by lil_Toady
*
**************************************]]
aPermissions = {
    Form = nil
}

addEvent(EVENT_ACL, true)

function aPermissions.Show()
    if (not aPermissions.Form) then
        local x, y = guiGetScreenSize()
        aPermissions.Form = guiCreateWindow(x / 2 - 150, y / 2 - 125, 300, 250, "Player Permissions Management", false)
        aPermissions.Label =
            guiCreateLabel(0.03, 0.09, 0.94, 0.07, "Select a group from the list to give or revoke", true, aPermissions.Form)
        guiLabelSetHorizontalAlign(aPermissions.Label, "center")
        guiLabelSetColor(aPermissions.Label, 255, 0, 0)
        aPermissions.List = guiCreateGridList(0.03, 0.18, 0.50, 0.71, true, aPermissions.Form)
        guiGridListAddColumn(aPermissions.List, "Groups", 0.85)
        aPermissions.Update = guiCreateButton(0.03, 0.90, 0.50, 0.08, "Refresh", true, aPermissions.Form)
        aPermissions.Give = guiCreateButton(0.55, 0.18, 0.42, 0.09, "Give Group", true, aPermissions.Form, "createteam")
        aPermissions.Revoke = guiCreateButton(0.55, 0.28, 0.42, 0.09, "Revoke Group", true, aPermissions.Form, "destroyteam")
        aPermissions.Hide = guiCreateButton(0.55, 0.88, 0.42, 0.09, "Close", true, aPermissions.Form)

        addEventHandler(EVENT_ACL, getLocalPlayer(), aPermissions.onSync)
        addEventHandler("onClientGUIClick", aPermissions.Form, aPermissions.onClick)
        --Register With Admin Form
        aRegister("PlayerPermissions", aPermissions.Form, aPermissions.Show, aPermissions.Close)
    end
    aPermissions.Refresh()
    guiSetVisible(aPermissions.Form, true)
    guiBringToFront(aPermissions.Form)
end

aPermissions.SyncFunctions = {
    [ACL_GROUPS] = function(data)
        guiGridListClear(aPermissions.List)
        for id, group in ipairs(data) do
            local row = guiGridListAddRow(aPermissions.List)
            guiGridListSetItemText(aPermissions.List, row, 1, group, false, false)
        end
    end,
}

function aPermissions.onSync(action, ...)
    aPermissions.SyncFunctions[action](...)
end

function aPermissions.Close(destroy)
    guiSetInputEnabled(false)
    if (destroy) then
        if (aPermissions.Form) then
            removeEventHandler("onClientGUIClick", aPermissions.Form, aPermissions.onClick)
            destroyElement(aPermissions.Form)
            aPermissions.Form = nil
        end
    else
        guiSetVisible(aPermissions.Form, false)
    end
end

function aPermissions.onClick(button)
    if (button == "left") then
        if (source == aPermissions.Update) then
            aPermissions.Refresh()
        elseif (source == aPermissions.Give) then
            if (guiGridListGetSelectedItem(aPermissions.List) == -1) then
                messageBox("No group selected!", MB_WARNING)
            else
                local group = guiGridListGetItemText(aPermissions.List, guiGridListGetSelectedItem(aPermissions.List), 1)
                if (messageBox('Are you sure to give "' .. group .. '"?', MB_QUESTION, MB_YESNO)) then
                    triggerServerEvent("aPlayer", getLocalPlayer(), getSelectedPlayer(), "setgroup", true, group)
                end
            end
        elseif (source == aPermissions.Revoke) then
            if (guiGridListGetSelectedItem(aPermissions.List) == -1) then
                messageBox("No group selected!", MB_WARNING)
            else
                local group = guiGridListGetItemText(aPermissions.List, guiGridListGetSelectedItem(aPermissions.List), 1)
                if (messageBox('Are you sure to revoke "' .. group .. '"?', MB_QUESTION, MB_YESNO)) then
                    triggerServerEvent("aPlayer", getLocalPlayer(), getSelectedPlayer(), "setgroup", false, group)
                end
            end
        elseif (source == aPermissions.Hide) then
            aPermissions.Close(false)
        end
    end
end

function aPermissions.Refresh()
    if (aPermissions.List) then
        guiGridListClear(aPermissions.List)
        triggerServerEvent(EVENT_ACL, getLocalPlayer(), ACL_GROUPS)
    end
end
