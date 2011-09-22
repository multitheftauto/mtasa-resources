settings = {
	["useanimation"] = nil,
	["toggleable"] = nil,
	["showserverinfo"] = nil,
	["showgamemodeinfo"] = nil,
	["showteams"] = nil,
	["usecolors"] = nil,
	["drawspeed"] = nil,
	["scale"] = nil,
	["columnfont"] = nil,
	["contentfont"] = nil,
	["teamfont"] = nil,
	["serverinfofont"] = nil,
	["bg_color"] = {},
	["selection_color"] = {},
	["highlight_color"] = {},
	["header_color"] = {},
	["team_color"] = {},
	["border_color"] = {},
	["serverinfo_color"] = {},
	["content_color"] = {}
}
defaultSettings = {
	["useanimation"] = true,
	["toggleable"] = false,
	["showserverinfo"] = false,
	["showgamemodeinfo"] = false,
	["showteams"] = true,
	["usecolors"] = true,
	["drawspeed"] = 1.5,
	["scale"] = 1.0,
	["columnfont"] = "default-bold",
	["contentfont"] = "default-bold",
	["teamfont"] = "clear",
	["serverinfofont"] = "default",
	["bg_color"] = {
		["r"] = 0,
		["g"] = 0,
		["b"] = 0,
		["a"] = 170
	},
	["selection_color"] = {
		["r"] = 82,
		["g"] = 103,
		["b"] = 188,
		["a"] = 170
	},
	["highlight_color"] = {
		["r"] = 255,
		["g"] = 255,
		["b"] = 255,
		["a"] = 50
	},
	["header_color"] = {
		["r"] = 100,
		["g"] = 100,
		["b"] = 100,
		["a"] = 255
	},
	["team_color"] = {
		["r"] = 100,
		["g"] = 100,
		["b"] = 100,
		["a"] = 100
	},
	["border_color"] = {
		["r"] = 100,
		["g"] = 100,
		["b"] = 100,
		["a"] = 50
	},
	["serverinfo_color"] = {
		["r"] = 150,
		["g"] = 150,
		["b"] = 150,
		["a"] = 255
	},
	["content_color"] = {
		["r"] = 255,
		["g"] = 255,
		["b"] = 255,
		["a"] = 255
	}
}

tempColors = {
	["bg_color"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil
	},
	["selection_color"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil
	},
	["highlight_color"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil
	},
	["header_color"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil
	},
	["team_color"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil
	},
	["border_color"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil
	},
	["serverinfo_color"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil
	},
	["content_color"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil
	}
}
MAX_DRAWSPEED = 4.0
MIN_DRAWSPEED = 0.5
MAX_SCALE = 2.5
MIN_SCALE = 0.5
fontIndexes = {
	["column"] = 1,
	["content"] = 1,
	["team"] = 1,
	["serverinfo"] = 1
}
fontNames = { "default", "default-bold", "clear", "arial", "sans","pricedown", "bankgothic", "diploma", "beckett" }

