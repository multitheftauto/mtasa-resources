--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\main\admin_players.lua
*
*	Original File by lil_Toady
*
**************************************]]

aPlayersTab = {
	CurrentVehicle = 429,
	CurrentWeapon = 30,
	CurrentAmmo = 90,
	CurrentSlap = 20
}

addEvent ( "aClientSync", true )
addEvent ( "aClientPlayerJoin", true )

function aPlayersTab.Create ( tab )
	aPlayersTab.Tab = tab

	aPlayersTab.Messages		= guiCreateButton ( 0.75, 0.02, 0.23, 0.04, "0/0 unread messages", true, aPlayersTab.Tab )
					  	  guiSetAlpha ( aPlayerAdvanced, 0.7 )
	aPlayersTab.PlayerListSearch 	= guiCreateEdit ( 0.01, 0.02, 0.20, 0.04, "", true, aPlayersTab.Tab )
					  	  guiCreateInnerImage ( "client\\images\\search.png", aPlayersTab.PlayerListSearch )
	aPlayersTab.PlayerList		= guiCreateGridList ( 0.01, 0.07, 0.20, 0.91, true, aPlayersTab.Tab )
					  	  guiGridListAddColumn( aPlayersTab.PlayerList, "Player list", 0.85 )
					  	  for id, player in ipairs ( getElementsByType ( "player" ) ) do
							local row = guiGridListAddRow ( aPlayersTab.PlayerList )
							guiGridListSetItemText ( aPlayersTab.PlayerList, row, 1, getPlayerName ( player ), false, false )
							guiGridListSetItemData ( aPlayersTab.PlayerList, row, 1, player )
						  end
	aPlayersTab.Kick			= guiCreateButton ( 0.71, 0.125, 0.13, 0.04, "Kick", true, aPlayersTab.Tab, "kick" )
	aPlayersTab.Ban			= guiCreateButton ( 0.85, 0.125, 0.13, 0.04, "Ban", true, aPlayersTab.Tab, "ban" )
	aPlayersTab.Mute			= guiCreateButton ( 0.71, 0.170, 0.13, 0.04, "Mute", true, aPlayersTab.Tab, "mute" )
	aPlayersTab.Freeze		= guiCreateButton ( 0.85, 0.170, 0.13, 0.04, "Freeze", true, aPlayersTab.Tab, "freeze" )
	aPlayersTab.Spectate		= guiCreateButton ( 0.71, 0.215, 0.13, 0.04, "Spectate", true, aPlayersTab.Tab, "spectate" )
	aPlayersTab.Slap			= guiCreateButton ( 0.85, 0.215, 0.13, 0.04, "Slap! "..aPlayersTab.CurrentSlap.." _", true, aPlayersTab.Tab, "slap" )
	aPlayersTab.SlapDropDown	= guiCreateInnerImage ( "client\\images\\dropdown.png", aPlayersTab.Slap, true )
	aPlayersTab.SlapOptions		= guiCreateGridList ( 0.85, 0.215, 0.13, 0.40, true, aPlayersTab.Tab )
					  	  guiGridListSetSortingEnabled ( aPlayersTab.SlapOptions, false )
					  	  guiGridListAddColumn( aPlayersTab.SlapOptions, "", 0.85 )
					  	  guiSetVisible ( aPlayersTab.SlapOptions, false )
					  	  for i = 0, 10 do guiGridListSetItemText ( aPlayersTab.SlapOptions, guiGridListAddRow ( aPlayersTab.SlapOptions ), 1, tostring ( i * 10 ), false, false ) end
	aPlayersTab.Shout			= guiCreateButton ( 0.85, 0.260, 0.13, 0.04, "Shout!", true, aPlayersTab.Tab, "shout" )
	aPlayersTab.Admin			= guiCreateButton ( 0.71, 0.305, 0.27, 0.04, "Give admin rights", true, aPlayersTab.Tab, "setgroup" )
						  guiCreateHeader ( 0.25, 0.035, 0.20, 0.04, "Player:", true, aPlayersTab.Tab )
	aPlayersTab.Name			= guiCreateLabel ( 0.26, 0.080, 0.30, 0.035, "Name: N/A", true, aPlayersTab.Tab )
	aPlayersTab.IP			= guiCreateLabel ( 0.26, 0.125, 0.30, 0.035, "IP: N/A", true, aPlayersTab.Tab )
	aPlayersTab.Serial		= guiCreateLabel ( 0.26, 0.170, 0.30, 0.035, "Serial: N/A", true, aPlayersTab.Tab )
	aPlayersTab.Country		= guiCreateLabel ( 0.26, 0.215, 0.30, 0.035, "Country: Unknown", true, aPlayersTab.Tab )
	aPlayersTab.Account		= guiCreateLabel ( 0.26, 0.260, 0.30, 0.035, "Account: N/A", true, aPlayersTab.Tab )
	aPlayersTab.Groups		= guiCreateLabel ( 0.26, 0.305, 0.30, 0.035, "Groups: N/A", true, aPlayersTab.Tab )
	aPlayersTab.Flag			= guiCreateStaticImage ( 0.40, 0.125, 0.025806, 0.021154, "client\\images\\empty.png", true, aPlayersTab.Tab )
					  	  guiCreateHeader ( 0.25, 0.350, 0.20, 0.04, "Game:", true, aPlayersTab.Tab )
	aPlayersTab.Health		= guiCreateLabel ( 0.26, 0.395, 0.20, 0.04, "Health: 0%", true, aPlayersTab.Tab )
	aPlayersTab.Armour		= guiCreateLabel ( 0.45, 0.395, 0.20, 0.04, "Armour: 0%", true, aPlayersTab.Tab )
	aPlayersTab.Skin			= guiCreateLabel ( 0.26, 0.440, 0.20, 0.04, "Skin: N/A", true, aPlayersTab.Tab )
	aPlayersTab.Team			= guiCreateLabel ( 0.45, 0.440, 0.20, 0.04, "Team: None", true, aPlayersTab.Tab )
	aPlayersTab.Weapon		= guiCreateLabel ( 0.26, 0.485, 0.35, 0.04, "Weapon: N/A", true, aPlayersTab.Tab )
	aPlayersTab.Ping			= guiCreateLabel ( 0.26, 0.530, 0.20, 0.04, "Ping: 0", true, aPlayersTab.Tab )
	aPlayersTab.Money			= guiCreateLabel ( 0.45, 0.530, 0.20, 0.04, "Money: 0", true, aPlayersTab.Tab )
	aPlayersTab.Area			= guiCreateLabel ( 0.26, 0.575, 0.44, 0.04, "Area: Unknown", true, aPlayersTab.Tab )
	aPlayersTab.PositionX		= guiCreateLabel ( 0.26, 0.620, 0.30, 0.04, "X: 0", true, aPlayersTab.Tab )
	aPlayersTab.PositionY		= guiCreateLabel ( 0.26, 0.665, 0.30, 0.04, "Y: 0", true, aPlayersTab.Tab )
	aPlayersTab.PositionZ		= guiCreateLabel ( 0.26, 0.710, 0.30, 0.04, "Z: 0", true, aPlayersTab.Tab )
	aPlayersTab.Dimension		= guiCreateLabel ( 0.26, 0.755, 0.20, 0.04, "Dimension: 0", true, aPlayersTab.Tab )
	aPlayersTab.Interior		= guiCreateLabel ( 0.45, 0.755, 0.20, 0.04, "Interior: 0", true, aPlayersTab.Tab )
	aPlayersTab.SetHealth		= guiCreateButton ( 0.71, 0.395, 0.13, 0.04, "Set Health", true, aPlayersTab.Tab, "sethealth" )
	aPlayersTab.SetArmour		= guiCreateButton ( 0.85, 0.395, 0.13, 0.04, "Set Armour", true, aPlayersTab.Tab, "setarmour" )
	aPlayersTab.SetSkin		= guiCreateButton ( 0.71, 0.440, 0.13, 0.04, "Set Skin", true, aPlayersTab.Tab, "setskin" )
	aPlayersTab.SetTeam		= guiCreateButton ( 0.85, 0.440, 0.13, 0.04, "Set Team", true, aPlayersTab.Tab, "setteam" )
	aPlayersTab.SetDimension	= guiCreateButton ( 0.71, 0.755, 0.13, 0.04, "Set Dimens.", true, aPlayersTab.Tab, "setdimension" )
	aPlayersTab.SetInterior		= guiCreateButton ( 0.85, 0.755, 0.13, 0.04, "Set Interior", true, aPlayersTab.Tab, "setinterior" )
	aPlayersTab.GiveWeapon		= guiCreateButton ( 0.71, 0.485, 0.27, 0.04, "Give: "..getWeaponNameFromID ( aPlayersTab.CurrentWeapon ), true, aPlayersTab.Tab, "giveweapon" )
	aPlayersTab.WeaponDropDown	= guiCreateInnerImage ( "client\\images\\dropdown.png", aPlayersTab.GiveWeapon, true )
	aPlayersTab.WeaponOptions	= guiCreateGridList ( 0.71, 0.485, 0.27, 0.48, true, aPlayersTab.Tab )
						  guiGridListAddColumn( aPlayersTab.WeaponOptions, "", 0.85 )
						  guiSetVisible ( aPlayersTab.WeaponOptions, false )
						  for i = 1, 46 do if ( getWeaponNameFromID ( i ) ~= false ) then guiGridListSetItemText ( aPlayersTab.WeaponOptions, guiGridListAddRow ( aPlayersTab.WeaponOptions ), 1, getWeaponNameFromID ( i ), false, false ) end end
	aPlayersTab.SetMoney		= guiCreateButton ( 0.71, 0.530, 0.13, 0.04, "Set Money", true, aPlayersTab.Tab, "setmoney" )
	aPlayersTab.SetStats		= guiCreateButton ( 0.85, 0.530, 0.13, 0.04, "Set Stats", true, aPlayersTab.Tab, "setstat" )
	aPlayersTab.JetPack		= guiCreateButton ( 0.71, 0.575, 0.27, 0.04, "Give JetPack", true, aPlayersTab.Tab, "jetpack" )
					  	  guiCreateHeader ( 0.25, 0.805, 0.20, 0.04, "Vehicle:", true, aPlayersTab.Tab )
	aPlayersTab.Vehicle		= guiCreateLabel ( 0.26, 0.850, 0.35, 0.04, "Vehicle: N/A", true, aPlayersTab.Tab )
	aPlayersTab.VehicleHealth	= guiCreateLabel ( 0.26, 0.895, 0.25, 0.04, "Vehicle Health: 0%", true, aPlayersTab.Tab )
	aPlayersTab.VehicleFix		= guiCreateButton ( 0.71, 0.85, 0.13, 0.04, "Fix", true, aPlayersTab.Tab, "repair" )
	aPlayersTab.VehicleDestroy	= guiCreateButton ( 0.71, 0.90, 0.13, 0.04, "Destroy", true, aPlayersTab.Tab, "destroyvehicle" )
	aPlayersTab.VehicleBlow		= guiCreateButton ( 0.85, 0.85, 0.13, 0.04, "Blow", true, aPlayersTab.Tab, "blowvehicle" )
	aPlayersTab.VehicleCustomize 	= guiCreateButton ( 0.85, 0.90, 0.13, 0.04, "Customize", true, aPlayersTab.Tab, "customize" )
	aPlayersTab.GiveVehicle		= guiCreateButton ( 0.71, 0.710, 0.27, 0.04, "Give: "..getVehicleNameFromModel ( aPlayersTab.CurrentVehicle ), true, aPlayersTab.Tab, "givevehicle" )
	aPlayersTab.VehicleDropDown 	= guiCreateInnerImage ( "client\\images\\dropdown.png", aPlayersTab.GiveVehicle, true )
	local gx, gy 			= guiGetSize ( aPlayersTab.GiveVehicle, false )
	aPlayersTab.VehicleOptions	= guiCreateGridList ( 0, 0, gx, 200, false )
						  guiGridListAddColumn( aPlayersTab.VehicleOptions, "", 0.85 )
						  guiSetAlpha ( aPlayersTab.VehicleOptions, 0.80 )
						  guiSetVisible ( aPlayersTab.VehicleOptions, false )
						  for i = 0, 211 do
							if ( getVehicleNameFromModel ( 400 + i ) ~= "" ) then
								guiGridListSetItemText ( aPlayersTab.VehicleOptions, guiGridListAddRow ( aPlayersTab.VehicleOptions ), 1, getVehicleNameFromModel ( 400 + i ), false, false )
							end
						  end

	-- EVENTS

	addEventHandler ( "onClientGUIClick", aPlayersTab.Tab, aPlayersTab.onClientClick )
	addEventHandler ( "onClientGUIDoubleClick", aPlayersTab.Tab, aPlayersTab.onClientDoubleClick )
	addEventHandler ( "onClientGUIDoubleClick", aPlayersTab.VehicleOptions, aPlayersTab.onClientDoubleClick )
	addEventHandler ( "onClientGUIChanged", aPlayersTab.PlayerListSearch, aPlayersTab.onPlayerListSearch )
	addEventHandler ( "onClientPlayerChangeNick", _root, aPlayersTab.onClientPlayerChangeNick )
	addEventHandler ( "aClientPlayerJoin", _root, aPlayersTab.onClientPlayerJoin )
	addEventHandler ( "onClientPlayerQuit", _root, aPlayersTab.onClientPlayerQuit )
	addEventHandler ( "aClientSync", _root, aPlayersTab.onClientSync )
	addEventHandler ( "onClientResourceStop", getResourceRootElement(), aPlayersTab.onClientResourceStop )
	addEventHandler ( "onAdminRefresh", _root, aPlayersTab.onRefresh )

	triggerServerEvent ( "aSync", getLocalPlayer(), "players" )
	if ( hasPermissionTo ( "command.listmessages" ) ) then triggerServerEvent ( "aSync", getLocalPlayer(), "messages" ) end

	bindKey ( "arrow_d", "down", aPlayersTab.onPlayerListScroll, 1 )
	bindKey ( "arrow_u", "down", aPlayersTab.onPlayerListScroll, -1 )
