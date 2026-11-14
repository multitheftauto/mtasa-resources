function isRotatableMarker(element)
	if isElement(element) and getElementType(element) == "marker" then
		local markerType = getMarkerType(element)
		return markerType == "ring" or markerType == "checkpoint"
	end
	return false
end

local function parseMarkerTarget(target)
	if type(target) == "string" then
		target = split(target, 44)
	end
	if type(target) ~= "table" then return false end
	local x, y, z = tonumber(target[1]), tonumber(target[2]), tonumber(target[3])
	if not x or not y or not z then return false end
	return x, y, z
end

local function getMarkerTargetPosition(element)
	-- Prefer EDF's saved coordinates to avoid the precision loss from round-tripping through rotation.
	local target = getElementData(element, "target")
	if target == "" then return false end
	if target ~= nil and target ~= false then
		return parseMarkerTarget(target)
	end
	return getMarkerTarget(element)
end

function edfApplyMarkerTargetArrowProperties(element, targetColor, targetSize, targetIsSet)
	if not isRotatableMarker(element) or getMarkerType(element) ~= "checkpoint" then
		return true
	end
	if targetColor == nil and targetSize == nil then
		return true
	end
	local target = getElementData(element, "target")
	if targetIsSet == nil then
		targetIsSet = target and target ~= ""
	end
	if not targetIsSet then
		return true
	end

	local red, green, blue, alpha = getMarkerTargetArrowProperties(element)
	if not red then return false end
	if targetColor == "" then
		red, green, blue, alpha = 255, 64, 64, 255
	elseif targetColor then
		red, green, blue, alpha = getColorFromString(targetColor)
		if not red then return false end
	end

	local requestedSize = tonumber(targetSize)
	if targetSize ~= nil and targetSize ~= false and targetSize ~= "" and not requestedSize then return false end
	if requestedSize and requestedSize < 0 then return false end
	if requestedSize and requestedSize > 0 then
		return setMarkerTargetArrowProperties(element, red, green, blue, alpha, requestedSize)
	end
	return setMarkerTargetArrowProperties(element, red, green, blue, alpha)
end

-- Keep targets on unsupported marker types so switching back restores the direction.
function edfSetMarkerTarget(element, target)
	if not isRotatableMarker(element) then
		return true
	end
	if not target or target == "" then
		-- MTA's Lua setter requires a target, so emulate each marker type's no-target default.
		local markerType = getMarkerType(element)
		local success
		if markerType == "checkpoint" then
			success = setMarkerIcon(element, "none")
		else
			local x, y, z = getElementPosition(element)
			success = setMarkerTarget(element, x + 1, y, z)
		end
		if not success then return false end
		return setElementData(element, "target", "", not isClient())
	end
	local x, y, z = parseMarkerTarget(target)
	if not x then return false end
	if not setMarkerTarget(element, x, y, z) then return false end
	local storedTarget = type(target) == "string" and target or string.format("%.9g,%.9g,%.9g", x, y, z)
	return setElementData(element, "target", storedTarget, not isClient())
end

-- Marker rotations use ZYX Euler angles, like the editor's rotation controls.
function edfGetMarkerRotation(element)
	local x, y, z = getElementPosition(element)
	local tx, ty, tz = getMarkerTargetPosition(element)
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
	local tx, ty, tz = getMarkerTargetPosition(element)
	if not tx and rx == 0 and ry == 0 and rz == -90 then return true end
	local distance = tx and math.sqrt((tx - x)^2 + (ty - y)^2 + (tz - z)^2) or 1
	if distance < 0.001 then distance = 1 end
	local sx, cx = math.sin(math.rad(rx)), math.cos(math.rad(rx))
	local sy, cy = math.sin(math.rad(ry)), math.cos(math.rad(ry))
	local sz, cz = math.sin(math.rad(rz)), math.cos(math.rad(rz))
	return storeMarkerTarget(element, x + distance * (sx * sy * cz - cx * sz),
		y + distance * (sx * sy * sz + cx * cz), z + distance * sx * cy)
end

-- Marker targets are absolute world coordinates; moving a marker must not translate them.
function edfMoveMarker(element, x, y, z)
	local keepRingDefaultDirection = getMarkerType(element) == "ring" and getElementData(element, "target") == ""
	if not setElementPosition(element, x, y, z) then return false end
	-- A cleared ring uses a synthetic +X target because MTA has no clear-target API.
	if keepRingDefaultDirection then
		return setMarkerTarget(element, x + 1, y, z)
	end
	return true
end

function isClient()
	return getLocalPlayer and true
end
