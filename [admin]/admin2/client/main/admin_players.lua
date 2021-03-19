--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\main\admin_players.lua
*
*	Original File by lil_Toady
*
**************************************]]
aPlayersTab = {}
aPlayers = {}

addEvent("aClientPlayerJoin", true)

function aPlayersTab.Create(tab)
    aPlayersTab.Tab = tab

    -- Player list (left pane)
    aPlayersTab.PlayerListSearch = guiCreateEdit(0.01, 0.01, 0.25, 0.04, "", true, tab)
    guiCreateInnerImage("client\\images\\search.png", aPlayersTab.PlayerListSearch)
    guiHandleInput(aPlayersTab.PlayerListSearch)
    aPlayersTab.PlayerList = guiCreateGridList(0.01, 0.06, 0.25, 0.88, true, tab)
    guiGridListAddColumn(aPlayersTab.PlayerList, "Player list", 0.85)
    aPlayersTab.Context = guiCreateContextMenu(aPlayersTab.PlayerList)
    aPlayersTab.ContextKick = guiContextMenuAddItem(aPlayersTab.Context, "Kick")
    aPlayersTab.ColorCodes = guiCreateCheckBox(0.01, 0.95, 0.25, 0.04, "Hide color codes", true, true, tab)

    -- Player info (middle pane)
    guiCreateHeader(0.27, 0.04, 0.20, 0.04, "Player:", true, tab)
    aPlayersTab.InfoContext = guiCreateContextMenu()
    aPlayersTab.ContextCopy = guiContextMenuAddItem(aPlayersTab.InfoContext, "copy")
    aPlayersTab.Name = guiCreateLabel(0.27, 0.080, 0.45, 0.035, "Name: N/A", true, tab)
    guiSetContextMenu(aPlayersTab.Name, aPlayersTab.InfoContext)
    aPlayersTab.IP = guiCreateLabel(0.27, 0.125, 0.45, 0.035, "IP: N/A", true, tab)
    guiSetContextMenu(aPlayersTab.IP, aPlayersTab.InfoContext)
    aPlayersTab.Serial = guiCreateLabel(0.27, 0.170, 0.45, 0.035, "Serial: N/A", true, tab)
    guiSetContextMenu(aPlayersTab.Serial, aPlayersTab.InfoContext)
    aPlayersTab.Country = guiCreateLabel(0.27, 0.215, 0.45, 0.035, "Country: Unknown", true, tab)
    aPlayersTab.Account = guiCreateLabel(0.27, 0.260, 0.45, 0.035, "Account: N/A", true, tab)
    guiSetContextMenu(aPlayersTab.Account, aPlayersTab.InfoContext)
    aPlayersTab.Groups = guiCreateLabel(0.27, 0.305, 0.45, 0.035, "Groups: N/A", true, tab)
    aPlayersTab.Flag = guiCreateStaticImage(0.40, 0.125, 0.025806, 0.021154, "client\\images\\empty.png", true, tab)
    guiSetVisible(aPlayersTab.Flag, false)
    guiCreateHeader(0.27, 0.350, 0.20, 0.04, "Game:", true, tab)
    aPlayersTab.Health = guiCreateLabel(0.27, 0.395, 0.20, 0.04, "Health: 0%", true, tab)
    aPlayersTab.Armour = guiCreateLabel(0.45, 0.395, 0.20, 0.04, "Armour: 0%", true, tab)
    aPlayersTab.Skin = guiCreateLabel(0.27, 0.440, 0.20, 0.04, "Skin: N/A", true, tab)
    aPlayersTab.Team = guiCreateLabel(0.45, 0.440, 0.20, 0.04, "Team: None", true, tab)
    aPlayersTab.Weapon = guiCreateLabel(0.27, 0.485, 0.35, 0.04, "Weapon: N/A", true, tab)
    aPlayersTab.Ping = guiCreateLabel(0.27, 0.530, 0.20, 0.04, "Ping: 0", true, tab)
    aPlayersTab.Money = guiCreateLabel(0.45, 0.530, 0.20, 0.04, "Money: 0", true, tab)
    aPlayersTab.Area = guiCreateLabel(0.27, 0.575, 0.44, 0.04, "Area: Unknown", true, tab)
    guiSetContextMenu(aPlayersTab.Area, aPlayersTab.InfoContext)
    aPlayersTab.PositionX = guiCreateLabel(0.27, 0.620, 0.30, 0.04, "X: 0", true, tab)
    aPlayersTab.PositionY = guiCreateLabel(0.27, 0.665, 0.30, 0.04, "Y: 0", true, tab)
    aPlayersTab.PositionZ = guiCreateLabel(0.27, 0.710, 0.30, 0.04, "Z: 0", true, tab)
    guiSetContextMenu(aPlayersTab.PositionX, aPlayersTab.InfoContext)
    guiSetContextMenu(aPlayersTab.PositionY, aPlayersTab.InfoContext)
    guiSetContextMenu(aPlayersTab.PositionZ, aPlayersTab.InfoContext)
    aPlayersTab.Dimension = guiCreateLabel(0.27, 0.755, 0.20, 0.04, "Dimension: 0", true, tab)
    aPlayersTab.Interior = guiCreateLabel(0.45, 0.755, 0.20, 0.04, "Interior: 0", true, tab)
    guiCreateHeader(0.27, 0.805, 0.20, 0.04, "Vehicle:", true, tab)
    aPlayersTab.Vehicle = guiCreateLabel(0.27, 0.850, 0.35, 0.04, "Vehicle: N/A", true, tab)
    aPlayersTab.VehicleHealth = guiCreateLabel(0.27, 0.895, 0.25, 0.04, "Vehicle Health: 0%", true, tab)


    -- Action buttons (right pane)
    aPlayersTab.Messages = guiCreateButton(0.74, 0.01, 0.25, 0.04, "0/0 unread messages", true, tab)
    aPlayersTab.Kick = guiCreateButton(0.74, 0.1, 0.12, 0.04, "Kick", true, tab, "kick")
    aPlayersTab.Ban = guiCreateButton(0.87, 0.1, 0.12, 0.04, "Ban", true, tab, "ban")
    aPlayersTab.Mute = guiCreateButton(0.74, 0.145, 0.12, 0.04, "Mute", true, tab, "mute")
    aPlayersTab.Freeze = guiCreateButton(0.87, 0.145, 0.12, 0.04, "Freeze", true, tab, "freeze")
    aPlayersTab.Shout = guiCreateButton(0.74, 0.19, 0.12, 0.04, "Shout", true, tab, "shout")
    aPlayersTab.Spectate = guiCreateButton(0.87, 0.19, 0.12, 0.04, "Spectate", true, tab, "spectate")
    aPlayersTab.SetNick = guiCreateButton(0.74, 0.235, 0.12, 0.04, "Set nick", true, tab, "setnick")
    aPlayersTab.Admin = guiCreateButton(0.87, 0.235, 0.12, 0.04, "Give admin", true, tab, "setgroup")
    aPlayersTab.SlapOptions = guiCreateComboBox(0.76, 0.28, 0.1, 0.04, "0", true, tab)
    local width, height = guiGetSize(aPlayersTab.SlapOptions, false)
    for i = 0, 200, 20 do
        local id = guiComboBoxAddItem(aPlayersTab.SlapOptions, i)
        if i == 20 then
            guiComboBoxSetSelected(aPlayersTab.SlapOptions, id)
        end
    end
    guiSetSize(aPlayersTab.SlapOptions, width, height + (16 * 11), false) -- adjust height to fit items (16px per item)
    aPlayersTab.Slap = guiCreateButton(0.87, 0.28, 0.12, 0.04, "Slap!", true, tab, "slap")

    aPlayersTab.SetHealth = guiCreateButton(0.74, 0.35, 0.12, 0.04, "Set Health", true, tab, "sethealth")
    aPlayersTab.SetArmour = guiCreateButton(0.87, 0.35, 0.12, 0.04, "Set Armour", true, tab, "setarmour")
    aPlayersTab.SetSkin = guiCreateButton(0.74, 0.395, 0.12, 0.04, "Set Skin", true, tab, "setskin")
    aPlayersTab.SetTeam = guiCreateButton(0.87, 0.395, 0.12, 0.04, "Set Team", true, tab, "setteam")
    aPlayersTab.SetDimension = guiCreateButton(0.74, 0.44, 0.12, 0.04, "Set Dimens.", true, tab, "setdimension")
    aPlayersTab.SetInterior = guiCreateButton(0.87, 0.44, 0.12, 0.04, "Set Interior", true, tab, "setinterior")
    aPlayersTab.SetMoney = guiCreateButton(0.74, 0.485, 0.12, 0.04, "Set Money", true, tab, "setmoney")
    aPlayersTab.SetStats = guiCreateButton(0.87, 0.485, 0.12, 0.04, "Set Stats", true, tab, "setstat")
    aPlayersTab.GiveWeapon = guiCreateButton(0.74, 0.53, 0.25, 0.04, "Give Weapon", true, tab)
    aPlayersTab.JetPack = guiCreateButton(0.74, 0.575, 0.25, 0.04, "Give JetPack", true, tab, "jetpack")
    aPlayersTab.GiveVehicle = guiCreateButton(0.74, 0.62, 0.25, 0.04, "Give Vehicle", true, tab)
    aPlayersTab.WarpTo = guiCreateButton(0.74, 0.665, 0.25, 0.04, "Warp to player", true, tab, "warp")
    aPlayersTab.WarpPlayer = guiCreateButton(0.74, 0.71, 0.25, 0.04, "Warp player to...", true, tab, "warp")
    aPlayersTab.VehicleFix = guiCreateButton(0.74, 0.805, 0.12, 0.04, "Fix", true, tab, "repair")
    aPlayersTab.VehicleDestroy = guiCreateButton(0.74, 0.85, 0.12, 0.04, "Destroy", true, tab, "destroyvehicle")
    aPlayersTab.VehicleBlow = guiCreateButton(0.87, 0.805, 0.12, 0.04, "Blow", true, tab, "blowvehicle")
    aPlayersTab.VehicleCustomize = guiCreateButton(0.87, 0.85, 0.12, 0.04, "Customize", true, tab, "customize")

    aPlayersTab.AnonAdmin = guiCreateCheckBox(0.745, 0.942, 0.20, 0.04, "Anonymous Admin", isAnonAdmin(), true, tab)

    aPlayersTab.Refresh()

    -- EVENTS

    addEventHandler("onClientGUIClick", aPlayersTab.Context, aPlayersTab.onContextClick)
    addEventHandler("onClientGUIClick", aPlayersTab.InfoContext, aPlayersTab.onContextClick)
    addEventHandler("onClientGUIClick", aPlayersTab.Tab, aPlayersTab.onClientClick)
    addEventHandler("onClientGUIChanged", aPlayersTab.PlayerListSearch, aPlayersTab.onPlayerListSearch)
    addEventHandler("onClientPlayerChangeNick", root, aPlayersTab.onClientPlayerChangeNick)
    addEventHandler("aClientPlayerJoin", root, aPlayersTab.onClientPlayerJoin)
    addEventHandler("onClientPlayerQuit", root, aPlayersTab.onClientPlayerQuit)
    addEventHandler(EVENT_SYNC, root, aPlayersTab.onClientSync)
    addEventHandler("onClientResourceStop", getResourceRootElement(), aPlayersTab.onClientResourceStop)
    addEventHandler("onAdminRefresh", aPlayersTab.Tab, aPlayersTab.onRefresh)

    sync(SYNC_PLAYERS)
    if (hasPermissionTo("command.listmessages")) then
        sync(SYNC_MESSAGES)
    end

    --bindKey("arrow_d", "down", aPlayersTab.onPlayerListScroll, 1)
    --bindKey("arrow_u", "down", aPlayersTab.onPlayerListScroll, -1)
    -- bindKey will not work while the searchbar has input focus - here is a hack using onClientKey instead
    addEventHandler("onClientKey", root, function(key, press)
        if not (key == "arrow_u" or key == "arrow_d") then return end
        if not press then return end
        if not guiGetVisible(aAdminMain.Form) then return end
        aPlayersTab.onPlayerListScroll(key, press and "down" or "up", key == "arrow_u" and -1 or 1)
    end)
