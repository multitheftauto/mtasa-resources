local customKills = {}
local config = {
["lines"] = 5,
["startY"] = 0.35,
["textHeight"] = 16,
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
local killMessages = {}
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
	local i = 1
	if #killMessages ~= 0 and isElement (killMessages[i]["leftShadow"]) then
		while i ~= config.lines+1 do
			if killMessages[i] then
				destroyElement ( killMessages[i]["leftShadow"] )
				destroyElement ( killMessages[i]["left"] )
				destroyElement ( killMessages[i]["rightShadow"] )
				destroyElement ( killMessages[i]["right"] )
				destroyElement ( killMessages[i]["icon"] )
			end
			i = i + 1
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
	local i = 1
	while i ~= config.lines+1 do
		local gap = config.iconHeight - config.textHeight
		gap = gap/2
		local y = config.startY*screenY + (config.iconHeight*(i-1))
		y = y + gap
		killMessages[i] = {}
		killMessages[i]["y"] = y
		killMessages[i]["iconPath"] = ""
		killMessages[i]["leftShadow"] = guiCreateLabel ( 0, 0, 200,16,"", false )
		killMessages[i]["left"] = guiCreateLabel ( 0, 0, 200,16,"", false )
		killMessages[i]["rightShadow"] = guiCreateLabel ( 0,0,200,16,"", false )
		killMessages[i]["right"] = guiCreateLabel ( 0, 0,200,16, "", false )
		killMessages[i]["icon"] = guiCreateStaticImage ( 0,0,0,0,"icons/generic.png", false )
		guiLabelSetColor ( killMessages[i]["leftShadow"],0,0,0 )
		guiLabelSetColor ( killMessages[i]["rightShadow"],0,0,0 )
		i = i + 1
	end
	endTime = config.fadeTime + config.startFade
end

addEvent ("onClientPlayerKillMessage",true)
function onClientPlayerKillMessage ( killer,weapon,wr,wg,wb,kr,kg,kb,width,resource )
	if wasEventCancelled() then return end
	outputKillMessage ( source, wr,wg,wb,killer,kr,kg,kb,weapon,width,resource )
end
addEventHandler ("onClientPlayerKillMessage",getRootElement(),onClientPlayerKillMessage)

function outputKillMessage ( source, wr,wg,wb,killer,kr,kg,kb,weapon,width,resource )
	if not iconWidths[weapon] then 
		if type(weapon) ~= "string" then
			weapon = 999 
		end
	end
	local killerName
	local wastedName
	if not tonumber(wr) then wr = 255 end
	if not tonumber(wg) then wg = 255 end
	if not tonumber(wb) then wb = 255 end
	if not tonumber(kr) then kr = 255 end
	if not tonumber(kg) then kg = 255 end
	if not tonumber(kb) then kb = 255 end
	if ( source ) then
		if isElement ( source ) then
			if getElementType ( source ) == "player" then 
				wastedName = getPlayerName ( source )
			else 
			outputDebugString ( "outputKillMessage - Invalid 'wasted' player specified",0,0,0,100)
			return false end
		elseif type(source) == "string" then
			wastedName = source
		end
	else 
		outputDebugString ( "outputKillMessage - Invalid 'wasted' player specified",0,0,0,100)
	return false end
	if ( killer ) then
		if isElement ( killer ) then
			if getElementType ( killer ) == "player" then
				killerName = getPlayerName ( killer )
			else 
				outputDebugString ( "outputKillMessage - Invalid 'killer' player specified",0,0,0,100)
			return false end
		elseif type(killer) == "string" then
			killerName = killer
		else
			killerName = ""
		end
	else killerName = "" end
	---shift everything up
	shiftUpGUI()
	--create the new text

	if not killerName then
		killerName = ""
	end
	local iconWidth = iconWidths[weapon]
	local iconPath = icons[weapon]
	if tonumber(width) then iconWidth = width end
	if type(weapon) == "string" then iconPath = weapon end
	setLineMessage(config.lines,killerName,wastedName,kr,kg,kb,wr,wg,wb,iconPath,iconWidth,resource)
	fadeLine ( config.lines )	
end
---NEED TO ALLOW CUSTOM RESOURCE

function shiftUpGUI()
	local i = 1
	while i ~= (config.lines) do
		local newTextLeft = guiGetText ( killMessages[i+1]["left"], false )
		local newLeftR,newLeftG,newLeftB = guiLabelGetColor ( killMessages[i+1]["left"] )
		local newTextRight = guiGetText ( killMessages[i+1]["right"], false )
		local newRightR,newRightG,newRightB = guiLabelGetColor ( killMessages[i+1]["right"] )
		local iconPath = killMessages[i+1]["iconPath"]
		local iconWidth = guiGetSize ( killMessages[i+1]["icon"], false )
		local resource = killMessages[i+1]["resource"]
		setLineMessage ( i,newTextLeft,newTextRight,newLeftR,newLeftG,newLeftB,newRightR,newRightG,newRightB,iconPath,iconWidth,resource )
		---shift up the alpha too
		local tick = fadingLines[i+1]
		fadingLines[i] = tick
		fadingLines[i+1] = nil
		i = i + 1
	end	
end

function setLineMessage ( line, text1,text2,r1,g1,b1,r2,g2,b2,iconPath, iconWidth,resource )
	local left = killMessages[line]["left"]
	local right = killMessages[line]["right"]
	local leftShadow = killMessages[line]["leftShadow"]
	local rightShadow = killMessages[line]["rightShadow"]
	--Set the text
	guiSetText ( left,text1 )
	guiSetText ( leftShadow,text1 )
	guiSetText ( right,text2 )
	guiSetText ( rightShadow,text2 )
	--Set the colour
	guiLabelSetColor ( left, r1,g1,b1 )
	guiLabelSetColor ( right, r2,g2,b2 )
	--Set the position
	local leftX,rightX,iconX
	local startX = config.startX
	if startX < 1 and startX > -1 then --auto calculate whether its relative or absolute
		startX = screenX/startX --make it relative
	end
	if startX < 0 then
		startX = screenX + startX
	end
	local iconGap = 3 --in between text and icon
	local y = killMessages[line]["y"]
	local lengthRight = guiLabelGetTextExtent ( right )
	local lengthLeft = guiLabelGetTextExtent ( left )
	--Set right text pos
	if config.align == "left" then
		rightX = startX
	elseif config.align == "center" or config.align == "centre" then
		rightX = startX + (iconWidth/2)
	else
		rightX = startX - lengthRight
	end
	guiSetPosition ( right, rightX, y, false )
	guiSetPosition ( rightShadow, rightX + 1, y + 1, false )
	--Set the icon pos/size
	local icon = killMessages[line]["icon"]
	killMessages[line]["icon"] = guiStaticImageLoadImage ( icon, iconPath, resource )
	guiSetSize ( icon, iconWidth, 20, false )
	if config.align == "left" then
		iconX = rightX + iconGap
	elseif config.align == "center" or config.align == "centre" then
		iconX = startX - (iconWidth/2)
	else
		iconX = rightX - iconGap - iconWidth
	end
	guiSetPosition ( icon, iconX, y, false )
	killMessages[line]["iconPath"] = iconPath
	--Set the left text pos
	if config.align == "left" then
		leftX = iconX + iconGap
	elseif config.align == "center" or config.align == "centre" then
		iconX = iconX - iconGap - lengthLeft
	else
		leftX = iconX - iconGap - lengthLeft
	end
	guiSetPosition ( left, leftX, y, false )
	guiSetPosition ( leftShadow, leftX + 1, y + 1, false )
	--Set the alpha correctly
	setLineAlpha ( line, 1 )
end

mta_guiStaticImageLoadImage = guiStaticImageLoadImage
function guiStaticImageLoadImage ( icon, path, resourceName )
	if ( resourceName ) then
		local resource = getResourceFromName ( resourceName )
		if ( resource ) then
			destroyElement ( icon )
			icon = guiCreateStaticImage ( 0,0,0,0,path, false,false,resource )
		end
	else
		mta_guiStaticImageLoadImage ( icon, path )
	end
	return icon
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
			setLineMessage ( line, "","",0,0,0,0,0,0,"",0 )
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
	guiSetAlpha ( killMessages[line]["left"], alpha )
	guiSetAlpha ( killMessages[line]["right"], alpha )
	guiSetAlpha ( killMessages[line]["leftShadow"], alpha )
	guiSetAlpha ( killMessages[line]["rightShadow"], alpha )
	guiSetAlpha ( killMessages[line]["icon"], alpha )
end


-----------guiLabelGetColor
local mta_guiLabelSetColor = guiLabelSetColor
local storedColors = {}
function guiLabelSetColor ( element, red, green, blue )
	storedColors[element] = {}
	storedColors[element]["r"] = red
	storedColors[element]["g"] = green
	storedColors[element]["b"] = blue
	mta_guiLabelSetColor ( element,red,green,blue )
end

function guiLabelGetColor ( element )
	if storedColors[element] then
		local r = storedColors[element]["r"]
		local g = storedColors[element]["g"]
		local b = storedColors[element]["b"]
		return r,g,b
	else
		return 0,0,0
	end
end



--function setRightAligned ( element, x )