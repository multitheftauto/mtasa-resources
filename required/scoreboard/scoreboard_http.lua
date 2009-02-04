local httpColumns = {}
local httpRows = {}
local updateInterval = 1000

function getScoreboardColumns( )
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

local function refreshServerScoreboard()
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
		table.insert(scoreboardNewRows,getRowData(team))
		for i,player in ipairs(getPlayersInTeam(team)) do
			table.insert(scoreboardNewRows,getRowData(player))
		end
	end
	
	httpRows = scoreboardNewRows
end

addEventHandler("onResourceStart", getResourceRootElement(getThisResource()),
	function()
		setTimer(refreshServerScoreboard, updateInterval, 0)
	end
)