end

function aPlayersTab.onContextClick(button)
    local translator = {
        [aPlayersTab.ContextKick] = aPlayersTab.Kick
    }
    if (translator[source]) then
        source = translator[source]
        aPlayersTab.onClientClick(button)
    elseif (source == aPlayersTab.ContextCopy) then
        if (contextSource) then
            local copy = string.sub(guiGetText(contextSource), guiGetText(contextSource):match("%w+:"):len() + 2)
            setClipboard(copy)
        end
    end
end

function aPlayersTab.onClientClick(button)
    if (button == "left") then
        if (source == aPlayersTab.Messages) then
            aMessages.Open()
        elseif (getElementType(source) == "gui-button") then
            if (guiGridListGetSelectedItem(aPlayersTab.PlayerList) == -1) then
                messageBox("No player selected!", MB_ERROR, MB_OK)
            else
                local player = getSelectedPlayer()
                local name = getPlayerName(player)
                if (source == aPlayersTab.Kick) then
                    local reason = inputBox("Kick player " .. name, "Enter the kick reason")
                    if (reason) then
                        triggerServerEvent("aPlayer", getLocalPlayer(), player, "kick", reason)
                    end
                elseif (source == aPlayersTab.Ban) then
                    local reason = inputBox("Ban player " .. name, "Enter the ban reason")
                    if (reason) then
                        triggerServerEvent("aPlayer", getLocalPlayer(), player, "ban", reason)
                    end
                elseif (source == aPlayersTab.Slap) then
                    triggerServerEvent("aPlayer", getLocalPlayer(), player, "slap",
                        guiComboBoxGetItemText(aPlayersTab.SlapOptions, guiComboBoxGetSelected(aPlayersTab.SlapOptions))
                    )
                elseif (source == aPlayersTab.Mute) then
                    triggerServerEvent(
                        "aPlayer",
                        getLocalPlayer(),
                        player,
                        iif(aPlayers[player].mute, "unmute", "mute")
                    )
                elseif (source == aPlayersTab.Freeze) then
                    triggerServerEvent(
                        "aPlayer",
                        getLocalPlayer(),
                        player,
                        iif(aPlayers[player].freeze, "unfreeze", "freeze")
                    )
                elseif (source == aPlayersTab.Spectate) then
                    aSpectate(player)
                elseif (source == aPlayersTab.SetNick) then
                    local nick = inputBox("Set nick", "Enter new nickname for " .. name)
                    if (nick) then
                        triggerServerEvent("aPlayer", getLocalPlayer(), player, "setnick", nick)
                    end
                elseif (source == aPlayersTab.Shout) then
                    local shout = inputBox("Shout", "Enter text to be shown on player's screen")
                    if (shout) then
                        triggerServerEvent("aPlayer", getLocalPlayer(), player, "shout", shout)
                    end
                elseif (source == aPlayersTab.SetHealth) then
                    local health = inputBox("Set health", "Enter the health value", "100")
                    if (health) then
                        triggerServerEvent("aPlayer", getLocalPlayer(), player, "sethealth", health)
                    end
                elseif (source == aPlayersTab.SetArmour) then
                    local armour = inputBox("Set armour", "Enter the armour value", "100")
                    if (armour) then
                        triggerServerEvent("aPlayer", getLocalPlayer(), player, "setarmour", armour)
                    end
                elseif (source == aPlayersTab.SetTeam) then
                    aTeam.Show()
                elseif (source == aPlayersTab.SetSkin) then
                    aSkin.Show(player)
                elseif (source == aPlayersTab.SetInterior) then
                    aPlayerInterior(player)
                elseif (source == aPlayersTab.JetPack) then
                    triggerServerEvent("aPlayer", getLocalPlayer(), player, "jetpack")
                elseif (source == aPlayersTab.SetMoney) then
                    local money = inputBox("Set money", "Enter the money value")
                    if (money) then
                        triggerServerEvent("aPlayer", getLocalPlayer(), player, "setmoney", money)
                    end
                elseif (source == aPlayersTab.SetStats) then
                    aPlayerStats(player)
                elseif (source == aPlayersTab.SetDimension) then
                    local dimension = inputBox("Set dimension", "Enter dimension ID between 0 and 65535", "0")
                    if (dimension) then
                        triggerServerEvent("aPlayer", getLocalPlayer(), player, "setdimension", dimension)
                    end
                elseif (source == aPlayersTab.GiveWeapon) then
                    aWeapon.Show(player)
                elseif (source == aPlayersTab.GiveVehicle) then
                    aVehicle.Show(player)
                elseif (source == aPlayersTab.VehicleFix) then
                    triggerServerEvent("aVehicle", getLocalPlayer(), player, "repair")
                elseif (source == aPlayersTab.VehicleBlow) then
                    triggerServerEvent("aVehicle", getLocalPlayer(), player, "blowvehicle")
                elseif (source == aPlayersTab.VehicleDestroy) then
                    triggerServerEvent("aVehicle", getLocalPlayer(), player, "destroyvehicle")
                elseif (source == aPlayersTab.VehicleCustomize) then
                    local vehicle = getPedOccupiedVehicle(player)
                    if not isElement(vehicle) then
                        messageBox("Player is not in a vehicle!", MB_ERROR)
                    else
                        aVehicleUpgrades.Open(player, vehicle)
                    end
                elseif (source == aPlayersTab.WarpTo) then
                    if player == localPlayer then
                        messageBox("You can't warp to yourself!", MB_ERROR)
                    else
                        triggerServerEvent("aPlayer", getLocalPlayer(), player, "warp")
                    end
                elseif (source == aPlayersTab.WarpPlayer) then
                    aPlayerWarp(player)
                elseif (source == aPlayersTab.Admin) then
                    if
                        (aPlayers[player]["admin"] and
                            messageBox("Revoke admin rights from " .. name .. "?", MB_WARNING))
                     then
                        triggerServerEvent("aPlayer", getLocalPlayer(), player, "setgroup", false)
                    elseif (messageBox("Give admin rights to " .. name .. "?", MB_WARNING)) then
                        triggerServerEvent("aPlayer", getLocalPlayer(), player, "setgroup", true)
                    end
                end
            end
        elseif (source == aPlayersTab.AnonAdmin) then
            setElementData(localPlayer, "AnonAdmin", guiCheckBoxGetSelected(aPlayersTab.AnonAdmin))
        elseif (source == aPlayersTab.ColorCodes) then
            aPlayersTab.Refresh()
        elseif (source == aPlayersTab.PlayerList) then
            local player = getSelectedPlayer()
            if (player) then
                aPlayersTab.onRefresh()
            else
                guiSetText(aPlayersTab.Name, "Name: N/A")
                guiSetText(aPlayersTab.IP, "IP: N/A")
                guiSetText(aPlayersTab.Serial, "Serial: N/A")
                guiSetText(aPlayersTab.Account, "Account: N/A")
                guiSetText(aPlayersTab.Country, "Country: Unknown")
                guiSetText(aPlayersTab.Groups, "Groups: N/A")
                guiSetText(aPlayersTab.Mute, "Mute")
                guiSetText(aPlayersTab.Freeze, "Freeze")
                guiSetText(aPlayersTab.Admin, "Give admin")
                guiSetText(aPlayersTab.Health, "Health: 0%")
                guiSetText(aPlayersTab.Armour, "Armour: 0%")
                guiSetText(aPlayersTab.Skin, "Skin: N/A")
                guiSetText(aPlayersTab.Team, "Team: None")
                guiSetText(aPlayersTab.Ping, "Ping: 0")
                guiSetText(aPlayersTab.Money, "Money: 0")
                guiSetText(aPlayersTab.Dimension, "Dimension: 0")
                guiSetText(aPlayersTab.Interior, "Interior: 0")
                guiSetText(aPlayersTab.JetPack, "Give JetPack")
                guiSetText(aPlayersTab.Weapon, "Weapon: N/A")
                guiSetText(aPlayersTab.Area, "Area: Unknown")
                guiSetText(aPlayersTab.PositionX, "X: 0")
                guiSetText(aPlayersTab.PositionY, "Y: 0")
                guiSetText(aPlayersTab.PositionZ, "Z: 0")
                guiSetText(aPlayersTab.Vehicle, "Vehicle: N/A")
                guiSetText(aPlayersTab.VehicleHealth, "Vehicle Health: 0%")
                guiSetVisible(aPlayersTab.Flag, false)
            end
        end
    end
