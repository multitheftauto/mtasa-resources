--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_main.lua
*
*	Original File by lil_Toady
*
**************************************]]

aAdminForm = nil
aLastCheck = 0
aCurrentVehicle = 429
aCurrentWeapon = 30
aCurrentAmmo = 90
aCurrentSlap = 20
aPlayers = {}
aBans = {}
aLastSync = 0

function aAdminMenu ()
	if ( aAdminForm == nil ) then
		local x, y = guiGetScreenSize()
		aAdminForm			= guiCreateWindow ( x / 2 - 310, y / 2 - 260, 620, 520, "Admin Menu - v".._version, false )
						  guiSetText ( aAdminForm, "Admin Menu - v".._version )
						  guiCreateLabel ( 0.68, 0.05, 0.45, 0.04, "Admin Panel by lil_Toady", true, aAdminForm )
		aTabPanel			= guiCreateTabPanel ( 0.01, 0.05, 0.98, 0.95, true, aAdminForm )
		aTab1 = {}	
		aTab1.Tab			= guiCreateTab ( "Players", aTabPanel, "players" )
		aTab1.Messages		= guiCreateButton ( 0.75, 0.02, 0.23, 0.04, "0/0 unread messages", true, aTab1.Tab )
						  guiSetAlpha ( aPlayerAdvanced, 0.7 )
		aTab1.PlayerListSearch 	= guiCreateEdit ( 0.03, 0.05, 0.16, 0.04, "", true, aTab1.Tab )
						  guiCreateStaticImage ( 0.19, 0.05, 0.035, 0.04, "client\\images\\search.png", true, aTab1.Tab )
		aTab1.PlayerList		= guiCreateGridList ( 0.03, 0.10, 0.20, 0.85, true, aTab1.Tab )
						  guiGridListAddColumn( aTab1.PlayerList, "Player Name", 0.85 )
						  for id, player in ipairs ( getElementsByType ( "player" ) ) do guiGridListSetItemText ( aTab1.PlayerList, guiGridListAddRow ( aTab1.PlayerList ), 1, getPlayerName ( player ), false, false ) end
		aTab1.Kick			= guiCreateButton ( 0.71, 0.125, 0.13, 0.04, "Kick", true, aTab1.Tab, "kick" )
		aTab1.Ban			= guiCreateButton ( 0.85, 0.125, 0.13, 0.04, "Ban", true, aTab1.Tab, "ban" )
		aTab1.Mute			= guiCreateButton ( 0.71, 0.170, 0.13, 0.04, "Mute", true, aTab1.Tab, "mute" )
		aTab1.Freeze		= guiCreateButton ( 0.85, 0.170, 0.13, 0.04, "Freeze", true, aTab1.Tab, "freeze" )
		aTab1.Spectate		= guiCreateButton ( 0.71, 0.215, 0.13, 0.04, "Spectate", true, aTab1.Tab, "spectate" )
		aTab1.Slap			= guiCreateButton ( 0.85, 0.215, 0.13, 0.04, "Slap! "..aCurrentSlap.." _", true, aTab1.Tab, "slap" )
		aTab1.SlapDropDown	= guiCreateStaticImage ( 0.95, 0.215, 0.03, 0.04, "client\\images\\dropdown.png", true, aTab1.Tab )
		aTab1.SlapOptions		= guiCreateGridList ( 0.85, 0.215, 0.13, 0.40, true, aTab1.Tab )
						  guiGridListSetSortingEnabled ( aTab1.SlapOptions, false )
						  guiGridListAddColumn( aTab1.SlapOptions, "", 0.85 )
						  guiSetVisible ( aTab1.SlapOptions, false )
						  for i = 0, 10 do guiGridListSetItemText ( aTab1.SlapOptions, guiGridListAddRow ( aTab1.SlapOptions ), 1, tostring ( i * 10 ), false, false ) end
		aTab1.Shout			= guiCreateButton ( 0.85, 0.260, 0.13, 0.04, "Shout!", true, aTab1.Tab, "shout" )
		aTab1.Admin			= guiCreateButton ( 0.71, 0.305, 0.27, 0.04, "Give admin rights", true, aTab1.Tab, "setgroup" )
	
						  guiCreateHeader ( 0.25, 0.08, 0.20, 0.04, "Player:", true, aTab1.Tab )
		aTab1.Name			= guiCreateLabel ( 0.26, 0.125, 0.30, 0.035, "Name: N/A", true, aTab1.Tab )
		aTab1.IP			= guiCreateLabel ( 0.26, 0.170, 0.30, 0.035, "IP: N/A", true, aTab1.Tab )
		aTab1.Serial		= guiCreateLabel ( 0.26, 0.215, 0.435, 0.035, "Serial: N/A", true, aTab1.Tab )
		--aTab1.Username		= guiCreateLabel ( 0.26, 0.245, 0.435, 0.035, "Username: N/A", true, aTab1.Tab )
		aTab1.Version		= guiCreateLabel ( 0.26, 0.245, 0.435, 0.035, "Version: N/A", true, aTab1.Tab )
		aTab1.Accountname	= guiCreateLabel ( 0.26, 0.275, 0.435, 0.035, "Account Name: N/A", true, aTab1.Tab )
		aTab1.Groups		= guiCreateLabel ( 0.26, 0.305, 0.435, 0.035, "Groups: N/A", true, aTab1.Tab )
		aTab1.Flag			= guiCreateStaticImage ( 0.40, 0.125, 0.025806, 0.021154, "client\\images\\empty.png", true, aTab1.Tab )
						  guiCreateHeader ( 0.25, 0.350, 0.20, 0.04, "Game:", true, aTab1.Tab )
		aTab1.Health		= guiCreateLabel ( 0.26, 0.395, 0.20, 0.04, "Health: 0%", true, aTab1.Tab )
		aTab1.Armour		= guiCreateLabel ( 0.45, 0.395, 0.20, 0.04, "Armour: 0%", true, aTab1.Tab )
		aTab1.Skin			= guiCreateLabel ( 0.26, 0.440, 0.20, 0.04, "Skin: N/A", true, aTab1.Tab )
		aTab1.Team			= guiCreateLabel ( 0.45, 0.440, 0.20, 0.04, "Team: None", true, aTab1.Tab )
		aTab1.Weapon		= guiCreateLabel ( 0.26, 0.485, 0.35, 0.04, "Weapon: N/A", true, aTab1.Tab )
		aTab1.Ping			= guiCreateLabel ( 0.26, 0.530, 0.20, 0.04, "Ping: 0", true, aTab1.Tab )
		aTab1.Money			= guiCreateLabel ( 0.45, 0.530, 0.20, 0.04, "Money: 0", true, aTab1.Tab )
		aTab1.Area			= guiCreateLabel ( 0.26, 0.575, 0.44, 0.04, "Area: Unknown", true, aTab1.Tab )
		aTab1.PositionX		= guiCreateLabel ( 0.26, 0.620, 0.30, 0.04, "X: 0", true, aTab1.Tab )
		aTab1.PositionY		= guiCreateLabel ( 0.26, 0.665, 0.30, 0.04, "Y: 0", true, aTab1.Tab )
		aTab1.PositionZ		= guiCreateLabel ( 0.26, 0.710, 0.30, 0.04, "Z: 0", true, aTab1.Tab )
		aTab1.Dimension		= guiCreateLabel ( 0.26, 0.755, 0.20, 0.04, "Dimension: 0", true, aTab1.Tab )
		aTab1.Interior		= guiCreateLabel ( 0.45, 0.755, 0.20, 0.04, "Interior: 0", true, aTab1.Tab )
		aTab1.SetHealth		= guiCreateButton ( 0.71, 0.395, 0.13, 0.04, "Set Health", true, aTab1.Tab, "sethealth" )
		aTab1.SetArmour		= guiCreateButton ( 0.85, 0.395, 0.13, 0.04, "Set Armour", true, aTab1.Tab, "setarmour" )
		aTab1.SetSkin		= guiCreateButton ( 0.71, 0.440, 0.13, 0.04, "Set Skin", true, aTab1.Tab, "setskin" )
		aTab1.SetTeam		= guiCreateButton ( 0.85, 0.440, 0.13, 0.04, "Set Team", true, aTab1.Tab, "setteam" )
		aTab1.SetDimension	= guiCreateButton ( 0.71, 0.755, 0.13, 0.04, "Set Dimens.", true, aTab1.Tab, "setdimension" )
		aTab1.SetInterior		= guiCreateButton ( 0.85, 0.755, 0.13, 0.04, "Set Interior", true, aTab1.Tab, "setinterior" )
		aTab1.GiveWeapon		= guiCreateButton ( 0.71, 0.485, 0.27, 0.04, "Give: "..getWeaponNameFromID ( aCurrentWeapon ), true, aTab1.Tab )
		aTab1.WeaponDropDown	= guiCreateStaticImage ( 0.95, 0.485, 0.03, 0.04, "client\\images\\dropdown.png", true, aTab1.Tab )
		aTab1.WeaponOptions	= guiCreateGridList ( 0.71, 0.485, 0.27, 0.48, true, aTab1.Tab )
						  guiGridListAddColumn( aTab1.WeaponOptions, "", 0.85 )
						  guiSetVisible ( aTab1.WeaponOptions, false )
						  for i = 1, 46 do if ( getWeaponNameFromID ( i ) ~= false ) then guiGridListSetItemText ( aTab1.WeaponOptions, guiGridListAddRow ( aTab1.WeaponOptions ), 1, getWeaponNameFromID ( i ), false, false ) end end
		aTab1.SetMoney		= guiCreateButton ( 0.71, 0.530, 0.13, 0.04, "Set Money", true, aTab1.Tab, "setmoney" )
		aTab1.SetStats		= guiCreateButton ( 0.85, 0.530, 0.13, 0.04, "Set Stats", true, aTab1.Tab, "setstat" )
		aTab1.JetPack		= guiCreateButton ( 0.71, 0.575, 0.27, 0.04, "Give JetPack", true, aTab1.Tab, "jetpack" )
		aTab1.Warp			= guiCreateButton ( 0.71, 0.620, 0.27, 0.04, "Warp to player", true, aTab1.Tab, "warp" )
		aTab1.WarpTo		= guiCreateButton ( 0.71, 0.665, 0.27, 0.04, "Warp player to..", true, aTab1.Tab, "warp" )
						  guiCreateHeader ( 0.25, 0.805, 0.20, 0.04, "Vehicle:", true, aTab1.Tab )
		aTab1.Vehicle		= guiCreateLabel ( 0.26, 0.850, 0.35, 0.04, "Vehicle: N/A", true, aTab1.Tab )
		aTab1.VehicleHealth	= guiCreateLabel ( 0.26, 0.895, 0.25, 0.04, "Vehicle Health: 0%", true, aTab1.Tab )
		aTab1.VehicleFix		= guiCreateButton ( 0.71, 0.85, 0.13, 0.04, "Fix", true, aTab1.Tab, "repair" )
		aTab1.VehicleDestroy	= guiCreateButton ( 0.71, 0.90, 0.13, 0.04, "Destroy", true, aTab1.Tab, "destroyvehicle" )
		aTab1.VehicleBlow		= guiCreateButton ( 0.85, 0.85, 0.13, 0.04, "Blow", true, aTab1.Tab, "blowvehicle" )
		aTab1.VehicleCustomize 	= guiCreateButton ( 0.85, 0.90, 0.13, 0.04, "Customize", true, aTab1.Tab, "customize" )
		aTab1.GiveVehicle		= guiCreateButton ( 0.71, 0.710, 0.27, 0.04, "Give: "..getVehicleNameFromModel ( aCurrentVehicle ), true, aTab1.Tab, "givevehicle" )
		aTab1.VehicleDropDown 	= guiCreateStaticImage ( 0.95, 0.710, 0.03, 0.04, "client\\images\\dropdown.png", true, aTab1.Tab )
		local gx, gy 		= guiGetSize ( aTab1.GiveVehicle, false )
		aTab1.VehicleOptions	= guiCreateGridList ( 0, 0, gx, 200, false )
						  guiGridListAddColumn( aTab1.VehicleOptions, "", 0.85 )
						  guiSetAlpha ( aTab1.VehicleOptions, 0.80 )
						  guiSetVisible ( aTab1.VehicleOptions, false )
						  local avehspecial = { [596] = "LS", [597] = "SF", [598] = "LV" }
						  for i = 0, 211 do
							if ( getVehicleNameFromModel ( 400 + i ) ~= "" ) then
								local row = guiGridListAddRow ( aTab1.VehicleOptions )
								local name = getVehicleNameFromModel ( 400 + i )
								if ( avehspecial[400+i] ) then name = name.." "..avehspecial[400+i] end
								guiGridListSetItemText ( aTab1.VehicleOptions, row, 1, name, false, false )
								guiGridListSetItemData ( aTab1.VehicleOptions, row, 1, tostring ( 400 + i ) )
							end
						  end
		aTab2 = {}
		aTab2.Tab			= guiCreateTab ( "Resources", aTabPanel, "resources" )
		aTab2.ManageACL		= guiCreateButton ( 0.75, 0.02, 0.23, 0.04, "Manage ACL", true, aTab2.Tab )
		aTab2.ResourceList	= guiCreateGridList ( 0.03, 0.05, 0.35, 0.85, true, aTab2.Tab )
						  guiGridListAddColumn( aTab2.ResourceList, "Resource", 0.55 )
						  guiGridListAddColumn( aTab2.ResourceList, "", 0.05 )
						  guiGridListAddColumn( aTab2.ResourceList, "State", 0.35 )
		aTab2.ResourceRefresh	= guiCreateButton ( 0.03, 0.91, 0.35, 0.04, "Refresh list", true, aTab2.Tab, "listresources" )
		aTab2.ResourceSettings	= guiCreateButton ( 0.40, 0.05, 0.20, 0.04, "Settings", true, aTab2.Tab )
		aTab2.ResourceStart	= guiCreateButton ( 0.40, 0.10, 0.20, 0.04, "Start", true, aTab2.Tab, "start" )
		aTab2.ResourceRestart	= guiCreateButton ( 0.40, 0.15, 0.20, 0.04, "Restart", true, aTab2.Tab, "restart" )
		aTab2.ResourceStop	= guiCreateButton ( 0.40, 0.20, 0.20, 0.04, "Stop", true, aTab2.Tab, "stop" )
		aTab2.ResourceFailture	= guiCreateButton ( 0.63, 0.10, 0.25, 0.04, "Get Load Failture", true, aTab2.Tab )
						  guiSetVisible ( aTab2.ResourceFailture, false )
		aModules			= guiCreateTabPanel ( 0.40, 0.25, 0.57, 0.38, true, aTab2.Tab )
						  guiCreateLabel ( 0.40, 0.77, 0.20, 0.03, "Actions log:", true, aTab2.Tab )
		aTab2.LogLine1		= guiCreateLabel ( 0.41, 0.81, 0.50, 0.03, "", true, aTab2.Tab )
		aTab2.LogLine2		= guiCreateLabel ( 0.41, 0.84, 0.50, 0.03, "", true, aTab2.Tab )
		aTab2.LogLine3		= guiCreateLabel ( 0.41, 0.87, 0.50, 0.03, "", true, aTab2.Tab )
		aTab2.LogLine4		= guiCreateLabel ( 0.41, 0.90, 0.50, 0.03, "", true, aTab2.Tab )
		aTab2.LogLine5		= guiCreateLabel ( 0.41, 0.93, 0.50, 0.03, "", true, aTab2.Tab )
						  guiCreateLabel ( 0.41, 0.65, 0.50, 0.04, "Execute Command:", true, aTab2.Tab )
		aTab2.Command		= guiCreateEdit ( 0.41, 0.70, 0.40, 0.055, "", true, aTab2.Tab )
		aTab2.ExecuteClient	= guiCreateButton ( 0.82, 0.70, 0.16, 0.035, "Client", true, aTab2.Tab, "execute" )
		aTab2.ExecuteServer	= guiCreateButton ( 0.82, 0.736, 0.16, 0.035, "Server", true, aTab2.Tab, "execute" )
		aTab2.ExecuteAdvanced	= guiCreateLabel ( 0.45, 0.71, 0.50, 0.04, "For advanced users only.", true, aTab2.Tab )
						  guiLabelSetColor ( aTab2.ExecuteAdvanced, 255, 0, 0 )
		aLogLines = 1

		aTab3 = {}
		aTab3.Tab			= guiCreateTab ( "Server", aTabPanel, "server" )
		aTab3.Server		= guiCreateLabel ( 0.05, 0.05, 0.70, 0.05, "Server: Unknown", true, aTab3.Tab )
		aTab3.Password		= guiCreateLabel ( 0.05, 0.10, 0.40, 0.05, "Password: None", true, aTab3.Tab )
		aTab3.GameType		= guiCreateLabel ( 0.05, 0.15, 0.40, 0.05, "Game Type: None", true, aTab3.Tab )
		aTab3.MapName		= guiCreateLabel ( 0.05, 0.20, 0.40, 0.05, "Map Name: None", true, aTab3.Tab )
		aTab3.Players		= guiCreateLabel ( 0.05, 0.25, 0.20, 0.05, "Players: 0/0", true, aTab3.Tab )
		aTab3.SetPassword		= guiCreateButton ( 0.80, 0.05, 0.18, 0.04, "Set Password", true, aTab3.Tab, "setpassword" )
		aTab3.ResetPassword	= guiCreateButton ( 0.80, 0.10, 0.18, 0.04, "Reset Password", true, aTab3.Tab, "setpassword" )
		aTab3.SetGameType		= guiCreateButton ( 0.80, 0.15, 0.18, 0.04, "Set Game Type", true, aTab3.Tab, "setgame" )
		aTab3.SetMapName		= guiCreateButton ( 0.80, 0.20, 0.18, 0.04, "Set Map Name", true, aTab3.Tab, "setmap" )
		aTab3.SetWelcome		= guiCreateButton ( 0.80, 0.25, 0.18, 0.04, "Welcome Message", true, aTab3.Tab, "setwelcome" )
						  guiCreateStaticImage ( 0.05, 0.32, 0.50, 0.0025, "client\\images\\dot.png", true, aTab3.Tab )
		aTab3.WeatherCurrent	= guiCreateLabel ( 0.05, 0.35, 0.45, 0.05, "Current Weather: "..getWeather().." ("..getWeatherNameFromID ( getWeather() )..")", true, aTab3.Tab )
		aTab3.WeatherDec		= guiCreateButton ( 0.05, 0.40, 0.035, 0.04, "<", true, aTab3.Tab )
		aTab3.Weather		= guiCreateEdit ( 0.095, 0.40, 0.35, 0.04, getWeather().." ("..getWeatherNameFromID ( getWeather() )..")", true, aTab3.Tab )
		aTab3.WeatherInc		= guiCreateButton ( 0.45, 0.40, 0.035, 0.04, ">", true, aTab3.Tab )
						  guiEditSetReadOnly ( aTab3.Weather, true )
		aTab3.WeatherSet		= guiCreateButton ( 0.50, 0.40, 0.10, 0.04, "Set", true, aTab3.Tab, "setweather" )
		aTab3.WeatherBlend	= guiCreateButton ( 0.61, 0.40, 0.15, 0.04, "Set Blended", true, aTab3.Tab, "blendweather" )

						  local th, tm = getTime()
		aTab3.TimeCurrent		= guiCreateLabel ( 0.05, 0.45, 0.25, 0.04, "Time: "..th..":"..tm, true, aTab3.Tab )
		aTab3.TimeH			= guiCreateEdit ( 0.35, 0.45, 0.055, 0.04, "12", true, aTab3.Tab )
		aTab3.TimeM			= guiCreateEdit ( 0.425, 0.45, 0.055, 0.04, "00", true, aTab3.Tab )
						  guiCreateLabel ( 0.415, 0.45, 0.05, 0.04, ":", true, aTab3.Tab )
						  guiEditSetMaxLength ( aTab3.TimeH, 2 )
						  guiEditSetMaxLength ( aTab3.TimeM, 2 )
		aTab3.TimeSet		= guiCreateButton ( 0.50, 0.45, 0.10, 0.04, "Set", true, aTab3.Tab, "settime" )
						  guiCreateLabel ( 0.63, 0.45, 0.12, 0.04, "( 0-23:0-59 )", true, aTab3.Tab )

		aTab3.GravityCurrent	= guiCreateLabel ( 0.05, 0.50, 0.28, 0.04, "Gravitation: "..string.sub ( getGravity(), 0, 6 ), true, aTab3.Tab )
		aTab3.Gravity		= guiCreateEdit ( 0.35, 0.50, 0.135, 0.04, "0.008", true, aTab3.Tab )
		aTab3.GravitySet		= guiCreateButton ( 0.50, 0.50, 0.10, 0.04, "Set", true, aTab3.Tab, "setgravity" )

		aTab3.SpeedCurrent	= guiCreateLabel ( 0.05, 0.55, 0.30, 0.04, "Game Speed: "..getGameSpeed(), true, aTab3.Tab )
		aTab3.Speed			= guiCreateEdit ( 0.35, 0.55, 0.135, 0.04, "1", true, aTab3.Tab )
		aTab3.SpeedSet		= guiCreateButton ( 0.50, 0.55, 0.10, 0.04, "Set", true, aTab3.Tab, "setgamespeed" )
						  guiCreateLabel ( 0.63, 0.55, 0.09, 0.04, "( 0-10 )", true, aTab3.Tab )

		aTab3.BlurCurrent		= guiCreateLabel ( 0.05, 0.60, 0.25, 0.04, "Blur Level: 36", true, aTab3.Tab )
		aTab3.Blur			= guiCreateEdit ( 0.35, 0.60, 0.135, 0.04, "36", true, aTab3.Tab )
		aTab3.BlurSet		= guiCreateButton ( 0.50, 0.60, 0.10, 0.04, "Set", true, aTab3.Tab, "setblurlevel" )
						  guiCreateLabel ( 0.63, 0.60, 0.09, 0.04, "( 0-255 )", true, aTab3.Tab )

		aTab3.WavesCurrent	= guiCreateLabel ( 0.05, 0.65, 0.25, 0.04, "Wave Height: "..getWaveHeight(), true, aTab3.Tab )
		aTab3.Waves			= guiCreateEdit ( 0.35, 0.65, 0.135, 0.04, "0", true, aTab3.Tab )
		aTab3.WavesSet		= guiCreateButton ( 0.50, 0.65, 0.10, 0.04, "Set", true, aTab3.Tab, "setwaveheight" )
					 	 guiCreateLabel ( 0.63, 0.65, 0.09, 0.04, "( 0-100 )", true, aTab3.Tab )

		aTab4 = {}
		aTab4.Tab			= guiCreateTab ( "Bans", aTabPanel, "bans" )
		aTab4.BansList		= guiCreateGridList ( 0.03, 0.05, 0.80, 0.90, true, aTab4.Tab )
						  guiGridListAddColumn( aTab4.BansList, "Name", 0.22 )
						  guiGridListAddColumn( aTab4.BansList, "IP", 0.22 )
						  guiGridListAddColumn( aTab4.BansList, "Serial", 0.22 )
						  guiGridListAddColumn( aTab4.BansList, "By", 0.22 )
						  guiGridListAddColumn( aTab4.BansList, "Date", 0.17 )
						  guiGridListAddColumn( aTab4.BansList, "Time", 0.13 )
						  guiGridListAddColumn( aTab4.BansList, "Reason", 0.22 )
		aTab4.Details		= guiCreateButton ( 0.85, 0.10, 0.13, 0.04, "Details", true, aTab4.Tab )
		aTab4.Unban			= guiCreateButton ( 0.85, 0.20, 0.13, 0.04, "Unban", true, aTab4.Tab, "unban" )
		aTab4.UnbanIP		= guiCreateButton ( 0.85, 0.25, 0.13, 0.04, "Unban IP", true, aTab4.Tab, "unbanip" )
		aTab4.UnbanSerial		= guiCreateButton ( 0.85, 0.30, 0.13, 0.04, "Unban Serial", true, aTab4.Tab, "unbanserial" )
		aTab4.BanIP			= guiCreateButton ( 0.85, 0.40, 0.13, 0.04, "Ban IP", true, aTab4.Tab, "banip" )
		aTab4.BanSerial		= guiCreateButton ( 0.85, 0.45, 0.13, 0.04, "Ban Serial", true, aTab4.Tab, "banserial" )
		aTab4.BansRefresh		= guiCreateButton ( 0.85, 0.85, 0.13, 0.04, "Refresh", true, aTab4.Tab, "listbans" )

		aTab5 = {}
		aTab5.Tab			= guiCreateTab ( "Admin Chat", aTabPanel, "adminchat" )
		aTab5.AdminChat		= guiCreateMemo ( 0.03, 0.05, 0.75, 0.85, "", true, aTab5.Tab )
						  guiSetProperty ( aTab5.AdminChat, "ReadOnly", "true" )
		aTab5.AdminPlayers	= guiCreateGridList ( 0.79, 0.05, 0.18, 0.80, true, aTab5.Tab )
						  guiGridListAddColumn ( aTab5.AdminPlayers, "Admins", 0.90 )
		aTab5.AdminChatSound	= guiCreateCheckBox ( 0.79, 0.86, 0.18, 0.04, "Play Sound", true, true, aTab5.Tab )
		aTab5.AdminText		= guiCreateEdit ( 0.03, 0.92, 0.80, 0.06, "", true, aTab5.Tab )
		aTab5.AdminSay		= guiCreateButton ( 0.85, 0.92, 0.08, 0.06, "Say", true, aTab5.Tab )
		aTab5.AdminChatHelp	= guiCreateButton ( 0.94, 0.92, 0.03, 0.06, "?", true, aTab5.Tab )

		aTab6 = {}
		aTab6.Tab			= guiCreateTab ( "Options", aTabPanel )
						  guiCreateHeader ( 0.03, 0.05, 0.10, 0.05, "Main:", true, aTab6.Tab )
		aTab6.OutputPlayer	= guiCreateCheckBox ( 0.05, 0.10, 0.47, 0.04, "Output player information to console on select", false, true, aTab6.Tab )
						  guiCreateLabel ( 0.08, 0.15, 0.40, 0.04, "This might be useful to copy player data", true, aTab6.Tab )
		aTab6.AdminChatOutput 	= guiCreateCheckBox ( 0.05, 0.20, 0.47, 0.04, "Output admin messages to chat box", false, true, aTab6.Tab )
						  guiCreateHeader (  0.03, 0.30, 0.47, 0.04, "Appearance:", true, aTab6.Tab )
						  guiCreateHeader ( 0.63, 0.05, 0.10, 0.05, "Account:", true, aTab6.Tab )
		aTab6.AutoLogin		= guiCreateCheckBox ( 0.65, 0.10, 0.47, 0.04, "Auto-login by serial", false, true, aTab6.Tab )
						  guiCreateHeader ( 0.63, 0.15, 0.25, 0.05, "Change Password:", true, aTab6.Tab )
						  guiCreateLabel ( 0.65, 0.20, 0.15, 0.05, "Old password:", true, aTab6.Tab )
						  guiCreateLabel ( 0.65, 0.25, 0.15, 0.05, "New password:", true, aTab6.Tab )
						  guiCreateLabel ( 0.65, 0.30, 0.15, 0.05, "Confirm:", true, aTab6.Tab )
		aTab6.PasswordOld		= guiCreateEdit ( 0.80, 0.20, 0.15, 0.045, "", true, aTab6.Tab )
		aTab6.PasswordNew		= guiCreateEdit ( 0.80, 0.25, 0.15, 0.045, "", true, aTab6.Tab )
		aTab6.PasswordConfirm	= guiCreateEdit ( 0.80, 0.30, 0.15, 0.045, "", true, aTab6.Tab )
						  guiEditSetMasked ( aTab6.PasswordOld, true )
						  guiEditSetMasked ( aTab6.PasswordNew, true )
						  guiEditSetMasked ( aTab6.PasswordConfirm, true )
		aTab6.PasswordChange	= guiCreateButton ( 0.85, 0.35, 0.10, 0.04, "Accept", true, aTab6.Tab )
						  guiCreateHeader ( 0.03, 0.65, 0.20, 0.055, "Performance:", true, aTab6.Tab )
						  guiCreateStaticImage ( 0.03, 0.69, 0.94, 0.0025, "client\\images\\dot.png", true, aTab6.Tab )
						  guiCreateLabel ( 0.05, 0.71, 0.20, 0.055, "Performance priority:", true, aTab6.Tab )
						  guiCreateLabel ( 0.11, 0.76, 0.10, 0.05, "Memory", true, aTab6.Tab )
						  guiCreateLabel ( 0.11, 0.81, 0.10, 0.05, "Auto", true, aTab6.Tab )
						  guiCreateLabel ( 0.11, 0.86, 0.10, 0.05, "Speed", true, aTab6.Tab )
		aTab6.PerformanceRAM	= guiCreateRadioButton ( 0.07, 0.75, 0.05, 0.055, "", true, aTab6.Tab )
		aTab6.PerformanceAuto	= guiCreateRadioButton ( 0.07, 0.80, 0.05, 0.055, "", true, aTab6.Tab )
		aTab6.PerformanceCPU	= guiCreateRadioButton ( 0.07, 0.85, 0.05, 0.055, "", true, aTab6.Tab )
						  if ( aGetSetting ( "performance" ) == "RAM" ) then guiRadioButtonSetSelected ( aTab6.PerformanceRAM, true )
						  elseif ( aGetSetting ( "performance" ) == "CPU" ) then guiRadioButtonSetSelected ( aTab6.PerformanceCPU, true )
						  else guiRadioButtonSetSelected ( aTab6.PerformanceAuto, true ) end
		aTab6.PerformanceAdvanced = guiCreateButton ( 0.05, 0.91, 0.11, 0.04, "Advanced", true, aTab6.Tab )
		aPerformance()
					   	  guiCreateLabel ( 0.70, 0.90, 0.19, 0.055, "Refresh Delay(MS):", true, aTab6.Tab )
		aTab6.RefreshDelay	= guiCreateEdit ( 0.89, 0.90, 0.08, 0.045, "50", true, aTab6.Tab )

		if ( aGetSetting ( "outputPlayer" ) ) then guiCheckBoxSetSelected ( aTab6.OutputPlayer, true ) end
		if ( aGetSetting ( "adminChatOutput" ) ) then guiCheckBoxSetSelected ( aTab6.AdminChatOutput, true ) end
		if ( aGetSetting ( "adminChatSound" ) ) then guiCheckBoxSetSelected ( aTab5.AdminChatSound, true ) end
		if ( tonumber ( aGetSetting ( "adminChatLines" ) ) ) then guiSetText ( aTab6.AdminChatLines, aGetSetting ( "adminChatLines" ) ) end
		if ( ( tonumber ( aGetSetting ( "refreshDelay" ) ) ) and ( tonumber ( aGetSetting ( "refreshDelay" ) ) >= 50 ) ) then guiSetText ( aTab6.RefreshDelay, aGetSetting ( "refreshDelay" ) ) end

		addEventHandler ( "aClientLog", _root, aClientLog )
		addEventHandler ( "aClientAdminChat", _root, aClientAdminChat )
		addEventHandler ( "aClientSync", _root, aClientSync )
		addEventHandler ( "aMessage", _root, aMessage )
		addEventHandler ( "aClientResourceStart", _root, aClientResourceStart )
		addEventHandler ( "aClientResourceStop", _root, aClientResourceStop )
		addEventHandler ( "aClientPlayerJoin", _root, aClientPlayerJoin )
		addEventHandler ( "onClientPlayerQuit", _root, aClientPlayerQuit )
		addEventHandler ( "onClientMouseEnter", _root, aClientMouseEnter )
		addEventHandler ( "onClientGUIClick", aAdminForm, aClientClick )
		addEventHandler ( "onClientGUIScroll", aAdminForm, aClientScroll )
		addEventHandler ( "onClientGUIDoubleClick", aAdminForm, aClientDoubleClick )
		addEventHandler ( "onClientGUIDoubleClick", aTab1.VehicleOptions, aClientDoubleClick )
		addEventHandler ( "onClientGUIAccepted", aAdminForm, aClientGUIAccepted )
		addEventHandler ( "onClientGUIChanged", aAdminForm, aClientGUIChanged )
		addEventHandler ( "onClientCursorMove", _root, aClientCursorMove )
		addEventHandler ( "onClientRender", _root, aClientRender )
		addEventHandler ( "onClientPlayerChangeNick", _root, aClientPlayerChangeNick )
		addEventHandler ( "onClientResourceStop", _root, aMainSaveSettings )
		addEventHandler ( "onClientGUITabSwitched", aTabPanel, aClientGUITabSwitched )

		bindKey ( "arrow_d", "down", aPlayerListScroll, 1 )
		bindKey ( "arrow_u", "down", aPlayerListScroll, -1 )

		triggerServerEvent ( "aSync", getLocalPlayer(), "players" )
		if ( hasPermissionTo ( "command.listmessages" ) ) then triggerServerEvent ( "aSync", getLocalPlayer(), "messages" ) end
		if ( hasPermissionTo ( "command.listresources" ) ) then triggerServerEvent ( "aSync", getLocalPlayer(), "resources" ) end
		triggerServerEvent ( "aSync", getLocalPlayer(), "server" )
		triggerEvent ( "onAdminInitialize" )
		showCursor ( true )
	end
	guiSetVisible ( aAdminForm, true )
	showCursor ( true )
