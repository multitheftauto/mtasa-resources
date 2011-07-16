local columnByName = {}
local scoreboardColumns = {}
local scoreboardRows = {}
local scoreboardGrid
local updateInterval = 1000 --ms
local visibilityCheckInterval = 500 --ms
local indent = ' '

local localPlayer = getLocalPlayer()
local playerTeam = getPlayerTeam(localPlayer)
local playerParent = getElementParent(localPlayer)
local rootElement = getRootElement()
local thisResourceRoot = getResourceRootElement(getThisResource())

-- getPlayerName with color coding removed
local _getPlayerName = getPlayerName
local function getPlayerName ( player )
	local name = _getPlayerName ( player )
	return type(name)=='string' and string.gsub ( name, '#%x%x%x%x%x%x', '' ) or name
end

function getName(element)
	local eType = getElementType(element)
	
	if eType == "player" then
		return getPlayerName(element)
	elseif eType == "team" then
		return getTeamName(element)..' ('..countPlayersInTeam(element)..' players)'
	end
end

function updateScoreboardData(element,field,data)
	local sectionheader = (getElementType(element) == "team")
	
	if scoreboardRows[element] and columnByName[field] then
		data = tostring(data or "")
		if field == "name" and getElementType(element) == "player" and getPlayerTeam(element) then
			data = indent .. data
        elseif field ~= "name" then
			data = '  ' .. data     -- Added to make alignment look better
		end
		guiGridListSetItemText(
			scoreboardGrid,
			scoreboardRows[element],
			scoreboardColumns[columnByName[field]].id,
			data,
			sectionheader,
			false
		)
	end
end

function updatePlayerNick()
	updateScoreboardData(source,"name",getPlayerName(source))
end

function updateChangedData(field)
	if not isElement(source) then return false end --!wk
	
	local eType = getElementType(source)	
	
	if eType == "player" or eType == "team" then
		updateScoreboardData(source,field,getElementData(source,field))
	end
end

function addToScoreboard(element)
	element = element or source
	local row = guiGridListAddRow(scoreboardGrid)
	
	scoreboardRows[element] = row
	updateScoreboardData(element,"name",getName(element))
	return row
end

function removeFromScoreboard(element)
	element = element or source
	if not scoreboardRows[element] then return false end
	
	guiGridListRemoveRow(scoreboardRows[element])
	scoreboardRows[element] = nil
end

function refreshScoreboardElementData()
	for element, row in pairs(scoreboardRows) do
		for i, column in ipairs(scoreboardColumns) do
			local columnName = column.name
			if columnName ~= "name" and columnName ~= "ping" then
				if isElement(element) then
					updateScoreboardData(element,columnName,getElementData(element,columnName))
--				else outputDebugString("Unexpected: "..tostring(element),0)
				end
			end
		end
	end
end

function refreshScoreboardPings()
	for i,player in ipairs(getElementsByType("player")) do
		updateScoreboardData(player,"ping",getPlayerPing(player))
	end
end

function refreshScoreboardTeams()
	guiGridListClear(scoreboardGrid)
	scoreboardRows = {}
	for i, player in ipairs(getElementsByType("player")) do
		if not getPlayerTeam(player) then
			addToScoreboard(player)
		end
	end
	
	for i,team in ipairs(getElementsByType("team")) do
		addToScoreboard(team)
		local teamname = getTeamName(team)
		for i,player in ipairs(getPlayersInTeam(team)) do
			addToScoreboard(player)
			updateScoreboardData(player,"team",teamname)
		end
	end
end

function updateScoreboard()
	refreshScoreboardTeams()
	refreshScoreboardPings()
	refreshScoreboardElementData()
	if scoreboardColumns[1] then
		guiGridListSetSelectedItem(scoreboardGrid, scoreboardRows[localPlayer], scoreboardColumns[1].id)
	end
end

function refreshScoreboard()
	if guiGetVisible(scoreboardGrid) and not isCursorShowing() then
		updateScoreboard()
	end
end

function addScoreboardColumn(columnData, position)
	local name = columnData[1]
	local size = columnData[2] or 0.1
	
	local numberOfColumns = #scoreboardColumns
	position = position or numberOfColumns
	if name and not columnByName[name] then
		if position <= numberOfColumns and numberOfColumns > 0 then
			--delete all columns to the right of the new one, insert it and readd them
			for i=position, numberOfColumns do
				guiGridListRemoveColumn(scoreboardGrid,scoreboardColumns[i].id)
			end
			columnByName[name] = position
			table.insert(scoreboardColumns,position,{name=name,id=guiGridListAddColumn(scoreboardGrid,name,size),size=size})
			for i=position+1, numberOfColumns+1 do
				columnByName[scoreboardColumns[i].name] = i
				scoreboardColumns[i].id = guiGridListAddColumn(scoreboardGrid,scoreboardColumns[i].name,scoreboardColumns[i].size)
			end
		else
			columnByName[name] = #scoreboardColumns + 1
			table.insert(scoreboardColumns,{name=name,id=guiGridListAddColumn(scoreboardGrid,name,size), size=size})
		end
	end
	return true
