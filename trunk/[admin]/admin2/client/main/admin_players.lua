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
aPlayers = {}

addEvent ( "aClientPlayerJoin", true )

function aPlayersTab.Create ( tab )
	aPlayersTab.Tab = tab

	aPlayersTab.Messages		= guiCreateButton ( 0.75, 0.02, 0.23, 0.04, "0/0 unread messages", true, tab )
	aPlayersTab.PlayerListSearch 	= guiCreateEdit ( 0.01, 0.02, 0.20, 0.04, "", true, tab )
					  	  guiCreateInnerImage ( "client\\images\\search.png", aPlayersTab.PlayerListSearch )
						  guiHandleInput ( aPlayersTab.PlayerListSearch )
	aPlayersTab.PlayerList		= guiCreateGridList ( 0.01, 0.07, 0.20, 0.88, true, tab )
					  	  guiGridListAddColumn ( aPlayersTab.PlayerList, "Player list", 0.85 )
	aPlayersTab.Context		= guiCreateContextMenu ( aPlayersTab.PlayerList )
	aPlayersTab.ContextKick		= guiContextMenuAddItem ( aPlayersTab.Context, "Kick" )

	aPlayersTab.ColorCodes		= guiCreateCheckBox ( 0.02, 0.95, 0.20, 0.04, "Hide color codes", true, true, tab )
						  aPlayersTab.Refresh()
	aPlayersTab.Kick			= guiCreateButton ( 0.71, 0.125, 0.13, 0.04, "Kick", true, tab, "kick" )
	aPlayersTab.Ban			= guiCreateButton ( 0.85, 0.125, 0.13, 0.04, "Ban", true, tab, "ban" )
	aPlayersTab.Mute			= guiCreateButton ( 0.71, 0.170, 0.13, 0.04, "Mute", true, tab, "mute" )
	aPlayersTab.Freeze		= guiCreateButton ( 0.85, 0.170, 0.13, 0.04, "Freeze", true, tab, "freeze" )
	aPlayersTab.Spectate		= guiCreateButton ( 0.71, 0.215, 0.13, 0.04, "Spectate", true, tab, "spectate" )
	aPlayersTab.Slap			= guiCreateButton ( 0.85, 0.215, 0.13, 0.04, "Slap! "..aPlayersTab.CurrentSlap.." _", true, tab, "slap" )
	aPlayersTab.SlapDropDown	= guiCreateInnerImage ( "client\\images\\dropdown.png", aPlayersTab.Slap, true )
	aPlayersTab.SlapOptions		= guiCreateGridList ( 0.85, 0.215, 0.13, 0.40, true, tab )
					  	  guiGridListSetSortingEnabled ( aPlayersTab.SlapOptions, false )
					  	  guiGridListAddColumn( aPlayersTab.SlapOptions, "", 0.85 )
					  	  guiSetVisible ( aPlayersTab.SlapOptions, false )
					  	  for i = 0, 10 do guiGridListSetItemText ( aPlayersTab.SlapOptions, guiGridListAddRow ( aPlayersTab.SlapOptions ), 1, tostring ( i * 10 ), false, false ) end
	aPlayersTab.SetNick		= guiCreateButton ( 0.71, 0.260, 0.13, 0.04, "Set nick", true, tab, "setnick" )
	aPlayersTab.Shout			= guiCreateButton ( 0.85, 0.260, 0.13, 0.04, "Shout!", true, tab, "shout" )
	aPlayersTab.Admin			= guiCreateButton ( 0.71, 0.305, 0.27, 0.04, "Give admin rights", true, tab, "setgroup" )
						  guiCreateHeader ( 0.23, 0.035, 0.20, 0.04, "Player:", true, tab )

	aPlayersTab.InfoContext		= guiCreateContextMenu ()
	aPlayersTab.ContextCopy		= guiContextMenuAddItem ( aPlayersTab.InfoContext, "copy" )

	aPlayersTab.Name			= guiCreateLabel ( 0.24, 0.080, 0.45, 0.035, "Name: N/A", true, tab )
						  guiSetContextMenu ( aPlayersTab.Name, aPlayersTab.InfoContext )
	aPlayersTab.IP			= guiCreateLabel ( 0.24, 0.125, 0.45, 0.035, "IP: N/A", true, tab )
						  guiSetContextMenu ( aPlayersTab.IP, aPlayersTab.InfoContext )
	aPlayersTab.Serial		= guiCreateLabel ( 0.24, 0.170, 0.45, 0.035, "Serial: N/A", true, tab )
						  guiSetContextMenu ( aPlayersTab.Serial, aPlayersTab.InfoContext )
	aPlayersTab.Country		= guiCreateLabel ( 0.24, 0.215, 0.45, 0.035, "Country: Unknown", true, tab )
	aPlayersTab.Account		= guiCreateLabel ( 0.24, 0.260, 0.45, 0.035, "Account: N/A", true, tab )
						  guiSetContextMenu ( aPlayersTab.Account, aPlayersTab.InfoContext )
	aPlayersTab.Groups		= guiCreateLabel ( 0.24, 0.305, 0.45, 0.035, "Groups: N/A", true, tab )
	aPlayersTab.Flag			= guiCreateStaticImage ( 0.40, 0.125, 0.025806, 0.021154, "client\\images\\empty.png", true, tab )
						  guiSetVisible ( aPlayersTab.Flag, false )
					  	  guiCreateHeader ( 0.23, 0.350, 0.20, 0.04, "Game:", true, tab )
	aPlayersTab.Health		= guiCreateLabel ( 0.24, 0.395, 0.20, 0.04, "Health: 0%", true, tab )
	aPlayersTab.Armour		= guiCreateLabel ( 0.45, 0.395, 0.20, 0.04, "Armour: 0%", true, tab )
	aPlayersTab.Skin			= guiCreateLabel ( 0.24, 0.440, 0.20, 0.04, "Skin: N/A", true, tab )
	aPlayersTab.Team			= guiCreateLabel ( 0.45, 0.440, 0.20, 0.04, "Team: None", true, tab )
	aPlayersTab.Weapon		= guiCreateLabel ( 0.24, 0.485, 0.35, 0.04, "Weapon: N/A", true, tab )
	aPlayersTab.Ping			= guiCreateLabel ( 0.24, 0.530, 0.20, 0.04, "Ping: 0", true, tab )
	aPlayersTab.Money			= guiCreateLabel ( 0.45, 0.530, 0.20, 0.04, "Money: 0", true, tab )
	aPlayersTab.Area			= guiCreateLabel ( 0.24, 0.575, 0.44, 0.04, "Area: Unknown", true, tab )
						  guiSetContextMenu ( aPlayersTab.Area, aPlayersTab.InfoContext )
	aPlayersTab.PositionX		= guiCreateLabel ( 0.24, 0.620, 0.30, 0.04, "X: 0", true, tab )
	aPlayersTab.PositionY		= guiCreateLabel ( 0.24, 0.665, 0.30, 0.04, "Y: 0", true, tab )
	aPlayersTab.PositionZ		= guiCreateLabel ( 0.24, 0.710, 0.30, 0.04, "Z: 0", true, tab )
						  guiSetContextMenu ( aPlayersTab.PositionX, aPlayersTab.InfoContext )
						  guiSetContextMenu ( aPlayersTab.PositionY, aPlayersTab.InfoContext )
						  guiSetContextMenu ( aPlayersTab.PositionZ, aPlayersTab.InfoContext )
	aPlayersTab.Dimension		= guiCreateLabel ( 0.24, 0.755, 0.20, 0.04, "Dimension: 0", true, tab )
	aPlayersTab.Interior		= guiCreateLabel ( 0.45, 0.755, 0.20, 0.04, "Interior: 0", true, tab )
	aPlayersTab.SetHealth		= guiCreateButton ( 0.71, 0.395, 0.13, 0.04, "Set Health", true, tab, "sethealth" )
	aPlayersTab.SetArmour		= guiCreateButton ( 0.85, 0.395, 0.13, 0.04, "Set Armour", true, tab, "setarmour" )
	aPlayersTab.SetSkin		= guiCreateButton ( 0.71, 0.440, 0.13, 0.04, "Set Skin", true, tab, "setskin" )
	aPlayersTab.SetTeam		= guiCreateButton ( 0.85, 0.440, 0.13, 0.04, "Set Team", true, tab, "setteam" )
	aPlayersTab.SetDimension	= guiCreateButton ( 0.71, 0.755, 0.13, 0.04, "Set Dimens.", true, tab, "setdimension" )
	aPlayersTab.SetInterior		= guiCreateButton ( 0.85, 0.755, 0.13, 0.04, "Set Interior", true, tab, "setinterior" )
	aPlayersTab.GiveWeapon		= guiCreateButton ( 0.71, 0.485, 0.27, 0.04, "Give: "..getWeaponNameFromID ( aPlayersTab.CurrentWeapon ), true, tab )
	aPlayersTab.WeaponDropDown	= guiCreateInnerImage ( "client\\images\\dropdown.png", aPlayersTab.GiveWeapon, true )
	aPlayersTab.WeaponOptions	= guiCreateGridList ( 0.71, 0.485, 0.27, 0.48, true, tab )
						  guiGridListAddColumn( aPlayersTab.WeaponOptions, "", 0.85 )
						  guiSetVisible ( aPlayersTab.WeaponOptions, false )
						  for i = 1, 46 do if ( getWeaponNameFromID ( i ) ~= false ) then guiGridListSetItemText ( aPlayersTab.WeaponOptions, guiGridListAddRow ( aPlayersTab.WeaponOptions ), 1, getWeaponNameFromID ( i ), false, false ) end end
	aPlayersTab.SetMoney		= guiCreateButton ( 0.71, 0.530, 0.13, 0.04, "Set Money", true, tab, "setmoney" )
	aPlayersTab.SetStats		= guiCreateButton ( 0.85, 0.530, 0.13, 0.04, "Set Stats", true, tab, "setstat" )
	aPlayersTab.JetPack		= guiCreateButton ( 0.71, 0.575, 0.27, 0.04, "Give JetPack", true, tab, "jetpack" )
					  	  guiCreateHeader ( 0.23, 0.805, 0.20, 0.04, "Vehicle:", true, tab )
	aPlayersTab.Vehicle		= guiCreateLabel ( 0.24, 0.850, 0.35, 0.04, "Vehicle: N/A", true, tab )
	aPlayersTab.VehicleHealth	= guiCreateLabel ( 0.24, 0.895, 0.25, 0.04, "Vehicle Health: 0%", true, tab )
	aPlayersTab.VehicleFix		= guiCreateButton ( 0.71, 0.85, 0.13, 0.04, "Fix", true, tab, "repair" )
	aPlayersTab.VehicleDestroy	= guiCreateButton ( 0.71, 0.90, 0.13, 0.04, "Destroy", true, tab, "destroyvehicle" )
	aPlayersTab.VehicleBlow		= guiCreateButton ( 0.85, 0.85, 0.13, 0.04, "Blow", true, tab, "blowvehicle" )
	aPlayersTab.VehicleCustomize 	= guiCreateButton ( 0.85, 0.90, 0.13, 0.04, "Customize", true, tab, "customize" )
	aPlayersTab.GiveVehicle		= guiCreateButton ( 0.71, 0.710, 0.27, 0.04, "Give: "..getVehicleNameFromModel ( aPlayersTab.CurrentVehicle ), true, tab, "givevehicle" )
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

	addEventHandler ( "onClientGUIClick", aPlayersTab.Context, aPlayersTab.onContextClick )
	addEventHandler ( "onClientGUIClick", aPlayersTab.InfoContext, aPlayersTab.onContextClick )
	addEventHandler ( "onClientGUIClick", aPlayersTab.Tab, aPlayersTab.onClientClick )
	addEventHandler ( "onClientGUIClick", aPlayersTab.VehicleOptions, aPlayersTab.onClientClick )
	addEventHandler ( "onClientGUIChanged", aPlayersTab.PlayerListSearch, aPlayersTab.onPlayerListSearch )
	addEventHandler ( "onClientPlayerChangeNick", _root, aPlayersTab.onClientPlayerChangeNick )
	addEventHandler ( "aClientPlayerJoin", _root, aPlayersTab.onClientPlayerJoin )
	addEventHandler ( "onClientPlayerQuit", _root, aPlayersTab.onClientPlayerQuit )
	addEventHandler ( EVENT_SYNC, _root, aPlayersTab.onClientSync )
	addEventHandler ( "onClientResourceStop", getResourceRootElement(), aPlayersTab.onClientResourceStop )
	addEventHandler ( "onAdminRefresh", aPlayersTab.Tab, aPlayersTab.onRefresh )

	sync ( SYNC_PLAYERS )
	if ( hasPermissionTo ( "command.listmessages" ) ) then sync ( SYNC_MESSAGES ) end

	bindKey ( "arrow_d", "down", aPlayersTab.onPlayerListScroll, 1 )
	bindKey ( "arrow_u", "down", aPlayersTab.onPlayerListScroll, -1 )
