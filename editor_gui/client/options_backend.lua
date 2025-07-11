------All the tables defining stuff
local bools = { ["false"]=false, ["true"]=true }
local xmlVariants = {
["enableSounds"]="enablesounds",
["normalMove"]="camera_normal_speed",
["fastMove"]="camera_max_speed",
["slowMove"]="camera_min_speed",
["mouseSensitivity"]="camera_look_sensitivity",
["smoothCamMove"]="camera_smooth_movement",
["invertMouseLook"]="invert_mouse_look",
["iconSize"]="icon_size",
["topAlign"]="alignment_topmenu",
["bottomAlign"]="alignment_bottommenu",
["normalElemMove"]="movement_normal_speed",
["fastElemMove"]="movement_max_speed",
["slowElemMove"]="movement_min_speed",
["normalElemRotate"]="rotate_normal_speed",
["fastElemRotate"]="rotate_fast_speed",
["slowElemRotate"]="rotate_slow_speed",
["elemScaling"]="scaling_increment",
["lockToAxes"]="movement_lock_to_axes",
["autosnap"]="currentbrowser_autosnap",
["tutorialOnStart"]="tutorial_on_start",
["enableBox"]="enablebox",
["enableXYZlines"]="enablexyzlines",
["precisionLevel"]="precisionlevel",
["precisionRotLevel"]="precisionrotlevel",
["elemScalingSnap"]="scalingSnap",
["enablePrecisionSnap"]="enableprecisionsnap",
["enablePrecisionRotation"]="enableprecisionrotation",
["enableColPatch"]="enablecolpatch",
["enableRotPatch"]="enablerotpatch",
["fov"]="fov",
}
local nodeTypes = {
["enableSounds"]="bool",
["normalMove"]="progress",
["fastMove"]="progress",
["slowMove"]="progress",
["mouseSensitivity"]="progress",
["smoothCamMove"]="bool",
["invertMouseLook"]="bool",
["iconSize"]={"small","medium","large"},
["topAlign"]={"left","right","center"},
["bottomAlign"]={"left","right","center"},
["normalElemMove"]="progress",
["fastElemMove"]="progress",
["slowElemMove"]="progress",
["normalElemRotate"]="progress",
["fastElemRotate"]="progress",
["slowElemRotate"]="progress",
["elemScaling"]="progress",
["lockToAxes"]="bool",
["autosnap"]="bool",
["tutorialOnStart"]="bool",
["enableDumpSave"]="bool",
["enableBox"]="bool",
["precisionLevel"]={"10","5","2","1","0.1","0.01","0.001","0.0001"},
["precisionRotLevel"]={"180","90","45","30","20","10","5","1"},
["elemScalingSnap"]={"1","0.1","0.01","0.001","0.0001"},
["enablePrecisionSnap"]="bool",
["enablePrecisionRotation"]="bool",
["enableXYZlines"]="bool",
["enableColPatch"]="bool",
["enableRotPatch"]="bool",
["fov"]="progress",
}
local defaults = {
["enableSounds"]=true,
["normalMove"]=2,
["fastMove"]=12,
["slowMove"]=.2,
["mouseSensitivity"]=.73,
["smoothCamMove"]=true,
["invertMouseLook"]=false,
["iconSize"]="medium",
["topAlign"]="center",
["bottomAlign"]="left",
["normalElemMove"]=.25,
["fastElemMove"]=1.57,
["slowElemMove"]=.025,
["normalElemRotate"]=2,
["fastElemRotate"]=10,
["slowElemRotate"]=.25,
["elemScaling"]=.1,
["lockToAxes"]=false,
["autosnap"]=true,
["tutorialOnStart"]=true,
["enableBox"]=true,
["precisionLevel"]="0.1",
["precisionRotLevel"]="30",
["elemScalingSnap"]="0.1",
["enablePrecisionSnap"]=true,
["enablePrecisionRotation"]=false,
["enableXYZlines"]=true,
["enableColPatch"]=false,
["enableRotPatch"]=true,
["fov"]=dxGetStatus()["SettingFOV"],
}

--stuff involving xml and dumping
function doActions()
	for name,v in pairs(nodeTypes) do
		if ( optionsActions[name] ) and ( dialog[name] ) then
			optionsActions[name]( dialog[name]:getValue() )
		end
	end
end

function loadXMLSettings()
	--this should use xmlLoadFile afterwards
	if settingsXML then
		xmlUnloadFile ( settingsXML )
	end
	settingsXML = xmlLoadFile ( "settings.xml" )
	if not settingsXML then createSettingsXML() end
	if not settingsXML then
		outputMessage ( "Map editor settings could not be created!.", 255,0,0 )
		return
	end
	--
	local settingsNodes = {}
	for gui,nodeName in pairs(xmlVariants) do
		local node = xmlFindChild ( settingsXML, nodeName, 0 )
		if node then
			settingsNodes[gui] = node
		else
			settingsNodes[gui] = xmlCreateChild ( settingsXML, nodeName )
		end
	end

	local settingsTable = {}
	for gui,node in pairs(settingsNodes) do
		local value
		if nodeTypes[gui] == "bool" then
			nodeValue = getNodeValue ( node, defaults[gui] )
			value = bools[xmlNodeGetValue ( node )]
		elseif nodeTypes[gui] == "progress" then
			value = tonumber(getNodeValue ( node, defaults[gui] ))
		elseif type(nodeTypes[gui]) == "table" then
			value = tostring(getNodeValue ( node, defaults[gui] ))
			local valid = false
			for key,valuePossibility in pairs(nodeTypes[gui]) do
				if value == valuePossibility then
					valid = true
				end
			end
			if not valid then value = defaults[gui] end
		end
		settingsTable[gui] = value
	end
	inputSettings ( settingsTable )
	doActions()
end

function getNodeValue ( node, default )
	local value = xmlNodeGetValue ( node )
	if ( value ) then
		return value
	else
		xmlNodeSetValue ( node, tostring(default) )
	end
	xmlSaveFile ( settingsXML )
end

function createSettingsXML()
	local xml = xmlCreateFile ( "settings.xml", "settings" )
	for gui,nodeName in pairs(xmlVariants) do
		local node = xmlCreateChild ( xml, nodeName )
		xmlNodeSetValue ( node, tostring(defaults[gui]) )
	end
	xmlSaveFile ( xml )
	xmlUnloadFile ( xml )
	if settingsXML then
		xmlUnloadFile ( settingsXML )
	end
	settingsXML = xmlLoadFile ( "settings.xml" )
end

function inputSettings ( settingsTable )
	for gui,value in pairs(settingsTable) do
		dialog[gui]:setValue(value)
	end
	optionsSettings = settingsTable
end

function dumpSettings() --this does the reverse of input settings.  Dumps the current GUI into a table, and saves it to XML.
	for gui,nodeName in pairs(xmlVariants) do
		local value = dialog[gui]:getValue()
		optionsSettings[gui] = value
		--save to xml
		local node = xmlFindChild ( settingsXML, nodeName, 0 )
		if not node then node = xmlCreateChild ( settingsXML, nodeName ) end
		xmlNodeSetValue ( node, tostring(value) )
	end
end

function restoreDefaults()
	for gui,value in pairs(defaults) do
		dialog[gui]:setValue(value)
	end
end
