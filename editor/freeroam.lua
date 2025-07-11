addEventHandler("onResourceStart", resourceRoot,
	function()
		if not getResourceFromName("freeroam") then
			outputChatBox("WARNING: 'FREEROAM' RESOURCE NOT FOUND.  Editor will not function properly.  Please install the 'freeroam' resource immediately!", root, 255, 0, 0)
			outputDebugString("WARNING: 'FREEROAM' RESOURCE NOT FOUND.  Editor will not function properly.  Please install the 'freeroam' resource immediately!")
		end
	end
)