end

function aPlayersTab.onPlayerListSearch()
    guiGridListClear(aPlayersTab.PlayerList)
    local text = guiGetText(source)
    if (text == "") then
        for id, player in ipairs(getElementsByType("player")) do
            local row = guiGridListAddRow(aPlayersTab.PlayerList)
            guiGridListSetItemText(aPlayersTab.PlayerList, row, 1, getPlayerName(player), false, false)
            guiGridListSetItemData(aPlayersTab.PlayerList, row, 1, player)
        end
    else
        for id, player in ipairs(getElementsByType("player")) do
            if (string.find(string.upper(getPlayerName(player)), string.upper(text))) then
                local row = guiGridListAddRow(aPlayersTab.PlayerList)
                guiGridListSetItemText(aPlayersTab.PlayerList, row, 1, getPlayerName(player), false, false)
                guiGridListSetItemData(aPlayersTab.PlayerList, row, 1, player)
            end
        end
    end
end

function aPlayersTab.onPlayerListScroll(key, state, inc)
    if (not guiGetVisible(aAdminMain.Form)) then
        return
    end
    local max = guiGridListGetRowCount(aPlayersTab.PlayerList)
    if (max <= 0) then
        return
    end
    local current = guiGridListGetSelectedItem(aPlayersTab.PlayerList)
    local next = current + inc
    max = max - 1
    if (current == -1) then
        guiGridListSetSelectedItem(aPlayersTab.PlayerList, 0, 1)
    elseif (next > max) then
        return
    elseif (next < 0) then
        return
    else
        guiGridListSetSelectedItem(aPlayersTab.PlayerList, next, 1)
    end

    -- If we have finally selected an item
    if guiGridListGetSelectedItem(aPlayersTab.PlayerList) ~= -1 then
        aPlayersTab.onRefresh()
    end
