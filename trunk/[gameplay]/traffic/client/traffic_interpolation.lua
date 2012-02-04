Node = setmetatable(
	{},
	{
		__call = function(self, x, y, z)
			return setmetatable({ x = x, y = y, z = z }, Node)
		end
	}
)
Node.__index = Node

function Node.__add(a, b)
	return setmetatable({ x = a.x + b.x, y = a.y + b.y, z = a.z + b.z }, Node)
end

function Node.__sub(a, b)
	return setmetatable({ x = a.x - b.x, y = a.y - b.y, z = a.z - b.z }, Node)
end

function Node.__mul(a, b)
	if type(a) == 'table' and type(b) == 'number' then
		-- vector*scalar
		return setmetatable({ x = a.x * b, y = a.y * b, z = a.z * b }, Node)
	elseif type(a) == 'number' and type(b) == 'table' then
		-- scalar*vector
		return setmetatable({ x = a * b.x, y = a * b.y, z = a * b.z }, Node)
	elseif type(a) == 'table' and type(b) == 'table' then
		-- inner product
		return setmetatable({ x = a.x * b.x, y = a.y * b.y, z = a.z * b.z }, Node)
	end
end

function Node.__div(a, b)
	if type(a) == 'table' and type(b) == 'number' then
		-- vector/scalar
		return setmetatable({ x = a.x / b, y = a.y / b, z = a.z / b }, Node)
	end
end

function Node:__tostring()
	return '(' .. self.x .. ', ' .. self.y .. ', ' .. self.z .. ')'
end

local facCache = {}
do
	local f = 1
	for i=1,10 do
		f = f*i
		facCache[i] = f
	end
end

function fac(n)
	if n <= 0 then
		return 0
	end
	if facCache[n] then
		return facCache[n]
	end
	local f = 1
	for i=2,n do
		f = f*i
	end
	facCache[n] = f
	return f
end

local function binom(n, k)
	if k == 0 or k == n then
		return 1
	end
	return fac(n)/(fac(k) * fac(n-k))
end

------------------------------
-- Interpolator superclass

Interpolation = {}
Interpolation.__index = {}

setmetatable(
	Interpolation,
	{
		__call = function(self, ...)
			local instance = setmetatable({ ... }, self)
			for i,node in ipairs(instance) do
				setmetatable(node, Node)
			end
			return instance
		end
	}
)

------------------------------
-- Bezier

Interpolation.Bezier = setmetatable({}, { __index = Interpolation, __call = getmetatable(Interpolation).__call })
Interpolation.Bezier.__index = Interpolation.Bezier

function Interpolation.Bezier:eval(t)
	local result = Node(0, 0, 0)
	local n = #self-1
	for i=0,n do
		result = result + binom(n, i)*self[i+1]*(1-t)^(n-i)*t^i
	end
	return result
end

function Interpolation.Bezier:evalRational(t,w)
	local resultZ = Node(0, 0, 0)
	local resultN = 0
	local result = 0
	local n = #self-1
	for i=0,n do
		result = binom(n, i)*t^i*(1-t)^(n-i)*(w[i+1] or 1)
		resultZ = resultZ + result*self[i+1]
		resultN = resultN + result
	end
	return resultZ/resultN
end