end

function aPlayersTab.onClientClick ( button )
	guiSetInputEnabled ( false )
	if ( ( source == aPlayersTab.WeaponOptions ) or ( source == aPlayersTab.VehicleOptions ) or ( source == aPlayersTab.SlapOptions ) ) then return
	else
		if ( guiGetVisible ( aPlayersTab.WeaponOptions ) ) then guiSetVisible ( aPlayersTab.WeaponOptions, false ) end
		if ( guiGetVisible ( aPlayersTab.VehicleOptions ) ) then guiSetVisible ( aPlayersTab.VehicleOptions, false ) end
		if ( guiGetVisible ( aPlayersTab.SlapOptions ) ) then guiSetVisible ( aPlayersTab.SlapOptions, false ) end
	end
	if ( button == "left" ) then
		if ( source == aPlayersTab.Messages ) then
			aViewMessages()
		elseif ( source == aPlayersTab.PlayerListSearch ) then
			guiSetInputEnabled ( true )
		elseif ( getElementType ( source ) == "gui-button" )  then
			if ( source == aPlayersTab.GiveVehicle ) then guiBringToFront ( aPlayersTab.VehicleDropDown )
			elseif ( source == aPlayersTab.GiveWeapon ) then guiBringToFront ( aPlayersTab.WeaponDropDown )
			elseif ( source == aPlayersTab.Slap ) then guiBringToFront ( aPlayersTab.SlapDropDown ) end
			if ( guiGridListGetSelectedItem ( aPlayersTab.PlayerList ) == -1 ) then
				messageBox ( "No player selected!", MB_ERROR, MB_OK )
			else
				local player = getSelectedPlayer ()
				local name = getPlayerName ( player )
				if ( source == aPlayersTab.Kick ) then aInputBox ( "Kick nub "..name.." out", "Whai?", "", "triggerServerEvent ( \"aPlayer\", getLocalPlayer(), getPlayerFromNick ( \""..name.."\" ), \"kick\", $value )" )
				elseif ( source == aPlayersTab.Ban ) then aInputBox ( "Bant nub "..name, "Whai?!", "gay!", "triggerServerEvent ( \"aPlayer\", getLocalPlayer(), getPlayerFromNick ( \""..name.."\" ), \"ban\", $value )" )
				elseif ( source == aPlayersTab.Slap ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "slap", aPlayersTab.CurrentSlap )
				elseif ( source == aPlayersTab.Mute ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "mute" )
				elseif ( source == aPlayersTab.Freeze ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "freeze" )
				elseif ( source == aPlayersTab.Spectate ) then aSpectate ( player )
				elseif ( source == aPlayersTab.Shout ) then aInputBox ( "Shout", "Enter text the nub would see", "", "triggerServerEvent ( \"aPlayer\", getLocalPlayer(), getPlayerFromNick ( \""..name.."\" ), \"shout\", $value )" )
				elseif ( source == aPlayersTab.SetHealth ) then aInputBox ( "Set Health", "Enter the health value", "100", "triggerServerEvent ( \"aPlayer\", getLocalPlayer(), getPlayerFromNick ( \""..name.."\" ), \"sethealth\", $value )" )
				elseif ( source == aPlayersTab.SetArmour ) then aInputBox ( "Set Armour", "Enter the armour value", "100", "triggerServerEvent ( \"aPlayer\", getLocalPlayer(), getPlayerFromNick ( \""..name.."\" ), \"setarmour\", $value )" )
				elseif ( source == aPlayersTab.SetTeam ) then aPlayerTeam ( player )
				elseif ( source == aPlayersTab.SetSkin ) then aPlayerSkin ( player )
				elseif ( source == aPlayersTab.SetInterior ) then aPlayerInterior ( player )
				elseif ( source == aPlayersTab.JetPack ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "jetpack" )
				elseif ( source == aPlayersTab.SetMoney ) then aInputBox ( "Set Money", "Enter the money value", "0", "triggerServerEvent ( \"aPlayer\", getLocalPlayer(), getPlayerFromNick ( \""..name.."\" ), \"setmoney\", $value )" )
				elseif ( source == aPlayersTab.SetStats ) then aPlayerStats ( player )
				elseif ( source == aPlayersTab.SetDimension ) then aInputBox ( "Dimension ID Required", "Enter Dimension ID between 0  and 65535", "0", "triggerServerEvent ( \"aPlayer\", getLocalPlayer(), getPlayerFromNick ( \""..name.."\" ), \"setdimension\", $value )" )
				elseif ( source == aPlayersTab.GiveVehicle ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "givevehicle", aPlayersTab.CurrentVehicle )
				elseif ( source == aPlayersTab.GiveWeapon ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "giveweapon", aPlayersTab.CurrentWeapon, aPlayersTab.CurrentAmmo )
				elseif ( source == aPlayersTab.VehicleFix ) then triggerServerEvent ( "aVehicle", getLocalPlayer(), player, "repair" )
				elseif ( source == aPlayersTab.VehicleBlow ) then triggerServerEvent ( "aVehicle", getLocalPlayer(), player, "blowvehicle" )
				elseif ( source == aPlayersTab.VehicleDestroy ) then triggerServerEvent ( "aVehicle", getLocalPlayer(), player, "destroyvehicle" )
				elseif ( source == aPlayersTab.VehicleCustomize ) then aVehicleCustomize ( player )
				elseif ( source == aPlayersTab.Admin ) then
					if ( aPlayers[player]["admin"] and messageBox ( "Revoke admin rights from "..name.."?", MB_WARNING ) ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "setgroup", false )
					elseif ( messageBox ( "Give admin rights to "..name.."?", MB_WARNING ) )then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "setgroup", true ) end
				end
			end
		elseif ( source == aPlayersTab.VehicleDropDown ) then
			local x1, y1 = guiGetPosition ( aAdminMain.Form, false )
			local x2, y2 = guiGetPosition ( aAdminMain.Panel, false )
			local x3, y3 = guiGetPosition ( aPlayersTab.Tab, false )
			local x4, y4 = guiGetPosition ( aPlayersTab.GiveVehicle, false )
			guiSetPosition ( aPlayersTab.VehicleOptions, x1 + x2 + x3 + x4, y1 + y2 + y3 + y4 + 23, false )
			guiSetVisible ( aPlayersTab.VehicleOptions, true )
			guiBringToFront ( aPlayersTab.VehicleOptions )
		elseif ( source == aPlayersTab.WeaponDropDown ) then
			guiSetVisible ( aPlayersTab.WeaponOptions, true )
			guiBringToFront ( aPlayersTab.WeaponOptions )
		elseif ( source == aPlayersTab.SlapDropDown ) then
			guiSetVisible ( aPlayersTab.SlapOptions, true )
			guiBringToFront ( aPlayersTab.SlapOptions )
		elseif ( source == aPlayersTab.PlayerList ) then
			if ( guiGridListGetSelectedItem( aPlayersTab.PlayerList ) ~= -1 ) then
				local player = aPlayersTab.onRefresh ()
				if ( player ) then
					triggerServerEvent ( "aSync", getLocalPlayer(), "player", player )
					guiSetText ( aPlayersTab.IP, "IP: "..aPlayers[player]["IP"] )
					guiSetText ( aPlayersTab.Serial, "Serial: "..(aPlayers[player]["serial"] or "N/A") )
					guiSetText ( aPlayersTab.Country, "Country: ".. (aPlayers[player]["countryname"] or "Unknown") )
					if ( aPlayers[player]["country"] ) then
						local x, y = guiGetPosition ( aPlayersTab.IP, false )
						local width = guiLabelGetTextExtent ( aPlayersTab.IP )
						guiSetPosition ( aPlayersTab.Flag, x + width + 3, y + 4, false )
						if ( not guiStaticImageLoadImage ( aPlayersTab.Flag, "client\\images\\flags\\"..tostring ( aPlayers[player]["country"] )..".png" ) ) then
							guiStaticImageLoadImage ( aPlayersTab.Flag, "client\\images\\empty.png" ) end
					else
						guiStaticImageLoadImage ( aPlayersTab.Flag, "client\\images\\empty.png" )
					end
				end
			else
				guiSetText ( aPlayersTab.Name, "Name: N/A" )
				guiSetText ( aPlayersTab.IP, "IP: N/A" )
				guiSetText ( aPlayersTab.Serial, "Serial: N/A" )
				guiSetText ( aPlayersTab.Account, "Account: N/A" )
				guiSetText ( aPlayersTab.Country, "Country: Unknown" )
				guiSetText ( aPlayersTab.Groups, "Groups: N/A" )
				guiSetText ( aPlayersTab.Mute, "Stfu" )
				guiSetText ( aPlayersTab.Freeze, "Freeze" )
				guiSetText ( aPlayersTab.Admin, "Give admin rights" )
				guiSetText ( aPlayersTab.Health, "Health: 0%" ) 
				guiSetText ( aPlayersTab.Armour, "Armour: 0%" )
				guiSetText ( aPlayersTab.Skin, "Skin: N/A" )
				guiSetText ( aPlayersTab.Team, "Team: None" )
				guiSetText ( aPlayersTab.Ping, "Ping: 0" )
				guiSetText ( aPlayersTab.Money, "Money: 0" )
				guiSetText ( aPlayersTab.Dimension, "Dimension: 0" )
				guiSetText ( aPlayersTab.Interior, "Interior: 0" )
				guiSetText ( aPlayersTab.JetPack, "Give JetPack" )
				guiSetText ( aPlayersTab.Weapon, "Weapon: N/A" )
				guiSetText ( aPlayersTab.Area, "Area: Unknown" )
				guiSetText ( aPlayersTab.PositionX, "X: 0" )
				guiSetText ( aPlayersTab.PositionY, "Y: 0" )
				guiSetText ( aPlayersTab.PositionZ, "Z: 0" )
				guiSetText ( aPlayersTab.Vehicle, "Vehicle: N/A" )
				guiSetText ( aVehicleHealth, "Vehicle Health: 0%" )
				guiStaticImageLoadImage ( aPlayersTab.Flag, "client\\images\\empty.png" )
			end
		end
	elseif ( button == "right" ) then
		if ( source == aPlayersTab.GiveWeapon ) then aInputBox ( "Weapon Ammo", "Ammo value from 1 to 9999", "100", "aPlayersTab.SetCurrentAmmo ( $value )" )
		end
	end
