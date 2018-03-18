function startCycler_random()
	addCommandHandler("skipmap", cycleMap_random, true)

	cycleMap_random()
	addEventHandler("onRoundFinished", rootElement, roundCounter)
end

function cycleMap_random()
	local allModes = exports.mapmanager:getGamemodes()

	-- get up to eight random modes with a compatible map
	math.randomseed(getTickCount())
	local randomMode = allModes[math.random(1, #allModes)]

	local compatibleMaps = exports.mapmanager:getMapsCompatibleWithGamemode(randomMode)
	if #compatibleMaps > 0 then
		local randomMap = compatibleMaps[math.random(1, #compatibleMaps)]
		exports.mapmanager:changeGamemodeMap(randomMap, randomMode)
	else
		exports.mapmanager:changeGamemode(randomMode)
	end

	remainingRounds = get("random_rounds")
end
