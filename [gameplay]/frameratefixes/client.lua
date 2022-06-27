-- Fix for "Climbing over certain objects kills you, when you have high FPS"
-- https://github.com/multitheftauto/mtasa-blue/issues/602
function damageHandler(attacker, weapon, bodypart)
	if not attacker and weapon == 54 and bodypart == 3 then
		local task = {}
		task[1], task[2], task[3] = getPedTask(localPlayer, "primary", 3)
		if task[1] == "TASK_COMPLEX_JUMP" and task[2] == "TASK_COMPLEX_IN_AIR_AND_LAND" and task[3] == "TASK_SIMPLE_CLIMB" then
			cancelEvent()
		end
	end
end

addEventHandler("onClientPlayerDamage", localPlayer, damageHandler)
addEventHandler("onClientPedDamage", root, damageHandler)