end

function aPlayersTab.onClientDoubleClick ( button )
	if ( source == aPlayersTab.WeaponOptions ) then
		if ( guiGridListGetSelectedItem ( aPlayersTab.WeaponOptions ) ~= -1 ) then
			aPlayersTab.CurrentWeapon = getWeaponIDFromName ( guiGridListGetItemText ( aPlayersTab.WeaponOptions, guiGridListGetSelectedItem ( aPlayersTab.WeaponOptions ), 1 ) )
			local wep = guiGridListGetItemText ( aPlayersTab.WeaponOptions, guiGridListGetSelectedItem ( aPlayersTab.WeaponOptions ), 1 )
			wep = string.gsub ( wep, "Combat Shotgun", "Combat SG" )
			guiSetText ( aPlayersTab.GiveWeapon, "Give: "..wep.." " )
		end
		guiSetVisible ( aPlayersTab.WeaponOptions, false )
	elseif ( source == aPlayersTab.VehicleOptions ) then
		local item = guiGridListGetSelectedItem ( aPlayersTab.VehicleOptions )
		if ( item ~= -1 ) then
			if ( guiGridListGetItemText ( aPlayersTab.VehicleOptions, item, 1 ) ~= "" ) then
				aPlayersTab.CurrentVehicle = getVehicleModelFromName ( guiGridListGetItemText ( aPlayersTab.VehicleOptions, item, 1 ) )
				guiSetText ( aPlayersTab.GiveVehicle, "Give: "..guiGridListGetItemText ( aPlayersTab.VehicleOptions, item, 1 ).." " )
			end
		end
		guiSetVisible ( aPlayersTab.VehicleOptions, false )
	elseif ( source == aPlayersTab.SlapOptions ) then
		if ( guiGridListGetSelectedItem ( aPlayersTab.SlapOptions ) ~= -1 ) then
			aPlayersTab.CurrentSlap = guiGridListGetItemText ( aPlayersTab.SlapOptions, guiGridListGetSelectedItem ( aPlayersTab.SlapOptions ), 1 )
			guiSetText ( aPlayersTab.Slap, "Slap! "..aPlayersTab.CurrentSlap.." _" )
			if ( aSpecSlap ) then guiSetText ( aSpecSlap, "Slap! "..aPlayersTab.CurrentSlap.."hp" ) end
		end
		guiSetVisible ( aPlayersTab.SlapOptions, false )
	end
	if ( guiGetVisible ( aPlayersTab.WeaponOptions ) ) then guiSetVisible ( aPlayersTab.WeaponOptions, false ) end
	if ( guiGetVisible ( aPlayersTab.VehicleOptions ) ) then guiSetVisible ( aPlayersTab.VehicleOptions, false ) end
	if ( guiGetVisible ( aPlayersTab.SlapOptions ) ) then guiSetVisible ( aPlayersTab.SlapOptions, false ) end
