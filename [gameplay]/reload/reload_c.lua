local reloadCmd = "Reload weapon"
local reloadKey = getKeyBoundToCommand("Reload weapon")
if not reloadKey then
    reloadKey = "r"
end

local blockedTasks = {
    ["TASK_SIMPLE_JUMP"] = true,
    ["TASK_SIMPLE_LAND"] = true,
    ["TASK_SIMPLE_SWIM"] = true,
    ["TASK_SIMPLE_FALL"] = true,
    ["TASK_SIMPLE_CLIMB"] = true,
    ["TASK_SIMPLE_GET_UP"] = true,
    ["TASK_SIMPLE_IN_AIR"] = true,
    ["TASK_SIMPLE_HIT_HEAD"] = true,
    ["TASK_SIMPLE_NAMED_ANIM"] = true,
    ["TASK_SIMPLE_CAR_GET_IN"] = true,
    ["TASK_SIMPLE_GO_TO_POINT"] = true,
    ["TASK_SIMPLE_CAR_OPEN_DOOR_FROM_OUTSIDE"] = true,
}

local function reloadTimer()
    local task = getPedSimplestTask(localPlayer)
    if blockedTasks[task] then return end
    if isPedInVehicle(localPlayer) then return end
    if getPedAmmoInClip(localPlayer) == getPedTotalAmmo(localPlayer) then return end
    triggerServerEvent("relWep", localPlayer)
end

local function reloadWeapon()
    setTimer(reloadTimer, math.random(50, 120), 1)
end

bindKey(reloadKey, "down", reloadCmd)
addCommandHandler(reloadCmd, reloadWeapon)
