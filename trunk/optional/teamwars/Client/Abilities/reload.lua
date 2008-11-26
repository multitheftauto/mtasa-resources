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

$Id: reload.lua 40 2007-12-31 00:46:26Z sinnerg $
]]

-- <ability id="reload" weapon="25" ammoPerReload="1" maxAmmo="7" reloadTime="1000" autoReload="0" command="reload" />

-- Ability: reload
-- Adds a reload bar to any weapon (when no bullet is loaded, firing is disabled)
-- Author: SinnerG

Ability_Reload = class("Ability_Reload", Ability)

function Ability_Reload:__init(name, element, owner)
	self.Ability:__init(name, element, owner)
	
	self.commandName = getElementData(element, "command")
	self.weaponID = INT(getElementData(element, "weapon"))
	self.ammoPerReload = INT(getElementData(element, "ammoPerReload"))
	self.maxAmmo = INT(getElementData(element, "maxAmmo"))
	self.reloadTime = INT(getElementData(element, "reloadTime"))
	self.autoReload = INT(getElementData(element, "autoReload"))
	self.reloadTillFiring = INT(getElementData(element, "reloadTillFire"))
	self.reloadStart = 0
	
	if (not self.reloadTime) then self.reloadTime = 1000 end -- default 1second
	if (self.maxAmmo == nil) then self.maxAmmo = 1 end -- default
	if (self.ammoPerReload == nil) then self.ammoPerReload = 1 end -- default
	if (not self.weaponID) then self.weaponID = 0 end
	if (self.reloadTillFiring == nil) then self.reloadTillFiring = 0 end
	if (self.autoReload == nil) then self.autoReload = 0 end
	if (self.commandName == nil) then self.commandName = "reload" end
	
	-- Add the required command handler
	addCommandHandler(self.commandName, TW_OnCommand)
	bindKey("fire", "both", TW_OnKeyInput )
	
	
	self.weaponSlot = getSlotFromWeapon(self.weaponID)
		
	self.started = false
end

function Ability_Reload:ToggleFire(enable)
	toggleControl("fire", enable)
end
function Ability_Reload:Destroy()
	if (isElement(self.reloadBar)) then
		guiSetVisible(self.reloadBar, false)
		destroyElement(self.reloadBar)
		self:ToggleFire(true) -- Re-enable firing
	end
	if (isElement(self.ammoLabel)) then
		guiSetVisible(self.ammoLabel2, false)
		destroyElement(self.ammoLabel)
		self:ToggleFire(true) -- Re-enable firing
	end
	if (isElement(self.ammoLabel2)) then
		guiSetVisible(self.ammoLabel2, false)
		destroyElement(self.ammoLabel2)
		self:ToggleFire(true) -- Re-enable firing
	end
end


function Ability_Reload:OnKeyInput(key, keyState)
	--outputDebugString("key pressed: " ..key .. "state: " .. keyState)
	if not (key == "fire") then return end
	
	if (keyState == "down") then
		self.isFiring = true	
		self.reloading = false
		self.reloadStart = 0
		guiSetVisible(self.reloadBar, false)
	else
		self.isFiring = false
	end
end
function Ability_Reload:updateAmmoLabel(visible)
	local newText = ""

	if ((visible) and (self.started)) then
		newText = "Ammo Loaded: " .. self.loadedAmmo .. "/" .. self.maxAmmo .. " (" .. (self.weaponRealAmmo - self.loadedAmmo) .. " ammo left)"
		guiSetText(self.ammoLabel, newText)
		guiSetText(self.ammoLabel2, newText)
		guiSetVisible(self.ammoLabel, true)
		guiSetVisible(self.ammoLabel2, true)
	else
		guiSetVisible(self.ammoLabel, false)
		guiSetVisible(self.ammoLabel2, false)	
	end
end