function readScoreboardSettings()
	local settingsFile = xmlLoadFile( "settings.xml" )
	if not settingsFile then
		settingsFile = xmlCreateFile( "settings.xml", "settings" )
		if not settingsFile then return false end
		
		local useanimationTag = xmlCreateChild( settingsFile, "useanimation" )
			xmlNodeSetValue( useanimationTag, tostring( defaultSettings.useanimation ) )
		local toggleableTag = xmlCreateChild( settingsFile, "toggleable" )
			xmlNodeSetValue( toggleableTag, tostring( defaultSettings.toggleable ) )
		local showserverinfoTag = xmlCreateChild( settingsFile, "showserverinfo" )
			xmlNodeSetValue( showserverinfoTag, tostring( defaultSettings.showserverinfo ) )
		local showgamemodeinfoTag = xmlCreateChild( settingsFile, "showgamemodeinfo" )
			xmlNodeSetValue( showgamemodeinfoTag, tostring( defaultSettings.showgamemodeinfo ) )
		local showteamsTag = xmlCreateChild( settingsFile, "showteams" )
			xmlNodeSetValue( showteamsTag, tostring( defaultSettings.showteams ) )
		local usecolorsTag = xmlCreateChild( settingsFile, "usecolors" )
			xmlNodeSetValue( usecolorsTag, tostring( defaultSettings.usecolors ) )
		local drawspeedTag = xmlCreateChild( settingsFile, "drawspeed" )
			xmlNodeSetValue( drawspeedTag, tostring( defaultSettings.drawspeed ) )
		local scaleTag = xmlCreateChild( settingsFile, "scale" )
			xmlNodeSetValue( scaleTag, tostring( defaultSettings.scale ) )
		local columnfontTag = xmlCreateChild( settingsFile, "columnfont" )
			xmlNodeSetValue( columnfontTag, tostring( defaultSettings.columnfont ) )
		local contentfontTag = xmlCreateChild( settingsFile, "contentfont" )
			xmlNodeSetValue( contentfontTag, tostring( defaultSettings.contentfont ) )
		local teamfontTag = xmlCreateChild( settingsFile, "teamfont" )
			xmlNodeSetValue( teamfontTag, tostring( defaultSettings.teamfont ) )
		local serverinfofontTag = xmlCreateChild( settingsFile, "serverinfofont" )
			xmlNodeSetValue( serverinfofontTag, tostring( defaultSettings.serverinfofont ) )
		local bg_colorTag = xmlCreateChild( settingsFile, "bg_color" )
			xmlNodeSetAttribute( bg_colorTag, "r", tostring( defaultSettings.bg_color.r ) )
			xmlNodeSetAttribute( bg_colorTag, "g", tostring( defaultSettings.bg_color.g ) )
			xmlNodeSetAttribute( bg_colorTag, "b", tostring( defaultSettings.bg_color.b ) )
			xmlNodeSetAttribute( bg_colorTag, "a", tostring( defaultSettings.bg_color.a ) )
		local selection_colorTag = xmlCreateChild( settingsFile, "selection_color" )
			xmlNodeSetAttribute( selection_colorTag, "r", tostring( defaultSettings.selection_color.r ) )
			xmlNodeSetAttribute( selection_colorTag, "g", tostring( defaultSettings.selection_color.g ) )
			xmlNodeSetAttribute( selection_colorTag, "b", tostring( defaultSettings.selection_color.b ) )
			xmlNodeSetAttribute( selection_colorTag, "a", tostring( defaultSettings.selection_color.a ) )
		local highlight_colorTag = xmlCreateChild( settingsFile, "highlight_color" )
			xmlNodeSetAttribute( highlight_colorTag, "r", tostring( defaultSettings.highlight_color.r ) )
			xmlNodeSetAttribute( highlight_colorTag, "g", tostring( defaultSettings.highlight_color.g ) )
			xmlNodeSetAttribute( highlight_colorTag, "b", tostring( defaultSettings.highlight_color.b ) )
			xmlNodeSetAttribute( highlight_colorTag, "a", tostring( defaultSettings.highlight_color.a ) )
		local header_colorTag = xmlCreateChild( settingsFile, "header_color" )
			xmlNodeSetAttribute( header_colorTag, "r", tostring( defaultSettings.header_color.r ) )
			xmlNodeSetAttribute( header_colorTag, "g", tostring( defaultSettings.header_color.g ) )
			xmlNodeSetAttribute( header_colorTag, "b", tostring( defaultSettings.header_color.b ) )
			xmlNodeSetAttribute( header_colorTag, "a", tostring( defaultSettings.header_color.a ) )
		local team_colorTag = xmlCreateChild( settingsFile, "team_color" )
			xmlNodeSetAttribute( team_colorTag, "r", tostring( defaultSettings.team_color.r ) )
			xmlNodeSetAttribute( team_colorTag, "g", tostring( defaultSettings.team_color.g ) )
			xmlNodeSetAttribute( team_colorTag, "b", tostring( defaultSettings.team_color.b ) )
			xmlNodeSetAttribute( team_colorTag, "a", tostring( defaultSettings.team_color.a ) )
		local border_colorTag = xmlCreateChild( settingsFile, "border_color" )
			xmlNodeSetAttribute( border_colorTag, "r", tostring( defaultSettings.border_color.r ) )
			xmlNodeSetAttribute( border_colorTag, "g", tostring( defaultSettings.border_color.g ) )
			xmlNodeSetAttribute( border_colorTag, "b", tostring( defaultSettings.border_color.b ) )
			xmlNodeSetAttribute( border_colorTag, "a", tostring( defaultSettings.border_color.a ) )
		local serverinfo_colorTag = xmlCreateChild( settingsFile, "serverinfo_color" )
			xmlNodeSetAttribute( serverinfo_colorTag, "r", tostring( defaultSettings.serverinfo_color.r ) )
			xmlNodeSetAttribute( serverinfo_colorTag, "g", tostring( defaultSettings.serverinfo_color.g ) )
			xmlNodeSetAttribute( serverinfo_colorTag, "b", tostring( defaultSettings.serverinfo_color.b ) )
			xmlNodeSetAttribute( serverinfo_colorTag, "a", tostring( defaultSettings.serverinfo_color.a ) )
		local content_colorTag = xmlCreateChild( settingsFile, "content_color" )
			xmlNodeSetAttribute( content_colorTag, "r", tostring( defaultSettings.content_color.r ) )
			xmlNodeSetAttribute( content_colorTag, "g", tostring( defaultSettings.content_color.g ) )
			xmlNodeSetAttribute( content_colorTag, "b", tostring( defaultSettings.content_color.b ) )
			xmlNodeSetAttribute( content_colorTag, "a", tostring( defaultSettings.content_color.a ) )
		xmlSaveFile( settingsFile )
	end
	
	local useanimationTag = xmlFindChild( settingsFile, "useanimation", 0 )
	if not useanimationTag then
		useanimationTag = xmlCreateChild( settingsFile, "useanimation" )
			xmlNodeSetValue( useanimationTag, tostring( defaultSettings.useanimation ) )
		xmlSaveFile( settingsFile )
	end
	
	local toggleableTag = xmlFindChild( settingsFile, "toggleable", 0 )
	if not toggleableTag then
		toggleableTag = xmlCreateChild( settingsFile, "toggleable" )
			xmlNodeSetValue( toggleableTag, tostring( defaultSettings.toggleable ) )
		xmlSaveFile( settingsFile )
	end
	
	local showserverinfoTag = xmlFindChild( settingsFile, "showserverinfo", 0 )
	if not showserverinfoTag then
		showserverinfoTag = xmlCreateChild( settingsFile, "showserverinfo" )
			xmlNodeSetValue( showserverinfoTag, tostring( defaultSettings.showserverinfo ) )
		xmlSaveFile( settingsFile )
	end
	
	local showgamemodeinfoTag = xmlFindChild( settingsFile, "showgamemodeinfo", 0 )
	if not showgamemodeinfoTag then
		showgamemodeinfoTag = xmlCreateChild( settingsFile, "showgamemodeinfo" )
			xmlNodeSetValue( showgamemodeinfoTag, tostring( defaultSettings.showgamemodeinfo ) )
		xmlSaveFile( settingsFile )
	end
	
	local showteamsTag = xmlFindChild( settingsFile, "showteams", 0 )
	if not showteamsTag then
		showteamsTag = xmlCreateChild( settingsFile, "showteams" )
			xmlNodeSetValue( showteamsTag, tostring( defaultSettings.showteams ) )
		xmlSaveFile( settingsFile )
	end
	
	local usecolorsTag = xmlFindChild( settingsFile, "usecolors", 0 )
	if not usecolorsTag then
		usecolorsTag = xmlCreateChild( settingsFile, "usecolors" )
			xmlNodeSetValue( usecolorsTag, tostring( defaultSettings.usecolors ) )
		xmlSaveFile( settingsFile )
	end
	
	local drawspeedTag = xmlFindChild( settingsFile, "drawspeed", 0 )
	if not drawspeedTag then
		drawspeedTag = xmlCreateChild( settingsFile, "drawspeed" )
			xmlNodeSetValue( drawspeedTag, tostring( defaultSettings.drawspeed ) )
		xmlSaveFile( settingsFile )
	end
	
	local scaleTag = xmlFindChild( settingsFile, "scale", 0 )
	if not scaleTag then
		scaleTag = xmlCreateChild( settingsFile, "scale" )
			xmlNodeSetValue( scaleTag, tostring( defaultSettings.scale ) )
		xmlSaveFile( settingsFile )
	end
	
	local columnfontTag = xmlFindChild( settingsFile, "columnfont", 0 )
	if not columnfontTag then
		columnfontTag = xmlCreateChild( settingsFile, "columnfont" )
			xmlNodeSetValue( columnfontTag, tostring( defaultSettings.columnfont ) )
		xmlSaveFile( settingsFile )
	end
	
	local contentfontTag = xmlFindChild( settingsFile, "contentfont", 0 )
	if not contentfontTag then
		contentfontTag = xmlCreateChild( settingsFile, "contentfont" )
			xmlNodeSetValue( contentfontTag, tostring( defaultSettings.contentfont ) )
		xmlSaveFile( settingsFile )
	end
	
	local teamfontTag = xmlFindChild( settingsFile, "teamfont", 0 )
	if not teamfontTag then
		teamfontTag = xmlCreateChild( settingsFile, "teamfont" )
			xmlNodeSetValue( teamfontTag, tostring( defaultSettings.teamfont ) )
		xmlSaveFile( settingsFile )
	end
	
	local serverinfofontTag = xmlFindChild( settingsFile, "serverinfofont", 0 )
	if not serverinfofontTag then
		serverinfofontTag = xmlCreateChild( settingsFile, "serverinfofont" )
			xmlNodeSetValue( serverinfofontTag, tostring( defaultSettings.serverinfofont ) )
		xmlSaveFile( settingsFile )
	end
	
	local bg_colorTag = xmlFindChild( settingsFile, "bg_color", 0 )
	if not bg_colorTag then
		bg_colorTag = xmlCreateChild( settingsFile, "bg_color" )
			xmlNodeSetAttribute( bg_colorTag, "r", tostring( defaultSettings.bg_color.r ) )
			xmlNodeSetAttribute( bg_colorTag, "g", tostring( defaultSettings.bg_color.g ) )
			xmlNodeSetAttribute( bg_colorTag, "b", tostring( defaultSettings.bg_color.b ) )
			xmlNodeSetAttribute( bg_colorTag, "a", tostring( defaultSettings.bg_color.a ) )
		xmlSaveFile( settingsFile )
	end
	
	local selection_colorTag = xmlFindChild( settingsFile, "selection_color", 0 )
	if not selection_colorTag then
		selection_colorTag = xmlCreateChild( settingsFile, "selection_color" )
			xmlNodeSetAttribute( selection_colorTag, "r", tostring( defaultSettings.selection_color.r ) )
			xmlNodeSetAttribute( selection_colorTag, "g", tostring( defaultSettings.selection_color.g ) )
			xmlNodeSetAttribute( selection_colorTag, "b", tostring( defaultSettings.selection_color.b ) )
			xmlNodeSetAttribute( selection_colorTag, "a", tostring( defaultSettings.selection_color.a ) )
		xmlSaveFile( settingsFile )
	end
	
	local highlight_colorTag = xmlFindChild( settingsFile, "highlight_color", 0 )
	if not highlight_colorTag then
		highlight_colorTag = xmlCreateChild( settingsFile, "highlight_color" )
			xmlNodeSetAttribute( highlight_colorTag, "r", tostring( defaultSettings.highlight_color.r ) )
			xmlNodeSetAttribute( highlight_colorTag, "g", tostring( defaultSettings.highlight_color.g ) )
			xmlNodeSetAttribute( highlight_colorTag, "b", tostring( defaultSettings.highlight_color.b ) )
			xmlNodeSetAttribute( highlight_colorTag, "a", tostring( defaultSettings.highlight_color.a ) )
		xmlSaveFile( settingsFile )
	end
	
	local header_colorTag = xmlFindChild( settingsFile, "header_color", 0 )
	if not header_colorTag then
		header_colorTag = xmlCreateChild( settingsFile, "header_color" )
			xmlNodeSetAttribute( header_colorTag, "r", tostring( defaultSettings.header_color.r ) )
			xmlNodeSetAttribute( header_colorTag, "g", tostring( defaultSettings.header_color.g ) )
			xmlNodeSetAttribute( header_colorTag, "b", tostring( defaultSettings.header_color.b ) )
			xmlNodeSetAttribute( header_colorTag, "a", tostring( defaultSettings.header_color.a ) )
		xmlSaveFile( settingsFile )
	end
	
	local team_colorTag = xmlFindChild( settingsFile, "team_color", 0 )
	if not team_colorTag then
		team_colorTag = xmlCreateChild( settingsFile, "team_color" )
			xmlNodeSetAttribute( team_colorTag, "r", tostring( defaultSettings.team_color.r ) )
			xmlNodeSetAttribute( team_colorTag, "g", tostring( defaultSettings.team_color.g ) )
			xmlNodeSetAttribute( team_colorTag, "b", tostring( defaultSettings.team_color.b ) )
			xmlNodeSetAttribute( team_colorTag, "a", tostring( defaultSettings.team_color.a ) )
		xmlSaveFile( settingsFile )
	end
	
	local border_colorTag = xmlFindChild( settingsFile, "border_color", 0 )
	if not border_colorTag then
		border_colorTag = xmlCreateChild( settingsFile, "border_color" )
			xmlNodeSetAttribute( border_colorTag, "r", tostring( defaultSettings.border_color.r ) )
			xmlNodeSetAttribute( border_colorTag, "g", tostring( defaultSettings.border_color.g ) )
			xmlNodeSetAttribute( border_colorTag, "b", tostring( defaultSettings.border_color.b ) )
			xmlNodeSetAttribute( border_colorTag, "a", tostring( defaultSettings.border_color.a ) )
		xmlSaveFile( settingsFile )
	end
	
	local serverinfo_colorTag = xmlFindChild( settingsFile, "serverinfo_color", 0 )
	if not serverinfo_colorTag then
		serverinfo_colorTag = xmlCreateChild( settingsFile, "serverinfo_color" )
			xmlNodeSetAttribute( serverinfo_colorTag, "r", tostring( defaultSettings.serverinfo_color.r ) )
			xmlNodeSetAttribute( serverinfo_colorTag, "g", tostring( defaultSettings.serverinfo_color.g ) )
			xmlNodeSetAttribute( serverinfo_colorTag, "b", tostring( defaultSettings.serverinfo_color.b ) )
			xmlNodeSetAttribute( serverinfo_colorTag, "a", tostring( defaultSettings.serverinfo_color.a ) )
		xmlSaveFile( settingsFile )
	end
	
	local content_colorTag = xmlFindChild( settingsFile, "content_color", 0 )
	if not content_colorTag then
		content_colorTag = xmlCreateChild( settingsFile, "content_color" )
			xmlNodeSetAttribute( content_colorTag, "r", tostring( defaultSettings.content_color.r ) )
			xmlNodeSetAttribute( content_colorTag, "g", tostring( defaultSettings.content_color.g ) )
			xmlNodeSetAttribute( content_colorTag, "b", tostring( defaultSettings.content_color.b ) )
			xmlNodeSetAttribute( content_colorTag, "a", tostring( defaultSettings.content_color.a ) )
		xmlSaveFile( settingsFile )
	end
	
	settings.useanimation = xmlNodeGetValue( useanimationTag )
	settings.useanimation = iif( settings.useanimation and tostring( settings.useanimation ) == "false", false, true )
	
	settings.toggleable = xmlNodeGetValue( toggleableTag )
	settings.toggleable = iif( settings.toggleable and tostring( settings.toggleable ) == "true", true, false )
	
	settings.showserverinfo = xmlNodeGetValue( showserverinfoTag )
	settings.showserverinfo = iif( settings.showserverinfo and tostring( settings.showserverinfo ) == "true", true, false )
	
	settings.showgamemodeinfo = xmlNodeGetValue( showgamemodeinfoTag )
	settings.showgamemodeinfo = iif( settings.showgamemodeinfo and tostring( settings.showgamemodeinfo ) == "true", true, false )
	
	settings.showteams = xmlNodeGetValue( showteamsTag )
	settings.showteams = iif( settings.showteams and tostring( settings.showteams ) == "false", false, true )
	
	settings.usecolors = xmlNodeGetValue( usecolorsTag )
	settings.usecolors = iif( settings.usecolors and tostring( settings.usecolors ) == "false", false, true )
	
	settings.drawspeed = tonumber( xmlNodeGetValue( drawspeedTag ) )
	settings.drawspeed = iif( type( settings.drawspeed ) == "number" and settings.drawspeed >= MIN_DRAWSPEED and settings.drawspeed <= MAX_DRAWSPEED, settings.drawspeed, defaultSettings.drawspeed )
	
	settings.scale = tonumber( xmlNodeGetValue( scaleTag ) )
	settings.scale = iif( type( settings.scale ) == "number" and settings.scale >= MIN_SCALE and settings.scale <= MAX_SCALE, settings.scale, defaultSettings.scale )
	
	settings.columnfont = xmlNodeGetValue( columnfontTag )
	settings.columnfont = iif( fontScale[settings.columnfont], settings.columnfont, defaultSettings.columnfont )
	
	settings.contentfont = xmlNodeGetValue( contentfontTag )
	settings.contentfont = iif( fontScale[settings.contentfont], settings.contentfont, defaultSettings.contentfont )
	
	settings.teamfont = xmlNodeGetValue( teamfontTag )
	settings.teamfont = iif( fontScale[settings.teamfont], settings.teamfont, defaultSettings.teamfont )
	
	settings.serverinfofont = xmlNodeGetValue( serverinfofontTag )
	settings.serverinfofont = iif( fontScale[settings.serverinfofont], settings.serverinfofont, defaultSettings.serverinfofont )
	
	settings.bg_color.r = validateRange( tonumber( xmlNodeGetAttribute( bg_colorTag, "r" ) ) ) or defaultSettings.bg_color.r
	settings.bg_color.g = validateRange( tonumber( xmlNodeGetAttribute( bg_colorTag, "g" ) ) ) or defaultSettings.bg_color.g
	settings.bg_color.b = validateRange( tonumber( xmlNodeGetAttribute( bg_colorTag, "b" ) ) ) or defaultSettings.bg_color.b
	settings.bg_color.a = validateRange( tonumber( xmlNodeGetAttribute( bg_colorTag, "a" ) ) ) or defaultSettings.bg_color.a
	
	settings.selection_color.r = validateRange( tonumber( xmlNodeGetAttribute( selection_colorTag, "r" ) ) ) or defaultSettings.selection_color.r
	settings.selection_color.g = validateRange( tonumber( xmlNodeGetAttribute( selection_colorTag, "g" ) ) ) or defaultSettings.selection_color.g
	settings.selection_color.b = validateRange( tonumber( xmlNodeGetAttribute( selection_colorTag, "b" ) ) ) or defaultSettings.selection_color.b
	settings.selection_color.a = validateRange( tonumber( xmlNodeGetAttribute( selection_colorTag, "a" ) ) ) or defaultSettings.selection_color.a
	
	settings.highlight_color.r = validateRange( tonumber( xmlNodeGetAttribute( highlight_colorTag, "r" ) ) ) or defaultSettings.highlight_color.r
	settings.highlight_color.g = validateRange( tonumber( xmlNodeGetAttribute( highlight_colorTag, "g" ) ) ) or defaultSettings.highlight_color.g
	settings.highlight_color.b = validateRange( tonumber( xmlNodeGetAttribute( highlight_colorTag, "b" ) ) ) or defaultSettings.highlight_color.b
	settings.highlight_color.a = validateRange( tonumber( xmlNodeGetAttribute( highlight_colorTag, "a" ) ) ) or defaultSettings.highlight_color.a
	
	settings.header_color.r = validateRange( tonumber( xmlNodeGetAttribute( header_colorTag, "r" ) ) ) or defaultSettings.header_color.r
	settings.header_color.g = validateRange( tonumber( xmlNodeGetAttribute( header_colorTag, "g" ) ) ) or defaultSettings.header_color.g
	settings.header_color.b = validateRange( tonumber( xmlNodeGetAttribute( header_colorTag, "b" ) ) ) or defaultSettings.header_color.b
	settings.header_color.a = validateRange( tonumber( xmlNodeGetAttribute( header_colorTag, "a" ) ) ) or defaultSettings.header_color.a
	
	settings.team_color.r = validateRange( tonumber( xmlNodeGetAttribute( team_colorTag, "r" ) ) ) or defaultSettings.team_color.r
	settings.team_color.g = validateRange( tonumber( xmlNodeGetAttribute( team_colorTag, "g" ) ) ) or defaultSettings.team_color.g
	settings.team_color.b = validateRange( tonumber( xmlNodeGetAttribute( team_colorTag, "b" ) ) ) or defaultSettings.team_color.b
	settings.team_color.a = validateRange( tonumber( xmlNodeGetAttribute( team_colorTag, "a" ) ) ) or defaultSettings.team_color.a
	
	settings.border_color.r = validateRange( tonumber( xmlNodeGetAttribute( border_colorTag, "r" ) ) ) or defaultSettings.border_color.r
	settings.border_color.g = validateRange( tonumber( xmlNodeGetAttribute( border_colorTag, "g" ) ) ) or defaultSettings.border_color.g
	settings.border_color.b = validateRange( tonumber( xmlNodeGetAttribute( border_colorTag, "b" ) ) ) or defaultSettings.border_color.b
	settings.border_color.a = validateRange( tonumber( xmlNodeGetAttribute( border_colorTag, "a" ) ) ) or defaultSettings.border_color.a
	
	settings.serverinfo_color.r = validateRange( tonumber( xmlNodeGetAttribute( serverinfo_colorTag, "r" ) ) ) or defaultSettings.serverinfo_color.r
	settings.serverinfo_color.g = validateRange( tonumber( xmlNodeGetAttribute( serverinfo_colorTag, "g" ) ) ) or defaultSettings.serverinfo_color.g
	settings.serverinfo_color.b = validateRange( tonumber( xmlNodeGetAttribute( serverinfo_colorTag, "b" ) ) ) or defaultSettings.serverinfo_color.b
	settings.serverinfo_color.a = validateRange( tonumber( xmlNodeGetAttribute( serverinfo_colorTag, "a" ) ) ) or defaultSettings.serverinfo_color.a
	
	settings.content_color.r = validateRange( tonumber( xmlNodeGetAttribute( content_colorTag, "r" ) ) ) or defaultSettings.content_color.r
	settings.content_color.g = validateRange( tonumber( xmlNodeGetAttribute( content_colorTag, "g" ) ) ) or defaultSettings.content_color.g
	settings.content_color.b = validateRange( tonumber( xmlNodeGetAttribute( content_colorTag, "b" ) ) ) or defaultSettings.content_color.b
	settings.content_color.a = validateRange( tonumber( xmlNodeGetAttribute( content_colorTag, "a" ) ) ) or defaultSettings.content_color.a
	
	xmlUnloadFile( settingsFile )
	useAnimation = settings.useanimation
	scoreboardIsToggleable = settings.toggleable
	showServerInfo = settings.showserverinfo
	showGamemodeInfo = settings.showgamemodeinfo
	showTeams = settings.showteams
	useColors = settings.usecolors
	drawSpeed = settings.drawspeed
	scoreboardScale = settings.scale
	columnFont = settings.columnfont
	contentFont = settings.contentfont
	teamHeaderFont = settings.teamfont
	serverInfoFont = settings.serverinfofont
	cScoreboardBackground = tocolor( settings.bg_color.r, settings.bg_color.g, settings.bg_color.b, settings.bg_color.a )
	cSelection = tocolor( settings.selection_color.r, settings.selection_color.g, settings.selection_color.b, settings.selection_color.a )
	cHighlight = tocolor( settings.highlight_color.r, settings.highlight_color.g, settings.highlight_color.b, settings.highlight_color.a )
	cHeader = tocolor( settings.header_color.r, settings.header_color.g, settings.header_color.b, settings.header_color.a )
	cTeam = tocolor( settings.team_color.r, settings.team_color.g, settings.team_color.b, settings.team_color.a )
	cBorder = tocolor( settings.border_color.r, settings.border_color.g, settings.border_color.b, settings.border_color.a )
	cServerInfo = tocolor( settings.serverinfo_color.r, settings.serverinfo_color.g, settings.serverinfo_color.b, settings.serverinfo_color.a )
	cContent = tocolor( settings.content_color.r, settings.content_color.g, settings.content_color.b, settings.content_color.a )
