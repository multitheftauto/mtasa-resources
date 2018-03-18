-- XYZ euler rotation to YXZ euler rotation
function convertRotationToMTA(rx, ry, rz)
	local sinX = math.sin(rx)
	local cosX = math.cos(rx)
	local sinY = math.sin(ry)
	local cosY = math.cos(ry)
	local sinZ = math.sin(rz)
	local cosZ = math.cos(rz)

	local newRx = math.asin(cosY * sinX)

	local newRy = math.atan2(sinY, cosX * cosY)

	local newRz = math.atan2(cosX * sinZ - cosZ * sinX * sinY,
		cosX * cosZ + sinX * sinY * sinZ)

	return math.deg(newRx), math.deg(newRy), math.deg(newRz)
end

-- YXZ rotation to XYZ rotation
function convertRotationFromMTA(rx, ry, rz)
	rx = math.rad(rx)
	ry = math.rad(ry)
	rz = math.rad(rz)

	local sinX = math.sin(rx)
	local cosX = math.cos(rx)
	local sinY = math.sin(ry)
	local cosY = math.cos(ry)
	local sinZ = math.sin(rz)
	local cosZ = math.cos(rz)

	return math.atan2(sinX, cosX * cosY), math.asin(cosX * sinY), math.atan2(cosZ * sinX * sinY + cosY * sinZ,
		cosY * cosZ - sinX * sinY * sinZ)
end
