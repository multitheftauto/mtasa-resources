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

$Id: classes.lua 32 2007-12-10 01:37:43Z sinnerg $
]]

-- Class related functions

function getClassName(classElement)
	if ((isElement(classElement)) and (getElementType(classElement) == "class")) then
		return getElementID(classElement)
	end
	
	return false
end

function getClassFromName(name, classes)
	if (not classes) then return false end
	if ((not name) or (isElement(name))) then return false end
		
	for k, v in ipairs(classes) do
		if (isElement(v)) then
			if (getClassName(v) == name) then return v end
		end
	end
	
	return false
end
if (getAllElementDatass) then	-- Server side
	function getClassInfo(classElement)
		if ((isElement(classElement)) and (getElementType(classElement) == "class")) then
			return getAllElementData(classElement)
		end
		
		return false
	end
else -- Client Side
	-- CLIENT SIDE IS BUGGED UNTIL THE GetAllElementData FUNCTION GETS ADDED CLIENTSIDE
	function getClassInfo(classElement)
		if ((isElement(classElement)) and (getElementType(classElement) == "class")) then
			local result  ={}
			result["skinID"] = getElementData(classElement, "skinID")
			result["startHealth"] = getElementData(classElement, "startHealth")
			result["maxHealth"] = getElementData(classElement, "maxHealth")
			result["startArmor"] = getElementData(classElement, "startArmor")
			result["maxArmor"] = getElementData(classElement, "maxArmor")
			result["description"] = getElementData(classElement, "description")
			-- Add to this list if you require new fields!
			
			return result
		end
		
		return false
	end
end

function getClassWeapons(classElement)
	if ((isElement(classElement)) and (getElementType(classElement) == "class")) then
		local weapons = getChildren(classElement, "weapon")
		return weapons
	end
	
	return false
end

function getClassWeaponInfo(weaponElement)
	if ((isElement(weaponElement)) and (getElementType(weaponElement) == "weapon")) then
		local result = {}
		result.ID = INT(getElementID(weaponElement))
		
		result.maxAmmo = INT(getElementData(weaponElement, "maxAmmo"))
		result.startAmmo = INT(getElementData(weaponElement, "startAmmo"))
		result.description = getElementData(weaponElement, "description")
		result.default = getElementData(weaponElement, "default")
		if (result.default) then result.default = true end
		
		if ((result.ID < 16) and (not result.startAmmo)) then
			result.startAmmo = 1 -- Melee
		end		
		return result
	end
	
	return false
end

function getClassAbilities(classElement)
	if ((isElement(classElement)) and (getElementType(classElement) == "class")) then
		return getChildren(classElement, "ability")
	end
	
	return false
end

function getClassAbilityName(abilityElement)
	if ((isElement(abilityElement)) and (getElementType(abilityElement) == "ability")) then
		return getElementID(abilityElement)
	end
	
	return false
end

function getClassAbilityMode(abilityElement)
	if ((isElement(abilityElement)) and (getElementType(abilityElement) == "ability")) then
		return getElementData(abilityElement, "abilityMode")
	end
	
	return false
end


function getClassAbilityDescription(abilityElement)
	if ((isElement(abilityElement)) and (getElementType(abilityElement) == "ability")) then
		return getElementData(abilityElement, "description")
	end
	
	return false
end