end

function aAdminMenuClose ( destroy )
	if ( destroy ) then
		aMainSaveSettings ()
		aPlayers = {}
		aWeathers = {}
		aBans = {}
		removeEventHandler ( "aClientLog", _root, aClientLog )
		removeEventHandler ( "aClientAdminChat", _root, aClientAdminChat )
		removeEventHandler ( "aClientSync", _root, aClientSync )
		removeEventHandler ( "aMessage", _root, aMessage )
		removeEventHandler ( "aClientResourceStart", _root, aClientResourceStart )
		removeEventHandler ( "aClientResourceStop", _root, aClientResourceStop )
		removeEventHandler ( "aClientPlayerJoin", _root, aClientPlayerJoin )
		removeEventHandler ( "onClientPlayerQuit", _root, aClientPlayerQuit )
		removeEventHandler ( "onClientMouseEnter", _root, aClientMouseEnter )
		removeEventHandler ( "onClientGUIClick", aAdminForm, aClientClick )
		removeEventHandler ( "onClientGUIScroll", aAdminForm, aClientScroll )
		removeEventHandler ( "onClientGUIDoubleClick", aAdminForm, aClientDoubleClick )
		removeEventHandler ( "onClientGUIDoubleClick", aTab1.VehicleOptions, aClientDoubleClick )
		removeEventHandler ( "onClientGUIAccepted", aAdminForm, aClientGUIAccepted )
		removeEventHandler ( "onClientGUIChanged", aAdminForm, aClientGUIChanged )
		removeEventHandler ( "onClientCursorMove", _root, aClientCursorMove )
		removeEventHandler ( "onClientRender", _root, aClientRender )
		removeEventHandler ( "onClientPlayerChangeNick", _root, aClientPlayerChangeNick )
		removeEventHandler ( "onClientResourceStop", _root, aMainSaveSettings )
		unbindKey ( "arrow_d", "down", aPlayerListScroll )
		unbindKey ( "arrow_u", "down", aPlayerListScroll )
		destroyElement ( aTab1.VehicleOptions )
		destroyElement ( aAdminForm )
		aAdminForm = nil
	else
		guiSetVisible ( aTab1.VehicleOptions, false )
		guiSetVisible ( aAdminForm, false )
	end
	guiSetInputEnabled ( false )
	showCursor ( false )
