local guiCreateLabel = guiCreateMinimalLabel
local tabpanel
dialog = {}
interiors = {}
interiorsNames = {}

function createOptionsDialog()
	dialog.window		=	guiCreateWindow ( screenX/2 - 320, screenY/2 - 180, 640, 360, "OPTIONS", false )
	guiWindowSetSizable ( dialog.window, false )
	guiSetVisible(dialog.window, false )

	tabpanel = guiCreateTabPanel ( 0.02388, 0.09444, 0.9582, 0.81389, true, dialog.window )
	dialog.generalTab = guiCreateTab("General",tabpanel)
	dialog.cameraTab = guiCreateTab("Camera",tabpanel)
	dialog.movementTab = guiCreateTab("Movement",tabpanel)

	dialog.ok = guiCreateButton ( 0.5, 0.919444, 0.22857142, 0.05555555, "OK", true, dialog.window )
	dialog.cancel = guiCreateButton ( 0.780357142, 0.919444, 0.22857142, 0.05555555, "Cancel", true, dialog.window )
	dialog.restoreDefaults = guiCreateButton ( 0.02, 0.919444, 0.22857142, 0.05555555, "Restore defaults", true, dialog.window )

	--create general settings
	dialog.enableSounds = editingControl.boolean:create{["x"]=0.02,["y"]=0.02,["width"]=1,["height"]=0.1,["relative"]=true,["parent"]=dialog.generalTab,["label"]="Enable Sounds"}
	guiCreateLabel ( 0.02, 0.14, 1, 0.1, "Icon size:", true, dialog.generalTab )
	guiCreateLabel ( 0.02, 0.34, 1, 0.1, "Control panel alignment:", true, dialog.generalTab )
	guiCreateLabel ( 0.02, 0.54, 1, 0.1, "Element creation panel alignment:", true, dialog.generalTab )

	dialog.iconSize = editingControl.dropdown:create{["x"]=0.02,["y"]=0.2,["width"]=0.30,["height"]=0.07,["dropWidth"]=0.30,["dropHeight"]=0.35,["relative"]=true,["parent"]=dialog.generalTab,["rows"]={"small","medium","large"}}
	dialog.topAlign = editingControl.dropdown:create{["x"]=0.02,["y"]=0.4,["width"]=0.30,["height"]=0.07,["dropWidth"]=0.30,["dropHeight"]=0.35,["relative"]=true,["parent"]=dialog.generalTab,["rows"]={"left","right","center"}}
	dialog.bottomAlign = editingControl.dropdown:create{["x"]=0.02,["y"]=0.6,["width"]=0.30,["height"]=0.07,["dropWidth"]=0.30,["dropHeight"]=0.35,["relative"]=true,["parent"]=dialog.generalTab,["rows"]={"left","right","center"}}

	dialog.tutorialOnStart = editingControl.boolean:create{["x"]=0.02,["y"]=0.8,["width"]=1,["height"]=0.1,["relative"]=true,["parent"]=dialog.generalTab,["label"]="Query for tutorial on start"}

	---------------------------------
	dialog.enableBox = editingControl.boolean:create{["x"]=0.60,["y"]=0.02,["width"]=1,["height"]=0.1,["relative"]=true,["parent"]=dialog.generalTab,["label"]="Enable Bounding Box"}
	dialog.enableXYZlines = editingControl.boolean:create{["x"]=0.60,["y"]=0.12,["width"]=1,["height"]=0.1,["relative"]=true,["parent"]=dialog.generalTab,["label"]="Enable XYZ Lines"}
	---------------------------------
	dialog.enablePrecisionSnap = editingControl.boolean:create{["x"]=0.60,["y"]=0.22,["width"]=1,["height"]=0.1,["relative"]=true,["parent"]=dialog.generalTab,["label"]="Enable Snap - Precise Position"}
	guiCreateLabel ( 0.47, 0.34, 70, 17, "Position Snap Level:", true, dialog.generalTab )
	dialog.precisionLevel = editingControl.dropdown:create{["x"]=0.68,["y"]=0.34,["width"]=0.3,["height"]=0.07,["dropWidth"]=0.30,["dropHeight"]=0.55,["relative"]=true,["rows"]={"10","5","2","1","0.1","0.01","0.001","0.0001"},["parent"]=dialog.generalTab}
	guiCreateLabel ( 0.47, 0.44, 70, 17, "Rotation Snap Level:", true, dialog.generalTab )
	dialog.precisionRotLevel = editingControl.dropdown:create{["x"]=0.68,["y"]=0.44,["width"]=0.3,["height"]=0.07,["dropWidth"]=0.30,["dropHeight"]=0.55,["relative"]=true,["rows"]={"180","90","45","30","20","10","5","1"},["parent"]=dialog.generalTab}
	dialog.enablePrecisionRotation = editingControl.boolean:create{["x"]=0.60,["y"]=0.52,["width"]=1,["height"]=0.1,["relative"]=true,["parent"]=dialog.generalTab,["label"]="Enable Snap - Precise Rotation"}
	guiCreateLabel ( 0.47, 0.64, 70, 17, "Scaling Snap Level:", true, dialog.generalTab )
	dialog.elemScalingSnap = editingControl.dropdown:create{["x"]=0.68,["y"]=0.64,["width"]=0.3,["height"]=0.07,["dropWidth"]=0.30,["dropHeight"]=0.55,["relative"]=true,["rows"]={"1","0.1","0.01","0.001","0.0001"},["parent"]=dialog.generalTab}
	---------------------------------
	dialog.enableColPatch = editingControl.boolean:create{["x"]=0.60,["y"]=0.72,["width"]=1,["height"]=0.1,["relative"]=true,["parent"]=dialog.generalTab,["label"]="Enable collision patches"}
	dialog.enableRotPatch = editingControl.boolean:create{["x"]=0.60,["y"]=0.82,["width"]=1,["height"]=0.1,["relative"]=true,["parent"]=dialog.generalTab,["label"]="Enable rotation patches"}
	---------------------------------
	--camera settings
	guiCreateLabel ( 0.02, 0.02, 1, 0.1, "Normal camera move speed:", true, dialog.cameraTab )
	guiCreateLabel ( 0.02, 0.22, 1, 0.1, "Fast camera move speed:", true, dialog.cameraTab )
	guiCreateLabel ( 0.02, 0.42, 1, 0.1, "Slow camera move speed:", true, dialog.cameraTab )
	guiCreateLabel ( 0.02, 0.72, 1, 0.1, "Look sensitivity:", true, dialog.cameraTab )
	guiCreateLabel ( 0.5, 0.02, 1, 0.1, "Field of View:", true, dialog.cameraTab )

	dialog.normalMove = editingControl.slider:create{["x"]=0.02,["y"]=0.08,["width"]=0.4,["height"]=0.11,["relative"]=true,["parent"]=dialog.cameraTab,
		["min"]=1,
		["max"]=6,
	}
	dialog.fastMove = editingControl.slider:create{["x"]=0.02,["y"]=0.28,["width"]=0.4,["height"]=0.11,["relative"]=true,["parent"]=dialog.cameraTab,
		["min"]=7,
		["max"]=16,
	}
	dialog.slowMove = editingControl.slider:create{["x"]=0.02,["y"]=0.48,["width"]=0.4,["height"]=0.11,["relative"]=true,["parent"]=dialog.cameraTab,
		["min"]=0.1,
		["max"]=0.8,
	}
	dialog.mouseSensitivity = editingControl.slider:create{["x"]=0.02,["y"]=0.78,["width"]=0.4,["height"]=0.11,["relative"]=true,["parent"]=dialog.cameraTab,
		["min"]=0.01,
		["max"]=1.3,
	}
	dialog.fov = editingControl.slider:create{["x"]=0.5,["y"]=0.08,["width"]=0.4,["height"]=0.11,["relative"]=true,["parent"]=dialog.cameraTab,
		["min"]=70,
		["max"]=90,
	}

	dialog.smoothCamMove = editingControl.boolean:create{["x"]=0.5,["y"]=0.22,["width"]=1,["height"]=0.1,["relative"]=true,["parent"]=dialog.cameraTab,["label"]="Smooth Camera movement"}
	dialog.invertMouseLook = editingControl.boolean:create{["x"]=0.5,["y"]=0.32,["width"]=1,["height"]=0.1,["relative"]=true,["parent"]=dialog.cameraTab,["label"]="Invert mouse look"}
	--create movement settings
	guiCreateLabel ( 0.02, 0.12, 1, 0.1, "Normal element movement speed:", true, dialog.movementTab )
	guiCreateLabel ( 0.02, 0.32, 1, 0.1, "Fast element movement speed:", true, dialog.movementTab )
	guiCreateLabel ( 0.02, 0.52, 1, 0.1, "Slow element movement speed:", true, dialog.movementTab )
	guiCreateLabel ( 0.5, 0.12, 1, 0.1, "Normal element rotation speed:", true, dialog.movementTab )
	guiCreateLabel ( 0.5, 0.32, 1, 0.1, "Fast element rotation speed:", true, dialog.movementTab )
	guiCreateLabel ( 0.5, 0.52, 1, 0.1, "Slow element rotation speed:", true, dialog.movementTab )
	guiCreateLabel ( 0.5, 0.72, 1, 0.1, "Element scaling:", true, dialog.movementTab )


	dialog.normalElemMove = editingControl.slider:create{["x"]=0.02,["y"]=0.18,["width"]=0.4,["height"]=0.11,["relative"]=true,["parent"]=dialog.movementTab,
		["min"]=0.075,
		["max"]=0.5,
	}
	dialog.fastElemMove = editingControl.slider:create{["x"]=0.02,["y"]=0.38,["width"]=0.4,["height"]=0.11,["relative"]=true,["parent"]=dialog.movementTab,
		["min"]=0.75,
		["max"]=4,
	}
	dialog.slowElemMove = editingControl.slider:create{["x"]=0.02,["y"]=0.58,["width"]=0.4,["height"]=0.11,["relative"]=true,["parent"]=dialog.movementTab,
		["min"]=0.001,
		["max"]=0.05,
	}
	dialog.normalElemRotate = editingControl.slider:create{["x"]=0.5,["y"]=0.18,["width"]=0.4,["height"]=0.11,["relative"]=true,["parent"]=dialog.movementTab,
		["min"]=0.75,
		["max"]=4,
	}
	dialog.fastElemRotate = editingControl.slider:create{["x"]=0.5,["y"]=0.38,["width"]=0.4,["height"]=0.11,["relative"]=true,["parent"]=dialog.movementTab,
		["min"]=7,
		["max"]=18,
	}
	dialog.slowElemRotate = editingControl.slider:create{["x"]=0.5,["y"]=0.58,["width"]=0.4,["height"]=0.11,["relative"]=true,["parent"]=dialog.movementTab,
		["min"]=0.01,
		["max"]=0.5,
	}
	dialog.elemScaling = editingControl.slider:create{["x"]=0.5,["y"]=0.78,["width"]=0.4,["height"]=0.11,["relative"]=true,["parent"]=dialog.movementTab,
		["min"]=0.01,
		["max"]=1,
	}
	dialog.lockToAxes = editingControl.boolean:create{["x"]=0.02,["y"]=0.78,["width"]=0.4,["height"]=0.1,["relative"]=true,["parent"]=dialog.movementTab,["label"]="Lock movement to axes"}
	--
	loadXMLSettings()
	addEventHandler ( "onClientGUIClick", dialog.ok, confirmSettings,false )
	addEventHandler ( "onClientGUIClick", dialog.cancel, cancelSettings,false )
	addEventHandler ( "onClientGUIClick", dialog.restoreDefaults, restoreDefaults,false )
