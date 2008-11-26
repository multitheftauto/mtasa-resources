local NAMECOLUMNSIZE = .55
local PINGCOLUMNSIZE = .1

isColumn = {name=true,ping=true}
scoreboardColumns = {
	{name="name",size=NAMECOLUMNSIZE},
	{name="ping",size=PINGCOLUMNSIZE},
}
local rootElement = getRootElement()

addEvent("onClientScoreboardLoaded", true)
addEvent("onClientVisibilityChange", true)

local function sendVisibleColumns(aClient)
	client = aClient or client
	local clientColumnData = {}
	for i, column in ipairs(scoreboardColumns) do
		local visibleToElement = column.visibleTo
		if visibleToElement == nil or visibleToElement == rootElement then
			table.insert(clientColumnData,{column.name,column.size})
		else
			if getElementType(visibleToElement) == "team" and getPlayerTeam(client) == visibleToElement then
				table.insert(clientColumnData,{column.name,column.size})
			else
				local ancestorElement = client
				while ancestorElement ~= rootElement do
					if ancestorElement == visibleToElement then
						table.insert(clientColumnData,{column.name,column.size})
						break
					end
					ancestorElement = getElementParent(ancestorElement)
				end
			end
		end
	end
	triggerClientEvent(client,"onServerSendColumns",rootElement,clientColumnData)
end
addEventHandler("onClientScoreboardLoaded",rootElement,sendVisibleColumns)
addEventHandler("onClientVisibilityChange",rootElement,sendVisibleColumns)

function addScoreboardColumn(name, element, position, size)
	if name and not isColumn[name] then
		isColumn[name] = true
		table.insert(scoreboardColumns,position or #scoreboardColumns,{name=name,visibleTo=element,size=size})
		return triggerClientEvent(element or rootElement,"doAddColumn",rootElement,{name,size},position)
	else
		return false
	end
end

function removeScoreboardColumn(name)
	if name and isColumn[name] then
		for i, column in ipairs(scoreboardColumns) do
			if column.name == name then
				isColumn[name] = nil
				table.remove(scoreboardColumns,i)
				return triggerClientEvent(rootElement,"doRemoveColumn",rootElement,name)
			end
		end
	else
		return false
	end
end

function resetScoreboardColumns()
	local nameExists, pingExists = false, false
	for i, column in ipairs(scoreboardColumns) do
		if column.name == "name" then
			nameExists = true
		elseif column.name == "ping" then
			pingExists = true
		else
			isColumn[column.name] = nil
			table.remove(scoreboardColumns,i)
			triggerClientEvent(rootElement,"doRemoveColumn",rootElement,column.name)
		end
	end
	
	if not nameExists then
		addScoreboardColumn("name", rootElement, 1, NAMECOLUMNSIZE)
	end
	if not pingExists then
		addScoreboardColumn("ping", rootElement, #scoreboardColumns, PINGCOLUMNSIZE)
	end
	
	return true
end

function setPlayerScoreboardForced(element, state)
	return triggerClientEvent(element,"doForceScoreboard",rootElement,state)
end
