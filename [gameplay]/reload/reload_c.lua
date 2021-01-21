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

local function reloadWeapon()
    if blockedTasks[getPedSimplestTask(localPlayer)] then
        return
    end
    triggerServerEvent("relWep", resourceRoot)
end

-- The jump task is not instantly detectable and bindKey works quicker than getControlState
-- If you try to reload and jump at the same time, you will be able to instant reload.
-- We work around this by adding an unnoticable delay to foil this exploit.
addCommandHandler("Reload weapon", function()
    setTimer(reloadWeapon, 50, 1)
end)
bindKey("r", "down", "Reload weapon")