end

function aPlayersTab.onContextClick ( button )
	local translator = {
		[aPlayersTab.ContextKick] = aPlayersTab.Kick
	}
	if ( translator[source] ) then
		source = translator[source]
		aPlayersTab.onClientClick ( button )
	elseif ( source == aPlayersTab.ContextCopy ) then
		if ( contextSource ) then
			local copy = string.sub ( guiGetText ( contextSource ), guiGetText ( contextSource ):match ( "%w+:" ):len() + 2 )
			setClipboard ( copy )
		end
	end
end

function aPlayersTab.onClientClick ( button )
	if ( guiGetVisible ( aPlayersTab.WeaponOptions ) and ( source ~= aPlayersTab.WeaponOptions ) ) then guiSetVisible ( aPlayersTab.WeaponOptions, false ) end
	if ( guiGetVisible ( aPlayersTab.VehicleOptions ) and ( source ~= aPlayersTab.VehicleOptions ) ) then guiSetVisible ( aPlayersTab.VehicleOptions, false ) end
	if ( guiGetVisible ( aPlayersTab.SlapOptions ) and ( source ~= aPlayersTab.SlapOptions ) ) then guiSetVisible ( aPlayersTab.SlapOptions, false ) end
	if ( button == "left" ) then
		if ( source == aPlayersTab.WeaponOptions ) then
			local item = guiGridListGetSelectedItem ( aPlayersTab.WeaponOptions )
			if ( item ~= -1 ) then
				aPlayersTab.CurrentWeapon = getWeaponIDFromName ( guiGridListGetItemText ( aPlayersTab.WeaponOptions, item, 1 ) )
				local wep = guiGridListGetItemText ( aPlayersTab.WeaponOptions, item, 1 )
				wep = string.gsub ( wep, "Combat Shotgun", "Combat SG" )
				guiSetText ( aPlayersTab.GiveWeapon, "Give: "..wep.." " )
				guiSetVisible ( aPlayersTab.WeaponOptions, false )
			end
		elseif ( source == aPlayersTab.VehicleOptions ) then
			local item = guiGridListGetSelectedItem ( aPlayersTab.VehicleOptions )
			if ( item ~= -1 ) then
				aPlayersTab.CurrentVehicle = getVehicleModelFromName ( guiGridListGetItemText ( aPlayersTab.VehicleOptions, item, 1 ) )
				guiSetText ( aPlayersTab.GiveVehicle, "Give: "..guiGridListGetItemText ( aPlayersTab.VehicleOptions, item, 1 ).." " )
				guiSetVisible ( aPlayersTab.VehicleOptions, false )
			end
		elseif ( source == aPlayersTab.SlapOptions ) then
			local item = guiGridListGetSelectedItem ( aPlayersTab.SlapOptions )
			if ( item ~= -1 ) then
				aPlayersTab.CurrentSlap = guiGridListGetItemText ( aPlayersTab.SlapOptions, item, 1 )
				guiSetText ( aPlayersTab.Slap, "Slap! "..aPlayersTab.CurrentSlap.." _" )
				if ( aSpecSlap ) then guiSetText ( aSpecSlap, "Slap! "..aPlayersTab.CurrentSlap.."hp" ) end
				guiSetVisible ( aPlayersTab.SlapOptions, false )
			end
		end
		if ( source == aPlayersTab.Messages ) then
			aMessages.Open ()
		elseif ( getElementType ( source ) == "gui-button" )  then
			if ( source == aPlayersTab.GiveVehicle ) then guiBringToFront ( aPlayersTab.VehicleDropDown )
			elseif ( source == aPlayersTab.GiveWeapon ) then guiBringToFront ( aPlayersTab.WeaponDropDown )
			elseif ( source == aPlayersTab.Slap ) then guiBringToFront ( aPlayersTab.SlapDropDown ) end
			if ( guiGridListGetSelectedItem ( aPlayersTab.PlayerList ) == -1 ) then
				messageBox ( "No player selected!", MB_ERROR, MB_OK )
			else
				local player = getSelectedPlayer ()
				local name = getPlayerName ( player )
				if ( source == aPlayersTab.Kick ) then local reason = inputBox ( "Kick player "..name, "Enter the kick reason" ) if ( reason ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "kick", reason ) end
				elseif ( source == aPlayersTab.Ban ) then local reason = inputBox ( "Ban player "..name, "Enter the ban reason" ) if ( reason ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "ban", reason ) end
				elseif ( source == aPlayersTab.Slap ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "slap", aPlayersTab.CurrentSlap )
				elseif ( source == aPlayersTab.Mute ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, iif ( aPlayers[player].mute, "unmute", "mute" ) )
				elseif ( source == aPlayersTab.Freeze ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, iif ( aPlayers[player].freeze, "unfreeze", "freeze" ) )
				elseif ( source == aPlayersTab.Spectate ) then aSpectate ( player )
				elseif ( source == aPlayersTab.SetNick ) then local nick = inputBox ( "Set nick", "Enter new nickname for "..name ) if ( nick ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "setnick", nick ) end
				elseif ( source == aPlayersTab.Shout ) then local shout = inputBox ( "Shout", "Enter text to be shown on player's screen" ) if ( shout ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "shout", shout ) end
				elseif ( source == aPlayersTab.SetHealth ) then local health = inputBox ( "Set health", "Enter the health value", "100" ) if ( health ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "sethealth", health ) end
				elseif ( source == aPlayersTab.SetArmour ) then local armour = inputBox ( "Set armour", "Enter the armour value", "100" ) if ( armour ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "setarmour", armour ) end
				elseif ( source == aPlayersTab.SetTeam ) then aTeam.Show ()
				elseif ( source == aPlayersTab.SetSkin ) then aSkin.Show ( player )
				elseif ( source == aPlayersTab.SetInterior ) then aPlayerInterior ( player )
				elseif ( source == aPlayersTab.JetPack ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "jetpack" )
				elseif ( source == aPlayersTab.SetMoney ) then local money = inputBox ( "Set money", "Enter the money value" ) if ( money ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "setmoney", money ) end
				elseif ( source == aPlayersTab.SetStats ) then aPlayerStats ( player )
				elseif ( source == aPlayersTab.SetDimension ) then local dimension = inputBox ( "Set dimension", "Enter dimension ID between 0 and 65535", "0" ) if ( dimension ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "setdimension", dimension ) end
				elseif ( source == aPlayersTab.GiveVehicle ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "givevehicle", aPlayersTab.CurrentVehicle )
				elseif ( source == aPlayersTab.GiveWeapon ) then triggerServerEvent ( "aPlayer", getLocalPlayer(), player, "giveweapon", aPlayersTab.CurrentWeapon, aPlayersTab.CurrentAmmo )
				elseif ( source == aPlayersTab.VehicleFix ) then triggerServerEvent ( "aVehicle", getLocalPlayer(), player, "repair" )
				elseif ( source == aPlayersTab.VehicleBlow ) then triggerServerEvent ( "aVehicle", getLocalPlayer(), player, "blowvehicle" )
				elseif ( source == aPlayersTab.VehicleDestroy ) then triggerServerEvent ( "aVehicle", getLocalPlayer(), player, "destroyvehicle" )
				elseif ( source == aPlayersTab.VehicleCustomize ) then aVehicle.Open ( getPedOccupiedVehicle ( player ) )
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
		elseif ( source == aPlayersTab.ColorCodes ) then
			aPlayersTab.Refresh()
		elseif ( source == aPlayersTab.PlayerList ) then
			local player = getSelectedPlayer ()
			if ( player ) then
				aPlayersTab.onRefresh ()
				sync ( SYNC_PLAYER, player )
				guiSetText ( aPlayersTab.IP, "IP: "..aPlayers[player].ip )
				guiSetText ( aPlayersTab.Serial, "Serial: "..( aPlayers[player].serial or "Unknown" ) )
				guiSetText ( aPlayersTab.Country, "Country: ".. ( aPlayers[player].countryname or "Unknown" ) )
				guiSetText ( aPlayersTab.Account, "Account: "..( aPlayers[player]["account"] or "guest" ) )
				guiSetText ( aPlayersTab.Groups, "Groups: "..( aPlayers[player]["groups"] or "None" ) )
				if ( aPlayers[player].country and string.lower ( tostring ( aPlayers[player].country ) ) ~= "zz" ) then
					local x, y = guiGetPosition ( aPlayersTab.Country, false )
					local width = guiLabelGetTextExtent ( aPlayersTab.Country )
					guiSetPosition ( aPlayersTab.Flag, x + width + 3, y + 4, false )
					guiSetVisible ( aPlayersTab.Flag, guiStaticImageLoadImage ( aPlayersTab.Flag, "client\\images\\flags\\"..string.lower ( tostring ( aPlayers[player].country ) )..".png" ) )
				else
					guiSetVisible ( aPlayersTab.Flag, false )
				end
			else
				guiSetText ( aPlayersTab.Name, "Name: N/A" )
				guiSetText ( aPlayersTab.IP, "IP: N/A" )
				guiSetText ( aPlayersTab.Serial, "Serial: N/A" )
				guiSetText ( aPlayersTab.Account, "Account: N/A" )
				guiSetText ( aPlayersTab.Country, "Country: Unknown" )
				guiSetText ( aPlayersTab.Groups, "Groups: N/A" )
				guiSetText ( aPlayersTab.Mute, "Mute" )
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
				guiSetText ( aPlayersTab.VehicleHealth, "Vehicle Health: 0%" )
				guiSetVisible ( aPlayersTab.Flag, false )
			end
		end
	elseif ( button == "right" ) then
		if ( source == aPlayersTab.GiveWeapon ) then
			local ammo = inputBox ( "Weapon Ammo", "Enter ammo value between 1 and 9999", "100" )
			if ( ammo ) then
				ammo = tonumber ( ammo )
				if ( ( ammo ) and ( ammo > 0 ) and ( ammo < 10000 ) ) then
					aPlayersTab.CurrentAmmo = ammo
					return
				end
				messageBox ( "Invalid ammo value", MB_ERROR )
			end
		end
	end
