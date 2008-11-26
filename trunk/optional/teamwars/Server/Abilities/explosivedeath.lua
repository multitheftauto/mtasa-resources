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

$Id: explosivedeath.lua 32 2007-12-10 01:37:43Z sinnerg $
]]

-- Ability: explosivedeath
-- Player who uses this ability explodes on death
-- Author: SinnerG
-- Example usage: <ability id="explosivedeath" explosiveType="0" description="Explodes on death." />
Ability_ExplosiveDeath = class("Ability_ExplosiveDeath", Ability)

function Ability_ExplosiveDeath:__init(name, element, owner)
	self.Ability:__init(name, element, owner)
	
	self.explosiveType = INT(getElementData(element, "explosiveType"))
	if (not self.explosiveType) then self.explosiveType = 0 end
end

function Ability_ExplosiveDeath:OnPlayerDead(player, ammo, attacker, weapon, bodypart)
	if (player == self:getOwner()) then
		local x, y, z = getElementPosition(player)
		createExplosion(x, y, z+0.5, self.explosiveType, player)
	end
end

local function OnResourceStart(resource)
	if (resource == getThisResource()) then			
		-- Register the ability in the 'register'
		registerAbility("explosivedeath", Ability_ExplosiveDeath)					
	end
end

addEventHandler("onResourceStart", getRootElement(), OnResourceStart )