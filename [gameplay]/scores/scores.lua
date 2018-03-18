local root = getRootElement()
local scoresRoot = getResourceRootElement(getThisResource())

local scoreColumns = {"kills", "deaths", "self", "ratio", "status"}
local isColumnActive = {}

local KDR_DECIMAL_PLACES = 2

--http://lua-users.org/wiki/SimpleRound
local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

local function setScoreData (element, column, data)
	if isColumnActive[column] then
		setElementData(element, column, data)
	end
end

local function resetScores (element)
	setScoreData(element, "kills", 0)
	setScoreData(element, "deaths", 0)
	setScoreData(element, "self", 0)
	setScoreData(element, "ratio", "-")
	local status = ""
	if isPedDead(element) then
		status = "Dead"
	end
	setScoreData(element, "status", status)
end

local function updateRatio (element)
	local deaths = getElementData(element, "deaths")
	if deaths == 0 then
		setScoreData(element, "ratio", "-")
	else
		local kdr = round(getElementData(element, "kills") / deaths, KDR_DECIMAL_PLACES)
		setScoreData(element, "ratio", tostring(kdr))
	end
end

function updateActiveColumns ()
	for i, column in ipairs(scoreColumns) do
		if get(column) then
			isColumnActive[column] = true
			exports.scoreboard:addScoreboardColumn(column)
		elseif isColumnActive[column] then
			isColumnActive[column] = false
			exports.scoreboard:removeScoreboardColumn(column)
		end
	end
end

addEventHandler("onResourceStart", scoresRoot,
	function ()
		updateActiveColumns()
		for i, player in ipairs(getElementsByType("player")) do
			resetScores(player)
		end
	end
)

addEventHandler("onResourceStop", scoresRoot,
	function ()
		for i, column in ipairs(scoreColumns) do
			if isColumnActive[column] then
				exports.scoreboard:removeScoreboardColumn(column)
			end
		end
	end
)

addEventHandler("onPlayerJoin", root,
	function ()
		resetScores(source)
	end
)

addEventHandler("onPlayerWasted", root,
	function (ammo, killer, weapon)
		if killer then
			if killer ~= source then
				-- killer killed victim
				setScoreData(killer, "kills", getElementData(killer, "kills") + 1)
				setScoreData(source, "deaths", getElementData(source, "deaths") + 1)
				if isColumnActive["ratio"] then
					updateRatio(killer)
					updateRatio(source)
				end
			else
				-- victim killed himself
				setScoreData(source, "self", getElementData(source, "self") + 1)
			end
		else
			-- victim died
			setScoreData(source, "deaths", getElementData(source, "deaths") + 1)
			if isColumnActive["ratio"] then
				updateRatio(source)
			end
		end

		setScoreData(source, "status", "Dead")
	end
)

addEventHandler("onPlayerSpawn", root,
	function ()
		setScoreData(source, "status", "")
	end
)

addCommandHandler("score",
	function (player)
		if player then
			for i, column in ipairs(scoreColumns) do
				if column == "status" then
					break
				end
				if isColumnActive[column] then
					exports.scoreboard:addScoreboardColumn(column)
					outputConsole(column .. ": " .. getElementData(player, column), player)
				end
			end
		end
	end
)
