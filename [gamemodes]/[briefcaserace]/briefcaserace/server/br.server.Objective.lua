-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- OBJECTIVE OBJECT --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- bugs
--  objective isnt removed after delivery

Objective = {x = 0, y = 0, z = 0, team = false, ohitter = false}

function Objective:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	-- constructor --
	if (not o.team) then
		scheduleClientEventForPlayers(getReadyPlayers(), "clientCreateObjective", root, o.x, o.y, o.z, not settings.hide)
	else
		for i,team in ipairs(getValidTeams()) do
			for j,player in ipairs(getPlayersInTeam(team)) do
				if (team == o.team) then
					scheduleClientEvent(player, "clientCreateTeamObjective", root, o.team, true, o.x, o.y, o.z)
				else
					scheduleClientEvent(player, "clientCreateTeamObjective", root, o.team, false, o.x, o.y, o.z)
				end
			end
		end
	end
	-----------------
	return o
end

-- must always call this before deleting objective object!
function Objective:destroy()
	if (not self.team) then
		if (self.ohitter) then
			scheduleClientEvent(self.ohitter, "clientSetObjectiveHittable", root, false, not settings.hide)
		end
		scheduleClientEventForPlayers(getReadyPlayers(), "clientDestroyObjective", root)
	else
		if (self.ohitter) then
			scheduleClientEvent(self.ohitter, "clientSetTeamObjectiveHittable", root, self.team, false)
		end
		scheduleClientEventForPlayers(getReadyPlayers(), "clientDestroyTeamObjective", root, self.team)
	end
end

function Objective:hitter(player)
	if (player) then
		assert(not self.ohitter) ---:(
		if (not self.team) then
			scheduleClientEvent(player, "clientSetObjectiveHittable", root, true, not settings.hide)
		else
			scheduleClientEvent(player, "clientSetTeamObjectiveHittable", root, self.team, true)
		end
		self.ohitter = player
	else
		assert(self.ohitter)
		if (not self.team) then
			scheduleClientEvent(self.ohitter, "clientSetObjectiveHittable", root, false, not settings.hide)
		else
			scheduleClientEvent(self.ohitter, "clientSetTeamObjectiveHittable", root, self.team, false)
		end
		self.ohitter = false
	end
end

function Objective:getPosition()
	return self.x, self.y, self.z
end

function Objective:getHitter()
	return self.ohitter
end

function Objective:getTeam()
	return self.team
end
