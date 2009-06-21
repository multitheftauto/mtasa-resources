--
-- traffic_sensor_server.lua
--


---------------------------------------------------------------------------
--
-- Settings
--
--
--
---------------------------------------------------------------------------
function cacheSettings()
	g_Settings = {}
	g_Settings.hotkey		= getString('hotkey','F4')
end

-- Initial cache
addEventHandler('onResourceStart', g_ResRoot,
	function()
		cacheSettings()
	end
)

-- React to admin panel changes
addEvent ( "onSettingChange" )
addEventHandler('onSettingChange', g_ResRoot,
	function(name, oldvalue, value, playeradmin)
		cacheSettings()
		-- Update clients
		clientCall(g_Root,'updateSettings', g_Settings, playeradmin)
	end
)

-- New player joined
addEvent('onLoadedAtClient_rts', true)
addEventHandler('onLoadedAtClient_rts', g_Root,
	function()
		-- Tell newly joined client current settings
		clientCall(source,'updateSettings', g_Settings)
	end
)

