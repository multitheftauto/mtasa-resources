--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_spectator.lua
*
*	Original File by lil_Toady
*
**************************************]]
aSpectator = {Offset = 5, AngleX = 0, AngleZ = 30, Spectating = nil}

function aSpectate(player)
    --if ( player == localPlayer ) then
    --	messageBox ( "Can not spectate yourself", MB_ERROR, MB_OK )
    --	return
    --end
    aSpectator.Spectating = player
    if ((not aSpectator.Actions) or (not guiGetVisible(aSpectator.Actions))) then
        aSpectator.Open()
    end
end

function aSpectator.Open()
    if (aSpectator.Actions == nil) then
        local x, y = guiGetScreenSize()
        aSpectator.Actions = guiCreateWindow(x - 190, y / 2 - 200, 160, 400, "Actions", false)
        aSpectator.Ban = guiCreateButton(0.10, 0.09, 0.80, 0.05, "Ban", true, aSpectator.Actions)
        aSpectator.Kick = guiCreateButton(0.10, 0.15, 0.80, 0.05, "Kick", true, aSpectator.Actions)
        aSpectator.Freeze = guiCreateButton(0.10, 0.21, 0.80, 0.05, "Freeze", true, aSpectator.Actions)
        aSpectator.SetSkin = guiCreateButton(0.10, 0.27, 0.80, 0.05, "Set Skin", true, aSpectator.Actions)
        aSpectator.SetHealth = guiCreateButton(0.10, 0.33, 0.80, 0.05, "Set Health", true, aSpectator.Actions)
        aSpectator.SetArmour = guiCreateButton(0.10, 0.39, 0.80, 0.05, "Set Armour", true, aSpectator.Actions)
        aSpectator.SetStats = guiCreateButton(0.10, 0.45, 0.80, 0.05, "Set Stats", true, aSpectator.Actions)
        aSpectator.Slap = guiCreateButton(0.10, 0.51, 0.80, 0.05, "Slap! 20hp", true, aSpectator.Actions)
        aSpectator.Slaps = guiCreateGridList(0.10, 0.51, 0.80, 0.48, true, aSpectator.Actions)
        guiGridListAddColumn(aSpectator.Slaps, "", 0.60)
        guiGridListAddColumn(aSpectator.Slaps, "", 0.60)
        guiSetVisible(aSpectator.Slaps, false)
        local i = 0
        while i <= 5 do
            guiGridListSetItemText(
                aSpectator.Slaps,
                guiGridListAddRow(aSpectator.Slaps),
                2,
                tostring(i * 20),
                false,
                false
            )
            i = i + 1
        end
        guiGridListRemoveColumn(aSpectator.Slaps, 1)

		aSpectator.CollideWithWalls = guiCreateCheckBox ( 0.08, 0.8, 0.84, 0.04, "Collide with walls", true, true, aSpectator.Actions )
        aSpectator.Skip = guiCreateCheckBox(0.08, 0.85, 0.84, 0.04, "Skip dead players", true, true, aSpectator.Actions)
        guiCreateLabel(0.08, 0.89, 0.84, 0.04, "____________________", true, aSpectator.Actions)
        aSpectator.Back = guiCreateButton(0.10, 0.93, 0.80, 0.05, "Back", true, aSpectator.Actions)

        aSpectator.Players = guiCreateWindow(30, y / 2 - 200, 160, 400, "Players", false)
        guiWindowSetSizable(aSpectator.Players, false)
        aSpectator.PlayerList = guiCreateGridList(0.03, 0.07, 0.94, 0.92, true, aSpectator.Players)
        guiGridListAddColumn(aSpectator.PlayerList, "Player Name", 0.85)
        for id, player in ipairs(getElementsByType("player")) do
            local row = guiGridListAddRow(aSpectator.PlayerList)
            guiGridListSetItemText(aSpectator.PlayerList, row, 1, getPlayerName(player), false, false)
            if (player == aSpectator.Spectating) then
                guiGridListSetSelectedItem(aSpectator.PlayerList, row, 1)
            end
        end
        aSpectator.Prev = guiCreateButton(x / 2 - 100, y - 50, 70, 30, "< Previous", false)
        aSpectator.Next = guiCreateButton(x / 2 + 30, y - 50, 70, 30, "Next >", false)

        addEventHandler("onClientGUIClick", aSpectator.Actions, aSpectator.ClientClick)
        addEventHandler("onClientGUIClick", aSpectator.Players, aSpectator.ClientClick)
        addEventHandler("onClientGUIClick", aSpectator.Prev, aSpectator.ClientClick)
        addEventHandler("onClientGUIClick", aSpectator.Next, aSpectator.ClientClick)

        aRegister("Spectator", aSpectator.Actions, aSpectator.Open, aSpectator.Close)
    end

    bindKey("arrow_l", "down", aSpectator.SwitchPlayer, -1)
    bindKey("arrow_r", "down", aSpectator.SwitchPlayer, 1)
    bindKey("mouse_wheel_up", "down", aSpectator.MoveOffset, -1)
    bindKey("mouse_wheel_down", "down", aSpectator.MoveOffset, 1)
    bindKey("mouse2", "both", aSpectator.Cursor)
    addEventHandler("onClientPlayerWasted", root, aSpectator.PlayerCheck)
    addEventHandler("onClientPlayerQuit", root, aSpectator.PlayerCheck)
    addEventHandler("onClientCursorMove", root, aSpectator.CursorMove)
    addEventHandler("onClientRender", root, aSpectator.Render)

    guiSetVisible(aSpectator.Actions, true)
    guiSetVisible(aSpectator.Players, true)
    guiSetVisible(aSpectator.Next, true)
    guiSetVisible(aSpectator.Prev, true)
    aAdminMain.Close(false, "Spectator")

    showCursor(true)
