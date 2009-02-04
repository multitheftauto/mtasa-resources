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

$Id: ModeBase.lua 39 2007-12-18 21:50:11Z sinnerg $
]]

-- Server Side ModeBase
	ModeBase = class('ModeBase')
	
	function ModeBase:__init(modeName)
		if (modeName == nil) then modeName = "base" end
		self.modeName = modeName
	end
	
	function ModeBase:getModeName()
		return self.modeName
	end
--	Mode related events
	function ModeBase:OnModeStart()	
		self.announceDisplay = textCreateDisplay ()
		self.announceText = textCreateTextItem ( "", 0.5, 0.25, 0, 0, 0, 0, 255, 2, "center" )
		textDisplayAddText ( self.announceDisplay, self.announceText )
		
		self.isAnnouncing = false
		self.announceTimer= false
			
		self.Settings = {}
		self.Abilities = {} -- List of abilities, 'index' is the player
		
		-- Loop all players
		local players = getElementsByType("player")
		for k, player in ipairs(players) do
			self.Abilities[player] = {}
		end		
		
		-- Handle ability-handler objects
		for k,abilityObj in ipairs(getAbilityHandlers()) do
			if (abilityObj.OnModeStart) then abilityObj:OnModeStart() end
		end
		-- Prepare scoreboard (Status field)
		-- Following crashes MTA
		--local scoreColumns = call(getResourceFromName("scoreboard"), "getScoreboardColumns" )
		--call(getResourceFromName("scoreboard"), "addScoreboardColumn", "Status", Root, #scoreColumns , 0.20 )
		
		call(getResourceFromName("scoreboard"), "addScoreboardColumn", "Status", Root, 6 , 0.20 ) -- FIXME This is NOT correct, should be added as the LAST row!
		
		local players = getElementsByType( "player" )
		for k,player in ipairs(players) do
			setElementData( player, "Status", "Loading..." )
		end
		
		outputDebugString("Started the Team Wars mode.")
	end

	function ModeBase:OnModeStop()
		-- Handle ability-handler objects
		for k,abilityObj in ipairs(getAbilityHandlers()) do
			if (abilityObj.OnModeStop) then abilityObj:OnModeStop() end
		end
		
		self:HideAnnounce()
		if (self.announceDisplay) then
			textDestroyDisplay(self.announceDisplay)
			self.announceDisplay = nil
		end
		if (self.announceText) then
			textDestroyTextItem(self.announceText)
			self.announceText = nil
		end
		self.Settings = nil
		
		
		call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "Status" )
		
		-- triggerClientEvent("onTeamWarsGamemodeMapStop", self.MapSource, self.MapResource)
		outputDebugString("Stopped the Team Wars mode.")
	end
	
	function ModeBase:OnMapStart(source, startedMap)
		self.MapSource = source
		self.MapResource = startedMap
		-- Load settings
		self.Settings.teamBalance = INT(get("teamwars_balancing", 1)) -- 1 is the default, means that teams may be uneven for 1 player, so you can have teams like 4vs5 but not 5vs7 (0 means do not balance)
		
		if (self.Settings.teamBalance == 0) then
			self.Settings.teamBalance = false
		end	
		
		-- Load classes
		self.Classes = getElementsByType("class")
		
		-- Handle ability-handler objects
		for k,abilityObj in ipairs(getAbilityHandlers()) do
			if (abilityObj.OnMapStart) then abilityObj:OnMapStart(source, startedMap) end
		end

		triggerClientEvent("onTeamWarsGamemodeMapStart", self.MapSource, true)	
	end
	
	function ModeBase:OnMapStop(source, startedMap)
		-- Handle ability-handler objects
		for k,abilityObj in ipairs(getAbilityHandlers()) do
			if (abilityObj.OnMapStop) then abilityObj:OnMapStop(source, startedMap) end
		end

		-- Handle ability objects (and destroy)
		for k, selPlayer in ipairs(getElementsByType("player")) do
			local abilityList = self.Abilities[selPlayer]
			for key,abilityObj in ipairs(abilityList) do
				if (abilityObj.OnMapStop) then abilityObj:OnMapStop(source, startedMap) end	
				
				if (abilityObj.Destroy) then 
					abilityObj:Destroy() 
					table.remove(self.Abilities[selPlayer], key)
				end	
			end
		end		
		
		self.MapSource = nil
		self.MapResource = nil
		self.Classes = nil
		-- Loop all players
		local players = getElementsByType("player")
		for k, player in ipairs(players) do
			self.Abilities[player] = {}
		end		
	end
	
