local welcomeWindow
local proceedToTutorial,skipTutorial
local editorRes = getResourceFromName"editor_main"

function disclaimer()
	editor_main.setMode (2)
	guiSetInputEnabled(true)
	disclaimerWindow = guiCreateWindow ( screenX/2 - 300, screenY/2 - 150, 600, 300, exports.editor_lang:_("WELCOME_DISCLAIMER"), false )
	local label = guiCreateLabel ( 13,25,585,200,exports.editorlang:_("WELCOME_DISCLAIMER_TEXT"),false,disclaimerWindow)
	guiLabelSetVerticalAlign ( label, "center" )
	guiLabelSetHorizontalAlign ( label, "center", true )
	local ok = guiCreateButton ( 200,215, 200,46,exports.editor_lang:_("OK"),false,disclaimerWindow )
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
		welcomeWindow = guiCreateWindow ( screenX/2 - 300, screenY/2 - 150, 600, 300, exports.editor_lang:_("WELCOME_TITLE"), false )
		--
		local label = guiCreateLabel ( 13,25,585,200,exports.editor_lang:_("WELCOME_MAP_EDITOR_TEXT"),false,welcomeWindow)
		guiLabelSetVerticalAlign ( label, "center" )
		guiLabelSetHorizontalAlign ( label, "center", true )
		local proceed = guiCreateButton ( 83,215, 180,46,exports.editor_lang:_("PROCEED"),false,welcomeWindow )
		local skip = guiCreateButton ( 318,215, 180,46,exports.editor_lang:_("SKIP_TUTORIAL"),false,welcomeWindow )
		addEventHandler ( "onClientGUIClick",proceed,proceedToTutorial,false )
		addEventHandler ( "onClientGUIClick",skip,skipTutorial,false )
	end
end

function proceedToTutorial()
	editor_main.setMode(1)
	destroyElement ( welcomeWindow )
	guiSetInputEnabled ( false )
	startTutorial()
	addEventHandler ( "onClientRender", getRootElement(), drawRectangle )
	addEventHandler ( "onClientRender", getRootElement(), drawText )
	addEventHandler ( "onClientRender", getRootElement(), drawGlow )
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