end

function aSpectator.Cursor(key, state)
    local show = not isCursorShowing()
    guiSetVisible(aSpectator.Actions, show)
    guiSetVisible(aSpectator.Players, show)
    guiSetVisible(aSpectator.Next, show)
    guiSetVisible(aSpectator.Prev, show)
    showCursor(show)
end

function aSpectator.Close(destroy)
    if (aSpectator.Actions) then
        unbindKey("arrow_l", "down", aSpectator.SwitchPlayer, -1)
        unbindKey("arrow_r", "down", aSpectator.SwitchPlayer, 1)
        unbindKey("mouse_wheel_up", "down", aSpectator.MoveOffset, -1)
        unbindKey("mouse_wheel_down", "down", aSpectator.MoveOffset, 1)
        unbindKey("mouse2", "both", aSpectator.Cursor)
        removeEventHandler("onClientPlayerWasted", root, aSpectator.PlayerCheck)
        removeEventHandler("onClientPlayerQuit", root, aSpectator.PlayerCheck)
        removeEventHandler("onClientMouseMove", root, aSpectator.CursorMove)
        removeEventHandler("onClientRender", root, aSpectator.Render)

        if (destroy) then
            destroyElement(aSpectator.Actions)
            destroyElement(aSpectator.Players)
            destroyElement(aSpectator.Next)
            destroyElement(aSpectator.Prev)
            aSpectator.Actions = nil
        else
            guiSetVisible(aSpectator.Actions, false)
            guiSetVisible(aSpectator.Players, false)
            guiSetVisible(aSpectator.Next, false)
            guiSetVisible(aSpectator.Prev, false)
        end
    end
    setCameraTarget(localPlayer)
    aSpectator.Spectating = nil
end

