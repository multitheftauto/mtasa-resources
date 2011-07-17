convert = {}
local c = convert

--basic datatypes--
c.string = tostring

c.number = tonumber

c.integer = function(var)
	local nVar = c.number(var)
	if nVar then
		local int, frac = math.modf(nVar)
		if frac == 0 then
			return int
		else
			return nil
		end
	else
		return nil
	end
end

c.natural = function(var)
	local nVar = c.integer(var)
	if nVar then
		if nVar >= 0 then
			return nVar
		else
			return nil
		end
	else
		return nil
	end
end

c.boolean = function(var)
	if type(var) == "boolean" then
		return var
	elseif var == "true" then
		return true
	elseif var == "false" then
		return false
	else
		return nil
	end
end

c.colour = function(var)
	local var = string.upper(c.string(var))
	if getColorFromString(var) then return var
	else
		var = '#'..var
		if getColorFromString(var) then return var
		else
			return nil
		end
	end
end

c.color = c.colour

c.element = function(ID, elementType)
	if isElement(ID) then return ID end
	if type(ID) ~= "string" then
		return nil
	end
	if type(elementType) == "table" then
		elementType = elementType[1]
	end
	local theElement = getElementByID(ID)
	if theElement then
		if elementType then
			if getElementType(theElement) == elementType then
				return theElement
			end
		else
			return theElement
		end
	else
		return nil
	end
end

c.plate = function(var)
   if var ~= nil then
      var = c.string(var)
   else
      return nil
   end
	if #var <= 8 then
		return string.upper(string.gsub( var, "[^%d%a]", "" ))
	else
		return nil
	end
end

c.objectID = function(var)
	local var = c.number(var)
	if var and var >= 615 and var <= 18630 then
		return var
	else
		return nil
	end
end

c.vehicleID = function(var)
	local var = c.number(var)
	if var and getVehicleNameFromModel(var) then
		return var
	else
		return nil
	end
end

local skinIDs = {
[0]=true,
[1]=true,
[2]=true,
[7]=true,
[9]=true,
[10]=true,
[11]=true,
[12]=true,
[13]=true,
[14]=true,
[15]=true,
[16]=true,
[17]=true,
[18]=true,
[19]=true,
[20]=true,
[21]=true,
[22]=true,
[23]=true,
[24]=true,
[25]=true,
[26]=true,
[27]=true,
[28]=true,
[29]=true,
[30]=true,
[31]=true,
[32]=true,
[33]=true,
[34]=true,
[35]=true,
[36]=true,
[37]=true,
[38]=true,
[39]=true,
[40]=true,
[41]=true,
[43]=true,
[44]=true,
[45]=true,
[46]=true,
[47]=true,
[48]=true,
[49]=true,
[50]=true,
[51]=true,
[52]=true,
[53]=true,
[54]=true,
[55]=true,
[56]=true,
[57]=true,
[58]=true,
[59]=true,
[60]=true,
[61]=true,
[62]=true,
[63]=true,
[64]=true,
[66]=true,
[67]=true,
[68]=true,
[69]=true,
[70]=true,
[71]=true,
[72]=true,
[73]=true,
[75]=true,
[76]=true,
[77]=true,
[78]=true,
[79]=true,
[80]=true,
[81]=true,
[82]=true,
[83]=true,
[84]=true,
[85]=true,
[87]=true,
[88]=true,
[89]=true,
[90]=true,
[91]=true,
[92]=true,
[93]=true,
[94]=true,
[95]=true,
[96]=true,
[97]=true,
[98]=true,
[99]=true,
[100]=true,
[101]=true,
[102]=true,
[103]=true,
[104]=true,
[105]=true,
[106]=true,
[107]=true,
[108]=true,
[109]=true,
[110]=true,
[111]=true,
[112]=true,
[113]=true,
[114]=true,
[115]=true,
[116]=true,
[117]=true,
[118]=true,
[120]=true,
[121]=true,
[122]=true,
[123]=true,
[124]=true,
[125]=true,
[126]=true,
[127]=true,
[128]=true,
[129]=true,
[130]=true,
[131]=true,
[132]=true,
[133]=true,
[134]=true,
[135]=true,
[136]=true,
[137]=true,
[138]=true,
[139]=true,
[140]=true,
[141]=true,
[142]=true,
[143]=true,
[144]=true,
[145]=true,
[146]=true,
[147]=true,
[148]=true,
[150]=true,
[151]=true,
[152]=true,
[153]=true,
[154]=true,
[155]=true,
[156]=true,
[157]=true,
[158]=true,
[159]=true,
[160]=true,
[161]=true,
[162]=true,
[163]=true,
[164]=true,
[165]=true,
[166]=true,
[167]=true,
[168]=true,
[169]=true,
[170]=true,
[171]=true,
[172]=true,
[173]=true,
[174]=true,
[175]=true,
[176]=true,
[177]=true,
[178]=true,
[179]=true,
[180]=true,
[181]=true,
[182]=true,
[183]=true,
[184]=true,
[185]=true,
[186]=true,
[187]=true,
[188]=true,
[189]=true,
[190]=true,
[191]=true,
[192]=true,
[193]=true,
[194]=true,
[195]=true,
[196]=true,
[197]=true,
[198]=true,
[199]=true,
[200]=true,
[201]=true,
[202]=true,
[203]=true,
[204]=true,
[205]=true,
[206]=true,
[207]=true,
[209]=true,
[210]=true,
[211]=true,
[212]=true,
[213]=true,
[214]=true,
[215]=true,
[216]=true,
[217]=true,
[218]=true,
[219]=true,
[220]=true,
[221]=true,
[222]=true,
[223]=true,
[224]=true,
[225]=true,
[226]=true,
[227]=true,
[228]=true,
[229]=true,
[230]=true,
[231]=true,
[232]=true,
[233]=true,
[234]=true,
[235]=true,
[236]=true,
[237]=true,
[238]=true,
[239]=true,
[240]=true,
[241]=true,
[242]=true,
[243]=true,
[244]=true,
[245]=true,
[246]=true,
[247]=true,
[248]=true,
[249]=true,
[250]=true,
[251]=true,
[252]=true,
[253]=true,
[254]=true,
[255]=true,
[256]=true,
[257]=true,
[258]=true,
[259]=true,
[260]=true,
[261]=true,
[262]=true,
[263]=true,
[264]=true,
[265]=true,
[266]=true,
[267]=true,
[268]=true,
[269]=true,
[270]=true,
[271]=true,
[272]=true,
[274]=true,
[275]=true,
[276]=true,
[277]=true,
[278]=true,
[279]=true,
[280]=true,
[281]=true,
[282]=true,
[283]=true,
[284]=true,
[285]=true,
[286]=true,
[287]=true,
[288]=true,
[290]=true,
[291]=true,
[292]=true,
[293]=true,
[294]=true,
[295]=true,
[296]=true,
[297]=true,
[298]=true,
[299]=true,
[300]=true,
[301]=true,
[302]=true,
[303]=true,
[304]=true,
[305]=true,
[306]=true,
[307]=true,
[308]=true,
[309]=true,
[310]=true,
[311]=true,
[310]=true,

}

