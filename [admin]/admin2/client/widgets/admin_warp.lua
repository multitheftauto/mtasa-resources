--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_warp.lua
*
*	Original File by lil_Toady
*
**************************************]]

aWarpForm           = nil
aWarpToPositionForm = nil

function aPlayerWarp(player)
    if (aWarpForm == nil) then
        local x, y = guiGetScreenSize()
        aWarpForm = guiCreateWindow(x / 2 - 110, y / 2 - 150, 200, 330, "Player Warp Management", false)
        aWarpList = guiCreateGridList(0.03, 0.08, 0.94, 0.64, true, aWarpForm)
        guiGridListAddColumn(aWarpList, "Player", 0.9)
        aWarpSelect     = guiCreateButton(0.03, 0.74, 0.94, 0.07, "Select", true, aWarpForm)
        aWarpToPosition = guiCreateButton(0.03, 0.82, 0.94, 0.07, "To position", true, aWarpForm)
        aWarpCancel     = guiCreateButton(0.03, 0.90, 0.94, 0.07, "Cancel", true, aWarpForm)

        addEventHandler("onClientGUIDoubleClick", aWarpForm, aClientWarpDoubleClick)
        addEventHandler("onClientGUIClick", aWarpForm, aClientWarpClick)
        --Register With Admin Form
        aRegister("PlayerWarp", aWarpForm, aPlayerWarp, aPlayerWarpClose)
    end
    aWarpSelectPointer = player
    guiGridListClear(aWarpList)
    for id, player in ipairs(getElementsByType("player")) do
        if (player ~= aWarpSelectPointer) then
            guiGridListSetItemText(aWarpList, guiGridListAddRow(aWarpList), 1, getPlayerName(player), false, false)
        end
    end
    guiSetVisible(aWarpForm, true)
    guiBringToFront(aWarpForm)
end

function aPlayerWarpClose(destroy)
    if ((destroy) --[[or (guiCheckBoxGetSelected(aPerformanceWarp))]]) then
        if (aWarpForm) then
            removeEventHandler("onClientGUIDoubleClick", aWarpForm, aClientWarpDoubleClick)
            removeEventHandler("onClientGUIClick", aWarpForm, aClientWarpClick)
            destroyElement(aWarpForm)
            aWarpForm = nil
        end
    else
        guiSetVisible(aWarpForm, false)
    end
end


function aPlayerWarpToPosition()
    if (aWarpToPositionForm == nil) then
        local x, y = guiGetScreenSize()
        local h    = y * 0.75
        aWarpToPositionForm     = guiCreateWindow(x / 2 - h / 2, y / 2 - h / 2, h, h + 40, "Player Warp To Position", false)
        aWarpToPositionMap      = guiCreateStaticImage(10, 25, h - 20, h - 20, "client/images/map.png", false, aWarpToPositionForm)
        aWarpToPositionTeleport = guiCreateButton(10,     h + 10, 80, 25, "Teleport", false, aWarpToPositionForm)
        aWarpToPositionCancel   = guiCreateButton(h - 90, h + 10, 80, 25, "Cancel",   false, aWarpToPositionForm)
        aWarpToPositionX        = guiCreateEdit(100, h + 10, 80, 25, "0", false, aWarpToPositionForm)
        aWarpToPositionY        = guiCreateEdit(185, h + 10, 80, 25, "0", false, aWarpToPositionForm)
        aWarpToPositionZ        = guiCreateEdit(270, h + 10, 80, 25, "3", false, aWarpToPositionForm)

        addEventHandler("onClientGUIDoubleClick", aWarpToPositionForm, aClientWarpDoubleClick)
        addEventHandler("onClientGUIClick", aWarpToPositionForm, aClientWarpClick)
        --Register With Admin Form
        aRegister("PlayerWarpToPosition", aWarpToPositionForm, aPlayerWarpToPosition, aPlayerWarpToPositionClose)
    end
    guiSetVisible(aWarpToPositionForm, true)
    guiBringToFront(aWarpToPositionForm)
end