--	Misc events
	function ModeBase:OnTick()
		local ticks = getTickCount()
		
		if (not self.lastTick) then
			self.lastTick = ticks
		end
		
		local timeSinceLastTick = ticks - self.lastTick
		
		-- We need to load the classes ASAP!
		if (not self.Classes) then
		--	Load the classes
			self.Classes = getElementsByType("class")
		end
		
		if ((self.announceTimer ~= false) and (ticks >= self.announceTimer)) then
			-- Time has passed.. Time to hide the announce
			self:HideAnnounce()
		end
		
		-- Handle ability-handler objects
		for k,abilityObj in ipairs(getAbilityHandlers()) do
			if (abilityObj.OnTick) then abilityObj:OnTick(timeSinceLastTick) end
		end

		-- Handle ability objects
		for k, selPlayer in ipairs(getElementsByType("player")) do
			local abilityList = self.Abilities[selPlayer]

			for key,abilityObj in ipairs(abilityList) do
				if (abilityObj.OnTick) then abilityObj:OnTick(timeSinceLastTick) end	
			end
		end		
	end

	function ModeBase:OnPlayerDamage(source, attacker, weapon, bodypart, loss)		
		triggerClientEvent("onTeamWarsPlayerDamage", Root, source, attacker, weapon, bodypart, loss)
		
		local attackingPlayer = attacker
		
		if ((isElement(attacker)) and (getElementType ( attacker ) == "vehicle" )) then
			attackingPlayer = getVehicleController ( attacker )			
		end
		
		-- Handle ability-handler objects
		for k,abilityObj in ipairs(getAbilityHandlers()) do
			if (abilityObj.OnPlayerDamage) then abilityObj:OnPlayerDamage(source, attacker, weapon, bodypart, loss) end
		end
		
		-- Handle ability objects (and destroy if needed)
		for k, selPlayer in ipairs(getElementsByType("player")) do
			local abilityList = self.Abilities[selPlayer]
			for key,abilityObj in ipairs(abilityList) do
				if (abilityObj.OnPlayerDamage) then abilityObj:OnPlayerDamage(source, attacker, weapon, bodypart, loss) end	
			end
		end
	end
	
	function ModeBase:OnVehicleExit(vehicle, player, seat, jacker)	

	end
	
	function ModeBase:OnVehicleDamage(vehicle, attacker, weapon, loss)
		-- attacker + weapon currently doesnt work!
		local drivingPlayer =getVehicleController ( vehicle )		

	end
	
	function ModeBase:OnCustomEvent(eventName, arg1, arg2, arg3, arg4, arg5)
		if (not eventName) then return false end
		
		if (eventName == "setElementAlpha") then
			if (not isElement(arg1)) then
				return false
			end
			if (arg2 == nil) then return false end
			return setElementAlpha(arg1, arg2)
		end
	end
	
	function ModeBase:OnPlayerJoin(source)
		local playerName = getPlayerName(source)
	
		-- Set connection status
		setElementData(source, "Status", "Loading...")
		
		self.Abilities[source] = {}
	end
	function ModeBase:OnPlayerJoined(source)
		local playerName = getPlayerName(source)
		
		-- Announce check
		if (self.isAnnouncing) then
			textDisplayAddObserver ( self.announceDisplay, source )
		end
		
		-- Set connection status
		setElementData(source, "Status", "Playing")
		
		if (self.MapSource) then			
			triggerClientEvent(source, "onTeamWarsGamemodeMapStart", self.MapSource, true)	
			triggerClientEvent(source, "onTeamWarsShowTeamSelection", Root, true)
		end
		
	end


	function ModeBase:SlayPlayers()
		local Players = getElementsByType("player")
		
		for k, Player  in ipairs(Players) do
			if (not isPedDead(Player)) then killPed(Player) end -- Slay him! :P
		end
	end
	
	function ModeBase:OnColShapeHit(colshape, player, matchedDimension)

	end

	function ModeBase:OnMarkerHit(marker, player, matchedDimension)

	end

	function ModeBase:OnMarkerLeave(marker, player, matchedDimension)

	end
	
	function ModeBase:OnPickupUse(thePickup, thePlayer)
		if (isElement(thePickup)) then
			if (getElementData(thePickup, "destroyOnPickup") == true) then
				destroyElement(thePickup)
			end
		end
	end

	function ModeBase:OnPlayerQuit(source, reason)
		local playerName = getPlayerName(source)
		
		-- Announce check
		if (self.isAnnouncing) then
			textDisplayRemoveObserver ( self.announceDisplay, source )
		end
		
		-- Handle ability-handler objects
		for k,abilityObj in ipairs(getAbilityHandlers()) do
			if (abilityObj.OnPlayerQuit) then abilityObj:OnPlayerQuit(source, reason) end
		end
		
		-- Handle ability objects (and destroy if needed)
		for k, selPlayer in ipairs(getElementsByType("player")) do
			local abilityList = self.Abilities[selPlayer]
			for key,abilityObj in ipairs(abilityList) do
				if (abilityObj.OnPlayerQuit) then abilityObj:OnPlayerQuit(source, reason) end	
				if (source == selPlayer) then
					if (abilityObj.Destroy) then 
						abilityObj:Destroy() 
						table.remove(self.Abilities[source], key)
					end	
				end
			end
		end
		
		-- outputChatBox(playerName .. " left the game (reason: " .. reason .. ".)") -- HANDLED BY MTA
	end

	function ModeBase:OnPlayerDead(source, ammo, attacker, weapon, bodypart)		
		-- Handle ability-handler objects
		for k,abilityObj in ipairs(getAbilityHandlers()) do
			if (abilityObj.OnPlayerDead) then abilityObj:OnPlayerDead(source, ammo, attacker, weapon, bodypart) end
		end
		
		-- Handle ability objects (and destroy if needed)
		for k, selPlayer in ipairs(getElementsByType("player")) do
			local abilityList = self.Abilities[selPlayer]
			for key,abilityObj in ipairs(abilityList) do
				if (abilityObj.OnPlayerDead) then abilityObj:OnPlayerDead(source, ammo, attacker, weapon, bodypart) end	
				if (source == selPlayer) then
					if (abilityObj.Destroy) then 
						abilityObj:Destroy() 
						table.remove(self.Abilities[source], key)
					end	
				end
			end
		end
	end

	function ModeBase:OnKeyInput( source, key, keyState)

	end
	
	function ModeBase:OnPlayerSpawn(player, x, y, z, rotation, team, model, interior, dimension)
		local classElement = getElementData(player, "teamwars_class")
		if (isElement(classElement)) then
			local Abilities = getClassAbilities(classElement)
			
			-- Create the required ability objects
			for k, ability in ipairs(Abilities) do
				if ((not getClassAbilityMode(ability)) or (getClassAbilityMode(ability) == self:getModeName())) then
					self.Abilities[player][#self.Abilities[player] + 1]  = createAbility(getClassAbilityName(ability), ability, player)	
				end
			end
		else 
			-- ERROR
		end

	end
	
--	Custom events
	function ModeBase:OnClassSelection(player, classElement, randomSelect)
		if (not player) then return end
		
		if (randomSelect) then
			setElementData(player, "teamwars_random_class", true)
			setElementData(player, "teamwars_selected_class", true)
			outputChatBox("Your class will be randomly selected each spawn.", player)
			return
		end
		
		local classInfo = getClassInfo(classElement)
		
		if (not classInfo) then
			-- Should not happen (I hope)			
			triggerClientEvent(player, "onTeamWarsShowClassSelection", Root, true)
			return
		end
		
		setElementData(player, "teamwars_random_class", false)
		setElementData(player, "teamwars_selected_class", classElement)
		outputChatBox("You will spawn as " .. getClassName(classElement) .. ".", player)
	end
	
	function ModeBase:OnTeamSelection (player, teamName, autoAssign) -- We send the team name, since its more error prone ;)
		if (not player) then return end
		
		if (autoAssign) then
			return self:AutoAssignTeam(player)
		end
		
		local selectedTeam = getTeamFromName(teamName)
		local oldTeam = getPlayerTeam(player)
		
		if (not selectedTeam) then
			outputChatBox("Invalid team selected. Please, try again.", player)
		end
		
		if (selectedTeam == oldTeam) then return end -- Same team.
		
		-- Get current players on the selected team
		local teamPlayers = countPlayersInTeam(selectedTeam)
		
		-- Loop through all teams
		--self.Settings.teamBalance
		if (self.Settings.teamBalance == false) then
			-- No balancing, just join the team
			self:SetPlayerTeam(player, selectedTeam)
		elseif (selectedTeam ~= oldTeam) then
			local teams = getElementsByType("team")
			local isBalanced = true
			for key,team in ipairs(teams) do 
				if (team ~= selectedTeam) then
					local players = countPlayersInTeam(team)
					if (team == oldTeam) then
						players = players - 1
					end
					
					if ((teamPlayers + 1) - players > self.Settings.teamBalance) then
						-- Cannot join this team! Would inbalance!
						isBalanced = false
					end

				end
			end
			
			if (isBalanced) then
				self:SetPlayerTeam(player, selectedTeam)
			else
				outputChatBox( "Could not join " .. getTeamName(selectedTeam) .. " since this would inbalance the teams!", player)
				triggerClientEvent(player, "onTeamWarsShowTeamSelection", Root, true)
			end
		end
	end
	
