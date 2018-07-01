--
-- Anti-Cheat Control Panel
--
-- c_joiner.lua
--
-- See s_joiner.lua
--

------------------------------------------------------
------------------------------------------------------
--
-- Events
--
------------------------------------------------------
------------------------------------------------------
addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		-- Tell server we are ready
		triggerServerEvent( "onResourceLoadedAtClient_internal", resourceRoot, getLocalPlayer() )
	end
)
