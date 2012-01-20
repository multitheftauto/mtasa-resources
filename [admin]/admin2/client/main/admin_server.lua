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

						  guiCreateHeader ( 0.02, 0.015, 0.30, 0.035, "Server info:", true, tab )
	aServerTab.Server			= guiCreateLabel ( 0.03, 0.060, 0.40, 0.035, "Server: Unknown", true, tab )
	aServerTab.Password		= guiCreateLabel ( 0.03, 0.105, 0.40, 0.035, "Password: None", true, tab )
	aServerTab.GameType		= guiCreateLabel ( 0.03, 0.150, 0.40, 0.035, "Game Type: None", true, tab )
	aServerTab.MapName		= guiCreateLabel ( 0.03, 0.195, 0.40, 0.035, "Map Name: None", true, tab )
	aServerTab.Players		= guiCreateLabel ( 0.03, 0.240, 0.20, 0.035, "Players: 0/0", true, tab )
	aServerTab.SetPassword		= guiCreateButton ( 0.42, 0.060, 0.18, 0.04, "Set Password", true, tab, "setpassword" )
	aServerTab.ResetPassword	= guiCreateButton ( 0.42, 0.105, 0.18, 0.04, "Reset Password", true, tab, "setpassword" )
	aServerTab.SetGameType		= guiCreateButton ( 0.42, 0.150, 0.18, 0.04, "Set Game Type", true, tab, "setgame" )
	aServerTab.SetMapName		= guiCreateButton ( 0.42, 0.195, 0.18, 0.04, "Set Map Name", true, tab, "setmap" )
	aServerTab.Shutdown		= guiCreateButton ( 0.42, 0.240, 0.18, 0.04, "Shutdown", true, tab, "shutdown" )
					  	  guiCreateHeader ( 0.02, 0.285, 0.30, 0.035, "Server properties:", true, tab )
	aServerTab.WeatherCurrent	= guiCreateLabel ( 0.03, 0.330, 0.45, 0.035, "Current Weather: "..getWeather().." ("..getWeatherNameFromID ( getWeather() )..")", true, tab )
	--aServerTab.WeatherDec		= guiCreateButton ( 0.05, 0.40, 0.035, 0.04, "<", true, tab )
	aServerTab.Weather		= guiCreateEdit ( 0.35, 0.330, 0.25, 0.04, "", true, tab )
	--aServerTab.WeatherInc		= guiCreateButton ( 0.45, 0.40, 0.035, 0.04, ">", true, tab )
					  	  guiEditSetReadOnly ( aServerTab.Weather, true )
	aServerTab.WeatherSet		= guiCreateButton ( 0.50, 0.375, 0.10, 0.04, "Set", true, tab, "setweather" )
	aServerTab.WeatherBlend		= guiCreateButton ( 0.35, 0.375, 0.135, 0.04, "Blend", true, tab, "blendweather" )

					  	  local th, tm = getTime()
	aServerTab.TimeCurrent		= guiCreateLabel ( 0.03, 0.420, 0.25, 0.035, "Time: "..th..":"..tm, true, tab )
	aServerTab.TimeH			= guiCreateEdit ( 0.35, 0.420, 0.055, 0.04, "12", true, tab )
	aServerTab.TimeM			= guiCreateEdit ( 0.425, 0.420, 0.055, 0.04, "00", true, tab )
					  	  guiCreateLabel ( 0.415, 0.420, 0.05, 0.04, ":", true, tab )
					  	  guiEditSetMaxLength ( aServerTab.TimeH, 2 )
					  	  guiEditSetMaxLength ( aServerTab.TimeM, 2 )
	aServerTab.TimeSet		= guiCreateButton ( 0.50, 0.420, 0.10, 0.04, "Set", true, tab, "settime" )

	aServerTab.GravityCurrent	= guiCreateLabel ( 0.03, 0.465, 0.28, 0.035, "Gravitation: "..string.format ( "%.3f", getGravity() ), true, tab )
	aServerTab.Gravity		= guiCreateEdit ( 0.35, 0.465, 0.135, 0.04, "0.008", true, tab )
	aServerTab.GravitySet		= guiCreateButton ( 0.50, 0.465, 0.10, 0.04, "Set", true, tab, "setgravity" )

	aServerTab.SpeedCurrent		= guiCreateLabel ( 0.03, 0.510, 0.30, 0.035, "Game Speed: "..getGameSpeed(), true, tab )
	aServerTab.Speed			= guiCreateEdit ( 0.35, 0.510, 0.135, 0.04, "1", true, tab )
	aServerTab.SpeedSet		= guiCreateButton ( 0.50, 0.510, 0.10, 0.04, "Set", true, tab, "setgamespeed" )

	aServerTab.BlurCurrent		= guiCreateLabel ( 0.03, 0.555, 0.25, 0.035, "Blur Level: 36", true, tab )
	aServerTab.Blur			= guiCreateEdit ( 0.35, 0.555, 0.135, 0.04, "36", true, tab )
	aServerTab.BlurSet		= guiCreateButton ( 0.50, 0.555, 0.10, 0.04, "Set", true, tab, "setblurlevel" )

	aServerTab.HeatHazeCurrent	= guiCreateLabel ( 0.03, 0.600, 0.25, 0.035, "Heat Haze Level: "..getHeatHaze(), true, tab )
	aServerTab.HeatHaze		= guiCreateEdit ( 0.35, 0.600, 0.135, 0.04, "80", true, tab )
	aServerTab.HeatHazeSet		= guiCreateButton ( 0.50, 0.600, 0.10, 0.04, "Set", true, tab, "setheathazelevel" )

	aServerTab.WavesCurrent		= guiCreateLabel ( 0.03, 0.645, 0.25, 0.035, "Wave Height: "..getWaveHeight(), true, tab )
	aServerTab.Waves			= guiCreateEdit ( 0.35, 0.645, 0.135, 0.04, "0", true, tab )
	aServerTab.WavesSet		= guiCreateButton ( 0.50, 0.645, 0.10, 0.04, "Set", true, tab, "setwaveheight" )

	aServerTab.FPSCurrent		= guiCreateLabel ( 0.03, 0.690, 0.25, 0.035, "FPS Limit: 36", true, tab )
	aServerTab.FPS			= guiCreateEdit ( 0.35, 0.690, 0.135, 0.04, "0", true, tab )
	aServerTab.FPSSet			= guiCreateButton ( 0.50, 0.690, 0.10, 0.04, "Set", true, tab, "setfpslimit" )

						  guiCreateHeader ( 0.02, 0.735, 0.30, 0.035, "Automatic scripts:", true, tab )
	aServerTab.PingKickerCheck	= guiCreateCheckBox ( 0.03, 0.780, 0.30, 0.04, "Ping Kicker", false, true, tab, "setpingkicker" )
	aServerTab.PingKicker		= guiCreateEdit ( 0.35, 0.780, 0.135, 0.04, "300", true, tab )
	aServerTab.PingKickerSet	= guiCreateButton ( 0.50, 0.780, 0.10, 0.04, "Set", true, tab, "setpingkicker" )
						  guiSetEnabled ( aServerTab.PingKicker, false )
						  guiSetEnabled ( aServerTab.PingKickerSet, false )

	aServerTab.FPSKickerCheck	= guiCreateCheckBox ( 0.03, 0.825, 0.30, 0.04, "FPS Kicker", false, true, tab, "setfpskicker" )
	aServerTab.FPSKicker		= guiCreateEdit ( 0.35, 0.825, 0.135, 0.04, "5", true, tab )
	aServerTab.FPSKickerSet		= guiCreateButton ( 0.50, 0.825, 0.10, 0.04, "Set", true, tab, "setfpskicker" )
						  guiSetEnabled ( aServerTab.FPSKicker, false )
						  guiSetEnabled ( aServerTab.FPSKickerSet, false )

	aServerTab.IdleKickerCheck	= guiCreateCheckBox ( 0.03, 0.870, 0.30, 0.04, "Idle Kicker", false, true, tab, "setidlekicker" )
	aServerTab.IdleKicker		= guiCreateEdit ( 0.35, 0.870, 0.135, 0.04, "10", true, tab )
	aServerTab.IdleKickerSet	= guiCreateButton ( 0.50, 0.870, 0.10, 0.04, "Set", true, tab, "setidlekicker" )
						  guiSetEnabled ( aServerTab.IdleKicker, false )
						  guiSetEnabled ( aServerTab.IdleKickerSet, false )

						  guiCreateHeader ( 0.65, 0.285, 0.30, 0.035, "Allowed glitches:", true, tab )
	aServerTab.QuickReload		= guiCreateCheckBox ( 0.66, 0.330, 0.20, 0.04, "Quick Reload", false, true, tab, "setglitch" )
	aServerTab.FastMove		= guiCreateCheckBox ( 0.66, 0.375, 0.20, 0.04, "Fast Move", false, true, tab, "setglitch" )
	aServerTab.FastFire		= guiCreateCheckBox ( 0.66, 0.420, 0.20, 0.04, "Fast Fire", false, true, tab, "setglitch" )
	aServerTab.CrouchBug		= guiCreateCheckBox ( 0.66, 0.465, 0.20, 0.04, "Crouch Bug", false, true, tab, "setglitch" )

						  guiCreateHeader ( 0.65, 0.510, 0.30, 0.035, "Special world properties:", true, tab )
	aServerTab.HoverCars		= guiCreateCheckBox ( 0.66, 0.555, 0.20, 0.04, "Hover cars", false, true, tab, "setworldproperty" )
	aServerTab.AirCars		= guiCreateCheckBox ( 0.66, 0.600, 0.20, 0.04, "Air cars", false, true, tab, "setworldproperty" )
	aServerTab.ExtraBunny		= guiCreateCheckBox ( 0.66, 0.645, 0.20, 0.04, "Extra bunny", false, true, tab, "setworldproperty" )
	aServerTab.ExtraJump		= guiCreateCheckBox ( 0.66, 0.690, 0.20, 0.04, "Extra jump", false, true, tab, "setworldproperty" )


	addEventHandler ( "onClientGUIClick", aServerTab.Tab, aServerTab.onClientClick )
	addEventHandler ( EVENT_SYNC, _root, aServerTab.onClientSync )
	addEventHandler ( "onAdminRefresh", aServerTab.Tab, aServerTab.onRefresh )

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

	sync ( SYNC_SERVER )

	aServerTab.onRefresh ()