function aPlayerWarpToPositionClose(destroy)
    if ((destroy) --[[or (aPerformanceWarp and guiCheckBoxGetSelected(aPerformanceWarp))--]]) then
        if (aWarpToPositionForm) then
            removeEventHandler("onClientGUIDoubleClick", aWarpToPositionForm, aClientWarpDoubleClick)
            removeEventHandler("onClientGUIClick", aWarpToPositionForm, aClientWarpClick)
            destroyElement(aWarpToPositionForm )
            aWarpToPositionForm = nil
        end
    else
        guiSetVisible(aWarpToPositionForm, false)
    end
end

local function calculatePosition(absX, absY)
    local x, y  = guiGetPosition(aWarpToPositionForm, false)
          x, y  = x + 10, y + 25
    local w, h  = guiGetSize(aWarpToPositionMap, false)
    local tpX, tpY       = (absX - x) / w * 6000 - 3000, - ((absY - y) / h * 6000 - 3000)
    local hit, _, _, tpZ = processLineOfSight(tpX, tpY, 3000, tpX, tpY, -3000)
                     tpZ = hit and tpZ or "auto"
    guiSetText(aWarpToPositionX, tpX); guiSetText(aWarpToPositionY, tpY); guiSetText(aWarpToPositionZ, tpZ)
    return tpX, tpY, tpY
end

local function getTeleportPosition()
    return guiGetText(aWarpToPositionX), guiGetText(aWarpToPositionY), guiGetText(aWarpToPositionZ)
end

local function warpToPosition(player, x, y, z)
    if isElement(player) then
        local x, y, z  = tonumber(x) or 0, tonumber(y) or 0, tonumber(z) or 0
        local distance = getElementDistanceFromCentreOfMassToBaseOfModel(player)
        triggerServerEvent(
            "aPlayer",
            localPlayer,
            player,
            "warpto",
            { x, y, z + distance + 0.25 }
        )
        aPlayerWarpToPositionClose(false)
        aPlayerWarpClose(false)
    end
end

local function warpPlayerToPositionTrigger()
    local x, y, z = getTeleportPosition()
    if z == "auto" then
        local target = getPedOccupiedVehicle(localPlayer) or localPlayer
        fadeCamera(false, 0)
        setElementFrozen(target, true)
        setCameraMatrix(x, y, 0)
        setTimer(function()
            local hit, _, _, hitZ = processLineOfSight(x, y, 3000, x, y, -3000)
            setCameraTarget(localPlayer)
            setElementFrozen(target, false)
            fadeCamera(true, 0.1)
            if not hit then return end
            warpToPosition(aWarpSelectPointer, x, y, hitZ)
        end, 100, 1)
    else
        warpToPosition(aWarpSelectPointer, x, y, z)
    end
end

function aClientWarpDoubleClick(button)
    if (button == "left") then
        if (source == aWarpList) then
            if (guiGridListGetSelectedItem(aWarpList) ~= -1) then
                if isElement(aWarpSelectPointer) then
                    triggerServerEvent(
                        "aPlayer",
                        localPlayer,
                        aWarpSelectPointer,
                        "warpto",
                        getPlayerFromName(guiGridListGetItemText(aWarpList, guiGridListGetSelectedItem(aWarpList), 1))
                    )
                end
                aPlayerWarpClose(false)
            end
        elseif (source == aWarpToPositionMap) then
            warpPlayerToPositionTrigger()
        end
    end
end

function aClientWarpClick(button, state, absX, absY)
    if (button == "left") then
        -- Player Warp Management
        if (source == aWarpSelect) then
            if (guiGridListGetSelectedItem(aWarpList) ~= -1) then
                if isElement(aWarpSelectPointer) then
                    triggerServerEvent(
                        "aPlayer",
                        localPlayer,
                        aWarpSelectPointer,
                        "warpto",
                        getPlayerFromName(guiGridListGetItemText(aWarpList, guiGridListGetSelectedItem(aWarpList), 1))
                    )
                end
                aPlayerWarpClose(false)
            end
        elseif (source == aWarpCancel) then
            aPlayerWarpClose(false)
        elseif (source == aWarpToPosition) then
            aPlayerWarpToPosition()

        -- Player Warp To Position Map
        elseif (source == aWarpToPositionMap) then
            calculatePosition(absX, absY)
        elseif (source == aWarpToPositionTeleport) then
            warpPlayerToPositionTrigger()
        elseif (source == aWarpToPositionCancel) then
            aPlayerWarpToPositionClose(false)
        end
    end
end