function aSpectator.ClientClick(button)
    if (source == aSpectator.Slaps) then
        return
    end
    guiSetVisible(aSpectator.Slaps, false)
    if (button == "left") then
        if (source == aSpectator.Back) then
            aSpectator.Close(false)
            aAdminMain.Open()
        elseif (source == aSpectator.Ban) then
            triggerEvent("onClientGUIClick", aPlayersTab.Ban, "left")
        elseif (source == aSpectator.Kick) then
            triggerEvent("onClientGUIClick", aPlayersTab.Kick, "left")
        elseif (source == aSpectator.Freeze) then
            triggerEvent("onClientGUIClick", aPlayersTab.Freeze, "left")
        elseif (source == aSpectator.SetSkin) then
            triggerEvent("onClientGUIClick", aPlayersTab.SetSkin, "left")
        elseif (source == aSpectator.SetHealth) then
            triggerEvent("onClientGUIClick", aPlayersTab.SetHealth, "left")
        elseif (source == aSpectator.SetArmour) then
            triggerEvent("onClientGUIClick", aPlayersTab.SetArmour, "left")
        elseif (source == aSpectator.SetStats) then
            triggerEvent("onClientGUIClick", aPlayersTab.SetStats, "left")
        elseif (source == aSpectator.Slap) then
            triggerEvent("onClientGUIClick", aPlayersTab.Slap, "left")
        elseif (source == aSpectator.Next) then
            aSpectator.SwitchPlayer(1)
        elseif (source == aSpectator.Prev) then
            aSpectator.SwitchPlayer(-1)
        elseif (source == aSpectator.PlayerList) then
            if (guiGridListGetSelectedItem(source) ~= -1) then
                aSpectate(getPlayerFromName(guiGridListGetItemText(source, guiGridListGetSelectedItem(source), 1)))
            end
        end
    end
end

function aSpectator.PlayerCheck()
    if (source == aSpectator.Spectating) then
        aSpectator.SwitchPlayer(1)
    end
end

