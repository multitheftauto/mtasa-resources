WebBrowserGUI = {}
WebBrowserGUI.instance = nil

function WebBrowserGUI:new() local o=setmetatable({},{__index=WebBrowserGUI}) o:constructor() return o end

function WebBrowserGUI:constructor()
	local sizeX, sizeY = screenWidth * 0.9, screenHeight * 0.9
	self.m_Window = GuiWindow(screenWidth * 0.05, screenHeight * 0.05, sizeX, sizeY, "Web browser", false)
	self.m_Window:setSizable(false)

	self.m_BackButton = GuiButton(5, 25, 32, 32, "<", false, self.m_Window)
	self.m_BackButton:setEnabled(false)
	self.m_ForwardButton = GuiButton(42, 25, 32, 32, ">", false, self.m_Window)
	self.m_ForwardButton:setEnabled(false)
	self.m_EditAddress = GuiEdit(77, 25, sizeX - 192, 32, "Please enter an address", false, self.m_Window)
	self.m_DevButton = GuiButton(sizeX - 110, 25, 32, 32, "â", false, self.m_Window)
	self.m_LoadButton = GuiButton(sizeX - 75, 25, 32, 32, "â½", false, self.m_Window)
	self.m_ButtonClose = GuiButton(sizeX - 38, 25, 24, 24, "â", false, self.m_Window)
	self.m_ButtonClose:setProperty("NormalTextColour", "FFFF2929")
	self.m_ButtonClose:setProperty("HoverTextColour", "FF990909")
	self.m_ButtonClose:setFont("default-bold-small")

	self.m_Browser = GuiBrowser(5, 62, sizeX - 10, sizeY - 67, false, false, false, self.m_Window)

	if not self.m_Browser then
		outputChatBox( "Can't create browser. Check Settings->Web Browser" )
		self.m_Window:destroy()
		return
	end

	local browser = self.m_Browser:getBrowser()
	addEventHandler("onClientBrowserCreated", browser, function(...) self:Browser_Created(...) end)
	addEventHandler("onClientBrowserNavigate", browser, function(...) self:Browser_Navigate(...) end)
	addEventHandler("onClientBrowserWhitelistChange", root, function(...) self:Browser_WhitelistChange(...) end)
	addEventHandler("onClientBrowserDocumentReady", browser, function(...) self:Browser_DocumentReady(...) end)

	self.m_RequestedURL = ""

	showCursor(true)
	GuiElement.setInputMode("no_binds_when_editing")
end

function WebBrowserGUI:Browser_Created()
	addEventHandler("onClientGUIClick", self.m_LoadButton, function(...) self:LoadButton_Click(...) end, false)
	addEventHandler("onClientGUIAccepted", self.m_EditAddress, function(...) self:LoadButton_Click(...) end, false)
	addEventHandler("onClientGUIClick", self.m_BackButton, function(...) self:BackButton_Click(...) end, false)
	addEventHandler("onClientGUIClick", self.m_ForwardButton, function(...) self:ForwardButton_Click(...) end, false)
	addEventHandler("onClientGUIClick", self.m_ButtonClose, function(...) self:CloseButton_Click(...) end, false)
	addEventHandler("onClientGUIClick", self.m_DevButton, function(...) self:DevButton_Click(...) end, false)

	self:loadURL("https://mtasa.com/")
end

function WebBrowserGUI:Browser_Navigate(targetURL, isBlocked)
	if isBlocked then
		self.m_RequestedURL = targetURL
		Browser.requestDomains({targetURL}, true)
		return
	end
end

function WebBrowserGUI:Browser_WhitelistChange(whitelistedURLs)
	for i, v in pairs(whitelistedURLs) do
		if self.m_RequestedURL:find(v) then
			self.m_Browser:getBrowser():loadURL(self.m_RequestedURL)
			self.m_RequestedURL = ""
		end
	end
end

function WebBrowserGUI:Browser_DocumentReady()
	self.m_Window:setText("Web browser: " .. tostring(self.m_Browser:getBrowser():getTitle()))
	self.m_EditAddress:setText(tostring(self.m_Browser:getBrowser():getURL()))

	self.m_BackButton:setEnabled(self.m_Browser:getBrowser():canNavigateBack())
	self.m_ForwardButton:setEnabled(self.m_Browser:getBrowser():canNavigateForward())
end

-- // GUI Navigation
function WebBrowserGUI:LoadButton_Click(param1, state)
	if isElement(param1) or (param1 == "left" and state == "up") then
		self:loadURL(self.m_EditAddress:getText())
	end
end

function WebBrowserGUI:BackButton_Click(button, state)
	if button == "left" and state == "up" then
		self.m_Browser:getBrowser():navigateBack()
	end
end

function WebBrowserGUI:ForwardButton_Click(button, state)
	if button == "left" and state == "up" then
		self.m_Browser:getBrowser():navigateForward()
	end
end

function WebBrowserGUI:CloseButton_Click(button, state)
	if button == "left" and state == "up" then
		self.m_Window:destroy()
		showCursor(false)
		--GuiElement.setInputMode("no_binds_when_editing")
		WebBrowserGUI.instance = nil
	end
end

function WebBrowserGUI:DevButton_Click(button, state)
	if button == "left" and state == "up" then
		if not getDevelopmentMode() then
			exports.msgbox:guiShowMessageBox("You have to enable the development using setDevelopmentMode", "error", "Development mode required", false)
			return
		end

		self.m_Browser:getBrowser():toggleDevTools(true)
	end
end
-- \\ GUI Navigation

function WebBrowserGUI:loadURL(url)
	if url == "" then
		self.m_EditAddress:setText("about:blank")
		self.m_Browser:getBrowser():loadURL("about:blank")
		return
	elseif url:sub(0, 6)  == "about:" then
		self.m_EditAddress:setText(url)
		self.m_Browser:getBrowser():loadURL(url)
		return
	elseif url:sub(0, 7)  ~= "http://" and url:sub(0, 8) ~= "https://" then
		url = "http://"..url
	end

	if Browser.isDomainBlocked(url, true) then
		self.m_RequestedURL = url
		Browser.requestDomains({url}, true)
		return
	end

	self.m_EditAddress:setText(url)
	self.m_Browser:getBrowser():loadURL(url)
end
