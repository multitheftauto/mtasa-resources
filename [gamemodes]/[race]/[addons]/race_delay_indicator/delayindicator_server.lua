local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement(getThisResource())
local debug = false

local mapName
local topTimeInterims			--topTimeInterims[checkpointNum] = time
local topTimeRankPlayer = {10} 	--topTimeRankPlayer[1] = rank, topTimeRankPlayer[2] = playername
local lastPlayer = {} 			--lastPlayer[checkpointNum] = player
local allCpTimes = {} 			--allCpTimes[player][checkpointNum] = time
local players = {}

addEventHandler('onResourceStart', g_ResRoot,
	function()
		-- executeSQLDropTable("mapInterims")
		-- Add table if required
		executeSQLQuery("CREATE TABLE IF NOT EXISTS mapinterims (mapname TEXT, playername TEXT, interims TEXT)")
		-- Remove any duplicate mapname entries
		executeSQLQuery("DELETE FROM mapinterims WHERE rowid in "
							.. " (SELECT A.rowid"
							.. " FROM mapinterims A, mapinterims B"
							.. " WHERE A.rowid > B.rowid AND A.mapname = B.mapname)")
		-- Add unique index to speed things up (Also means INSERT will fail if the unique index (mapname) already exists)
		executeSQLQuery("CREATE UNIQUE INDEX IF NOT EXISTS IDX_MAPINTERIMS_MAPNAME on mapinterims(mapname)")

		-- Perform upgrade from an old version if necessary
		updateMapNames()
		updatetopTimeInterims()
	end
)

addEventHandler('onGamemodeMapStart', g_Root,
	function(mapres)
		if debug then outputDebugString("delay_indicator: sending data: "..tostring(mapInfo.name)) end
		mapName = getResourceName(mapres)
		cpTimes = {}
		allCpTimes = {}
		topTimeInterims = nil
		local sql = executeSQLQuery("SELECT playername, interims FROM mapinterims WHERE mapname = ?", mapName )
		if #sql > 0 then
			if debug then outputDebugString(tostring(sql[1].playername).." "..tostring(sql[1].interims)) end
			topTimeRankPlayer = split(sql[1].playername, string.byte(' '))
			topTimeInterims = split(sql[1].interims, string.byte(','))
			topTimeRankPlayer[1] = tonumber(topTimeRankPlayer[1])
		end
		if debug then outputDebugString(tostring(topTimeRankPlayer[1]).." "..tostring(topTimeRankPlayer[2])) end
	end
)

addEvent('onPlayerReachCheckpoint')
addEventHandler('onPlayerReachCheckpoint', g_Root,
	function(checkpointNum, timePassed)
		timePassed = math.floor(timePassed)
        if debug then outputDebugString("race_delay_indicator: ".."info for "..getPlayerName(source)) end
        if not allCpTimes[source] then allCpTimes[source] = {} end
		allCpTimes[source][checkpointNum] = timePassed
        local rank = getElementData(source , "race rank")
        if rank == 1 then
			if topTimeInterims and topTimeRankPlayer then
				local diff = topTimeInterims[checkpointNum] - timePassed
				if debug then outputDebugString("race_delay_indicator: "..getPlayerName(source).." "..diff.." record  #"..topTimeRankPlayer[1]) end
				if not players[source] then
					triggerClientEvent(source, "showDelay", source, diff, topTimeRankPlayer)
				end
			end
		else
            local frontPlayer = getPlayerFromRank(rank - 1)
            if debug then outputDebugString("race_delay_indicator: ".."frontPlayer = "..tostring(frontPlayer)) end
            if not frontPlayer then
                if debug then outputDebugString("race_delay_indicator: ".."no frontPlayer use lastPlayer") end
                if lastPlayer[checkpointNum] then
                    frontPlayer = lastPlayer[checkpointNum]
                else
                    if debug then outputDebugString("race_delay_indicator: ".."no lastPlayer use nothing") end
                end
			else
				if allCpTimes[frontPlayer] and allCpTimes[frontPlayer][checkpointNum] then
					if debug then outputDebugString("race_delay_indicator: ".."use allCpTimes["..getPlayerName(frontPlayer).."]["..checkpointNum.."] = "..tostring(allCpTimes[frontPlayer][checkpointNum])) end
					diff = timePassed - allCpTimes[frontPlayer][checkpointNum]
				else
					if debug then outputDebugString("race_delay_indicator: ".."lua is too slow no difference") end
					diff = 0
				end
				if not players[source] then
					triggerClientEvent(source, "showDelay", frontPlayer, diff)
				end
				if not players[frontPlayer] then
					triggerClientEvent(frontPlayer, "showDelay", source, diff, checkpointNum)
				end
            end
        end
        lastPlayer[checkpointNum] = source
		if debug then outputDebugString("race_delay_indicator: ".."allCpTimes: "..tostring(getPlayerName(source)).." checkpointNum = "..tostring(checkpointNum).." timePassed = "..tostring(allCpTimes[source][checkpointNum])) end
	end
)

