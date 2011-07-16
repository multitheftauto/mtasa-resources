local httpColumns = {}
local httpRows = {}
local updateInterval = 1000
local lastUpdateTime = 0

function getScoreboardColumns( )
	-- Only update http data if someone is looking
	if getTickCount() - lastUpdateTime > updateInterval then
		lastUpdateTime = getTickCount()
		refreshServerScoreboard()
	end
	return httpColumns
end

function getScoreboardRows( )
	return httpRows
end

local function getName(element)
	local etype = getElementType(element)
	
	if etype == "player" then
		return getPlayerName(element)
	elseif etype == "team" then
		return getTeamName(element)
	end
end

local function getRowData( element )

	if not isElement(element) then return end

	local rowData = {getElementType(element),}
	for i, column in ipairs(httpColumns) do
		if column.name == "name" then
			table.insert(rowData, getName(element))
		elseif column.name == "ping" then
			local ping = ""
			if getElementType(element) == "player" then
				ping = getPlayerPing(element)
			end
			table.insert(rowData, ping)
		else
			table.insert(rowData, getElementData(element,column.name) or "")
		end
	end

	return rowData
end

function refreshServerScoreboard()
	local scoreboardNewColumns = {}
	
	for i, column in ipairs(scoreboardColumns) do
		local visibleToElement = column.visibleTo
		if visibleToElement == nil or visibleToElement == rootElement then
			table.insert(scoreboardNewColumns,{name=column.name,size=column.size})
		end
	end
	
	httpColumns = scoreboardNewColumns

	local scoreboardNewRows = {}
	
	for i, player in ipairs(getElementsByType("player")) do
		if not getPlayerTeam(player) then
			table.insert(scoreboardNewRows,getRowData(player))
		end
	end
	
	for i,team in ipairs(getElementsByType("team")) do
		if isElement(team) then		-- Sanity check, as sometimes team is not valid here. (Why?)
			table.insert(scoreboardNewRows,getRowData(team))
			for i,player in ipairs(getPlayersInTeam(team)) do
				if isElement(player) and getElementType(player) == "player" then
					table.insert(scoreboardNewRows,getRowData(player))
				end
			end
		end
	end
	
	httpRows = scoreboardNewRows
end
