--this script does most of the work where a highlighter appears when you mouse over an icon
local textOffsetY = 2
local textOffsetX = 5
local resourceTextOffsetY = 37
local resourceTextOffsetX = 5
iconMouseOver = {}

function showHighlighter( source )
	if source == currentButton then return end
	if iconData[source] == nil then return end
	if currentButton ~= source then playSoundFrontEnd ( 42 ) currentButton = source end
	iconData[source]["mouseOver"]( source )
end

function hideHighlighter()
	if currentButton == false then return end
	isCurrentButtonElement = false
	setSelectedText ( 0, 0, "" )
	guiSetVisible ( selected, false )
	currentButton = false
	local resourceText = guiGetText ( selectedResourceText )
	if ( string.find( resourceText, "%)", -1) ) and ( string.find( resourceText, "%(", -29) ) then--this check should not be required, but just incase
		setSelectedResourceText ( string.sub ( resourceText, 1, -31 ) )
	end
end

function topMenuMouseOver ( source )
	isCurrentButtonElement = false
	local name = iconData[source]["name"]
	local iconX, iconY = guiGetPosition ( source, false )
	local textY = iconY + guiConfig.iconSize + textOffsetY
	setSelectedText ( iconX, textY, name, guiConfig.topMenuAlign )
	guiSetVisible ( selected, true )
	guiSetPosition ( selected, iconX, iconY, false )
	guiMoveToBack ( selected )
---------------------------------------------------------------------------------------------------
end

function elementIconsMouseOver ( source )
	isCurrentButtonElement = true
	local resourceText = guiGetText ( selectedResourceText )
	if ( not string.find( resourceText, "%)", -1) ) and ( not string.find( resourceText, "%(", -29) ) then--this check should not be required, but just incase
		setSelectedResourceText ( resourceText.." (Scroll to change definition)" )
	end
	local name = elementIcons[source]["name"]
	if elementIcons[source]["labelName"] ~= nil then name = elementIcons[source]["labelName"] end
	local iconX, iconY = guiGetPosition ( source, false )
	local textY = iconY - 20
	setSelectedText ( iconX, textY, name, guiConfig.elementIconsAlign )
	guiSetVisible ( selected, true )
	guiSetPosition ( selected, iconX, iconY, false )
	guiMoveToBack ( selected )
end

function setSelectedText ( x, y, text, align )
	guiSetText ( selectedText, text )
	guiSetText ( selectedShadow, text )
	--
	local textX
	local length = guiLabelGetTextExtent ( selectedText )
	if align == "left" then
		textX = x + 2
	elseif align == "right" then
		textX = x - length + guiConfig.iconSize
	else
		textX = x - ((length - guiConfig.iconSize)/2)
	end
	guiSetPosition ( selectedText, textX, y, false )
	guiSetPosition ( selectedShadow, textX  + 1, y + 1, false )
	guiSetSize ( selectedText, length, 16, false )
	guiSetSize ( selectedShadow, length, 16, false )
end

function setSelectedResourceText ( text )
	guiSetText ( selectedResourceText, text )
	guiSetText ( selectedResourceShadow, text )
	guiSetVisible ( selected, false )
	local textX
	local y = screenY - guiConfig.iconSize - resourceTextOffsetY
	local length = guiLabelGetTextExtent ( selectedResourceText )
	local align = guiConfig.elementIconsAlign
	if align == "left" then
		textX = resourceTextOffsetX
	elseif align == "right" then
		textX = screenX - resourceTextOffsetX - length
	else
		textX = (screenX/2) - (length/2)
	end
	guiSetPosition ( selectedResourceText, textX, y, false )
	guiSetPosition ( selectedResourceShadow, textX  + 1, y + 1, false )
	guiSetSize ( selectedResourceText, length, 16, false )
	guiSetSize ( selectedResourceShadow, length, 16, false )
	setSelectedText ( 0.5, 0.5, "" )
end
