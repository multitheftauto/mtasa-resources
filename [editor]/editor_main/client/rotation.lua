local rotationFixes = {}
local elementQuat = {}
local fromQuatThreshold = 0.499999999

function loadRotationFixXML()
	local xmlRoot = xmlLoadFile("client/rotation_fix.xml")
	if not xmlRoot then
		outputDebugString("Cannot load rotation_fix.xml")
		return false
	end

	rotationFixes = {}

	local models = xmlNodeGetChildren(xmlRoot)
	for k,model in ipairs(models) do
		local id = tonumber(xmlNodeGetAttribute(model, "id"))
		local x = tonumber(xmlNodeGetAttribute(model, "x"))
		local y = tonumber(xmlNodeGetAttribute(model, "y"))
		local z = tonumber(xmlNodeGetAttribute(model, "z"))
		local w = tonumber(xmlNodeGetAttribute(model, "w"))

		if id and x and y and z and w then
			rotationFixes[id] = {z, y, x, w}
		else
			outputDebugString("Incorrect entry in rotation_fix.xml")
		end
	end

	xmlUnloadFile(xmlRoot)

	return true
end

function clearElementQuat(element)
	elementQuat[element] = nil
end

addEventHandler("onClientElementDestroy", root, function()
	clearElementQuat(source)
end)

function applyIncrementalRotation(element, axis, angle, world_space)
	-- Create the offset angle/axis quaternion
	local offset_quat -- Normalized
	local arad = math.rad(angle)
	local sina = math.sin(arad / 2)

	if axis == "yaw" then
		offset_quat = {
			sina, 0, 0
		}
	elseif axis == "pitch" then
		offset_quat = {
			0, sina, 0
		}
	elseif axis == "roll" then
		offset_quat = {
			0, 0, sina
		}
	else
		return false
	end
	offset_quat[4] = math.cos(arad / 2)

	-- Get rotation patch userdata
	local enableRotPatch = exports["editor_gui"]:sx_getOptionData("enableRotPatch")

	-- Get current rotation
	local cur_quat
	if elementQuat[element] then
		cur_quat = elementQuat[element]
	else
		local euler_rot = {getElementRotation(element, "ZYX")}
		-- Is it not rotated ingame
		if euler_rot[1] == 0 and euler_rot[2] == 0 and euler_rot[3] == 0 then
			-- Is there a fix and are rotation patches enabled
			local id = getElementModel(element)
			if rotationFixes[id] and enableRotPatch then
				-- Rotate from the fix
				cur_quat = {unpack(rotationFixes[id])}
			else
				-- Rotate from 0
				cur_quat = {1, 0, 0, 0}
			end
		else
			-- Convert the current euler rotation to quaternion
			cur_quat = getQuatFromEuler(euler_rot)
		end
	end

	-- Check if rotation patch is enabled
	if enableRotPatch then
		-- Rotate by the offset quaternion
		-- Right or left multiplication for world or local space
		cur_quat = world_space == true and quatMul(cur_quat, offset_quat) or quatMul(offset_quat, cur_quat)
	else
		-- Do the old rotation behaviour
		if world_space then
			cur_quat = axis == "yaw" and quatMul(cur_quat, offset_quat) or quatMul(offset_quat, cur_quat)
		else
			cur_quat = quatMul(offset_quat, cur_quat)
		end
	end

	elementQuat[element] = cur_quat

	-- Convert to euler and apply
	local cur_euler = getEulerFromQuat(cur_quat)
	setElementRotation(element, cur_euler[1], cur_euler[2], cur_euler[3], "ZYX")

	return unpack(cur_euler)
end

-- https://paroj.github.io/gltut/Positioning/Tut08%20Quaternions.html
function quatMul(a, b)
	local result = {}
	result[1] = a[4]*b[1] + a[1]*b[4] + a[2]*b[3] - a[3]*b[2]
	result[2] = a[4]*b[2] + a[2]*b[4] + a[3]*b[1] - a[1]*b[3]
	result[3] = a[4]*b[3] + a[3]*b[4] + a[1]*b[2] - a[2]*b[1]
	result[4] = a[4]*b[4] - a[1]*b[1] - a[2]*b[2] - a[3]*b[3]
	return result
end

-- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
function getQuatFromEuler(euler)
	local result = {}
	local tcos = {}
	local tsin = {}
	for i=1,3 do
		tcos[i] = math.cos(math.rad(euler[i]/2))
		tsin[i] = math.sin(math.rad(euler[i]/2))
	end
	result[1] = tcos[1]*tcos[2]*tcos[3] + tsin[1]*tsin[2]*tsin[3]
	result[2] = tsin[1]*tcos[2]*tcos[3] - tcos[1]*tsin[2]*tsin[3]
	result[3] = tcos[1]*tsin[2]*tcos[3] + tsin[1]*tcos[2]*tsin[3]
	result[4] = tcos[1]*tcos[2]*tsin[3] - tsin[1]*tsin[2]*tcos[3]
	return result
end

function getEulerFromQuat(quat)
    local q0, q1, q2, q3 = quat[1], quat[2], quat[3], quat[4]
    local threshold = q0 * q2 - q3 * q1

    if threshold > fromQuatThreshold then
        return {math.deg(2 * math.atan2(q1, q0)), 90, 0}
    elseif threshold < -fromQuatThreshold then
        return {math.deg(2 * math.atan2(q1, q0)), -90, 0}
    else
        return {
            math.deg(math.atan2(2 * (q0 * q1 + q2 * q3), 1 - 2 * (q1^2 + q2^2))),
            math.deg(math.asin(2 * threshold)),
            math.deg(math.atan2(2 * (q0 * q3 + q1 * q2), 1 - 2 * (q2^2 + q3^2)))
        }
    end
end