end

function aPlayersTab.onPlayerListSearch ()
	guiGridListClear ( aPlayersTab.PlayerList )
	local text = guiGetText ( source )
	if ( text == "" ) then
		for id, player in ipairs ( getElementsByType ( "player" ) ) do
			local row = guiGridListAddRow ( aPlayersTab.PlayerList )
			guiGridListSetItemText ( aPlayersTab.PlayerList, row, 1, getPlayerName ( player ), false, false )
			guiGridListSetItemData ( aPlayersTab.PlayerList, row, 1, player )
		end
	else
		for id, player in ipairs ( getElementsByType ( "player" ) ) do
			if ( string.find ( string.upper ( getPlayerName ( player ) ), string.upper ( text ) ) ) then
				local row = guiGridListAddRow ( aPlayersTab.PlayerList )
				guiGridListSetItemText ( aPlayersTab.PlayerList, row, 1, getPlayerName ( player ), false, false )
				guiGridListSetItemData ( aPlayersTab.PlayerList, row, 1, player )
			end
		end
	end
end

function aPlayersTab.onPlayerListScroll ( key, state, inc )
	if ( not guiGetVisible ( aAdminMain.Form ) ) then return end
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
			if ( guiCheckBoxGetSelected ( aPlayersTab.ColorCodes ) ) then
				guiGridListSetItemText ( list, id, 1, stripColorCodes ( newNick ), false, false )
			else
				guiGridListSetItemText ( list, id, 1, newNick, false, false )
			end
		end
		id = id + 1
	end
