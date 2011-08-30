MinHeap = {}
MinHeap.__index = MinHeap

local floor = math.floor

function MinHeap.new()
	return setmetatable({ n = 0 }, MinHeap)
end

function MinHeap:insertvalue(num)
	self[self.n] = num
	self.n = self.n + 1
	
	local child = self.n - 1
	local parent, temp
	while child > 0 do
		parent = floor((child - 1)/2)
		if self[parent] <= self[child] then
			break
		end
		temp = self[parent]
		self[parent] = self[child]
		self[child] = temp
		child = parent
	end
	return true
end

function MinHeap:findindex(num, root)
	root = root or 0
	if root >= self.n or num < self[root] then
		return false
	end
	if num == self[root] then
		return root
	end
	return self:findindex(num, root*2 + 1) or self:findindex(num, root*2 + 2)
end

function MinHeap:deleteindex(index)
	if index < 0 or index >= self.n then
		return false
	end
	local deleted = self[index]
	self[index] = self[self.n-1]
	self[self.n-1] = nil
	self.n = self.n - 1
	
	local parent = index
	local child, temp
	while true do
		child = parent*2 + 1
		if child >= self.n then
			break
		end
		if child < self.n - 1 and self[child+1] < self[child] then
			child = child + 1
		end
		if self[parent] <= self[child] then
			break
		end
		temp = self[parent]
		self[parent] = self[child]
		self[child] = temp
		parent = child
	end
	return deleted
end

function MinHeap:deletevalue(num)
	local index = self:findindex(num)
	if not index then
		return false
	end
	return self:deleteindex(index)
end

function MinHeap:size()
	return self.n
end

function MinHeap:empty()
	return self.n == 0
end

function MinHeap:__tostring(index, depth)
	index = index or 0
	depth = depth or 0
	if index >= self.n then
		return ''
	end
	return ('    '):rep(depth) .. tostring(self[index]) .. '\n' .. self:__tostring(index*2+1, depth+1) .. self:__tostring(index*2+2, depth+1)
end
