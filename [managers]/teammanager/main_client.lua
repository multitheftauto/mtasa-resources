local teamsTable

function handlePlayer (teams,gamemodeName)
	--If its an array, convert it
	if teams[1] then
		teamsTable = {}
		for i,team in ipairs(teams) do
			teamsTable[team] = {}
		end
	else
		teamsTable = teams
	end
	bindKey ( ".", "down", "changeteam", "" )
	return drawMenu ( teamsTable, gamemodeName, true )
end

addEvent ( "rpc_handlePlayer", true )
addEventHandler ( "rpc_handlePlayer", root, handlePlayer )

addCommandHandler ( "changeteam",
	function()
		drawMenu(teamsTable)
	end
)
