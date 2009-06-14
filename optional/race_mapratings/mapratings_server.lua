local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement(getThisResource())

local mapName

addEvent('onMapStarting')
addEventHandler('onMapStarting', g_Root,
	function(mapInfo)
		-- outputDebugString("mapratings: sending data: "..tostring(mapInfo.name))
        mapName = mapInfo.name
		triggerEvent("onSendMapRating", g_Root, getMapRating(mapName) or "unrated")
	end
)

addEventHandler('onResourceStart', g_ResRoot,
	function()
		-- executeSQLDropTable("mapRatings")
		executeSQLCreateTable("mapRatings", "playername TEXT, mapname TEXT, rating INTEGER")
	end
)

function updateMapRating(player, mapname, rating)
	local playername = getPlayerName(player)
	local sql = executeSQLQuery("SELECT rating, playername, mapname FROM mapRatings WHERE playername = '"..playername.."' AND mapname = '"..mapname.."'")
	if #sql > 0 then
		-- outputDebugString("mapratings: update maprating "..playername.." "..rating)
		executeSQLUpdate("mapRatings", "rating = '"..rating.."'", "playername = '"..playername.."' AND mapname = '"..mapname.."'")
		if sql[1].rating == rating then
			outputChatBox("You already rated this map "..getRatingColorAsHex(rating)..rating.."/10#FF0000.", player, 255, 0, 0, true)
		else
			outputChatBox("Changed rating from "..getRatingColorAsHex(sql[1].rating)..sql[1].rating.."/10 #E1AA5Ato "..getRatingColorAsHex(rating)..rating.."/10#E1AA5A.", player, 225, 170, 90, true)
		end
	else
		-- outputDebugString("mapratings: insert maprating "..playername.." "..rating)
		executeSQLInsert("mapRatings", "'"..playername.."', '"..mapname.."', '"..rating.."'")
		outputChatBox("Rated '"..mapname.."' "..getRatingColorAsHex(rating)..rating.."/10#E1AA5A.", player, 225, 170, 90, true)
	end
	outputConsole(playername.." rate '"..mapname.."' to "..rating.."/10")
	triggerEvent("onSendMapRating", g_Root, getMapRating(mapname) or "unrated")
end


addEvent('onPollStarting')
addEventHandler('onPollStarting', g_Root,
	function(poll)
		for index, item in ipairs(poll) do
			local mapname = item[1]
			local rating
			if mapname == "Play again" then
                if mapName then
                    rating = getMapRating(mapName)
                else
                    item[1] = nil
                    break
                end
			else
				rating = getMapRating(mapname)
			end
			if rating then
				mapname = mapname.." ("..(rating.average or "?")..")"
			end
			item[1] = mapname
		end
		triggerEvent('onPollModified', source, poll )
	end
)

function getMapRating(mapname)
	local sql = executeSQLQuery("SELECT AVG(rating) AS avg , COUNT(rating) AS count FROM mapRatings WHERE mapname = '"..mapname.."'")
	if sql[1].count > 0 then
		local avg = math.floor((sql[1].avg + 0.005)*100)/100
		return {average = avg, color = getRatingColorAsHex(avg), count = sql[1].count}
	else
		return {false}
	end
end

function getRatingColorAsHex(rating)
	local r, g = -5.1*(rating^2) + 25.5*rating + 255, -5.1*(rating^2) + 76.5*rating
	r, g = r > 255 and 255 or r, g > 255 and 255 or g
	-- outputDebugString("mapratings: rating = "..rating.." r = "..r.." g = "..g)
	return "#"..string.format("%02X", r)..string.format("%02X", g).."00"
end

addCommandHandler('rate',
	function(player, cmd, rating)
		rating = tonumber(rating)
		if rating then
			if rating >= 0 and rating <= 10 then
				updateMapRating(player, mapName, math.floor((rating + 0.005)*100)/100)
			else
				outputChatBox("Choose a rating between 0 and 10.", player, 255, 0, 0)
			end
		else
			outputChatBox("Choose a rating between 0 and 10.", player, 255, 0, 0)
		end
	end
)
