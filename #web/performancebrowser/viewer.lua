--
-- viewer.lua
--

Viewer = {}
Viewer.__index = Viewer
Viewer.instances = {}

---------------------------------------------------------------------------
--
-- Viewer:create()
--
--
--
---------------------------------------------------------------------------
function Viewer:create(name)
	local id = #Viewer.instances + 1
	Viewer.instances[id] = setmetatable(
		{
			id = id,
			name				= name,
			lastUsedTime		= getTickCount (),
			DEFAULTCOLUMNSIZE	= "180px",
			httpColumns			= {},
			httpRows			= {},
			queryTargetName		= "",
			queryCategoryName	= "",
			queryFilterText		= "",
			queryShowClients    = "",
			queryOptionsText	= "",
			categoryUpdateTime  = {},
			bQueryDone		    = false,
			lastTargets			= {},
			lastCategories		= {},
			lastRows			= {},
			lastHeaders		    = {},
		},
		self
	)

	Viewer.instances[id]:postCreate()
	return Viewer.instances[id]
end


---------------------------------------------------------------------------
--
-- Viewer:postCreate()
--
--
--
---------------------------------------------------------------------------
function Viewer:postCreate()
end


---------------------------------------------------------------------------
--
-- Viewer:destroy()
--
--
--
---------------------------------------------------------------------------
function Viewer:destroy()
	Viewer.instances[self.id] = nil
	self.id = 0
end


---------------------------------------------------------------------------
--
-- Viewer:getSecondsSinceLastUsed()
--
--
--
---------------------------------------------------------------------------
function Viewer:getSecondsSinceLastUsed()
	local ticks = getTickCount () - self.lastUsedTime
	return ticks / 1000
end


---------------------------------------------------------------------------
--
-- Viewer:setUsed()
--
--
--
---------------------------------------------------------------------------
function Viewer:setUsed()
	self.lastUsedTime = getTickCount ()
end


---------------------------------------------------------------------------
--
-- Viewer:getCurrentTarget()
--
--
--
---------------------------------------------------------------------------
function Viewer:getCurrentTarget ()
	local currentTarget = getTargetFromName(self.queryTargetName, self.queryShowClients)
	currentTarget = validateTarget(currentTarget, self.queryShowClients)
	return currentTarget
end


---------------------------------------------------------------------------
--
-- Viewer:getCategoryIndex()
--
--
--
---------------------------------------------------------------------------
function Viewer:getCategoryIndex ( categoryName )
	local idx = 1
	for _,category in pairs(self:getCategoriesRaw ()) do
		if category == categoryName then
			return idx
		end
		idx = idx + 1
	end
	return 1
end

---------------------------------------------------------------------------
--
-- Viewer:getCategoriesIfChanged()
--
-- Browser wants to know what categories to put in the list
--
---------------------------------------------------------------------------
function Viewer:getCategoriesIfChanged ()
	local categories = self:getCategoriesRaw ()
	local bChanged = not table.deepcompare(categories, self.lastCategories)
	self.lastCategories = categories
	return bChanged and categories or false
end


---------------------------------------------------------------------------
--
-- Viewer:getCategoriesRaw()
--
--
--
---------------------------------------------------------------------------
function Viewer:getCategoriesRaw ()
	local target = self:getCurrentTarget()
	if not target then return { "no target" } end
	if not target.bSupportsStats then return { "not supported" } end
	-- Get active categories
	local columnList,rowList = target:getPerformanceStats(self.name,"")
	local categories = {}
	for _,row in ipairs(rowList) do
		table.insert( categories, row[1] )
	end
	return categories
end


---------------------------------------------------------------------------
--
-- Viewer:getTargetsIfChanged()
--
-- Browser wants to know what targets to put in the list
--
---------------------------------------------------------------------------
function Viewer:getTargetsIfChanged ()
	local targets = getTargetNameList (self.queryShowClients)
	local bChanged = not table.deepcompare(targets, self.lastTargets)
	self.lastTargets = targets
	return bChanged and targets or false
end


