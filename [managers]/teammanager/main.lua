addEvent ("onPlayerTeamSwitch")
local settings = {
	"balance_teams",
	"balance_threshold",
	"autobalance_teams",
	"autobalance_threshold",
	"friendly_fire",
}

function handlePlayer ( player, teams, gamemodeName )
	if not isElement(player) or getElementType(player) ~= "player" then
		outputDebugString ( "teammanager: Error, bad 'player' argument" )
		return false
	end
	for t1,t2 in pairs(teams) do
		if isElement(t1) then
			setTeamFriendlyFire ( t1, get"friendly_fire" )
		end
		if isElement(t2) then
			setTeamFriendlyFire ( t2, get"friendly_fire" )
		end
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
	function ( team, scriptRequested )
		local prevTeam = getPlayerTeam ( client )
		if triggerEvent ( "onPlayerTeamSwitch", client, prevTeam, team, scriptRequested and "script" or "manual" ) then
			setPlayerTeam ( client, team )
		end
	end
)
