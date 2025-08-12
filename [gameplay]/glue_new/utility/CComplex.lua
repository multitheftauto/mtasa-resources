-- Glue only uses this as a library, to perform specific calls. This is done to enhance precision of glue position/seamlessness.
-- 99.5% of the code in this library will never be read by Glue, it's not a bottleneck at all.

--[[
	complex 0.3.0 LIBRARY
	Lua 5.1

	MODIFIED TO SUIT THE MTA SCRIPTING SYSTEM

	Note: for Glue script, all code comments were removed. Visit the original library source to get them, (Lua community) if you want to use this lib for other purposes.

]] --

complex = {}

local complex_meta = {}

local _retone = function() return 1 end
local _retminusone = function() return -1 end
function complex.to(num)
	if type(num) == "table" then
		if getmetatable(num) == complex_meta then
			return num
		end
		local real, imag = tonumber(num[1]), tonumber(num[2])
		if real and imag then
			return setmetatable({ real, imag }, complex_meta)
		end
		return
	end

	local isnum = tonumber(num)
	if isnum then
		return setmetatable({ isnum, 0 }, complex_meta)
	end
	if type(num) == "string" then
		local real, sign, imag = string.match(num, "^([%-%+%*%^%d%./Ee]*%d)([%+%-])([%-%+%*%^%d%./Ee]*)i$")
		if real then
			if string.lower(string.sub(real, 1, 1)) == "e"
				or string.lower(string.sub(imag, 1, 1)) == "e" then
				return
			end
			if imag == "" then
				if sign == "+" then
					imag = _retone
				else
					imag = _retminusone
				end
			elseif sign == "+" then
				imag = loadstring("return tonumber(" .. imag .. ")")
			else
				imag = loadstring("return tonumber(" .. sign .. imag .. ")")
			end
			real = loadstring("return tonumber(" .. real .. ")")
			if real and imag then
				return setmetatable({ real(), imag() }, complex_meta)
			end
			return
		end

		local imag = string.match(num, "^([%-%+%*%^%d%./Ee]*)i$")
		if imag then
			if imag == "" then
				return setmetatable({ 0, 1 }, complex_meta)
			elseif imag == "-" then
				return setmetatable({ 0, -1 }, complex_meta)
			end
			if string.lower(string.sub(imag, 1, 1)) ~= "e" then
				imag = loadstring("return tonumber(" .. imag .. ")")
				if imag then
					return setmetatable({ 0, imag() }, complex_meta)
				end
			end
			return
		end

		local real = string.match(num, "^(%-*[%d%.][%-%+%*%^%d%./Ee]*)$")
		if real then
			real = loadstring("return tonumber(" .. real .. ")")
			if real then
				return setmetatable({ real(), 0 }, complex_meta)
			end
		end
	end
end

setmetatable(complex, { __call = function(_, num) return complex.to(num) end })


function complex.new(...)
	return setmetatable({ ... }, complex_meta)
end

function complex.type(arg)
	if getmetatable(arg) == complex_meta then
		return "complex"
	end
end

function complex.convpolar(radius, phi)
	return setmetatable({ radius * math.cos(phi), radius * math.sin(phi) }, complex_meta)
end

function complex.convpolardeg(radius, phi)
	phi = phi / 180 * math.pi
	return setmetatable({ radius * math.cos(phi), radius * math.sin(phi) }, complex_meta)
end

function complex.tostring(cx, formatstr)
	local real, imag = cx[1], cx[2]
	if formatstr then
		if imag == 0 then
			return string.format(formatstr, real)
		elseif real == 0 then
			return string.format(formatstr, imag) .. "i"
		elseif imag > 0 then
			return string.format(formatstr, real) .. "+" .. string.format(formatstr, imag) .. "i"
		end
		return string.format(formatstr, real) .. string.format(formatstr, imag) .. "i"
	end
	if imag == 0 then
		return real
	elseif real == 0 then
		return ((imag == 1 and "") or (imag == -1 and "-") or imag) .. "i"
	elseif imag > 0 then
		return real .. "+" .. (imag == 1 and "" or imag) .. "i"
	end
	return real .. (imag == -1 and "-" or imag) .. "i"
end

function complex.print(...)
	print(complex.tostring(...))
end

function complex.polar(cx)
	return math.sqrt(cx[1] ^ 2 + cx[2] ^ 2), math.atan2(cx[2], cx[1])
end

function complex.polardeg(cx)
	return math.sqrt(cx[1] ^ 2 + cx[2] ^ 2), math.atan2(cx[2], cx[1]) / math.pi * 180
end

function complex.mulconjugate(cx)
	return cx[1] ^ 2 + cx[2] ^ 2
end

function complex.abs(cx)
	return math.sqrt(cx[1] ^ 2 + cx[2] ^ 2)
end

