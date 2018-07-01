Sprint = setmetatable({}, RaceMode)
Sprint.__index = Sprint

Sprint:register('Sprint')

function Sprint.isApplicable()
	return RaceMode.checkpointsExist() -- and RaceMode.getMapOption('respawn') == 'timelimit'
end
