screenWidth, screenHeight = guiGetScreenSize()

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		-- Register bind for toggling the mouse cursor
		bindKey("lalt", "down", function(button, state) showCursor(not isCursorShowing()) end)
		
		-- Create Chromium icon
		local icon = GuiStaticImage.create(0, screenHeight - 48, 48, 48, "chromiumIcon.png", false)
		addEventHandler("onClientGUIClick", icon,
			function(button, state)
				if button == "left" and state == "up" then
					-- Check if browser is supported
					if not Browser.isSupported() then
						outputChatBox("Your operating system does not support the browser. Please consider upgrading to a newer OS version", 255, 0, 0)
						return
					end
					
					-- Create the browser now
					if WebBrowserGUI.instance ~= nil then return end
					WebBrowserGUI.instance = WebBrowserGUI:new()
				end
			end
		)
	end
)
