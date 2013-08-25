sfxBrowser = {}
local screenWidth, screenHeight = guiGetScreenSize()

function sfxBrowser:new()
	local object = setmetatable({}, {__index = sfxBrowser})
	if object.constructor then
		object.constructor(self)
	end
	return object
end

function sfxBrowser:constructor()
	self.m_CurrentContainer = nil
	self.m_CurrentBank = nil
	self.m_CurrentSFX = nil

	-- Create the GUI
	self.m_GUI = {}
	self.m_GUI.window = guiCreateWindow(screenWidth/2 - 609/2, screenHeight/2 - 421/2, 609, 415, "SFX browser", false) -- old height: 421
	self.m_GUI.containerGrid = guiCreateGridList(9, 26, 88, 291, false, self.m_GUI.window)
	self.m_GUI.bankGrid = guiCreateGridList(103, 24, 354, 293, false, self.m_GUI.window)
	self.m_GUI.sfxGrid = guiCreateGridList(462, 39, 137, 278, false, self.m_GUI.window) -- old y: 24; old height: 293
	self.m_GUI.luaEdit = guiCreateEdit(9, 327, 590, 30, "Lua code - Please select a sound first", false, self.m_GUI.window)
	self.m_GUI.loopedCheck = guiCreateCheckBox(11, 368, 82, 34, "Looped?", false, false, self.m_GUI.window)
	self.m_GUI.playButton = guiCreateButton(103, 368, 127, 34, "Play", false, self.m_GUI.window)
	self.m_GUI.soundProgress = guiCreateProgressBar(240, 370, 359, 32, false, self.m_GUI.window)
	self.m_GUI.closeButton = guiCreateButton(580, 20, 19, 19, "X", false, self.m_GUI.window)
	
	-- Setup gridlist columns
	guiGridListAddColumn(self.m_GUI.containerGrid, "Container", 0.8)
	guiGridListAddColumn(self.m_GUI.bankGrid, "Banks", 0.15)
	guiGridListAddColumn(self.m_GUI.bankGrid, "Description", 0.8)
	guiGridListAddColumn(self.m_GUI.sfxGrid, "SFX", 1.0)
	
	guiGridListSetSortingEnabled(self.m_GUI.bankGrid, false)
	guiGridListSetSortingEnabled(self.m_GUI.sfxGrid, false)
	guiWindowSetSizable(self.m_GUI.window, false)
	guiEditSetReadOnly(self.m_GUI.luaEdit, true)
	
	for containerName in pairs(self.ms_Data) do
		local row = guiGridListAddRow(self.m_GUI.containerGrid)
		guiGridListSetItemText(self.m_GUI.containerGrid, row, 1, containerName, false, false)
	end
	
	guiSetVisible(self.m_GUI.window, false)
	addEventHandler("onClientGUIClick", self.m_GUI.playButton, function(...) self:playButton_Click(...) end, false)
	addEventHandler("onClientGUIClick", self.m_GUI.containerGrid, function(...) self:containerGrid_Click(...) end, false)
	addEventHandler("onClientGUIClick", self.m_GUI.bankGrid, function(...) self:bankGrid_Click(...) end, false)
	addEventHandler("onClientGUIClick", self.m_GUI.sfxGrid, function(...) self:sfxGrid_Click(...) end, false)
	addEventHandler("onClientGUIDoubleClick", self.m_GUI.sfxGrid, function(...) self:sfxGrid_DoubleClick(...) end, false)
	addEventHandler("onClientGUIClick", self.m_GUI.closeButton, function(...) self:closeButton_Click(...) end, false)
	addEventHandler("onClientGUIClick", self.m_GUI.loopedCheck, function(...) self:loopedCheck_Click(...) end, false)
end

function sfxBrowser:open()
	guiSetVisible(self.m_GUI.window, true)
end

function sfxBrowser:close()
	guiSetVisible(self.m_GUI.window, false)
	
	-- Stop currently playing sounds
	if self.m_Sound and isElement(self.m_Sound) then
		destroyElement(self.m_Sound)
	end
end

function sfxBrowser:isOpen()
	return guiGetVisible(self.m_GUI.window)
end

function sfxBrowser:makeLuacode()
	if self.m_CurrentContainer and self.m_CurrentBank and self.m_CurrentSFX then
		return ("playSFX(\"%s\", %d, %d, %s)"):format(self.m_CurrentContainer, self.m_CurrentBank, self.m_CurrentSFX, tostring(guiCheckBoxGetSelected(self.m_GUI.loopedCheck)))
	end
	return false
end

function sfxBrowser:updateLuacode()
	if self:makeLuacode() then
		guiSetText(self.m_GUI.luaEdit, self:makeLuacode())
	end
end