end

function aPlayersTab.onClientPlayerChangeNick(oldNick, newNick)
    local id = 0
    local list = aPlayersTab.PlayerList
    while (id <= guiGridListGetRowCount(list)) do
        if (guiGridListGetItemData(list, id, 1) == source) then
            if (guiCheckBoxGetSelected(aPlayersTab.ColorCodes)) then
                guiGridListSetItemText(list, id, 1, stripColorCodes(newNick), false, false)
            else
                guiGridListSetItemText(list, id, 1, newNick, false, false)
            end
        end
        id = id + 1
    end
end

function aPlayersTab.onClientPlayerJoin(ip, username, serial, country, countryname)
    aPlayers[source] = {}
    aPlayers[source].name = getPlayerName(source)
    aPlayers[source].ip = ip
    aPlayers[source].serial = serial or "N/A"
    aPlayers[source].country = country
    aPlayers[source].countryname = countryname
    aPlayers[source].account = "guest"
    aPlayers[source].groups = "None"

    local list = aPlayersTab.PlayerList
    local row = guiGridListAddRow(list)
    if (guiCheckBoxGetSelected(aPlayersTab.ColorCodes)) then
        guiGridListSetItemText(list, row, 1, stripColorCodes(getPlayerName(source)), false, false)
    else
        guiGridListSetItemText(list, row, 1, getPlayerName(source), false, false)
    end
    guiGridListSetItemData(list, row, 1, source)
    if (aSpecPlayerList) then
        local row = guiGridListAddRow(aSpecPlayerList)
        guiGridListSetItemText(aSpecPlayerList, row, 1, getPlayerName(source), false, false)
    end