end

function createScoreboardSettingsWindow( posX, posY )
	if not windowSettings then
		windowSettings = guiCreateWindow( posX, posY, 323, 350, "Scoreboard settings", false )
		guiSetText( windowSettings, "Scoreboard settings" )
		guiWindowSetSizable( windowSettings, false )
		
		labelUseAnimation = guiCreateLabel( 10, 26, 64, 15, "Use animation:", false, windowSettings )
		guiSetFont( labelUseAnimation, "default-small" )
		checkAnimationYes = guiCreateCheckBox( 101, 26, 42, 14, "yes", false, false, windowSettings )
		checkAnimationNo = guiCreateCheckBox( 167, 26, 42, 14, "no", false, false, windowSettings )
		
		labelMode = guiCreateLabel( 10, 43, 64, 15, "Mode:", false, windowSettings )
		guiSetFont( labelMode, "default-small" )
		checkModeHolding = guiCreateCheckBox( 101, 43, 64, 14, "holding", false, false, windowSettings )
		checkModeToggled = guiCreateCheckBox( 167, 43, 64, 14, "toggled", false, false, windowSettings )
		
		labelShowInfoOf = guiCreateLabel( 10, 60, 64, 15, "Show info of:", false, windowSettings )
		guiSetFont( labelShowInfoOf, "default-small" )
		checkServerInfoServer = guiCreateCheckBox( 101, 60, 64, 14, "server", false, false, windowSettings )
		checkServerInfoGamemode = guiCreateCheckBox( 167, 60, 84, 14, "gamemode", false, false, windowSettings )
		
		labelShowTeams = guiCreateLabel( 10, 77, 64, 15, "Show teams:", false, windowSettings )
		guiSetFont( labelShowTeams, "default-small" )
		checkShowTeamsYes = guiCreateCheckBox( 101, 77, 64, 14, "yes", false, false, windowSettings )
		checkShowTeamsNo = guiCreateCheckBox( 167, 77, 84, 14, "no", false, false, windowSettings )
		
		labelUseColors = guiCreateLabel( 10, 94, 64, 15, "Use colors:", false, windowSettings )
		guiSetFont( labelUseColors, "default-small" )
		checkUseColorsYes = guiCreateCheckBox( 101, 94, 64, 14, "yes", false, false, windowSettings )
		checkUseColorsNo = guiCreateCheckBox( 167, 94, 84, 14, "no", false, false, windowSettings )
		
		labelDrawSpeed = guiCreateLabel( 10, 111, 64, 15, "Draw speed:", false, windowSettings )
		guiSetFont( labelDrawSpeed, "default-small" )
		scrollDrawSpeed = guiCreateScrollBar( 101, 111, 172, 14, true, false, windowSettings )
		
		labelScale = guiCreateLabel( 10, 128, 64, 15, "Scale:", false, windowSettings )
		guiSetFont( labelScale, "default-small" )
		scrollScale = guiCreateScrollBar( 101, 128, 172, 14, true, false, windowSettings )
		
		labelFonts = guiCreateLabel( 10, 145, 64, 15, "Fonts:", false, windowSettings )
		guiSetFont( labelFonts, "default-small" )
		buttonColumnFont = guiCreateButton( 101, 145, 87, 14, " ", false, windowSettings )
		buttonContentFont = guiCreateButton( 187, 145, 87, 14, " ", false, windowSettings )
		buttonTeamFont = guiCreateButton( 101, 162, 87, 14, " ", false, windowSettings )
		buttonServerInfoFont = guiCreateButton( 187, 162, 87, 14, " ", false, windowSettings )
		
		labelBackgroundColor = guiCreateLabel( 10, 179, 74, 12, "Background color:", false, windowSettings)
		guiSetFont( labelBackgroundColor, "default-small" )
		buttonChangeBackgroundColor = guiCreateButton( 187, 179, 87, 14, "Change", false, windowSettings )
		guiSetFont( buttonChangeBackgroundColor, "default-bold-small" )
		
		labelSelectionColor = guiCreateLabel( 10, 196, 74, 12, "Local player color:", false, windowSettings )
		guiSetFont( labelSelectionColor, "default-small" )
		buttonChangeSelectionColor = guiCreateButton( 187, 196, 87, 14, "Change", false, windowSettings )
		guiSetFont( buttonChangeSelectionColor, "default-bold-small" )
		
		labelHighlightColor = guiCreateLabel( 10, 213, 64, 12, "Selection color:", false, windowSettings )
		guiSetFont( labelHighlightColor, "default-small" )
		buttonChangeHighlightColor = guiCreateButton( 187, 213, 87, 14, "Change", false, windowSettings )
		guiSetFont( buttonChangeHighlightColor, "default-bold-small" )
		
		labelColumnHeaderColor = guiCreateLabel( 10, 230, 87, 12, "Column header color:", false, windowSettings )
		guiSetFont( labelColumnHeaderColor, "default-small" )
		buttonChangeColumnHeaderColor = guiCreateButton( 187, 230, 87, 14, "Change", false, windowSettings )
		guiSetFont( buttonChangeColumnHeaderColor, "default-bold-small" )
		
		labelTeamHeaderColor = guiCreateLabel( 10, 247, 85, 12, "Team header color:", false, windowSettings )
		guiSetFont( labelTeamHeaderColor, "default-small" )
		buttonChangeTeamHeaderColor = guiCreateButton( 187, 247, 87, 14, "Change", false, windowSettings )
		guiSetFont( buttonChangeTeamHeaderColor, "default-bold-small" )
		
		labelBorderlineColor = guiCreateLabel( 10, 264, 86, 12, "Border line color:", false, windowSettings )
		guiSetFont( labelBorderlineColor, "default-small" )
		buttonChangeBorderlineColor = guiCreateButton( 187, 264, 87, 14, "Change", false, windowSettings )
		guiSetFont( buttonChangeBorderlineColor, "default-bold-small" )
		
		labelServerInfoColor = guiCreateLabel( 10, 281, 86, 12, "Server info color:", false, windowSettings )
		guiSetFont( labelServerInfoColor, "default-small" )
		buttonChangeServerInfoColor = guiCreateButton( 187, 281, 87, 14, "Change", false, windowSettings )
		guiSetFont( buttonChangeServerInfoColor, "default-bold-small" )
		
		labelContentColor = guiCreateLabel( 10, 298, 86, 12, "Content color:", false, windowSettings )
		guiSetFont( labelContentColor, "default-small" )
		buttonChangeContentColor = guiCreateButton( 187, 298, 87, 14, "Change", false, windowSettings )
		guiSetFont( buttonChangeContentColor, "default-bold-small" )
		
		buttonSaveChanges = guiCreateButton( 10, 322, 80, 15, "Save changes", false, windowSettings )
		guiSetFont( buttonSaveChanges, "default-small" )
		buttonRestoreDefaults = guiCreateButton( 95, 322, 80, 15, "Restore defaults", false, windowSettings )
		guiSetFont( buttonRestoreDefaults, "default-small" )
		buttonCancel = guiCreateButton( 200, 322, 120, 15, "Cancel", false, windowSettings )
		guiSetFont( buttonCancel, "default-small" )
	end
	
	if type( settings.useanimation ) == "boolean" and not settings.useanimation then
		guiCheckBoxSetSelected( checkAnimationNo, true )
		guiCheckBoxSetSelected( checkAnimationYes, false )
	else
		guiCheckBoxSetSelected( checkAnimationNo, false )
		guiCheckBoxSetSelected( checkAnimationYes, true )
	end
	if type( settings.toggleable ) == "boolean" and settings.toggleable then
		guiCheckBoxSetSelected( checkModeToggled, true )
		guiCheckBoxSetSelected( checkModeHolding, false )
	else
		guiCheckBoxSetSelected( checkModeToggled, false )
		guiCheckBoxSetSelected( checkModeHolding, true )
	end
	if type( settings.showteams ) == "boolean" and not settings.showteams then
		guiCheckBoxSetSelected( checkShowTeamsNo, true )
		guiCheckBoxSetSelected( checkShowTeamsYes, false )
	else
		guiCheckBoxSetSelected( checkShowTeamsNo, false )
		guiCheckBoxSetSelected( checkShowTeamsYes, true )
	end
	if type( settings.usecolors ) == "boolean" and not settings.usecolors then
		guiCheckBoxSetSelected( checkUseColorsNo, true )
		guiCheckBoxSetSelected( checkUseColorsYes, false )
	else
		guiCheckBoxSetSelected( checkUseColorsNo, false )
		guiCheckBoxSetSelected( checkUseColorsYes, true )
	end
	guiCheckBoxSetSelected( checkServerInfoServer, settings.showserverinfo or defaultSettings.showserverinfo )
	guiCheckBoxSetSelected( checkServerInfoGamemode, settings.showgamemodeinfo or defaultSettings.showgamemodeinfo )
	
	guiScrollBarSetScrollPosition( scrollDrawSpeed, ((settings.drawspeed or defaultSettings.drawspeed)-MIN_DRAWSPEED)/(MAX_DRAWSPEED-MIN_DRAWSPEED)*100 )
	guiScrollBarSetScrollPosition( scrollScale, ((settings.scale or defaultSettings.scale)-MIN_SCALE)/(MAX_SCALE-MIN_SCALE)*100 )
	
	for k, v in ipairs( fontNames ) do
		if settings.columnfont == v then fontIndexes.column = k end
		if settings.contentfont == v then fontIndexes.content = k end
		if settings.teamfont == v then fontIndexes.team = k end
		if settings.serverinfofont == v then fontIndexes.serverinfo = k end
	end
	
	tempColors.bg_color.r = settings.bg_color.r or defaultSettings.bg_color.r
	tempColors.bg_color.g = settings.bg_color.g or defaultSettings.bg_color.g
	tempColors.bg_color.b = settings.bg_color.b or defaultSettings.bg_color.b
	tempColors.bg_color.a = settings.bg_color.a or defaultSettings.bg_color.a
	tempColors.selection_color.r = settings.selection_color.r or defaultSettings.selection_color.r
	tempColors.selection_color.g = settings.selection_color.g or defaultSettings.selection_color.g
	tempColors.selection_color.b = settings.selection_color.b or defaultSettings.selection_color.b
	tempColors.selection_color.a = settings.selection_color.a or defaultSettings.selection_color.a
	tempColors.highlight_color.r = settings.highlight_color.r or defaultSettings.highlight_color.r
	tempColors.highlight_color.g = settings.highlight_color.g or defaultSettings.highlight_color.g
	tempColors.highlight_color.b = settings.highlight_color.b or defaultSettings.highlight_color.b
	tempColors.highlight_color.a = settings.highlight_color.a or defaultSettings.highlight_color.a
	tempColors.header_color.r = settings.header_color.r or defaultSettings.header_color.r
	tempColors.header_color.g = settings.header_color.g or defaultSettings.header_color.g
	tempColors.header_color.b = settings.header_color.b or defaultSettings.header_color.b
	tempColors.header_color.a = settings.header_color.a or defaultSettings.header_color.a
	tempColors.team_color.r = settings.team_color.r or defaultSettings.team_color.r
	tempColors.team_color.g = settings.team_color.g or defaultSettings.team_color.g
	tempColors.team_color.b = settings.team_color.b or defaultSettings.team_color.b
	tempColors.team_color.a = settings.team_color.a or defaultSettings.team_color.a
	tempColors.border_color.r = settings.border_color.r or defaultSettings.border_color.r
	tempColors.border_color.g = settings.border_color.g or defaultSettings.border_color.g
	tempColors.border_color.b = settings.border_color.b or defaultSettings.border_color.b
	tempColors.border_color.a = settings.border_color.a or defaultSettings.border_color.a
	tempColors.serverinfo_color.r = settings.serverinfo_color.r or defaultSettings.serverinfo_color.r
	tempColors.serverinfo_color.g = settings.serverinfo_color.g or defaultSettings.serverinfo_color.g
	tempColors.serverinfo_color.b = settings.serverinfo_color.b or defaultSettings.serverinfo_color.b
	tempColors.serverinfo_color.a = settings.serverinfo_color.a or defaultSettings.serverinfo_color.a
	tempColors.content_color.r = settings.content_color.r or defaultSettings.content_color.r
	tempColors.content_color.g = settings.content_color.g or defaultSettings.content_color.g
	tempColors.content_color.b = settings.content_color.b or defaultSettings.content_color.b
	tempColors.content_color.a = settings.content_color.a or defaultSettings.content_color.a
	
	addEventHandler( "onClientGUIClick", windowSettings, settingsWindowClickHandler )
	addEventHandler( "onClientRender", getRootElement(), drawSettingsWindowColors )