end

function aPlayersTab.onPlayerListSearch ()
	guiGridListClear ( aPlayersTab.PlayerList )
	local text = guiGetText ( source )
	if ( text == "" ) then
		for id, player in ipairs ( getElementsByType ( "player" ) ) do
			guiGridListSetItemText ( aPlayersTab.PlayerList, guiGridListAddRow ( aPlayersTab.PlayerList ), 1, getPlayerName ( player ), false, false )
		end
	else
		for id, player in ipairs ( getElementsByType ( "player" ) ) do
			if ( string.find ( string.upper ( getPlayerName ( player ) ), string.upper ( text ) ) ) then
				guiGridListSetItemText ( aPlayersTab.PlayerList, guiGridListAddRow ( aPlayersTab.PlayerList ), 1, getPlayerName ( player ), false, false )
			end
		end
	end
end

function aPlayersTab.onPlayerListScroll ( key, state, inc )
	if ( not guiGetVisible ( aAdminForm ) ) then return end
	local max = guiGridListGetRowCount ( aPlayersTab.PlayerList )
	if ( max <= 0 ) then return end
	local current = guiGridListGetSelectedItem ( aPlayersTab.PlayerList )
	local next = current + inc
	max = max - 1
	if ( current == -1 ) then
		guiGridListSetSelectedItem ( aPlayersTab.PlayerList, 0, 1 )
	elseif ( next > max ) then return
	elseif ( next < 0 ) then return
	else
		guiGridListSetSelectedItem ( aPlayersTab.PlayerList, next, 1 )
	end