function aSpectator.SwitchPlayer(inc, arg, inc2)
    if (not tonumber(inc)) then
        inc = inc2
    end
    if (not tonumber(inc)) then
        return
    end
    local players
    if (guiCheckBoxGetSelected(aSpectator.Skip)) then
        players = aSpectator.GetAlive()
    else
        players = getElementsByType("player")
    end
    if (#players <= 0) then
        if (messageBox("Nobody else to spectate, exit spectator?", 1, 1) == true) then
            aSpectator.Close(false)
            aAdminMain.Open()
        end
        return
    end
    local current = 1
    for id, player in ipairs(players) do
        if (player == aSpectator.Spectating) then
            current = id
        end
    end
    local next = ((current - 1 + inc) % #players) + 1
    if (next == current) then
        if (messageBox("Nobody else to spectate, exit spectator?", 1, 1) == true) then
            aSpectator.Close(false)
            aAdminMain.Open()
        end
        return
    end
    aSpectator.Spectating = players[next]
end

function aSpectator.CursorMove(rx, ry, x, y)
    if (not isCursorShowing()) then
        local sx, sy = guiGetScreenSize()
        aSpectator.AngleX = (aSpectator.AngleX + (x - sx / 2) / 10) % 360
        aSpectator.AngleZ = (aSpectator.AngleZ + (y - sy / 2) / 10) % 360
        if (aSpectator.AngleZ > 180) then
            if (aSpectator.AngleZ < 315) then
                aSpectator.AngleZ = 315
            end
        else
            if (aSpectator.AngleZ > 45) then
                aSpectator.AngleZ = 45
            end
        end
    end
end

function aSpectator.Render()
    local sx, sy = guiGetScreenSize()
    if (not aSpectator.Spectating) then
        dxDrawText("Nobody to spectate", sx - 170, 200, sx - 170, 200, tocolor(255, 0, 0, 255), 1)
        return
    end

    local x, y, z = getElementPosition(aSpectator.Spectating)

    if (not x) then
        dxDrawText("Error recieving coordinates", sx - 170, 200, sx - 170, 200, tocolor(255, 0, 0, 255), 1)
        return
    end

    local offset = aSpectator.Offset

	if guiCheckBoxGetSelected(aSpectator.CollideWithWalls) then
		local nearest_hit = aSpectator.CheckCollision(x, y, z)
		if nearest_hit and (nearest_hit < offset) then
            offset = nearest_hit
        end
	end

    local ox, oy, oz
    ox = x - math.sin(math.rad(aSpectator.AngleX)) * offset
    oy = y - math.cos(math.rad(aSpectator.AngleX)) * offset
    oz = z + math.tan(math.rad(aSpectator.AngleZ)) * offset
    setCameraMatrix(ox, oy, oz, x, y, z)

    dxDrawText(
        "Spectating: " .. getPlayerName(aSpectator.Spectating),
        sx - 170,
        200,
        sx - 170,
        200,
        tocolor(255, 255, 255, 255),
        1
    )
    if (_DEBUG) then
        dxDrawText(
            "DEBUG:\nAngleX: " ..
                aSpectator.AngleX ..
                    "\nAngleZ: " ..
                        aSpectator.AngleZ ..
                            "\n\nOffset: " ..
                                aSpectator.Offset ..
                                    "\nX: " ..
                                        ox ..
                                            "\nY: " ..
                                                oy ..
                                                    "\nZ: " ..
                                                        oz ..
                                                            "\nDist: " ..
                                                                getDistanceBetweenPoints3D(x, y, z, ox, oy, oz),
            sx - 170,
            sy - 180,
            sx - 170,
            sy - 180,
            tocolor(255, 255, 255, 255),
            1
        )
    else
        if (isCursorShowing()) then
            dxDrawText(
                "Tip: mouse2 - toggle free camera mode",
                20,
                sy - 50,
                20,
                sy - 50,
                tocolor(255, 255, 255, 255),
                1
            )
        else
            dxDrawText("Tip: Use mouse scroll to zoom in/out", 20, sy - 50, 20, sy - 50, tocolor(255, 255, 255, 255), 1)
        end
    end
end

local checks = {
    {-1, -0.5},
    {-1, 0.5},
    {1, 0.5},
    {1, -0.5},
}

function aSpectator.CheckCollision(x, y, z)
	local nearest_distance

	for k, v in ipairs(checks) do
		local xx, yy, zz = getPositionFromOffset(getCamera(), v[1], 0, v[2])
		local hit, hitx, hity, hitz = processLineOfSight(xx, yy, zz, x, y, z, true, true, false, true, true, false, false, false, (getPedOccupiedVehicle(localPlayer) or nil))
		if hit then
			local dist = getDistanceBetweenPoints3D(x, y, z, hitx, hity, hitz)
			if (dist <= (nearest_distance or math.huge)) then
				nearest_distance = dist
			end
		end
	end
	
	return nearest_distance or false
end

function aSpectator.MoveOffset(key, state, inc)
    if (not isCursorShowing()) then
        aSpectator.Offset = aSpectator.Offset + tonumber(inc)
        if (aSpectator.Offset > 70) then
            aSpectator.Offset = 70
        elseif (aSpectator.Offset < 2) then
            aSpectator.Offset = 2
        end
    end
end

function aSpectator.GetAlive()
    local alive = {}
    for id, player in ipairs(getElementsByType("player")) do
        if (not isPedDead(player)) then
            table.insert(alive, player)
        end
    end
    return alive
end

function getPositionFromOffset(element, x, y, z)
    local matrix = getElementMatrix(element)
    local offX = x * matrix[1][1] + y * matrix[2][1] + z * matrix[3][1] + matrix[4][1]
    local offY = x * matrix[1][2] + y * matrix[2][2] + z * matrix[3][2] + matrix[4][2]
    local offZ = x * matrix[1][3] + y * matrix[2][3] + z * matrix[3][3] + matrix[4][3]
    return offX, offY, offZ
end
