--[[
	Collection of functions to detect if a line hits a shape

	Special thanks to Rayco "XeNMaX" Hernandez García for his BIG help.
]]

local ZERO_TOLERANCE = 0.000001

Vector3D = {
	new = function(self, x2, y2, z2)
		local newVector = { x = x2 or 0.0, y = y2 or 0.0, z = z2 or 0.0 }
		return setmetatable(newVector, { __index = Vector3D })
	end,

	Copy = function(self)
		return Vector3D:new(self.x, self.y, self.z)
	end,

	Normalize = function(self)
		local mod = self:Module()
		self.x = self.x / mod
		self.y = self.y / mod
		self.z = self.z / mod
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
		return Vector3D:new(self.y * V.z - self.z * V.y,
		                    self.z * V.x - self.x * V.z,
				    self.x * V.y - self.y * V.z)
	end,

	Mul = function(self, n)
		return Vector3D:new(self.x * n, self.y * n, self.z * n)
	end,

	Div = function(self, n)
		return Vector3D:new(self.x / n, self.y / n, self.z / n)
	end,
}


collisionTest = { }

collisionTest.Rectangle = function(lineStart, lineEnd, rectangleCenter, sizeX, sizeY )
    -- check if line intersects rectangle around element
	local ratio = rectangleCenter.z / lineEnd.z

	lineEnd.x = rectangleCenter.x * lineEnd.x
	lineEnd.y = rectangleCenter.y * lineEnd.y
	lineEnd.z = rectangleCenter.z

	if lineEnd.x < (rectangleCenter.x + sizeX/2) and lineEnd.x > (rectangleCenter.x - sizeX/2) then
		if lineEnd.y < (rectangleCenter.y + sizeY/2) and lineEnd.y > (rectangleCenter.y - sizeY/2) then
			return lineEnd
		end
	end
end

collisionTest.Sphere = function(lineStart, lineEnd, sphereCenter, sphereRadius)
        -- check if line intersects sphere around element
	local vec = Vector3D:new(lineEnd.x - lineStart.x, lineEnd.y - lineStart.y, lineEnd.z - lineStart.z)

	local A = vec.x^2 + vec.y^2 + vec.z^2
	local B = ( (lineStart.x - sphereCenter.x) * vec.x + (lineStart.y - sphereCenter.y) * vec.y + (lineStart.z - sphereCenter.z) * vec.z ) * 2
	local C = ( (lineStart.x - sphereCenter.x)^2 + (lineStart.y - sphereCenter.y)^2 + (lineStart.z - sphereCenter.z)^2 ) - sphereRadius^2

	local delta = B^2 - 4*A*C

	if (delta >= 0) then
		delta = math.sqrt(delta)
		local t = (-B - delta) / (2*A)

		if (t > 0) then
			return Vector3D:new(lineStart.x + vec.x * t, lineStart.y + vec.y * t, lineStart.z + vec.z * t)
		end
	end
end

