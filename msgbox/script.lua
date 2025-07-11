--[[-----------DOCUMENTATION---------------
WARNING:
This resource is deprecated as the new 'dialogs' resource replaces it.

SYNTAX:
guibutton,guibutton,guibutton = guiShowMessageBox ( string message, string boxType, string title [, string button1, string button2, stringbutton3] )
REQUIRED ARGUMENTS
* message - The message you want in the message box
* boxType - Either "warning","question","error","info".  Displays different icons accordingly
OPTIONAL ARGUMENTS
guiShowMessageBox allows for up to 3 buttons in the message box
* forceShowing - Ensures that nothing else but the message box can be clicked, besides gui elements created afterwards.
* button1 - A string of the first button that appears
* button2 - A string of the second button that appears
* button3 - A string of the third button that appears
Not specifying forceShowing will default to false.
Not specifying all buttons will only create that many buttons.  For example, specifying 2 buttons will only display 2 buttons.
Not specifying any buttons at all will default to one "OK" button.
All buttons hide the message box by default


RETURNS:
Returns 3 gui elements of the each button the gui window.  If these dont exist nil is returned instead.  You can attach these to a
onClientGUIClick event to do whatever you want.
--------------------------------------------------------]]

local validTypes = { ["warning"]=true, ["question"]=true, ["error"]=true, ["info"]=true }
local screenX, screenY = guiGetScreenSize()
local guiAttached = {}
---Msg box position/size config
local msgBox = {}
msgBox.sizeX = 280
msgBox.sizeY = 135
---

function guiShowMessageBox ( message, boxType, title, forceShowing, button1, button2, button3 )
	local aMessage = {}
	local buttons = { button1,button2,button3 }
	--add checks to ensure everything is valid
	if type(message) ~= "string" then
		outputDebugString ( "guiShowMessageBox - Invalid 'message' specified.", 0 )
		return false
	end
	if not validTypes[boxType] then
		outputDebugString ( "guiShowMessageBox - Invalid 'type' specified.", 0 )
		return false
	end
	if type(title) ~= "string"  then
		outputDebugString ( "guiShowMessageBox - Invalid 'title' specified.", 0 )
		return false
	end
	---work out the number of buttons
	local buttonCount = 0
	while type(buttons[buttonCount+1]) == "string" do
		buttonCount = buttonCount + 1
	end
	if buttonCount == 0 then
		button1 = "OK"
		buttonCount = 1
	end
	local cover
	if ( forceShowing ) then
		cover = guiCreateButton ( 0, 0, 1, 1, "", true )
		guiSetAlpha ( cover, 0 )
		addEventHandler ( "onClientGUIClick", cover, bringMsgBoxToFront )
	end

	local formPosX = screenX / 2 - msgBox.sizeX/2
	local formPosY = screenY / 2 - msgBox.sizeY/2
	aMessage.Form	= guiCreateWindow ( formPosX,formPosY, msgBox.sizeX, msgBox.sizeY, title, false )
	guiWindowSetSizable ( aMessage.Form, false )
	aMessage.Image	= guiCreateStaticImage ( 15, 28, 42, 42, "images/"..boxType..".png", false, aMessage.Form )
	aMessage.Label	= guiCreateLabel ( 76, 35, 190, 65, message, false, aMessage.Form )
	guiLabelSetHorizontalAlign ( aMessage.Label,"left",true)
	--create gui buttons
	--130
	local guiButton1, guiButton2, guiButton3
	if buttonCount == 1 then
		guiButton1 = guiCreateButton ( 99, 104, 84, 23, button1, false, aMessage.Form )
		addEventHandler ( "onClientGUIClick", guiButton1, aMessageBoxClick )
		guiAttached[guiButton1] = {}
		guiAttached[guiButton1].parent = aMessage.Form
		guiAttached[guiButton1].forcedButton = cover
	elseif buttonCount == 2 then
		guiButton1 = guiCreateButton ( 48.5, 104, 84, 23, button1, false, aMessage.Form )
		guiButton2 = guiCreateButton ( 149.5, 104, 84, 23, button2, false, aMessage.Form )
		addEventHandler ( "onClientGUIClick", guiButton1, aMessageBoxClick )
		addEventHandler ( "onClientGUIClick", guiButton2, aMessageBoxClick )
		guiAttached[guiButton1] = {}
		guiAttached[guiButton2] = {}
		guiAttached[guiButton1].parent = aMessage.Form
		guiAttached[guiButton2].parent = aMessage.Form
		guiAttached[guiButton1].forcedButton = cover
		guiAttached[guiButton2].forcedButton = cover
	elseif buttonCount == 3 then
		guiButton1 = guiCreateButton ( 10, 104, 84, 23, button1, false, aMessage.Form )
		guiButton2 = guiCreateButton ( 100, 104, 84, 23, button2, false, aMessage.Form )
		guiButton3 = guiCreateButton ( 190, 104, 84, 23, button3, false, aMessage.Form )
		addEventHandler ( "onClientGUIClick", guiButton1, aMessageBoxClick )
		addEventHandler ( "onClientGUIClick", guiButton2, aMessageBoxClick )
		addEventHandler ( "onClientGUIClick", guiButton3, aMessageBoxClick )
		guiAttached[guiButton1] = {}
		guiAttached[guiButton2] = {}
		guiAttached[guiButton3] = {}
		guiAttached[guiButton1].parent = aMessage.Form
		guiAttached[guiButton2].parent = aMessage.Form
		guiAttached[guiButton3].parent = aMessage.Form
		guiAttached[guiButton1].forcedButton = cover
		guiAttached[guiButton2].forcedButton = cover
		guiAttached[guiButton3].forcedButton = cover
	end
	--260
	--
	if ( forceShowing ) then
		guiAttached[cover] = aMessage.Form
	end

	outputDebugString("This resource is deprecated as the new 'dialogs' resource replaces it.", 2)

	return guiButton1, guiButton2, guiButton3
end

function aMessageBoxClick ()
	if source ~= this then return end
	guiSetVisible ( guiAttached[source].parent, false )
	destroyElement ( guiAttached[source].parent )
	local forcedButton = guiAttached[source].forcedButton
	if ( forcedButton ) then
		guiSetVisible ( forcedButton, false )
		destroyElement ( forcedButton )
		guiAttached[forcedButton] = nil
	end
	guiAttached[source] = nil
end

function bringMsgBoxToFront()
	guiBringToFront ( guiAttached[source] )
end
