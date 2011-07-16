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

function getRandomSkin(usedSkins)
	local freeSkins = getValidSkins(usedSkins)
	if (#freeSkins == 0) then
		-- there are no more free skins, choose a random skin from one that is taken
		local allSkins = getValidSkins({})
		return allSkins[math.random(1, #allSkins)]
	else
		-- choose a random free skin
		return freeSkins[math.random(1, #freeSkins)]
	end
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

function getValidSkins(excludeList)
	local skinsTable = {}
	for skin=0,288 do
		if (isSkinValid(skin)) then
			local match = false
			for j,v in ipairs(excludeList) do
				if (v == skin) then
					match = true
					break
				end
			end
			if (not match) then
				table.insert(skinsTable, skin)
			end
		end
	end
	return skinsTable
end
