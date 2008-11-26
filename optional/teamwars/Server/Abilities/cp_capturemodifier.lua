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

$Id: cp_capturemodifier.lua 32 2007-12-10 01:37:43Z sinnerg $
]]

-- Ability: headshot
-- Headshots are instant kills
-- Author: SinnerG
-- Example usage: <ability id="headshot" weapon="34" /> or <ability id="headshot" includeMelee="false" />
Ability_CP_CaptureModifier = class("Ability_CP_CaptureModifier", Ability)

function Ability_CP_CaptureModifier:__init(name, element, owner)
	self.Ability:__init(name, element, owner)
	
	self.modifier = INT(getElementData(element, "modifier"), 1)
	setElementData(source, "ability_cp_capturemodifier", self.modifier)
end

function Ability_CP_CaptureModifier:OnPlayerDead(source, ammo, attacker, weapon, bodypart)
	if (source == self:getOwner()) then
		setElementData(source, "ability_cp_capturemodifier", false)
	end
end 

function Ability_CP_CaptureModifier:Destroy()
	setElementData(self:getOwner(), "ability_cp_capturemodifier", false)
end 

local function OnResourceStart (resource)
	if (resource == getThisResource()) then			
		-- Register the ability in the 'register'
		registerAbility("cp_capturemodifier", Ability_CP_CaptureModifier)					
	end
end

addEventHandler("onResourceStart", getRootElement(), OnResourceStart )