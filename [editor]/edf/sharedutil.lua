function isRotatableMarker(element)
	if isElement(element) and getElementType(element) == "marker" then
		local markerType = getMarkerType(element)
		return markerType == "ring" or markerType == "checkpoint"
	end
	return false
end

-- Keep targets on unsupported marker types so switching back restores the direction.
function edfSetMarkerTarget(element, target)
	if not isRotatableMarker(element) then
		return true
	end
	if not target or target == "" then
		return setMarkerTarget(element)
	end
	if type(target) == "string" then
		target = split(target, 44)
	end
	if type(target) ~= "table" then return false end
	local x, y, z = tonumber(target[1]), tonumber(target[2]), tonumber(target[3])
	if not x or not y or not z then return false end
	return setMarkerTarget(element, x, y, z)
end

-- Marker rotations use ZYX Euler angles, like the editor's rotation controls.
function edfGetMarkerRotation(element)
	local x, y, z = getElementPosition(element)
	local tx, ty, tz = getMarkerTarget(element)
	-- MTA rings without a target face along the positive X axis.
	if not tx then return 0, 0, -90 end
	local dx, dy, dz = tx - x, ty - y, tz - z
	local horizontal = math.sqrt(dx * dx + dy * dy)
	return math.deg(math.atan2(dz, horizontal)), 0, math.deg(math.atan2(-dx, dy))
end

local function storeMarkerTarget(element, x, y, z)
	if not setMarkerTarget(element, x, y, z) then return false end
	return setElementData(element, "target", string.format("%.9g,%.9g,%.9g", x, y, z), not isClient())
end

function edfSetMarkerRotation(element, rx, ry, rz)
	local x, y, z = getElementPosition(element)
	local tx, ty, tz = getMarkerTarget(element)
	if not tx and rx == 0 and ry == 0 and rz == -90 then return true end
	local distance = tx and math.sqrt((tx - x)^2 + (ty - y)^2 + (tz - z)^2) or 1
	if distance < 0.001 then distance = 1 end
	local sx, cx = math.sin(math.rad(rx)), math.cos(math.rad(rx))
	local sy, cy = math.sin(math.rad(ry)), math.cos(math.rad(ry))
	local sz, cz = math.sin(math.rad(rz)), math.cos(math.rad(rz))
	return storeMarkerTarget(element, x + distance * (sx * sy * cz - cx * sz),
		y + distance * (sx * sy * sz + cx * cz), z + distance * sx * cy)
end

function edfMoveMarker(element, x, y, z)
	local px, py, pz = getElementPosition(element)
	local tx, ty, tz = getMarkerTarget(element)
	if not setElementPosition(element, x, y, z) then return false end
	if tx then
		return storeMarkerTarget(element, tx + x - px, ty + y - py, tz + z - pz)
	end
	return true
end

function isClient()
	return getLocalPlayer and true
end
