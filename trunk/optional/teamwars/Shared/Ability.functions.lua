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

$Id: Ability.functions.lua 32 2007-12-10 01:37:43Z sinnerg $
]]

__ability_list = {}
__ability_handler_list = {}

function registerAbility(name, classx)
	if (not name) then return false end
	if (not classx) then return false end
	__ability_list[name] = classx
--	outputDebugString("Registered ability: " .. name .. " (Class: " .. classname(classx) .. ")")
	return true
end

-- Creates a dummy ability if it doesnt exist 
-- This is to cope with the fact that some abilities might be server or client side only)
function createAbility(name, abilityElement, owner)
	if (not name) then return false end
	if (__ability_list[name]) then return __ability_list[name](name, abilityElement, owner) end
	
	if (not __ability_list["ability"]) then return false end
	return __ability_list["ability"](name, abilityElement, owner)
end

function unregisterAbilities()
	__ability_list = {}
end

function unregisterAbility(name)
	if (not name) then return false end
	__ability_list[name] = nil
	
	return true
end


-- Ability handlers are bit different (they get created and added to a list)
function registerAbilityHandler(name, class)
	if (not name) then return false end
	if (not class) then return false end
	__ability_handler_list[name] = class(name)
	
	return true
end

function unregisterAbilitiesHandlers()
		-- Desotry ability handlers
		local abilityList = __ability_handler_list
		for key,abilityObj in ipairs(abilityList) do
			abilityList:Destroy()
		end

	__ability_handler_list = {}
end

function unregisterAbilityHandler(name)
	if (not name) then return false end
	__ability_handler_list[name] = nil
	
	return true
end

function getAbilityHandlers()
	return __ability_handler_list
end
