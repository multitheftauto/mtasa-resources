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

$Id: Ability.class.lua 37 2007-12-12 04:25:10Z sinnerg $
]]

Ability  = class('Ability')

function Ability:__init(name, abilityElement, owner)
	self.name = name
	self.destroyed = false
	self.owner = owner
	self.element = abilityElement
	if (not isElement(abilityElement)) then return false end
	
	-- Retrieve info from the element
	self.description = getElementData(abilityElement, "description")
	self.commandID = getElementData(abilityElement, "commandID")	-- /specialX	
	self.abilityMode = getElementData(abilityElement, "abilityMode")
end


function Ability:getName()
	return self.name
end

function Ability:getDescription()
	return self.description
end

-- Aka /special<IDHERE>
function Ability:getCommandID()
	return self.commandID
end

function Ability:Destroy()
	self.destroyed = true
end

function Ability:isValid()
	return (not self.destroyed)
end

function Ability:setOwner(player)
	self.owner = player
end

function Ability:getOwner()
	return self.owner
end	
function Ability:getElement()
	return self.element
end	
-- Use the Ability class as a dummy (for both client and server)
registerAbility("ability", Ability)
registerAbility("dummy", Ability)

-- HANDLER
AbilityHandler  = class('AbilityHandler')

function AbilityHandler:__init(name)
	self.name = name	
	self.destroyed = false
	self:Initialize(name, xmlnode)
end

function AbilityHandler:Initialize(name)

end

function AbilityHandler:getName()
	return self.name
end

function AbilityHandler:Destroy()
	self.destroyed = true
end

function AbilityHandler:isValid()
	return (not self.destroyed)
end
-- Use the Ability class as a dummy (for both client and server)
registerAbilityHandler("ability", AbilityHandler)
registerAbilityHandler("dummy", AbilityHandler)