end


-------OK and Cancel clicking
function cancelSettings ()
	guiSetVisible ( dialog.window, false )
	setGUIShowing(true)
	guiSetInputEnabled ( false )
	setWorldClickEnabled ( true )
end

function confirmSettings ()
	guiSetVisible ( dialog.window, false )
	dumpSettings()
	doActions()
	updateGUI()
	setGUIShowing(true)
	guiSetInputEnabled ( false )
	setWorldClickEnabled ( true )
	xmlSaveFile ( settingsXML )
end

addEvent("enableServerSettings", true)
addEventHandler("enableServerSettings", root,
	function(enabled, interval)
		dialog.serverTab = guiCreateTab("Server Settings",tabpanel)
		dialog.enableDumpSave = editingControl.boolean:create{["x"]=0.02,["y"]=0.02,["width"]=1,["height"]=0.1,["relative"]=true,["value"]=enabled,["parent"]=dialog.serverTab,["label"]="Enable Map Backup"}
		guiCreateLabel ( 0.02, 0.14, 1, 0.1, "Map Backup Interval (seconds):", true, dialog.serverTab )
		dialog.dumpSaveInterval = editingControl.integer:create{["x"]=0.02,["y"]=0.2,["width"]=0.30,["height"]=0.07,["relative"]=true,["value"]=interval,["parent"]=dialog.serverTab }
	end
)
