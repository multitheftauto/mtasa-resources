--0
--7
--9-41
--43-64
--66-73
--75-85
--87-118
--120-148
--150-207
--209-264
--274-288

function getRandomSkin()
	local model
	repeat
		model = math.random(0, 288)
	until(isSkinValid(model))
	return model
end

function isSkinValid(model)
	if (model < 0 or
		model > 0 and model < 7 or
		model == 8 or
		model == 42 or
		model == 65 or
		model == 74 or
		model == 86 or
		model == 119 or
		model == 149 or
		model == 208 or
		model > 264 and model < 274
		or model > 288) then
		return false
	else
		return true
	end
end