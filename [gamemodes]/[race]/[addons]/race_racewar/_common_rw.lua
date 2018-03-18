--
-- common_rw.lua
--	Common setting for server and client
--

--_DEBUG_LOG = {'UNDEF','MISC','BIGDAR'}	-- More logging
_TESTING = false				-- Any user can issue test commands


---------------------------------------------------------------------------
-- Math extentions
---------------------------------------------------------------------------
function math.lerp(from,to,alpha)
	return from + (to-from) * alpha
end

function math.clamp(low,value,high)
	return math.max(low,math.min(value,high))
end

function math.wrap(low,value,high)
	while value > high do
		value = value - (high-low)
	end
	while value < low do
		value = value + (high-low)
	end
	return value
end

function math.wrapdifference(low,value,other,high)
	return math.wrap(low,value-other,high)+other
end
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- String extentions
---------------------------------------------------------------------------
function string:split(sep)
	if #self == 0 then
		return {}
	end
	sep = sep or ' '
	local result = {}
	local from = 1
	local to
	repeat
		to = self:find(sep, from, true) or (#self + 1)
		result[#result+1] = self:sub(from, to - 1)
		from = to + 1
	until from == #self + 2
	return result
end
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- Table extentions
---------------------------------------------------------------------------
function table.map(t, callback, ...)
	for k,v in ipairs(t) do
		t[k] = callback(v, ...)
	end
	return t
end

function table.maptry(t, callback, ...)
	for k,v in pairs(t) do
		t[k] = callback(v, ...)
		if not t[k] then
			return false
		end
	end
	return t
end

function table.find(t, ...)
	local args = { ... }
	if #args == 0 then
		for k,v in pairs(t) do
			if v then
				return k
			end
		end
		return false
	end

	local value = table.remove(args)
	if value == '[nil]' then
		value = nil
	end
	for k,v in pairs(t) do
		for i,index in ipairs(args) do
			if type(index) == 'function' then
				v = index(v)
			else
				if index == '[last]' then
					index = #v
				end
				v = v[index]
			end
		end
		if v == value then
			return k
		end
	end
	return false
end

function table.merge(t1, t2)
	local l = #t1
	for i,v in ipairs(t2) do
		t1[l+i] = v
	end
	return t1
end

function table.removevalue(t, val)
	for i,v in ipairs(t) do
		if v == val then
			table.remove(t, i)
			return i
		end
	end
	return false
end

function table.deletevalue(t, val)
	for k,v in pairs(t) do
		if v == val then
			t[k] = nil
			return k
		end
	end
	return false
end

function table.deepcopy(t)
	local known = {}
	local function _deepcopy(t)
		local result = {}
		for k,v in pairs(t) do
			if type(v) == 'table' then
				if not known[v] then
					known[v] = _deepcopy(v)
				end
				result[k] = known[v]
			else
				result[k] = v
			end
		end
		return result
	end
	return _deepcopy(t)
end

function table.random(t)
	return t[math.random(#t)]
end

function table.dump(t, caption, depth)
	if not depth then
		depth = 1
	end
	if depth == 1 and caption then
		outputConsole(caption .. ':')
	end
	if not t then
		outputConsole('Table is nil')
	elseif type(t) ~= 'table' then
		outputConsole('Argument passed is of type ' .. type(t))
		local str = tostring(t)
		if str then
			outputConsole(str)
		end
	else
		local braceIndent = string.rep('  ', depth-1)
		local fieldIndent = braceIndent .. '  '
		outputConsole(braceIndent .. '{')
		for k,v in pairs(t) do
			if type(v) == 'table' and k ~= 'siblings' and k ~= 'parent' then
				outputConsole(fieldIndent .. tostring(k) .. ' = ')
				table.dump(v, nil, depth+1)
			else
				outputConsole(fieldIndent .. tostring(k) .. ' = ' .. tostring(v))
			end
		end
		outputConsole(braceIndent .. '}')
	end
end


function table.filter(t, callback, cmpval)
	if cmpval == nil then
		cmpval = true
	end
	for k,v in pairs(t) do
		if callback(v) ~= cmpval then
			t[k] = nil
		end
	end
	return t
end

function table.create(keys, vals)
	local result = {}
	if type(vals) == 'table' then
		for i,k in ipairs(keys) do
			result[k] = vals[i]
		end
	else
		for i,k in ipairs(keys) do
			result[k] = vals
		end
	end
	return result
end

function table.each(t, index, callback, ...)
	local args = { ... }
	if type(index) == 'function' then
		table.insert(args, 1, callback)
		callback = index
		index = false
	end
	for k,v in pairs(t) do
		callback(index and v[index] or v, unpack(args))
	end
	return t
end

function table.insertUnique(t,val)
	if not table.find(t, val) then
		table.insert(t,val)
	end
end

function table.popLast(t,val)
	if #t==0 then
		return false
	end
	local last = t[#t]
	table.remove(t)
	return last
end
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- Time functions
---------------------------------------------------------------------------
function getSecondCount()
 	return getTickCount() * 0.001
end

function msToTimeStr(ms)
	if not ms then
		return ''
	end
	local centiseconds = tostring(math.floor(math.fmod(ms, 1000)/10))
	if #centiseconds == 1 then
		centiseconds = '0' .. centiseconds
	end
	local s = math.floor(ms / 1000)
	local seconds = tostring(math.fmod(s, 60))
	if #seconds == 1 then
		seconds = '0' .. seconds
	end
	local minutes = tostring(math.floor(s / 60))
	return minutes .. ':' .. seconds .. ':' .. centiseconds
end

function getTickTimeStr()
	return msToTimeStr(getTickCount())
end
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- Misc functions
---------------------------------------------------------------------------
-- remove color coding from string
function removeColorCoding ( name )
	return type(name)=='string' and string.gsub ( name, '#%x%x%x%x%x%x', '' ) or name
end

-- getPlayerName with color coding removed
_getPlayerName = getPlayerName
function getPlayerName ( player )
	return removeColorCoding ( _getPlayerName ( player ) )
end
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- Camera functions
---------------------------------------------------------------------------
function getCameraRot()
	local px, py, pz, lx, ly, lz = getCameraMatrix()
	local rotz = math.atan2 ( ( lx - px ), ( ly - py ) )
 	local rotx = math.atan2 ( lz - pz, getDistanceBetweenPoints2D ( lx, ly, px, py ) )
 	return math.deg(rotx), 180, -math.deg(rotz)
end
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- Timer - Wraps a standard timer
---------------------------------------------------------------------------
Timer = {}
Timer.__index = Timer
Timer.instances = {}

-- Create a Timer instance
function Timer:create()
	local id = #Timer.instances + 1
	Timer.instances[id] = setmetatable(
		{
			id = id,
			timer = nil,	  -- Actual timer
		},
		self
	)
	return Timer.instances[id]
end

-- Destroy a Timer instance
function Timer:destroy()
	self:killTimer()
	Timer.instances[self.id] = nil
	self.id = 0
end

-- Check if timer is valid
function Timer:isActive()
	return self.timer ~= nil
end

-- killTimer
function Timer:killTimer()
	if self.timer then
		killTimer( self.timer )
		self.timer = nil
	end
end

-- setTimer
function Timer:setTimer( theFunction, timeInterval, timesToExecute, ... )
	self:killTimer()
	self.fn = theFunction
	self.count = timesToExecute
	self.args = { ... }
	self.timer = setTimer( function() self:handleFunctionCall() end, timeInterval, timesToExecute )
end

function Timer:handleFunctionCall()
	-- Delete reference to timer if there are no more repeats
	if self.count > 0 then
		self.count = self.count - 1
		if self.count == 0 then
			self.timer = nil
		end
	end
	self.fn(unpack(self.args))
end

---------------------------------------------------------------------------