end

function destroyScoreboardSettingsWindow()
	removeEventHandler( "onClientGUIClick", windowSettings, settingsWindowClickHandler )
	removeEventHandler( "onClientRender", getRootElement(), drawSettingsWindowColors )
	destroyElement( windowSettings )
	if not getKeyState( "mouse2" ) then
		showCursor( false )
	end
	colorPicker.closeSelect()
	windowSettings = nil
end

function settingsWindowClickHandler( button, state )
	if source == buttonSaveChanges then
		saveSettingsFromSettingsWindow()
	elseif source == buttonRestoreDefaults then
		restoreDefaultSettings()
	elseif source == buttonCancel then
		destroyScoreboardSettingsWindow()
	
	elseif source == buttonColumnFont then
		if fontIndexes.column + 1 > #fontNames then
			fontIndexes.column = 1
		else
			fontIndexes.column = fontIndexes.column + 1
		end
	elseif source == buttonContentFont then
		if fontIndexes.content + 1 > #fontNames then
			fontIndexes.content = 1
		else
			fontIndexes.content = fontIndexes.content + 1
		end
	elseif source == buttonTeamFont then
		if fontIndexes.team + 1 > #fontNames then
			fontIndexes.team = 1
		else
			fontIndexes.team = fontIndexes.team + 1
		end
	elseif source == buttonServerInfoFont then
		if fontIndexes.serverinfo + 1 > #fontNames then
			fontIndexes.serverinfo = 1
		else
			fontIndexes.serverinfo = fontIndexes.serverinfo + 1
		end
		
	elseif source == buttonChangeBackgroundColor then
		colorPicker.openSelect( "bg_color" )
	elseif source == buttonChangeSelectionColor then
		colorPicker.openSelect( "selection_color" )
	elseif source == buttonChangeHighlightColor then
		colorPicker.openSelect( "highlight_color" )
	elseif source == buttonChangeColumnHeaderColor then
		colorPicker.openSelect( "header_color" )
	elseif source == buttonChangeTeamHeaderColor then
		colorPicker.openSelect( "team_color" )
	elseif source == buttonChangeBorderlineColor then
		colorPicker.openSelect( "border_color" )
	elseif source == buttonChangeServerInfoColor then
		colorPicker.openSelect( "serverinfo_color" )
	elseif source == buttonChangeContentColor then
		colorPicker.openSelect( "content_color" )
		
	elseif source == checkAnimationNo or source == checkAnimationYes then
		guiCheckBoxSetSelected( checkAnimationYes, false )
		guiCheckBoxSetSelected( checkAnimationNo, false )
		guiCheckBoxSetSelected( source, true )
	elseif source == checkModeToggled or source == checkModeHolding then
		guiCheckBoxSetSelected( checkModeToggled, false )
		guiCheckBoxSetSelected( checkModeHolding, false )
		guiCheckBoxSetSelected( source, true )
	elseif source == checkShowTeamsNo or source == checkShowTeamsYes then
		guiCheckBoxSetSelected( checkShowTeamsYes, false )
		guiCheckBoxSetSelected( checkShowTeamsNo, false )
		guiCheckBoxSetSelected( source, true )
	elseif source == checkUseColorsNo or source == checkUseColorsYes then
		guiCheckBoxSetSelected( checkUseColorsYes, false )
		guiCheckBoxSetSelected( checkUseColorsNo, false )
		guiCheckBoxSetSelected( source, true )
	end
