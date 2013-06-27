--
-- Anti-Cheat Control Panel
--
-- c_settings.lua
--

-----------------------------------------------------------------
-- Settings
-----------------------------------------------------------------

clientCachedSettings = {}

addEvent ( "onAcpClientSettingsChanged", true )
addEventHandler ( "onAcpClientSettingsChanged", resourceRoot,
	function ( newSettings )
		clientCachedSettings = newSettings
	end
)

function getPanelSetting(name)
	return clientCachedSettings[name]
end

function setPanelSetting(name,value)
	if clientCachedSettings[name] ~= value then
		clientCachedSettings[name] = value
		triggerServerEvent("onAcpSettingsChange", resourceRoot, name, value )
	end
end
