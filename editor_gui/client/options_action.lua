optionsActions = {}
optionsData = {}
function sx_getOptionData(var)
	return (optionsData[var] or false)
end
function optionsActions.enableSounds (value)
	enableSound = value
end

function optionsActions.enableBox(value)
	optionsData.enableBox = value
end

function optionsActions.enableXYZlines(value)
	optionsData.enableXYZlines = value
end

function optionsActions.enablePrecisionRotation(value)
	optionsData.enablePrecisionRotation = value
end

function optionsActions.enablePrecisionSnap(value)
	optionsData.enablePrecisionSnap = value
end

function optionsActions.precisionLevel(value)
	optionsData.precisionLevel = tonumber(value)
end

function optionsActions.precisionRotLevel(value)
	optionsData.precisionRotLevel = tonumber(value)
end

function optionsActions.elemScalingSnap(value)
	optionsData.elemScalingSnap = tonumber(value)
end

function optionsActions.enableColPatch(value)
	local success, isLoaded = editor_main.toggleColPatch(value)
	if success then
		optionsData.enableColPatch = value
	else
		-- Set checkbox state to loaded state
		optionsData.enableColPatch = isLoaded
		guiCheckBoxSetSelected(dialog.enableColPatch.GUI.checkbox, isLoaded)
		-- Save settings again
		dumpSettings()
	end
end

function optionsActions.enableRotPatch(value)
	optionsData.enableRotPatch = value
end

function optionsActions.smoothCamMove (value)
	local loaded = 	freecam.setFreecamOption ( "smoothMovement", value )
	if ( loaded ) then
		setFreecamSpeeds()
	else
		addEventHandler ( "onClientResourceStart", root, waitForFreecam )
	end
end

function waitForFreecam(resource)
	if resource ~= getResourceFromName("freecam") then return end
	freecam.setFreecamOption ( "smoothMovement", dialog.smoothCamMove:getValue() )
	setFreecamSpeeds()
	removeEventHandler ( "onClientResourceStart", root, waitForFreecam )
end

function setFreecamSpeeds()
	local freecamRes = getResourceFromName("freecam")

	freecam.setFreecamOption ( "invertMouseLook", dialog.invertMouseLook:getValue() )
	freecam.setFreecamOption ( "normalMaxSpeed", dialog.normalMove:getValue() )
	freecam.setFreecamOption ( "fastMaxSpeed", dialog.fastMove:getValue() )
	freecam.setFreecamOption ( "slowMaxSpeed", dialog.slowMove:getValue() )
	freecam.setFreecamOption ( "mouseSensitivity", dialog.mouseSensitivity:getValue() )
	freecam.setFreecamOption ( "fov", dialog.fov:getValue() )
end

---This part decides whether gui should be refreshed or not
local iconSize,topmenuAlign,bottommenuAlign
local doesGUINeedRefreshing = false
function dumpGUISettings()
	doesGUINeedRefreshing = false
	iconSize = dialog.iconSize:getRow()
	topmenuAlign = dialog.topAlign:getRow()
	bottommenuAlign = dialog.bottomAlign:getRow()
end

local iconSizes = { small = 32, medium = 48, large = 64 }
function optionsActions.iconSize (value)
	guiConfig.iconSize = iconSizes[value]
	if value ~= iconSize then
		doesGUINeedRefreshing = true
	end
end

function optionsActions.topAlign (value)
	guiConfig.topMenuAlign = value
	if value ~= topmenuAlign then
		doesGUINeedRefreshing = true
	end
end

function optionsActions.bottomAlign (value)
	guiConfig.elementIconsAlign = value
	if value ~= bottommenuAlign then
		doesGUINeedRefreshing = true
	end
end

function updateGUI()
	if doesGUINeedRefreshing then
		destroyAllIconGUI()
		createGUILayout()
		refreshElementIcons()
		nextEDF()
	end
end
   -- void setRotateSpeeds(num slow, num medium, num fast)
      -- void setMoveSpeeds(num slow, num medium, num fast)
	     -- void setRotateSpeeds(num slow, num medium, num fast)
---Movement action
 -- move_cursor
   -- num num num getRotateSpeeds()
	-- Command executed! Results: 0.25 [number], 2 [number], 10 [number]
 -- move_freecam
   -- num num num getRotateSpeeds()
	-- Command executed! Results: 1 [number], 8 [number], 40 [number]
 -- move_keyboard
   -- num num num getMoveSpeeds()
	-- Command executed! Results: 0.025 [number], 0.25 [number], 2 [number]
   -- num num num getRotateSpeeds()
	-- Command executed! Results: 0.25 [number], 2 [number], 10 [number]


function optionsActions.normalElemMove (value)
	local slow, normal, fast = move_keyboard.getMoveSpeeds ()
	if getResourceFromName("move_keyboard") then
		setEditorMoveSpeeds()
	else
		addEventHandler ( "onClientResourceStart", root, waitForResources )
	end
end

local res1,res2,res3
function waitForResources(resource)
	if getResourceName(resource) == "move_keyboard" then
		res1 = true
	elseif getResourceName(resource) == "move_cursor" then
		res2 = true
	elseif getResourceName(resource) == "move_freecam" then
		res3 = true
	end
	if ( res1 ) and ( res2 ) and ( res3 ) then
		setEditorMoveSpeeds()
	end
end

function setEditorMoveSpeeds()
	local kbRes = getResourceFromName("move_keyboard")
	local cRes = getResourceFromName("move_cursor")
	local fRes = getResourceFromName("move_freecam")

	move_keyboard.setMoveSpeeds ( dialog.slowElemMove:getValue(), dialog.normalElemMove:getValue(), dialog.fastElemMove:getValue())
	--
	move_keyboard.setRotateSpeeds ( dialog.slowElemRotate:getValue(), dialog.normalElemRotate:getValue(), dialog.fastElemRotate:getValue() )
	move_cursor.setRotateSpeeds ( dialog.slowElemRotate:getValue(), dialog.normalElemRotate:getValue(), dialog.fastElemRotate:getValue() )
	move_freecam.setRotateSpeeds ( dialog.slowElemRotate:getValue(), dialog.normalElemRotate:getValue(), dialog.fastElemRotate:getValue() )

	move_keyboard.setScaleIncrement ( dialog.elemScaling:getValue() )

	move_keyboard.toggleAxesLock ( dialog.lockToAxes:getValue() )
end

function optionsActions.enableDumpSave(value)
	triggerServerEvent("dumpSaveSettings", root, value, dialog.dumpSaveInterval:getValue())
end
