addEventHandler("onResourceStart",getResourceRootElement(getThisResource()),
	function()
		if getResourceState(getResourceFromName"freeroam") == "running" then
			outputChatBox ( "WARNING: 'FREEROAM' resource is currently running.  The resource has been shut off as a precaution!", getRootElement(), 255, 0, 0 )
			outputDebugString (  "WARNING: 'FREEROAM' resource is currently running.  The resource has been shut off as a precaution!" )
			stopResource(getResourceFromName"freeroam")
		end
	end
)