end

function aPlayersTab.onClientPlayerQuit()
    local list = aPlayersTab.PlayerList
    local id = 0
    while (id <= guiGridListGetRowCount(list)) do
        if (guiGridListGetItemData(list, id, 1) == source) then
            guiGridListRemoveRow(list, id)
        end
        id = id + 1
    end
    if (aSpecPlayerList) then
        local id = 0
        while (id <= guiGridListGetRowCount(aSpecPlayerList)) do
            if (guiGridListGetItemText(aSpecPlayerList, id, 1) == getPlayerName(source)) then
                guiGridListRemoveRow(aSpecPlayerList, id)
            end
            id = id + 1
        end
    end
    aPlayers[source] = nil
end

function aPlayersTab.onClientSync(type, table)
    if (type == SYNC_PLAYER) then
        for type, data in pairs(table) do
            aPlayers[source][type] = data
        end
    elseif (type == SYNC_PLAYERS) then
        aPlayers = table
    elseif (type == SYNC_MESSAGES) then
        local prev = tonumber(string.sub(guiGetText(aPlayersTab.Messages), 1, 1))
        if (prev < table["unread"]) then
            playSoundFrontEnd(18)
        end
        guiSetText(aPlayersTab.Messages, table["unread"] .. "/" .. table["total"] .. " unread messages")
    end
