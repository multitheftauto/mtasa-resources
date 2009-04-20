DestructionDerby = setmetatable({}, RaceMode)
DestructionDerby.__index = DestructionDerby

DestructionDerby:register('Destruction derby')

function DestructionDerby:isApplicable()
	return not RaceMode.checkpointsExist() and RaceMode.getMapOption('respawn') == 'none'
end

function DestructionDerby:getPlayerRank(player)
	return #getAlivePlayers()
end

function DestructionDerby:onPlayerWasted(player)
	if RaceMode.isPlayerFinished(player) then
		return
	end
	if not self.rankingBoard then
		self.rankingBoard = RankingBoard:create()
		self.rankingBoard:setDirection('up')
	end
	local timePassed = self:getTimePassed()
	self.rankingBoard:add(player, timePassed)
	local alivePlayers = getAlivePlayers()
	if #alivePlayers == 1 then
		self.rankingBoard:add(alivePlayers[1], timePassed)
		showMessage(getPlayerName(alivePlayers[1]) .. ' is the final survivor!', 0, 255, 0)
	end
	if #alivePlayers <= 1 then
		RaceMode.endMap()
	else
		setTimer(clientCall, 2000, 1, player, 'startSpectate')
	end
	RaceMode.setPlayerFinished(player)
end

--[[
function DestructionDerby:pickFreeSpawnpoint()
	local i = table.find(RaceMode.getSpawnpoints(), 'used', '[nil]')
	if i then
		repeat
			i = math.random(RaceMode.getNumberOfSpawnpoints())
		until not RaceMode.getSpawnpoint(i).used
	else
		i = math.random(RaceMode.getNumberOfSpawnpoints())
	end
	local spawnpoint = RaceMode.getSpawnpoint(i)
	spawnpoint.used = true
	if self.startTick then
		setTimer(freeSpawnpoint, 10000, 1, i)
	end
	return spawnpoint
end
--]]