end

function aMainSaveSettings ()
	aSetSetting ( "outputPlayer", guiCheckBoxGetSelected ( aTab6.OutputPlayer ) )
	aSetSetting ( "adminChatOutput", guiCheckBoxGetSelected ( aTab6.AdminChatOutput ) )
	aSetSetting ( "adminChatSound", guiCheckBoxGetSelected ( aTab5.AdminChatSound ) )
	aSetSetting ( "adminChatLines", guiGetText ( aTab6.AdminChatLines ) )
	aSetSetting ( "refreshDelay", guiGetText ( aTab6.RefreshDelay ) )
	aSetSetting ( "currentWeapon", aCurrentWeapon )
	aSetSetting ( "currentAmmo", aCurrentAmmo )
	aSetSetting ( "currentVehicle", aCurrentVehicle )
	aSetSetting ( "currentSlap", aCurrentSlap )
	if ( guiRadioButtonGetSelected ( aTab6.PerformanceRAM ) ) then aSetSetting ( "performance", "RAM" )
	elseif ( guiRadioButtonGetSelected ( aTab6.PerformanceCPU ) ) then aSetSetting ( "performance", "CPU" )
	else aSetSetting ( "performance", "Auto" ) end
end

function aAdminRefresh ()
	if ( guiGridListGetSelectedItem ( aTab1.PlayerList ) ~= -1 ) then
		local player = getPlayerFromNick ( guiGridListGetItemText ( aTab1.PlayerList, guiGridListGetSelectedItem( aTab1.PlayerList ), 1 ) )
		if ( player ) then
			guiSetText ( aTab1.Name, "Name: "..aPlayers[player]["name"] )
			guiSetText ( aTab1.Mute, iif ( aPlayers[player]["mute"], "Unmute", "Mute" ) )
			guiSetText ( aTab1.Freeze, iif ( aPlayers[player]["freeze"], "Unfreeze", "Freeze" ) )
			guiSetText ( aTab1.Username, "Community Username: "..( aPlayers[player]["username"] or "" ) )
			guiSetText ( aTab1.Version, "Version: "..( aPlayers[player]["version"] or "" ) )
			guiSetText ( aTab1.Accountname, "Account Name: "..( aPlayers[player]["accountname"] or "" ) )
			guiSetText ( aTab1.Groups, "Groups: "..( aPlayers[player]["groups"] or "None" ) )
			if ( isPlayerDead ( player ) ) then guiSetText ( aTab1.Health, "Health: Dead" )
			else guiSetText ( aTab1.Health, "Health: "..math.ceil ( getElementHealth ( player ) ).."%" ) end
			guiSetText ( aTab1.Armour, "Armour: "..math.ceil ( getPedArmor ( player ) ).."%" )
			guiSetText ( aTab1.Skin, "Skin: "..iif ( getElementModel ( player ), getElementModel ( player ), "N/A" ) )
			if ( getPlayerTeam ( player ) ) then guiSetText ( aTab1.Team, "Team: "..getTeamName ( getPlayerTeam ( player ) ) )
			else guiSetText ( aTab1.Team, "Team: None" ) end
			guiSetText ( aTab1.Ping, "Ping: "..getPlayerPing ( player ) )
			guiSetText ( aTab1.Money, "Money: "..( aPlayers[player]["money"] or 0 ) )
			if ( getElementDimension ( player ) ) then guiSetText ( aTab1.Dimension, "Dimension: "..getElementDimension ( player ) ) end
			if ( getElementInterior ( player ) ) then guiSetText ( aTab1.Interior, "Interior: "..getElementInterior ( player ) ) end
			guiSetText ( aTab1.JetPack, iif ( doesPedHaveJetPack ( player ), "Remove JetPack", "Give JetPack" ) )
			if ( getPedWeapon ( player ) ) then guiSetText ( aTab1.Weapon, "Weapon: "..getWeaponNameFromID ( getPedWeapon ( player ) ).." (ID: "..getPedWeapon ( player )..")" ) end
			local x, y, z = getElementPosition ( player )
			guiSetText ( aTab1.Area, "Area: "..iif ( getZoneName ( x, y, z, false ) == getZoneName ( x, y, z, true ), getZoneName ( x, y, z, false ), getZoneName ( x, y, z, false ).." ("..getZoneName ( x, y, z, true )..")" ) )
			guiSetText ( aTab1.PositionX, "X: "..x )
			guiSetText ( aTab1.PositionY, "Y: "..y )
			guiSetText ( aTab1.PositionZ, "Z: "..z )
			local vehicle = getPedOccupiedVehicle ( player )
			if ( vehicle ) then
				guiSetText ( aTab1.Vehicle, "Vehicle: "..getVehicleName ( vehicle ).." (ID: "..getElementModel ( vehicle )..")" )
				guiSetText ( aTab1.VehicleHealth, "Vehicle Health: "..math.ceil ( getElementHealth ( vehicle ) ).."%" )
			else
				guiSetText ( aTab1.Vehicle, "Vehicle: Foot" )
				guiSetText ( aTab1.VehicleHealth, "Vehicle Health: 0%" )
			end
			return player
		end
	end
