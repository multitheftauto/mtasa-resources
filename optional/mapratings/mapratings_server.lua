local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement(getThisResource())

local g_MapResName

addEventHandler('onGamemodeMapStart', g_Root,
	function(mapres)
		-- outputDebugString("mapratings: sending data: "..tostring(mapInfo.name))
        g_MapResName = getResourceName(mapres)
	end
)

addEventHandler('onResourceStart', g_ResRoot,
	function()
		-- Add table if required
		executeSQLQuery("CREATE TABLE IF NOT EXISTS mapratings (mapname TEXT, playername TEXT, rating INTEGER)")
		-- Remove any duplicate mapname entries
		executeSQLQuery("DELETE FROM mapratings WHERE rowid in "
							.. " (SELECT A.rowid"
							.. " FROM mapratings A, mapratings B"
							.. " WHERE A.rowid > B.rowid AND A.mapname = B.mapname)")
		-- Add unique index to speed things up (Also means INSERT will fail if the unique index (mapname) already exists)
		executeSQLQuery("CREATE UNIQUE INDEX IF NOT EXISTS IDX_MAPRATINGS_MAPNAME on mapratings(mapname)")
		
		-- Perform upgrade from an old version if necessary
		updateMapNames()
		
		g_MapResName = exports.mapmanager:getRunningGamemodeMap()
	end
)

function updateMapRating(player, mapresname, rating)
	local playername = getPlayerName(player)
	local sql = executeSQLQuery("SELECT rating FROM mapratings WHERE mapname=? AND playername=?", mapresname, playername)
	if #sql > 0 then
		-- outputDebugString("mapratings: update maprating "..playername.." "..rating)
		executeSQLQuery("UPDATE mapratings SET rating=? WHERE mapname=? AND playername=?", rating, mapresname, playername)
		if sql[1].rating == rating then
			outputChatBox("You already rated this map "..getRatingColorAsHex(rating)..rating.."/10#FF0000.", player, 255, 0, 0, true)
		else
			outputChatBox("Changed rating from "..getRatingColorAsHex(sql[1].rating)..sql[1].rating.."/10 #E1AA5Ato "..getRatingColorAsHex(rating)..rating.."/10#E1AA5A.", player, 225, 170, 90, true)
		end
	else
		-- outputDebugString("mapratings: insert maprating "..playername.." "..rating)
		executeSQLQuery("INSERT INTO mapratings (mapname,playername,rating) VALUES (?,?,?)", mapresname, playername, rating)
		outputChatBox("Rated '"..(getResourceInfo(getResourceFromName(mapresname), "name") or mapresname).."' "..getRatingColorAsHex(rating)..rating.."/10#E1AA5A.", player, 225, 170, 90, true)
		triggerEvent("onPlayerRateMap", player, mapresname, rating, getMapRating(mapresname))
	end
	triggerEvent("onMapRatingChange", player, getMapRating(mapresname), rating)
end

addEvent('onPollStarting')
addEventHandler('onPollStarting', g_Root,
	function(poll)
		for index, item in ipairs(poll) do
			if item[1] == "Yes" or item[1] == "No" then return end
			
			local mapname = item[1]
			local map
			for k,v in pairs(item) do
				if type(v) == "userdata" and getResourceName(v) and exports.mapmanager:isMap(v) then
					map = v
					outputDebugString("found map "..tostring(getResourceName(v)).." at "..tostring(k))
					break
				end
			end
			if map then
				local rating = getMapRating(getResourceName(map))
				if rating then
					mapname = mapname.." ("..(rating.average or "?")..")"
				end

				item[1] = mapname
			end
		end
		triggerEvent('onPollModified', source, poll )
	end
)

function getMapRating(mapresname)
	local sql = executeSQLQuery("SELECT AVG(rating) AS avg , COUNT(rating) AS count FROM mapratings WHERE mapname=?", mapresname)
	if sql[1].count > 0 then
		local avg = math.floor(sql[1].avg*100+0.5)/100
		return {average = avg, count = sql[1].count}
	end
	return false
end

function getPlayerRating(playername, mapresname)
	if mapresname then
		local sql = executeSQLQuery("SELECT rating FROM mapratings WHERE playername=? AND mapname=?", playername, mapresname)
		if #sql > 0 then
			return sql[1].rating
		end
	else
		local sql = executeSQLQuery("SELECT AVG(rating) AS avg , COUNT(rating) AS count FROM mapratings WHERE playername=?", playername)
		if sql[1].count > 0 then
			local avg = math.floor(sql[1].avg*100+0.5)/100
			return {average = avg, count = sql[1].count}
		end
	end
	return false
end

function getRatingColor(rating)
	local r, g = -5.1*(rating^2) + 25.5*rating + 255, -5.1*(rating^2) + 76.5*rating
	r, g = r > 255 and 255 or math.floor(r+0.5), g > 255 and 255 or math.floor(g+0.5)
	-- outputDebugString("mapratings: rating = "..rating.." r = "..r.." g = "..g)
	return {r,g,0}--"#"..string.format("%02X", r)..string.format("%02X", g).."00"
end

function getRatingColorAsHex(rating)
	local r, g = unpack(getRatingColor(rating))
	return "#"..string.format("%02X", r)..string.format("%02X", g).."00"
end

addCommandHandler('rate',
	function(player, cmd, rating)
		rating = tonumber(rating)
		if rating then
			if rating >= 0 and rating <= 10 then
				updateMapRating(player, g_MapResName, math.floor(rating*100+0.5)/100)
			else
				outputChatBox("Choose a rating between 0 and 10.", player, 255, 0, 0)
			end
		else
			outputChatBox("Choose a rating between 0 and 10.", player, 255, 0, 0)
		end
	end
)

function updateMapNames()
	local sql = executeSQLQuery("SELECT * FROM mapratings")
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
	outputDebugString("mapratings: Need Mapname Update")
	local maps = exports.mapmanager:getMaps()
	local infoMaps = {}
	for _,map in ipairs(exports.mapmanager:getMaps()) do
		infoMaps[getResourceInfo(map, "name") or getResourceName(map)] = getResourceName(map)
	end
	for _,row in ipairs(sql) do
		if infoMaps[row.mapname] then
			executeSQLQuery("UPDATE mapratings SET mapname=? WHERE mapname=?", infoMaps[row.mapname], row.mapname)
			outputDebugString("mapratings: changed "..tostring(row.mapname).." to "..tostring(infoMaps[row.mapname]))
		elseif not getResourceFromName(row.mapname) then
			executeSQLQuery("DELETE FROM mapratings WHERE mapname=?", row.mapname)
			outputDebugString("mapratings: deleted "..tostring(row.mapname))
		end
	end
end