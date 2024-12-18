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