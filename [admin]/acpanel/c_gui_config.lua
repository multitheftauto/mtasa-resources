--
-- Anti-Cheat Control Panel
--
-- c_gui_config.lua
--


function aServerConfigTab.Create ( tab )
	aServerConfigTab.Tab = tab

	xpos = 20
	ypos = 10

	local label1 = guiCreateLabel ( xpos, ypos, 200, 16, "Minimum allow client setting", false, tab )
	ypos = ypos + 20

	---------------------------------------------------------
	-- Radio buttons
	---------------------------------------------------------
	local xoffset = 0
	for _,info in ipairs(aServerConfigTab.radioButtons) do
		if xoffset > 400 then
			xoffset = 0
			ypos = ypos + 20
		end
		info.label = guiCreateLabel( xpos + xoffset + 20, ypos - 1, 250, 16, info.desc, false, tab )
		guiSetProperty ( info.label, "RiseOnClick", "False" )
		info.button = guiCreateRadioButton( xpos + xoffset, ypos, 16+70, 16, "", false, tab )
		guiLabelSetColor( info.label, unpack(info.color) )
		xoffset = xoffset + 250
	end
	ypos = ypos + 20

	---------------------------------------------------------
	-- Definition list
	---------------------------------------------------------
	local label1 = guiCreateLabel ( xpos, ypos, 200, 16, "Min client version:", false, tab )
	ypos = ypos + 20
	--aServerConfigTab.memoDefinition = guiCreateMemo ( xpos, ypos, 250, 40, "", false, tab )
	aServerConfigTab.memoDefinition = guiCreateEdit ( xpos, ypos, 250, 30, "", false, tab )
	ypos = ypos + 40

	ypos = ypos + 240


	---------------------------------------------------------
	-- acpanel version alert
	---------------------------------------------------------
	aServerConfigTab.acpanelVersionLabel = guiCreateLabel ( xpos+5, ypos, 400, 16, "NEW VERSION OF Anti Cheat Panel is available from:", false, tab )
	guiLabelSetColor( aServerConfigTab.acpanelVersionLabel, unpack(colorRed) )
	ypos = ypos + 20
	aServerConfigTab.acpanelUrlEdit = guiCreateEdit ( xpos, ypos, 550, 30, "", false, tab )

	guiSetVisible( aServerConfigTab.acpanelVersionLabel, false )
	guiSetVisible( aServerConfigTab.acpanelUrlEdit, false )


	aServerConfigTab.Refresh()

	-- EVENTS
	addEventHandler ( "onClientGUIClick", aServerConfigTab.Tab, aServerConfigTab.onClientGUIClick )
	addEventHandler ( "onClientGUIChanged", aServerConfigTab.memoDefinition, aServerConfigTab.onMemoDefinitionChanged )

end


function aServerConfigTab.onMemoDefinitionChanged(element)
	if bSaveMemoEdits then
		setPanelSetting( "minclientconfig.customText", guiGetText(aServerConfigTab.memoDefinition) )
	end
end


function aServerConfigTab.onClientGUIClick()
	local element = source

	local typeNew = aServerConfigTab.getTypeFromGui()
	local typeCurrent = getPanelSetting( "minclientconfig.type" )
	if typeNew ~= typeCurrent then
		setPanelSetting( "minclientconfig.type", typeNew )
		aServerConfigTab.Refresh()
	end

	if element ~= aServerConfigTab.memoDefinition then
		guiMoveToBack( aServerConfigTab.memoDefinition )
	end
end


function aServerConfigTab.getTypeFromGui()
	for _,info in ipairs(aServerConfigTab.radioButtons) do
		if guiRadioButtonGetSelected( info.button ) then
			return info.type
		end
	end
end


function aServerConfigTab.Refresh()
	local type = getPanelSetting( "minclientconfig.type" )


	local info = aServerConfigTab.getInfoForType("release")
	info.text = getPanelSetting( "lastFetchedReleaseVersion" )
	local info = aServerConfigTab.getInfoForType("latest")
	info.text = getPanelSetting( "lastFetchedLatestVersion" )

	local info = aServerConfigTab.getInfoForType(type)
	guiRadioButtonSetSelected( info.button, true )
	if info.custom then
		local customText = getPanelSetting( "minclientconfig.customText" )
		guiSetText( aServerConfigTab.memoDefinition, customText )
		guiEditSetReadOnly( aServerConfigTab.memoDefinition, false )
		guiSetAlpha ( aServerConfigTab.memoDefinition, 1 )
		bSaveMemoEdits = true
	else
		bSaveMemoEdits = false
		guiSetText( aServerConfigTab.memoDefinition, info.text )
		guiEditSetReadOnly( aServerConfigTab.memoDefinition, true )
		guiSetAlpha ( aServerConfigTab.memoDefinition, 0.75 )
	end

	-- ALERT ** VERY IMPORTANT NEWS **
	local acpanelVersion = getPanelSetting( "acpanelVersion" )
	local acpanelUrl = getPanelSetting( "acpanelUrl" )
	if acpanelVersion and acpanelUrl and acpanelVersion > _version then
		guiSetVisible( aServerConfigTab.acpanelVersionLabel, true )
		guiSetVisible( aServerConfigTab.acpanelUrlEdit, true )
		guiSetText( aServerConfigTab.acpanelUrlEdit, acpanelUrl )
	end
end