end

function aPlayersTab.onClientPlayerChangeNick ( oldNick, newNick )
	local id = 0
	local list = aPlayersTab.PlayerList
	while ( id <= guiGridListGetRowCount( list ) ) do
		if ( guiGridListGetItemData ( list, id, 1 ) == source ) then
			guiGridListSetItemText ( list, id, 1, newNick, false, false )
		end
		id = id + 1
	end
end

function aPlayersTab.onClientPlayerJoin ( ip, username, serial, admin, country, countryname )
	aPlayers[source] = {}
	aPlayers[source]["name"] = getPlayerName ( source )
	aPlayers[source]["IP"] = ip
	aPlayers[source]["serial"] = serial or "N/A"
	aPlayers[source]["admin"] = admin
	aPlayers[source]["country"] = country
	aPlayers[source]["countryname"] = countryname
	aPlayers[source]["account"] = "Guest"
	aPlayers[source]["groups"] = "Not logged in"

	local list = aPlayersTab.PlayerList
	local row = guiGridListAddRow ( list )
	guiGridListSetItemData ( list, row, 1, source )
	guiGridListSetItemText ( list, row, 1, getPlayerName ( source ), false, false )
	if ( aSpecPlayerList ) then
		local row = guiGridListAddRow ( aSpecPlayerList )
		guiGridListSetItemText ( aSpecPlayerList, row, 1, getPlayerName ( source ), false, false )
	end
