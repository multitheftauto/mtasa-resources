screenWidth, screenHeight = guiGetScreenSize()

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		-- Register bind for toggling the mouse cursor
		bindKey("lalt", "down", function(button, state) showCursor(not isCursorShowing()) end)

		-- Create Chromium icon
		local icon = GuiStaticImage(0, screenHeight - 48, 48, 48, "chromiumIcon.png", false)
		addEventHandler("onClientGUIClick", icon,
			function(button, state)
				if button == "left" and state == "up" then
					-- Create the browser now
					if WebBrowserGUI.instance ~= nil then return end
					WebBrowserGUI.instance = WebBrowserGUI:new()
				end
			end
		)
	end
)