collisionTest.Cylinder = function(lineStart, lineEnd, cylCenter, cylRadius, cylHeight)
	local kU = Vector3D:new(1, 0, 0)
	local kV = Vector3D:new(0, 1, 0)
	local kW = Vector3D:new(0, 0, 1)
	local rkDir = lineEnd:SubV(lineStart)
	rkDir:Normalize()

	local afT = { 0.0, 0.0 }

	local fHalfHeight = cylHeight * 0.5
	local fRSqr = cylRadius * cylRadius

	local kDiff = lineStart:SubV(cylCenter)
	local kP = Vector3D:new(kU:Dot(kDiff), kV:Dot(kDiff), kW:Dot(kDiff))

	local fDz = kW:Dot(rkDir)

	if (math.abs(fDz) >= 1.0 - ZERO_TOLERANCE) then
		local fRadialSqrDist = fRSqr - kP.x * kP.x - kP.y * kP.y
		if (fRadialSqrDist < 0.0) then
			return nil
		end

		if (fDz > 0.0) then
			afT[1] = -kP.z - fHalfHeight
			if afT[1] < 0 then return nil end
			return lineStart:AddV(rkDir:Mul(afT[1]))
		else
			afT[1] = kP.z - fHalfHeight
			if afT[1] < 0 then return nil end
			return lineStart:AddV(rkDir:Mul(afT[1]))
		end
	end

	local kD = Vector3D:new(kU:Dot(rkDir), kV:Dot(rkDir), fDz)
	local fA0, fA1, fA2, fDiscr, fRoot, fInv, fT

	if (math.abs(kD.z) <= ZERO_TOLERANCE) then
		if (math.abs(kP.z) > fHalfHeight) then
			return nil
		end

		fA0 = kP.x * kP.x + kP.y * kP.y - fRSqr
		fA1 = kP.x * kD.x + kP.y * kD.y
		fA2 = kD.x * kD.x + kD.y * kD.y
		fDiscr = fA1 * fA1 - fA0 * fA2

		if (fDiscr < 0.0) then
			return nil

		elseif (fDiscr > ZERO_TOLERANCE) then
			fRoot = math.sqrt(fDiscr)
			fInv = 1.0 / fA2
			afT[1] = (-fA1 - fRoot) * fInv

			if afT[1] < 0 then return nil end
			return lineStart:AddV(rkDir:Mul(afT[1]))
		else
			afT[1] = -fA1 / fA2
			if afT[1] < 0 then return nil end
			return lineStart:AddV(rkDir:Mul(afT[1]))
		end
	end

	local iQuantity = 0
	fInv = 1.0 / kD.z

	local fT0 = (-fHalfHeight - kP.z) * fInv
	local fXTmp = kP.x + fT0 * kD.x
	local fYTmp = kP.y + fT0 * kD.y
	if (fXTmp * fXTmp + fYTmp * fYTmp <= fRSqr) then
		iQuantity = iQuantity + 1
		afT[iQuantity] = fT0
	end

	local fT1 = (fHalfHeight - kP.z) * fInv
	fXTmp = kP.x + fT1 * kD.x
	fYTmp = kP.y + fT1 * kD.y
	if (fXTmp * fXTmp + fYTmp * fYTmp <= fRSqr) then
		iQuantity = iQuantity + 1
		afT[iQuantity] = fT1
	end

	if (iQuantity == 2) then
		if (afT[1] > afT[2]) then
			local fSave = afT[1]
			afT[1] = afT[2]
			afT[2] = fSave
		end

		if afT[1] < 0 then return nil end
		return lineStart:AddV(rkDir:Mul(afT[1]))
	end

	fA0 = kP.x * kP.x + kP.y * kP.y - fRSqr
	fA1 = kP.x * kD.x + kP.y * kD.y
	fA2 = kD.x * kD.x + kD.y * kD.y
	fDiscr = fA1 * fA1 - fA0 * fA2
	if (fDiscr < 0.0) then
		return nil

	elseif (fDiscr > ZERO_TOLERANCE) then
		fRoot = math.sqrt(fDiscr)
		fInv = 1.0 / fA2
		fT = (-fA1 - fRoot) * fInv
		if (fT0 <= fT1) then
			if (fT0 <= fT and fT <= fT1) then
				iQuantity = iQuantity + 1
				afT[iQuantity] = fT
			end
		else
			if (fT1 <= fT and fT <= fT0) then
				iQuantity = iQuantity + 1
				afT[iQuantity] = fT
			end
		end

		if (iQuantity == 2) then
			if (afT[1] > afT[2]) then
				local fSave = afT[1]
				afT[1] = afT[2]
				afT[2] = fSave
			end

			if afT[1] < 0 then return nil end
			return lineStart:AddV(rkDir:Mul(afT[1]))
		end

		fT = (-fA1 + fRoot) * fInv
		if (fT0 <= fT1) then
			if (fT0 <= fT and fT <= fT1) then
				iQuantity = iQuantity + 1
				afT[iQuantity] = fT
			end
		else
			if (fT1 <= fT and fT <= fT0) then
				iQuantity = iQuantity + 1
				afT[iQuantity] = fT
			end
		end
	else
		fT = -fA1 / fA2
		if (fT0 <= fT1) then
			if (fT0 <= fT and fT <= fT1) then
				iQuantity = iQuantity + 1
				afT[iQuantity] = fT
			end
		else
			if (fT1 <= fT and fT <= fT0) then
				iQuantity = iQuantity + 1
				afT[iQuantity] = fT
			end
		end
	end

	if (iQuantity == 2) then
		if (afT[1] > afT[2]) then
			local fSave = afT[1]
			afT[1] = afT[2]
			afT[2] = fSave
		end

		if afT[1] < 0 then return nil end
		return lineStart:AddV(rkDir:Mul(afT[1]))
	elseif (iQuantity == 1) then
		if afT[1] < 0 then return nil end
		return lineStart:AddV(rkDir:Mul(afT[1]))
	end

	return nil
end
