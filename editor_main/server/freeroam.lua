addEventHandler("onResourceStart",resourceRoot,
	function()
		local freeroam = getResourceFromName("freeroam")
		if not freeroam then
			return
		end

		if getResourceState(freeroam) == "running" then
			outputChatBox ( "INFO: 'FREEROAM' resource is currently running.  The resource has been shut off as a precaution!", root, 255, 255, 0 )
			outputDebugString (  "'FREEROAM' resource is currently running.  The resource has been shut off as a precaution!",4,255,255,0 )
			stopResource(freeroam)
		end
	end
)
