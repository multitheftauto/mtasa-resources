addEventHandler("onResourceStart",getResourceRootElement(getThisResource()),
	function()
		local freeroam = getResourceFromName("freeroam")
		if not freeroam then
			return
		end

		if getResourceState(freeroam) == "running" then
			outputChatBox ( "WARNING: 'FREEROAM' resource is currently running.  The resource has been shut off as a precaution!", getRootElement(), 255, 0, 0 )
			outputDebugString (  "WARNING: 'FREEROAM' resource is currently running.  The resource has been shut off as a precaution!" )
			stopResource(freeroam)
		end
	end
)
