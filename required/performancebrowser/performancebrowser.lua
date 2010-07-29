--
--
-- performancebrowser.lua
--
--

local bSupportsStats = getPerformanceStats
local DEFAULTCOLUMNSIZE = "180px"
local httpColumns = {}
local httpRows = {}
local updateInterval = 5000
local lastUpdateTime = 0
local queryCatagory = "none"
local queryFilter = ""
local queryOptions = ""
local categoryUpdateTime = {}


-- Browser wants to know what categories to put in the list
function getCategories ()
	if not bSupportsStats then return { "not supported" } end
	-- Get active catagories
	local columnList,rowList = getPerformanceStats("")
	local categories = {}
	for _,row in ipairs(rowList) do
		table.insert( categories, row[1] )
	end
	return categories
end


-- Browser has changed display request
function setQuery ( catagory, options, filter )
	queryCatagory = catagory
	queryOptions = options
	queryFilter = filter
	lastUpdateTime = 0
end


-- Browser wants columns to display
function getHttpColumns( )
	if getTickCount() - lastUpdateTime > updateInterval then
		lastUpdateTime = getTickCount()
		updateCache()
	end
	return httpColumns
end


-- Browser wants rows to display
function getHttpRows( )
	return httpRows
end


-- Update cached table
function updateCache()
	if not bSupportsStats then return end

	local bClearChange = getTickCount() - (categoryUpdateTime[queryCatagory] or 0) > 60000
	categoryUpdateTime[queryCatagory] = getTickCount()


	local columnSize = DEFAULTCOLUMNSIZE

	-- Fetch table
	local columnList,rowList = getPerformanceStats( queryCatagory, queryOptions, queryFilter )

	if #columnList == 1 then
		columnSize = "500px"
	end

	-- Process columns
	local rowIndices = {}
	local newColumns = {}
	local prevSectionName = ""
	local idx = 1
	for k,columnName in pairs(columnList) do
		local parts = split ( columnName, string.byte( '.' ) )
		if #parts == 2 then
			local sectionName = parts[1]
			columnName = parts[2]
			if sectionName ~= prevSectionName then
				prevSectionName = sectionName
				table.insert(rowIndices,false)
				table.insert(newColumns,{name=" "..sectionName,size=columnSize})
			end
		end
		table.insert(rowIndices,idx)
		idx = idx + 1	
		table.insert(newColumns,{name=columnName,size=columnSize})
	end
	httpColumns = newColumns

	-- Process rows
	local newRows = {}
	for _, row in ipairs(rowList) do
		local rowdata = {}
		local style = "main"
		if #row > 0 then
			if string.find( row[1], '.', 1, true ) ~= nil then
				style = "sub"
			end
		end
		table.insert(rowdata,style)
		for i, idx in ipairs(rowIndices) do
			if idx then
				if bClearChange and newColumns[i].name == "change" then
					table.insert(rowdata,"")
				else
					table.insert(rowdata,row[idx])
				end
			else
				table.insert(rowdata,style == "sub" and " + " or " | ")
			end
		end
		table.insert(newRows,rowdata)
	end
	httpRows = newRows
end
