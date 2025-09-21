function newVector3D(posX, posY, posZ)
	local newVector = {x = posX or 0.0, y = posY or 0.0, z = posZ or 0.0}
	return newVector
end

function moduleVector3D(vector3D)
	if not vector3D or type(vector3D.x) ~= "number" then
		return 0
	end
	return math.sqrt(vector3D.x * vector3D.x + vector3D.y * vector3D.y + vector3D.z * vector3D.z)
end

function normalizeVector3D(vector3D)
	if not vector3D or type(vector3D.x) ~= "number" then
		return newVector3D(0, 0, 0)
	end
	local mod = moduleVector3D(vector3D)
	if mod ~= 0 then
		vector3D.x = vector3D.x / mod
		vector3D.y = vector3D.y / mod
		vector3D.z = vector3D.z / mod
	end
	return vector3D
end

function mulVector3D(vector3D, n)
	if not vector3D or type(vector3D.x) ~= "number" or type(n) ~= "number" then
		return newVector3D(0, 0, 0)
	end
	return newVector3D(vector3D.x * n, vector3D.y * n, vector3D.z * n)
end
