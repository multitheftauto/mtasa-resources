RankingBoard = {}
RankingBoard.__index = RankingBoard

RankingBoard.instances = {}

local screenWidth, screenHeight = guiGetScreenSize()
local topDistance = 250
local bottomDistance = 0.23*screenHeight
local posLeftDistance = 30
local nameLeftDistance = 60
local labelHeight = 20
local maxPositions = math.floor((screenHeight - topDistance - bottomDistance)/labelHeight)

function RankingBoard.create(id)
	RankingBoard.instances[id] = setmetatable({ id = id, direction = 'down', labels = {}, position = 0 }, RankingBoard)
end

function RankingBoard.call(id, fn, ...)
	RankingBoard[fn](RankingBoard.instances[id], ...)
end

function RankingBoard:setDirection(direction,plrcount)
	self.direction = direction
	if direction == 'up' then
		self.highestPos = plrcount
		self.position = self.highestPos + 1
	end
end

function RankingBoard:add(name, time)
	local position
	local y
	local doBoardScroll = false
	if self.direction == 'down' then
		self.position = self.position + 1
		if self.position > maxPositions then
			return
		end
		y = topDistance + (self.position-1)*labelHeight
	elseif self.direction == 'up' then
		self.position = self.position - 1
		local labelPosition = self.position
		if self.highestPos > maxPositions then
			labelPosition = labelPosition - (self.highestPos - maxPositions)
			if labelPosition < 1 then
				labelPosition = 0
				doBoardScroll = true
			end
		elseif labelPosition < 1 then
			return
		end
		y = topDistance + (labelPosition-1)*labelHeight
	end
	local posLabel, posLabelShadow = createShadowedLabelFromSpare(posLeftDistance, y, 20, labelHeight, tostring(self.position) .. ')', 'right')
	if time then
		if not self.firsttime then
			self.firsttime = time
			time = ': ' .. msToTimeStr(time)
		else
			time = ': +' .. msToTimeStr(time - self.firsttime)
		end
	else
		time = ''
	end
	local playerLabel, playerLabelShadow = createShadowedLabelFromSpare(nameLeftDistance, y, 250, labelHeight, name .. time)
	table.insert(self.labels, posLabel)
	table.insert(self.labels, posLabelShadow)
	table.insert(self.labels, playerLabel)
	table.insert(self.labels, playerLabelShadow)
    playSoundFrontEnd(7)
	if doBoardScroll then
		guiSetAlpha(posLabel, 0)
		guiSetAlpha(posLabelShadow, 0)
		guiSetAlpha(playerLabel, 0)
		guiSetAlpha(playerLabelShadow, 0)
		local anim = Animation.createNamed('race.boardscroll', self)
		anim:addPhase({ from = 0, to = 1, time = 700, fn = RankingBoard.scroll, firstLabel = posLabel })
		anim:addPhase({ fn = RankingBoard.destroyLastLabel, firstLabel = posLabel })
		anim:play()
	end
end

function RankingBoard:scroll(param, phase)
	local firstLabelIndex = table.find(self.labels, phase.firstLabel)
	for i=firstLabelIndex,firstLabelIndex+3 do
		guiSetAlpha(self.labels[i], param)
	end
	local x, y
	for i=0,#self.labels/4-1 do
		for j=1,4 do
			x = (j <= 2 and posLeftDistance or nameLeftDistance)
			y = topDistance + ((maxPositions - i - 1) + param)*labelHeight
			if j % 2 == 0 then
				x = x + 1
				y = y + 1
			end
			guiSetPosition(self.labels[i*4+j], x, y, false)
		end
	end
	for i=1,4 do
		guiSetAlpha(self.labels[i], 1 - param)
	end
end

function RankingBoard:destroyLastLabel(phase)
	for i=1,4 do
		destroyElementToSpare(self.labels[1])
		table.remove(self.labels, 1)
	end
	local firstLabelIndex = table.find(self.labels, phase.firstLabel)
	for i=firstLabelIndex,firstLabelIndex+3 do
		guiSetAlpha(self.labels[i], 1)
	end
end

function RankingBoard:addMultiple(items)
	for i,item in ipairs(items) do
		self:add(item.name, item.time)
	end
end

function RankingBoard:clear()
	table.each(self.labels, destroyElementToSpare)
	self.labels = {}
end

function RankingBoard:destroy()
	self:clear()
	RankingBoard.instances[self.id] = nil
end


--
-- Label cache
--

local spareElems = {}
local donePrecreate = false

function RankingBoard.precreateLabels(count)
    donePrecreate = false
    while #spareElems/4 < count do
        local label, shadow = createShadowedLabel(10, 1, 20, 10, 'a' )
        destroyElementToSpare(label)
        destroyElementToSpare(shadow)
	end
    donePrecreate = true
end

function destroyElementToSpare(elem)
    table.insertUnique( spareElems, elem )
    guiSetVisible(elem, false)
end

function createShadowedLabelFromSpare(x, y, width, height, text, align)

    if #spareElems < 2 then
        if not donePrecreate then
            outputDebug( 'OPTIMIZATION', 'createShadowedLabel' )
        end
	    return createShadowedLabel(x, y, width, height, text, align)
    else
        local shadow = table.popLast( spareElems )
	    guiSetSize(shadow, width, height, false)
	    guiSetText(shadow, text)
	    --guiLabelSetColor(shadow, 0, 0, 0)
	    guiSetPosition(shadow, x + 1, y + 1, false)
        guiSetVisible(shadow, true)

        local label = table.popLast( spareElems )
	    guiSetSize(label, width, height, false)
	    guiSetText(label, text)
	    --guiLabelSetColor(label, 255, 255, 255)
	    guiSetPosition(label, x, y, false)
        guiSetVisible(label, true)
	    if align then
		    guiLabelSetHorizontalAlign(shadow, align)
		    guiLabelSetHorizontalAlign(label, align)
        else
		    guiLabelSetHorizontalAlign(shadow, 'left')
		    guiLabelSetHorizontalAlign(label, 'left')
	    end
        return label, shadow
    end
end
