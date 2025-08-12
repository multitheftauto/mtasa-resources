-- Glue only uses this as a library, to perform specific calls. This is done to enhance precision of glue position/seamlessness.
-- 99.5% of the code in this library will never be read by Glue, it's not a bottleneck at all.

--[[
	matrix v 0.2.8
	Lua 5.1 compatible

	'matrix' provides a good selection of matrix functions.

	MODIFIED TO SUIT THE MTA SCRIPTING SYSTEM
	Note: for Glue script, all code comments were removed. Visit the original library source to get them, (Lua community) if you want to use this lib for other purposes.
]] --

--////////////
--// matrix //
--////////////

matrix = {}

local matrix_meta = {}

local symbol_meta = {}; symbol_meta.__index = symbol_meta

local function newsymbol(o)
	return setmetatable({ tostring(o) }, symbol_meta)
end


function matrix:new(rows, columns, value)
	if type(rows) == "table" then
		if type(rows[1]) ~= "table" then
			return setmetatable({ { rows[1] }, { rows[2] }, { rows[3] } }, matrix_meta)
		end
		return setmetatable(rows, matrix_meta)
	end

	local mtx = {}
	local value = value or 0

	if columns == "I" then
		for i = 1, rows do
			mtx[i] = {}
			for j = 1, rows do
				if i == j then
					mtx[i][j] = 1
				else
					mtx[i][j] = 0
				end
			end
		end
	else
		for i = 1, rows do
			mtx[i] = {}
			for j = 1, columns do
				mtx[i][j] = value
			end
		end
	end

	return setmetatable(mtx, matrix_meta)
end

setmetatable(matrix, { __call = function(...) return matrix.new(...) end })

function matrix.add(m1, m2)
	local mtx = {}
	for i = 1, #m1 do
		mtx[i] = {}
		for j = 1, #m1[1] do
			mtx[i][j] = m1[i][j] + m2[i][j]
		end
	end
	return setmetatable(mtx, matrix_meta)
end

function matrix.sub(m1, m2)
	local mtx = {}
	for i = 1, #m1 do
		mtx[i] = {}
		for j = 1, #m1[1] do
			mtx[i][j] = m1[i][j] - m2[i][j]
		end
	end
	return setmetatable(mtx, matrix_meta)
end

function matrix.mul(m1, m2)
	local mtx = {}
	for i = 1, #m1 do
		mtx[i] = {}
		for j = 1, #m2[1] do
			local num = m1[i][1] * m2[1][j]
			for n = 2, #m1[1] do
				num = num + m1[i][n] * m2[n][j]
			end
			mtx[i][j] = num
		end
	end
	return setmetatable(mtx, matrix_meta)
end

function matrix.div(m1, m2)
	local rank; m2, rank = matrix.invert(m2)
	if not m2 then return m2, rank end
	return matrix.mul(m1, m2)
end

function matrix.mulnum(m1, num)
	if type(num) == "string" then
		num = complex.to(num) or newsymbol(num)
	end
	local mtx = {}
	for i = 1, #m1 do
		mtx[i] = {}
		for j = 1, #m1[1] do
			mtx[i][j] = m1[i][j] * num
		end
	end
	return setmetatable(mtx, matrix_meta)
end

function matrix.divnum(m1, num)
	if type(num) == "string" then
		num = complex.to(num) or newsymbol(num)
	end
	local mtx = {}

	for i = 1, #m1 do
		mtx[i] = {}
		for j = 1, #m1[1] do
			mtx[i][j] = m1[i][j] / num
		end
	end
	return setmetatable(mtx, matrix_meta)
end

