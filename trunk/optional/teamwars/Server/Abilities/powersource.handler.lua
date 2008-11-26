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

$Id$
]]

-- Ability: powersource
-- Headshots are instant kills
-- Author: SinnerG
-- Example usage: <ability id="headshot" weapon="34" /> or <ability id="headshot" includeMelee="false" />
Ability_PowerSourceHandler = class("Ability_PowerSourceHandler", AbilityHandler)

function Ability_PowerSourceHandler:__init(name, element, owner)
	self.Ability:__init(name, element, owner)
	
	self.weaponID = INT(getElementData(element, "weapon"))
	self.includeMelee = getElementData(element, "includeMelee")
	if ((not self.includeMelee) or ((includeMelee == "true") or (includeMelee == "yes") or (includeMelee == "1") or (includeMelee == "") )) then
		self.includeMelee = true -- default
	else
		self.includeMelee = false
	end

	if (self.regenLimit == nil) then self.weaponID = false end
end

function Ability_PowerSourceHandler:OnPlayerDamage(source, attacker, weapon, bodypart, loss)		

end

local function OnResourceStart (resource)
	if (resource == getThisResource()) then			
		-- Register the ability in the 'register'
		registerAbilityHandler("powersource", Ability_PowerSourceHandler)					
	end
end

addEventHandler("onResourceStart", getRootElement(), OnResourceStart )