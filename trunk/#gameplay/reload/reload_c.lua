addCommandHandler("Reload weapon",
	function()
		triggerServerEvent("onPlayerReload",getLocalPlayer())
	end
)

bindKey("r","down","Reload weapon")