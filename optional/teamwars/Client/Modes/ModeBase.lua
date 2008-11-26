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

$Id: ModeBase.lua 36 2007-12-12 01:42:23Z sinnerg $
]]

--	Client Side Base mode
	ModeBase = class('ModeBase')
	ModeBase.elementList = {}
	
	function ModeBase:__init(modeName)
		if (modeName == nil) then modeName = "base" end
		self.modeName = modeName
	end
	
	function ModeBase:getModeName()
		return self.modeName
	end
	
--	Mode related events
	function ModeBase:OnModeStart()		
	--	Create GUI elements
		self:_guiCreateSprintBar()	
		self._Timers = {}
		self._Timers["UpdateTeamSelection"] = false	
		self._Timers["UpdateClassSelection"]= false
		
	--	Load the classes
		
	--	Handy to know ? 	
		self.pressingFire = false -- TODO Get real state!
		
	--	For abilities
		addCommandHandler("special1", TW_OnCommand)
		addCommandHandler("special2", TW_OnCommand)	
		addCommandHandler("special3", TW_OnCommand)	
		addCommandHandler("special4", TW_OnCommand)	
		addCommandHandler("special5", TW_OnCommand)	
		addCommandHandler("special6", TW_OnCommand)	
		addCommandHandler("special7", TW_OnCommand)	
		addCommandHandler("special8", TW_OnCommand)	
		addCommandHandler("special9", TW_OnCommand)	
		
		GameMode.elementList = {} -- Will be destroyed on stop
		
		outputDebugString("Team Wars started.")
	end

	function ModeBase:OnModeStop()	
	--	Clean up GUI elements
		self.teamSelectionCurrent = false
		self.classSelectionCurrent = false
		self:_guiDestroySprintBar()
		self:_guiDestroyTeamSelection()
		self:_guiDestroyHealingCross()
		self:_guiDestroyWeaponHealCross()
		self._Timers = nil
		
	-- Unload the classes (from current player that is)
		-- local classInfo = GameMode:GetClassElement(getElementData(getLocalPlayer(), "teamwars_class"))

		-- if (classInfo)then
			-- for abilityName,abilityObj in pairs(classInfo["abilities"]) do 
				-- if (abilityObj.Destroy) then
					-- abilityObj:Destroy()
				-- end
			-- end
		-- end
		
		for key,element in ipairs(self.elementList) do
			if (isElement(element)) then
				destroyElement(element)
			end
		end
		GameMode.elementList = {} -- Will be destroyed on stop
		
		if (isElement(self.unprotectGUILabel)) then
			guiSetVisible(self.unprotectGUILabel, false)
			destroyElement(self.unprotectGUILabel)
		end
		self.unprotectGUILabel = nil
		self.unprotectTime = nil
		self.unprotectCancelOnFire = false
		setElementData(getLocalPlayer(), "tw_spawn_protected", nil)
		outputDebugString("Team Wars stopped.")
	end
	
