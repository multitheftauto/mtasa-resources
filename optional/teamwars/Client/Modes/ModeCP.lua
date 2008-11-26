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

$Id: ModeCP.lua 40 2007-12-31 00:46:26Z sinnerg $
]]

--	Client Side CP (Capture Point) mode
	ModeCP = class('ModeCTF', ModeBase)

--	Map related events
	function ModeCP:OnMapStart(source, startedMap)
		self.ModeBase:OnMapStart(source, startedMap)
		
		self:_guiCreateCaptureBar()
	end
	
	function ModeCP:OnMapStop(source, stoppedMap)
		self.ModeBase:OnMapStop(source, stoppedMap)
		
		self:_guiDestroyCaptureBar()
	end
	
	function ModeCP:OnClientElementDataChange(source, key)
		self.ModeBase:OnClientElementDataChange(source, key)
		
		local newValue = getElementData(source, key)

	
	end
	
	function ModeCP:OnTick()
		self.ModeBase:OnTick()
	
		local ticks = getTickCount()
		
		if (not self.onTick100) then
			self.onTick100 = getTickCount() + 100
		end
		
		if (not self.onTick50) then
			self.onTick50 = getTickCount() + 50
		end
		
		if (getTickCount() >= self.onTick100) then
			self.onTick100 = getTickCount() + 100

	
		end
		
		if (getTickCount() >= self.onTick50) then
			self.onTick50 = getTickCount() +50

		end
		
	end
	
	function ModeCP:OnPlayerDead(source, killer, weapon, bodypart)		
		self.ModeBase:OnPlayerDead(source, killer, weapon, bodypart)
	
		if (source == getLocalPlayer()) then
			self:guiShowCaptureBar(false)
			self.capturingMarker = nil
		end
	end
	
	function ModeCP:OnCustomEvent(eventName, marker, currentProgress, maxProgress, ...)
		self.ModeBase:OnCustomEvent(eventName, marker, currentProgress, maxProgress, ...)
		local baseName = "Unknown"
		
		if (isElement(marker)) then
			local cp = getElementData(marker, "teamwars_cp")
			if ((cp) and (isElement(cp))) then
				baseName = getElementData(cp, "name")			
				if (not baseName) then baseName = "Unknown" end
			end
		end
		
		if (eventName == "captureProgress") then
			if (currentProgress == -1) then -- Blocked
				--outputChatBox("CAPTURE: BLOCKED")
				self.capturingMarker = marker
				self:guiSetCaptureLabel("Capture blocked.")
				self:guiUpdateCaptureBar(1, 10000)	
			elseif (currentProgress == false) then
				--outputChatBox("CAPTURE: STOPPED")
				self:guiShowCaptureBar(false)
				self.capturingMarker = nil -- stopped capping
			else
				--outputChatBox("CAPTURE: CAPPING")
				self:guiUpdateCaptureBar(currentProgress, maxProgress)	
				self.capturingMarker = marker		
				self:guiSetCaptureLabel("Capturing ...")
			end
		end
	end
	
	function ModeCP:OnRender()
		self.ModeBase:OnRender()
	end
	
	function ModeCP:OnCommand(...)
		self.ModeBase:OnCommand(...)
	end
	
	function ModeCP:OnPlayerDamage(source, attacker, weapon, bodypart, loss)
		self.ModeBase:OnPlayerDamage(source, attacker, weapon, bodypart, loss)
	end
	
	function ModeCP:OnPlayerSpawn(player, team)
		self.ModeBase:OnPlayerSpawn(player, team)
		
		if (player == getLocalPlayer()) then
			self:EnableSpawnProtection(5000, true)
		end
	end
	
	function ModeCP:_guiCreateCaptureBar()
		if (self.captureProgressBar) then self:_guiDestroyCaptureBar() end		
		
		self.captureProgressBar = guiCreateProgressBar(0.40,0.48,0.20,0.06, true, nil)
		self.captureLabel = guiCreateLabel(0.05, 0.30, 1,1, "Capturing ...", true, self.captureProgressBar)
		guiSetVisible(self.captureProgressBar, false)
	end
	
	function ModeCP:_guiDestroyCaptureBar()
		if (self.captureProgressBar) then
			guiSetVisible(self.captureProgressBar, false) 
			destroyElement(self.captureProgressBar)
			self.captureProgressBar = nil
		end
	end
	
	function ModeCP:guiShowCaptureBar(showit)
		if (not self.captureProgressBar) then return end	

		guiSetVisible(self.captureProgressBar, showit) 
	end
	
	function ModeCP:guiSetCaptureLabel(text)
		if (self.captureLabel) then
			guiSetText(self.captureLabel, text)
		end
	end
	
	function ModeCP:guiUpdateCaptureBar(leftSprint, maxSprint)
		if (not self.captureProgressBar) then return end	
		if ((maxSprint == 0) or (maxSprint == -1)) then
			return self:guiShowCaptureBar(false)			
		end
		
		guiProgressBarSetProgress(self.captureProgressBar, 100 / maxSprint * leftSprint)		
		if (100 / maxSprint * leftSprint ~= 100) then
			self:guiShowCaptureBar(true)
		else
			self:guiShowCaptureBar(false)		
		end
		
		-- Catch all fix - No more progress bars should be shown when dead :)
		if (isPlayerDead(getLocalPlayer())) then
			self:guiShowCaptureBar(false)			
		end
	end
