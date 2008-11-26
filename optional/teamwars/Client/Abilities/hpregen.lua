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

$Id: hpregen.lua 32 2007-12-10 01:37:43Z sinnerg $
]]

-- Ability: hpregen
-- Regenerates HP at a defineable rate
-- Author: SinnerG
-- Example usage: <ability id="hpregen" regenTime="1000" regenAmount="1" regenLimit="startHealth" />
Ability_HPRegen = class("Ability_HPRegen", Ability)

function Ability_HPRegen:__init(name, element, owner)
	self.Ability:__init(name, element, owner)
	
	self.regenTime = INT(getElementData(element, "regenTime"))
	self.regenAmount = INT(getElementData(element, "regenAmount"))
	self.regenLimit = getElementData(element, "regenLimit")
	
	if (not self.regenTime) then self.regenTime = 1000 end -- default 1second
	if (not self.regenAmount) then self.regenAmount = 1 end -- default 1HP (cannot be 0!)
	if (not self.regenLimit) then self.regenLimit = "max" end
	
	local classInfo = getClassInfo(getElementData(self:getOwner(), "teamwars_class"))
	
	if (self.regenLimit == "maxHealth") then
		self.regenLimit = INT(classInfo["maxHealth"])
	elseif (self.regenLimit == "startHealth") then
		self.regenLimit = INT(classInfo["startHealth"]	)
	else
		self.regenLimit = INT(self.regenLimit)
	end
	
	if (not self.regenLimit) then self.regenLimit = 100 end -- Default (this shouldn't happen btw...)
end

function Ability_HPRegen:OnTick(timePassed)
	if (not self.lastRegen) then self.lastRegen = getTickCount() end
	if (isPlayerDead(self:getOwner())) then return end
	
	if (getTickCount() - self.lastRegen >= self.regenTime) then
		local currentHP = getElementHealth(self:getOwner())
		self.lastRegen = getTickCount()
		if ((currentHP < self.regenLimit) or ((self.regenAmount < 0) and (currentHP > self.regenLimit))) then
			currentHP = currentHP + self.regenAmount
			if ((currentHP > self.regenLimit) and (self.regenAmount >= 0)) then currentHP = self.regenLimit end
			
			setElementHealth(self:getOwner(), currentHP)
		end		
	end
end

local function OnClientResourceStart(resource)
	if (resource == getThisResource()) then			
		-- Register the ability in the 'register'
		registerAbility("hpregen", Ability_HPRegen)					
	end
end

addEventHandler("onClientResourceStart", getRootElement(), OnClientResourceStart )