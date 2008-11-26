--[[
HOW TO USE:

---displayGUItextToAll---
This is mainly written to display information to all players, preferebly triggerd from a server script.
It can however be triggerd from a clientscript aswell.

CLIENT:
displayGUItextToAll(text theText, int red, int green, int blue)
Note: In order to make the message visible to all players, displayGUItextToAll must be triggerd on ALL clients.
I strongly recoment using the server method instead.

SERVER:
triggerClientEvent( element triggerFor, "displayGUItextAll", element sourceElement, text theText, int red, int green, int blue )

theText: the desired string of text
red: amount of red (0-255)
green: amount of green (0-255)
blue: amount of blue (0-255)


---displayGUItextToPlayer---
This function can be used to display various information to a specific player, aswell as all players.

CLIENT:
displayGUItextToPlayer(float x, float y, text theText, font theFont, int red, int green, int blue, visible timeVisible)

SERVER:
triggerClientEvent( element triggerFor, "displayGUItext", element sourceElement, float x, float y, text theText, font theFont, int red, int green, int blue, visible timeVisible )

x: the position over the X axis 
y: the position over the Y axis 
NOTE: the position must be relative! (0-1)
theText: the desired string of text
theFont: the desired font
red: amount of red (0-255)
green: amount of green (0-255)
blue: amount of blue (0-255)
timeVisible: the amount of time the text should be visible, in ms.

for more information about triggerClientEvent, please see the wiki.
]]

theTexts = {}
theShadow = {}
nT = 0
function displayGUItextToAll(text, r, g, b) --function name, along with the arguments
	alpha = 0.8 --the starting alpha
if not ( blinking ) then --if theres no blinking marker
	blinking = guiCreateLabel(0.9, 0.8, 0,0, "  _", true) --create one
	guiSetFont(blinking, "default-bold-small") --set font to match the rest
	guiSetSize(blinking, guiLabelGetTextExtent(blinking), guiLabelGetFontHeight(blinking), false) --set the size as big as it needs to be
	isVisible = true --tell the script its currently visible
	setTimer(flashBlink, 300, 0) --start blinking it
end
if ( scrolling ) then --if a text is currently scrolling
	killTimer(scrolling) --stop it
	scrolling = nil --make sure the element is really gone
	guiSetSize ( theShadow[nT], guiLabelGetTextExtent ( theTexts[nT] ), guiLabelGetFontHeight ( theTexts[nT] ), false ) --set the shadow size as big as it should be
	guiSetSize ( theTexts[nT], guiLabelGetTextExtent ( theTexts[nT] ), guiLabelGetFontHeight ( theTexts[nT] ), false ) --set the text size as big as it should be
end
	if isElement(theTexts[1]) then --if theres a text item
		local i = #theTexts --get the amount of text items
		while i > 0 do --start from the number of text items, count down to 0
			if i <= 0 then --safety check
				break --break the loop in case something's gone wrong.
			end
			local x, y = guiGetPosition(theTexts[i], false) --get the position of the current text item
			local x1, y1 = guiGetPosition(theShadow[i], false) --get the position of the current shadow item
			local fy = guiLabelGetFontHeight(theTexts[i]) --get the font height
			guiSetPosition(theShadow[i], x1, y1 - fy, false) --move the shadow one step up
			guiSetPosition(theTexts[i], x, y - fy, false) --move the text one step up
			guiSetAlpha(theTexts[i], alpha) --set the alpha
			guiSetAlpha(theShadow[i], alpha) --set the alpha
			alpha = alpha - 0.2 --make the alpha smaller on the next item
			i = i - 1 --count down
		end
	end
	if nT < 5 then --if theres less than 5 text items
		nT = nT + 1 --count up
	else --if there are 5 or more items
		destroyElement(theTexts[1]) --destroy the first item
		destroyElement(theShadow[1]) --destroy its shadow
		table.remove(theTexts, 1) --remove it from the table
		table.remove(theShadow, 1)
	end
	theShadow[nT] = guiCreateLabel(0.9, 0.8, 0, 0, text, true) --create a shadow
	theTexts[nT] = guiCreateLabel(0.9, 0.8, 0, 0, text, true) --create text
	guiSetFont(theShadow[nT], "default-bold-small") --set the font
	guiSetFont(theTexts[nT], "default-bold-small") --set the font
	guiLabelSetColor(theShadow[nT], 1, 1, 1) --set the shadow color (0,0,0 aint working with new theme.)
	guiLabelSetColor(theTexts[nT], r, g, b) --set the color of the text
	local x, y = guiGetPosition(theTexts[nT], false) --get the position
	local x1, y1 = guiGetPosition(theShadow[nT], false)
	local fx = guiLabelGetTextExtent(theTexts[nT]) --get the lenght of the text item
	local sX, sY = guiGetScreenSize() --get the screensize
	local size = ( x + fx ) - sX --calculate a new position for the text, so it wont go off screen
	local margin = 0.05 * sX --add a margin
	local move = size + margin --calculate the total move
	guiSetPosition(theTexts[nT], x - move, y, false) --set the final position
	guiSetPosition(theShadow[nT], (x1 + 2) - move, y1 + 2, false)
	guiMoveToBack(theTexts[nT])
	guiMoveToBack(theShadow[nT])
	guiSetPosition(blinking, x - move, y, false) --set the blinking marker at the same place
	
	guiSetSize(theTexts[nT], 0, 0, false) --set the size to 0 again (for scrolling)
	guiSetSize(theShadow[nT], 0, 0, false)
	scrollsize = 0
	scrolling = setTimer(startScroll, 100, 0) --set a timer to start scrolling
