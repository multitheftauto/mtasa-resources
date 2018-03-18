Freeroam = setmetatable({}, RaceMode)
Freeroam.__index = Freeroam

Freeroam:register('Freeroam')

function Freeroam:isApplicable()
	return not RaceMode.checkpointsExist() and RaceMode.getMapOption('respawn') == 'timelimit'
end

function Freeroam:isRanked()
	return false
end

function Freeroam:pickFreeSpawnpoint(ignore)
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
		TimerManager.createTimerFor("map"):setTimer(freeSpawnpoint, 2000, 1, i)
	end
	return spawnpoint
end