--	Map related events
	function ModeBase:OnMapStart(source, startedMap)
	-- 	Create the Team Selection stuff		
		self.teamSelectionCurrent = false
		self.classSelectionCurrent = false
		self.selectTeamInfoRows = {}
		self.selectClassInfoRows = {}
		
		self.Classes =  getElementsByType("class")
		self.Abilities = {}
		self:_guiCreateTeamSelection()
		self:_guiCreateClassSelection()
		
		-- self:guiShowTeamSelection(true) -- DEBUG
		self:BindKeys() -- Bind required teams
		
		-- Handle ability-handler objects
		for k,abilityObj in ipairs(getAbilityHandlers()) do
			if (abilityObj.OnMapStart) then abilityObj:OnMapStart(source, startedMap) end
		end
		
	end

	function ModeBase:OnMapStop(source, startedMap)
	--	Destroy the team selection stuff
		self.teamSelectionCurrent = false
		self.classSelectionCurrent = false
		self:_guiDestroyTeamSelection()
		self:_guiDestroyClassSelection()
		self._Timers["UpdateTeamSelection"] = false
		self._Timers["UpdateClassSelection"] = false
		self.selectTeamInfoRows = nil
		self.selectClassInfoRows = nil
		self.Classes = nil
		--for k, v in ipairs(self.ClassesRoot) do
		--destroyElement(v)
		--end
		
		-- Handle ability-handler objects
		for k,abilityObj in ipairs(getAbilityHandlers()) do
			if (abilityObj.OnMapStop) then abilityObj:OnMapStop(source, startedMap) end
		end

		-- Handle ability objects (and destroy)
		for key,abilityObj in ipairs(self.Abilities) do
			if (abilityObj.OnMapStop) then abilityObj:OnMapStop(source, startedMap) end	
			
			if (abilityObj.Destroy) then 
				abilityObj:Destroy() 
			end	
		end
		
		self.Abilities = {}
		GameMode.elementList = {} -- Will be destroyed on stop
		
		if (isElement(self.unprotectGUILabel)) then
			guiSetVisible(self.unprotectGUILabel, false)
		end
		self:DisableSpawnProtection()
	end
	
	function ModeBase:OnPlayerSpawn(player, team)

		if (player == getLocalPlayer()) then
			-- Handle ability objects (and destroy)
			for key,abilityObj in ipairs(self.Abilities) do
				if (abilityObj.OnPlayerSpawn) then abilityObj:OnPlayerSpawn(player, team) end	
				
				if (abilityObj.Destroy) then 
					abilityObj:Destroy() 
				end	
			end
		
			local classElement = getElementData(player, "teamwars_class")
			if (isElement(classElement)) then
				self.class = classElement
				local Abilities = getClassAbilities(classElement)

				-- Create the required ability objects
				for k, ability in ipairs(Abilities) do
					if ((not getClassAbilityMode(ability)) or (getClassAbilityMode(ability) == self:getModeName())) then
						self.Abilities[#self.Abilities + 1] = createAbility(getClassAbilityName(ability),  ability, getLocalPlayer())	
					end
				end
			else 
				-- ERROR
			end
		end
			
		-- Handle ability-handler objects
		for k,abilityObj in ipairs(getAbilityHandlers()) do
			if (abilityObj.OnPlayerSpawn) then abilityObj:OnPlayerSpawn(player, team) end
		end

		-- Handle ability objects (and destroy)
		for key,abilityObj in ipairs(self.Abilities) do
			if (abilityObj.OnPlayerSpawn) then abilityObj:OnPlayerSpawn(player, team) end	
		end
	end

	function ModeBase:OnPlayerDead(source, killer, weapon, bodypart)
		-- Handle ability-handler objects
		for k,abilityObj in ipairs(getAbilityHandlers()) do
			if (abilityObj.OnPlayerDead) then abilityObj:OnPlayerDead(source, killer, weapon, bodypart) end
		end

		-- Handle ability objects (and destroy)
		for key,abilityObj in ipairs(self.Abilities) do
			if (abilityObj.OnPlayerDead) then abilityObj:OnPlayerDead(source, killer, weapon, bodypart) end	
			if (source == getLocalPlayer()) then
				if (abilityObj.Destroy) then 
					abilityObj:Destroy() 
				end	
			end
		end
		if (source == getLocalPlayer()) then
			self.Abilities = {}
		end
				
		self.unprotectTime = nil
		self.unprotectCancelOnFire = false
		if (isElement(self.unprotectGUILabel)) then
			guiSetVisible(self.unprotectGUILabel, false)
		end
	end
	
	function ModeBase:OnClientPlayerWeaponSwitch(prevWeapon, curSlot)		
		local curWeapon = getPlayerWeapon(getLocalPlayer())
		
		-- Handle ability-handler objects
		for k,abilityObj in ipairs(getAbilityHandlers()) do
			if (abilityObj.OnClientPlayerWeaponSwitch) then abilityObj:OnClientPlayerWeaponSwitch(prevWeapon, curSlot)	end
		end

		-- Handle ability objects (and destroy)
		for key,abilityObj in ipairs(self.Abilities) do
			if (abilityObj.OnClientPlayerWeaponSwitch) then abilityObj:OnClientPlayerWeaponSwitch(prevWeapon, curSlot)	end	
		end
	
	end
	
-- 	Custom events
	function ModeBase:OnTick()
		local ticks = getTickCount()
		
		if (not self.lastTick) then
			self.lastTick = ticks
		end
		
		local timeSinceLastTick = ticks - self.lastTick
		
		if (not self.onTick100) then
			self.onTick100 = getTickCount() + 100
		end
		
		if ((self._Timers["UpdateTeamSelection"]) and (ticks >= self._Timers["UpdateTeamSelection"])) then
			self:_UpdateTeamSelection()
			self._Timers["UpdateTeamSelection"] = getTickCount() + 1000 -- 100ms
		end
		
		if ((self._Timers["UpdateClassSelection"]) and (ticks >= self._Timers["UpdateClassSelection"])) then
			self:_UpdateClassSelection()
			self._Timers["UpdateClassSelection"] = getTickCount() + 5000 -- 100ms
		end
		
		if (getTickCount() >= self.onTick100) then
			self.onTick100 = getTickCount() + 100	

			if (self.unprotectTime ~= nil) then
				-- Spawn Protected!
				if ((self.unprotectTime > 0) and (self.unprotectTime <= getTickCount())) then
					self:DisableSpawnProtection()
				end
			end
		end
		
		-- Handle ability-handler objects
		for k,abilityObj in ipairs(getAbilityHandlers()) do
			if (abilityObj.OnTick) then abilityObj:OnTick(timeSinceLastTick) end
		end

		-- Handle ability objects (and destroy)
		for key,abilityObj in ipairs(self.Abilities) do
			if (abilityObj.OnTick) then abilityObj:OnTick(timeSinceLastTick) end	
		end
	end
	
	function ModeBase:OnClientElementDataChange(source, key)

	end
	
	function ModeBase:OnClientGUIClick(source)
		
        -- Detect team selection		
		if ((self.selectTeamGridlist) and ( source == self.selectTeamGridlist ) ) then
			local teamName = guiGridListGetItemText ( self.selectTeamGridlist, guiGridListGetSelectedItem ( self.selectTeamGridlist ), 1 )
			local selectedTeam = getTeamFromName(teamName)
			if (selectedTeam) then
				self.teamSelectionCurrent = selectedTeam
				self:_UpdateTeamSelection(selectedTeam)
				playSoundFrontEnd(2)
			end
        elseif ((self.selectTeamButtons["#JOIN#"]) and (source == self.selectTeamButtons["#JOIN#"])) then
			local teamName = guiGridListGetItemText ( self.selectTeamGridlist, guiGridListGetSelectedItem ( self.selectTeamGridlist ), 1 )
			local selectedTeam = getTeamFromName(teamName)
			
			if (selectedTeam) then
				self.teamSelectionCurrent = selectedTeam
			end
			
			if (self.teamSelectionCurrent) then
				selectedTeam = self.teamSelectionCurrent
				triggerServerEvent("onTeamWarsTeamSelection", Root, getLocalPlayer(), getTeamName(selectedTeam))
				self:guiShowTeamSelection(false)
				playSoundFrontEnd(3)
			end
		elseif ((self.selectTeamButtons["#AUTO#"]) and (source == self.selectTeamButtons["#AUTO#"])) then		
			triggerServerEvent("onTeamWarsTeamSelection", Root, getLocalPlayer(), false, true)
			self:guiShowTeamSelection(false)
			playSoundFrontEnd(3) -- Maybe use 4?
			
		-- Detect class selection
		elseif ((self.selectClassGridlist) and ( source == self.selectClassGridlist ) ) then -- detect class selection
			local className = guiGridListGetItemText ( self.selectClassGridlist, guiGridListGetSelectedItem ( self.selectClassGridlist ), 1 )
			local selectedClass = self:GetClassElement(className)
			if (selectedClass) then
				self.classSelectionCurrent = selectedClass
				self:_UpdateClassSelection(selectedClass)
				playSoundFrontEnd(2)
			end
        elseif ((self.selectClassButtons["#SELECT#"]) and (source == self.selectClassButtons["#SELECT#"])) then
			local className = guiGridListGetItemText ( self.selectClassGridlist, guiGridListGetSelectedItem ( self.selectClassGridlist ), 1 )
			local selectedClass = self:GetClassElement(className)
			
			if (selectedClass) then
				self.classSelectionCurrent = selectedClass
			end
			if (self.classSelectionCurrent) then
				triggerServerEvent("onTeamWarsClassSelection", Root, getLocalPlayer(), self.classSelectionCurrent, false)
				self:guiShowClassSelection(false)
				playSoundFrontEnd(3)
			end
		elseif ((self.selectClassButtons["#RANDOM#"]) and (source == self.selectClassButtons["#RANDOM#"])) then		
			triggerServerEvent("onTeamWarsClassSelection", Root, getLocalPlayer(), false, true)
			self:guiShowClassSelection(false)
			playSoundFrontEnd(3) -- Maybe use 4?
		end
	end
	
	function ModeBase:OnKeyInput(key, keyState)
		if (key == "jump") then
		
			elseif (key == "fire") then
			if (keyState == "down") then
				self.pressingFire = true	
				if ((self.unprotectTime ~= nil) and (self.unprotectCancelOnFire)) then
					self:DisableSpawnProtection()
				end
			else
				self.pressingFire = false
			end
		end		
		
		-- Handle ability-handler objects
		for k,abilityObj in ipairs(getAbilityHandlers()) do
			if (abilityObj.OnKeyInput) then abilityObj:OnKeyInput(key, keyState) end
		end

		-- Handle ability objects (and destroy)
		for kk,abilityObj in ipairs(self.Abilities) do
			if (abilityObj.OnKeyInput) then abilityObj:OnKeyInput(key, keyState) end	
		end
	end
	
	function ModeBase:OnRender()
		-- Handle ability-handler objects
		for k,abilityObj in ipairs(getAbilityHandlers()) do
			if (abilityObj.OnRender) then abilityObj:OnRender() end
		end

		-- Handle ability objects (and destroy)
		for key,abilityObj in ipairs(self.Abilities) do
			if (abilityObj.OnRender) then abilityObj:OnRender() end	
		end
	end	
	
	function ModeBase:OnCommand(command, arg1, arg2, arg3, ...)
		-- Handle ability-handler objects
		for k,abilityObj in ipairs(getAbilityHandlers()) do
			if (abilityObj.OnCommand) then abilityObj:OnCommand(command, arg1, arg2, arg3, ...) end
		end

		-- Handle ability objects (and destroy)
		for key,abilityObj in ipairs(self.Abilities) do
			if (abilityObj.OnCommand) then abilityObj:OnCommand(command, arg1, arg2, arg3, ...) end	
		end
		
	end
	
	function ModeBase:OnClienPlayerDamage(source, attacker, weapon, bodypart)		
		local attackingPlayer = attacker
		
		if ((isElement(attacker)) and (getElementType ( attacker ) == "vehicle" )) then
			attackingPlayer = getVehicleController ( attacker )			
		end
		
		
		-- Spawn Protection is enabled if self.unprotectTime ~= nil
		if ((source == getLocalPlayer()) and (self.unprotectTime ~= nil)) then
			cancelEvent()
		end
	end
	
	function ModeBase:OnPlayerDamage(source, attacker, weapon, bodypart, loss)
		local attackingPlayer = attacker
		
		if ((isElement(attacker)) and (getElementType ( attacker ) == "vehicle" )) then
			attackingPlayer = getVehicleController ( attacker )			
		end
		
		if ((attackingPlayer) and (attackingPlayer == getLocalPlayer()) and (source) and (source ~= getLocalPlayer()) and (loss)) then
			playSoundFrontEnd (43)
		end
		
	end
	
	function ModeBase:OnCustomEvent(eventName, arg1, arg2, arg3, arg4, arg5)
		-- Someone healed this player
		if (eventName == "playerwashealed") then
			local medic = arg1
			local amount = arg2
			
			if ((isElement(medic)) and (amount) and (amount > 0)) then
				-- Really got healed! Jippy!
				self:showHealingCross() -- Show the healing cross
				outputChatBox("NOTICE: " .. getPlayerName(medic) .. " has healed you for " .. amount .. " healthpoint(s).", 0,255,0)
			end
		-- This player healed someone
		elseif (eventName == "healedplayer") then
			local target = arg1
			local amount = arg2
			
			if ((isElement(target)) and (amount) and (amount > 0)) then
				outputChatBox("NOTICE: You healed " .. getPlayerName(target) .. " for " .. amount .. " healthpoint(s).", 0,255,0)
				playSoundFrontEnd(46) -- Engineer sound, since we cant play custom sounds 'yet'
			end
		elseif (eventName == "disableSpawnProtection") then
			self:DisableSpawnProtection()
		end
		
		-- playSoundFrontEnd(46)
	end
	
--	Custom functions
	function ModeBase:ToggleMovement(enabled)
		if (enabled == nil) then enabled = true end
		
	-- disable moving
		toggleControl ("forwards", enabled)
		toggleControl ("backwards", enabled)
		toggleControl ("left", enabled)
		toggleControl ("right", enabled)
		toggleControl ("jump", enabled)	
	end   

	function ModeBase:guiShowTeamSelection(visible)
		if ((self.selectTeamWindow) and (isElement(self.selectTeamWindow))) then
			showCursor(visible)
			guiSetVisible(self.selectTeamWindow, visible)			
		end
	end
	
	function ModeBase:guiShowClassSelection(visible)
		if ((self.selectClassWindow) and (isElement(self.selectClassWindow))) then
			showCursor(visible)
			guiSetVisible(self.selectClassWindow, visible)			
		end
	end
	
	function ModeBase:guiShowIngameClassSelection(visible)
		self:guiShowClassSelection(visible)
	end		
	
	-- Bind the required keys
	function ModeBase:BindKeys()
		bindKey ( "jump", "down", TW_OnKeyInput )
		bindKey ( "fire", "both", TW_OnKeyInput )
	end
	
	function ModeBase:GetClassElement(className)
		if (not self.Classes) then return false end	
		for classKey,classElement in ipairs(self.Classes) do
			if (getClassName(classElement) == className) then
				return classElement
			end
		end
		
		return false
	end
	function ModeBase:IsSpawnProtected()
		if (self.unprotectTime  ~= nil) then
			return true
		end
		
		return false
	end
	function ModeBase:EnableSpawnProtection(protectionTimeMS, cancelOnFire, transparancyLevel)
		if (transparancyLevel == nil) then transparancyLevel = 125 end
		if (not isPlayerDead(getLocalPlayer())) then
			--setElementAlpha (getLocalPlayer(), transparancyLevel)
			--triggerServerEvent( "onTeamWarsCustomEvent",  Root, "setElementAlpha", getLocalPlayer(), transparancyLevel)
			if (not cancelOnFire) then cancelOnFire = false end
			if ((not protectionTimeMS) or (protectionTimeMS == 0)) then 
				self.unprotectTime = 0 
			else
				self.unprotectTime = getTickCount() + protectionTimeMS			
			end
			self.unprotectCancelOnFire = cancelOnFire
			if (isElement(self.unprotectGUILabel)) then
				guiSetVisible(self.unprotectGUILabel, false)
			else
				self.unprotectGUILabel = guiCreateLabel ( 0.38, 0.45, 1, 1, "- Spawn Protected -", true )
				guiLabelSetColor(self.unprotectGUILabel, 255, 255, 255)
				guiSetFont ( self.unprotectGUILabel, "sa-header" )
			end
			setElementData(getLocalPlayer(), "tw_spawn_protected", true)
		end
	end
	
	function ModeBase:DisableSpawnProtection(skipRestoreAlpha)		
		-- Restore Transparancy
		if (not skipRestoreAlpha) then
			--setElementAlpha (getLocalPlayer(), 255)
			--triggerServerEvent( "onTeamWarsCustomEvent",  Root, "setElementAlpha", getLocalPlayer(), 255)
		end
			
		if (isElement(self.unprotectGUILabel)) then
			guiSetVisible(self.unprotectGUILabel, false)
			destroyElement(self.unprotectGUILabel)
			self.unprotectGUILabel = nil
		end
		self.unprotectTime = nil	
		setElementData(getLocalPlayer(), "tw_spawn_protected", false)	
	end
	
	function ModeBase:_guiCreateWeaponHealCross()
		self.guiWeaponHealCross = guiCreateStaticImage(0.81, 0.11, 0.03, 0.03, "Client/Gfx/BlackWhiteCross.png", true)	
		guiSetVisible(self.guiWeaponHealCross, false)
	end
	
	function ModeBase:showWeaponHealCross(visible,changeAlpha )
		if (visible == nil) then visible = true end	
		if (isElement(self.guiWeaponHealCross)) then
			guiSetVisible(self.guiWeaponHealCross, visible)
			if ((changeAlpha~= nil) and (changeAlpha ~= false)) then
				guiSetAlpha(self.guiWeaponHealCross, changeAlpha)
			end
		end
	end
	
	function ModeBase:_guiDestroyWeaponHealCross()
		if (isElement(self.guiWeaponHealCross)) then
			destroyElement(self.guiWeaponHealCross)
			self.guiWeaponHealCross = false
			outputDebugString("Base * Destroyed the Weapon Heal Cross image.")
		end
	end
	
	function ModeBase:_guiCreateHealingCross()
		self.guiHealingCross = guiCreateStaticImage(0.90, 0.90, 0.05, 0.05, "Client/Gfx/RedCross.png", true)		
		guiSetVisible(self.guiHealingCross, false)
	end
	
	function ModeBase:showHealingCross(visible,changeAlpha )
		if (visible == nil) then visible = true end	
		if (isElement(self.guiHealingCross)) then
			guiSetVisible(self.guiHealingCross, visible)
			if ((changeAlpha~= nil) and (changeAlpha ~= false)) then
				guiSetAlpha(self.guiHealingCross, changeAlpha)
			end
		end
	end
	
	function ModeBase:_guiDestroyHealingCross()
		if (isElement(self.guiHealingCross)) then
			destroyElement(self.guiHealingCross)
			self.guiHealingCross = false
			outputDebugString("Base * Destroyed the Healing Cross image.")
		end
	end
	
	function ModeBase:_guiCreateClassSelection()
		if (self.selectClassWindow) then
			self:_guiDestroyClassSelection() -- Destroy it first
		end
		
	-- 	Create our window
		self.selectClassWindow = guiCreateWindow ( 0.10, 0.25, 0.80, 0.50, "SELECT YOUR CLASS", true )
		guiWindowSetSizable(self.selectClassWindow, false)
		
	--	Create the Class gridlist
		self.selectClassGridlist = guiCreateGridList ( 0.05, 0.10, 0.30, 0.80, true, self.selectClassWindow )
		guiGridListSetSortingEnabled(self.selectClassGridlist, false)
		
		self.selectClassColumn = guiGridListAddColumn( self.selectClassGridlist, "Class", 0.80 )
	--	BUG(mantis:2585) - Looks like this crashes MTA: guiGridListAutoSizeColumn(self.selectClassGridlist, self.selectClassColumn)
	
	-- 	Prepare
		self.selectClassButtons = {}
		
		local lastY =  0.17
		for classKey,classElement in ipairs(self.Classes) do
			local className = getClassName(classElement)			
			if (not isElement(self.classSelectionCurrent)) then self.classSelectionCurrent = classElement end
			local currentRow = guiGridListAddRow ( self.selectClassGridlist )
			guiGridListSetItemText ( self.selectClassGridlist, currentRow, self.selectClassColumn, className, false, false )
		end
		
	--	Create the random Class button (make this assign right away without needing to click the #JOIN# button?)
		self.selectClassButtons["#RANDOM#"] 	= guiCreateButton ( 0.05, 0.90, 0.30, 0.10, "Random", true, self.selectClassWindow )
		
	--	Create the 'frame'
		self.selectClassInfoFrame = guiCreateGridList ( 0.40, 0.10, 0.55, 0.80, true,  self.selectClassWindow)
		guiGridListSetSortingEnabled(self.selectClassInfoFrame, false)
		
	--	Create a new column, simply named "Class Info"
		self.selectClassInfoColumn = guiGridListAddColumn( self.selectClassInfoFrame, "Class Info", 0.90 )

	--	Create the 'Select <class>' Button
		local className = getClassName(self.classSelectionCurrent)
		self.selectClassButtons["#SELECT#"] = guiCreateButton (0.40, 0.90, 0.55, 0.10, "Spawn as " .. className, true, self.selectClassWindow )
		
		guiSetVisible(self.selectClassWindow, false)
		
	--	Start the update Class selection timer (triggers every second to update info)
		self._Timers["UpdateClassSelection"] = getTickCount() + 1000 -- 1sec
		
	--	Update the Class selection (using the first Class on the list)
		self:_UpdateClassSelection(self.classSelectionCurrent)
		
		outputDebugString("TeamWars: Base * Created the Class Selection window.")
	end	
	
	function ModeBase:_guiDestroyClassSelection()
		if ((self.selectClassWindow) and (isElement(self.selectClassWindow))) then
			guiSetVisible(self.selectClassWindow, false)
			destroyElement(self.selectClassWindow)
			self.selectClassWindow = nil
			self.selectClassInfoRows = {}
			outputDebugString("TeamWars: Base * Destroyed the Class Selection window.")
		end
	end

	function ModeBase:_UpdateClassSelection(selectedClass)
		if (not selectedClass) then selectedClass = self.classSelectionCurrent end
		if (not self.selectClassInfoRows) then return end -- This should not happen btw :P
		local classInfo = getClassInfo(selectedClass)
		
		if (classInfo) then
			-- Valid class
			
			-- First destroy the old rows
			if (self.selectClassInfoRows) then
				-- Clean up columns
				for i = 1, guiGridListGetRowCount(self.selectClassInfoFrame) do
					guiGridListRemoveRow(self.selectClassInfoFrame, 0)
				end
			end
			
		--	CLASS INFO
			-- Name
			self.selectClassInfoRows["className"] = {}
			self.selectClassInfoRows["className"][1] = guiGridListAddRow( self.selectClassInfoFrame )
			self.selectClassInfoRows["className"][2] = guiGridListAddRow( self.selectClassInfoFrame )
			guiGridListSetItemText ( self.selectClassInfoFrame, self.selectClassInfoRows["className"][1], self.selectClassInfoColumn, "Class", true, false )
			guiGridListSetItemText ( self.selectClassInfoFrame, self.selectClassInfoRows["className"][2], self.selectClassInfoColumn, getClassName(selectedClass), false, false )
			-- Description
			self.selectClassInfoRows["classDescription"] = {}
			self.selectClassInfoRows["classDescription"][1] = guiGridListAddRow( self.selectClassInfoFrame )
			self.selectClassInfoRows["classDescription"][2] = guiGridListAddRow( self.selectClassInfoFrame )
			guiGridListSetItemText ( self.selectClassInfoFrame, self.selectClassInfoRows["classDescription"][1], self.selectClassInfoColumn, "Description", true, false )
			guiGridListSetItemText ( self.selectClassInfoFrame, self.selectClassInfoRows["classDescription"][2], self.selectClassInfoColumn, classInfo["description"], false, false )
		
		--	STATS
			self.selectClassInfoRows["classStats"] = {}
					
			self.selectClassInfoRows["classStats"][#self.selectClassInfoRows["classStats"] + 1] = guiGridListAddRow( self.selectClassInfoFrame )
			guiGridListSetItemText ( self.selectClassInfoFrame, self.selectClassInfoRows["classStats"][#self.selectClassInfoRows["classStats"]], self.selectClassInfoColumn, "Stats", true, false )
			
			-- Sprint
			-- self.selectClassInfoRows["classStats"][#self.selectClassInfoRows["classStats"] + 1] = guiGridListAddRow( self.selectClassInfoFrame )
			-- if (classInfo["sprintTime"] == "-1") then
				-- guiGridListSetItemText ( self.selectClassInfoFrame, self.selectClassInfoRows["classStats"][#self.selectClassInfoRows["classStats"]], self.selectClassInfoColumn, "Can sprint: Always", false, false )
			-- elseif (classInfo["sprintTime"] == "0") then			
				-- guiGridListSetItemText ( self.selectClassInfoFrame, self.selectClassInfoRows["classStats"][#self.selectClassInfoRows["classStats"]], self.selectClassInfoColumn, "Can sprint: Never", false, false )
			-- else			
				-- guiGridListSetItemText ( self.selectClassInfoFrame, self.selectClassInfoRows["classStats"][#self.selectClassInfoRows["classStats"]], self.selectClassInfoColumn, "Can sprint: " .. classInfo["sprintTime"] .. " second(s)", false, false )
			-- end		
			local classInfo = getClassInfo(selectedClass)
			
			-- startHealth
			self.selectClassInfoRows["classStats"][#self.selectClassInfoRows["classStats"] + 1] = guiGridListAddRow( self.selectClassInfoFrame )
			guiGridListSetItemText ( self.selectClassInfoFrame, self.selectClassInfoRows["classStats"][#self.selectClassInfoRows["classStats"]], self.selectClassInfoColumn, "Start Health: " .. classInfo["startHealth"], false, false )
			-- maxHealth
			self.selectClassInfoRows["classStats"][#self.selectClassInfoRows["classStats"] + 1] = guiGridListAddRow( self.selectClassInfoFrame )
			guiGridListSetItemText ( self.selectClassInfoFrame, self.selectClassInfoRows["classStats"][#self.selectClassInfoRows["classStats"]], self.selectClassInfoColumn, "Max Health: " .. classInfo["maxHealth"] , false, false )
			-- startArmor
			self.selectClassInfoRows["classStats"][#self.selectClassInfoRows["classStats"] + 1] = guiGridListAddRow( self.selectClassInfoFrame )
			guiGridListSetItemText ( self.selectClassInfoFrame, self.selectClassInfoRows["classStats"][#self.selectClassInfoRows["classStats"]], self.selectClassInfoColumn, "Start Armor: " .. classInfo["startArmor"] , false, false )
			-- maxArmor
			self.selectClassInfoRows["classStats"][#self.selectClassInfoRows["classStats"] + 1] = guiGridListAddRow( self.selectClassInfoFrame )
			guiGridListSetItemText ( self.selectClassInfoFrame, self.selectClassInfoRows["classStats"][#self.selectClassInfoRows["classStats"]], self.selectClassInfoColumn, "Max Armor: " .. classInfo["maxArmor"] , false, false )
			
		-- 	WEAPONS
			self.selectClassInfoRows["classWeapons"] = {}
			self.selectClassInfoRows["classWeapons"][#self.selectClassInfoRows["classWeapons"] + 1] = guiGridListAddRow( self.selectClassInfoFrame )
			guiGridListSetItemText ( self.selectClassInfoFrame, self.selectClassInfoRows["classWeapons"][#self.selectClassInfoRows["classWeapons"]], self.selectClassInfoColumn, "Weapons", true, false )
			
			for weaponKey,weaponElement in ipairs(getClassWeapons(selectedClass)) do
				local weaponInfo = getClassWeaponInfo(weaponElement)
				self.selectClassInfoRows["classWeapons"][#self.selectClassInfoRows["classWeapons"] + 1] = guiGridListAddRow( self.selectClassInfoFrame )
				guiGridListSetItemText ( self.selectClassInfoFrame, self.selectClassInfoRows["classWeapons"][#self.selectClassInfoRows["classWeapons"]], self.selectClassInfoColumn, getWeaponNameFromID (weaponInfo.ID) , false, false )		
			end
			
		-- 	ABILITIES
			self.selectClassInfoRows["classAbilities"] = {}
			self.selectClassInfoRows["classAbilities"][#self.selectClassInfoRows["classAbilities"] + 1] = guiGridListAddRow( self.selectClassInfoFrame )
			guiGridListSetItemText ( self.selectClassInfoFrame, self.selectClassInfoRows["classAbilities"][#self.selectClassInfoRows["classAbilities"]], self.selectClassInfoColumn, "Abilities", true, false )
			
			local classAbilities = getClassAbilities(selectedClass)
			for abilityID,abilityElement in ipairs(classAbilities) do
				local description = getClassAbilityDescription(abilityElement)
				if ((description) and (description ~= "")) then
					self.selectClassInfoRows["classAbilities"][#self.selectClassInfoRows["classAbilities"] + 1] = guiGridListAddRow( self.selectClassInfoFrame )
					guiGridListSetItemText ( self.selectClassInfoFrame, self.selectClassInfoRows["classAbilities"][#self.selectClassInfoRows["classAbilities"]], self.selectClassInfoColumn, description, false, false )		
				end
			end
			
		-- Update select button
			guiSetText(self.selectClassButtons["#SELECT#"], "Spawn as " .. getClassName(selectedClass))
		end
	end
	
	function ModeBase:_guiCreateTeamSelection()
		if (self.selectTeamWindow) then
			self:_guiDestroyTeamSelection() -- Destroy it first
		end
		
	-- 	Create our window
		self.selectTeamWindow = guiCreateWindow ( 0.10, 0.25, 0.80, 0.50, "SELECT YOUR TEAM", true )
		guiWindowSetSizable(self.selectTeamWindow, false)
		
	--	Create the team gridlist
		self.selectTeamGridlist = guiCreateGridList ( 0.05, 0.10, 0.30, 0.80, true, self.selectTeamWindow )
		guiGridListSetSortingEnabled(self.selectTeamGridlist, false)
		
		-- guiGridListSetScrollbars(self.selectTeamGridlist, false)
		
		self.selectTeamColumn = guiGridListAddColumn( self.selectTeamGridlist, "Team", 0.80 )
	--	BUG(mantis:2585) - Looks like this crashes MTA: guiGridListAutoSizeColumn(self.selectTeamGridlist, self.selectTeamColumn)
	
	-- 	Prepare
		self.selectTeamButtons = {}
		self.selectTeamLabels = {}
		
		local lastY =  0.17
		local teams = getElementsByType ( "team" )
		local firstTeam = nil

		for teamKey,teamValue in ipairs(teams) do
			local team_upperName = string.upper(getTeamName(teamValue))
			local currentRow = guiGridListAddRow ( self.selectTeamGridlist )
			
			guiGridListSetItemText ( self.selectTeamGridlist, currentRow, self.selectTeamColumn, getTeamName(teamValue), false, false )

			if (not self.teamSelectionCurrent) then self.teamSelectionCurrent = teamValue end
		end

	--	Create the auto assign team button (make this assign right away without needing to click the #JOIN# button?)
		self.selectTeamButtons["#AUTO#"] 	= guiCreateButton ( 0.05, 0.90, 0.30, 0.10, "Auto Assign", true, self.selectTeamWindow )
		
	--	Create the 'frame'
		self.selectTeamInfoFrame = guiCreateGridList ( 0.40, 0.10, 0.55, 0.80, true,  self.selectTeamWindow)
		guiGridListSetSortingEnabled(self.selectTeamInfoFrame, false)
		
	--	Create a new column, simply named "Info"
		self.selectTeamInfoColumn = guiGridListAddColumn( self.selectTeamInfoFrame, "Info", 0.90 )

	--	Create the 'Select <class>' Button
		self.selectTeamButtons["#JOIN#"] = guiCreateButton (0.40, 0.90, 0.55, 0.10, "Join " .. string.upper(getTeamName(self.teamSelectionCurrent)), true, self.selectTeamWindow )
		
		guiSetVisible(self.selectTeamWindow, false)
		
	--	Start the update team selection timer (triggers every second to update info)
		self._Timers["UpdateTeamSelection"] = getTickCount() + 1000 -- 1sec
		
	--	Update the team selection (using the first team on the list)
		self:_UpdateTeamSelection(self.teamSelectionCurrent)
		
		outputDebugString("TeamWars: Base * Created the Team Selection window.")
	end

	function ModeBase:_guiDestroyTeamSelection()
		if ((self.selectTeamWindow) and (isElement(self.selectTeamWindow))) then
			guiSetVisible(self.selectTeamWindow, false)
			destroyElement(self.selectTeamWindow)
			self.selectTeamWindow = nil
			self.selectTeamInfoRows = {}
			outputDebugString("TeamWars: Base * Destroyed the Team Selection window.")
		end
	end

	
	function ModeBase:_guiCreateSprintBar()
		if (self.sprintProgressBar) then self:_guiDestroySprintBar() end		
		
		self.sprintProgressBar = guiCreateProgressBar(0.40,0.95,0.20,0.03, true, nil)
		guiSetVisible(self.sprintProgressBar, false)
	end
	
	function ModeBase:_guiDestroySprintBar()
		if (self.sprintProgressBar) then
			guiSetVisible(self.sprintProgressBar, false) 
			destroyElement(self.sprintProgressBar)
			self.sprintProgressBar = nil
		end
	end
	
	function ModeBase:guiShowSprintBar(showit)
		if (not self.sprintProgressBar) then return end	

		guiSetVisible(self.sprintProgressBar, showit) 
	end
	
	function ModeBase:guiUpdateSprintBar(leftSprint, maxSprint)
		if (not self.sprintProgressBar) then return end	
		if ((maxSprint == 0) or (maxSprint == -1)) then
			return self:guiShowSprintBar(false)			
		end
		
		guiProgressBarSetProgress(self.sprintProgressBar, 100 / maxSprint * leftSprint)		
		if (100 / maxSprint * leftSprint ~= 100) then
			self:guiShowSprintBar(true)
		else
			self:guiShowSprintBar(false)		
		end
	end


	function ModeBase:_UpdateTeamSelection(selectedTeam)
		if (not selectedTeam) then selectedTeam = self.teamSelectionCurrent end
		if (not self.selectTeamInfoRows) then return end -- This should not happen btw :P

		if ((isElement(selectedTeam)) and (getElementType(selectedTeam) == "team")) then
			-- Valid team
			
			-- First destroy the old rows
			if (self.selectTeamInfoRows) then
				-- Clean up columns
				for i = 1, guiGridListGetRowCount(self.selectTeamInfoFrame) do
					guiGridListRemoveRow(self.selectTeamInfoFrame, 0)
				end
			end
			
			-- Create the new ones
			self.selectTeamInfoRows["Team"] = {}
			self.selectTeamInfoRows["Team"][1] = guiGridListAddRow( self.selectTeamInfoFrame )
			self.selectTeamInfoRows["Team"][2] = guiGridListAddRow( self.selectTeamInfoFrame )
			guiGridListSetItemText ( self.selectTeamInfoFrame, self.selectTeamInfoRows["Team"][1], self.selectTeamInfoColumn, "Team", true, false )
			guiGridListSetItemText ( self.selectTeamInfoFrame, self.selectTeamInfoRows["Team"][2], self.selectTeamInfoColumn, getTeamName(selectedTeam), false, false )
			
			self.selectTeamInfoRows["Players"] = {}
			self.selectTeamInfoRows["Players"][1] = guiGridListAddRow( self.selectTeamInfoFrame )
			self.selectTeamInfoRows["Players"][2] = guiGridListAddRow( self.selectTeamInfoFrame )
			guiGridListSetItemText ( self.selectTeamInfoFrame, self.selectTeamInfoRows["Players"][1], self.selectTeamInfoColumn, "Players", true, false )
			guiGridListSetItemText ( self.selectTeamInfoFrame, self.selectTeamInfoRows["Players"][2], self.selectTeamInfoColumn, countPlayersInTeam(selectedTeam) .. "", false, false )
			
			-- TODO Add objectives
			
			-- Update join button
			guiSetText(self.selectTeamButtons["#JOIN#"], "Join " .. getTeamName(self.teamSelectionCurrent))
		end
	end
	