function Ability_Reload:OnRender()
	local ticks = getTickCount()
	local firedGun = false
	
	-- Another possible fix for the 'no start ammo' bug
	if ((not self.started) and (getPlayerTotalAmmo (self:getOwner(), self.weaponSlot) > 0)) then
		-- Get some info
		self.curHolding = getPlayerWeapon(self:getOwner())
		self.reloading = false
		
		self.startAmmo = INT(getElementData(self:getElement(), "startAmmo"), getPlayerTotalAmmo (self:getOwner(), self.weaponSlot))
		self.loadedAmmo = self.startAmmo
		
		self.isFiring = getControlState("fire")
		
		if (self.loadedAmmo > self.maxAmmo) then 
			self.loadedAmmo = self.maxAmmo 
		end
		
		
		if ((self.loadedAmmo < self.maxAmmo) and (self.autoReload > 0) and (self.curHolding == self.weaponID)) then 
			self.reloading = true
			self.reloadStart = getTickCount()
		end
		
		self.reloadBar = guiCreateProgressBar(0.78, 0.22, 0.17, 0.02, true, nil)
		--self.reloadBarLabel = guiCreateLabel(0.20, 0.20, 1, 1, "Reloading...", true, self.reloadBar)
		self.ammoLabel2 = guiCreateLabel(0.722, 0.252, 1, 1, "Ammo Loaded: 0/0 (100 ammo left)", true)
		self.ammoLabel = guiCreateLabel(0.72, 0.25, 1, 1, "Ammo Loaded: 0/0 (100 ammo left)", true)
		
		guiLabelSetColor(self.ammoLabel, 255, 255, 255)
		guiLabelSetColor(self.ammoLabel2, 0, 0, 0)
		guiSetVisible(self.reloadBar, false)
		self.weaponRealAmmo = getPlayerTotalAmmo (self:getOwner(), self.weaponSlot)
		self.started = true -- Ok start up ok
	end
	
	-- Recheck if the reload script got started
	if (not self.started) then
		return
	end
	
	if ((self.curHolding == self.weaponID) and (not isPlayerDead(self:getOwner()))) then		
		self:updateAmmoLabel(true)		
		showPlayerHudComponent ("ammo", false)		
		
		local currentAmmo = getPlayerTotalAmmo (self:getOwner(), self.weaponSlot)
		
		if (currentAmmo < self.weaponRealAmmo) then
			self.loadedAmmo = self.loadedAmmo - (self.weaponRealAmmo - currentAmmo) -- We got a shot!
			self.weaponRealAmmo = currentAmmo
			firedGun = true
		elseif(currentAmmo > self.weaponRealAmmo) then
			-- Bug fix (possible)
			self.weaponRealAmmo = currentAmmo
		end

		-- Check if we need to auto reload
		if ((self.autoReload > 0) and (not self.reloading) and (self.loadedAmmo < self.maxAmmo) and (not self.isFiring))  then 
			self.reloading = true 
			self.reloadStart = ticks
		end
		
		-- Possible fix (the weaponRealAmmo check)
		if (((self.isFiring) and (firedGun)) or (self.weaponRealAmmo == 0)) then
			self.reloading = false
		end
		
		if ((self.reloading) and (self.loadedAmmo < self.maxAmmo) and (self.loadedAmmo < currentAmmo) and (not self.isFiring))then
		
			guiSetVisible(self.reloadBar, false)
			local progress = 100 / self.reloadTime  * (ticks - self.reloadStart)
			guiProgressBarSetProgress(self.reloadBar, progress)
			
			if (progress >= 100) then -- Got loaded !
				playSoundFrontEnd(41)
				
				-- Bugfix
				if (self.ammoPerReload > self.weaponRealAmmo) then
					self.loadedAmmo = self.loadedAmmo + self.weaponRealAmmo
				else
					self.loadedAmmo = self.loadedAmmo + self.ammoPerReload				
				end
				
				if (self.loadedAmmo > self.maxAmmo) then self.loadedAmmo = self.maxAmmo end
				if ((self.loadedAmmo < self.maxAmmo) and (self.reloadTillFiring > 0) and (not self.isFiring)) then
					self.reloading = true 
					self.reloadStart = ticks
					guiProgressBarSetProgress(self.reloadBar, 0)
					guiSetVisible(self.reloadBar, true)
				else
					self.reloading = false		
					guiSetVisible(self.reloadBar, false)		
				end
			else
				guiSetVisible(self.reloadBar, true)
			end
		end
		
		if (self.loadedAmmo > 0) then
			self:ToggleFire(true)
		else
			self:ToggleFire(false)		
		end		
	else
		guiSetVisible(self.reloadBar, false)	
		self:updateAmmoLabel(false)
	end
end

function Ability_Reload:OnClientPlayerWeaponSwitch(prevWeaponSlot, curSlot)	
	local curWeapon = getPlayerWeapon(getLocalPlayer())
	local prevWeapon = getPlayerWeapon(getLocalPlayer(), prevWeaponSlot)
	self.curHolding = getPlayerWeapon(self:getOwner())
	self.curHoldingSlot = getSlotFromWeapon(self.curHolding)
	
	if (prevWeapon == self.weaponID) then
		self:ToggleFire(true)
		self.reloading = false 
		self.reloadStart = 0
		self:updateAmmoLabel(false)
		guiSetVisible(self.reloadBar, false)	
		showPlayerHudComponent ("ammo", true)
	elseif (curWeapon == self.weaponID) then
		self:updateAmmoLabel(true)
	end
end

function Ability_Reload:OnPlayerSpawn(player, team)
	
end

function Ability_Reload:OnCommand(command, arg1, arg2, arg3)	
	if ((command == self.commandName) and (self.loadedAmmo < self.maxAmmo)) then
		if (not isPlayerDead(getLocalPlayer())) then
			self.reloading = true 
			self.reloadStart = getTickCount()
		end
	end
end


local function OnClientResourceStart(resource)
	if (resource == getThisResource()) then			
		-- Register the ability in the 'register'
		registerAbility("reload", Ability_Reload)					
	end
end

addEventHandler("onClientResourceStart", getRootElement(), OnClientResourceStart )