end

function drawSettingsWindowColors()
	local x, y = guiGetPosition( windowSettings, false )
	
	local drawSpeed = MIN_DRAWSPEED + ((guiScrollBarGetScrollPosition( scrollDrawSpeed )/100)*(MAX_DRAWSPEED-MIN_DRAWSPEED))
	dxDrawText( string.format( "%.2f", drawSpeed ), x+280, y+111, x+280+33, y+111+16, cWhite, 1, "default", "left", "top", true, false, true )
	
	local scale = MIN_SCALE + ((guiScrollBarGetScrollPosition( scrollScale )/100)*(MAX_SCALE-MIN_SCALE))
	dxDrawText( string.format( "%.2f", scale ), x+280, y+128, x+280+33, y+128+16, cWhite, 1, "default", "left", "top", true, false, true )
	
	dxDrawText( "Column", x+101, y+145, x+101+87, y+145+14, cWhite, fontscale( fontNames[fontIndexes.column], 1 ), fontNames[fontIndexes.column], "center", "center", true, false, true )
	dxDrawText( "Content", x+187, y+145, x+187+87, y+145+14, cWhite, fontscale( fontNames[fontIndexes.content], 1 ), fontNames[fontIndexes.content], "center", "center", true, false, true )
	dxDrawText( "Team", x+101, y+162, x+101+87, y+162+14, cWhite, fontscale( fontNames[fontIndexes.team], 1 ), fontNames[fontIndexes.team], "center", "center", true, false, true )
	dxDrawText( "Server info", x+187, y+162, x+187+87, y+162+14, cWhite, fontscale( fontNames[fontIndexes.serverinfo], 1 ), fontNames[fontIndexes.serverinfo], "center", "center", true, false, true )
	
	if tempColors.bg_color.r and tempColors.bg_color.g and tempColors.bg_color.b and tempColors.bg_color.a then
		dxDrawRectangle( x+101, y+179, 84, 16, tocolor( tempColors.bg_color.r, tempColors.bg_color.g, tempColors.bg_color.b, tempColors.bg_color.a ), true )
	end
	if tempColors.selection_color.r and tempColors.selection_color.g and tempColors.selection_color.b and tempColors.selection_color.a then
		dxDrawRectangle( x+101, y+196, 84, 16, tocolor( tempColors.selection_color.r, tempColors.selection_color.g, tempColors.selection_color.b, tempColors.selection_color.a ), true )
	end
	if tempColors.highlight_color.r and tempColors.highlight_color.g and tempColors.highlight_color.b and tempColors.highlight_color.a then
		dxDrawRectangle( x+101, y+213, 84, 16, tocolor( tempColors.highlight_color.r, tempColors.highlight_color.g, tempColors.highlight_color.b, tempColors.highlight_color.a ), true )
	end
	if tempColors.header_color.r and tempColors.header_color.g and tempColors.header_color.b and tempColors.header_color.a then
		dxDrawRectangle( x+101, y+230, 84, 16, tocolor( tempColors.header_color.r, tempColors.header_color.g, tempColors.header_color.b, tempColors.header_color.a ), true )
	end
	if tempColors.team_color.r and tempColors.team_color.g and tempColors.team_color.b and tempColors.team_color.a then
		dxDrawRectangle( x+101, y+247, 84, 16, tocolor( tempColors.team_color.r, tempColors.team_color.g, tempColors.team_color.b, tempColors.team_color.a ), true )
	end
	if tempColors.border_color.r and tempColors.border_color.g and tempColors.border_color.b and tempColors.border_color.a then
		dxDrawRectangle( x+101, y+264, 84, 16, tocolor( tempColors.border_color.r, tempColors.border_color.g, tempColors.border_color.b, tempColors.border_color.a ), true )
	end
	if tempColors.serverinfo_color.r and tempColors.serverinfo_color.g and tempColors.serverinfo_color.b and tempColors.serverinfo_color.a then
		dxDrawRectangle( x+101, y+281, 84, 16, tocolor( tempColors.serverinfo_color.r, tempColors.serverinfo_color.g, tempColors.serverinfo_color.b, tempColors.serverinfo_color.a ), true )
	end
	if tempColors.content_color.r and tempColors.content_color.g and tempColors.content_color.b and tempColors.content_color.a then
		dxDrawRectangle( x+101, y+298, 84, 16, tocolor( tempColors.content_color.r, tempColors.content_color.g, tempColors.content_color.b, tempColors.content_color.a ), true )
	end