--	Custom functions
-- 	Check if a player is spawn protected (handled client side for speed)
	function ModeBase:IsSpawnProtected(player)
		if (not isElement(player)) then return false end
		if (isPedDead(player)) then return false end
		
		return getElementData(player, "tw_spawn_protected")
	end
	
	function ModeBase:DisableSpawnProtection(player)
		if ((self:IsSpawnProtected(player)) and (not isPedDead(player))) then
			return triggerClientEvent(player, "onTeamWarsCustomEvent", Root, "disableSpawnProtection", player)
		end
		
		return false -- not needed
	end
-- 	Auto Assign joins the team with the least members
	function ModeBase:AutoAssignTeam(player)
		local oldTeam = getPlayerTeam(player)
		local selectedTeam
		local teams = getElementsByType("team")
		local teamPlayers = {}
		
		for key,team in ipairs(teams) do 
			teamPlayers[#teamPlayers + 1] = countPlayersInTeam(team)
		end
		
		if (#teamPlayers == 0) then return false end -- Oh oh... Should never happen!
		
		table.sort(teamPlayers) -- Hope this is enough 
		
		local leastCount = teamPlayers[1]
		for key,team in ipairs(teams) do 
			local count = countPlayersInTeam(team)
			if ( count == leastCount ) then
				selectedTeam = team
			end
		end
		
		if (selectedTeam == oldTeam) then return true end -- Same team
	
		self:SetPlayerTeam(player, selectedTeam)
	end
	
	function ModeBase:SetPlayerTeam(player, team)
		local oldTeam = getPlayerTeam(player)
		if (not team) then return false end -- Invalid!
		triggerClientEvent(player, "onTeamWarsShowClassSelection", Root, true)	
		if (oldTeam == team) then return true end -- Already on it
		
		if (oldTeam) then 
			-- removePlayerFromTeam(player) 
			-- outputChatBox(getClientName(player) .. " left " .. getTeamName(oldTeam) .. ".")
			if (not isPedDead(player)) then
				killPed(player)
			end
		end
		setPlayerTeam(player, team)
		-- outputChatBox(getClientName(player) .. " joined " .. getTeamName(team) .. ".")		
	end
	
	-- Shows a message to ALL players
	function ModeBase:Announce ( red, green, blue, text, time )
		textItemSetColor ( self.announceText, red, green, blue, 255 )
		textItemSetText ( self.announceText, text )

		if (self.announceTimer == false) then
			local players = getElementsByType( "player" )
			for k,v in ipairs(players) do
				textDisplayAddObserver ( self.announceDisplay, v )
			end
		end

		if (time < 0) then time = 0 end
		self.announceTimer = getTickCount() + time
		self.isAnnouncing = true
	end

	-- Hide the announcement message from all players
	function ModeBase:HideAnnounce()
		local players = getElementsByType( "player" )
		
		for k,player in ipairs(players) do
			textDisplayRemoveObserver( self.announceDisplay, player )
		end
		
		self.isAnnouncing = false
		self.announceTimer = false
	end

	-- Get the class info
	function ModeBase:GetClassInfo(classElement)
	
		return getClassInfo(classElement)
		
		--return false
	end
	
	-- Respawn a team (MUST be overriden)
	function ModeBase:RespawnTeam(team)
		outputDebugString("Dummy function called (RespawnTeam). Please inform the script maintainer.", 2)	
	end	
	
	-- Respawn a player (MUST be overriden)
	function ModeBase:SpawnPlayer(player)
		outputDebugString("Dummy function called (SpawnPlayer). Please inform the script maintainer.", 2)
	end
	
	function ModeBase:GetRandomClass()
		if (not self.Classes) then return false end
		
		local className = getClassName(self.Classes[math.random(1, #self.Classes)])
		
		return className
	end
	
	function ModeBase:GetRandomClassElement()
		if (not self.Classes) then return false end
		
		return self.Classes[math.random(1, #self.Classes)]
	end
	