c.skinID = function(var)
	local var = c.number(var)
	if skinIDs[var] then
		return var
	else
		return nil
	end
end

c.blipID = function(var)
	local var = c.number(var)
	if var ~= nil and var >= 0 and var <= 63 then
		return var
	else
		return nil
	end
end

c.weaponID = function(var)
	local var = c.number(var)
	if var and getWeaponNameFromID(var) then
		return var
	else
		return nil
	end
end

c.pickupType = function(var)
	if var == "health" or var == "armor" then
		return var
	else return c.weaponID(var) end
end

local markerTypes = {
	arrow = true,
	checkpoint = true,
	corona = true,
	cylinder = true,
	ring = true,
}

c.markerType = function(var)
	if markerTypes[var] then
		return var
	else
		return nil
	end
end

local colshapeTypes = {
	colcircle = true,
	colcube = true,
	colrectangle = true,
	colsphere = true,
	coltube = true,
}

c.colshapeType = function(var)
	if colshapeTypes[var] then
		return var
	else
		return nil
	end
end

c.coord3d = function(var)
	local vType = type(var)
	if vType == "string" then
		local substrings = split(var, string.byte(','))
		local coord = {}
		for i = 1, 3 do
			coord[i] = c.number(substrings[i])
			if not coord[i] then
				return nil
			end
		end
		return coord
	elseif vType == "table" then
		local coord = {}
		for i = 1, 3 do
			coord[i] = c.number(var[i])
			if not coord[i] then
				return nil
			end
		end
		return coord
	else
		return nil
	end
end

c.camera = function(var)
	local vType = type(var)
	if vType == "string" then
		local substrings = split(var, string.byte(','))
		if #substrings >= 6 then
			return {{substrings[1],substrings[2],substrings[3]},{substrings[4],substrings[5],substrings[6]} }
		end
		-- local coord1 = c.coord3d {substrings[1], substrings[2], substrings[3]}
		-- local coord2 = c.coord3d {substrings[4], substrings[5], substrings[6]}
		
		-- if coord1 and coord2 then
			-- return {coord1, coord2}
		-- else
			-- return nil
		-- end
	elseif vType == "table" then
		local coord1 = c.coord3d(var[1])
		local coord2 = c.coord3d(var[2])
		
		if coord1 and coord2 then
			return var
		else
			return nil
		end
	else
		return nil
	end
end

c.selection = function(var,validTypes)
	if not validTypes then return var end
	local vType = type(var)
	if vType ~= "string" then
		return false
	end
	local found
	for selectionKey,selectionValue in ipairs(validTypes) do
		if selectionValue == var then
			found = true
			break
		end
	end
	if ( found ) then
		return var
	else
		return validTypes[1]
	end
end

--c.vehicleupgrades

--c.vehiclecolors
c.vehiclecolours = c.vehiclecolors
