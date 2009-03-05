addEventHandler("onResourceStart",getResourceRootElement(getThisResource()),
	function()
		if not getResourceFromName"freeroam" then
			outputChatBox ( "WARNING: 'FREEROAM' RESOURCE NOT FOUND.  Editor will not function properly.  Please install the 'freeroam' resource immediately!", getRootElement(), 255, 0, 0 )
		end
	end
)