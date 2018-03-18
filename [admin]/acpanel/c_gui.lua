--
-- Anti-Cheat Control Panel
--
-- c_gui.lua
--

aAdminMain = {
	Form = nil,
	Panel = nil,
	Tabs = {},
	Tab = nil,
	Refresh = 0,
	Hidden = false
}

g_serverConfigSettings = {}

addEvent ( "onAdminInitialize", true )
addEvent ( "onAdminRefresh", false )

addEvent ( "onAcpClientInitialSettings", true )
addEventHandler ( "onAcpClientInitialSettings", resourceRoot,
	function ( serverConfigSettings )
		g_serverConfigSettings = serverConfigSettings;
	end
)

function getServerConfigSetting(name)
	return g_serverConfigSettings[name]
end


addEvent ( "aClientAcMenu", true )
addEventHandler ( "aClientAcMenu", resourceRoot,
	function ( mode )
		if ( ( ( aAdminMain.Form ) and ( guiGetVisible ( aAdminMain.Form ) == true ) ) or ( aAdminMain.Hidden ) or mode == "close" ) then
			aAdminMain.Close ( false )
		else
			aAdminMain.Open ()
		end
	end
)

function aAdminMain.Open ()
	if ( aAdminMain.Form == nil ) then
		local x, y = guiGetScreenSize()
		aAdminMain.Form		= guiCreateWindow ( x / 2 - 310 - 20, y / 2 - 260 - 20, 620, 520, "Anti-Cheat Panel - v".._version, false )
		aAdminMain.Panel		= guiCreateTabPanel ( 0.01, 0.05, 0.98, 0.95, true, aAdminMain.Form )

		aAdminMain.AddTab ( "Status", aAntiCheatTab, "anticheat" )
		aAdminMain.AddTab ( "Status #2", aAntiCheatTab2, "anticheat" )
		aAdminMain.AddTab ( "Block Img Mods", aBlockModsTab, "mods" )
		aAdminMain.AddTab ( "Server Config", aServerConfigTab, "server" )

		addEventHandler ( "onClientGUITabSwitched", resourceRoot, aAdminMain.Switch )
		addEventHandler ( "onAdminInitialize", aAdminMain.Form, aAdminMain.Initialize )

		triggerEvent ( "onAdminInitialize", aAdminMain.Form )
	end
	guiSetAlpha ( aAdminMain.Form, 1 )
	guiSetVisible ( aAdminMain.Form, true )
	showCursor ( true )
	aAdminMain.Hidden = false
end

function aAdminMain.Close ()
	guiSetVisible ( aAdminMain.Form, false )
	showCursor ( false )
end

function aAdminMain.Initialize ()
	if ( #aAdminMain.Tabs > 0 ) then
		aAdminMain.Switch ( aAdminMain.Tabs[1].Tab )
	end
end

function aAdminMain.Switch ( tab )
	aAdminMain.Tab = tab
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

addEventHandler ( "onClientRender", root,
	function ()
		guiSetInputMode ( "no_binds_when_editing" )
	end
)