end

function aPlayersTab.onClientPlayerJoin ( ip, username, serial, country, countryname )
	aPlayers[source] = {}
	aPlayers[source].name = getPlayerName ( source )
	aPlayers[source].ip = ip
	aPlayers[source].serial = serial or "N/A"
	aPlayers[source].country = country
	aPlayers[source].countryname = countryname
	aPlayers[source].account = "guest"
	aPlayers[source].groups = "None"

	local list = aPlayersTab.PlayerList
	local row = guiGridListAddRow ( list )
	if ( guiCheckBoxGetSelected ( aPlayersTab.ColorCodes ) ) then
		guiGridListSetItemText ( list, row, 1, stripColorCodes ( getPlayerName ( source ) ), false, false )
	else
		guiGridListSetItemText ( list, row, 1, getPlayerName ( source ), false, false )
	end
	guiGridListSetItemData ( list, row, 1, source )
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
	if ( type == SYNC_PLAYER ) then
		for type, data in pairs ( table ) do
			aPlayers[source][type] = data
		end
	elseif ( type == SYNC_PLAYERS ) then
		aPlayers = table
	elseif ( type == SYNC_MESSAGES ) then
		local prev = tonumber ( string.sub ( guiGetText ( aPlayersTab.Messages ), 1, 1 ) )
		if ( prev < table["unread"] ) then
			playSoundFrontEnd ( 18 )
		end
		guiSetText ( aPlayersTab.Messages, table["unread"].."/"..table["total"].." unread messages" )
	end
