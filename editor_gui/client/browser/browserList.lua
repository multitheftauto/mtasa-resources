browserList = {}
browserList_mt = { __index = browserList }
local activatedBrowsers = {}
local ROW_HEIGHT = 14
local keyUp,keyDown,ignore
--NOTE: All functions lack necessary checks to verify valid args, its intended for internal use only
-------
local function browserListGridlistClick( button,state,x,y )
	if state == "up" then return end
	ignore = false
	if getElementType(source) ~= "gui-gridlist" then return end
	for self,oldScrollPosition in pairs(activatedBrowsers) do
		if source == self.gridlist then
			-- local startKey = math.ceil(guiScrollBarGetScrollPosition(self.scrollbar) * self.rowMultiplier)
			local startKey = self.startKey
			local row = guiGridListGetSelectedItem ( self.gridlist )
			if row == -1 then
				row = 0
				--Possibly add a check if row ~= self.selected.
			else
				row = row + startKey
			end
			self:setSelected(row)
			if button == "right" then
				toggleFavourite(self.gridlist)
			end
		end
	end
end

local function browserListDoubleClick(button,state,x,y)
	for self,oldScrollPosition in pairs(activatedBrowsers) do
		if source == self.gridlist then
			if self.doubleClickCallback then
				self.doubleClickCallback()
			end
		end
	end
end

local function checkPosition(self)
	local newPosition = guiScrollBarGetScrollPosition ( self.scrollbar )
	if not ignore then
		if newPosition ~= math.floor(self.position) then
			self.position = newPosition
		end
	end
end

local function updateActivatedBrowsers()
	for self,oldScrollPosition in pairs(activatedBrowsers) do
		checkPosition(self)
		local position = self.position
		if position < 0 then position = 0 end
		if position ~= oldScrollPosition then
			guiGridListClear ( self.gridlist )
			local centre = math.ceil(position * self.rowMultiplier)
			local startKey = centre + 1
			local targetKey = startKey + self.gridlistRowCount - 1
			--set the text
			local i = startKey
			while i ~= targetKey do
				rowColumns = self.rowList[i]
				if type(rowColumns) == "table" then
					local pos = guiGridListAddRow ( self.gridlist )
					for columnID, text in ipairs(rowColumns) do
						if (text) then
							guiGridListSetItemText(self.gridlist,pos,columnID,text,false,false)
						end
					end
				else --if its a linear table then there's only 1 column to set
					local pos = guiGridListAddRow ( self.gridlist )
					if (rowColumns) then
						guiGridListSetItemText(self.gridlist,pos,1,rowColumns,false,false)
					end
				end
				i = i + 1
			end
			if self.selected >= startKey and self.selected <= targetKey then
				local row = self.selected - startKey
				guiGridListSetSelectedItem ( self.gridlist,row,1)
			end
			self.startKey = startKey
			activatedBrowsers[self] = position
		end
	end
end

--Scroll stuff
local scrollTimer
local isScrolling = false
local initialDelay = 600
local acceleration = 100
local maximum = 50 --lower the faster
local function browserListScrollList ( key, newRepeatDelay )
	if not isScrolling then return end
	for self,oldScrollPosition in pairs(activatedBrowsers) do --this is lazy, it means all browserLists scroll simultaneously
		local cellrow = self:getSelected()
	-- local rowCount = 5
		local rowCount = self.rowCount
		if key == keyUp then
			cellrow = cellrow - 1
			if cellrow <= 0 then
				cellrow = rowCount
			end
		elseif key == keyDown then
			cellrow = cellrow + 1
			if cellrow > rowCount then
				cellrow = 1
			end
		end
		self:setSelected(cellrow)
		self:centre(cellrow)

		newRepeatDelay = newRepeatDelay - acceleration
		if newRepeatDelay < maximum then newRepeatDelay = maximum end
		if isScrolling then
			scrollTimer = setTimer ( browserListScrollList, newRepeatDelay, 1, key, newRepeatDelay )
		end
	end
end

local function browserListScroll ( key, keyState )
	if keyState == "down" then
		isScrolling = true
		browserListScrollList ( key, initialDelay )
	elseif keyState == "up" then
		isScrolling = false
		for k,timer in pairs(getTimers()) do
			if timer == scrollTimer then
				killTimer ( scrollTimer )
				break
			end
		end
	end
end

local function gridlistScroll(key,keyState)
	for self,oldScrollPosition in pairs(activatedBrowsers) do
		if guiGetMouseOverElement() == self.gridlist then
			--get the current position
			local row = (self.position*self.rowMultiplier) + (self.gridlistRowCount/2)
			--local row = math.floor(row)
			if key == "mouse_wheel_up" then
				row = row - 3
			else
				row = row + 3
			end
			self:centre(row)
		end
	end
end

function round(number,idp)
	local mult = 10^(idp or 0)
    return math.floor(number * mult + 0.5) / mult
end

function browserList:create(x,y,width,height,columnTable,relative,parent)
    local new = {}
    setmetatable( new, browserList_mt )
    new.gridlist = guiCreateGridList (x,y,width,height,relative,parent)
	guiGridListSetSortingEnabled ( new.gridlist,false )
	x,y = guiGetSize ( new.gridlist, false )
	new.scrollbar = guiCreateScrollBar(x - 20,0,20,y,false,false,new.gridlist)
	new.gridlistSizeY = y - 23
	new.gridlistRowCount = math.ceil((y-25)/ROW_HEIGHT) --The number of rows you can fit into it
	for key,columnSubTable in pairs(columnTable) do
		for columnName,width2 in pairs(columnSubTable) do
			guiGridListAddColumn ( new.gridlist,tostring(columnName),width2 )
		end
	end
	return new
