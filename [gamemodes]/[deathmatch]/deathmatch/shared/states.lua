--
--  enum: creates a c-style enum
--
function enum ( args, prefix )
	for i, v in ipairs ( args ) do
		if ( prefix ) then _G[v] = prefix..i
		else _G[v] = i end
	end
end

--
--  GAME_STATE enum
--
enum({
    "GAME_WAITING",     -- waiting for a map to start
    "GAME_STARTING",    -- game is starting (map resource has loaded)
    "GAME_IN_PROGRESS", -- game is in progress
    "GAME_FINISHED"    -- game has ended
})