end

function aPlayersTab.onRefresh ()
	local player = getSelectedPlayer ()
	if ( not player ) then
		return
	end

	local data = aPlayers[player]
	if ( not data ) then
		return
	end

	guiSetText ( aPlayersTab.Name, "Name: "..getPlayerName ( player ) )
	guiSetText ( aPlayersTab.Mute, iif ( aPlayers[player].mute, "Unmute", "Mute" ) )
	guiSetText ( aPlayersTab.Freeze, iif ( aPlayers[player].freeze, "Unfreeze", "Freeze" ) )

	if ( isPlayerDead ( player ) ) then guiSetText ( aPlayersTab.Health, "Health: Dead" )
	else guiSetText ( aPlayersTab.Health, "Health: "..math.ceil ( getElementHealth ( player ) ).."%" ) end

	guiSetText ( aPlayersTab.Armour, "Armour: "..math.ceil ( getPedArmor ( player ) ).."%" )
	guiSetText ( aPlayersTab.Skin, "Skin: "..getElementModel ( player ) or "N/A" )

	local team = getPlayerTeam ( player )
	if ( team ) then guiSetText ( aPlayersTab.Team, "Team: "..getTeamName ( team ) )
	else guiSetText ( aPlayersTab.Team, "Team: None" ) end

	guiSetText ( aPlayersTab.Ping, "Ping: "..getPlayerPing ( player ) or 0 )
	guiSetText ( aPlayersTab.Money, "Money: "..( aPlayers[player].money or 0 ) )
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

	return player