function matrix.pow(m1, num)
	assert(num == math.floor(num), "exponent not an integer")
	if num == 0 then
		return matrix:new(#m1, "I")
	end
	if num < 0 then
		local rank; m1, rank = matrix.invert(m1)
		if not m1 then return m1, rank end -- singular
		num = -num
	end
	local mtx = matrix.copy(m1)
	for i = 2, num do
		mtx = matrix.mul(mtx, m1)
	end
	return mtx
end

local fiszerocomplex = function(cx) return complex.is(cx, 0, 0) end
local fiszeronumber = function(num) return num == 0 end
function matrix.det(m1)
	assert(#m1 == #m1[1], "matrix not square")

	local size = #m1

	if size == 1 then
		return m1[1][1]
	end

	if size == 2 then
		return m1[1][1] * m1[2][2] - m1[2][1] * m1[1][2]
	end

	if size == 3 then
		return (m1[1][1] * m1[2][2] * m1[3][3] + m1[1][2] * m1[2][3] * m1[3][1] + m1[1][3] * m1[2][1] * m1[3][2]
			- m1[1][3] * m1[2][2] * m1[3][1] - m1[1][1] * m1[2][3] * m1[3][2] - m1[1][2] * m1[2][1] * m1[3][3])
	end


	local fiszero, abs
	if matrix.type(m1) == "complex" then
		fiszero = fiszerocomplex
		abs = complex.mulconjugate
	else
		fiszero = fiszeronumber
		abs = math.abs
	end

	local mtx = matrix.copy(m1)
	local det = 1

	for j = 1, #mtx[1] do
		local rows = #mtx
		local subdet, xrow
		for i = 1, rows do
			local e = mtx[i][j]
			if not subdet then
				if not fiszero(e) then
					subdet, xrow = e, i
				end
			elseif (not fiszero(e)) and math.abs(abs(e) - 1) < math.abs(abs(subdet) - 1) then
				subdet, xrow = e, i
			end
		end
		if subdet then
			if xrow ~= rows then
				mtx[rows], mtx[xrow] = mtx[xrow], mtx[rows]
				det = -det
			end
			for i = 1, rows - 1 do
				if not fiszero(mtx[i][j]) then
					local factor = mtx[i][j] / subdet
					for n = j + 1, #mtx[1] do
						mtx[i][n] = mtx[i][n] - factor * mtx[rows][n]
					end
				end
			end
			if math.fmod(rows, 2) == 0 then
				det = -det
			end
			det = det * subdet
			table.remove(mtx)
		else
			return det * 0
		end
	end
	return det
end

local setelementtosmallest = function(mtx, i, j, fiszero, fisone, abs)
	if fisone(mtx[i][j]) then return true end
	local _ilow
	for _i = i, #mtx do
		local e = mtx[_i][j]
		if fisone(e) then
			break
		end
		if not _ilow then
			if not fiszero(e) then
				_ilow = _i
			end
		elseif (not fiszero(e)) and math.abs(abs(e) - 1) < math.abs(abs(mtx[_ilow][j]) - 1) then
			_ilow = _i
		end
	end
	if _ilow then
		if _ilow ~= i then
			mtx[i], mtx[_ilow] = mtx[_ilow], mtx[i]
		end
		return true
	end
end
local cxfiszero = function(cx) return complex.is(cx, 0, 0) end
local cxfsetzero = function(mtx, i, j) complex.set(mtx[i][j], 0, 0) end
local cxfisone = function(cx) return complex.abs(cx) == 1 end
local cxfsetone = function(mtx, i, j) complex.set(mtx[i][j], 1, 0) end
local numfiszero = function(num) return num == 0 end
local numfsetzero = function(mtx, i, j) mtx[i][j] = 0 end
local numfisone = function(num) return math.abs(num) == 1 end
local numfsetone = function(mtx, i, j) mtx[i][j] = 1 end

function matrix.dogauss(mtx)
	local fiszero, fsetzero, fisone, fsetone, abs
	if matrix.type(mtx) == "complex" then
		fiszero = cxfiszero
		fsetzero = cxfsetzero
		fisone = cxfisone
		fsetone = cxfsetone
		abs = complex.mulconjugate
	else
		fiszero = numfiszero
		fsetzero = numfsetzero
		fisone = numfisone
		fsetone = numfsetone
		abs = math.abs
	end
	local rows, columns = #mtx, #mtx[1]

	for j = 1, rows do
		if setelementtosmallest(mtx, j, j, fiszero, fisone, abs) then
			for i = j + 1, rows do
				if not fiszero(mtx[i][j]) then
					local factor = mtx[i][j] / mtx[j][j]

					fsetzero(mtx, i, j)
					for _j = j + 1, columns do
						mtx[i][_j] = mtx[i][_j] - factor * mtx[j][_j]
					end
				end
			end
		else
			return false, j - 1
		end
	end

	for j = rows, 1, -1 do
		local div = mtx[j][j]
		for _j = j + 1, columns do
			mtx[j][_j] = mtx[j][_j] / div
		end
		for i = j - 1, 1, -1 do
			if not fiszero(mtx[i][j]) then
				local factor = mtx[i][j]
				for _j = j + 1, columns do
					mtx[i][_j] = mtx[i][_j] - factor * mtx[j][_j]
				end
				fsetzero(mtx, i, j)
			end
		end
		fsetone(mtx, j, j)
	end
	return true
end

function matrix.invert(m1)
	assert(#m1 == #m1[1], "matrix not square")
	local mtx = matrix.copy(m1)
	local ident = setmetatable({}, matrix_meta)
	if matrix.type(mtx) == "complex" then
		for i = 1, #m1 do
			ident[i] = {}
			for j = 1, #m1 do
				if i == j then
					ident[i][j] = complex.new(1, 0)
				else
					ident[i][j] = complex.new(0, 0)
				end
			end
		end
	else
		for i = 1, #m1 do
			ident[i] = {}
			for j = 1, #m1 do
				if i == j then
					ident[i][j] = 1
				else
					ident[i][j] = 0
				end
			end
		end
	end
	mtx = matrix.concath(mtx, ident)
	local done, rank = matrix.dogauss(mtx)
	if done then
		return matrix.subm(mtx, 1, (#mtx[1] / 2) + 1, #mtx, #mtx[1])
	else
		return nil, rank
	end
end

local function get_abs_avg(m1, m2)
	local dist = 0
	local abs = matrix.type(m1) == "complex" and complex.abs or math.abs
	for i = 1, #m1 do
		for j = 1, #m1[1] do
			dist = dist + abs(m1[i][j] - m2[i][j])
		end
	end
	return dist / (#m1 * 2)
end

function matrix.sqrt(m1, iters)
	assert(#m1 == #m1[1], "matrix not square")
	local iters = iters or math.huge
	local y = matrix.copy(m1)
	local z = matrix(#y, 'I')
	local dist = math.huge

	for n = 1, iters do
		local lasty, lastz = y, z
		y, z = matrix.divnum((matrix.add(y, matrix.invert(z))), 2),
			matrix.divnum((matrix.add(z, matrix.invert(y))), 2)
		local dist1 = get_abs_avg(y, lasty)
		if iters == math.huge then
			if dist1 >= dist then
				return lasty, lastz, get_abs_avg(matrix.mul(lasty, lasty), m1)
			end
		end
		dist = dist1
	end
	return y, z, get_abs_avg(matrix.mul(y, y), m1)
end

function matrix.root(m1, root, iters)
	assert(#m1 == #m1[1], "matrix not square")
	local iters = iters or math.huge
	local mx = matrix.copy(m1)
	local my = matrix.mul(mx:invert(), mx:pow(root - 1))
	local dist = math.huge

	for n = 1, iters do
		local lastx, lasty = mx, my

		mx, my = mx:mulnum(root - 1):add(my:invert()):divnum(root),
			my:mulnum(root - 1):add(mx:invert()):divnum(root)
			:mul(my:invert():pow(root - 2)):mul(my:mulnum(root - 1)
				:add(mx:invert())):divnum(root)
		local dist1 = get_abs_avg(mx, lastx)
		if iters == math.huge then
			if dist1 >= dist then
				return lastx, lasty, get_abs_avg(matrix.pow(lastx, root), m1)
			end
		end
		dist = dist1
	end
	return mx, my, get_abs_avg(matrix.pow(mx, root), m1)
end

function matrix.normf(mtx)
	local mtype = matrix.type(mtx)
	local result = 0
	for i = 1, #mtx do
		for j = 1, #mtx[1] do
			local e = mtx[i][j]
			if mtype ~= "number" then e = e:abs() end
			result = result + e ^ 2
		end
	end
	local sqrt = (type(result) == "number") and math.sqrt or result.sqrt
	return sqrt(result)
end

function matrix.normmax(mtx)
	local abs = (matrix.type(mtx) == "number") and math.abs or mtx[1][1].abs
	local result = 0
	for i = 1, #mtx do
		for j = 1, #mtx[1] do
			local e = abs(mtx[i][j])
			if e > result then result = e end
		end
	end
	return result
end

local numround = function(num, mult)
	return math.floor(num * mult + 0.5) / mult
end
local tround = function(t, mult)
	for i, v in ipairs(t) do
		t[i] = math.floor(v * mult + 0.5) / mult
	end
	return t
end
function matrix.round(mtx, idp)
	local mult = 10 ^ (idp or 0)
	local fround = matrix.type(mtx) == "number" and numound or tround
	for i = 1, #mtx do
		for j = 1, #mtx[1] do
			mtx[i][j] = fround(mtx[i][j], mult)
		end
	end
	return mtx
end

local numfill = function(_, start, stop, idp)
	return math.random(start, stop) / idp
end
local tfill = function(t, start, stop, idp)
	for i in ipairs(t) do
		t[i] = math.random(start, stop) / idp
	end
	return t
end
function matrix.random(mtx, start, stop, idp)
	local start, stop, idp = start or -10, stop or 10, idp or 1
	local ffill = matrix.type(mtx) == "number" and numfill or tfill
	for i = 1, #mtx do
		for j = 1, #mtx[1] do
			mtx[i][j] = ffill(mtx[i][j], start, stop, idp)
		end
	end
	return mtx
end

function matrix.type(mtx)
	if type(mtx[1][1]) == "table" then
		if complex.type(mtx[1][1]) then
			return "complex"
		end
		if getmetatable(mtx[1][1]) == symbol_meta then
			return "symbol"
		end
		return "tensor"
	end
	return "number"
end

local num_copy = function(num)
	return num
end
local t_copy = function(t)
	local newt = setmetatable({}, getmetatable(t))
	for i, v in ipairs(t) do
		newt[i] = v
	end
	return newt
end


function matrix.copy(m1)
	local docopy = matrix.type(m1) == "number" and num_copy or t_copy
	local mtx = {}
	for i = 1, #m1[1] do
		mtx[i] = {}
		for j = 1, #m1 do
			mtx[i][j] = docopy(m1[i][j])
		end
	end
	return setmetatable(mtx, matrix_meta)
end

function matrix.transpose(m1)
	local docopy = matrix.type(m1) == "number" and num_copy or t_copy
	local mtx = {}
	for i = 1, #m1[1] do
		mtx[i] = {}
		for j = 1, #m1 do
			mtx[i][j] = docopy(m1[j][i])
		end
	end
	return setmetatable(mtx, matrix_meta)
end

function matrix.subm(m1, i1, j1, i2, j2)
	local docopy = matrix.type(m1) == "number" and num_copy or t_copy
	local mtx = {}
	for i = i1, i2 do
		local _i = i - i1 + 1
		mtx[_i] = {}
		for j = j1, j2 do
			local _j = j - j1 + 1
			mtx[_i][_j] = docopy(m1[i][j])
		end
	end
	return setmetatable(mtx, matrix_meta)
end

function matrix.concath(m1, m2)
	assert(#m1 == #m2, "matrix size mismatch")
	local docopy = matrix.type(m1) == "number" and num_copy or t_copy
	local mtx = {}
	local offset = #m1[1]
	for i = 1, #m1 do
		mtx[i] = {}
		for j = 1, offset do
			mtx[i][j] = docopy(m1[i][j])
		end
		for j = 1, #m2[1] do
			mtx[i][j + offset] = docopy(m2[i][j])
		end
	end
	return setmetatable(mtx, matrix_meta)
end

function matrix.concatv(m1, m2)
	assert(#m1[1] == #m2[1], "matrix size mismatch")
	local docopy = matrix.type(m1) == "number" and num_copy or t_copy
	local mtx = {}
	for i = 1, #m1 do
		mtx[i] = {}
		for j = 1, #m1[1] do
			mtx[i][j] = docopy(m1[i][j])
		end
	end
	local offset = #mtx
	for i = 1, #m2 do
		local _i = i + offset
		mtx[_i] = {}
		for j = 1, #m2[1] do
			mtx[_i][j] = docopy(m2[i][j])
		end
	end
	return setmetatable(mtx, matrix_meta)
end

function matrix.rotl(m1)
	local mtx = matrix:new(#m1[1], #m1)
	local docopy = matrix.type(m1) == "number" and num_copy or t_copy
	for i = 1, #m1 do
		for j = 1, #m1[1] do
			mtx[#m1[1] - j + 1][i] = docopy(m1[i][j])
		end
	end
	return mtx
end

function matrix.rotr(m1)
	local mtx = matrix:new(#m1[1], #m1)
	local docopy = matrix.type(m1) == "number" and num_copy or t_copy
	for i = 1, #m1 do
		for j = 1, #m1[1] do
			mtx[j][#m1 - i + 1] = docopy(m1[i][j])
		end
	end
	return mtx
end

local get_tstr = function(t)
	return "[" .. table.concat(t, ",") .. "]"
end
local get_str = function(e)
	return tostring(e)
end

local getf_tstr = function(t, fstr)
	local tval = {}
	for i, v in ipairs(t) do
		tval[i] = string.format(fstr, v)
	end
	return "[" .. table.concat(tval, ",") .. "]"
end
local getf_cxstr = function(e, fstr)
	return complex.tostring(e, fstr)
end
local getf_symstr = function(e, fstr)
	return string.format(fstr, e[1])
end
local getf_str = function(e, fstr)
	return string.format(fstr, e)
end

function matrix.tostring(mtx, formatstr)
	local ts = {}
	local getstr
	if formatstr then -- get str formatted
		local mtype = matrix.type(mtx)
		if mtype == "tensor" then
			getstr = getf_tstr
		elseif mtype == "complex" then
			getstr = getf_cxstr
		elseif mtype == "symbol" then
			getstr = getf_symstr
		else
			getstr = getf_str
		end
		-- iteratr
		for i = 1, #mtx do
			local tstr = {}
			for j = 1, #mtx[1] do
				tstr[j] = getstr(mtx[i][j], formatstr)
			end
			ts[i] = table.concat(tstr, "\t")
		end
	else
		getstr = matrix.type(mtx) == "tensor" and get_tstr or get_str
		for i = 1, #mtx do
			local tstr = {}
			for j = 1, #mtx[1] do
				tstr[j] = getstr(mtx[i][j])
			end
			ts[i] = table.concat(tstr, "\t")
		end
	end
	return table.concat(ts, "\n")
end

function matrix.print(...)
	print(matrix.tostring(...))
end

function matrix.latex(mtx, align)
	local align = align or "c"
	local str = "$\\left( \\begin{array}{" .. string.rep(align, #mtx[1]) .. "}\n"
	local getstr = matrix.type(mtx) == "tensor" and get_tstr or get_str
	for i = 1, #mtx do
		str = str .. "\t" .. getstr(mtx[i][1])
		for j = 2, #mtx[1] do
			str = str .. " & " .. getstr(mtx[i][j])
		end
		-- close line
		if i == #mtx then
			str = str .. "\n"
		else
			str = str .. " \\\\\n"
		end
	end
	return str .. "\\end{array} \\right)$"
end

function matrix.rows(mtx)
	return #mtx
end

function matrix.columns(mtx)
	return #mtx[1]
end

function matrix.size(mtx)
	if matrix.type(mtx) == "tensor" then
		return #mtx, #mtx[1], #mtx[1][1]
	end
	return #mtx, #mtx[1]
end

function matrix.getelement(mtx, i, j)
	if mtx[i] and mtx[i][j] then
		return mtx[i][j]
	end
end

function matrix.setelement(mtx, i, j, value)
	if matrix.getelement(mtx, i, j) then
		mtx[i][j] = value
		return 1
	end
end

function matrix.ipairs(mtx)
	local i, j, rows, columns = 1, 0, #mtx, #mtx[1]
	local function iter()
		j = j + 1
		if j > columns then
			i, j = i + 1, 1
		end
		if i <= rows then
			return i, j
		end
	end
	return iter
end

function matrix.scalar(m1, m2)
	return m1[1][1] * m2[1][1] + m1[2][1] * m2[2][1] + m1[3][1] * m2[3][1]
end

function matrix.cross(m1, m2)
	local mtx = {}
	mtx[1] = { m1[2][1] * m2[3][1] - m1[3][1] * m2[2][1] }
	mtx[2] = { m1[3][1] * m2[1][1] - m1[1][1] * m2[3][1] }
	mtx[3] = { m1[1][1] * m2[2][1] - m1[2][1] * m2[1][1] }
	return setmetatable(mtx, matrix_meta)
end

function matrix.len(m1)
	return math.sqrt(m1[1][1] ^ 2 + m1[2][1] ^ 2 + m1[3][1] ^ 2)
end

function matrix.tocomplex(mtx)
	assert(matrix.type(mtx) == "number", "matrix not of type 'number'")
	for i = 1, #mtx do
		for j = 1, #mtx[1] do
			mtx[i][j] = complex.to(mtx[i][j])
		end
	end
	return setmetatable(mtx, matrix_meta)
end

function matrix.remcomplex(mtx)
	assert(matrix.type(mtx) == "complex", "matrix not of type 'complex'")
	for i = 1, #mtx do
		for j = 1, #mtx[1] do
			mtx[i][j] = complex.tostring(mtx[i][j])
		end
	end
	return setmetatable(mtx, matrix_meta)
end

function matrix.conjugate(m1)
	assert(matrix.type(m1) == "complex", "matrix not of type 'complex'")
	local mtx = {}
	for i = 1, #m1 do
		mtx[i] = {}
		for j = 1, #m1[1] do
			mtx[i][j] = complex.conjugate(m1[i][j])
		end
	end
	return setmetatable(mtx, matrix_meta)
end

function matrix.tosymbol(mtx)
	assert(matrix.type(mtx) ~= "tensor", "cannot convert type 'tensor' to 'symbol'")
	for i = 1, #mtx do
		for j = 1, #mtx[1] do
			mtx[i][j] = newsymbol(mtx[i][j])
		end
	end
	return setmetatable(mtx, matrix_meta)
end

function matrix.gsub(m1, from, to)
	assert(matrix.type(m1) == "symbol", "matrix not of type 'symbol'")
	local mtx = {}
	for i = 1, #m1 do
		mtx[i] = {}
		for j = 1, #m1[1] do
			mtx[i][j] = newsymbol(string.gsub(m1[i][j][1], from, to))
		end
	end
	return setmetatable(mtx, matrix_meta)
end

function matrix.replace(m1, ...)
	assert(matrix.type(m1) == "symbol", "matrix not of type 'symbol'")
	local tosub, args = {}, { ... }
	for i = 1, #args, 2 do
		tosub[args[i]] = args[i + 1]
	end
	local mtx = {}
	for i = 1, #m1 do
		mtx[i] = {}
		for j = 1, #m1[1] do
			mtx[i][j] = newsymbol(string.gsub(m1[i][j][1], "%a", function(a) return tosub[a] or a end))
		end
	end
	return setmetatable(mtx, matrix_meta)
end

function matrix.solve(m1)
	assert(matrix.type(m1) == "symbol", "matrix not of type 'symbol'")
	local mtx = {}
	for i = 1, #m1 do
		mtx[i] = {}
		for j = 1, #m1[1] do
			mtx[i][j] = tonumber(loadstring("return " .. m1[i][j][1])())
		end
	end
	return setmetatable(mtx, matrix_meta)
end

function symbol_meta.__add(a, b)
	return newsymbol(a .. "+" .. b)
end

function symbol_meta.__sub(a, b)
	return newsymbol(a .. "-" .. b)
end

function symbol_meta.__mul(a, b)
	return newsymbol("(" .. a .. ")*(" .. b .. ")")
end

function symbol_meta.__div(a, b)
	return newsymbol("(" .. a .. ")/(" .. b .. ")")
end

function symbol_meta.__pow(a, b)
	return newsymbol("(" .. a .. ")^(" .. b .. ")")
end

function symbol_meta.__eq(a, b)
	return a[1] == b[1]
end

function symbol_meta.__tostring(a)
	return a[1]
end

function symbol_meta.__concat(a, b)
	return tostring(a) .. tostring(b)
end

function symbol_meta.abs(a)
	return newsymbol("(" .. a[1] .. "):abs()")
end

function symbol_meta.sqrt(a)
	return newsymbol("(" .. a[1] .. "):sqrt()")
end

matrix_meta.__add = function(...)
	return matrix.add(...)
end

matrix_meta.__sub = function(...)
	return matrix.sub(...)
end


matrix_meta.__mul = function(m1, m2)
	if getmetatable(m1) ~= matrix_meta then
		return matrix.mulnum(m2, m1)
	elseif getmetatable(m2) ~= matrix_meta then
		return matrix.mulnum(m1, m2)
	end
	return matrix.mul(m1, m2)
end


matrix_meta.__div = function(m1, m2)
	if getmetatable(m1) ~= matrix_meta then
		return matrix.mulnum(matrix.invert(m2), m1)
	elseif getmetatable(m2) ~= matrix_meta then
		return matrix.divnum(m1, m2)
	end
	return matrix.div(m1, m2)
end


matrix_meta.__unm = function(mtx)
	return matrix.mulnum(mtx, -1)
end


local option = {

	["*"] = function(m1) return matrix.conjugate(m1) end,

	["T"] = function(m1) return matrix.transpose(m1) end,
}
matrix_meta.__pow = function(m1, opt)
	return option[opt] and option[opt](m1) or matrix.pow(m1, opt)
end


matrix_meta.__eq = function(m1, m2)
	if matrix.type(m1) ~= matrix.type(m2) then
		return false
	end

	if #m1 ~= #m2 or #m1[1] ~= #m2[1] then
		return false
	end

	for i = 1, #m1 do
		for j = 1, #m1[1] do
			if m1[i][j] ~= m2[i][j] then
				return false
			end
		end
	end
	return true
end


matrix_meta.__tostring = function(...)
	return matrix.tostring(...)
end


matrix_meta.__call = function(...)
	matrix.print(...)
end


matrix_meta.__index = {}
for k, v in pairs(matrix) do
	matrix_meta.__index[k] = v
end

function getOffsetFromXYZ(mat, vec)
	mat[1][4] = 0
	mat[2][4] = 0
	mat[3][4] = 0
	mat[4][4] = 1
	mat = matrix.invert(mat)

	local offX = vec[1] * mat[1][1] + vec[2] * mat[2][1] + vec[3] * mat[3][1] + mat[4][1]
	local offY = vec[1] * mat[1][2] + vec[2] * mat[2][2] + vec[3] * mat[3][2] + mat[4][2]
	local offZ = vec[1] * mat[1][3] + vec[2] * mat[2][3] + vec[3] * mat[3][3] + mat[4][3]

	return offX, offY, offZ
end