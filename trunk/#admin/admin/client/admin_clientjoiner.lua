--
--
-- admin_clientjoiner.lua
--
-- See admin_joinerserver.lua
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
