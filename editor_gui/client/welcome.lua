local welcomeWindow
local proceedToTutorial,skipTutorial
local editorRes = getResourceFromName"editor_main"
local welcomeText = [[Welcome to the MTA:SA Map Editor.  This is your first time using the editor, so you are able to enter tutorial mode which will teach you the basics of using the editor.

If you want to skip the tutorial, press the 'Skip Tutorial' button.  Otherwise, press the 'Proceed' button.]]
local disclaimerText = [[This map editor is still a work in progress and is not fully functional yet.

If you want to try it as a preview, press 'OK'. Otherwise, please press Escape and disconnect now.]]

function disclaimer()
	editor_main.setMode (2)
	guiSetInputEnabled(true)
	disclaimerWindow = guiCreateWindow ( screenX/2 - 300, screenY/2 - 150, 600, 300, "Disclaimer", false )
	local label = guiCreateLabel ( 13,25,585,200,disclaimerText,false,disclaimerWindow)
	guiLabelSetVerticalAlign ( label, "center" )
	guiLabelSetHorizontalAlign ( label, "center", true )
	local ok = guiCreateButton ( 200,215, 200,46,"OK",false,disclaimerWindow )
	addEventHandler ( "onClientGUIClick",ok,removeDisclaimer,false )
	addEventHandler ( "onClientGUIClick",ok,welcomeUser,false )
end

function removeDisclaimer()
	destroyElement(disclaimerWindow)
	guiSetInputEnabled ( false )
end

function welcomeUser()
	local welcome = dialog.tutorialOnStart:getValue()
	if welcome then -- its a new user!
		call(editorRes,"setMode",2)
		guiSetInputEnabled(true)
		tutorialBlock = ""
		welcomeWindow = guiCreateWindow ( screenX/2 - 300, screenY/2 - 150, 600, 300, "Welcome to the Map Editor!", false )
		--
		local label = guiCreateLabel ( 13,25,585,200,welcomeText,false,welcomeWindow)
		guiLabelSetVerticalAlign ( label, "center" )
		guiLabelSetHorizontalAlign ( label, "center", true )
		local proceed = guiCreateButton ( 83,215, 180,46,"Proceed",false,welcomeWindow )
		local skip = guiCreateButton ( 318,215, 180,46,"Skip Tutorial",false,welcomeWindow )
		addEventHandler ( "onClientGUIClick",proceed,proceedToTutorial,false )
		addEventHandler ( "onClientGUIClick",skip,skipTutorial,false )
	end
end

function proceedToTutorial()
	editor_main.setMode(1)
	destroyElement ( welcomeWindow )
	guiSetInputEnabled ( false )
	startTutorial()
	addEventHandler ( "onClientRender", root, drawRectangle )
	addEventHandler ( "onClientRender", root, drawText )
	addEventHandler ( "onClientRender", root, drawGlow )
end

function skipTutorial()
	dialog.tutorialOnStart:setValue(false)
	dumpSettings()
	xmlSaveFile ( settingsXML )
	editor_main.setMode (1)
	tutorialBlock = nil
	destroyElement ( welcomeWindow )
	guiSetInputEnabled ( false )
end