function sfxBrowser:playCurrent()
	if self.m_Sound and isElement(self.m_Sound) then
		destroyElement(self.m_Sound)
	end
	
	if not self.m_CurrentContainer or not self.m_CurrentBank or not self.m_CurrentSFX then
		outputChatBox("Please select a sound first!", 255, 0, 0)
		return false
	end
	
	self.m_Sound = playSFX(self.m_CurrentContainer, self.m_CurrentBank, self.m_CurrentSFX, guiCheckBoxGetSelected(self.m_GUI.loopedCheck))
	if not self.m_Sound then
		outputChatBox("Some audio files are missing! Please check your GTASA\Audio\SFX\ folder!", 255, 0, 0)
		return false
	end
	
	-- Reset progressbar and its timer
	guiProgressBarSetProgress(self.m_GUI.soundProgress, 0)
	if self.m_ProgressTimer and isTimer(self.m_ProgressTimer) then
		killTimer(self.m_ProgressTimer)
	end
	
	self.m_ProgressTimer = setTimer(
		function()
			if self:isSoundEnded() then
				killTimer(self.m_ProgressTimer)
				return
			end
			
			local progress = getSoundPosition(self.m_Sound)/getSoundLength(self.m_Sound)*100
			guiProgressBarSetProgress(self.m_GUI.soundProgress, progress)
			if progress >= 100 then
				killTimer(self.m_ProgressTimer)
			end
		end, 100, 0
	)
end

function sfxBrowser:isSoundEnded()
	return not isElement(self.m_Sound)
end

function sfxBrowser:playButton_Click(button, state)
	if button == "left" and state == "up" then
		self:playCurrent()
	end
end

function sfxBrowser:containerGrid_Click(button, state)
	if not (button == "left" and state == "up") then
		return
	end
	
	local selectedText = guiGridListGetItemText(self.m_GUI.containerGrid, guiGridListGetSelectedItem(self.m_GUI.containerGrid), 1)
	if selectedText == "" then
		return
	end
	
	-- List sound banks
	local containerData = self.ms_Data[selectedText]
	if not containerData then
		return
	end
	
	guiGridListClear(self.m_GUI.bankGrid)
	guiGridListClear(self.m_GUI.sfxGrid)
	for bankNum, bankData in ipairs(containerData) do
		local row = guiGridListAddRow(self.m_GUI.bankGrid)
		guiGridListSetItemText(self.m_GUI.bankGrid, row, 1, bankData.num, false, true)
		guiGridListSetItemText(self.m_GUI.bankGrid, row, 2, bankData.desc, false, false)
	end
	
	self.m_CurrentContainer = selectedText
	self:updateLuacode()
end

function sfxBrowser:bankGrid_Click(button, state)
	if not (button == "left" and state == "up") then
		return
	end
	
	local selectedRow = guiGridListGetSelectedItem(self.m_GUI.bankGrid) -- rowData? might be better
	if selectedRow == -1 then
		return
	end
	
	if not self.m_CurrentContainer then
		return
	end
	
	self.m_CurrentBank = selectedRow
	self:updateLuacode()
	
	-- List sound IDs
	guiGridListClear(self.m_GUI.sfxGrid)
	local numSounds = self.ms_Data[self.m_CurrentContainer][self.m_CurrentBank+1].num
	for i=0, numSounds-1 do
		local row = guiGridListAddRow(self.m_GUI.sfxGrid)
		guiGridListSetItemText(self.m_GUI.sfxGrid, row, 1, ("Sound %d"):format(i), false, false)
	end
end

function sfxBrowser:sfxGrid_Click(button, state)
	if not (button == "left" and state == "up") then
		return
	end
	
	local selectedRow = guiGridListGetSelectedItem(self.m_GUI.sfxGrid)
	if selectedRow == -1 then
		return
	end
	
	self.m_CurrentSFX = selectedRow
	self:updateLuacode()
end

function sfxBrowser:sfxGrid_DoubleClick(button, state)
	if not (button == "left" and state == "up") then
		return
	end
	
	local selectedRow = guiGridListGetSelectedItem(self.m_GUI.sfxGrid)
	if selectedRow == -1 then
		return
	end
	
	self.m_CurrentSFX = selectedRow
	self:playCurrent()
end

function sfxBrowser:closeButton_Click(button, state)
	if button == "left" and state == "up" then
		self:close()
		showCursor(false)
	end
end

function sfxBrowser:loopedCheck_Click(button, state)
	if button == "left" and state == "up" then
		self:updateLuacode()
	end
end


local browser
addCommandHandler("sfxbrowser",
	function(cmd)
		if not browser then
			browser = sfxBrowser:new()
		end
		if not browser:isOpen() then
			browser:open()
			showCursor(true)
		else
			browser:close()
			showCursor(false)
		end
	end, false, false
)
