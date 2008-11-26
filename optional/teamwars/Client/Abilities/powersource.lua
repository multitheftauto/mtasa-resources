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

$Id: powersource.lua 32 2007-12-10 01:37:43Z sinnerg $
]]

-- Ability: powersource
-- Defines a (regenerating) 'mana' like field 
-- To retrieve current mana:
-- getElementData(thePlayer, "TW_POWERSOURCE_PWTYPE") where PWTYPE is the name of the power
-- Author: SinnerG
-- Example usage: <ability id="powersource" description="" regenTime="1000" sourceName="mana" regenAmount="1" startPower="0" maxPower="200" showBar="true" barX="50" barY="50" barColor="red" barWidth="10" barHeight="10" barRelative="true" />
Ability_PowerSource = class("Ability_PowerSource", Ability)

function Ability_PowerSource:__init(name, element, owner)
	self.Ability:__init(name, element, owner)
	
	self.regenTime = INT(getElementData(element, "regenTime"), 1000)
	self.regenAmount = INT(getElementData(element, "regenAmount"), 0)
	self.startPower = INT(getElementData(element, "startPower"), 0)
	self.maxPower = INT(getElementData(element, "maxPower"), 0)
	self.sourceName= getElementData(element, "sourceName")
	
	if ((self.sourceName == nil) or (self.sourceName == false)) then
		self.sourceName = "power"
	end
	
	self.elementName = "TW_A_POWERSOURCE_" .. self.sourceName
	self.maxPowerName = "TW_A_POWERSOURCE_" .. self.sourceName .. "_MAX"
	self.startPowerName = "TW_A_POWERSOURCE_" .. self.sourceName .. "_START"
	self.currentPower = self.startPower 
	Ability_PowerSource.SetCurrentPower(self:getOwner(), self.sourceName, self.currentPower)
end

function Ability_PowerSource:OnTick(timePassed)
	if (not self.lastRegen) then self.lastRegen = getTickCount() end
	if (isPlayerDead(self:getOwner())) then return end
	
	-- Update the value first
	self.currentPower = Ability_PowerSource.GetCurrentPower(self:getOwner(), self.sourceName)
	
	if (getTickCount() - self.lastRegen >= self.regenTime) then
		self.currentPower = self.currentPower + self.regenAmount
		if (self.currentPower > self.maxPower) then
			self.currentPower = self.maxPower
			if (getElementData(self:getOwner(), self.elementName) ~= self.currentPower) then
				setElementData(self:getOwner(), self.elementName, self.currentPower)				
			end
		end
	end
end
function Ability_PowerSource.GetCurrentPower(player, sourceName)
	return getElementData(player, "TW_A_POWERSOURCE_" .. sourceName);
end
function Ability_PowerSource.SetCurrentPower(player, sourceName, Power)
	return setElementData(player, "TW_A_POWERSOURCE_" .. sourceName, Power);
end
function Ability_PowerSource.GetMaxPower(player, sourceName)
	return getElementData(player, "TW_A_POWERSOURCE_" .. sourceName .. "_MAX");
end
function Ability_PowerSource.GetStartPower(player, sourceName)
	return getElementData(player, "TW_A_POWERSOURCE_" .. sourceName .. "_START");
end

local function OnClientResourceStart(resource)
	if (resource == getThisResource()) then			
		-- Register the ability in the 'register'
		registerAbility("powersource", Ability_PowerSource)					
	end
end

addEventHandler("onClientResourceStart", getRootElement(), OnClientResourceStart )