function complex.get(cx)
	return cx[1], cx[2]
end

function complex.set(cx, real, imag)
	cx[1], cx[2] = real, imag
end

function complex.is(cx, real, imag)
	if cx[1] == real and cx[2] == imag then
		return true
	end
	return false
end

function complex.copy(cx)
	return setmetatable({ cx[1], cx[2] }, complex_meta)
end

function complex.add(cx1, cx2)
	return setmetatable({ cx1[1] + cx2[1], cx1[2] + cx2[2] }, complex_meta)
end

function complex.sub(cx1, cx2)
	return setmetatable({ cx1[1] - cx2[1], cx1[2] - cx2[2] }, complex_meta)
end

function complex.mul(cx1, cx2)
	return setmetatable({ cx1[1] * cx2[1] - cx1[2] * cx2[2], cx1[1] * cx2[2] + cx1[2] * cx2[1] }, complex_meta)
end

function complex.mulnum(cx, num)
	return setmetatable({ cx[1] * num, cx[2] * num }, complex_meta)
end

function complex.div(cx1, cx2)
	local val = cx2[1] ^ 2 + cx2[2] ^ 2

	return setmetatable({ (cx1[1] * cx2[1] + cx1[2] * cx2[2]) / val, (cx1[2] * cx2[1] - cx1[1] * cx2[2]) / val },
		complex_meta)
end

function complex.divnum(cx, num)
	return setmetatable({ cx[1] / num, cx[2] / num }, complex_meta)
end

function complex.pow(cx, num)
	if math.floor(num) == num then
		if num < 0 then
			local val = cx[1] ^ 2 + cx[2] ^ 2
			cx = { cx[1] / val, -cx[2] / val }
			num = -num
		end
		local real, imag = cx[1], cx[2]
		for i = 2, num do
			real, imag = real * cx[1] - imag * cx[2], real * cx[2] + imag * cx[1]
		end
		return setmetatable({ real, imag }, complex_meta)
	end

	local length, phi = math.sqrt(cx[1] ^ 2 + cx[2] ^ 2) ^ num, math.atan2(cx[2], cx[1]) * num
	return setmetatable({ length * math.cos(phi), length * math.sin(phi) }, complex_meta)
end

function complex.sqrt(cx)
	local len = math.sqrt(cx[1] ^ 2 + cx[2] ^ 2)
	local sign = (cx[2] < 0 and -1) or 1
	return setmetatable({ math.sqrt((cx[1] + len) / 2), sign * math.sqrt((len - cx[1]) / 2) }, complex_meta)
end

function complex.ln(cx)
	return setmetatable({ math.log(math.sqrt(cx[1] ^ 2 + cx[2] ^ 2)),
		math.atan2(cx[2], cx[1]) }, complex_meta)
end

function complex.exp(cx)
	local expreal = math.exp(cx[1])
	return setmetatable({ expreal * math.cos(cx[2]), expreal * math.sin(cx[2]) }, complex_meta)
end

function complex.conjugate(cx)
	return setmetatable({ cx[1], -cx[2] }, complex_meta)
end

function complex.round(cx, idp)
	local mult = 10 ^ (idp or 0)
	return setmetatable({ math.floor(cx[1] * mult + 0.5) / mult,
		math.floor(cx[2] * mult + 0.5) / mult }, complex_meta)
end

complex_meta.__add = function(cx1, cx2)
	local cx1, cx2 = complex.to(cx1), complex.to(cx2)
	return complex.add(cx1, cx2)
end
complex_meta.__sub = function(cx1, cx2)
	local cx1, cx2 = complex.to(cx1), complex.to(cx2)
	return complex.sub(cx1, cx2)
end
complex_meta.__mul = function(cx1, cx2)
	local cx1, cx2 = complex.to(cx1), complex.to(cx2)
	return complex.mul(cx1, cx2)
end
complex_meta.__div = function(cx1, cx2)
	local cx1, cx2 = complex.to(cx1), complex.to(cx2)
	return complex.div(cx1, cx2)
end
complex_meta.__pow = function(cx, num)
	if num == "*" then
		return complex.conjugate(cx)
	end
	return complex.pow(cx, num)
end
complex_meta.__unm = function(cx)
	return setmetatable({ -cx[1], -cx[2] }, complex_meta)
end
complex_meta.__eq = function(cx1, cx2)
	if cx1[1] == cx2[1] and cx1[2] == cx2[2] then
		return true
	end
	return false
end
complex_meta.__tostring = function(cx)
	return tostring(complex.tostring(cx))
end
complex_meta.__concat = function(cx, cx2)
	return tostring(cx) .. tostring(cx2)
end

complex_meta.__call = function(...)
	print(complex.tostring(...))
end
complex_meta.__index = {}
for k, v in pairs(complex) do
	complex_meta.__index[k] = v
end