local customKills = {}
local config = {
["lines"] = 5,
["startY"] = 0.35,
["textHeight"] = 16,
["iconPosOffY"] = -10,
["iconHeight"] = 20,
["iconSpacing"] = 4,
["defaultWeapon"] = 255,
["fadeTime"] = 5000,
["startFade"] = 15000,
["align"] = "right",
["startX"] = -10
}
local default = {
["lines"] = 5,
["startY"] = 0.25,
["textHeight"] = 16,
["iconPosOffY"] = -10,
["iconHeight"] = 20,
["iconSpacing"] = 4,
["defaultWeapon"] = 255,
["fadeTime"] = 5000,
["startFade"] = 15000,
["align"] = "right",
["startX"] = -10
}
local endTime
local screenX,screenY = guiGetScreenSize ()
local contentMessages = {}
local fadingLines = {}
---
local iconOrder = {}


function setupTextOnStart ( resource )
	if resource ~= getThisResource() then return end
	triggerServerEvent ( "onClientKillmessagesLoaded", getLocalPlayer() )
end
addEventHandler ( "onClientResourceStart", getRootElement(), setupTextOnStart )

addEvent ("doSetKillMessageStyle",true)
function setKillMessageStyle ( startX,startY,align,lines,fadeStart,fadeAnimTime )
	if ( not startX ) then startX = default.startX end
	if ( not startY ) then startY = default.startY end
	if ( not align ) then align = default.align end
	if ( not lines ) then lines = default.lines end
	if ( not fadeStart ) then fadeStart = default.startFade end
	if ( not fadeAnimTime ) then fadeAnimTime = default.fadeTime end
	config.startX = startX
	config.startY = startY
	config.align = align
	config.lines = lines
	config.startFade = fadeStart
	config.fadeTime = fadeAnimTime
	if #contentMessages ~= 0 then
		for i=1,config.lines do
			if contentMessages[i] then
				destroyLine ( i )
			end
		end
	end
	fadingLines = {}
	killMessages = {}
	if ( config.startY < 0 ) then
		config.startY = screenY - math.abs(config.startY*screenY) - (config.iconHeight*config.lines)
		config.startY = config.startY/screenY
	end
	createKillMessageGUI()
	return true
end
addEventHandler ( "doSetKillMessageStyle",getRootElement(),setKillMessageStyle)

function createKillMessageGUI()
	local gap = config.iconHeight - config.textHeight
	gap = gap/2
	for i=1,config.lines do
		local y = config.startY*screenY + (config.iconHeight*(i-1))
		y = y + gap
		contentMessages[i] = { dxText:create("",0,y) }
	end
	endTime = config.fadeTime + config.startFade
end

function shiftUpGUI()
	local i = 1
	for i=config.lines,2,-1 do
		local y = config.startY*screenY + (config.iconHeight*(i-1)) + (config.iconHeight - config.textHeight)/2
		local targetY = config.startY*screenY + (config.iconHeight*(i-2)) + (config.iconHeight - config.textHeight)/2
		if contentMessages[i] then
			for k,part in ipairs(contentMessages[i]) do
				local x,realY = getWidgetPosition(part)

				local diffY = realY - y
				setWidgetPosition(part,x,targetY + diffY)
			end
		end
	end
	for i=1,config.lines-1 do
		---shift up the alpha too
		local tick = fadingLines[i+1]
		fadingLines[i] = tick
		fadingLines[i+1] = nil
	end
end

addEvent ( "doOutputMessage", true )
function outputMessage ( message, r, g, b, font )
	if type(message) ~= "string" and type(message) ~= "table" then
		outputDebugString ( "outputMessage - Bad 'message' argument", 0, 112, 112, 112 )
		return false
	end
	if type(font) ~= "string" then
		font = "default"
	end
	r = tonumber(r) or 255
	g = tonumber(g) or 255
	b = tonumber(b) or 255
	---shift everything up
	shiftUpGUI()
	--Delete the first line
	destroyLine (1)
	table.remove ( contentMessages, 1 )
	if type(message) == "string" then
		message = {message}
	end
	local y = config.startY*screenY + (config.iconHeight*(config.lines-1)) + (config.iconHeight - config.textHeight)/2
	local startX = config.startX
	if startX < 1 and startX > -1 then --auto calculate whether its relative or absolute
		startX = screenX/startX --make it relative
	end
	if startX < 0 then
		startX = screenX + startX
	end

	for i,part in ipairs(message) do
		if type(part) == "table" and part[1] == "image" then
			if not part.resource and not part.resourceName then
				part.resource = sourceResource
			end
		end
	end

	drawLine ( message, startX, y, config.align, config.lines, r, g, b, font, 1 )
	fadeLine ( config.lines )
