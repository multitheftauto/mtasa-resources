--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\main\admin.lua
*
*	Original File by lil_Toady
*
**************************************]]

aAdminMain = {
	Form = nil,
	Panel = nil,
	Tabs = {},
	Widgets = {},
	Refresh = 0
}

addEvent ( "aClientAdminMenu", true )
addEvent ( "onAdminInitialize", true )
addEvent ( "onAdminRefresh", false )

function aAdminMain.Open ()
	if ( aAdminMain.Form == nil ) then
		local x, y = guiGetScreenSize()
		aAdminMain.Form		= guiCreateWindow ( x / 2 - 310, y / 2 - 260, 620, 520, "Admin Menu - v".._version, false )
						  guiSetText ( aAdminMain.Form, "Admin Menu - v".._version )
						  guiCreateLabel ( 0.75, 0.05, 0.45, 0.04, "Admin Panel by lil_Toady", true, aAdminMain.Form )
		aAdminMain.Panel		= guiCreateTabPanel ( 0.01, 0.05, 0.98, 0.95, true, aAdminMain.Form )

		aAdminMain.AddTab ( "Players", aPlayersTab, "players" )
		aAdminMain.AddTab ( "Resources", aResourcesTab, "resources" )
		aAdminMain.AddTab ( "Server", aServerTab, "server" )
		aAdminMain.AddTab ( "Bans", aBansTab, "bans" )
		aAdminMain.AddTab ( "Admin Chat", aChatTab, "adminchat" )
		aAdminMain.AddTab ( "ACL", aACLTab, "acl" )
		aAdminMain.AddTab ( "Options", aOptionsTab )

		addEventHandler ( "onClientGUITabSwitched", _root, aAdminMain.Switch )
		addEventHandler ( "onAdminInitialize", aAdminMain.Form, aAdminMain.Initialize )
 
		triggerEvent ( "onAdminInitialize", aAdminMain.Form )
	end
	guiSetVisible ( aAdminMain.Form, true )
	showCursor ( true )
end

function aAdminMain.Close ( destroy )
	if ( destroy ) then
		destroyElement ( aAdminMain.Form )
		aAdminMain.Form = nil
	else
		guiSetVisible ( aAdminMain.Form, false )
	end
	guiSetInputEnabled ( false )
	showCursor ( false )
end

function aAdminMain.Initialize ()
	if ( #aAdminMain.Tabs > 0 ) then
		aAdminMain.Switch ( aAdminMain.Tabs[1].Tab )
	end
end

addEventHandler ( "aClientAdminMenu", _root, function ()
	guiSetInputEnabled ( false )
	if ( aAdminMain.Form ) and ( guiGetVisible ( aAdminMain.Form ) == true ) then
		for id, widget in pairs ( aAdminMain.Widgets ) do
			widget.close ( false )
		end
		aAdminMain.Close ( false )
	else
		aAdminMain.Open ()
	end
end )

function aAdminMain.Switch ( tab )
	local id = aAdminMain.GetTab ( tab )
	if ( id ) then
		if ( not aAdminMain.Tabs[id].Loaded ) then
			aAdminMain.Tabs[id].Class.Create ( tab )
			aAdminMain.Tabs[id].Loaded = true
		end
	end
end

function aAdminMain.AddTab ( name, class, acl )
	local tab = guiCreateTab ( name, aAdminMain.Panel, acl )
	table.insert ( aAdminMain.Tabs, { Tab = tab, Class = class, Loaded = false } )
end

function aAdminMain.GetTab ( tab )
	for k, v in ipairs ( aAdminMain.Tabs ) do
		if ( v.Tab == tab ) then return k end
	end
	return nil
end

function aRegister ( name, welement, fopen, fclose )
	aAdminMain.Widgets[name] = {}
	aAdminMain.Widgets[name].element = welement
	aAdminMain.Widgets[name].initialize = fopen
	aAdminMain.Widgets[name].close = fclose
end

addEventHandler ( "onClientRender", _root, function ()
	if ( getTickCount () > aAdminMain.Refresh ) then
		triggerEvent ( "onAdminRefresh", _root )
		aAdminMain.Refresh = getTickCount () + 100
	end
end )