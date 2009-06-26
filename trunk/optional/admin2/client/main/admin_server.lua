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

	aServerTab.Server			= guiCreateLabel ( 0.05, 0.05, 0.70, 0.05, "Server: Unknown", true, aServerTab.Tab )
	aServerTab.Password		= guiCreateLabel ( 0.05, 0.10, 0.40, 0.05, "Password: None", true, aServerTab.Tab )
	aServerTab.GameType		= guiCreateLabel ( 0.05, 0.15, 0.40, 0.05, "Game Type: None", true, aServerTab.Tab )
	aServerTab.MapName		= guiCreateLabel ( 0.05, 0.20, 0.40, 0.05, "Map Name: None", true, aServerTab.Tab )
	aServerTab.Players		= guiCreateLabel ( 0.05, 0.25, 0.20, 0.05, "Players: 0/0", true, aServerTab.Tab )
	aServerTab.SetPassword		= guiCreateButton ( 0.80, 0.05, 0.18, 0.04, "Set Password", true, aServerTab.Tab, "setpassword" )
	aServerTab.ResetPassword	= guiCreateButton ( 0.80, 0.10, 0.18, 0.04, "Reset Password", true, aServerTab.Tab, "setpassword" )
	aServerTab.SetGameType		= guiCreateButton ( 0.80, 0.15, 0.18, 0.04, "Set Game Type", true, aServerTab.Tab, "setgame" )
	aServerTab.SetMapName		= guiCreateButton ( 0.80, 0.20, 0.18, 0.04, "Set Map Name", true, aServerTab.Tab, "setmap" )
	aServerTab.SetWelcome		= guiCreateButton ( 0.80, 0.25, 0.18, 0.04, "Welcome Message", true, aServerTab.Tab, "setwelcome" )
					  	  guiCreateStaticImage ( 0.05, 0.32, 0.50, 0.0025, "client\\images\\dot.png", true, aServerTab.Tab )
	aServerTab.WeatherCurrent	= guiCreateLabel ( 0.05, 0.35, 0.45, 0.05, "Current Weather: "..getWeather().." ("..getWeatherNameFromID ( getWeather() )..")", true, aServerTab.Tab )
	aServerTab.WeatherDec		= guiCreateButton ( 0.05, 0.40, 0.035, 0.04, "<", true, aServerTab.Tab )
	aServerTab.Weather		= guiCreateEdit ( 0.095, 0.40, 0.35, 0.04, "", true, aServerTab.Tab )
	aServerTab.WeatherInc		= guiCreateButton ( 0.45, 0.40, 0.035, 0.04, ">", true, aServerTab.Tab )
					  	  guiEditSetReadOnly ( aServerTab.Weather, true )
	aServerTab.WeatherSet		= guiCreateButton ( 0.50, 0.40, 0.10, 0.04, "Set", true, aServerTab.Tab, "setweather" )
	aServerTab.WeatherBlend		= guiCreateButton ( 0.61, 0.40, 0.15, 0.04, "Set Blended", true, aServerTab.Tab, "blendweather" )

					  	  local th, tm = getTime()
	aServerTab.TimeCurrent		= guiCreateLabel ( 0.05, 0.45, 0.25, 0.04, "Tiem: "..th..":"..tm, true, aServerTab.Tab )
	aServerTab.TimeH			= guiCreateEdit ( 0.35, 0.45, 0.055, 0.04, "12", true, aServerTab.Tab )
	aServerTab.TimeM			= guiCreateEdit ( 0.425, 0.45, 0.055, 0.04, "00", true, aServerTab.Tab )
					  	  guiCreateLabel ( 0.415, 0.45, 0.05, 0.04, ":", true, aServerTab.Tab )
					  	  guiEditSetMaxLength ( aServerTab.TimeH, 2 )
					  	  guiEditSetMaxLength ( aServerTab.TimeM, 2 )
	aServerTab.TimeSet		= guiCreateButton ( 0.50, 0.45, 0.10, 0.04, "Set", true, aServerTab.Tab, "settime" )
					  	  guiCreateLabel ( 0.63, 0.45, 0.12, 0.04, "( 0-23:0-59 )", true, aServerTab.Tab )

	aServerTab.GravityCurrent	= guiCreateLabel ( 0.05, 0.50, 0.28, 0.04, "Gravitation: "..string.sub ( getGravity(), 0, 6 ), true, aServerTab.Tab )
	aServerTab.Gravity		= guiCreateEdit ( 0.35, 0.50, 0.135, 0.04, "0.008", true, aServerTab.Tab )
	aServerTab.GravitySet		= guiCreateButton ( 0.50, 0.50, 0.10, 0.04, "Set", true, aServerTab.Tab, "setgravity" )

	aServerTab.SpeedCurrent		= guiCreateLabel ( 0.05, 0.55, 0.30, 0.04, "Game Speed: "..getGameSpeed(), true, aServerTab.Tab )
	aServerTab.Speed			= guiCreateEdit ( 0.35, 0.55, 0.135, 0.04, "1", true, aServerTab.Tab )
	aServerTab.SpeedSet		= guiCreateButton ( 0.50, 0.55, 0.10, 0.04, "Set", true, aServerTab.Tab, "setgamespeed" )
					  	  guiCreateLabel ( 0.63, 0.55, 0.09, 0.04, "( 0-10 )", true, aServerTab.Tab )

	aServerTab.BlurCurrent		= guiCreateLabel ( 0.05, 0.60, 0.25, 0.04, "Blur Level: 36", true, aServerTab.Tab )
	aServerTab.Blur			= guiCreateEdit ( 0.35, 0.60, 0.135, 0.04, "36", true, aServerTab.Tab )
	aServerTab.BlurSet		= guiCreateButton ( 0.50, 0.60, 0.10, 0.04, "Set", true, aServerTab.Tab, "setblurlevel" )
					  	  guiCreateLabel ( 0.63, 0.60, 0.09, 0.04, "( 0-255 )", true, aServerTab.Tab )

	aServerTab.WavesCurrent		= guiCreateLabel ( 0.05, 0.65, 0.25, 0.04, "Wave Height: "..getWaveHeight(), true, aServerTab.Tab )
	aServerTab.Waves			= guiCreateEdit ( 0.35, 0.65, 0.135, 0.04, "0", true, aServerTab.Tab )
	aServerTab.WavesSet		= guiCreateButton ( 0.50, 0.65, 0.10, 0.04, "Set", true, aServerTab.Tab, "setwaveheight" )
				 	  	  guiCreateLabel ( 0.63, 0.65, 0.09, 0.04, "( 0-100 )", true, aServerTab.Tab )

	addEventHandler ( "onClientGUIClick", aServerTab.Tab, aServerTab.onClientClick )
	addEventHandler ( "aClientSync", _root, aServerTab.onClientSync )

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