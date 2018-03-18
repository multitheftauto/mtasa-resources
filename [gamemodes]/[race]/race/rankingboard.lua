RankingBoard = {}
RankingBoard.__index = RankingBoard

RankingBoard.clientInstances = {}

function RankingBoard:create()
	local result = { id = #RankingBoard.clientInstances + 1, items = {} }
	RankingBoard.clientInstances[result.id] = true
	clientCall(g_Root, 'RankingBoard.create', result.id)
	result.joinHandler = function() result:playerJoined(source) end
	addEventHandler('onPlayerJoin', getRootElement(), result.joinHandler)
	return setmetatable(result, self)
end

function RankingBoard:clientCall(player, fn, ...)
	clientCall(player, 'RankingBoard.call', self.id, fn, ...)
end

local savedplrcount = 1

function RankingBoard:setDirection(direction, plrcount)
	savedplrcount = plrcount
	if direction == 'up' or direction == 'down' then
		self.direction = direction
		self:clientCall(g_Root, 'setDirection', direction, plrcount )
	end
end

function RankingBoard:add(player, time)
	local playerName = getPlayerName(player)
	if table.find(self.items, 'name', playerName) then
		return
	end
	table.insert(self.items, { name = playerName, time = time })
	self:clientCall(g_Root, 'add', playerName, time)
end

function RankingBoard:playerJoined(player)
	clientCall(player, 'RankingBoard.create', self.id)
	if self.direction then
		self:clientCall(player, 'setDirection', self.direction, savedplrcount )
	end
	self:clientCall(player, 'addMultiple', self.items)
end

function RankingBoard:clear()
	self:clientCall(g_Root, 'clear')
	self.items = {}
end

function RankingBoard:destroy()
	self:clientCall(g_Root, 'destroy')
	removeEventHandler('onPlayerJoin', getRootElement(), self.joinHandler)
	RankingBoard.clientInstances[self.id] = nil
end