end

function browserList:setSize(x,y)--only supports absolute positioning for now
	self.gridlistSizeY = y - 23
	self.gridlistRowCount = math.ceil((y-25)/ROW_HEIGHT)
	self.scrollDistance = self.rowCount - self.gridlistRowCount
	if self.scrollDistance == 0 then
		self.scrollDistance = 1
	end
	self.rowMultiplier = self.scrollDistance/100
	guiSetSize ( self.gridlist,x,y,false)
	local scrollbarX = guiGetSize ( self.gridlist, false )
	guiSetPosition ( self.scrollbar,scrollbarX - 20,0,false)
	guiSetSize ( self.scrollbar,20,y,false)
end

function browserList:setRows(rowTable)
	--store the data
	self.currentStartKey = 1
	self.rowCount = #rowTable --total number of rows
	self.rowList = rowTable
	self.scrollDistance = self.rowCount - self.gridlistRowCount
	if self.scrollDistance == 0 then
		self.scrollDistance = 1
	end
	self.rowMultiplier = self.scrollDistance/100 --how much 1% of a scrollbar would represent
	-- self.stepSize = 1/((self.gridlistRowCount/9.34) * self.rowMultiplier )
	--guiSetProperty(self.scrollbar,"StepSize",tostring(self.stepSize) )
	guiSetProperty(self.scrollbar,"StepSize","0" )
	self.startKey = 1
	self.selected = 0
	self.position = 0
	guiScrollBarSetScrollPosition ( self.scrollbar, 0 )
	if self.rowCount < self.gridlistRowCount then
		guiSetVisible ( self.scrollbar, false )
	else
		guiSetVisible ( self.scrollbar, true )
	end
	self:setSelected(0)
	guiGridListGetSelectedItem ( self.gridlist,-1,-1 )
	--
	guiGridListClear ( self.gridlist )
	if #rowTable == 0 then
		guiGridListAddRow ( self.gridlist )
		guiGridListSetItemText ( self.gridlist, 0, 1,"No results found", true, false )
		return true
	end
	local i = 1
	local target = self.gridlistRowCount + 2
	while i ~= target do
		local rowColumns = rowTable[i]
		if type(rowColumns) == "table" then
			local pos = guiGridListAddRow ( self.gridlist )
			for columnID, text in ipairs(rowColumns) do
				guiGridListSetItemText(self.gridlist,pos,columnID,text,false,false)
			end
		elseif type(rowColumns) == "string" then --if its a linear table then there's only 1 column to set
			local pos = guiGridListAddRow ( self.gridlist )
			guiGridListSetItemText(self.gridlist,pos,1,rowColumns,false,false)
			if exports.editor_main:isElementLocked(getElementByID(rowColumns)) then
				guiGridListSetItemColor(self.gridlist,pos,1,255,255,0)
			end
		end
		i = i + 1
	end
	return true
end

function browserList:clear()
	guiGridListClear ( self.gridlist )
	return true
end

local enabledBrowsers = {}
function browserList:enable(up,down)
	activatedBrowsers[self] = guiScrollBarGetScrollPosition ( self.scrollbar )
	local count = 0
	for k,v in pairs(activatedBrowsers) do
		count = count + 1
	end
	--
	if count == 1 then
		addEventHandler ( "onClientRender",root,updateActivatedBrowsers )
		addEventHandler("onClientGUIMouseDown",root,browserListGridlistClick )
		addEventHandler("onClientGUIDoubleClick",root,browserListDoubleClick )
		if not up then up = "arrow_u" end
		if not down then down = "arrow_d" end
		keyUp,keyDown = up,down
		bindKey ( keyUp, "both", browserListScroll )
		bindKey ( keyDown, "both", browserListScroll )
		bindKey ( "mouse_wheel_up", "both", gridlistScroll )
		bindKey ( "mouse_wheel_down", "both", gridlistScroll )
	end
	return true
end

function browserList:disable()
	activatedBrowsers[self] = nil
	local count = 0
	for k,v in pairs(activatedBrowsers) do
		count = count + 1
	end
	--
	if count == 0 then
		removeEventHandler ( "onClientRender",root,updateActivatedBrowsers )
		removeEventHandler("onClientGUIMouseDown",root,browserListGridlistClick )
		removeEventHandler("onClientGUIDoubleClick",root,browserListDoubleClick )
		unbindKey ( keyUp, "both", browserListScroll )
		unbindKey ( keyDown, "both", browserListScroll )
		unbindKey ( "mouse_wheel_up", "both", gridlistScroll )
		unbindKey ( "mouse_wheel_down", "both", gridlistScroll )
	end
	return true
end

function browserList:setSelected(value)
	self.selected = value
	local startKey = self.startKey
	local targetKey = startKey + self.gridlistRowCount + 1
	if self.selected >= startKey and self.selected <= targetKey then
		local row = self.selected - startKey
		guiGridListSetSelectedItem ( self.gridlist,row,1)
	end
	if self.callback then
		self.callback(value)
	end
	return true
end
function browserList:getSelected()
	return self.selected
end
function browserList:getSelectedText()
	return self.rowList[self.selected]
end

function browserList:centre(row)
	local position = (row - (self.gridlistRowCount/2))/self.rowMultiplier
	if position < 0 then position = 0 end
	if position > 100 then position = 100 end
	ignore = true
	guiScrollBarSetScrollPosition ( self.scrollbar, (position) )
	self.position = position
end
browserList.center = browserList.centre

function browserList:addCallback(theFunction)
	self.callback = theFunction
end

function browserList:addDoubleClickCallback(theFunction)
	self.doubleClickCallback = theFunction
end

