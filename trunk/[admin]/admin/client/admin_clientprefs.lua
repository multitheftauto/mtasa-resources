--
--
-- admin_clientprefs.lua
--
--

g_Prefs = {}

------------------------------------------------------
------------------------------------------------------
--
-- Events
--
------------------------------------------------------
------------------------------------------------------
addEvent( "onClientUpdatePrefs", true )
addEventHandler("onClientUpdatePrefs", resourceRoot, 
	function ( prefs )
		g_Prefs = prefs
	end
)