end

function aClientSync ( type, table )
	if ( type == "player" ) then
		for type, data in pairs ( table ) do
			aPlayers[source][type] = data
		end
	elseif ( type == "players" ) then
		aPlayers = table
	elseif ( type == "resources" ) then
		for id, resource in ipairs(table) do
			local row = guiGridListAddRow ( aTab2.ResourceList )
			guiGridListSetItemText ( aTab2.ResourceList, row, 1, resource["name"], false, false )
			guiGridListSetItemText ( aTab2.ResourceList, row, 2, resource["numsettings"] > 0 and tostring(resource["numsettings"]) or "", false, false )
			guiGridListSetItemText ( aTab2.ResourceList, row, 3, resource["state"], false, false )
		end
	elseif ( type == "admins" ) then
		--if ( guiGridListGetRowCount ( aTab5.AdminPlayers ) > 0 ) then guiGridListClear ( aTab5.AdminPlayers ) end
		for id, player in ipairs(getElementsByType("player")) do
			if ( table[player]["admin"] == false ) and ( player == getLocalPlayer() ) then
				aAdminDestroy()
				break
			else
				aPlayers[player]["groups"] = table[player]["groups"]
				if ( table[player]["chat"] ) then
					local id = 0
					local exists = false
					while ( id <= guiGridListGetRowCount( aTab5.AdminPlayers ) ) do
						if ( guiGridListGetItemText ( aTab5.AdminPlayers, id, 1 ) == getPlayerName ( player ) ) then
							exists = true
						end
						id = id + 1
					end
					if ( exists == false ) then guiGridListSetItemText ( aTab5.AdminPlayers, guiGridListAddRow ( aTab5.AdminPlayers ), 1, getPlayerName ( player ), false, false ) end
				end
			end
		end
	elseif ( type == "server" ) then
		guiSetText ( aTab3.Server, "Server: "..table["name"] )
		guiSetText ( aTab3.Players, "Players: "..#getElementsByType ( "player" ).."/"..table["players"] )
		guiSetText ( aTab3.Password, "Password: "..( table["password"] or "None" ) )
		guiSetText ( aTab3.GameType, "Game Type: "..( table["game"] or "None" ) )
		guiSetText ( aTab3.MapName, "Map Name: "..( table["map"] or "None" ) )
	elseif ( type == "bansdirty" ) then
		g_GotLatestBansList = false
		if aAdminForm and guiGetVisible ( aAdminForm ) and guiGetSelectedTab( aTabPanel ) == aTab4.Tab then
			-- Request full bans list if bans tab is displayed when 'bansdirty' is received
			triggerServerEvent ( "aSync", getLocalPlayer(), "bans" )
		end
	elseif ( type == "bans" ) then
		outputDebugString( "aClientSync received 'bans'" )
		g_GotLatestBansList = true
		guiGridListClear ( aTab4.BansList )
		aBans = {}
		aBans["Serial"] = {}
		aBans["IP"] = {}
		for i=#table,1,-1 do
			local ban = table[i]
			if ban.serial then
				aBans["Serial"][ban.serial] = ban
			end
			if ban.ip then
				aBans["IP"][ban.ip] = ban
			end
			local row = guiGridListAddRow ( aTab4.BansList )
			guiGridListSetItemText ( aTab4.BansList, row, 1, iif ( ban["nick"], ban["nick"], "Unknown" ), false, false )
			guiGridListSetItemText ( aTab4.BansList, row, 2, ban.ip or "Unknown", false, false )
			guiGridListSetItemText ( aTab4.BansList, row, 3, ban.serial or "Unknown", false, false )
			guiGridListSetItemText ( aTab4.BansList, row, 4, iif ( ban["banner"], ban["banner"], "Unknown" ), false, false )
			guiGridListSetItemText ( aTab4.BansList, row, 5, iif ( ban["date"], ban["date"], "Unknown" ), false, false )
			guiGridListSetItemText ( aTab4.BansList, row, 6, iif ( ban["time"], ban["time"], "Unknown" ), false, false )
			guiGridListSetItemText ( aTab4.BansList, row, 7, iif ( ban["reason"], ban["reason"], "Unknown" ), false, false )
		end
	elseif ( type == "messages" ) then
		local prev = tonumber ( string.sub ( guiGetText ( aTab1.Messages ), 1, 1 ) )
		if ( prev < table["unread"] ) then
			playSoundFrontEnd ( 18 )
		end
		guiSetText ( aTab1.Messages, table["unread"].."/"..table["total"].." unread messages" )
	end
end

function aClientGUITabSwitched( selectedTab )
	if getElementParent( selectedTab ) == aTabPanel then
		if selectedTab == aTab4.Tab then
			if not g_GotLatestBansList then
				-- Request full bans list if bans tab is selected and current list is out of date
				triggerServerEvent ( "aSync", getLocalPlayer(), "bans" )
			end
		end	
	end 
end

function aMessage ( )

end

function aClientResourceStart ( resource )
	local id = 0
	while ( id <= guiGridListGetRowCount( aTab2.ResourceList ) ) do
		if ( guiGridListGetItemText ( aTab2.ResourceList, id, 1 ) == resource ) then
			guiGridListSetItemText ( aTab2.ResourceList, id, 3, "running", false, false )
		end
		id = id + 1
	end
end

function aClientResourceStop ( resource )
	local id = 0
	while ( id <= guiGridListGetRowCount( aTab2.ResourceList ) ) do
		if ( guiGridListGetItemText ( aTab2.ResourceList, id, 1 ) == resource ) then
			guiGridListSetItemText ( aTab2.ResourceList, id, 3, "loaded", false, false )
		end
		id = id + 1
	end
end

function aClientPlayerJoin ( ip, username, accountname, serial, admin, country )
	aPlayers[source] = {}
	aPlayers[source]["name"] = getPlayerName ( source )
	aPlayers[source]["IP"] = ip
	aPlayers[source]["username"] = username or "N/A"
	aPlayers[source]["accountname"] = accountname or "N/A"
	aPlayers[source]["serial"] = serial
	aPlayers[source]["admin"] = admin
	aPlayers[source]["country"] = country
	local row = guiGridListAddRow ( aTab1.PlayerList )
	guiGridListSetItemText ( aTab1.PlayerList, row, 1, getPlayerName ( source ), false, false )
	if ( admin ) then
		local row = guiGridListAddRow ( aTab5.AdminPlayers )
		guiGridListSetItemText ( aTab5.AdminPlayers, row, 1, getPlayerName ( source ), false, false )
	end
	if ( aSpecPlayerList ) then
		local row = guiGridListAddRow ( aSpecPlayerList )
		guiGridListSetItemText ( aSpecPlayerList, row, 1, getPlayerName ( source ), false, false )
	end
end

function aClientPlayerQuit ()
	local id = 0
	while ( id <= guiGridListGetRowCount( aTab1.PlayerList ) ) do
		if ( guiGridListGetItemText ( aTab1.PlayerList, id, 1 ) == getPlayerName ( source ) ) then
			guiGridListRemoveRow ( aTab1.PlayerList, id )
		end
		id = id + 1
	end
	if ( aPlayers[source]["admin"] ) then
		local id = 0
		while ( id <= guiGridListGetRowCount( aTab5.AdminPlayers ) ) do
			if ( guiGridListGetItemText ( aTab5.AdminPlayers, id, 1 ) == getPlayerName ( source ) ) then
				guiGridListRemoveRow ( aTab5.AdminPlayers, id )
			end
			id = id + 1
		end
	end
	if ( aSpecPlayerList ) then
		local id = 0
		while ( id <= guiGridListGetRowCount( aSpecPlayerList ) ) do
			if ( guiGridListGetItemText ( aSpecPlayerList, id, 1 ) == getPlayerName ( source ) ) then
				guiGridListRemoveRow ( aSpecPlayerList, id )
			end
			id = id + 1
		end
	end
	aPlayers[source] = nil
end

function aPlayerListScroll ( key, state, inc )
	if ( not guiGetVisible ( aAdminForm ) ) then return end
	local max = guiGridListGetRowCount ( aTab1.PlayerList )
	if ( max <= 0 ) then return end
	local current = guiGridListGetSelectedItem ( aTab1.PlayerList )
	local next = current + inc
	max = max - 1
	if ( current == -1 ) then
		guiGridListSetSelectedItem ( aTab1.PlayerList, 0, 1 )
	elseif ( next > max ) then return
	elseif ( next < 0 ) then return
	else
		guiGridListSetSelectedItem ( aTab1.PlayerList, next, 1 )
	end
	local oldsource = source
	source = aTab1.PlayerList;
	aClientClick ( "left" )
	source = oldsource
end

function aClientPlayerChangeNick ( oldNick, newNick )
	local id = 0
	while ( id <= guiGridListGetRowCount( aTab1.PlayerList ) ) do
		if ( guiGridListGetItemText ( aTab1.PlayerList, id, 1 ) == oldNick ) then
			guiGridListSetItemText ( aTab1.PlayerList, id, 1, newNick, false, false )
		end
		id = id + 1
	end
end

function aClientLog ( text )
	text = "#"..aLogLines..": "..text
	if ( guiGetText ( aTab2.LogLine1 ) == "" ) then guiSetText ( aTab2.LogLine1, text )
	elseif ( guiGetText ( aTab2.LogLine2 ) == "" ) then guiSetText ( aTab2.LogLine2, text )
	elseif ( guiGetText ( aTab2.LogLine3 ) == "" ) then guiSetText ( aTab2.LogLine3, text )
	elseif ( guiGetText ( aTab2.LogLine4 ) == "" ) then guiSetText ( aTab2.LogLine4, text )
	elseif ( guiGetText ( aTab2.LogLine5 ) == "" ) then guiSetText ( aTab2.LogLine5, text )
	else
		guiSetText ( aTab2.LogLine1, guiGetText ( aTab2.LogLine2 ) )
		guiSetText ( aTab2.LogLine2, guiGetText ( aTab2.LogLine3 ) )
		guiSetText ( aTab2.LogLine3, guiGetText ( aTab2.LogLine4 ) )
		guiSetText ( aTab2.LogLine4, guiGetText ( aTab2.LogLine5 ) )
		guiSetText ( aTab2.LogLine5, text )
	end
	aLogLines = aLogLines + 1
end

function aClientAdminChat ( message )
	guiSetText ( aTab5.AdminChat, guiGetText ( aTab5.AdminChat )..""..getPlayerName ( source )..": "..message )
	guiSetProperty ( aTab5.AdminChat, "CaratIndex", tostring ( string.len ( guiGetText ( aTab5.AdminChat ) ) ) )
	if ( guiCheckBoxGetSelected ( aTab6.AdminChatOutput ) ) then outputChatBox ( "ADMIN> "..getPlayerName ( source )..": "..message, 255, 0, 0 ) end
	if ( ( guiCheckBoxGetSelected ( aTab5.AdminChatSound ) ) and ( source ~= getLocalPlayer() ) ) then playSoundFrontEnd ( 13 ) end
end

function aSetCurrentAmmo ( ammo )
	ammo = tonumber ( ammo )
	if ( ( ammo ) and ( ammo > 0 ) and ( ammo < 10000 ) ) then
		aCurrentAmmo = ammo
		return
	end
	outputChatBox ( "Invalid ammo value", getLocalPlayer(), 255, 0, 0 )
end

function aClientGUIAccepted ( element )
	if ( element == aTab5.AdminText ) then
		local message = guiGetText ( aTab5.AdminText )
		if ( ( message ) and ( message ~= "" ) ) then 
			if ( gettok ( message, 1, 32 ) == "/clear" ) then guiSetText ( aTab5.AdminChat, "" )
			else triggerServerEvent ( "aAdminChat", getLocalPlayer(), message ) end
			guiSetText ( aTab5.AdminText, "" )
		end
	end
end

function aClientGUIChanged ()
	if ( source == aTab1.PlayerListSearch ) then
		guiGridListClear ( aTab1.PlayerList )
		local text = guiGetText ( source )
		if ( text == "" ) then
			for id, player in ipairs ( getElementsByType ( "player" ) ) do
				guiGridListSetItemText ( aTab1.PlayerList, guiGridListAddRow ( aTab1.PlayerList ), 1, getPlayerName ( player ), false, false )
			end
		else
			for id, player in ipairs ( getElementsByType ( "player" ) ) do
				if ( string.find ( string.upper ( getPlayerName ( player ) ), string.upper ( text ) ) ) then
					guiGridListSetItemText ( aTab1.PlayerList, guiGridListAddRow ( aTab1.PlayerList ), 1, getPlayerName ( player ), false, false )
				end
			end
		end
	end
end

function aClientScroll ( element )
	if ( source == aTab6.MouseSense ) then
		guiSetText ( aTab6.MouseSenseCur, "Cursor sensivity: ("..string.sub ( guiScrollBarGetScrollPosition ( source ) / 50, 0, 4 )..")" )
	end
end

function aClientCursorMove ( rx, ry, x, y )
	
end

function aClientMouseEnter ( element )
	if ( getElementType ( source ) == "gui-button" ) then

	end
end

function aClientDoubleClick ( button )
	if ( source == aTab1.WeaponOptions ) then
		if ( guiGridListGetSelectedItem ( aTab1.WeaponOptions ) ~= -1 ) then
			aCurrentWeapon = getWeaponIDFromName ( guiGridListGetItemText ( aTab1.WeaponOptions, guiGridListGetSelectedItem ( aTab1.WeaponOptions ), 1 ) )
			local wep = guiGridListGetItemText ( aTab1.WeaponOptions, guiGridListGetSelectedItem ( aTab1.WeaponOptions ), 1 )
			wep = string.gsub ( wep, "Combat Shotgun", "Combat SG" )
			guiSetText ( aTab1.GiveWeapon, "Give: "..wep.." " )
		end
		guiSetVisible ( aTab1.WeaponOptions, false )
	elseif ( source == aTab1.VehicleOptions ) then
		local item = guiGridListGetSelectedItem ( aTab1.VehicleOptions )
		if ( item ~= -1 ) then
			if ( guiGridListGetItemText ( aTab1.VehicleOptions, item, 1 ) ~= "" ) then
				aCurrentVehicle = tonumber ( guiGridListGetItemData ( aTab1.VehicleOptions, item, 1 ) )
				guiSetText ( aTab1.GiveVehicle, "Give: "..guiGridListGetItemText ( aTab1.VehicleOptions, item, 1 ).." " )
			end
		end
		guiSetVisible ( aTab1.VehicleOptions, false )
	elseif ( source == aTab1.SlapOptions ) then
		if ( guiGridListGetSelectedItem ( aTab1.SlapOptions ) ~= -1 ) then
			aCurrentSlap = guiGridListGetItemText ( aTab1.SlapOptions, guiGridListGetSelectedItem ( aTab1.SlapOptions ), 1 )
			guiSetText ( aTab1.Slap, "Slap! "..aCurrentSlap.." _" )
			if ( aSpecSlap ) then guiSetText ( aSpecSlap, "Slap! "..aCurrentSlap.."hp" ) end
		end
		guiSetVisible ( aTab1.SlapOptions, false )
	elseif ( source == aTab2.ResourceList ) then
		if ( guiGridListGetSelectedItem ( aTab2.ResourceList ) ~= -1 ) then
			aManageSettings ( guiGridListGetItemText ( aTab2.ResourceList, guiGridListGetSelectedItem( aTab2.ResourceList ), 1 ) )
		end
	end
	if ( guiGetVisible ( aTab1.WeaponOptions ) ) then guiSetVisible ( aTab1.WeaponOptions, false ) end
	if ( guiGetVisible ( aTab1.VehicleOptions ) ) then guiSetVisible ( aTab1.VehicleOptions, false ) end
	if ( guiGetVisible ( aTab1.SlapOptions ) ) then guiSetVisible ( aTab1.SlapOptions, false ) end
end

function aClientClick ( button )
	guiSetInputEnabled ( false )
	if ( ( source == aTab1.WeaponOptions ) or ( source == aTab1.VehicleOptions ) or ( source == aTab1.SlapOptions ) ) then return
	else
		if ( guiGetVisible ( aTab1.WeaponOptions ) ) then guiSetVisible ( aTab1.WeaponOptions, false ) end
		if ( guiGetVisible ( aTab1.VehicleOptions ) ) then guiSetVisible ( aTab1.VehicleOptions, false ) end
		if ( guiGetVisible ( aTab1.SlapOptions ) ) then guiSetVisible ( aTab1.SlapOptions, false ) end
	end
	if ( button == "left" ) then
		-- TAB 1, PLAYERS
		if ( getElementParent ( source ) == aTab1.Tab ) then
			if ( source == aTab1.Messages ) then
				aViewMessages()
			elseif ( source == aTab1.PlayerListSearch ) then
				guiSetInputEnabled ( true )
			elseif ( getElementType ( source ) == "gui-button" )  then
				if ( source == aTab1.GiveVehicle ) then guiBringToFront ( aTab1.VehicleDropDown )
				elseif ( source == aTab1.GiveWeapon ) then guiBringToFront ( aTab1.WeaponDropDown )
				elseif ( source == aTab1.Slap ) then guiBringToFront ( aTab1.SlapDropDown ) end
				if ( guiGridListGetSelectedItem ( aTab1.PlayerList ) == -1 ) then
					aMessageBox ( "error", "No player selected!" )
				else
					local name = guiGridListGetItemText ( aTab1.PlayerList, guiGridListGetSelectedItem( aTab1.PlayerList ), 1 )
					local escname = string.gsub( name,"([\"])", "\\\"" )
					local player = getPlayerFromNick ( name )
					if ( source == aTab1.Kick ) then aInputBox ( "Kick player "..name, "Enter the kick reason", "", "triggerServerEvent ( \"aPlayer\", getLocalPlayer(), getPlayerFromNick ( \""..escname.."\" ), \"kick\", $value )" )
					elseif ( source == aTab1.Ban ) then aBanInputBox ( player )
					elseif ( source == aTab1.Slap ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "slap", aCurrentSlap )
					elseif ( source == aTab1.Mute ) then aMessageBox ( "question", "Are you sure to "..iif( aPlayers[player]["mute"], "unmute", "mute" ).." "..name.."?", "triggerServerEvent ( \"aPlayer\", getLocalPlayer(), getPlayerFromNick ( \""..escname.."\" ), \"mute\" )" )
					elseif ( source == aTab1.Freeze ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "freeze" )
					elseif ( source == aTab1.Spectate ) then aSpectate ( player )
					elseif ( source == aTab1.Shout ) then aInputBox ( "Shout", "Enter text to be shown on player's screen", "", "triggerServerEvent ( \"aPlayer\", getLocalPlayer(), getPlayerFromNick ( \""..escname.."\" ), \"shout\", $value )" )
					elseif ( source == aTab1.SetHealth ) then aInputBox ( "Set Health", "Enter the health value", "100", "triggerServerEvent ( \"aPlayer\", getLocalPlayer(), getPlayerFromNick ( \""..escname.."\" ), \"sethealth\", $value )" )
					elseif ( source == aTab1.SetArmour ) then aInputBox ( "Set Armour", "Enter the armour value", "100", "triggerServerEvent ( \"aPlayer\", getLocalPlayer(), getPlayerFromNick ( \""..escname.."\" ), \"setarmour\", $value )" )
					elseif ( source == aTab1.SetTeam ) then aPlayerTeam ( player )
					elseif ( source == aTab1.SetSkin ) then aPlayerSkin ( player )
					elseif ( source == aTab1.SetInterior ) then aPlayerInterior ( player )
					elseif ( source == aTab1.JetPack ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "jetpack" )
					elseif ( source == aTab1.SetMoney ) then aInputBox ( "Set Money", "Enter the money value", "0", "triggerServerEvent ( \"aPlayer\", getLocalPlayer(), getPlayerFromNick ( \""..escname.."\" ), \"setmoney\", $value )" )
					elseif ( source == aTab1.SetStats ) then aPlayerStats ( player )
					elseif ( source == aTab1.SetDimension ) then aInputBox ( "Dimension ID Required", "Enter Dimension ID between 0  and 65535", "0", "triggerServerEvent ( \"aPlayer\", getLocalPlayer(), getPlayerFromNick ( \""..escname.."\" ), \"setdimension\", $value )" )
					elseif ( source == aTab1.GiveVehicle ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "givevehicle", aCurrentVehicle )
					elseif ( source == aTab1.GiveWeapon ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "giveweapon", aCurrentWeapon, aCurrentAmmo )
					elseif ( source == aTab1.Warp ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "warp" )
					elseif ( source == aTab1.WarpTo ) then aPlayerWarp ( player )
					elseif ( source == aTab1.VehicleFix ) then triggerServerEvent ( "aVehicle", getLocalPlayer(), player, "repair" )
					elseif ( source == aTab1.VehicleBlow ) then triggerServerEvent ( "aVehicle", getLocalPlayer(), player, "blowvehicle" )
					elseif ( source == aTab1.VehicleDestroy ) then triggerServerEvent ( "aVehicle", getLocalPlayer(), player, "destroyvehicle" )
					elseif ( source == aTab1.VehicleCustomize ) then aVehicleCustomize ( player )
					elseif ( source == aTab1.Admin ) then
						if ( aPlayers[player]["admin"] ) then aMessageBox ( "warning", "Revoke admin rights from "..name.."?", "triggerServerEvent ( \"aPlayer\", getLocalPlayer(), getPlayerFromNick ( \""..escname.."\" ), \"setgroup\", false )" )
						else aMessageBox ( "warning", "Give admin rights to "..name.."?", "triggerServerEvent ( \"aPlayer\", getLocalPlayer(), getPlayerFromNick ( \""..escname.."\" ), \"setgroup\", true )" ) end
					end
				end
			elseif ( source == aTab1.VehicleDropDown ) then
				local x1, y1 = guiGetPosition ( aAdminForm, false )
				local x2, y2 = guiGetPosition ( aTabPanel, false )
				local x3, y3 = guiGetPosition ( aTab1.Tab, false )
				local x4, y4 = guiGetPosition ( aTab1.GiveVehicle, false )
				guiSetPosition ( aTab1.VehicleOptions, x1 + x2 + x3 + x4, y1 + y2 + y3 + y4 + 20, false )
				guiSetVisible ( aTab1.VehicleOptions, true )
				guiBringToFront ( aTab1.VehicleOptions )
			elseif ( source == aTab1.WeaponDropDown ) then
				guiSetVisible ( aTab1.WeaponOptions, true )
				guiBringToFront ( aTab1.WeaponOptions )
			elseif ( source == aTab1.SlapDropDown ) then
				guiSetVisible ( aTab1.SlapOptions, true )
				guiBringToFront ( aTab1.SlapOptions )
			elseif ( source == aTab1.PlayerList ) then
				if ( guiGridListGetSelectedItem( aTab1.PlayerList ) ~= -1 ) then
					local player = aAdminRefresh ()
					if ( player ) then
						triggerServerEvent ( "aSync", getLocalPlayer(), "player", player )
						if ( ( guiCheckBoxGetSelected ( aTab6.OutputPlayer ) ) and ( player ) ) then outputConsole ( "Name: "..aPlayers[player]["name"]..", IP: "..aPlayers[player]["IP"]..", Serial: "..aPlayers[player]["serial"]..", Community Username: "..aPlayers[player]["username"]..", Account Name: "..aPlayers[player]["accountname"] ) end
						guiSetText ( aTab1.IP, "IP: "..aPlayers[player]["IP"] )
						guiSetText ( aTab1.Serial, "Serial: "..aPlayers[player]["serial"] )
						guiSetText ( aTab1.Username, "Community Username: "..aPlayers[player]["username"] )
						guiSetText ( aTab1.Accountname, "Account Name: "..aPlayers[player]["accountname"] )
						guiStaticImageLoadImage ( aTab1.Flag, "client\\images\\empty.png" )
						if ( aPlayers[player]["country"] ) then
							local x, y = guiGetPosition ( aTab1.IP, false )
							local width = guiLabelGetTextExtent ( aTab1.IP )
							guiSetPosition ( aTab1.Flag, x + width + 7, y + 4, false )
							guiStaticImageLoadImage ( aTab1.Flag, "client\\images\\flags\\"..tostring ( aPlayers[player]["country"] )..".png" )
						end
						guiSetText ( aTab1.Version, "Version: " .. ( aPlayers[player]["version"] or "" ) )
					end
				else
					guiSetText ( aTab1.Name, "Name: N/A" )
					guiSetText ( aTab1.IP, "IP: N/A" )
					guiSetText ( aTab1.Serial, "Serial: N/A" )
					guiSetText ( aTab1.Username, "Community Username: N/A" )
					guiSetText ( aTab1.Version, "Version: N/A" )
					guiSetText ( aTab1.Accountname, "Account Name: N/A" )
					guiSetText ( aTab1.Groups, "Groups: N/A" )
					guiSetText ( aTab1.Mute, "Mute" )
					guiSetText ( aTab1.Freeze, "Freeze" )
					guiSetText ( aTab1.Admin, "Give admin rights" )
					guiSetText ( aTab1.Health, "Health: 0%" ) 
					guiSetText ( aTab1.Armour, "Armour: 0%" )
					guiSetText ( aTab1.Skin, "Skin: N/A" )
					guiSetText ( aTab1.Team, "Team: None" )
					guiSetText ( aTab1.Ping, "Ping: 0" )
					guiSetText ( aTab1.Money, "Money: 0" )
					guiSetText ( aTab1.Dimension, "Dimension: 0" )
					guiSetText ( aTab1.Interior, "Interior: 0" )
					guiSetText ( aTab1.JetPack, "Give JetPack" )
					guiSetText ( aTab1.Weapon, "Weapon: N/A" )
					guiSetText ( aTab1.Area, "Area: Unknown" )
					guiSetText ( aTab1.PositionX, "X: 0" )
					guiSetText ( aTab1.PositionY, "Y: 0" )
					guiSetText ( aTab1.PositionZ, "Z: 0" )
					guiSetText ( aTab1.Vehicle, "Vehicle: N/A" )
					guiSetText ( aVehicleHealth, "Vehicle Health: 0%" )
					guiStaticImageLoadImage ( aTab1.Flag, "client\\images\\empty.png" )

				end
			end
		-- TAB 2, RESOURCES
		elseif ( getElementParent ( source ) == aTab2.Tab ) then
			if ( ( source == aTab2.ResourceStart ) or ( source == aTab2.ResourceRestart ) or ( source == aTab2.ResourceStop ) or ( source == aTab2.ResourceSettings ) ) then
				if ( guiGridListGetSelectedItem ( aTab2.ResourceList ) == -1 ) then
					aMessageBox ( "error", "No resource selected!" )
				else
					if ( source == aTab2.ResourceStart ) then triggerServerEvent ( "aResource", getLocalPlayer(), guiGridListGetItemText ( aTab2.ResourceList, guiGridListGetSelectedItem( aTab2.ResourceList ), 1 ), "start" )
					elseif ( source == aTab2.ResourceRestart ) then triggerServerEvent ( "aResource", getLocalPlayer(), guiGridListGetItemText ( aTab2.ResourceList, guiGridListGetSelectedItem( aTab2.ResourceList ), 1 ), "restart" )
					elseif ( source == aTab2.ResourceStop ) then triggerServerEvent ( "aResource", getLocalPlayer(), guiGridListGetItemText ( aTab2.ResourceList, guiGridListGetSelectedItem( aTab2.ResourceList ), 1 ), "stop" )
					elseif ( source == aTab2.ResourceSettings ) then aManageSettings ( guiGridListGetItemText ( aTab2.ResourceList, guiGridListGetSelectedItem( aTab2.ResourceList ) ) )
					end
				end
			elseif ( source == aTab2.ResourceList ) then
				guiSetVisible ( aTab2.ResourceFailture, false )
				if ( guiGridListGetSelectedItem ( aTab2.ResourceList ) ~= -1 ) then
					if ( guiGridListGetItemText ( aTab2.ResourceList, guiGridListGetSelectedItem( aTab2.ResourceList ), 3 ) == "Failed to load" ) then
						guiSetVisible ( aTab2.ResourceFailture, true )
					end
				end
			elseif ( source == aTab2.ManageACL ) then
				aManageACL()
			elseif ( source == aTab2.ResourceRefresh ) then
				guiGridListClear ( aTab2.ResourceList )
				triggerServerEvent ( "aSync", getLocalPlayer(), "resources" )
			elseif ( source == aTab2.ExecuteClient ) then
				if ( ( guiGetText ( aTab2.Command ) ) and ( guiGetText ( aTab2.Command ) ~= "" ) ) then aExecute ( guiGetText ( aTab2.Command ), true ) end
			elseif ( source == aTab2.ExecuteServer ) then
				if ( ( guiGetText ( aTab2.Command ) ) and ( guiGetText ( aTab2.Command ) ~= "" ) ) then triggerServerEvent ( "aExecute", getLocalPlayer(), guiGetText ( aTab2.Command ), true ) end
			elseif ( source == aTab2.Command ) then
				guiSetInputEnabled ( true )
				guiSetVisible ( aTab2.ExecuteAdvanced, false )
			elseif ( source == aTab2.ExecuteAdvanced ) then
				guiSetVisible ( aTab2.ExecuteAdvanced, false )
			end
		-- TAB 3, WORLD
		elseif ( getElementParent ( source ) == aTab3.Tab ) then
			if ( source == aTab3.SetGameType ) then aInputBox ( "Game Type", "Enter game type:", "", "triggerServerEvent ( \"aServer\", getLocalPlayer(), \"setgame\", $value )" )
			elseif ( source == aTab3.SetMapName ) then aInputBox ( "Map Name", "Enter map name:", "", "triggerServerEvent ( \"aServer\", getLocalPlayer(), \"setmap\", $value )" )
			elseif ( source == aTab3.SetWelcome ) then aInputBox ( "Welcome Message", "Enter the server welcome message:", "", "triggerServerEvent ( \"aServer\", getLocalPlayer(), \"setwelcome\", $value )" )
			elseif ( source == aTab3.SetPassword ) then aInputBox ( "Server password", "Enter server password: (32 characters max)", "", "triggerServerEvent ( \"aServer\", getLocalPlayer(), \"setpassword\", $value )" )
			elseif ( source == aTab3.ResetPassword ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setpassword", "" )
			elseif ( ( source == aTab3.WeatherInc ) or ( source == aTab3.WeatherDec ) ) then
				local id = tonumber ( gettok ( guiGetText ( aTab3.Weather ), 1, 32 ) )
				if ( id ) then
					if ( ( source == aTab3.WeatherInc ) and ( id < _weathers_max ) ) then guiSetText ( aTab3.Weather, ( id + 1 ).." ("..getWeatherNameFromID ( id + 1 )..")" )
					elseif ( ( source == aTab3.WeatherDec ) and ( id > 0 ) ) then guiSetText ( aTab3.Weather, ( id - 1 ).." ("..getWeatherNameFromID ( id - 1 )..")" ) end
				else
					guiSetText ( aTab3.Weather, ( 14 ).." ("..getWeatherNameFromID ( 14 )..")" ) 
				end
			elseif ( source == aTab3.WeatherSet ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setweather", gettok ( guiGetText ( aTab3.Weather ), 1, 32 ) )
			elseif ( source == aTab3.WeatherBlend ) then triggerServerEvent ( "aServer", getLocalPlayer(), "blendweather", gettok ( guiGetText ( aTab3.Weather ), 1, 32 ) )
			elseif ( source == aTab3.TimeSet ) then triggerServerEvent ( "aServer", getLocalPlayer(), "settime", guiGetText ( aTab3.TimeH ), guiGetText ( aTab3.TimeM ) )
			elseif ( ( source == aTab3.SpeedInc ) or ( source == aTab3.SpeedDec ) ) then
				local value = tonumber ( guiGetText ( aTab3.Speed ) )
				if ( value ) then
					if ( ( source == aTab3.SpeedInc ) and ( value < 10 ) ) then guiSetText ( aTab3.Speed, tostring ( value + 1 ) )
					elseif ( ( source == aTab3.SpeedDec ) and ( value > 0 ) ) then guiSetText ( aTab3.Speed, tostring ( value - 1 ) ) end
				else
					guiSetText ( aTab3.Speed, "1" ) 
				end
			elseif ( source == aTab3.SpeedSet ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setgamespeed", guiGetText ( aTab3.Speed ) )
			elseif ( source == aTab3.GravitySet ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setgravity", guiGetText ( aTab3.Gravity ) )
			elseif ( source == aTab3.WavesSet ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setwaveheight", guiGetText ( aTab3.Waves ) )
			elseif ( source == aTab3.BlurSet ) then triggerServerEvent ( "aServer", getLocalPlayer(), "setblurlevel", guiGetText ( aTab3.Blur ) )
			end
		-- TAB 4, BANS
		elseif ( getElementParent ( source ) == aTab4.Tab ) then
			if ( source == aTab4.Details ) then
				if ( guiGridListGetSelectedItem ( aTab4.BansList ) == -1 ) then
					aMessageBox ( "error", "No ban row selected!" )
				else
					local ip = guiGridListGetItemText ( aTab4.BansList, guiGridListGetSelectedItem( aTab4.BansList ), 2 )
					aBanDetails ( ip )
				end
			elseif ( source == aTab4.Unban ) then
				if ( guiGridListGetSelectedItem ( aTab4.BansList ) == -1 ) then
					aMessageBox ( "error", "No ban row selected!" )
				else
					local selip = guiGridListGetItemText ( aTab4.BansList, guiGridListGetSelectedItem( aTab4.BansList ), 2 )
					local selserial = guiGridListGetItemText ( aTab4.BansList, guiGridListGetSelectedItem( aTab4.BansList ), 3 )
					if ( aBans["Serial"][selserial] and selserial ~= "Unknown" ) then aMessageBox ( "question", "Unban Serial "..selserial.."?", "triggerServerEvent ( \"aBans\", getLocalPlayer(), \"unbanserial\", \""..selserial.."\" )" )
					else aMessageBox ( "question", "Unban IP "..selip.."?", "triggerServerEvent ( \"aBans\", getLocalPlayer(), \"unbanip\", \""..selip.."\" )" ) end
				end
			elseif ( source == aTab4.UnbanIP ) then
				aInputBox ( "Unban IP", "Enter IP to be unbanned", "", "triggerServerEvent ( \"aBans\", getLocalPlayer(), \"unbanip\", $value )" )
			elseif ( source == aTab4.UnbanSerial ) then
				aInputBox ( "Unban Serial", "Enter Serial to be unbanned", "", "triggerServerEvent ( \"aBans\", getLocalPlayer(), \"unbanserial\", $value )" )
			elseif ( source == aTab4.BanIP ) then
				aInputBox ( "Add IP Ban", "Enter IP to be banned", "", "triggerServerEvent ( \"aBans\", getLocalPlayer(), \"banip\", $value )" )
			elseif ( source == aTab4.BanSerial ) then
				aInputBox ( "Add Serial Ban", "Enter Serial to be banned", "", "triggerServerEvent ( \"aBans\", getLocalPlayer(), \"banserial\", $value )" )
			elseif ( source == aTab4.BansRefresh ) then
				guiGridListClear ( aTab4.BansList )
				triggerServerEvent ( "aSync", getLocalPlayer(), "bans" )
			end
		-- TAB 5, ADMIN CHAT
		elseif ( getElementParent ( source ) == aTab5.Tab ) then
			if ( source == aTab5.AdminSay ) then
				local message = guiGetText ( aTab5.AdminText )
				if ( ( message ) and ( message ~= "" ) ) then
					if ( gettok ( message, 1, 32 ) == "/clear" ) then guiSetText ( aTab5.AdminChat, "" )
					else triggerServerEvent ( "aAdminChat", getLocalPlayer(), message ) end
					guiSetText ( aTab5.AdminText, "" )
				end
			elseif ( source == aTab5.AdminText ) then
				guiSetInputEnabled ( true )
			end
		-- TAB 6, OPTIONS
		elseif ( getElementParent ( source ) == aTab6.Tab ) then
			if ( source == aTab6.PerformanceCPU ) then
				for id, element in ipairs ( getElementChildren ( aPerformanceForm ) ) do
					if ( getElementType ( element ) == "gui-checkbox" ) then
						guiCheckBoxSetSelected ( element, false )
					end
				end
			elseif ( source == aTab6.PerformanceRAM ) then
				for id, element in ipairs ( getElementChildren ( aPerformanceForm ) ) do
					if ( getElementType ( element ) == "gui-checkbox" ) then
						guiCheckBoxSetSelected ( element, true )
					end
				end
			elseif ( source == aTab6.PerformanceAdvanced ) then
				aPerformance()
			elseif ( source == aTab6.AutoLogin ) then
				triggerServerEvent ( "aAdmin", getLocalPlayer(), "autologin", guiCheckBoxGetSelected ( aTab6.AutoLogin ) )
			elseif ( source == aTab6.PasswordOld ) then
				guiSetInputEnabled ( true )
			elseif ( source == aTab6.PasswordNew ) then
				guiSetInputEnabled ( true )
			elseif ( source == aTab6.PasswordConfirm ) then
				guiSetInputEnabled ( true )
			elseif ( source == aTab6.PasswordChange ) then
				local passwordNew, passwordConf = guiGetText ( aTab6.PasswordNew ), guiGetText ( aTab6.PasswordConfirm )
				if ( passwordNew == "" ) then aMessageBox ( "error", "Enter the new password" )
				elseif ( passwordConf == "" ) then aMessageBox ( "error", "Confirm the new password" )
				elseif ( string.len ( passwordNew ) < 4 ) then aMessageBox ( "error", "The new password must be at least 4 characters long" )
				elseif ( passwordNew ~= passwordConf ) then aMessageBox ( "error", "Confirmed password doesn't match" )
				else triggerServerEvent ( "aAdmin", getLocalPlayer(), "password", guiGetText ( aTab6.PasswordOld ), passwordNew, passwordConf ) end
			end
		end
	elseif ( button == "right" ) then
		if ( source == aTab1.GiveWeapon ) then aInputBox ( "Weapon Ammo", "Ammo value from 1 to 9999", "100", "aSetCurrentAmmo ( $value )" )
		end
	end
end

function aClientRender ()
	if ( guiGetVisible ( aAdminForm ) ) then
		if ( getTickCount() >= aLastCheck ) then
			aAdminRefresh ()
			local th, tm = getTime()
			guiSetText ( aTab3.Players, "Players: "..#getElementsByType ( "player" ).."/"..gettok ( guiGetText ( aTab3.Players ), 2, 47 ) )
			guiSetText ( aTab3.TimeCurrent,	string.format("Time: %02d:%02d", th, tm ) )
			guiSetText ( aTab3.GravityCurrent, "Gravitation: "..string.sub ( getGravity(), 0, 6 ) )
			guiSetText ( aTab3.SpeedCurrent, "Game Speed: "..getGameSpeed() )
			guiSetText ( aTab3.WeatherCurrent, "Weather: "..getWeather().." ("..getWeatherNameFromID ( getWeather() )..")" )
			local refreshTime = tonumber ( guiGetText ( aTab6.RefreshDelay ) )
			if ( ( refreshTime ) and ( refreshTime >= 20 ) ) then aLastCheck = getTickCount() + refreshTime
			else aLastCheck = getTickCount() + 50 end
		end
		if ( getTickCount() >= aLastSync ) then
			triggerServerEvent ( "aSync", getLocalPlayer(), "admins" )
			aLastSync = getTickCount() + 15000
		end
	end
end