end

function aPlayersTab.onRefresh()
    local player = getSelectedPlayer()
    if (not player) then
        return
    end

    local data = aPlayers[player]
    if (not data) then
        return
    end

    sync(SYNC_PLAYER, player)
    guiSetText(aPlayersTab.IP, "IP: " .. aPlayers[player].ip)
    guiSetText(aPlayersTab.Serial, "Serial: " .. (aPlayers[player].serial or "Unknown"))
    guiSetText(aPlayersTab.Country, "Country: " .. (aPlayers[player].countryname or "Unknown"))
    guiSetText(aPlayersTab.Account, "Account: " .. (aPlayers[player]["account"] or "guest"))
    guiSetText(aPlayersTab.Groups, "Groups: " .. (aPlayers[player]["groups"] or "None"))
    if (aPlayers[player].country and string.lower(tostring(aPlayers[player].country)) ~= "zz") then
        local x, y = guiGetPosition(aPlayersTab.Country, false)
        local width = guiLabelGetTextExtent(aPlayersTab.Country)
        guiSetPosition(aPlayersTab.Flag, x + width + 3, y + 4, false)
        guiSetVisible(
            aPlayersTab.Flag,
            guiStaticImageLoadImage(
                aPlayersTab.Flag,
                "client\\images\\flags\\" .. string.lower(tostring(aPlayers[player].country)) .. ".png"
            )
        )
    else
       guiSetVisible(aPlayersTab.Flag, false)
    end

    guiSetText(aPlayersTab.Name, "Name: " .. stripColorCodes(getPlayerName(player)))
    guiSetText(aPlayersTab.Mute, iif(aPlayers[player].mute, "Unmute", "Mute"))
    guiSetText(aPlayersTab.Freeze, iif(aPlayers[player].freeze, "Unfreeze", "Freeze"))

    if (isPedDead(player)) then
        guiSetText(aPlayersTab.Health, "Health: Dead")
    else
        guiSetText(aPlayersTab.Health, "Health: " .. math.ceil(getElementHealth(player)) .. "%")
    end

    guiSetText(aPlayersTab.Armour, "Armour: " .. math.ceil(getPedArmor(player)) .. "%")
    guiSetText(aPlayersTab.Skin, "Skin: " .. getElementModel(player) or "N/A")

    local team = getPlayerTeam(player)
    if (team) then
        guiSetText(aPlayersTab.Team, "Team: " .. getTeamName(team))
    else
        guiSetText(aPlayersTab.Team, "Team: None")
    end

    guiSetText(aPlayersTab.Ping, "Ping: " .. getPlayerPing(player) or 0)
    guiSetText(aPlayersTab.Money, "Money: " .. (aPlayers[player].money or 0))
    if (getElementDimension(player)) then
        guiSetText(aPlayersTab.Dimension, "Dimension: " .. getElementDimension(player))
    end
    if (getElementInterior(player)) then
        guiSetText(aPlayersTab.Interior, "Interior: " .. getElementInterior(player))
    end
    guiSetText(aPlayersTab.JetPack, iif(doesPedHaveJetPack(player), "Remove JetPack", "Give JetPack"))

    local weapon = getPedWeapon(player)
    if (weapon) then
        guiSetText(aPlayersTab.Weapon, "Weapon: " .. getWeaponNameFromID(weapon) .. " (ID: " .. weapon .. ")")
    end

    local x, y, z = getElementPosition(player)
    local area = getZoneName(x, y, z, false)
    local zone = getZoneName(x, y, z, true)
    guiSetText(aPlayersTab.Area, "Area: " .. iif(area == zone, area, area .. " (" .. zone .. ")"))
    guiSetText(aPlayersTab.PositionX, "X: " .. x)
    guiSetText(aPlayersTab.PositionY, "Y: " .. y)
    guiSetText(aPlayersTab.PositionZ, "Z: " .. z)

    local vehicle = getPedOccupiedVehicle(player)
    if (vehicle) then
        guiSetText(
            aPlayersTab.Vehicle,
            "Vehicle: " .. getVehicleName(vehicle) .. " (ID: " .. getElementModel(vehicle) .. ")"
        )
        guiSetText(aPlayersTab.VehicleHealth, "Vehicle Health: " .. math.ceil(getElementHealth(vehicle)) .. "%")
    else
        guiSetText(aPlayersTab.Vehicle, "Vehicle: Foot")
        guiSetText(aPlayersTab.VehicleHealth, "Vehicle Health: 0%")
    end
    return player
end

function aPlayersTab.onClientResourceStop()
    --[[aSetSetting("currentWeapon", aCurrentWeapon)
    aSetSetting("currentAmmo", aCurrentAmmo)
    aSetSetting("currentVehicle", aCurrentVehicle)
    aSetSetting("currentSlap", aCurrentSlap)]]
end

function aPlayersTab.Refresh()
    local selected = getSelectedPlayer()
    local list = aPlayersTab.PlayerList
    guiGridListClear(list)
    local strip = guiCheckBoxGetSelected(aPlayersTab.ColorCodes)
    for id, player in ipairs(getElementsByType("player")) do
        local row = guiGridListAddRow(list)
        local name = getPlayerName(player)
        if (strip) then
            name = stripColorCodes(name)
        end
        guiGridListSetItemText(list, row, 1, name, false, false)
        guiGridListSetItemData(list, row, 1, player)
        if (player == selected) then
            guiGridListSetSelectedItem(list, row, 1)
        end
    end
end

function getSelectedPlayer()
    local list = aPlayersTab.PlayerList
    local item = guiGridListGetSelectedItem(list)
    if (item ~= -1) then
        return guiGridListGetItemData(list, item, 1)
    end
    return nil
end