end

function aPlayersTab.onClientResourceStop ()
	aSetSetting ( "currentWeapon", aCurrentWeapon )
	aSetSetting ( "currentAmmo", aCurrentAmmo )
	aSetSetting ( "currentVehicle", aCurrentVehicle )
	aSetSetting ( "currentSlap", aCurrentSlap )
end

function aPlayersTab.Refresh ()
	local selected = getSelectedPlayer ()
	local list = aPlayersTab.PlayerList
	guiGridListClear ( list )
	local strip = guiCheckBoxGetSelected ( aPlayersTab.ColorCodes )
	for id, player in ipairs ( getElementsByType ( "player" ) ) do
		local row = guiGridListAddRow ( list )
		local name = getPlayerName ( player )
		if ( strip ) then name = stripColorCodes ( name ) end
		guiGridListSetItemText ( list, row, 1, name, false, false )
		guiGridListSetItemData ( list, row, 1, player )
		if ( player == selected ) then
			guiGridListSetSelectedItem ( list, row, 1 )
		end
	end
end

function getSelectedPlayer ()
	local list = aPlayersTab.PlayerList
	local item = guiGridListGetSelectedItem ( list )
	if ( item ~= -1 ) then
		return guiGridListGetItemData ( list, item, 1 )
	end
	return nil
end