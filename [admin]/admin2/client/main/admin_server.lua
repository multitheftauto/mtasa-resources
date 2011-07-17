--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\main\admin_server.lua
*
*	Original File by lil_Toady
*
**************************************]]

aServerTab = {
	Weathers = {},
	WeatherMax = 255
}

function aServerTab.Create ( tab )
	aServerTab.Tab = tab

						  guiCreateHeader ( 0.02, 0.015, 0.30, 0.035, "Server info:", true, aServerTab.Tab )
	aServerTab.Server			= guiCreateLabel ( 0.03, 0.060, 0.40, 0.035, "Server: Unknown", true, aServerTab.Tab )
	aServerTab.Password		= guiCreateLabel ( 0.03, 0.105, 0.40, 0.035, "Password: None", true, aServerTab.Tab )
	aServerTab.GameType		= guiCreateLabel ( 0.03, 0.150, 0.40, 0.035, "Game Type: None", true, aServerTab.Tab )
	aServerTab.MapName		= guiCreateLabel ( 0.03, 0.195, 0.40, 0.035, "Map Name: None", true, aServerTab.Tab )
	aServerTab.Players		= guiCreateLabel ( 0.03, 0.240, 0.20, 0.035, "Players: 0/0", true, aServerTab.Tab )
	aServerTab.SetPassword		= guiCreateButton ( 0.42, 0.060, 0.18, 0.04, "Set Password", true, aServerTab.Tab, "setpassword" )
	aServerTab.ResetPassword	= guiCreateButton ( 0.42, 0.105, 0.18, 0.04, "Reset Password", true, aServerTab.Tab, "setpassword" )
	aServerTab.SetGameType		= guiCreateButton ( 0.42, 0.150, 0.18, 0.04, "Set Game Type", true, aServerTab.Tab, "setgame" )
	aServerTab.SetMapName		= guiCreateButton ( 0.42, 0.195, 0.18, 0.04, "Set Map Name", true, aServerTab.Tab, "setmap" )
	aServerTab.Shutdown		= guiCreateButton ( 0.42, 0.240, 0.18, 0.04, "Shutdown", true, aServerTab.Tab, "shutdown" )
					  	  guiCreateHeader ( 0.02, 0.285, 0.30, 0.035, "Server properties:", true, aServerTab.Tab )
	aServerTab.WeatherCurrent	= guiCreateLabel ( 0.03, 0.330, 0.45, 0.035, "Current Weather: "..getWeather().." ("..getWeatherNameFromID ( getWeather() )..")", true, aServerTab.Tab )
	--aServerTab.WeatherDec		= guiCreateButton ( 0.05, 0.40, 0.035, 0.04, "<", true, aServerTab.Tab )
	aServerTab.Weather		= guiCreateEdit ( 0.35, 0.330, 0.25, 0.04, "", true, aServerTab.Tab )
	--aServerTab.WeatherInc		= guiCreateButton ( 0.45, 0.40, 0.035, 0.04, ">", true, aServerTab.Tab )
					  	  guiEditSetReadOnly ( aServerTab.Weather, true )
	aServerTab.WeatherSet		= guiCreateButton ( 0.50, 0.375, 0.10, 0.04, "Set", true, aServerTab.Tab, "setweather" )
	aServerTab.WeatherBlend		= guiCreateButton ( 0.35, 0.375, 0.135, 0.04, "Blend", true, aServerTab.Tab, "blendweather" )

					  	  local th, tm = getTime()
	aServerTab.TimeCurrent		= guiCreateLabel ( 0.03, 0.420, 0.25, 0.035, "Time: "..th..":"..tm, true, aServerTab.Tab )
	aServerTab.TimeH			= guiCreateEdit ( 0.35, 0.420, 0.055, 0.04, "12", true, aServerTab.Tab )
	aServerTab.TimeM			= guiCreateEdit ( 0.425, 0.420, 0.055, 0.04, "00", true, aServerTab.Tab )
					  	  guiCreateLabel ( 0.415, 0.420, 0.05, 0.04, ":", true, aServerTab.Tab )
					  	  guiEditSetMaxLength ( aServerTab.TimeH, 2 )
					  	  guiEditSetMaxLength ( aServerTab.TimeM, 2 )
	aServerTab.TimeSet		= guiCreateButton ( 0.50, 0.420, 0.10, 0.04, "Set", true, aServerTab.Tab, "settime" )

	aServerTab.GravityCurrent	= guiCreateLabel ( 0.03, 0.465, 0.28, 0.035, "Gravitation: "..string.sub ( getGravity(), 0, 6 ), true, aServerTab.Tab )
	aServerTab.Gravity		= guiCreateEdit ( 0.35, 0.465, 0.135, 0.04, "0.008", true, aServerTab.Tab )
	aServerTab.GravitySet		= guiCreateButton ( 0.50, 0.465, 0.10, 0.04, "Set", true, aServerTab.Tab, "setgravity" )

	aServerTab.SpeedCurrent		= guiCreateLabel ( 0.03, 0.510, 0.30, 0.035, "Game Speed: "..getGameSpeed(), true, aServerTab.Tab )
	aServerTab.Speed			= guiCreateEdit ( 0.35, 0.510, 0.135, 0.04, "1", true, aServerTab.Tab )
	aServerTab.SpeedSet		= guiCreateButton ( 0.50, 0.510, 0.10, 0.04, "Set", true, aServerTab.Tab, "setgamespeed" )

	aServerTab.BlurCurrent		= guiCreateLabel ( 0.03, 0.555, 0.25, 0.035, "Blur Level: 36", true, aServerTab.Tab )
	aServerTab.Blur			= guiCreateEdit ( 0.35, 0.555, 0.135, 0.04, "36", true, aServerTab.Tab )
	aServerTab.BlurSet		= guiCreateButton ( 0.50, 0.555, 0.10, 0.04, "Set", true, aServerTab.Tab, "setblurlevel" )

	aServerTab.WavesCurrent		= guiCreateLabel ( 0.03, 0.600, 0.25, 0.035, "Wave Height: "..getWaveHeight(), true, aServerTab.Tab )
	aServerTab.Waves			= guiCreateEdit ( 0.35, 0.600, 0.135, 0.04, "0", true, aServerTab.Tab )
	aServerTab.WavesSet		= guiCreateButton ( 0.50, 0.600, 0.10, 0.04, "Set", true, aServerTab.Tab, "setwaveheight" )

	aServerTab.FPSCurrent		= guiCreateLabel ( 0.03, 0.645, 0.25, 0.035, "FPS Limit: 36", true, aServerTab.Tab )
	aServerTab.FPS			= guiCreateEdit ( 0.35, 0.645, 0.135, 0.04, "0", true, aServerTab.Tab )
	aServerTab.FPSSet			= guiCreateButton ( 0.50, 0.645, 0.10, 0.04, "Set", true, aServerTab.Tab, "setwaveheight" )

						  guiCreateHeader ( 0.02, 0.690, 0.30, 0.035, "Automatic scripts:", true, aServerTab.Tab )
	aServerTab.PingKickerCheck	= guiCreateCheckBox ( 0.03, 0.735, 0.30, 0.04, "Ping Kicker", false, true, aServerTab.Tab )
	aServerTab.PingKicker		= guiCreateEdit ( 0.35, 0.735, 0.135, 0.04, "300", true, aServerTab.Tab )
	aServerTab.PingKickerSet	= guiCreateButton ( 0.50, 0.735, 0.10, 0.04, "Set", true, aServerTab.Tab, "setwaveheight" )
						  guiSetEnabled ( aServerTab.PingKicker, false )
						  guiSetEnabled ( aServerTab.PingKickerSet, false )

	aServerTab.FPSKickerCheck	= guiCreateCheckBox ( 0.03, 0.780, 0.30, 0.04, "FPS Kicker", false, true, aServerTab.Tab )
	aServerTab.FPSKicker		= guiCreateEdit ( 0.35, 0.780, 0.135, 0.04, "5", true, aServerTab.Tab )
	aServerTab.FPSKickerSet		= guiCreateButton ( 0.50, 0.780, 0.10, 0.04, "Set", true, aServerTab.Tab, "setwaveheight" )
						  guiSetEnabled ( aServerTab.FPSKicker, false )
						  guiSetEnabled ( aServerTab.FPSKickerSet, false )

	aServerTab.CapsKickerCheck	= guiCreateCheckBox ( 0.03, 0.825, 0.30, 0.04, "CAPS Kicker", false, true, aServerTab.Tab )
	aServerTab.CapsKicker		= guiCreateEdit ( 0.35, 0.825, 0.135, 0.04, "70", true, aServerTab.Tab )
	aServerTab.CapsKickerSet	= guiCreateButton ( 0.50, 0.825, 0.10, 0.04, "Set", true, aServerTab.Tab, "setwaveheight" )
						  guiSetEnabled ( aServerTab.CapsKicker, false )
						  guiSetEnabled ( aServerTab.CapsKickerSet, false )

	aServerTab.IdleKickerCheck	= guiCreateCheckBox ( 0.03, 0.870, 0.30, 0.04, "Idle Kicker", false, true, aServerTab.Tab )
	aServerTab.IdleKicker		= guiCreateEdit ( 0.35, 0.870, 0.135, 0.04, "10", true, aServerTab.Tab )
	aServerTab.IdleKickerSet	= guiCreateButton ( 0.50, 0.870, 0.10, 0.04, "Set", true, aServerTab.Tab, "setwaveheight" )
						  guiSetEnabled ( aServerTab.IdleKicker, false )
						  guiSetEnabled ( aServerTab.IdleKickerSet, false )

						  guiCreateHeader ( 0.65, 0.015, 0.30, 0.035, "Welcome message:", true, aServerTab.Tab )
	aServerTab.WelcomeCheck		= guiCreateCheckBox ( 0.66, 0.105, 0.20, 0.04, "Enabled", false, true, aServerTab.Tab, "setwelcome" )
	aServerTab.Welcome		= guiCreateEdit ( 0.66, 0.060, 0.31, 0.04, "", true, aServerTab.Tab, "setwelcome" )
	aServerTab.WelcomeSet		= guiCreateButton ( 0.87, 0.105, 0.10, 0.04, "Save", true, aServerTab.Tab, "setwaveheight" )

						  guiCreateHeader ( 0.65, 0.285, 0.30, 0.035, "Allowed glitches:", true, aServerTab.Tab )
	aServerTab.QuickReload		= guiCreateCheckBox ( 0.66, 0.330, 0.20, 0.04, "Quick Reload", false, true, aServerTab.Tab, "setwelcome" )
	aServerTab.FastMove		= guiCreateCheckBox ( 0.66, 0.375, 0.20, 0.04, "Fast Move", false, true, aServerTab.Tab, "setwelcome" )
	aServerTab.FastFire		= guiCreateCheckBox ( 0.66, 0.420, 0.20, 0.04, "Fast Fire", false, true, aServerTab.Tab, "setwelcome" )

	addEventHandler ( "onClientGUIClick", aServerTab.Tab, aServerTab.onClientClick )
	addEventHandler ( "aClientSync", _root, aServerTab.onClientSync )
	addEventHandler ( "onAdminRefresh", _root, aServerTab.onRefresh )

	local node = xmlLoadFile ( "conf\\weathers.xml" )
	if ( node ) then
		local weathers = 0
		while ( true ) do
			local weather = xmlFindChild ( node, "weather", weathers )
			if ( not weather ) then break end
			local id = tonumber ( xmlNodeGetAttribute ( weather, "id" ) )
			local name = xmlNodeGetAttribute ( weather, "name" )
			aServerTab.Weathers[id] = name
			weathers = weathers + 1
		end
	end

	triggerServerEvent ( "aSync", getLocalPlayer(), "server" )

	aServerTab.onRefresh ()
