root = getRootElement()
teams = {} -- used for team game, the participating teams
settings = {	limit = 1000, teams = false, hide = false, reset = 300,
				weapons = {[1] = 1, [22] = 200, [17] = 4, [29] = 250}	}

local theBriefcase = false
local theObjective = false


addCommandHandler("newbc",
function (player, command)
	theBriefcase = Briefcase:new({})
end
)

addCommandHandler("deletebc",
function (player, command)
	theBriefcase:destroy()
	theBriefcase = false
end
)

addCommandHandler("idlebc",
function (player, command)
	local x, y, z = getElementPosition(player)
	theBriefcase:idle(x+5, y, z)
end
)

addCommandHandler("notidlebc",
function (player, command)
	theBriefcase:notIdle()
end
)

addCommandHandler("attachbc",
function (player, command)
	theBriefcase:attach(player)
end
)

addCommandHandler("detachbc",
function (player, command)
	theBriefcase:detach()
end
)



addCommandHandler("newob",
function (player, command)
	local x, y, z = getElementPosition(player)
	theObjective = Objective:new({x = x-5, y = y, z = z-1})
end
)

addCommandHandler("deleteob",
function (player, command)
	theObjective:destroy()
	theObjective = false
end
)


addCommandHandler("hitter",
function (player, command)
	theObjective:hitter(player)
end
)

addCommandHandler("nothitter",
function (player, command)
	theObjective:hitter(false)
end
)


function getValidTeams()
	return teams
end

function isPlayerOnValidTeam(player)
	local team = getPlayerTeam(player)
	if (team) then
		for i,v in ipairs(teams) do
			if (v == team) then
				return true
			end
		end
		return false
	else
		return false
	end
end

function isTeamValid(team)
	for i,v in ipairs(teams) do
		if (v == team) then
			return true
		end
	end
	return false
end

function getReadyPlayers()
	-- generate array of ready players
	if (not settings.teams) then
		return getElementsByType("player")
	else
		local playerTable = {}
		for i,team in ipairs(getElementsByType("team")) do
			if (isTeamValid(team)) then
				for j,player in ipairs(getPlayersInTeam(team)) do
					table.insert(playerTable, player)
				end
			end
		end
		return playerTable
	end
end