end

function saveSettingsFromSettingsWindow()
	local userSettings = {
		["useanimation"] = nil,
		["toggleable"] = nil,
		["showserverinfo"] = nil,
		["showgamemodeinfo"] = nil,
		["showteams"] = nil,
		["usecolors"] = nil,
		["drawspeed"] = nil,
		["scale"] = nil,
		["columnfont"] = nil,
		["contentfont"] = nil,
		["teamfont"] = nil,
		["serverinfofont"] = nil,
		["bg_color"] = {},
		["selection_color"] = {},
		["highlight_color"] = {},
		["header_color"] = {},
		["team_color"] = {},
		["border_color"] = {},
		["serverinfo_color"] = {},
		["content_color"] = {}
	}
	
	userSettings.useanimation = iif( guiCheckBoxGetSelected( checkAnimationNo ), false, true )
	userSettings.toggleable = iif( guiCheckBoxGetSelected( checkModeToggled ), true, false )
	userSettings.showteams = iif( guiCheckBoxGetSelected( checkShowTeamsNo ), false, true )
	userSettings.usecolors = iif( guiCheckBoxGetSelected( checkUseColorsNo ), false, true )
	userSettings.showserverinfo = guiCheckBoxGetSelected( checkServerInfoServer )
	userSettings.showgamemodeinfo = guiCheckBoxGetSelected( checkServerInfoGamemode )
	
	userSettings.drawspeed = string.format( "%.2f", MIN_DRAWSPEED + ( (guiScrollBarGetScrollPosition( scrollDrawSpeed )/100)*(MAX_DRAWSPEED-MIN_DRAWSPEED) ) )
	userSettings.drawspeed = tonumber( userSettings.drawspeed )
	
	userSettings.scale = string.format( "%.2f", MIN_SCALE + ( (guiScrollBarGetScrollPosition( scrollScale )/100)*(MAX_SCALE-MIN_SCALE) ) )
	userSettings.scale = tonumber( userSettings.scale )
	
	userSettings.columnfont = fontNames[fontIndexes.column]
	userSettings.contentfont = fontNames[fontIndexes.content]
	userSettings.teamfont = fontNames[fontIndexes.team]
	userSettings.serverinfofont = fontNames[fontIndexes.serverinfo]
	
	userSettings.bg_color.r = tempColors.bg_color.r or defaultSettings.bg_color.r
	userSettings.bg_color.g = tempColors.bg_color.g or defaultSettings.bg_color.g
	userSettings.bg_color.b = tempColors.bg_color.b or defaultSettings.bg_color.b
	userSettings.bg_color.a = tempColors.bg_color.a or defaultSettings.bg_color.a
	
	userSettings.selection_color.r = tempColors.selection_color.r or defaultSettings.selection_color.r
	userSettings.selection_color.g = tempColors.selection_color.g or defaultSettings.selection_color.g
	userSettings.selection_color.b = tempColors.selection_color.b or defaultSettings.selection_color.b
	userSettings.selection_color.a = tempColors.selection_color.a or defaultSettings.selection_color.a
	
	userSettings.highlight_color.r = tempColors.highlight_color.r or defaultSettings.highlight_color.r
	userSettings.highlight_color.g = tempColors.highlight_color.g or defaultSettings.highlight_color.g
	userSettings.highlight_color.b = tempColors.highlight_color.b or defaultSettings.highlight_color.b
	userSettings.highlight_color.a = tempColors.highlight_color.a or defaultSettings.highlight_color.a
	
	userSettings.header_color.r = tempColors.header_color.r or defaultSettings.header_color.r
	userSettings.header_color.g = tempColors.header_color.g or defaultSettings.header_color.g
	userSettings.header_color.b = tempColors.header_color.b or defaultSettings.header_color.b
	userSettings.header_color.a = tempColors.header_color.a or defaultSettings.header_color.a
	
	userSettings.team_color.r = tempColors.team_color.r or defaultSettings.team_color.r
	userSettings.team_color.g = tempColors.team_color.g or defaultSettings.team_color.g
	userSettings.team_color.b = tempColors.team_color.b or defaultSettings.team_color.b
	userSettings.team_color.a = tempColors.team_color.a or defaultSettings.team_color.a
	
	userSettings.border_color.r = tempColors.border_color.r or defaultSettings.border_color.r
	userSettings.border_color.g = tempColors.border_color.g or defaultSettings.border_color.g
	userSettings.border_color.b = tempColors.border_color.b or defaultSettings.border_color.b
	userSettings.border_color.a = tempColors.border_color.a or defaultSettings.border_color.a

	userSettings.serverinfo_color.r = tempColors.serverinfo_color.r or defaultSettings.serverinfo_color.r
	userSettings.serverinfo_color.g = tempColors.serverinfo_color.g or defaultSettings.serverinfo_color.g
	userSettings.serverinfo_color.b = tempColors.serverinfo_color.b or defaultSettings.serverinfo_color.b
	userSettings.serverinfo_color.a = tempColors.serverinfo_color.a or defaultSettings.serverinfo_color.a
	
	userSettings.content_color.r = tempColors.content_color.r or defaultSettings.content_color.r
	userSettings.content_color.g = tempColors.content_color.g or defaultSettings.content_color.g
	userSettings.content_color.b = tempColors.content_color.b or defaultSettings.content_color.b
	userSettings.content_color.a = tempColors.content_color.a or defaultSettings.content_color.a
	
	saveSettings( userSettings )
