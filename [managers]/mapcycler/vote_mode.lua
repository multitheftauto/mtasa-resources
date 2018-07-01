
function startCycler_vote()
	addCommandHandler("skipmap", cycleMap_vote, true)

	cycleMap_vote()
	addEventHandler("onRoundFinished", rootElement, roundCounter)
end

function cycleMap_vote()
	-- This increases the server startup speed - ('voteBetweenModes' will fail with no players anyway)
	if #getElementsByType("player") < 1 then
		remainingRounds = get("vote_rounds")
		return
	end

	local allModes = exports.mapmanager:getGamemodes()
	local modeSelection = {}

	-- get up to eight random modes with a compatible map
	math.randomseed(getTickCount())
	while #modeSelection < 8 do
		if #allModes == 0 then
			break
		end

		local randomIndex = math.random(1, #allModes)
		local randomMode = allModes[randomIndex]

		local compatibleMaps = exports.mapmanager:getMapsCompatibleWithGamemode(randomMode)
		local randomMap = nil
		if #compatibleMaps > 0 then
			randomMap = compatibleMaps[math.random(1, #compatibleMaps)]
		end

		table.insert(modeSelection, {randomMode, randomMap})
		table.remove(allModes, randomIndex)
	end

	exports.votemanager:voteBetweenModes(unpack(modeSelection))

	remainingRounds = get("vote_rounds")
end