end

function aPlayersTab.onClientPlayerQuit ()
	local list = aPlayersTab.PlayerList
	local id = 0
	while ( id <= guiGridListGetRowCount( list ) ) do
		if ( guiGridListGetItemData ( list, id, 1 ) == source ) then
			guiGridListRemoveRow ( list, id )
		end
		id = id + 1
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

function aPlayersTab.onClientSync ( type, table )
	if ( type == "player" ) then
		for type, data in pairs ( table ) do
			aPlayers[source][type] = data
		end
	elseif ( type == "players" ) then
		aPlayers = table
	elseif ( type == "messages" ) then
		local prev = tonumber ( string.sub ( guiGetText ( aPlayersTab.Messages ), 1, 1 ) )
		if ( prev < table["unread"] ) then
			playSoundFrontEnd ( 18 )
		end
		guiSetText ( aPlayersTab.Messages, table["unread"].."/"..table["total"].." unread messages" )
	end
end

function aPlayersTab.onRefresh ()
	local player = getSelectedPlayer ()
	if ( player ) then
		guiSetText ( aPlayersTab.Name, "Name: "..aPlayers[player]["name"] )
		guiSetText ( aPlayersTab.Mute, iif ( aPlayers[player]["mute"], "Unstfu", "Stfu" ) )
		guiSetText ( aPlayersTab.Freeze, iif ( aPlayers[player]["freeze"], "Unfreeze", "Freeze" ) )
		guiSetText ( aPlayersTab.Groups, "Account: "..( aPlayers[player]["account"] or "N/A" ) )
		guiSetText ( aPlayersTab.Groups, "Groups: "..( aPlayers[player]["groups"] or "N/A" ) )

		if ( isPlayerDead ( player ) ) then guiSetText ( aPlayersTab.Health, "Health: Dead" )
		else guiSetText ( aPlayersTab.Health, "Health: "..math.ceil ( getElementHealth ( player ) ).."%" ) end

		guiSetText ( aPlayersTab.Armour, "Armour: "..math.ceil ( getPedArmor ( player ) ).."%" )
		guiSetText ( aPlayersTab.Skin, "Skin: "..getElementModel ( player ) or "N/A" )

		local team = getPlayerTeam ( player )
		if ( team ) then guiSetText ( aPlayersTab.Team, "Team: "..getTeamName ( team ) )
		else guiSetText ( aPlayersTab.Team, "Team: None" ) end

		guiSetText ( aPlayersTab.Ping, "Ping: "..getPlayerPing ( player ) or 0 )
		guiSetText ( aPlayersTab.Money, "Money: "..( aPlayers[player]["money"] or 0 ) )
		if ( getElementDimension ( player ) ) then guiSetText ( aPlayersTab.Dimension, "Dimension: "..getElementDimension ( player ) ) end
		if ( getElementInterior ( player ) ) then guiSetText ( aPlayersTab.Interior, "Interior: "..getElementInterior ( player ) ) end
		guiSetText ( aPlayersTab.JetPack, iif ( doesPedHaveJetPack ( player ), "Remove JetPack", "Give JetPack" ) )
			
		local weapon = getPedWeapon ( player )
		if ( weapon ) then guiSetText ( aPlayersTab.Weapon, "Weapon: "..getWeaponNameFromID ( weapon ).." (ID: "..weapon..")" ) end

		local x, y, z = getElementPosition ( player )
		local area = getZoneName ( x, y, z, false )
		local zone = getZoneName ( x, y, z, true )
		guiSetText ( aPlayersTab.Area, "Area: "..iif ( area == zone, area, area.." ("..zone..")" ) )
		guiSetText ( aPlayersTab.PositionX, "X: "..x )
		guiSetText ( aPlayersTab.PositionY, "Y: "..y )
		guiSetText ( aPlayersTab.PositionZ, "Z: "..z )

		local vehicle = getPedOccupiedVehicle ( player )
		if ( vehicle ) then
			guiSetText ( aPlayersTab.Vehicle, "Vehicle: "..getVehicleName ( vehicle ).." (ID: "..getElementModel ( vehicle )..")" )
			guiSetText ( aPlayersTab.VehicleHealth, "Vehicle Health: "..math.ceil ( getElementHealth ( vehicle ) ).."%" )
		else
			guiSetText ( aPlayersTab.Vehicle, "Vehicle: Foot" )
			guiSetText ( aPlayersTab.VehicleHealth, "Vehicle Health: 0%" )
		end
	end
	return player
end

function aPlayersTab.onClientResourceStop ()
	aSetSetting ( "currentWeapon", aCurrentWeapon )
	aSetSetting ( "currentAmmo", aCurrentAmmo )
	aSetSetting ( "currentVehicle", aCurrentVehicle )
	aSetSetting ( "currentSlap", aCurrentSlap )
end

function aPlayersTab.SetCurrentAmmo ( ammo )
	ammo = tonumber ( ammo )
	if ( ( ammo ) and ( ammo > 0 ) and ( ammo < 10000 ) ) then
		aPlayersTab.CurrentAmmo = ammo
		return
	end
	messageBox ( "Invalid ammo value", MB_ERROR )
end

function getSelectedPlayer ()
	local list = aPlayersTab.PlayerList
	local item = guiGridListGetSelectedItem ( list )
	if ( item ~= -1 ) then
		return guiGridListGetItemData ( list, item, 1 )
	end
	return nil
end