end

function aServerTab.onClientClick ( button )
	if ( button == "left" ) then
		if ( source == aServerTab.SetGameType ) then 
			local gametype = inputBox ( "Map Name", "Enter map name:" )
			if ( gametype ) then
				triggerServerEvent ( "aServer", getLocalPlayer(), "setgame", gametype )
			end
		elseif ( source == aServerTab.SetMapName ) then
			local mapname = inputBox ( "Game Type", "Enter game type:" )
			if ( mapname ) then
				triggerServerEvent ( "aServer", getLocalPlayer(), "setmap", mapname )
			end
		elseif ( source == aServerTab.SetPassword ) then
			local password = inputBox ( "Server password", "Enter server password: (32 characters max)" )
			if ( password and password:len() > 0 ) then
				triggerServerEvent ( "aServer", getLocalPlayer(), "setpassword", password )
			end
		elseif ( source == aServerTab.ResetPassword ) then
			if ( messageBox ( "Reset password?", MB_QUESTION, MB_YESNO ) ) then
				triggerServerEvent ( "aServer", getLocalPlayer(), "setpassword", "" )
			end
		elseif ( source == aServerTab.Shutdown ) then
			local reason = inputBox ( "Shutdown", "Enter shut down reason:" )
			if ( reason ) then
				triggerServerEvent ( "aServer", getLocalPlayer(), "shutdown", reason )
			end
		elseif ( ( source == aServerTab.WeatherInc ) or ( source == aServerTab.WeatherDec ) ) then
			local id = tonumber ( gettok ( guiGetText ( aServerTab.Weather ), 1, 32 ) )
			if ( id ) then
				if ( ( source == aServerTab.WeatherInc ) and ( id < aServerTab.WeatherMax ) ) then guiSetText ( aServerTab.Weather, ( id + 1 ).." ("..getWeatherNameFromID ( id + 1 )..")" )
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
		elseif ( source == aServerTab.HeatHazeSet ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setheathazelevel", guiGetText ( aServerTab.HeatHaze ) )
		elseif ( source == aServerTab.FPSSet ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setfpslimit", guiGetText ( aServerTab.FPS ) )
		elseif ( source == aServerTab.QuickReload ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setglitch", "quickreload", iif ( guiCheckBoxGetSelected ( aServerTab.QuickReload ), "on", "off" ) )
		elseif ( source == aServerTab.FastMove ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setglitch", "fastmove", iif ( guiCheckBoxGetSelected ( aServerTab.FastMove ), "on", "off" ) )
		elseif ( source == aServerTab.FastFire ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setglitch", "fastfire", iif ( guiCheckBoxGetSelected ( aServerTab.FastFire ), "on", "off" ) )
		elseif ( source == aServerTab.CrouchBug ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setglitch", "crouchbug", iif ( guiCheckBoxGetSelected ( aServerTab.CrouchBug ), "on", "off" ) )
		elseif ( source == aServerTab.HoverCars ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setworldproperty", "hovercars", iif ( guiCheckBoxGetSelected ( aServerTab.HoverCars ), "on", "off" ) )
		elseif ( source == aServerTab.AirCars ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setworldproperty", "aircars", iif ( guiCheckBoxGetSelected ( aServerTab.AirCars ), "on", "off" ) )
		elseif ( source == aServerTab.ExtraBunny ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setworldproperty", "extrabunny", iif ( guiCheckBoxGetSelected ( aServerTab.ExtraBunny ), "on", "off" ) )
		elseif ( source == aServerTab.ExtraJump ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setworldproperty", "extrajump", iif ( guiCheckBoxGetSelected ( aServerTab.ExtraJump ), "on", "off" ) )
		end
	end
end

function aServerTab.onClientSync ( type, table )
	if ( type == SYNC_SERVER ) then
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
	guiSetText ( aServerTab.TimeCurrent, "Time: "..string.format ( "%02d:%02d", th, tm ) )
	guiSetText ( aServerTab.GravityCurrent, "Gravitation: "..string.format ( "%.3f", getGravity() ) )
	guiSetText ( aServerTab.SpeedCurrent, "Game Speed: "..getGameSpeed() )
	guiSetText ( aServerTab.WeatherCurrent, "Weather: "..getWeather().." ("..getWeatherNameFromID ( getWeather() )..")" )
	guiSetText ( aServerTab.BlurCurrent, "Blur Level: "..getBlurLevel () )
	guiSetText ( aServerTab.HeatHazeCurrent, "Heat Haze Level: "..getHeatHaze () )
	guiCheckBoxSetSelected ( aServerTab.HoverCars, isWorldSpecialPropertyEnabled ( "hovercars" ) )
	guiCheckBoxSetSelected ( aServerTab.AirCars, isWorldSpecialPropertyEnabled ( "aircars" ) )
	guiCheckBoxSetSelected ( aServerTab.ExtraBunny, isWorldSpecialPropertyEnabled ( "extrabunny" ) )
	guiCheckBoxSetSelected ( aServerTab.ExtraJump, isWorldSpecialPropertyEnabled ( "extrajump" ) )
end

function getWeatherNameFromID ( weather )
	return iif ( aServerTab.Weathers[weather], aServerTab.Weathers[weather], "Unknown" )
end