---------------------------------------------------------------------------
--
-- Viewer:getHeadersIfChanged()
--
-- returns false if not changed
--
---------------------------------------------------------------------------
function Viewer:getHeadersIfChanged ()
	local headers = self.httpColumns
	local bChanged = not table.deepcompare(headers, self.lastHeaders)
	self.lastHeaders = headers
	return bChanged and headers or false
end


---------------------------------------------------------------------------
--
-- Viewer:getRowsIfChanged()
--
-- returns false if not changed
--
---------------------------------------------------------------------------
function Viewer:getRowsIfChanged ()
	local rows = self.httpRows
	local bChanged = not table.deepcompare(rows, self.lastRows)
	self.lastRows = rows
	return bChanged and rows or false
end


---------------------------------------------------------------------------
--
-- Viewer:setQuery()
--
-- Browser has display request
--
---------------------------------------------------------------------------
function Viewer:setQuery ( counter, targetName, categoryName, optionsText, filterText, showClients )
	self:setUsed()

	local restoredQueryOptionsText = false
	local restoredQueryFilterText = false
	local restoredQueryShowClients = false

	-- Is this the first call from a new page?
	if counter == 0 then
		if #self.lastTargets == 0 then
			-- Set initial settings
			targetName = getTargetNameList (self.queryShowClients)[1]
			categoryName = self:getCategoriesRaw ()[1]
		else
			-- Restore last settings
			self.lastTargets = {}
			self.lastCategories = {}
			self.lastHeaders = {}
			self.lastRows = {}
			targetName = self.queryTargetName
			categoryName = self.queryCategoryName
			optionsText = self.queryOptionsText
			filterText = self.queryFilterText
			showClients = self.queryShowClients

			restoredQueryOptionsText = optionsText
			restoredQueryFilterText = filterText
			restoredQueryShowClients = showClients
		end
	end

	self.queryTargetName = targetName
	self.queryCategoryName = categoryName
	self.queryOptionsText = optionsText
	self.queryFilterText = filterText
	self.queryShowClients = showClients

	local targets = self:getTargetsIfChanged ()
	local targetIndex = getTargetIndex( self:getCurrentTarget(), self.queryShowClients )

	local categories = self:getCategoriesIfChanged ()
	local categoryIndex = self:getCategoryIndex( self.queryCategoryName )

	self:updateCache()
	local headers = self:getHeadersIfChanged()
	local rows = self:getRowsIfChanged()

	local status2 = tostring(self.queryTargetName)
	local status1 = status2=="" and "" or "Performance stats for: "
	local warning1 = tostring(self:getCurrentTarget().name):sub(1,6) ~= "client" and "" or "Warning: May affect client"

	return	counter,
			self.bQueryDone,
			categories, categoryIndex - 1,
			targets, targetIndex - 1,
			headers,
			rows,
            restoredQueryOptionsText,
            restoredQueryFilterText,
            restoredQueryShowClients,
			status1, status2, warning1
end


