local spamTimer = {}

local function reloadWeapon(player)
    if getControlState(player, "aim_weapon") then return end
    if getControlState(player, "fire") then return end
    if isPedDead(player) then return end
    if isPedInVehicle(player) then return end
    if getPedWeapon(player) == 0 then return end

    if getPedAmmoInClip(player) == getPedTotalAmmo(player) then return end

    if spamTimer[player] and getTickCount() - spamTimer[player] < 3000 then
        return
    end

    spamTimer[player] = getTickCount()
    reloadPedWeapon(player)
end

addEventHandler("onPlayerJoin", root, function()
    bindKey(source, "r", "down", reloadWeapon)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    for _, player in ipairs(getElementsByType("player")) do
        bindKey(player, "r", "down", reloadWeapon)
    end
end)

addEventHandler("onPlayerWeaponReload", root, function()
    spamTimer[source] = getTickCount()
end)

addEventHandler("onPlayerQuit", root, function()
    spamTimer[source] = nil
end)
