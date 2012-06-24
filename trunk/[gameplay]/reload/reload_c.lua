addCommandHandler("Reload weapon",
	function()
		local task = getPedSimplestTask(localPlayer)
		if ((task == "TASK_SIMPLE_JUMP" or task == "TASK_SIMPLE_IN_AIR") and not doesPedHaveJetPack(localPlayer)) then return end
		triggerServerEvent("onPlayerReload", localPlayer)
	end
)

bindKey("r","down","Reload weapon")