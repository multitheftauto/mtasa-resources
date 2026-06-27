ROUND_START_DELAY = 5000 -- delay used at beginning and end of round (ms)
WASTED_CAMERA_DURATION = 3000 -- duration of the wasted camera (ms)

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

--
--  PLAYER_STATE enum
--
enum({
    "PLAYER_JOINED",    -- player has joined the game
    "PLAYER_READY",     -- player is ready to play (post-onClientResourceStart clientside)
    "PLAYER_IN_GAME",   -- player is in-game (either spawned or waiting to respawn)
})

--
--	scoreSortingFunction: used to sort a table of players by their score
--
function scoreSortingFunction(a, b)
	return (getElementData(a, "Score") or 0) > (getElementData(b, "Score") or 0)
end