end

function removeScoreboardColumn(name)
	if name and columnByName[name] then
		local index = columnByName[name]
		columnByName[name] = nil
		guiGridListRemoveColumn(scoreboardGrid,scoreboardColumns[index].id)
		table.remove(scoreboardColumns,index)
		for i=index, #scoreboardColumns do
			columnByName[scoreboardColumns[i].name] = i
		end
		return true
	end
end

function replaceAllColumns(columnList)
	for name in pairs(columnByName) do
		removeScoreboardColumn(name)
	end
	for i, columnData in ipairs(columnList) do
		addScoreboardColumn(columnData,#scoreboardColumns+1)
	end
end

function showScoreboardCursor(key,keystate,show)
	showCursor(show)
end

function toggleScoreboard(state)
	if state == nil then state = not guiGetVisible(scoreboardGrid) end
	if state == true then
		showCursor(false)
		updateScoreboard()
		bindKey("mouse2","down",showScoreboardCursor,true)
		bindKey("mouse2","up",showScoreboardCursor,false)
		guiBringToFront(scoreboardGrid)
	elseif state == false then
		showCursor(false)
		unbindKey("mouse2","down",showScoreboardCursor)
		unbindKey("mouse2","up",showScoreboardCursor)
	end
	
	guiSetVisible(scoreboardGrid,state)
end

function toggleScoreboardPressed(command,state)
	state = (state == "1") and true or false
	toggleScoreboard(state)
end
addCommandHandler ( "scoreboard", toggleScoreboardPressed )

function checkVisibility()
	local currentTeam = getPlayerTeam(localPlayer)
	local currentParent = getElementParent(localPlayer)
	if not ( currentTeam == playerTeam and currentParent == playerParent ) then
		triggerServerEvent("onClientVisibilityChange",localPlayer)
		playerTeam = currentTeam
		playerParent = currentParent
	end
end

function setScoreboardForced(state)
	if state == true then
		unbindKey("tab","down","scoreboard")
		unbindKey("tab","up","scoreboard")
	elseif state == false then
		bindKey("tab","down","scoreboard","1")
		bindKey("tab","up","scoreboard","0")
	else
		return false
	end
	toggleScoreboard(state)
end

addEventHandler("onClientResourceStart", thisResourceRoot,
	function ()
		scoreboardGrid = guiCreateGridList(0.15,0.2,0.7,0.6,true)
		guiSetAlpha(scoreboardGrid,0.7)
		guiSetVisible(scoreboardGrid,false)
		
		local rmbLabel = guiCreateLabel(0, 0, 0, 0, "(Hold right mouse button to enable scrolling)",false,scoreboardGrid)
		local scoreX, scoreY = guiGetSize(scoreboardGrid, false)
		local labelWidth = guiLabelGetTextExtent(rmbLabel)
		local labelHeight = guiLabelGetFontHeight(rmbLabel)
		
		guiSetPosition(rmbLabel, (scoreX - labelWidth)/2, scoreY - labelHeight - 10, false)
		guiSetSize(rmbLabel, labelWidth, labelHeight, false)
		guiSetAlpha(rmbLabel, .8)
		guiLabelSetColor(rmbLabel, 200, 200, 255)
		
		bindKey("tab","down","scoreboard","1")
		bindKey("tab","up","scoreboard","0")
		
		setTimer(refreshScoreboard, updateInterval, 0)
		updateScoreboard()
		
		--serverside control events
		addEvent("onServerSendColumns", true)
		addEvent("doAddColumn", true)
		addEvent("doRemoveColumn", true)
		addEvent("doForceScoreboard", true)
		
		--serverside control event handlers
		addEventHandler("onServerSendColumns", rootElement, replaceAllColumns)
		addEventHandler("doAddColumn", rootElement, addScoreboardColumn)
		addEventHandler("doRemoveColumn", rootElement, removeScoreboardColumn)
		addEventHandler("doForceScoreboard", rootElement, setScoreboardForced)
		
		--scoreboard update event handlers
		addEventHandler("onClientPlayerJoin", rootElement, addToScoreboard)
		addEventHandler("onClientPlayerQuit", rootElement, removeFromScoreboard)
		addEventHandler("onClientPlayerChangeNick", rootElement, updatePlayerNick)
		addEventHandler("onClientElementDataChange", rootElement, updateChangedData)
		
		addEventHandler("onClientClick", scoreboardGrid,
			function()
				if scoreboardColumns[1] and guiGetVisible(scoreboardGrid) then
					guiGridListSetSelectedItem(scoreboardGrid, scoreboardRows[localPlayer], scoreboardColumns[1].id)
				end
			end
		)
		
		triggerServerEvent("onClientScoreboardLoaded", localPlayer)
		
		setTimer(checkVisibility, visibilityCheckInterval, 0)
	end
)