end
addEventHandler ( "doOutputMessage", getRootElement(), outputMessage )

function drawLine ( message, x,y, align, line, r, g, b, font, scale )
	--First draw it and work out the width
	local width = 0
	contentMessages[line] = {}
	for i,part in ipairs(message) do
		if type(part) == "string" then
			local text = dxText:create ( part, width, y, false )
			text:font ( font )
			text:scale ( scale )
			text:type("shadow",1)
			text:align"left"
			text:color ( r,g,b )
			table.insert ( contentMessages[line], text )
			width = width + text:extent()
		elseif part[1] == "icon" then
			local iconWidth = part.width or iconWidths[part.id or -1] or iconWidths[255]
			local iconHeight = part.height or config.iconHeight
			local image = dxImage:create ( icons[part.id or 0] or icons[255], width, y + (part.posOffY or config.iconPosOffY), iconWidth, iconHeight, false )
			image:color ( part.r or 255, part.g or 255, part.b or 255 )
			image:rotation ( part.rot or 0, part.rotOffX or 0, part.rotOffY or 0 )
			width = width + iconWidth
			table.insert ( contentMessages[line], image )
		elseif part[1] == "image" then
			if part.width and part.path then
				if part.resourceName then
					part.resource = getResourceFromName(tostring(part.resourceName)) or part.resource
				end
				local image = dxImage:create ( ":"..getResourceName(part.resource).."/"..part.path, width, y + (part.posOffY or config.iconPosOffY), part.width, part.height or config.iconHeight, false )
				image:color ( part.r or 255, part.g or 255, part.b or 255 )
				image:rotation ( part.rot or 0, part.rotOffX or 0, part.rotOffY or 0 )
				width = width + part.width
				table.insert ( contentMessages[line], image )
			end
		elseif part[1] == "color" or part[1] == "colour" then
			r = part.r or r
			g = part.g or g
			b = part.b or b
		elseif part[1] == "padding" then
			width = width + part.width or 0
		end
		contentMessages[line].scale = scale
	end
	--Now reposition everything properly
	if align == "center" or align == "centre" then
		x = x - width/2
	elseif align == "right" then
		x = x - width
	end
	for i,widget in ipairs(contentMessages[line]) do
		local wx,wy = getWidgetPosition ( widget )
		setWidgetPosition ( widget, x + wx, wy )
	end
	return true
end

function fadeLine ( line )
	setLineAlpha ( line, 1 )
	fadingLines[line] = getTickCount()
end
-----
addEventHandler ( "onClientRender",getRootElement(),
function()
	for line,originalTick in pairs(fadingLines) do
		local tickDifference = getTickCount() - originalTick
		if tickDifference > endTime then
			destroyLine ( line )
			setLineAlpha ( line, 1 )
			fadingLines[line] = nil
		elseif tickDifference >  config.startFade then
			local fadeTimeDifference = tickDifference - config.startFade
			--calculate the alpha
			local newAlpha = 1 - fadeTimeDifference/config.fadeTime
			--Set all the alphas
			setLineAlpha ( line, newAlpha )
		end
	end
end )

function setLineAlpha ( line, alpha )
	for i,part in ipairs(contentMessages[line]) do
		setWidgetAlpha ( part, alpha )
	end
end

function destroyLine ( line )
	for k,part in ipairs(contentMessages[line]) do
		destroyWidget(part)
	end
	contentMessages[line] = {}
end

function destroyWidget ( widget )
	if isElement(widget) then
		destroyElement ( widget )
	elseif type(widget) == "table" and widget.destroy then
		widget:destroy()
	end
end

function getWidgetPosition ( widget )
	if isElement(widget) then
		return guiGetPosition ( widget, false )
	elseif type(widget) == "table" and widget.position then
		return widget:position()
	end
end

function setWidgetPosition ( widget, x, y )
	if isElement(widget) then
		return guiSetPosition ( widget, x, y, false )
	elseif type(widget) == "table" and widget.position then
		return widget:position(x,y,false)
	end
end

function setWidgetAlpha ( widget, alpha )
	if isElement(widget) then
		guiSetAlpha ( widget, alpha )
	elseif type(widget) == "table" and widget.color then
		local r,g,b = widget:color()
		widget:color(r,g,b,alpha*255)
	end
end
