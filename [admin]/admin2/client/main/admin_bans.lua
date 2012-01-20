--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\main\admin_bans.lua
*
*	Original File by lil_Toady
*
**************************************]]

aBansTab = {
	List = {}
}

function aBansTab.Create ( tab )
	aBansTab.Tab = tab

	aBansTab.BansListSearch = guiCreateEdit ( 0.01, 0.02, 0.3, 0.04, "", true, aBansTab.Tab )
					  guiCreateInnerImage ( "client\\images\\search.png", aBansTab.BansListSearch )
					  guiHandleInput ( aBansTab.BansListSearch )
	aBansTab.BansList		= guiCreateGridList ( 0.01, 0.07, 0.80, 0.91, true, aBansTab.Tab )
					  guiGridListAddColumn ( aBansTab.BansList, "Name", 0.22 )
					  guiGridListAddColumn ( aBansTab.BansList, "IP", 0.25 )
					  guiGridListAddColumn ( aBansTab.BansList, "Serial", 0.25 )
					  guiGridListAddColumn ( aBansTab.BansList, "Username", 0.25 )
					  guiGridListAddColumn ( aBansTab.BansList, "Date", 0.17 )
					  guiGridListAddColumn ( aBansTab.BansList, "Banned by", 0.22 )
					  guiGridListAddColumn ( aBansTab.BansList, "Temporary", 0.22 )
	aBansTab.Details		= guiCreateButton ( 0.82, 0.07, 0.17, 0.04, "Details", true, aBansTab.Tab )
	aBansTab.Unban		= guiCreateButton ( 0.82, 0.12, 0.17, 0.04, "Unban", true, aBansTab.Tab, "unban" )
	aBansTab.BansRefresh	= guiCreateButton ( 0.82, 0.94, 0.17, 0.04, "Refresh", true, aBansTab.Tab, "listbans" )

	addEventHandler ( "onClientGUIChanged", aBansTab.BansListSearch, aBansTab.onBansListSearch )
	addEventHandler ( "onClientGUIClick", aBansTab.Tab, aBansTab.onClientClick )
	addEventHandler ( EVENT_SYNC, _root, aBansTab.onClientSync )

	guiGridListClear ( aBansTab.BansList )
	sync ( SYNC_BANS )
end

function aBansTab.onClientClick ( button )
	if ( button == "left" ) then
		if ( source == aBansTab.Details ) then
			if ( guiGridListGetSelectedItem ( aBansTab.BansList ) == -1 ) then
				aMessageBox ( "error", "No ban row selected!" )
			else
				local ip = guiGridListGetItemText ( aBansTab.BansList, guiGridListGetSelectedItem( aBansTab.BansList ), 2 )
				aBanDetails ( ip )
			end
		elseif ( source == aBansTab.Unban ) then
			if ( guiGridListGetSelectedItem ( aBansTab.BansList ) == -1 ) then
				aMessageBox ( "error", "No ban row selected!" )
			else
				local selected = guiGridListGetItemText ( aBansTab.BansList, guiGridListGetSelectedItem( aBansTab.BansList ), 2 )
				if ( aBans["Serial"][selected] ) then aMessageBox ( "question", "Unban Serial "..selected.."?", "triggerServerEvent ( \"aBans\", getLocalPlayer(), \"unbanserial\", \""..selected.."\" )" )
				else aMessageBox ( "question", "Unban IP "..selected.."?", "triggerServerEvent ( \"aBans\", getLocalPlayer(), \"unbanip\", \""..selected.."\" )" ) end
			end
		elseif ( source == aBansTab.BansRefresh ) then
			guiGridListClear ( aBansTab.BansList )
			sync ( SYNC_BANS )
		end
	end
end

function aBansTab.onBansListSearch ()
	guiGridListClear ( aBansTab.BansList )
	local text = string.upper ( guiGetText ( source ) )
	if ( text == "" ) then
		aBansTab.Refresh ()
	else
		for id, ban in pairs ( aBansTab.List ) do
			if ( ( ban.nick and string.find ( string.upper ( ban.nick ), text ) ) or
			     ( ban.ip and string.find ( string.upper ( ban.ip ), text ) ) or
			     ( ban.serial and string.find ( string.upper ( ban.serial ), text ) ) or
			     ( ban.username and string.find ( string.upper ( ban.username ), text ) ) or
			     ( ban.banner and string.find ( string.upper ( ban.banner ), text ) ) ) then
				aBansTab.AddRow ( id, ban )
			end
		end
	end
end

function aBansTab.onClientSync ( type, data )
	if ( type == SYNC_BANS ) then
		aBansTab.List = data
		aBansTab.Refresh ()
	elseif ( type == SYNC_BAN ) then
		if ( data.type == "a" ) then
			aBansTab.List[data.id] = data.ban
			aBansTab.AddRow ( data.id, data.ban )
		elseif ( data.type == "d" ) then
			aBansTab.List[data.id] = nil
			aBansTab.DeleteRow ( data.id )
		end
	end
end

function aBansTab.Refresh ()
	guiGridListClear ( aBansTab.BansList )
	for id, ban in pairs ( aBansTab.List ) do
		aBansTab.AddRow ( id, ban )
	end
end

function aBansTab.AddRow ( id, data )
	local list = aBansTab.BansList
	local row = guiGridListAddRow ( list )
	guiGridListSetItemText ( list, row, 1, data.nick or "Unknown",false, false )
	guiGridListSetItemText ( list, row, 2, data.ip or "", false, false )
	guiGridListSetItemText ( list, row, 3, data.serial or "", false, false )
	guiGridListSetItemText ( list, row, 4, data.username or "", false, false )
	if ( data.time ) then
		local time = getRealTime ( data.time )
		guiGridListSetItemText ( list, row, 5, time.monthday.." "..getMonthName ( time.month ).." "..( 1900 + time.year ), false, false )
	else
		guiGridListSetItemText ( list, row, 5, "", false, false )
	end
	guiGridListSetItemText ( list, row, 6, data.banner or "", false, false )
	guiGridListSetItemText ( list, row, 7, iif ( data.unban, "Yes", "No" ), false, false )

	guiGridListSetItemData ( list, row, 1, id )
end

function aBansTab.DeleteRow ( id )
	local list = aBansTab.BansList
	for i = 1, guiGridListGetRowCount ( list ) do
		local data = guiGridListGetItemData ( list, i, 1 )
		if ( data == id ) then
			guiGridListRemoveRow ( list, i )
		end
	end
end