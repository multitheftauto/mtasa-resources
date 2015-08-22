
---------------------------------------------------------------------------
--
-- Settings
--
--
--
---------------------------------------------------------------------------

-- Get option updates from the server
addEvent ( "race_ghost.updateOptions", true )
addEventHandler('race_ghost.updateOptions', resourceRoot,
	function( gameOptions )
		g_GameOptions = gameOptions
		if playback then
			playback:onUpdateOptions()
		end
	end
)
