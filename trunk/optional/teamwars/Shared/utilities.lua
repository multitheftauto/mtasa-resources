--[[
TeamWars, a Multi Theft Auto game mode
Copyright (C) 2007-2008 Tim Mylemans

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

$Id: utilities.lua 39 2007-12-18 21:50:11Z sinnerg $
]]

--	Shared Team Wars functions
	UTILITY_FAKE_ELEMENT_CACHE = {}
--	Handy misc functions
	function getChildren ( root, type )
		local elements = getElementsByType ( type )
		local result = {}
		for elementKey,elementValue in ipairs(elements) do
			if ( getElementParent( elementValue ) == root ) then
				result[ table.getn( result ) + 1 ] = elementValue
			end
		end
		return result
	end

	function explode(div,str)
		if (div=='') then return false end
		local pos,arr = 0,{}
		
		-- for each divider found
		for st,sp in function() return string.find(str,div,pos,true) end do
			table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
			pos = sp + 1 -- Jump past current divider
		end
		
		table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
		
		return arr
	end

	function round(num, idp)
		local mult = 10^(idp or 0)
		return math.floor(num * mult + 0.5) / mult
	end

	function INT(data, default)
		if (default ~= nil) then
			local res = tonumber(data)
			if (res == nil) then
				return default
			else
				return res
			end
		else		
			return tonumber(data)
		end
	end
	-- Cleans the cache - call this on round start to clean the cache
	function cleanElements(boolAll)
		if (boolAll == nil) then 
			boolAll = false; -- Default - only destroyed ones
		end
		for key, value in ipairs (UTILITY_FAKE_ELEMENT_CACHE) do
			if (isElement(UTILITY_FAKE_ELEMENT_CACHE[key])) then
				if (boolAll) then
					UTILITY_FAKE_ELEMENT_CACHE[key] = nil	
					destroyElement(value)
				end
			else
				UTILITY_FAKE_ELEMENT_CACHE[key] = nil				
			end
		end
	end
	-- Copies all relevant element data in a dummy element (so it is safe to send to clients)
	function fakeElement(element, newElementType)
		if ((not element) or (not isElement(element))) then return false end
		

		
		local theType = getElementType(element)
		if (not newElementType) then
			newElementType = "fakeElement"
		end
		local clone = nil
		if ((UTILITY_FAKE_ELEMENT_CACHE[element] ~= nil) and (isElement(UTILITY_FAKE_ELEMENT_CACHE[element])))
		then
			clone = UTILITY_FAKE_ELEMENT_CACHE[element]
		else
			clone = createElement (  newElementType,newElementType ) -- original type stored in id, type set to fakeElement		
			UTILITY_FAKE_ELEMENT_CACHE[element] = clone			
		end
		setElementID(clone, theType)	

		
		if (not clone) then return false end
		local data = getAllElementData(element)
		for key, value in pairs (data) do
			if (isElement(value)) then
				if (type(key) == "string") then
					theType = getElementType(value)
					if((theType ~= "marker") and (theType ~= "colshape") and (theType ~= "remoteclient") and (theType ~= "console")) then
						setElementData(clone, key, value)				
					else
						setElementData(clone, key, fakeElement(value, newElementType)) -- its a not-synced element, copyElement it								
					end
				end
			else
				setElementData(clone, key, value)
			end
		end
		
		return clone		
	end
	
	-- From http://lua-users.org/wiki/MakingLuaLikePhp
	function print_r (t, indent, done)
	  done = done or {}
	  indent = indent or ''
	  local nextIndent -- Storage for next indentation value
	  for key, value in pairs (t) do
	    if type (value) == "table" and not done [value] then
	      nextIndent = nextIndent or
	          (indent .. string.rep(' ',string.len(tostring (key))+2))
	          -- Shortcut conditional allocation
	      done [value] = true
	      outputChatBox (indent .. "[" .. tostring (key) .. "] => Table {");
	      outputChatBox  (nextIndent .. "{");
	      print_r (value, nextIndent .. string.rep(' ',2), done)
	      outputChatBox  (nextIndent .. "}");
	    else
	      outputChatBox  (indent .. "[" .. tostring (key) .. "] => " .. tostring (value).."")
	    end
	  end
	end

	-- Clientside only functions
	if (not getSlotFromWeapon ) then
		function getSlotFromWeapon  (weaponID)
			local weaponSlots = {}
			weaponSlots["0"] = 0
			weaponSlots["1"] = 0
			weaponSlots["2"] = 1
			weaponSlots["3"] = 1
			weaponSlots["4"] = 1
			weaponSlots["5"] = 1
			weaponSlots["6"] = 1
			weaponSlots["7"] = 1
			weaponSlots["8"] = 1
			weaponSlots["9"] = 1
			weaponSlots["15"] = 1
			weaponSlots["22"] = 2
			weaponSlots["23"] = 2
			weaponSlots["24"] = 2
			weaponSlots["25"] = 3
			weaponSlots["26"] = 3
			weaponSlots["27"] = 3
			weaponSlots["28"] = 4
			weaponSlots["29"] = 4
			weaponSlots["32"] = 4
			weaponSlots["30"] = 5
			weaponSlots["31"] = 5
			weaponSlots["33"] = 6
			weaponSlots["34"] = 6
			weaponSlots["35"] = 7
			weaponSlots["36"] = 7
			weaponSlots["37"] = 7
			weaponSlots["38"] = 7
			weaponSlots["16"] = 8
			weaponSlots["17"] = 8
			weaponSlots["18"] = 8
			weaponSlots["39"] = 8
			weaponSlots["42"] = 9
			weaponSlots["43"] = 9
			weaponSlots["10"] = 10
			weaponSlots["11"] = 10
			weaponSlots["12"] = 10
			weaponSlots["14"] = 10
			weaponSlots["44"] = 11
			weaponSlots["45"] = 11
			weaponSlots["46"] = 11
			weaponSlots["40"] = 12
			weaponID = tostring(weaponID)
			if (weaponSlots[weaponID] == nil) then return false end
			
			return weaponSlots[weaponID]
		end
	end
	
	function isWeaponMelee(weaponID) 
		if (weaponID < 19) then return true end
		
		return false
	end
	