end
addEvent("displayGUItextAll", true) --add a event to make it triggable from a server script
addEventHandler("displayGUItextAll", getRootElement(), displayGUItextToAll) --add a handler for the event.

function startScroll () --scroll function
	playSoundFrontEnd(42) --play a sound to simulate a type-writer
	local x = guiLabelGetTextExtent(theTexts[nT]) --get the lenght of the text
	if scrollsize < x then --if scrollsize is smaller than the text lenght
		scrollsize = scrollsize + 10 --add 10 pixels
	else
		scrollsize = x --if scollsize is bigger than the text lenght, tell it to set scrollsize the same size as the text lenght (we dont want it bigger!)
		killTimer(scrolling) --kill the timer
		scrolling = nil --make sure the element is deleted
	end
	guiSetSize(theShadow[nT], scrollsize, guiLabelGetFontHeight ( theTexts[nT] ), false) --set the size
	guiSetSize(theTexts[nT], scrollsize, guiLabelGetFontHeight ( theTexts[nT] ), false)
	local x, y = guiGetPosition(theTexts[nT], false) --get current position
	guiSetPosition(blinking, x + scrollsize, y, false) --set the blinking marker so it follows the text
end

function flashBlink () --blinking marker function
	if isVisible == true then --if its currently visible
		guiSetVisible(blinking, false) --set it invisible
		isVisible = false --tell the script its hidden
	else --if its hidden
		guiSetVisible(blinking, true) --set it visible
		isVisible = true --tell the script its visible
	end
end


function displayGUItextToPlayer(x, y, text, font, r, g, b, visible) --function name, along with the arguments
if ( myTextTimer ~= nil ) then --if theres a timer
	killTimer (myTextTimer) --kill it!
	myTextTimer = nil --make sure the element is gone
end
if not ( theText ) then --if theres no text item
	theText = guiCreateLabel(x, y, 0, 0, text, true) --create one
	guiMoveToBack(theText) --move it to the back
else --if there is a text item
	guiSetText (theText, text) --change the text on the current one
	guiSetPosition(theText, x, y, true) --set the position
	guiMoveToBack(theText) --move it to the back
end
	guiSetVisible(theText, true) --set it visible
	guiSetFont(theText, font) --set the font
	guiSetSize ( theText, guiLabelGetTextExtent ( theText ), guiLabelGetFontHeight ( theText ) + 26, false ) --set the size as big as it needs to be
	guiLabelSetColor(theText, r, g, b) --set the color
	myTextTimer = setTimer(hideTheText, visible, 1) --set a timer as to when the text should disappear
end
addEvent("displayGUItext", true) --add a event so it can be accessable from a server script
addEventHandler("displayGUItext", getRootElement(), displayGUItextToPlayer) --add a handler for the event

function hideTheText() --hide the text
	myTextTimer = nil --make sure the element is deleted
	destroyElement(theText) --destroy the textitem
	theText = nil --make sure the element is deleted
end