---------------------------------------------------------------------------
--
-- Viewer:updateCache()
--
-- Update cached table
--
---------------------------------------------------------------------------
function Viewer:updateCache()

	local bClearChange = getTickCount() - (self.categoryUpdateTime[self.queryCategoryName] or 0) > 60000
	self.categoryUpdateTime[self.queryCategoryName] = getTickCount()

	local columnSize = self.DEFAULTCOLUMNSIZE

	-- Fetch table
	local target = self:getCurrentTarget()
	if not target then
		self.httpColumns = {{name="no",size=columnSize},{name="target",size=columnSize}}
		self.httpRows = {}
		return
	end
	if not target.bSupportsStats then
		self.httpColumns = {{name="not",size=columnSize},{name="supported",size=columnSize}}
		self.httpRows = {}
		return
	end
	local columnList,rowList, bQueryDone = target:getPerformanceStats( self.name, self.queryCategoryName, self.queryOptionsText, self.queryFilterText )
	self.bQueryDone = bQueryDone

	if not columnList then
		return
	end

	if #columnList == 1 then
		columnSize = "500px"
	end

	-- Process columns
	local rowIndices = {}
	local newColumns = {}

	local prevSectionName = nil
	local newSections = {}

	local columnTint
	local sectionIdx = 0
	local sectionSubIdx = 0
	local idx = 0
	for k,columnName in pairs(columnList) do
		idx = idx + 1
		table.insert(rowIndices,idx)

		local parts = split ( columnName, string.byte( '.' ) )
		local sectionName = ""
		if #parts == 2 then
			sectionName = parts[1]
			columnName = parts[2]
		end

		if sectionName == prevSectionName then
			-- Extend previous section
			newSections[#newSections].span = tostring(newSections[#newSections].span + 1)
			sectionSubIdx = sectionSubIdx + 1
		else
			-- New section
			prevSectionName = sectionName
			table.insert(newSections,{name=sectionName,span="1"})
			sectionIdx = sectionIdx + 1
			sectionSubIdx = 1
			if sectionIdx % 2 == 1 then
				columnTint = Color:new(128,128,134)
			else
				columnTint = Color:new(134,128,128)
			end
		end
		local tintString = columnTint:Add( sectionSubIdx * 2 ):toString()
		table.insert(newColumns,{name=columnName,size=columnSize,tint=tintString})
	end
	self.httpColumns = {newSections,newColumns}

	-- Process rows
	local rowColors = { "#d8d8d8", "#d2d2d2", "#c0c4c0", "#b8bfb8" }
	local newRows = {}
	for irow, row in ipairs(rowList) do
		local rowdata = {}
		local rowclass = "main"
		local rowcolor = rowColors[ (irow % 2) + 1 ]
		local rowblank = " | "
		if #row > 0 then
			if string.find( row[1], '.', 1, true ) ~= nil then
				rowclass = "sub"
				rowcolor = rowColors[ (irow % 2) + 3 ]
				rowblank = " + "
			end
		end
		table.insert(rowdata,{class=rowclass,color=rowcolor})
		for i, idx in ipairs(rowIndices) do
			if idx then
				if bClearChange and newColumns[i].name == "change" then
					table.insert(rowdata,"")
				else
					table.insert(rowdata,row[idx])
				end
			else
				table.insert(rowdata,rowblank)
			end
		end
		table.insert(newRows,rowdata)
	end
	self.httpRows = newRows
end


---------------------------------------------------------------------------
--
-- table.deepcompare
--
-- Test for table equality
--
---------------------------------------------------------------------------
function table.deepcompare(tab1,tab2)
    if tab1 and tab2 then
        if tab1 == tab2 then
            return true
        end
        if type(tab1) == 'table' and type(tab2) == 'table' then
            if #tab1 ~= #tab2 then
                return false
            end
            for index, content in pairs(tab1) do
                if not table.deepcompare(tab2[index],content) then
                    return false
                end
            end
            return true
        end
    end
    return false
end


---------------------------------------------------------------------------
--
-- Color
--
-- Color manipulation (R,G,B) (0-255,0-255,0-255)
--
---------------------------------------------------------------------------
Color = {
	new = function(self, _x, _y, _z)
		local newColor = { x = _x or 0, y = _y or 0, z = _z or 0 }
		return setmetatable(newColor, { __index = Color })
	end,

	Copy = function(self)
		return Color:new(self.x, self.y, self.z)
	end,

	AddV = function(self, V)
		return Color:new(self.x + V.x, self.y + V.y, self.z + V.z)
	end,

	SubV = function(self, V)
		return Color:new(self.x - V.x, self.y - V.y, self.z - V.z)
	end,

	Add = function(self, n)
		return Color:new(self.x + n, self.y + n, self.z + n)
	end,

	Mul = function(self, n)
		return Color:new(self.x * n, self.y * n, self.z * n)
	end,

	Div = function(self, n)
		return Color:new(self.x / n, self.y / n, self.z / n)
	end,

	toString = function(self)
		return string.format( "#%02x%02x%02x", self.x, self.y, self.z )
	end,

}
