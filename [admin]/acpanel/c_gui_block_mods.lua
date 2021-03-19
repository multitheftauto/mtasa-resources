--
-- Anti-Cheat Control Panel
--
-- c_gui_block_mods.lua
--


function aBlockModsTab.Create ( tab )
	aBlockModsTab.Tab = tab

	xpos = 20
	ypos = 10

	local label1 = guiCreateLabel ( xpos, ypos, 100, 16, "Img file blocking", false, tab )
	ypos = ypos + 20

	---------------------------------------------------------
	-- Radio buttons
	---------------------------------------------------------
	local xoffset = 0
	for _,info in ipairs(aBlockModsTab.radioButtons) do
		if xoffset > 200 then
			xoffset = 0
			ypos = ypos + 20
		end
		info.label = guiCreateLabel( xpos + xoffset + 20, ypos - 1, 110, 16, info.desc, false, tab )
		guiSetProperty ( info.label, "RiseOnClick", "False" )
		info.button = guiCreateRadioButton( xpos + xoffset, ypos, 16+70, 16, "", false, tab )

		guiLabelSetColor( info.label, unpack(info.color) )
		xoffset = xoffset + 130
	end
	ypos = ypos + 20

	---------------------------------------------------------
	-- Definition list
	---------------------------------------------------------
	local label1 = guiCreateLabel ( xpos, ypos, 200, 16, "File name matches (one per line)", false, tab )
	ypos = ypos + 20
	aBlockModsTab.memoDefinition = guiCreateMemo ( xpos, ypos, 250, 300, "", false, tab )
	ypos = ypos + 300


	---------------------------------------------------------
	-- Version warning
	---------------------------------------------------------
	ypos = ypos + 20
	aBlockModsTab.versionWarningLabel = guiCreateLabel ( xpos, ypos, 400, 16, "** acpanel MUST BE RUNNING for this to work **", false, tab )
	guiLabelSetColor( aBlockModsTab.versionWarningLabel, unpack(colorYellow) )
	guiSetVisible( aBlockModsTab.versionWarningLabel, false )
	ypos = ypos + 20


	ypos = ypos - 320
	xpos = xpos + 360

	---------------------------------------------------------
	-- Detections log
	---------------------------------------------------------
--[[
	local label2 = guiCreateLabel ( xpos, ypos, 100, 16, "Recent detections:", false, tab )
	ypos = ypos + 20
	local memo2 = guiCreateMemo ( xpos, ypos, 200, 300, "", false, tab )
	ypos = ypos + 300
	guiMemoSetReadOnly( memo2, true )
	guiSetAlpha( memo2, 0.75 )
--]]


	aBlockModsTab.Refresh()

	addEventHandler ( "onClientGUIClick", aBlockModsTab.Tab, aBlockModsTab.onClientGUIClick )
	addEventHandler ( "onClientGUIChanged", aBlockModsTab.memoDefinition, aBlockModsTab.onMemoDefinitionChanged )

end


function aBlockModsTab.onMemoDefinitionChanged(element)
	if bSaveMemoEdits then
		setPanelSetting( "blockmods.customText", guiGetText(aBlockModsTab.memoDefinition) )
	end
end


function aBlockModsTab.onClientGUIClick()
	local element = source

	local typeNew = aBlockModsTab.getTypeFromGui()
	local typeCurrent = getPanelSetting( "blockmods.type" )
	if typeNew ~= typeCurrent then
		setPanelSetting( "blockmods.type", typeNew )
		aBlockModsTab.Refresh()
	end

	if element ~= aBlockModsTab.memoDefinition then
		guiMoveToBack( aBlockModsTab.memoDefinition )
	end
end


function aBlockModsTab.getTypeFromGui()
	for _,info in ipairs(aBlockModsTab.radioButtons) do
		if guiRadioButtonGetSelected( info.button ) then
			return info.type
		end
	end
end


function aBlockModsTab.Refresh()
	local type = getPanelSetting( "blockmods.type" )

	if type == "none" then
		guiSetVisible( aBlockModsTab.versionWarningLabel, false )
	else
		guiSetVisible( aBlockModsTab.versionWarningLabel, true )
	end

	local info = aBlockModsTab.getInfoForType(type)
	guiRadioButtonSetSelected( info.button, true )
	if info.custom then
		local customText = getPanelSetting( "blockmods.customText" )
		guiSetText( aBlockModsTab.memoDefinition, customText )
		guiMemoSetReadOnly( aBlockModsTab.memoDefinition, false )
		guiSetAlpha ( aBlockModsTab.memoDefinition, 1 )
		bSaveMemoEdits = true
	else
		bSaveMemoEdits = false
		guiSetText( aBlockModsTab.memoDefinition, info.text )
		guiMemoSetReadOnly( aBlockModsTab.memoDefinition, true )
		guiSetAlpha ( aBlockModsTab.memoDefinition, 0.75 )
	end
end