end

function aServerTab.onClientClick ( button )
	if ( button == "left" ) then
		if ( source == aServerTab.SetGameType ) then aInputBox ( "Game Type", "Enter game type:", "", "triggerServerEvent ( \"aServer\", getLocalPlayer(), \"setgame\", $value )" )
		elseif ( source == aServerTab.SetMapName ) then aInputBox ( "Map Name", "Enter map name:", "", "triggerServerEvent ( \"aServer\", getLocalPlayer(), \"setmap\", $value )" )
		elseif ( source == aServerTab.SetWelcome ) then aInputBox ( "Welcome Message", "Enter the server welcome message:", "", "triggerServerEvent ( \"aServer\", getLocalPlayer(), \"setwelcome\", $value )" )
		elseif ( source == aServerTab.SetPassword ) then aInputBox ( "Server password", "Enter server password: (32 characters max)", "", "triggerServerEvent ( \"aServer\", getLocalPlayer(), \"setpassword\", $value )" )
		elseif ( source == aServerTab.ResetPassword ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setpassword", "" )
		elseif ( ( source == aServerTab.WeatherInc ) or ( source == aServerTab.WeatherDec ) ) then
			local id = tonumber ( gettok ( guiGetText ( aServerTab.Weather ), 1, 32 ) )
			if ( id ) then
				if ( ( source == aServerTab.WeatherInc ) and ( id < _weathers_max ) ) then guiSetText ( aServerTab.Weather, ( id + 1 ).." ("..getWeatherNameFromID ( id + 1 )..")" )
				elseif ( ( source == aServerTab.WeatherDec ) and ( id > 0 ) ) then guiSetText ( aServerTab.Weather, ( id - 1 ).." ("..getWeatherNameFromID ( id - 1 )..")" ) end
			else
				guiSetText ( aServerTab.Weather, ( 14 ).." ("..getWeatherNameFromID ( 14 )..")" ) 
			end
		elseif ( source == aServerTab.WeatherSet ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setweather", gettok ( guiGetText ( aServerTab.Weather ), 1, 32 ) )
		elseif ( source == aServerTab.WeatherBlend ) then triggerServerEvent ( "aServer", getLocalPlayer(), "blendweather", gettok ( guiGetText ( aServerTab.Weather ), 1, 32 ) )
		elseif ( source == aServerTab.TimeSet ) then triggerServerEvent ( "aServer", getLocalPlayer(), "settime", guiGetText ( aServerTab.TimeH ), guiGetText ( aServerTab.TimeM ) )
		elseif ( ( source == aServerTab.SpeedInc ) or ( source == aServerTab.SpeedDec ) ) then
			local value = tonumber ( guiGetText ( aServerTab.Speed ) )
			if ( value ) then
				if ( ( source == aServerTab.SpeedInc ) and ( value < 10 ) ) then guiSetText ( aServerTab.Speed, tostring ( value + 1 ) )
				elseif ( ( source == aServerTab.SpeedDec ) and ( value > 0 ) ) then guiSetText ( aServerTab.Speed, tostring ( value - 1 ) ) end
			else
				guiSetText ( aServerTab.Speed, "1" ) 
			end
		elseif ( source == aServerTab.SpeedSet ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setgamespeed", guiGetText ( aServerTab.Speed ) )
		elseif ( source == aServerTab.GravitySet ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setgravity", guiGetText ( aServerTab.Gravity ) )
		elseif ( source == aServerTab.WavesSet ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setwaveheight", guiGetText ( aServerTab.Waves ) )
		elseif ( source == aServerTab.BlurSet ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setblurlevel", guiGetText ( aServerTab.Blur ) )
		end
	end
end

function aServerTab.onClientSync ( type, table )
	if ( type == "server" ) then
		guiSetText ( aServerTab.Server, "Server: "..table["name"] )
		guiSetText ( aServerTab.Players, "Players: "..#getElementsByType ( "player" ).."/"..table["players"] )
		guiSetText ( aServerTab.Password, "Password: "..( table["password"] or "None" ) )
		guiSetText ( aServerTab.GameType, "Game Type: "..( table["game"] or "None" ) )
		guiSetText ( aServerTab.MapName, "Map Name: "..( table["map"] or "None" ) )
	end
end

function aServerTab.onRefresh ()
	local th, tm = getTime()
	guiSetText ( aServerTab.Players, "Players: "..#getElementsByType ( "player" ).."/"..gettok ( guiGetText ( aServerTab.Players ), 2, 47 ) )
	guiSetText ( aServerTab.TimeCurrent, "Tiem: "..th..":"..tm )
	guiSetText ( aServerTab.GravityCurrent, "Gravitation: "..string.sub ( getGravity(), 0, 6 ) )
	guiSetText ( aServerTab.SpeedCurrent, "Game Speed: "..getGameSpeed() )
	guiSetText ( aServerTab.WeatherCurrent, "Weather: "..getWeather().." ("..getWeatherNameFromID ( getWeather() )..")" )
end

function getWeatherNameFromID ( weather )
	return iif ( aServerTab.Weathers[weather], aServerTab.Weathers[weather], "Unknown" )
end