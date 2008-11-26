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

$Id: medpack.lua 32 2007-12-10 01:37:43Z sinnerg $
]]

-- Ability: medpack
-- Allows medpacks to be dropped (but not used by self)
-- Requires a medpack to be defined FIRST
-- Author: SinnerG
-- Example usage: <ability id="medpack" description="Can drop medpacks using /medpack" powerSource="medbar" command="medpack" dropCost="25" healthDropped="25" setOwner="0" />
Ability_Medpack = class("Ability_Medpack", Ability)

function Ability_Medpack:__init(name, element, owner)
	self.Ability:__init(name, element, owner)
	
	self.powerSource = getElementData(element, "powerSource")
	self.command = getElementData(element, "command")
	self.dropCost = INT(getElementData(element, "dropCost"), 1)
	self.healthDropped = INT(getElementData(element, "healthDropped"), 1)
	self.currentPower = Ability_PowerSource.GetCurrentPower(self:getOwner(), self.powerSource)
	self.setOwner = INT(getElementData(element, "setOwner"), 0)
	
	-- Add the required command handler
	addCommandHandler(self.command, TW_OnCommand)
	
end

function Ability_Medpack:OnTick(timePassed)
	if (not self.lastUpdate) then self.lastUpdate = getTickCount() end
	if (isPlayerDead(self:getOwner())) then return end
	self.currentPower = Ability_PowerSource.GetCurrentPower(self:getOwner(), self.powerSource)	
end


function Ability_Medpack:OnCommand(command, arg1, arg2, arg3)	
	if (command == self.command) then
		if ((not isPlayerDead(getLocalPlayer())) and (not isPlayerInVehicle(getLocalPlayer()))) then
			self.currentPower = Ability_PowerSource.GetCurrentPower(self:getOwner(), self.powerSource)
			-- Check if we can drop a medpack
			if (self.currentPower >= self.dropCost) then
				self.currentPower = self.currentPower - self.dropCost
				Ability_PowerSource.SetCurrentPower(self:getOwner(), self.powerSource, self.currentPower)
				
				-- We can!
				local x, y, z = getElementPosition(getLocalPlayer())
				
				-- Create the medpack
				local pu = createPickup ( x, y, z, 0, self.healthDropped, 999999999 )
				if (self.setOwner) then
					setElementData(pu, "pickupOwner", getTeamName (getPlayerTeam(getLocalPlayer())))
				end
				setElementData(pu, "destroyOnPickup", true)		
				setElementPosition ( pu, x*5000, y*5000, z*5000 )
				setTimer(setElementPosition, 2000, 1, pu, x, y, z) -- TODO Add to global timer list ?
				table.insert(GameMode.elementList, pu) -- add to the global elementList (that will get cleaned on stopping the mode)
				
				outputChatBox("[MEDPACK] Medpack deployed.") -- Maybe disable this output?				
			else
				outputChatBox("[MEDPACK] Could not deploy. Not enough power left.")
			end
		end
	end
end
local function OnClientResourceStart(resource)
	if (resource == getThisResource()) then			
		-- Register the ability in the 'register'
		registerAbility("medpack", Ability_Medpack)					
	end
end

addEventHandler("onClientResourceStart", getRootElement(), OnClientResourceStart )