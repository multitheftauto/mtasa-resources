local colors = {}
local freeColors = {}

-- generates N distinct colors.. the larger the N, the less distinct they will be
function generateColors(N)
	assert(N > 0)
	local rgbTable = {}
	local increment = 360/N
	local i = 0
	while (i < 360) do
		local hue = i
		local saturation = 90 + math.random() * 10
		local lightness = 50 + math.random() * 10
		local r, g, b = HSLtoRGB(hue, saturation, lightness)
		table.insert(rgbTable, {r, g, b})
		i = i + increment
	end
	colors = rgbTable
	freeColors = copyTable(rgbTable)
	--return rgbTable
end

-- chooses one of the generated colors
function chooseRandomColor()
	if (#freeColors == 0) then
		return false
	else
		local index = math.random(1,#freeColors)
		local r = freeColors[index][1]
		local g = freeColors[index][2]
		local b = freeColors[index][3]
		table.remove(freeColors, index)
		return r, g, b
	end
end

-- converts HSL color to RGB color (found this process on Wikipedia)
-- h: [0,360), s: [0,100], l: [0,100]
-- returns: r: [0,255], g: [0,255], b: [0,255]
function HSLtoRGB(h, s, l)
	local q, p, h_k, t_r, t_g, t_b, r, g, b
	-- validate args
	if (h >= 360 or h < 0 or s > 100 or s < 0 or l > 100 or l < 0) then
		return false
	end
	-- convert s and l to [0,1] scale
	s = s / 100
	l = l / 100
	-- find q
	local q
	if (l < 0.5) then
		q = l*(1+s)
	else
		q = l+s-(l*s)
	end
	-- find p
	p = 2*l-q
	-- find h_k
	h_k = h/360
	-- find t_r, t_g, t_b
	t_r = h_k+(1/3)
	t_g = h_k
	t_b = h_k-(1/3)
	-- put t_r in range [0,1]
	if (t_r < 0) then	t_r = t_r + 1	end
	if (t_r > 1) then	t_r = t_r - 1	end
	-- put t_g in range [0,1]
	if (t_g < 0) then	t_g = t_g + 1	end
	if (t_g > 1) then	t_g = t_g - 1	end
	-- put t_b in range [0,1]
	if (t_b < 0) then	t_b = t_b + 1	end
	if (t_b > 1) then	t_b = t_b - 1	end
	-- find r
	if (t_r < (1/6)) then
		r = p+((q-p)*6*t_r)
	elseif (t_r < (1/2)) then
		r = q
	elseif (t_r < (2/3)) then
		r = p+((q-p)*6*((2/3)-t_r))
	else
		r = p
	end
	-- find g
	if (t_g < (1/6)) then
		g = p+((q-p)*6*t_g)
	elseif (t_g < (1/2)) then
		g = q
	elseif (t_g < (2/3)) then
		g = p+((q-p)*6*((2/3)-t_g))
	else
		g = p
	end
	-- find b
	if (t_b < (1/6)) then
		b = p+((q-p)*6*t_b)
	elseif (t_b < (1/2)) then
		b = q
	elseif (t_b < (2/3)) then
		b = p+((q-p)*6*((2/3)-t_b))
	else
		b = p
	end
	-- convert r, g, b to [0,255] scale
	r = math.floor(r*255)
	g = math.floor(g*255)
	b = math.floor(b*255)
	return r, g, b
end

function copyTable(oldTable)
	local newTable = {}
	for k,v in pairs(oldTable) do
		newTable[k] = v
	end
	return newTable
end
