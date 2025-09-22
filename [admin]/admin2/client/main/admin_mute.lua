--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\main\admin_mute.lua
*
*	Original File by omar-o22
*
**************************************]]
aMuteTab = {
    List = {}
}

function aMuteTab.Create(tab)
    aMuteTab.Tab = tab

    aMuteTab.MuteListSearch = guiCreateEdit(0.01, 0.02, 0.3, 0.04, "", true, aMuteTab.Tab)
    guiCreateInnerImage("client\\images\\search.png", aMuteTab.MuteListSearch)
    guiHandleInput(aMuteTab.MuteListSearch)
    aMuteTab.MuteList = guiCreateGridList(0.01, 0.07, 0.80, 0.91, true, aMuteTab.Tab)
    guiGridListAddColumn(aMuteTab.MuteList, "Name", 0.22)
    guiGridListAddColumn(aMuteTab.MuteList, "Serial", 0.25)
    guiGridListAddColumn(aMuteTab.MuteList, "Duration", 0.17)
    guiGridListAddColumn(aMuteTab.MuteList, "Muted by", 0.22)
    aMuteTab.Details = guiCreateButton(0.82, 0.07, 0.17, 0.04, "Details", true, aMuteTab.Tab)
    aMuteTab.Unmute = guiCreateButton(0.82, 0.12, 0.17, 0.04, "Unmute", true, aMuteTab.Tab, "unmute")
    aMuteTab.MuteRefresh = guiCreateButton(0.82, 0.94, 0.17, 0.04, "Refresh", true, aMuteTab.Tab, "listmute")

    addEventHandler("onClientGUIChanged", aMuteTab.MuteListSearch, aMuteTab.onMuteListSearch)
    addEventHandler("onClientGUIClick", aMuteTab.Tab, aMuteTab.onClientClick)
    addEventHandler(EVENT_SYNC, root, aMuteTab.onClientSync)

    guiGridListClear(aMuteTab.MuteList)
    sync(SYNC_MUTES)
end

function aMuteTab.onClientClick(button)
    if (button == "left") then
        if (source == aMuteTab.Details) then
            local row = guiGridListGetSelectedItem(aMuteTab.MuteList)
            if (row == -1) then
                messageBox("No mute selected!", MB_ERROR, MB_OK)
                return
            end

            local serial = guiGridListGetItemText(aMuteTab.MuteList, row, 2)
            aMuteDetails.Show(serial)
        elseif (source == aMuteTab.Unmute) then
            local row = guiGridListGetSelectedItem(aMuteTab.MuteList)
            if (row == -1) then
                messageBox("No mute selected!", MB_ERROR, MB_OK)
                return
            end

            local serial = guiGridListGetItemText(aMuteTab.MuteList, row, 2)
            aMuteDetails.Show(serial, true)
        elseif (source == aMuteTab.MuteRefresh) then
            guiGridListClear(aMuteTab.MuteList)
            sync(SYNC_MUTES)
        end
    end
end

function aMuteTab.onMuteListSearch()
    guiGridListClear(aMuteTab.MuteList)
    local text = string.upper(guiGetText(source))
    if (text == "") then
        aMuteTab.Refresh()
    else
        for serial, mute in pairs(aMuteTab.List) do
            if
                ((mute.name and string.find(string.upper(mute.name), text)) or
                (serial and string.find(string.upper(serial), text)) or
                (mute.admin and string.find(string.upper(mute.admin), text)))
            then
                aMuteTab.AddRow(serial, mute)
            end
        end
    end
end

function aMuteTab.onClientSync(type, data)
    if (type == SYNC_MUTES) then
        aMuteTab.List = data
        aMuteTab.Refresh()
    end
end

function aMuteTab.Refresh()
    guiGridListClear(aMuteTab.MuteList)
    for id, ban in pairs(aMuteTab.List) do
        aMuteTab.AddRow(id, ban)
    end
end

function aMuteTab.AddRow(serial, data)
    local list = aMuteTab.MuteList
    local row = guiGridListAddRow(list)
    local time
    if time == 0 then
        time = "Permanent"
    else
        time = secondsToTimeDesc(data.time / 1000)
    end
    guiGridListSetItemText(list, row, 1, data.name or "Unknown", false, false)
    guiGridListSetItemText(list, row, 2, serial or "", false, false)
    guiGridListSetItemText(list, row, 3, time, false, false)
    guiGridListSetItemText(list, row, 4, data.admin or "Console", false, false)
end