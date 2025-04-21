

function updateTooltipPosition(_,_, x, y)
	guiSetPosition(label, x + 8, y + 10, false)
	guiBringToFront(label)
end


function changeNosGaugePosition(_, btnState, x, y)
	if btnState == "down" then
		g_Settings.GaugePosition[1] = x - 50
		g_Settings.GaugePosition[2] = y - 50
	end
	if isEditingPosition then
		isEditingPosition = false
		showCursor(false)
		guiSetVisible(label, false)
		removeEventHandler("onClientCursorMove", g_Root, updateTooltipPosition)
		removeEventHandler("onClientClick", g_Root, changeNosGaugePosition)
		saveSettingsToFile()
		return;
	end	
end


function saveSettingsToFile()
	local xml = xmlCreateFile("nos_settings.xml", "settings")
	if not xml then return false end

	local gaugeNode = xmlCreateChild(xml, "gauge")
	xmlNodeSetAttribute(gaugeNode, "display", tostring(g_Settings.DisplayGauge))
	xmlNodeSetAttribute(gaugeNode, "posX", g_Settings.GaugePosition[1])
	xmlNodeSetAttribute(gaugeNode, "posY", g_Settings.GaugePosition[2])
	
	local styleNode = xmlCreateChild(xml, "behavior")
	xmlNodeSetAttribute(styleNode, "sustain", tostring(g_Settings.SustainOnPickup))
	xmlNodeSetAttribute(styleNode, "control", g_Settings.ControlStyle or "normal")
	
	local ret = xmlSaveFile(xml)
	xmlUnloadFile(xml)
	return ret
end


function loadSettingsFromFile()
	local xml = xmlLoadFile("nos_settings.xml")
	if not xml then return false end

	local gaugeNode = xmlFindChild(xml, "gauge", 0)
	g_Settings.DisplayGauge = (xmlNodeGetAttribute(gaugeNode, "display") == "true")
	g_Settings.GaugePosition[1] = xmlNodeGetAttribute(gaugeNode, "posX")
	g_Settings.GaugePosition[2] = xmlNodeGetAttribute(gaugeNode, "posY")
	
	local styleNode = xmlFindChild(xml, "behavior", 0)
	g_Settings.SustainOnPickup = (xmlNodeGetAttribute(styleNode, "sustain") == "true")
	g_Settings.ControlStyle = xmlNodeGetAttribute(styleNode, "control") or "normal"
			
	xmlUnloadFile(xml)
	return true
end


function letMePositionGauge()
	if not isEditingPosition then
		isEditingPosition = true
		showCursor(true)
		local x, y = getCursorPosition()
		x, y = x * g_ScreenSize[1], y * g_ScreenSize[2]
		guiSetPosition(label, x, y, false)
		guiSetVisible(label, true)
		addEventHandler("onClientCursorMove", g_Root, updateTooltipPosition)
		addEventHandler("onClientClick", g_Root, changeNosGaugePosition)
	end
end
addCommandHandler("move_nosgauge", letMePositionGauge)


-- Command to set the client's NOS control style
function consoleSetNosFiringStyle(commandName, nosControl)
	local settingName = nosControl
	--if commandName == "nos" and nosControl == "normal" then
	--	nosControl = "hybrid"
	--end

	if nosControl ~= "hybrid" and nosControl ~= "nfs" and nosControl ~= "normal" then
		if commandName == "nos" then
			outputGuiPopup("Syntax: /nos [normal|nfs|hybrid]")
		else
			outputGuiPopup("Syntax: /noscontrol [normal|nfs|hybrid]")
		end
		return
	end
	if g_Settings.ControlStyle ~= nosControl then
		g_Settings.ControlStyle = nosControl
		if saveSettingsToFile() then
			outputGuiPopup("Your NOS control style has been set to '" .. tostring(settingName) .. "'")
		end
	end
end
addCommandHandler("noscontrol", consoleSetNosFiringStyle)
addCommandHandler("nos", consoleSetNosFiringStyle)


-- Command to set the NOS gauge visibility on/off
function consoleSetGaugeVisibility(commandName, visibility)
	if visibility ~= "on" and visibility ~= "off" then
		outputGuiPopup("Syntax: /nosgauge [on|off]")
		return
	end
	if visibility == "on" and not g_Settings.DisplayGauge then
		g_Settings.DisplayGauge = true
	elseif g_Settings.DisplayGauge then
		g_Settings.DisplayGauge = false
	else
		return
	end

	if saveSettingsToFile() then
		local text = "NOS gauge is now "
		if g_Settings.DisplayGauge then
			text = text .. "visible."
		else
			text = text .. "hidden."
		end
		outputGuiPopup(text)
	end
	
end
addCommandHandler("nosgauge", consoleSetGaugeVisibility)


-- Command to set the NOS sustain behavior
function consoleSetNosSustainBehavior(commandName, arg)
	if arg ~= "on" and arg ~= "off" then
		outputGuiPopup("Syntax: /nossustain [on|off]")
		return
	end
	if arg == "on" and not g_Settings.SustainOnPickup then
		g_Settings.SustainOnPickup = true
	elseif g_Settings.SustainOnPickup then
		g_Settings.SustainOnPickup = false
	else
		return
	end
	
	if saveSettingsToFile() then
		outputGuiPopup("NOS sustain behavior is now " .. arg)
	end
	
end
addCommandHandler("nossustain", consoleSetNosSustainBehavior)



function maybeDisplaySpecialMessage()
	local xml = xmlLoadFile("nos_cookie.xml")
	if not xml then
		xml = xmlCreateFile("nos_cookie.xml", "settings")
	end
	if not xml then return false end

	local node = xmlFindChild(xml, "message1", 0)
	if not node then
		node = xmlCreateChild(xml, "message1")
	end
	local counter = xmlNodeGetAttribute(node, "counter")
	counter = tonumber(counter or 0) + 1
	xmlNodeSetAttribute(node, "counter", tostring(counter))

	xmlSaveFile(xml)

	-- Display custom message on 1st, 2nd and 6th connect
	if counter==1 then
		outputChatBox ( "** Note NOS has changed a little bit **" )
	end
	if counter==2 then
		outputChatBox ( "** Just incase you missed this message last time **" )
	end
	if counter==6 then
		outputChatBox ( "** Final reminder **" )
	end

	if counter==1 or counter==2 or counter==6 then
		outputChatBox ( "If you want normal nos type: /nos normal" )
		outputChatBox ( "If you want NFS style nos type: /nos nfs" )
	end

	xmlUnloadFile(xml)
end
maybeDisplaySpecialMessage()
