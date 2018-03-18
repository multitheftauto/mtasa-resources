registeredStats = {}
stats = {}
nodepos = 1
maxstatrecords = 60  -- 1  hours worth
lastnode = nil
UPDATE_FREQUENCY = 60 -- seconds
statsByResource = {}

setTimer (
	function()
	    local time = getRealTime()

		stats[nodepos] = {}
		stats[nodepos].time = time.hour .. ":" .. string.format("%.2d", time.minute)
		for k,v in pairs(registeredStats) do
			stats[nodepos][k] = tostring(call(v.resource, v.func))
		end

		nodepos = nodepos + 1;
		if ( nodepos > maxstatrecords ) then
			nodepos = 1
		end
	end
, UPDATE_FREQUENCY * 1000, 0 )

function registerStat(resource, func, name, description)
	local statname = getResourceName(resource) .. "_" .. func
	registeredStats[statname] = {resource=resource, func=func, name=name, description=description}
	if ( statsByResource[resource] == nil ) then
		statsByResource[resource] = {}
	end
	statsByResource[resource][statname] = registeredStats[statname]
end

function getCurrentStats ()
	local currStats = {}
	local arrpos = nodepos
	local stopat = arrpos
	if stats[arrpos] == nil then
		arrpos = 1
		stopat = 1
	end
	local i = 0
	repeat
		table.insert(currStats,stats[arrpos])
		arrpos = arrpos + 1;
		if stats[arrpos] == nil then
			arrpos = 1
		end
		i = i + 1
	until arrpos == stopat

	return currStats
end

function getRegisteredStats()
	return registeredStats
end

function getStatListByResource()
	return statsByResource
end