end

function restoreDefaultSettings()
	saveSettings( defaultSettings )
end

function saveSettings( settingsTable )
	local settingsFile = xmlLoadFile( "settings.xml" )
	if not settingsFile then
		settingsFile = xmlCreateFile( "settings.xml", "settings" )
		if not settingsFile then return false end
		local useanimationTag = xmlCreateChild( settingsFile, "useanimation" )
		local toggleableTag = xmlCreateChild( settingsFile, "toggleable" )
		local showserverinfoTag = xmlCreateChild( settingsFile, "showserverinfo" )
		local showgamemodeinfoTag = xmlCreateChild( settingsFile, "showgamemodeinfo" )
		local showteamsTag = xmlCreateChild( settingsFile, "showteams" )
		local usecolorsTag = xmlCreateChild( settingsFile, "usecolors" )
		local drawspeedTag = xmlCreateChild( settingsFile, "drawspeed" )
		local scaleTag = xmlCreateChild( settingsFile, "scale" )
		local columnfontTag = xmlCreateChild( settingsFile, "columnfont" )
		local contentfontTag = xmlCreateChild( settingsFile, "contentfont" )
		local teamfontTag = xmlCreateChild( settingsFile, "teamfont" )
		local serverinfofontTag = xmlCreateChild( settingsFile, "serverinfofont" )
		local bg_colorTag = xmlCreateChild( settingsFile, "bg_color" )
		local selection_colorTag = xmlCreateChild( settingsFile, "selection_color" )
		local highlight_colorTag = xmlCreateChild( settingsFile, "highlight_color" )
		local header_colorTag = xmlCreateChild( settingsFile, "header_color" )
		local team_colorTag = xmlCreateChild( settingsFile, "team_color" )
		local border_colorTag = xmlCreateChild( settingsFile, "border_color" )
		local serverinfo_colorTag = xmlCreateChild( settingsFile, "serverinfo_color" )
		local content_colorTag = xmlCreateChild( settingsFile, "content_color" )
	end
	
	local useanimationTag = xmlFindChild( settingsFile, "useanimation", 0 )
	if not useanimationTag then
		useanimationTag = xmlCreateChild( settingsFile, "useanimation" )
	end
	
	local toggleableTag = xmlFindChild( settingsFile, "toggleable", 0 )
	if not toggleableTag then
		toggleableTag = xmlCreateChild( settingsFile, "toggleable" )
	end
	
	local showserverinfoTag = xmlFindChild( settingsFile, "showserverinfo", 0 )
	if not showserverinfoTag then
		showserverinfoTag = xmlCreateChild( settingsFile, "showserverinfo" )
	end

	local showgamemodeinfoTag = xmlFindChild( settingsFile, "showgamemodeinfo", 0 )
	if not showgamemodeinfoTag then
		showgamemodeinfoTag = xmlCreateChild( settingsFile, "showgamemodeinfo" )
	end
	
	local showteamsTag = xmlFindChild( settingsFile, "showteams", 0 )
	if not showteamsTag then
		showteamsTag = xmlCreateChild( settingsFile, "showteams" )
	end
	
	local usecolorsTag = xmlFindChild( settingsFile, "usecolors", 0 )
	if not usecolorsTag then
		usecolorsTag = xmlCreateChild( settingsFile, "usecolors" )
	end
	
	local drawspeedTag = xmlFindChild( settingsFile, "drawspeed", 0 )
	if not drawspeedTag then
		drawspeedTag = xmlCreateChild( settingsFile, "drawspeed" )
	end
	
	local scaleTag = xmlFindChild( settingsFile, "scale", 0 )
	if not scaleTag then
		scaleTag = xmlCreateChild( settingsFile, "scale" )
	end
	
	local columnfontTag = xmlFindChild( settingsFile, "columnfont", 0 )
	if not columnfontTag then
		columnfontTag = xmlCreateChild( settingsFile, "columnfont" )
	end
	
	local contentfontTag = xmlFindChild( settingsFile, "contentfont", 0 )
	if not contentfontTag then
		contentfontTag = xmlCreateChild( settingsFile, "contentfont" )
	end
	
	local teamfontTag = xmlFindChild( settingsFile, "teamfont", 0 )
	if not teamfontTag then
		teamfontTag = xmlCreateChild( settingsFile, "teamfont" )
	end
	
	local serverinfofontTag = xmlFindChild( settingsFile, "serverinfofont", 0 )
	if not serverinfofontTag then
		serverinfofontTag = xmlCreateChild( settingsFile, "serverinfofont" )
	end
	
	local bg_colorTag = xmlFindChild( settingsFile, "bg_color", 0 )
	if not bg_colorTag then
		bg_colorTag = xmlCreateChild( settingsFile, "bg_color" )
	end
	
	local selection_colorTag = xmlFindChild( settingsFile, "selection_color", 0 )
	if not selection_colorTag then
		selection_colorTag = xmlCreateChild( settingsFile, "selection_color" )
	end
	
	local highlight_colorTag = xmlFindChild( settingsFile, "highlight_color", 0 )
	if not highlight_colorTag then
		highlight_colorTag = xmlCreateChild( settingsFile, "highlight_color" )
	end
	
	local header_colorTag = xmlFindChild( settingsFile, "header_color", 0 )
	if not header_colorTag then
		header_colorTag = xmlCreateChild( settingsFile, "header_color" )
	end
	
	local team_colorTag = xmlFindChild( settingsFile, "team_color", 0 )
	if not team_colorTag then
		team_colorTag = xmlCreateChild( settingsFile, "team_color" )
	end
	
	local border_colorTag = xmlFindChild( settingsFile, "border_color", 0 )
	if not border_colorTag then
		border_colorTag = xmlCreateChild( settingsFile, "border_color" )
	end
	
	local serverinfo_colorTag = xmlFindChild( settingsFile, "serverinfo_color", 0 )
	if not serverinfo_colorTag then
		serverinfo_colorTag = xmlCreateChild( settingsFile, "serverinfo_color" )
	end
	
	local content_colorTag = xmlFindChild( settingsFile, "content_color", 0 )
	if not content_colorTag then
		content_colorTag = xmlCreateChild( settingsFile, "content_color" )
	end
	
	xmlNodeSetValue( useanimationTag, tostring( settingsTable.useanimation ) )
	xmlNodeSetValue( toggleableTag, tostring( settingsTable.toggleable ) )
	xmlNodeSetValue( showserverinfoTag, tostring( settingsTable.showserverinfo ) )
	xmlNodeSetValue( showgamemodeinfoTag, tostring( settingsTable.showgamemodeinfo ) )
	xmlNodeSetValue( showteamsTag, tostring( settingsTable.showteams ) )
	xmlNodeSetValue( usecolorsTag, tostring( settingsTable.usecolors ) )
	xmlNodeSetValue( drawspeedTag, tostring( settingsTable.drawspeed ) )
	xmlNodeSetValue( scaleTag, tostring( settingsTable.scale ) )
	
	xmlNodeSetValue( columnfontTag, tostring( settingsTable.columnfont ) )
	xmlNodeSetValue( contentfontTag, tostring( settingsTable.contentfont ) )
	xmlNodeSetValue( teamfontTag, tostring( settingsTable.teamfont ) )
	xmlNodeSetValue( serverinfofontTag, tostring( settingsTable.serverinfofont ) )
	
	xmlNodeSetAttribute( bg_colorTag, "r", tostring( settingsTable.bg_color.r ) )
	xmlNodeSetAttribute( bg_colorTag, "g", tostring( settingsTable.bg_color.g ) )
	xmlNodeSetAttribute( bg_colorTag, "b", tostring( settingsTable.bg_color.b ) )
	xmlNodeSetAttribute( bg_colorTag, "a", tostring( settingsTable.bg_color.a ) )
	
	xmlNodeSetAttribute( selection_colorTag, "r", tostring( settingsTable.selection_color.r ) )
	xmlNodeSetAttribute( selection_colorTag, "g", tostring( settingsTable.selection_color.g ) )
	xmlNodeSetAttribute( selection_colorTag, "b", tostring( settingsTable.selection_color.b ) )
	xmlNodeSetAttribute( selection_colorTag, "a", tostring( settingsTable.selection_color.a ) )
	
	xmlNodeSetAttribute( highlight_colorTag, "r", tostring( settingsTable.highlight_color.r ) )
	xmlNodeSetAttribute( highlight_colorTag, "g", tostring( settingsTable.highlight_color.g ) )
	xmlNodeSetAttribute( highlight_colorTag, "b", tostring( settingsTable.highlight_color.b ) )
	xmlNodeSetAttribute( highlight_colorTag, "a", tostring( settingsTable.highlight_color.a ) )
	
	xmlNodeSetAttribute( header_colorTag, "r", tostring( settingsTable.header_color.r ) )
	xmlNodeSetAttribute( header_colorTag, "g", tostring( settingsTable.header_color.g ) )
	xmlNodeSetAttribute( header_colorTag, "b", tostring( settingsTable.header_color.b ) )
	xmlNodeSetAttribute( header_colorTag, "a", tostring( settingsTable.header_color.a ) )
	
	xmlNodeSetAttribute( team_colorTag, "r", tostring( settingsTable.team_color.r ) )
	xmlNodeSetAttribute( team_colorTag, "g", tostring( settingsTable.team_color.g ) )
	xmlNodeSetAttribute( team_colorTag, "b", tostring( settingsTable.team_color.b ) )
	xmlNodeSetAttribute( team_colorTag, "a", tostring( settingsTable.team_color.a ) )
	
	xmlNodeSetAttribute( border_colorTag, "r", tostring( settingsTable.border_color.r ) )
	xmlNodeSetAttribute( border_colorTag, "g", tostring( settingsTable.border_color.g ) )
	xmlNodeSetAttribute( border_colorTag, "b", tostring( settingsTable.border_color.b ) )
	xmlNodeSetAttribute( border_colorTag, "a", tostring( settingsTable.border_color.a ) )
	
	xmlNodeSetAttribute( serverinfo_colorTag, "r", tostring( settingsTable.serverinfo_color.r ) )
	xmlNodeSetAttribute( serverinfo_colorTag, "g", tostring( settingsTable.serverinfo_color.g ) )
	xmlNodeSetAttribute( serverinfo_colorTag, "b", tostring( settingsTable.serverinfo_color.b ) )
	xmlNodeSetAttribute( serverinfo_colorTag, "a", tostring( settingsTable.serverinfo_color.a ) )
	
	xmlNodeSetAttribute( content_colorTag, "r", tostring( settingsTable.content_color.r ) )
	xmlNodeSetAttribute( content_colorTag, "g", tostring( settingsTable.content_color.g ) )
	xmlNodeSetAttribute( content_colorTag, "b", tostring( settingsTable.content_color.b ) )
	xmlNodeSetAttribute( content_colorTag, "a", tostring( settingsTable.content_color.a ) )
	
	xmlSaveFile( settingsFile )
	xmlUnloadFile( settingsFile )
	destroyScoreboardSettingsWindow()
	readScoreboardSettings()
end

function validateRange( number )
	if type( number ) == "number" then
		local isValid = number >= 0 and number <= 255
		if isValid then
			return number
		end
	end
	return false
end