function getPlayerFromRank(rank)
    for i, player in ipairs(getElementsByType("player")) do
        if getElementData(player, "race rank") == rank then
            return player
        end
    end
    return false
end

addEvent("onPlayerToptimeImprovement")
addEventHandler("onPlayerToptimeImprovement", g_Root,
	function(newPos)
		if debug then outputDebugString(tostring(getPlayerName(source)).." "..tostring(newPos).." "..tostring(topTimeRankPlayer[1])) end
		if newPos <= topTimeRankPlayer[1] and allCpTimes[source] then
			local playername = newPos.." "..getPlayerName(source)
			local interims = table.concat(allCpTimes[source], ",")
			local sql = executeSQLQuery("SELECT * FROM mapinterims WHERE mapname = ?", mapName )
			if #sql > 0 then
				if debug then outputDebugString("mapinterims: update mapinterims "..playername.." "..interims) end
				executeSQLQuery("UPDATE mapinterims SET playername=?, interims=? WHERE mapname=?", playername, interims, mapName )
			else
				if debug then outputDebugString("mapinterims: insert mapinterims "..playername.." "..interims) end
				executeSQLQuery("INSERT INTO mapinterims (mapname,playername,interims) VALUES (?,?,?)", mapName, playername, interims )
			end
		end
	end
)

function updatetopTimeInterims()
	sql = executeSQLQuery("SELECT * FROM mapinterims")
	local needUpdate
	if sql and #sql > 0 then
		for i=1,math.min(5,#sql) do
			if not string.find(sql[math.random(1,#sql)].playername," ") then
				needUpdate = true
				break
			end
		end
	end
	if not needUpdate then return end
	outputDebugString("mapinterims: Need Player Update")
	if debug then outputDebugString("mapinterims: start update "..tostring(#sql)) end
	for _,row in ipairs(sql) do
		if not string.find(row.playername, " ") then
			local old = row.playername
			row.playername = "1 "..old
			executeSQLQuery("UPDATE mapinterims SET playername=? WHERE mapname=?", row.playername, row.mapname )
			outputDebugString("mapinterims: changed "..tostring(old).." to "..tostring(row.playername).." in "..tostring(row.mapname))
		end
	end
end

function updateMapNames()
	local sql = executeSQLQuery("SELECT * FROM mapinterims")
	local needUpdate
	if sql and #sql > 0 then
		for i=1,math.min(5,#sql) do
			if not getResourceFromName(sql[math.random(1,#sql)].mapname) then
				needUpdate = true
				break
			end
		end
	end
	if not needUpdate then return end
	outputDebugString("mapinterims: Need Mapname Update")
	local maps = exports.mapmanager:getMaps()
	local infoMaps = {}
	for _,map in ipairs(exports.mapmanager:getMaps()) do
		infoMaps[getResourceInfo(map, "name") or getResourceName(map)] = getResourceName(map)
	end
	for _,row in ipairs(sql) do
		if infoMaps[row.mapname] then
			executeSQLQuery("UPDATE mapinterims SET mapname=? WHERE mapname=?", infoMaps[row.mapname], row.mapname)
			outputDebugString("mapinterims: changed "..tostring(row.mapname).." to "..tostring(infoMaps[row.mapname]))
		elseif not getResourceFromName(row.mapname) then
			executeSQLQuery("DELETE FROM mapinterims WHERE mapname=?", row.mapname)
			outputDebugString("mapinterims: deleted "..tostring(row.mapname))
		end
	end
end

addCommandHandler("cpdelays",
	function(player)
		players[player] = not players[player]
	end
)
