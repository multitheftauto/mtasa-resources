addEvent ("onPlayerTeamSwitch")
local settings = {
	"balance_teams",
	"balance_threshold",
	"autobalance_teams",
	"autobalance_threshold",
}

function handlePlayer ( player, teams, gamemodeName )
	if not isElement(player) or getElementType(player) ~= "player" then
		outputDebugString ( "teammanager: Error, bad 'player' argument" )
		return false
	end
	local i = 0
	for _ in pairs(teams) do
		i = i + 1
	end
	if i == 0 then
		outputDebugString ( "teammanager: Error, teams table only has one entry" )
		return false
	end
	return triggerClientEvent ( player, "rpc_handlePlayer", player, teams )
end

function autoBalance()
	if get(autobalance_teams) then
		--stuffs
	end
end

--A little hacky, check every 30 seconds for updated settings
function updateSettings()
	for _,settingName in ipairs(settings) do
		setElementData(resourceRoot,settingName,get(settingName) )
	end
end
updateSettings()
setTimer ( updateSettings, 30000, 0 )

addEvent ("rpc_playerTeamSwitch",true)
addEventHandler ( "rpc_playerTeamSwitch", root,
	function ( team )
		local prevTeam = getPlayerTeam ( client )
		if triggerEvent ( "onPlayerTeamSwitch", client, prevTeam, team, "manual" ) then
			setPlayerTeam ( client, team )
		end
	end
)