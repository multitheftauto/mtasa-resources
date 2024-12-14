function newVector3D(posX, posY, posZ)
	local newVector = {x = posX or 0.0, y = posY or 0.0, z = posZ or 0.0}

	return newVector
end

function moduleVector3D(vector3D)
	return math.sqrt(vector3D.x * vector3D.x + vector3D.y * vector3D.y + vector3D.z * vector3D.z)
end

function normalizeVector3D(vector3D)
	local mod = moduleVector3D(vector3D)

	if mod ~= 0 then
		vector3D.x = vector3D.x / mod
		vector3D.y = vector3D.y / mod
		vector3D.z = vector3D.z / mod
	end

	return vector3D
end

function mulVector3D(vector3D, n)
	return newVector3D(vector3D.x * n, vector3D.y * n, vector3D.z * n)
end

Vector3D = {
	new = function(self, posX, posY, posZ)
		local newVector = {x = posX or 0.0, y = posY or 0.0, z = posZ or 0.0}
		return setmetatable(newVector, {__index = Vector3D})
	end,

	Copy = function(self)
		return Vector3D:new(self.x, self.y, self.z)
	end,

	Normalize = function(self)
		local mod = self:Module()
		if mod ~= 0 then
			self.x = self.x / mod
			self.y = self.y / mod
			self.z = self.z / mod
		end
	end,

	Dot = function(self, V)
		return self.x * V.x + self.y * V.y + self.z * V.z
	end,

	Module = function(self)
		return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
	end,

	AddV = function(self, V)
		return Vector3D:new(self.x + V.x, self.y + V.y, self.z + V.z)
	end,

	SubV = function(self, V)
		return Vector3D:new(self.x - V.x, self.y - V.y, self.z - V.z)
	end,

	CrossV = function(self, V)
		return Vector3D:new(self.y * V.z - self.z * V.y, self.z * V.x - self.x * V.z, self.x * V.y - self.y * V.z)
	end,

	Mul = function(self, n)
		return Vector3D:new(self.x * n, self.y * n, self.z * n)
	end,

	Div = function(self, n)
		return Vector3D:new(self.x / n, self.y / n, self.z / n)
	end,

	MulV = function(self, V)
		return Vector3D:new(self.x * V.x, self.y * V.y, self.z * V.z)
	end,

	DivV = function(self, V)
		return Vector3D:new(self.x / V.x, self.y / V.y, self.z / V.z)
	end
}