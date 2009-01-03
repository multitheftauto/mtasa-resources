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

	ModeCP = class('ModeCP', ModeBase)
	ModeCP.Name = "CP"
	
--	Mode related events
	function ModeCP:OnModeStart()	
		-- Do some initialisation (before calling base handler)
		call(getResourceFromName("scoreboard"), "resetScoreboardColumns")
		
		call(getResourceFromName("scoreboard"), "addScoreboardColumn", "Score",Root, 2, 0.08)
		call(getResourceFromName("scoreboard"), "addScoreboardColumn", "Captures",Root, 3, 0.1)
		call(getResourceFromName("scoreboard"), "addScoreboardColumn", "Rounds Won", Root, 4, 0.15 )
		
		self.ModeBase:OnModeStart()
		
		self.teamTable = {}			
		self.respawnTimers = {}
		--	outputChatBox("Team Wars: Base Wars started.")
		--	outputChatBox("Author: SinnerG (TeamChaos)")
		
		
		self.mapLoaded = false
		
		-- Loop through all players
		local players = getElementsByType( "player" )
		for k,player in ipairs(players) do
			setElementData( player, "Score", 0 )
			setElementData( player, "Captures", 0 )
			setElementData( player, "Rounds Won", 0 )
		end
		
 	end

	function ModeCP:OnModeStop()
		self.ModeBase:OnModeStop()
		
		-- Loop through all arrays and clean up
		self.respawnTimers = nil
		
		-- Clean up scoreboard
		call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "Score")
		call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "Captures")
		call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "Rounds Won" )
		
		-- Clean up player corona's
		local Players = getElementsByType("player")
		
		for k, Player  in ipairs(Players) do
			local playerCorona = getElementData(Player, "teamwars_player_corona")
			if ((playerCorona) and (isElement(playerCorona))) then
				destroyElement(playerCorona)
				removeElementData(Player, "teamwars_player_corona")
			end
		end

		--
		outputDebugString("TeamWars: CP Mode Stopped.")
	end
	
--	Map related events
	function ModeCP:OnMapStart(source, startedMap)
		self.ModeBase:OnMapStart(source, startedMap)
		
		self.teamTable = {}			
		self.respawnTimers = {}
		self.captureHouseBlips = {}
		local teams = getElementsByType ( "team" )
		
		if (table.getn( teams ) <2 ) then
			outputDebugString("CP * Map needs atleast 2 teams to be playable.", 1 )
			return
		end
		
		--for teamKey,teamValue in ipairs(teams) do
		--local r,g,b = getTeamColor( teamValue )
			
	--	Retrieve camera location
		local camera = getElementsByType( "camera" )
		if (camera) then
			self.cameraPosX, self.cameraPosY, self.cameraPosZ, self.cameraLookX, self.cameraLookY, self.cameraLookZ = tonumber(getElementData( camera[1], "posX" )), tonumber(getElementData( camera[1], "posY" )), tonumber(getElementData( camera[1], "posZ" )), tonumber(getElementData( camera[1], "lookX" )), tonumber(getElementData( camera[1], "lookY" )), tonumber(getElementData( camera[1], "lookZ" ))
		end
		if ( not self.cameraPosX ) or ( not self.cameraPosY ) or ( not self.cameraPosZ ) or ( not self.cameraLookX ) or ( not self.cameraLookY ) or ( not self.cameraLookZ ) then
			xi, yi, zi, xi, yi, zi = 0, 0, 0, 0, 0, 0
			self.cameraPosX, self.cameraPosY, self.cameraPosZ, self.cameraLookX, self.cameraLookY, self.cameraLookZ = xi, yi, zi, xi, yi, zi
			outputDebugString( "CP * Cameras are set wrong. Defaulting to " .. xi .. ", " .. yi .. ", " .. zi .. ".", 2 )
		end			
		
	-- 	Loop through all capturepoints
		local capturepoints = getElementsByType("capturepoint")	
		for capturepointKey,cp in ipairs(capturepoints) do
			local owningTeam = getElementData(cp, "owner")  
			local markerType = getElementData(cp, "marker") 
			local colSize = getElementData(cp, "colSize") 
			local name = getElementData(cp, "name") 
			local id = getElementData(cp, "id") 
			local r,g,b = 255,255,255
			local posX, posY, posZ = getElementData(cp, "posX"), getElementData(cp, "posY"), getElementData(cp, "posZ")
			
			if (not name) then 
				outputDebugString( "CP * Invalid capture point detected. Aborting.", 2 )
				return false -- Oh oh!
			end
			
			if (not markerType) then markerType = "corona" end
			if (not colSize) then colSize = 1 end
			if (not id) then id = name end
			
			-- Check if it has a valid owner
			if (owningTeam) then owningTeam = getTeamFromName(owningTeam) end
			if (owningTeam) then
				r,g,b = getTeamColor(owningTeam)
			end
			
			-- Create the capture point marker
			local markerObj = createMarker ( posX, posY, posZ, markerType, colSize, r, g, b, 100 ) -- TODO Make alpha configurable?
			if (not isElement(markerObj)) then
				--outputChatBox("ERROR: Control Point marker did not get created. Type: " .. markerType .. " Colsize: " .. colSize)			
			else
				--outputChatBox("Control Point marker created. Type: " .. markerType .. " Colsize: " .. colSize, 3)
				local m_test = getElementsByType("marker")
				local m_found = false
				for theKey,theMarker in ipairs(m_test) do
					if (theMarker == markerObj) then
						m_found = true
					end					
				end
				if (not m_found) then
				--	outputChatBox("ERROR: Control Point marker created but not found using getElementsByType(). Type: " .. markerType .. " Colsize: " .. colSize)						
				end
			end
			
			local radarArea = createRadarArea ( posX, posY, colSize * 20, colSize * 20,r, g, b, 100)
			
			setRadarAreaFlashing(radarArea, false)
			setElementData(cp, "teamwars_marker", markerObj)
			setElementData(cp, "teamwars_radar", radarArea)
			setElementData(cp, "teamwars_is_capturing", false)
			setElementData(cp, "teamwars_capture_team", false)
			setElementData(cp, "teamwars_capture_progress", false)
			setElementData(markerObj, "teamwars_cp", cp)
			

			
			-- Set owner of the capture point (false if 'neutral')
			setElementData(cp, "teamwars_owner", owningTeam) 				
			
			local teams = getChildren (cp, "teaminfo")
			local teamArr = {}
			for teamKey,team in ipairs(teams) do		
				local realTeam = getTeamFromName(getElementData(team, "name"))
				if (realTeam) then				
					
					teamArr[team] = {}
					setElementData(team, "teamwars_team", realTeam)
					
					-- Loop through all spawnpoints
					local spawnpoints = getChildren (team, "spawnpoint")
					for spawnpointKey,spawnpoint in ipairs(spawnpoints) do
						local x,y,z = getElementData(spawnpoint, "posX"), getElementData(spawnpoint, "posY"), getElementData(spawnpoint, "posZ")
						if (not x) then x = 0 end
						if (not y) then y = 0 end
						if (not z) then z = 0 end
						setElementPosition(spawnpoint, x, y, z)
						teamArr[team][#teamArr[team] + 1] = spawnpoint
					end
				end -- TODO what if else?
			end
			setElementData(cp, "teamwars_teamdata", teamArr) -- Store the list for easy access
		end
		--end
		local teams = getElementsByType ( "team" )
		
		if (table.getn( teams ) < 2 ) then
			outputDebugString("CP * Map needs atleast 2 teams to be playable.", 1 )
			return false -- Oh, oooh
		end
		
		for teamKey,teamValue in ipairs(teams) do
		--	Prepare capture blips		
			self.captureHouseBlips[teamValue] = {}
			
		--	Reset score
			setElementData( teamValue, "Score", 0 )
			setElementData( teamValue, "Captures", 0 )
			setElementData( teamValue, "Rounds Won", 0 )
			
		-- 	Extra 'info' display (Actually used for respawning countdown)
			local textRespawnTimeDisplay = textCreateDisplay ()
			local textRespawnTimeLabel = textCreateTextItem ("", 0.50, 0.50, 1, 255, 255, 255, 255, 2, "center", "center" )    
			textDisplayAddText(textRespawnTimeDisplay, textRespawnTimeLabel)
			
		-- 	Add it to the team table
			self.teamTable[teamValue] = {}
			self.teamTable[teamValue].respawnDisplay = textRespawnTimeDisplay
			self.teamTable[teamValue].respawnDisplayLabel = textRespawnTimeLabel
			
			outputDebugString("TeamWars: CP * Created respawn textDisplay and textItem for team " .. getTeamName ( teamValue ))
		end
		
	-- 	redifine pickups for custom typed ones
		local pickups = getElementsByType ( "pickup" )
		for k,pickup in ipairs(pickups) do
			local customType = getElementData(pickup, "customType")
			local respawnTime = getElementData(pickup, "respawn")
			local modelID = getElementData(pickup, "pickupModel")
			
			if (not respawnTime) then respawnTime = 30000 else respawnTime = tonumber(respawnTime) end
			if (customType) then
				if (not modelID) then
					if (customType == "refill") then
						modelID = 1271
					else
						modelID = 1239
					end
				else
					modelID = tonumber(modelID)
				end
				local x,y,z = getElementPosition(pickup)
				local createdPickup = createPickup(x, y, z, 3, modelID, respawnTime)
				setElementData(createdPickup, "respawn", respawnTime)
				setElementData(createdPickup, "pickupOwner", getElementData(pickup, "pickupOwner"))
				setElementData(createdPickup, "pickupModel", pickupModel)
				setElementData(createdPickup, "customType", customType)
				
				-- destroy the old pickup
				destroyElement(pickup)
			end
		end
		
		-- Loop through all players
		local players = getElementsByType( "player" )
		for k,player in ipairs(players) do
			setElementData( player, "Score", 0 )
			setElementData( player, "Captures", 0 )
			setElementData( player, "Rounds Won", 0 )
		end
		
		-- Initiate the round (respawn first time, ..)
		-- self:BeginRound()	
		
		-- Show the team selection to all players
		triggerClientEvent("onTeamWarsShowTeamSelection", Root, true)
		
		self.mapLoaded = true
		self.beginRoundTimer = getTickCount() + 1
	end

	function ModeCP:OnMapStop(source, startedMap)
		self.ModeBase:OnMapStop(source, startedMap)

	--	Clean up self.teamTable
		for team,arr in pairs(self.teamTable) do 
		
			if (self.teamTable[team].respawnDisplayLabel) then 
				-- Remove 'possible' observers
				local players = getElementsByType( "player" )
				for k,v in ipairs(players) do
					textDisplayRemoveObserver( self.teamTable[team].respawnDisplayLabel, v )
				end
				
				textDestroyTextItem(self.teamTable[team].respawnDisplayLabel)
				self.teamTable[team].respawnDisplayLabel = nil
			end

			if (self.teamTable[team].respawnDisplay) then 
				textDestroyDisplay(self.teamTable[team].respawnDisplay)
				self.teamTable[team].respawnDisplay = nil
			end
			
			-- for key,value in pairs(self.teamTable[team]) do 
				--	Todo, check for type and auto-free it
			-- end
			
			self.teamTable[team] = {}
		end
		
		self.teamTable = {}

		-- Clean up house blips		
		local teams = getElementsByType("team")
		for k, team in ipairs(teams) do
			local Markers = getElementsByType("marker")
			for markerKey,markerObj in ipairs(Markers) do
				-- Get our Capture Point from the marker
				local capturePoint = getElementData(markerObj, "teamwars_cp")
				if (isElement(capturePoint)) then
					if (isElement(self.captureHouseBlips[team][capturePoint])) then
						destroyElement(self.captureHouseBlips[team][capturePoint])
					end
				end
			end			
			self.captureHouseBlips[team] = {}
		end
		outputDebugString("Unloaded capture point blips.")
		
		-- Clean up markers and radar area's
		local capturepoints = getElementsByType("capturepoint")	
		for capturepointKey,CP in ipairs(capturepoints) do
			local Marker = self:GetCapturePointMarker(CP)
			local Radar = self:GetCapturePointRadar(CP)
			if (isElement(Marker)) then
				destroyElement(Marker)
			end
			if (isElement(Radar)) then
				destroyElement(Radar)
			end
		end
		outputDebugString("Unloaded markers and radar area's.")
		
		-- Clean up player blips and corona's
		local players = getElementsByType("player")
		for k, player in ipairs(players) do
			-- Destroy the 'player marker' if player has one
			local playerCorona = getElementData(player, "teamwars_player_corona")
			if ((playerCorona) and (isElement(playerCorona))) then
				if (not getElementData(playerCorona, "teamwars_cp")) then -- BUGFIX
					destroyElement(playerCorona)
					removeElementData(player, "teamwars_player_corona")
				end
			end

			destroyBlipsAttachedTo (player )
		end
		outputDebugString("Unloaded player blips and corona's.")

		self.mapLoaded = false
		outputDebugString("Map unloaded.")
	end
	
--	Misc events
	function ModeCP:OnTick()
		self.ModeBase:OnTick()

		if (not self.onTick100) then
			self.onTick100 = getTickCount() + 100
			self.onTick100Last = getTickCount()
		end
	
		local ticks = getTickCount()
		
		if ((self.beginRoundTimer) and (getTickCount() >= self.beginRoundTimer)) then
			self.beginRoundTimer = false
			self:BeginRound()
		end
		
		if ((self.respawnTimers) and (not self.beginRoundTimer) and (self.roundIsActive)) then
		--	Respawn timer
			local teams = getElementsByType ("team")
			for teamKey,team in ipairs(teams) do
				if (not self.respawnTimers[team]) then self.respawnTimers[team] = false end
			
				if (self.respawnTimers[team])  then
					if (getTickCount() > self.respawnTimers[team]) then
						-- Time to respawn baby!
						self.respawnTimers[team] = false
						
						local textRespawnTimeLabel = self.teamTable[team].respawnDisplayLabel
						textItemSetText(textRespawnTimeLabel, "") -- 'hide' the text
						
						self:RespawnTeam(team, true)
					else
						-- Not the time to respawn.. update the respawn 'counter'
						local secondsLeft = round((self.respawnTimers[team] - getTickCount()) / 1000, 0)
						local textRespawnTimeLabel = self.teamTable[team].respawnDisplayLabel
						textItemSetText(textRespawnTimeLabel, "Respawning in " .. secondsLeft .. " second(s).")			
					end
				end		
			end	
		end
		
		if (getTickCount() >= self.onTick100) then
			local timePassed = getTickCount() - self.onTick100Last -- Store how many time has passed
			self.onTick100Last = self.onTick100
			self.onTick100 = getTickCount() + 100
			
			if (self.roundIsActive) then
				-- Enforce limits
				local players = getElementsByType ( "player" )
				for playerKey,playerValue in ipairs(players) do
					local playerClass = getElementData(playerValue, "teamwars_class")
					if (playerClass) then
						local classInfo = self:GetClassInfo(playerClass)
						
						if (classInfo ~= false) then
							-- Check armour of players and enforce limits
							if (not isPlayerDead(playerValue)) then
								if (getPlayerArmor(playerValue) > INT(classInfo["maxArmor"])) then
									setPlayerArmor(playerValue, INT(classInfo["maxArmor"]))
								end
							end
							
							-- Check health of players and enforce limits
							if (not isPlayerDead(playerValue)) then
								if (getElementHealth(playerValue) > INT(classInfo["maxHealth"])) then
									setElementHealth(playerValue,INT( classInfo["maxHealth"]))
								end
							end
						end
					end
				end
				
				-- Check captures! (Loop through all markers)		
				-- TODO Loop through capture points instead?
				local markers = getElementsByType ("marker")
				for markerKey,Marker in ipairs(markers) do
					local CP = getElementData(Marker, "teamwars_cp")

					if (isElement(CP)) then -- its a capture point marker (or should be ;p)
						-- Get required objects
						local Owner = getElementData(CP, "teamwars_owner")
						local CappingTeam = self:GetCapturePointAttackTeam(CP)
						
						-- Get required variables
						local capturePointName = self:GetCapturePointName(CP)
						local captureProgress = self:GetCapturePointAttackProgress(CP)
						local captureIsBlocked = self:GetCapturePointAttackBlocked(CP)
						
						local playerList =self:GetCapturePointPlayers(CP)
						local captureTime = self:GetCapturePointTime(CP)
						
						local captureModifier = INT(getElementData(CP, "captureModifier")) -- TODO Make function for this						
						if (not captureModifier) then captureModifier = 1 end
						
						local modifier = 1 -- Was 0 before
						
						if (#playerList > 0) then
							local firstOne = true
							if ((CappingTeam) and (not captureIsBlocked)) then -- Someone is capping
								for playerKey, capPlayer in ipairs ( playerList ) do
									if (getPlayerTeam(capPlayer) == CappingTeam) then
										-- Found one
										local abilityCaptureModifier = getElementData(capPlayer, "ability_cp_capturemodifier")
										if (not abilityCaptureModifier) then abilityCaptureModifier = 1 end
										
										if (not firstOne) then
											modifier = modifier + (captureModifier * abilityCaptureModifier)
										else
											if (abilityCaptureModifier ~= 1) then
												modifier = modifier + (captureModifier * abilityCaptureModifier) -- Exception! :)
											end
										end
										firstOne = false										
									end
								end
								
								-- Should not modify the modifier for only 1 player so remove it once
								--modifier = modifier - captureModifier -- Done in the loop now :)
								
								captureProgress = captureProgress + (timePassed * modifier)
								
								self:SetCapturePointAttackProgress(CP, captureProgress)
								
								-- Send progress update		
								for playerKey, capPlayer in ipairs ( playerList ) do
									if (getPlayerTeam(capPlayer) == CappingTeam) then
										if (captureProgress < captureTime) then
											triggerClientEvent( capPlayer,  "onTeamWarsCustomEvent",  Root, "captureProgress", fakeElement(Marker), captureProgress, captureTime)								
										else
											triggerClientEvent( capPlayer,  "onTeamWarsCustomEvent",  Root, "captureProgress", fakeElement(Marker), false) -- Hide it			
										end
									end
								end
								
								-- If capture complete then .. 
								if (captureProgress >= captureTime) then
									self:CaptureCP(CP, CappingTeam)									
								end
							end				
						end
					end
				end
			end
		end
	end

	function ModeCP:OnPlayerDamage(source, attacker, weapon, bodypart, loss)
		self.ModeBase:OnPlayerDamage(source, attacker, weapon, bodypart, loss)

	end

	function ModeCP:OnPlayerJoin(source)
		self.ModeBase:OnPlayerJoin(source)
		--kickPlayer(source)
		setElementData( source, "Score", 0 )
		setElementData( source, "Captures", 0 )
		setElementData( source, "Rounds Won", 0 )
		
		-- Show the team selection to the joining player
		triggerClientEvent(source, "onTeamWarsShowTeamSelection", Root, true)
		--spawnPlayer (source, 0, 0, 0)
		--killPlayer(source)
	end



	function ModeCP:OnColShapeHit(colshape, player, matchedDimension)
		self.ModeBase:OnColShapeHit(colshape, player, matchedDimension)
		local source = colshape
		if (self.roundIsActive) then
			return 1
		end
	end
	
	function ModeCP:OnMarkerHit (marker, player, matchedDimension)
		self.ModeBase:OnMarkerHit(marker, player, matchedDimension)
		
		local source = marker
		
		if (self.roundIsActive) then
			-- Check for a Capture Point leave event
			if (not isPlayerDead(player)) then -- Dead check just for security ;)
				local CP = getElementData(marker, "teamwars_cp")
				if (isElement(CP)) then
					self:EnterCP(CP, player)
				end			
			end
		end
	end
	

	function ModeCP:OnMarkerLeave(marker, player, matchedDimension) 
	-- When a round is active
		if (self.roundIsActive) then
		
			-- Check for a Capture Point leave event
			if (not isPlayerDead(player)) then -- Dead check just for security ;)
				local CP = getElementData(marker, "teamwars_cp")
				if (isElement(CP)) then
					self:ExitCP(CP, player)
				end			
			end
			
		end		
	end
	
	function ModeCP:OnPickupUse(thePickup, thePlayer)
		self.ModeBase:OnPickupUse(thePickup, thePlayer)
		
	end

	function ModeCP:OnPlayerQuit(source, reason)
		self.ModeBase:OnPlayerQuit(source, reason)
		
		-- Destroy the 'player marker' if player had one
		local playerCorona = getElementData(source, "teamwars_player_corona")
		if ((playerCorona) and (isElement(playerCorona))) then		
			if (not getElementData(playerCorona, "teamwars_cp")) then -- BUGFIX
				destroyElement(playerCorona)
				-- setElementData(source, "teamwars_player_corona", nil) -- can we unset it this way?
				removeElementData(source, "teamwars_player_corona")
			end
		end
		
		if (self.roundIsActive) then
		
			-- Loop through all marks and emulate a leave if required
			local markers = getElementsByType("marker")
			for k,Marker in ipairs(markers) do
				local CP = getElementData(Marker, "teamwars_cp")
				
				if (isElement(CP))  then -- Its a capture point marker (or should be ;p)	
				
					-- Get list of players on the marker
					local playerList = self:GetCapturePointPlayers(CP)
					
					for playerKey, capPlayer in ipairs ( playerList ) do
						if (capPlayer == source) then
							-- fake trigger the leaving					
							self:ExitCP(CP, source) -- TODO Check for valid dimension?		
							break
						end
					end
				end
			end	
		end
		
		destroyBlipsAttachedTo (source )
	end

	function ModeCP:OnPlayerDead(source, ammo, attacker, weapon, bodypart)
		self.ModeBase:OnPlayerDead(source, ammo, attacker, weapon, bodypart)
		local attackingPlayer = attacker
		
		if ((isElement(attacker)) and (getElementType ( attacker ) == "vehicle" )) then
			attackingPlayer = getVehicleController ( attacker )			
		end
		
		-- Destroy the 'player marker' if player has one
		local playerCorona = getElementData(source, "teamwars_player_corona")
		if ((playerCorona) and (isElement(playerCorona))) then
			if (not getElementData(playerCorona, "teamwars_cp")) then -- BUGFIX
				destroyElement(playerCorona)
				--setElementData(source, "teamwars_player_corona", nil) -- can we unset it this way?
				removeElementData(source, "teamwars_player_corona")
			end
		end
			
		if (self.roundIsActive) then
			-- Messages handled by killmessages
			
			local playerTeam = getPlayerTeam(source)
			
			if (playerTeam) then
				if (not self.respawnTimers[playerTeam]) then 			
					self.respawnTimers[playerTeam] = getTickCount()  + (INT(get("teamwars_respawn", 10)) * 1000)
				end
				
				-- Show the respawn label
				if (self.teamTable[playerTeam].respawnDisplay) then
					textDisplayAddObserver(self.teamTable[playerTeam].respawnDisplay, source)
				end			
			end	
			

			
			-- Loop through all marks and emulate a leave if required
			local markers = getElementsByType("marker")
			for k,Marker in ipairs(markers) do
				local CP = getElementData(Marker, "teamwars_cp")
				
				if (isElement(CP))  then -- Its a capture point marker (or should be ;p)	
				
					-- Get list of players on the marker
					local playerList = self:GetCapturePointPlayers(CP)
					
					for playerKey, capPlayer in ipairs ( playerList ) do
						if (capPlayer == source) then
							-- fake trigger the leaving					
							self:ExitCP(CP, source) -- TODO Check for valid dimension?		
							break
						end
					end
				end
			end		

			-- Cleans up left behind progress bars (Work around tho :P)
			triggerClientEvent( source,  "onTeamWarsCustomEvent",  Root, "captureProgress", fakeElement(Marker), false)

			-- Give killer a point if teams are not equale
			if (attackingPlayer) then
				if (getPlayerTeam(attackingPlayer) ~= getPlayerTeam(source)) then
					local Score = getElementData(attackingPlayer, "Score")				
					setElementData(attackingPlayer, "Score", Score + 1)	
				elseif ((getPlayerTeam(attackingPlayer) == getPlayerTeam(source)) and (source ~= attackingPlayer)) then
					local Score = getElementData(attackingPlayer, "Score")				
					setElementData(attackingPlayer, "Score", Score - 1)	-- Remove a score
				end
			end
		end
		
		destroyBlipsAttachedTo (source )
	end

	function ModeCP:OnKeyInput( source, key, keyState)
		self.ModeBase:OnKeyInput(source, key, keyState)

	end
	
--	Custom functions
	function ModeCP:RespawnPlayers()
		local Players = getElementsByType("player")
		
		for k, Player  in ipairs(Players) do
			if (isPlayerDead(Player)) then 
				local classElement = getElementData(Player, "teamwars_selected_class")
				if (class) then
					local classInfo = getClassInfo(classElement)
					
					if (classInfo) then
						-- Respawn player
						self:SpawnPlayer(Player)
					end
				end
			end
		end
	end
	-- Called to start a new round
	function ModeCP:BeginRound()
		cleanElements(false) -- Clean the fakeElements cache
		self:ClearCapturePoints() -- Do that here :)
		self:ClearPlayers() -- Do that here also
		self:SlayPlayers() -- Slay all players
		
		-- Start respawn counters! (Or reset them)
		local teams = getElementsByType("team")
		for k, team in ipairs(teams) do
			self.respawnTimers[team] = getTickCount()  + 1 -- Respawn next ms

			local players = getPlayersInTeam(team)
			for p, Player in ipairs(players) do
				-- Show the respawn label
				if (self.teamTable[team].respawnDisplay) then
					textDisplayAddObserver(self.teamTable[team].respawnDisplay, Player)
				end	
			end
			
			self:UpdateCaptureHouseBlips()	
		end
		

		self.roundIsActive = true
		self:RespawnPlayers()		
	end
	
	-- Called to end current round
	function ModeCP:EndRound(skipRoundFinishedEvent)
		if (not skipRoundFinishedEvent) then
			triggerEvent("onRoundFinished", getResourceRootElement(getThisResource()))
		end
		self.roundIsActive = false
		self.beginRoundTimer = getTickCount() + INT(get("bonusTime", 5000)) -- time between end and start of round (or before start)
		
	-- Hides all progresses
		triggerClientEvent( "onTeamWarsCustomEvent",  Root, "captureProgress", false, false)
		
	-- Clean up house blips		
		local teams = getElementsByType("team")
		for k, team in ipairs(teams) do
			local Markers = getElementsByType("marker")
			for markerKey,markerObj in ipairs(Markers) do
				-- Get our Capture Point from the marker
				local capturePoint = getElementData(markerObj, "teamwars_cp")
				if (isElement(capturePoint)) then
					if (isElement(self.captureHouseBlips[team][capturePoint])) then
						destroyElement(self.captureHouseBlips[team][capturePoint])
					end
				end
			end			
			self.captureHouseBlips[team] = {}
		end
		
	end
	
	function ModeCP:UpdateCaptureHouseBlips()
	-- Clean up house blips		
		local teams = getElementsByType("team")
		for k, team in ipairs(teams) do
			local Markers = getElementsByType("marker")
			for markerKey,markerObj in ipairs(Markers) do
				-- Get our Capture Point from the marker
				local capturePoint = getElementData(markerObj, "teamwars_cp")
				if (isElement(capturePoint)) then
					if (isElement(self.captureHouseBlips[team][capturePoint])) then
						destroyElement(self.captureHouseBlips[team][capturePoint])
					end
				end
			end			
			self.captureHouseBlips[team] = {}
		end
				
	-- Create blips (green house : defend this / red house : capture this)	
		for k, team in ipairs(teams) do
			local Markers = getElementsByType("marker")
			for markerKey,markerObj in ipairs(Markers) do
				local posX, posY, posZ = getElementPosition(markerObj)
				-- Get our Capture Point from the marker
				local capturePoint = getElementData(markerObj, "teamwars_cp")
				if (isElement(capturePoint)) then -- If it is a CP marker, excluding the captured one
					if (self:GetCapturePointOwner(capturePoint) == team) then
						-- Check if the enemy can capture it						
						for k2, enemyTeam in ipairs(teams) do
							if (enemyTeam ~= team) then
								-- AN ENEMY!
								if (self:CanCaptureCP(capturePoint, enemyTeam)) then
									local blip = createBlip ( posX, posY, posZ, 31, 0.25, 0, 0, 0, 0, 255, team) -- Green house! DEFEND IT!
									setElementVisibleTo ( blip, Root, false )
									for k,v in ipairs(getPlayersInTeam(team)) do
										setElementVisibleTo ( blip, v, true )
									end
									self.captureHouseBlips[team][capturePoint] = blip
									-- TODO what to do with blip? :P
								end -- else : cannot capture it so no house :)
							end
						end
					else
						if (self:CanCaptureCP(capturePoint, team)) then
							local blip = createBlip ( posX, posY, posZ, 32, 0.25, 0, 0, 0, 0, 255, team) -- Red house! ATTACK IT!
							setElementVisibleTo ( blip, Root, false )
							for k,v in ipairs(getPlayersInTeam(team)) do
								setElementVisibleTo ( blip, v, true )
							end
							self.captureHouseBlips[team][capturePoint] = blip
							-- TODO what to do with blip? :P
						end -- else : cannot capture it so no house :)
					end
				end
			end
		end
	end
	
	-- Respawn a team
	function ModeCP:RespawnTeam(team, deadOnly)
		if (team) then
			local players = getPlayersInTeam(team)
			for playerKey, playerValue in ipairs ( players ) do
				local selectedClass = getElementData(playerValue, "teamwars_selected_class")
				local randomClass = getElementData(playerValue, "teamwars_random_class")

				if ((randomClass) or (selectedClass)) then
					if ((not deadOnly) or (isPlayerDead(playerValue))) then
						self:SpawnPlayer(playerValue)
					end
				end
			end
		end
	end	

	-- Respawn a single player
	function ModeCP:SpawnPlayer( player )
		if ( player ) then
			local team = getPlayerTeam( player )
			if (not team) then
				outputDebugString("Could not spawn player " .. getClientName(player) .. " since he does not belong to a team!")
				return false
			end
			local spawnpoints = getChildren ( team, "spawnpoint" )
			local r,g,b = getTeamColor( team )
			
			setPlayerNametagColor ( player, r, g, b )		
			
			-- Class stuff
			local classElement = getElementData(player, "teamwars_selected_class")
			local randomClass = getElementData(player, "teamwars_random_class")
			local playerTeam = getPlayerTeam(player)
			
			-- Check if player selected Random class
			if (randomClass) then 
				classElement = self:GetRandomClassElement()
			end
			
			local classInfo = getClassInfo(classElement)
			
			if (not classInfo) then
				outputDebugString("CP * Error getting class info. Cannot spawn.")
				return
			end
			-- Blips
			if ( true ) then -- make configurable? Also should attach a corona fyi :p
				local playerBlip = createBlipAttachedTo ( player, 0, 2, r, g, b, 255 )
				setElementData( playerBlip, "teamwars_player_blip", true )
				if ( true ) then -- make configurable? currently only team members can see it
					setElementVisibleTo ( playerBlip, Root, false )
					for k,v in ipairs(getPlayersInTeam(team)) do
						setElementVisibleTo ( playerBlip, v, true )
					end
					local cols = getElementsByType ( "teamwars_flag_colshape" )
					for k,v in ipairs(cols) do
						local colFlag = getElementData( v, "teamwars_team" )
						if ( colFlag ) then
							local colTeam = getElementData( v, "teamwars_team" )
							if ( colTeam == team ) then
								local colObject = getElementData( v, "teamwars_flag_object" )
								setElementVisibleTo ( getElementData( v, "teamwars_blip" ), player, true )
								setElementVisibleTo ( getElementData( v, "teamwars_blipTwo" ), player, true )
							end
						end
					end
				end
			end
			
			-- Coronas
			local x,y,z =  getElementPosition(player)
			local playerCorona = createMarker(x, y, z, "corona", 1.5, r, g, b, 100) -- was 125 alpha before

			attachElementToElement(playerCorona, player)
			local prevCorona = getElementData(player, "teamwars_player_corona")
			
			if (isElement(prevCorona)) then
				destroyElement(prevCorona)
			end
			
			setElementData(player, "teamwars_player_corona", playerCorona)
			--Hide to all
			setElementVisibleTo (playerCorona, Root, false)
			
			--Now make it visible to the team + other teams their spies
			local teams = getElementsByType ( "team" )
			for teamKey,teamValue in ipairs(teams) do
				local players = getPlayersInTeam(teamValue)
				
				for playerKey,playerValue in ipairs(players) do
					---if (playerValue ~= player then -- DEBUG use later
					if (teamValue == team) then
						if (playerValue ~= player) then
							setElementVisibleTo(playerCorona, playerValue, true)
						end
					else
					--	Get the class
						if (getElementData (playerValue, "teamwars_class") == "spy") then
							if (getElementData (playerValue, "teamwars_is_spying") == true) then						
								setElementVisibleTo(playerCorona, playerValue, true) -- it is a spy AND he is spying atm
							end
						end
					end
				end
			end
		
			--Now configure other player their coronas related to this player
			--TODO I think it sets stuff double sometimes.. maybe fix it.. might use extra BW :P
			local teams = getElementsByType ( "team" )
			for teamKey,teamValue in ipairs(teams) do
				local players = getPlayersInTeam(teamValue)
				
				for playerKey,playerValue in ipairs(players) do
					playerCorona = getElementData(playerValue, "teamwars_player_corona")
					
					if (isElement(playerCorona)) then
						if (teamValue == team) then
							if ((playerValue ~= player) and (playerCorona)) then
								setElementVisibleTo(playerCorona, player, true)
							end
						else		
							--Get the class
							if (getElementData (player, "class") == "spy") then
								if (getElementData (player, "teamwars_is_spying") == true) then						
									setElementVisibleTo(playerCorona, player, true) -- it is a spy AND he is spying atm -- TODO Add a team check ? (will we ever support multiple teams?)
								else
									setElementVisibleTo(playerCorona, playerValue, false)
								end
							else
								setElementVisibleTo(playerCorona, playerValue, false)
							end
						end
					end
				end
			end

			setElementData(player, "teamwars_class", classElement)
			--setElementData(player, "teamwars_classInfo", classInfo) -- Just for easy access, but is it needed?
			
			-- Search (and find) us a capture point (return false if not found)
			local capturepoints = getElementsByType("capturepoint")	
			local selectedSpawnpoint = false
			local highestImportance = 0
			local spawnpointList = {}
			
			for capturepointKey,cp in ipairs(capturepoints) do

				local cpOwner = getElementData(cp, "teamwars_owner")
				if ((cpOwner) and (cpOwner == playerTeam)) then	
	
					local teams = getChildren (cp, "teaminfo")
					local teamArr = {}
					for teamKey,team in ipairs(teams) do

						local realTeam = getTeamFromName(getElementData(team, "name"))
						if ((realTeam) and (realTeam == playerTeam)) then			
			
							local importance = INT(getElementData(team, "importance"))
							if (not importance) then importance = 0 end 

							if (importance > highestImportance) then
								highestImportance = importance
								spawnpointList = {}
							end
							
							if (importance >= highestImportance) then			
								local spawns = getChildren (team, "spawnpoint")
								for spawnKey,spawn in ipairs(spawns) do
									spawnpointList[#spawnpointList + 1] = spawn
								end
							end
						end -- TODO what if else?
					end
				end
			end
			if (#spawnpointList == 0) then
				outputChatBox("No spawnpoints left.", player)
				return false
			end
			local spawnpoint = spawnpointList[ math.random( 1, #spawnpointList ) ] 
			
			local x,y,z = getElementPosition(spawnpoint)
			local randx = getElementData(spawnpoint, "randx"); if (not randx) then randx = 0 end
			local randy = getElementData(spawnpoint, "randy"); if (not randy) then randy = 0 end
			local randz = getElementData(spawnpoint, "randz"); if (not randz) then randz = 0 end
		
			x = x + math.random(0, randx)
			y = y + math.random(0, randy)
			z = z + math.random(0, randz)
			
			
			-- TODO Apply MAX_HEALTH
			--setElementData(player, "teamwars_sprint_left", INT(classInfo["sprintTime"])) -- TODO Move to ModeBase
			
			spawnPlayer(player, x, y, z, getSpawnpointRotation(spawnpoint), INT(classInfo["skinID"]))
			
			-- setPlayerStat (player, 24, classInfo["MaxHealth"] * 5) -- DOES NOT WORK :(
			
			setElementHealth (player, INT(classInfo["startHealth"]))
			setPlayerArmor(player, INT(classInfo["startArmor"]))
			
			-- Give weapons
			-- loop -- giveWeapon ( player thePlayer, int weapon, [ int ammo=30, bool setAsCurrent=false ] )
			for weaponKey,weaponElement in pairs(getClassWeapons(classElement)) do 
				local weaponInfo = getClassWeaponInfo(weaponElement)
				giveWeapon(player, weaponInfo.ID, weaponInfo["startAmmo"], weaponInfo["default"])
			end
			
			--setCameraMode ( player, "player" )
			setCameraTarget( player, player )
			toggleAllControls ( player, true, true, false )
			
			if (self.teamTable[team].respawnDisplay) then
				textDisplayRemoveObserver(self.teamTable[team].respawnDisplay, player)
			end
			self:UpdateCaptureHouseBlips() -- VERY BAD - NEEDS UPDATE (costs traffic :/)
		end	
	end
		
	function ModeCP:OnClassSelection(player, className, randomSelect)
		self.ModeBase:OnClassSelection(player, className, randomSelect) -- This handles class selection
		
		if (not player) then return end
	
		local randomClass = getElementData(player, "teamwars_random_class")
		local selectedClass = getElementData(player, "teamwars_selected_class")
		local playerTeam = getPlayerTeam(player)
		
		if (playerTeam) then
		--	if (not self.respawnTimers[playerTeam]) then 			
		--		self.respawnTimers[playerTeam] = getTickCount()  + INT(get("teamwars_respawn", 10000))
		--	end
			
			-- Show the respawn label
		--	if (self.teamTable[playerTeam].respawnDisplay) then
		--		textDisplayAddObserver(self.teamTable[playerTeam].respawnDisplay, player)
		--	end		
			if ((not self.respawnTimers[team]) and (self.roundIsActive) and ((randomClass) or (selectedClass)))  then
				if (isPlayerDead(player)) then
					self:SpawnPlayer(player)
				end
			end
		end
		
	end
--	Setters
	function ModeCP:SetCapturePointRadar(CP, Radar)
		if (not isElement(CP)) then return false end
		return setElementData(CP, "teamwars_radar", Radar)
	end
	
	function ModeCP:SetCapturePointMarker(CP, Marker)
		if (not isElement(CP)) then return false end
		return setElementData(CP, "teamwars_marker", Marker)
	end
	
	function ModeCP:SetCapturePointOwner(CP, Owner)
		if (not isElement(CP)) then return false end
		return setElementData(CP, "teamwars_owner", Owner)
	end
	
	function ModeCP:SetCapturePointAttackTeam(CP, Team)
		if (not isElement(CP)) then return false end
		return setElementData(CP, "teamwars_capture_team", Team)
	end
	
	function ModeCP:SetCapturePointAttackProgress(CP, Progress)
		if (not isElement(CP)) then return false end
		return setElementData(CP, "teamwars_capture_progress", Progress)
	end
	
	function ModeCP:SetCapturePointAttackBlocked(CP, isBlocked)
		if (not isElement(CP)) then return false end
		return setElementData(CP, "teamwars_capture_block", isBlocked)
	end
	
	function ModeCP:SetCapturePointPlayers(CP, playerList)
		if (not isElement(CP)) then return false end
		return setElementData(CP, "teamwars_capture_players", playerList)
	end	
	
	-- Clean up capture points
	function ModeCP:ClearCapturePoints()
		local CPs = getElementsByType("capturepoint")
		for k, CP in ipairs(CPs) do
			local Marker = self:GetCapturePointMarker(CP)
			if (Marker) then
				local Owner = getElementData(CP, "owner")
				if (Owner == "") then Owner = false else Owner = getTeamFromName(Owner) end
				self:SetCapturePointAttackBlocked(CP, false)
				self:SetCapturePointAttackProgress(CP, false)
				self:SetCapturePointAttackTeam(CP, false)
				self:SetCapturePointOwner(CP, Owner)
				self:SetCapturePointPlayers(CP, {})
				Radar = self:GetCapturePointRadar(CP)
				local r, g, b = 255,255,255
				if (isElement(Owner)) then r, g, b = getTeamColor(Owner) end
				if ((isElement(Radar)) and getElementType(Radar) == "radararea") then
					setRadarAreaColor(Radar, r, g, b, 100)
					setRadarAreaFlashing(Radar, false)
				end
				if (Marker) then
					setMarkerColor(Marker, r, g, b, 100)
				end				
			end
		end
	end
	
	-- Clean up capture players
	function ModeCP:ClearPlayers()
		-- local Players = getElementsByType("player")
		-- for k, Player in ipairs(Players) do
			-- local className = getElementData(Player, "teamwars_class")
			-- if (className) then
				-- local classInfo = self:GetClassInfo(className)
				-- if (classInfo) then
					-- setElementData(Player, "teamwars_sprint_left", INT(classInfo["sprintTime"])) -- TODO Move to ModeBase				
				-- end
			-- end
		-- end
	end
	
--	Getters
	function ModeCP:GetCapturePointTime(CP)
		if (not isElement(CP)) then return false end
		local captureTime = getElementData(CP, "captureTime")
		if (not captureTime) then captureTime = 1 end

		return INT(captureTime)
	end

	-- Check if CappingTeam can capture given point or not
	function ModeCP:CanCaptureCP(CP, CappingTeam)
		if (not isElement(CP)) then return false end
		if (not isElement(CappingTeam)) then return false end
		
		-- Retrieve the required objects
		local Radar = self:GetCapturePointRadar(CP)
		local Marker = self:GetCapturePointMarker(CP)
		local Owner = self:GetCapturePointOwner(CP)
		if (Owner == CappingTeam) then return true end -- Already theirs
		
		-- Retrieve other info
		local r,g,b = getTeamColor(CappingTeam)
		local capturePointName = self:GetCapturePointName(CP)		
		local capturePointID = self:GetCapturePointID(CP)
		local requiredPoints = false

		-- Check if we CAN start capturing this CP! (check requires)
		-- Retrieve the teams their info
		local teamInfos = getChildren (CP, "teaminfo")
		
		-- Find this teams requirements to start capturing this CP
		for teamKey,teamInfo in ipairs(teamInfos) do
		
			-- Get the team object from the extracted teamInfo
			local realTeam = getTeamFromName(getElementData(teamInfo, "name"))
			
			if ((isElement(realTeam)) and (realTeam == CappingTeam)) then -- It is a valid element (TODO : Check for team as type ?)			
				requiredPoints = getElementData(teamInfo, "requires")
				break				
			end
		end
		
		-- If it has some requirements, validate it
		if ((requiredPoints) and (requiredPoints ~= "") and (requiredPoints ~= capturePointID)) then
			local canCapture = true
			local Markers = getElementsByType("marker")
			
			for markerKey,markerObj in ipairs(Markers) do
				-- Get our Capture Point from the marker
				local capturePoint = getElementData(markerObj, "teamwars_cp")
				
				if ((isElement(capturePoint)) and (capturePoint ~= CP)) then -- If it is a CP marker, excluding they captured one
					local baseID =  self:GetCapturePointID(capturePoint)
					if (baseID == requiredPoints) then
						-- Check if we can capture this point
						local currentOwner = self:GetCapturePointOwner(capturePoint)
						if (currentOwner ~= CappingTeam) then
							canCapture = false
							break
						end
					end
				end
			end
			
			if (not canCapture) then return false end -- Cannot capture!
		end
		
		return true
	end
	
	
	
	function ModeCP:IsCapturePointGoal(CP, Team)
		if (not isElement(CP)) then return false end
		if (not isElement(Team)) then return false end
		
		-- Retrieve the teams their info
		local teamInfos = getChildren (CP, "teaminfo")
		
		-- Find this teams requirements to start capturing this CP
		for teamKey,teamInfo in ipairs(teamInfos) do
			local isGoal = getElementData(teamInfo, "isGoal")
			
			if (isGoal) then
				-- Get the team object from the extracted teamInfo
				local realTeam = getTeamFromName(getElementData(teamInfo, "name"))
				
				if ((isElement(realTeam)) and (realTeam == Team)) then -- It is a valid element (TODO : Check for team as type ?)			
					return true		
				end
			end
		end
		
		return false
	end
	
	function ModeCP:GetCapturePointName(CP)
		if (not isElement(CP)) then return false end
		return getElementData(CP, "name")
	end
	
	function ModeCP:GetCapturePointMarker(CP)
		if (not isElement(CP)) then return false end
		return getElementData(CP, "teamwars_marker")
	end
	
	function ModeCP:GetCapturePointID(CP)
		if (not isElement(CP)) then return false end
		return getElementID(CP)
	end
	
	function ModeCP:GetCapturePointRadar(CP)
		if (not isElement(CP)) then return false end
		return getElementData(CP, "teamwars_radar")
	end
	
	function ModeCP:GetCapturePointMark(CP)
		if (not isElement(CP)) then return false end
		return getElementData(CP, "teamwars_marker")
	end
	
	function ModeCP:GetCapturePointOwner(CP)
		if (not isElement(CP)) then return false end
		return getElementData(CP, "teamwars_owner")
	end
	
	function ModeCP:GetCapturePointAttackTeam(CP)
		if (not isElement(CP)) then return false end
		return getElementData(CP, "teamwars_capture_team")
	end
	
	function ModeCP:GetCapturePointAttackProgress(CP)
		if (not isElement(CP)) then return false end
		return getElementData(CP, "teamwars_capture_progress")
	end
	
	function ModeCP:GetCapturePointAttackBlocked(CP)
		if (not isElement(CP)) then return false end
		return getElementData(CP, "teamwars_capture_block")
	end	
	
	function ModeCP:GetCapturePointPlayers(CP)
		if (not isElement(CP)) then return false end
		local playerList = getElementData(CP, "teamwars_capture_players")		
		if (not playerList) then playerList = {} end
		
		return playerList
	end	
	
	-- Trigger this when a player enters a CP
	function ModeCP:EnterCP(CP, Player)

		if (isElement(CP)) then -- It is a capture point marker (or should be ;p)
			-- Get required objects
			local playerTeam = getPlayerTeam(Player)
			local Owner = self:GetCapturePointOwner(CP)
			local CappingTeam = self:GetCapturePointAttackTeam(CP)
			
			-- Get required variables
			local capturePointName = self:GetCapturePointName(CP)
			local captureProgress = self:GetCapturePointAttackProgress(CP)
			local captureBlocked = self:GetCapturePointAttackBlocked(CP)

			-- Get list of players on the marker
			local playerList = self:GetCapturePointPlayers(CP)
			
			-- Add the player (since he entered it)	
			playerList[#playerList + 1 ] = Player	
			
			-- Update the list of players
			self:SetCapturePointPlayers(CP, playerList)
			
			-- Check and see if the player CAN capture (check if no capture is already going on!)
			if ((#playerList == 1) and (not captureBlocked) and (not captureProgress) and ((not Owner) or (Owner ~= playerTeam))) then -- Check if its a neutral point OR its current owner does not equal the players
				if (capturePointName) then -- Gives errors otherwise :/	
					self:StartCapturingCP(CP, playerTeam)
				end
			elseif ((#playerList > 1) and (not captureBlocked) and (not captureProgress) and ((not Owner) or (Owner ~= playerTeam))) then -- Check if its a neutral point OR its current owner does not equal the players
				if (capturePointName) then -- Gives errors otherwise :/	
					self:BlockCP(CP, playerTeam)
				end
			-- Check if another friendly player joins to help capturing			
			elseif ((#playerList > 1) and (captureProgress) and (CappingTeam) and (CappingTeam == playerTeam) and ((not Owner) or (Owner ~= playerTeam))) then
				if (capturePointName) then -- Gives errors otherwise :/
					local captureTime = self:GetCapturePointTime(CP)
					
					-- Send the current progress
					triggerClientEvent(Player, "onTeamWarsCustomEvent", Root, "captureProgress", fakeElement(marker), captureProgress, captureTime)	
				end
			-- Check if the player is blocking a capture
			elseif ((CappingTeam) and (CappingTeam ~= playerTeam) and (captureProgress) and ((not Owner) or (Owner == playerTeam))) then
				if (capturePointName) then -- Gives errors otherwise :/
					self:BlockCP(CP, playerTeam)
					
					-- Give blocker a point
					local blockScore = getElementData(Player, "Score")
					setElementData(Player, "Score", blockScore + 1)
				end
			end
		end
	end
	
	-- Trigger this when a player exists a CP (or on dead for example)
	function ModeCP:ExitCP(CP, Player)
		if ( not isElement(CP) ) then return false end
	
		-- Get required objects
		local playerTeam = getPlayerTeam(Player)
		local Owner = self:GetCapturePointOwner(CP)
		local Marker = self:GetCapturePointMarker(CP)
		
		-- Get required variables
		local capturePointName = self:GetCapturePointName(CP)		
		local captureProgress = self:GetCapturePointAttackProgress(CP)		
		local captureIsBlocked =  self:GetCapturePointAttackBlocked(CP)
		
		-- Get list of players on the marker
		local playerList =self:GetCapturePointPlayers(CP)	
		local playerCount, currentCount = #playerList, 1

		-- Remove the player if he is on the list
		for playerKey, capPlayer in ipairs ( playerList ) do
			if (capPlayer == Player) then
				table.remove(playerList, currentCount)
				break
			end
			currentCount = currentCount +1
		end
		
		-- Update the list of players
		self:SetCapturePointPlayers(CP, playerList)		
		
		-- Process the leaving of the capture point
		if (playerCount) then -- Had players on it (so it is to be considered valid)
			if (capturePointName) then -- For added safety				
				-- If there was progress and now the playerlist is empty, stop the capture
				if ((captureProgress) and (#playerList == 0)) then -- Stop capturing
					self:CancelCP(CP)		
					-- Still need to sent it to the Player, since he won't be on the playerList anymore
					triggerClientEvent(Player, "onTeamWarsCustomEvent",  Root, "captureProgress", fakeElement(Marker), false)					
				elseif ((captureIsBlocked) and (#playerList > 0)) then -- Still someone there, check if we have to start the capture again!
					local attackingTeam = false
					
					-- See if there is an attacking team
					for playerKey, capPlayer in ipairs ( playerList ) do
						if ((attackingTeam) and (attackingTeam ~= getPlayerTeam(capPlayer))) then
							attackingTeam = false
							break
						end
						
						attackingTeam = getPlayerTeam(capPlayer)
					end
					
					if ((attackingTeam) and (attackingTeam ~= Owner)) then -- Ok, all players on it have equal team! Restart the capture 
						self:StartCapturingCP(CP, attackingTeam) -- Start the capture						
					else					
						self:CancelCP(CP)							
					end
				--else
					-- Still need to sent it to the Player, since he won't be on the playerList anymore
					triggerClientEvent(Player, "onTeamWarsCustomEvent",  Root, "captureProgress", fakeElement(Marker), false)						
				end
			end
		end
	end

	-- Trigger this to start capturing a capturepoint
	function ModeCP:StartCapturingCP(CP, CappingTeam)
		if (not isElement(CP)) then return false end
		if (not isElement(CappingTeam)) then return false end

		-- Retrieve the required objects
		local Radar = self:GetCapturePointRadar(CP)
		local Marker = self:GetCapturePointMarker(CP)
		local Owner = self:GetCapturePointOwner(CP)
		if (Owner == CappingTeam) then return true end -- Already theirs
		
		-- Retrieve other info
		local r,g,b = getTeamColor(CappingTeam)
		local capturePointName = self:GetCapturePointName(CP)		
		local capturePointID = self:GetCapturePointID(CP)
		local requiredPoints = false

		-- Check if we CAN start capturing this CP! (check requires)
		-- Retrieve the teams their info
		local teamInfos = getChildren (CP, "teaminfo")
		
		-- Find this teams requirements to start capturing this CP
		for teamKey,teamInfo in ipairs(teamInfos) do
		
			-- Get the team object from the extracted teamInfo
			local realTeam = getTeamFromName(getElementData(teamInfo, "name"))
			
			if ((isElement(realTeam)) and (realTeam == CappingTeam)) then -- It is a valid element (TODO : Check for team as type ?)			
				requiredPoints = getElementData(teamInfo, "requires")
				break				
			end
		end
		
		-- If it has some requirements, validate it
		if ((requiredPoints) and (requiredPoints ~= "") and (requiredPoints ~= capturePointID)) then
			local canCapture = true
			local Markers = getElementsByType("marker")
			
			for markerKey,markerObj in ipairs(Markers) do
				-- Get our Capture Point from the marker
				local capturePoint = getElementData(markerObj, "teamwars_cp")
				
				if ((isElement(capturePoint)) and (capturePoint ~= CP)) then -- If it is a CP marker, excluding they captured one
					local baseID =  self:GetCapturePointID(capturePoint)
					if (baseID == requiredPoints) then
						-- Check if we can capture this point
						local currentOwner = self:GetCapturePointOwner(capturePoint)
						if (currentOwner ~= CappingTeam) then
							canCapture = false
							break
						end
					end
				end
			end
			
			if (not canCapture) then return false end -- Cannot capture!
		end
		
		-- Update the Radar
		setRadarAreaFlashing(Radar, true) 		-- Turn off blinking			
		setRadarAreaColor(Radar, r, g, b , 100) 	-- Set the color to the team who captured the point

		-- Announce the starting of the capture
		if (self:GetCapturePointAttackTeam(CP) == CappingTeam) then
			self:Announce(r, g, b, getTeamName(CappingTeam) .. " proceeded with capturing the " .. capturePointName .. ".", 3000)	
		else	
			self:Announce(r, g, b, getTeamName(CappingTeam) .. " started capturing the " .. capturePointName .. ".", 3000)
		end

		local captureTime = self:GetCapturePointTime(CP)

		if (self:GetCapturePointAttackTeam(CP) ~= CappingTeam) then
			self:SetCapturePointAttackTeam(CP, CappingTeam)
			self:SetCapturePointAttackProgress(CP, 1)			
		end	
		
		self:SetCapturePointAttackBlocked(CP, false)
		
		-- Show the progress bar
		local playerList = self:GetCapturePointPlayers(CP)

		for k, selectedPlayer in ipairs ( playerList ) do
			--local playerTeam = getPlayerTem(selectedPlayer)
			--if ((playerTeam) and (playerTeam == CappingTeam)) then
				triggerClientEvent( selectedPlayer,  "onTeamWarsCustomEvent",  Root, "captureProgress", fakeElement(Marker), 1, captureTime)
				self:DisableSpawnProtection(selectedPlayer) -- TODO Make more efficient!
			--end
		end
	end	

	
	-- Trigger this to capture a CP
	function ModeCP:CaptureCP(CP, CappingTeam)
		if (not isElement(CP)) then return false end
		if (not isElement(CappingTeam)) then return false end
		
		-- Retrieve the required objects
		local Radar = self:GetCapturePointRadar(CP)
		local Marker = self:GetCapturePointMarker(CP)
		local Markers = getElementsByType("marker")
		
		-- Retrieve other info
		local r,g,b = getTeamColor(CappingTeam)
		local capturePointName = self:GetCapturePointName(CP)		
		local capturePointID = self:GetCapturePointID(CP)
		
		-- Set the owner
		self:SetCapturePointOwner(CP, CappingTeam)
		
		-- Unset attack info
		self:SetCapturePointAttackTeam(CP, false)
		self:SetCapturePointAttackProgress(CP, false)
		self:SetCapturePointAttackBlocked(CP, false)

		-- Update the Radar
		setRadarAreaFlashing(Radar, false) 		-- Turn off blinking			
		setRadarAreaColor(Radar, r, g, b , 100) 	-- Set the color to the team who captured the point
		
		-- Update the Marker
		setMarkerColor(Marker, r, g, b, 100)	

		-- Announce the capture
		self:Announce(r, g, b, getTeamName(CappingTeam) .. " captured the " .. capturePointName .. ".", 3000)
		
		-- Hide the progress bar
		local playerList = self:GetCapturePointPlayers(CP)

		--Destroy house blip
		-- if (isElement(self.captureHouseBlips[CappingTeam][CP])) then
			-- destroyElement(self.captureHouseBlips[CappingTeam][CP])
			-- self.captureHouseBlips[CappingTeam][CP] = nil
		-- end
		
		--Recreate new one (if valid)
		--Check if the enemy can capture it	
		-- local teams = getElementsByType("team")					
		-- for k2, enemyTeam in ipairs(teams) do
			-- if (enemyTeam ~= CappingTeam) then
				--AN ENEMY!
				-- if (self:CanCaptureCP(CP, enemyTeam)) then
					-- local posX, posY, posZ = getElementPosition(Marker)
					-- local blip = createBlip ( posX, posY, posZ, 31, 0.25, 0, 0, 0, 0, 255, CappingTeam) -- Green house! DEFEND IT!
					-- self.captureHouseBlips[CappingTeam][CP] = blip
				-- end -- else : cannot capture it so no house :)
			-- end
		-- end

		
		for k, selectedPlayer in ipairs ( playerList ) do
			triggerClientEvent( selectedPlayer,  "onTeamWarsCustomEvent",  Root, "captureProgress", fakeElement(Marker), false)
		end

		-- Loop through all markers and check if we have to cancel/start another capture (dependency)
		for markerKey,markerObj in ipairs(Markers) do
			-- Get our Capture Point from the marker
			local capturePoint = getElementData(markerObj, "teamwars_cp")
			

			if ((isElement(capturePoint)) and (capturePoint ~= CP)) then -- If it is a CP marker, excluding the captured one


				-- Retrieve the teams their info
				local teamInfos = getChildren (capturePoint, "teaminfo")
				
				-- loop through it
				for teamKey,teamInfo in ipairs(teamInfos) do

					-- Get the team object from the extracted teamInfo
					local realTeam = getTeamFromName(getElementData(teamInfo, "name"))
					
					if (isElement(realTeam)) then -- It is a valid element (TODO : Check for team as type ?)
		
						local requiredBases = getElementData(teamInfo, "requires")
						
						-- Check if the captured CP was a dependency (requirement) of another CP
						if (requiredBases == capturePointID) then -- TODO Add support for coma seperated list of bases

							local capturingTeam = self:GetCapturePointAttackTeam(capturePoint)
							
							if (isElement(capturingTeam)) then 	
				
								-- Someone is capturing it, check if it should be blocked..
								
								if (capturingTeam ~= CappingTeam) then

									-- The team who just captured the point does not equal the ones who are caping the other cp
									
									-- Destroy house blip (since it cannot capture anymore)
									if (isElement(self.captureHouseBlips[capturingTeam][capturePoint])) then
										destroyElement(self.captureHouseBlips[capturingTeam][capturePoint])
										self.captureHouseBlips[capturingTeam][capturePoint] = nil
									end
									
									-- Unset attack info
									self:SetCapturePointAttackTeam(capturePoint, false)
									self:SetCapturePointAttackProgress(capturePoint, false)
									self:SetCapturePointAttackBlocked(capturePoint, false)
									
									-- Cancel the progress bar
									local playerList = self:GetCapturePointPlayers(capturePoint)

									for k, selectedPlayer in ipairs ( playerList ) do
										triggerClientEvent( selectedPlayer,  "onTeamWarsCustomEvent",  Root, "captureProgress", fakeElement(markerObj), false)
									end
								end									
							else
								-- Check if we have to start a capture
								local playerList = self:GetCapturePointPlayers(capturePoint)
								local bHasCappingTeam = false
								local bHasOtherTeam = false
								for k, selPlayer in ipairs(playerList) do
									if (not isPlayerDead(selPlayer)) then
										if (CappingTeam == getPlayerTeam(selPlayer)) then
											bHasCappingTeam= true
										else
											bHasOtherTeam = getPlayerTeam(selPlayer)
										end
									end
								end

							
								if ((bHasCappingTeam) and (bHasOtherTeam)) then
									-- Block
									self:BlockCP(capturePoint, bHasOtherTeam)
								elseif (bHasCappingTeam) then
									-- Start capture
									self:StartCapturingCP(capturePoint, CappingTeam)								
								end
							end
						end
					end
				end
			end
		end
		
		local currentPoints = getElementData(CappingTeam, "Captures")
		setElementData(CappingTeam, "Captures", currentPoints + 1)
		
		-- Give all capping players a point
		local playerList = self:GetCapturePointPlayers(CP)
		
		for k, player in ipairs ( playerList ) do
			if ((not isPlayerDead(player)) and (getPlayerTeam(player) == CappingTeam)) then
				local currentPoints = getElementData(player, "Captures")				
				setElementData(player, "Captures", currentPoints + 1)	
				local Score = getElementData(player, "Score")				
				setElementData(player, "Score", Score + 5)	
			end
			
			self:DisableSpawnProtection(player) -- TODO Make more efficient!
		end
			
		-- Check if it was the goal capture point
		if (self:IsCapturePointGoal(CP, CappingTeam)) then
			local currentPoints = getElementData(CappingTeam, "Rounds Won")
			setElementData(CappingTeam, "Rounds Won", currentPoints + 1)
			
			local wonPlayers = getPlayersInTeam(CappingTeam)

			for k, wonPlayer in ipairs ( wonPlayers ) do
				currentPoints = getElementData(wonPlayer, "Rounds Won")
				setElementData(wonPlayer, "Rounds Won", currentPoints + 1)
			end
			local r, g, b = getTeamColor(CappingTeam)
			self:Announce(r, g, b, getTeamName(CappingTeam) .. " won this round. Next round will start shortly.", 5000)
			self:EndRound()
			
			return -- So the update capture house blips isnt called :)
		end		
		self:UpdateCaptureHouseBlips()
	end	
	-- Trigger this to cancel a CP capture
	function ModeCP:CancelCP(CP)
		if (not isElement(CP)) then return false end
		
		-- Retrieve the required objects
		local Owner = self:GetCapturePointOwner(CP)
		local CappingTeam = self:GetCapturePointAttackTeam(CP)
		local Radar = self:GetCapturePointRadar(CP)
		local Marker = self:GetCapturePointMarker(CP)
		local Markers = getElementsByType("marker")
		
		-- Retrieve other info
		local r,g,b = 255, 255, 255
		-- If we DO have an owner, extract the colors
		if (isElement(Owner)) then r,g,b = getTeamColor(Owner) end
		
		local capturePointName = self:GetCapturePointName(CP)		
			
		-- Unset attack info
		self:SetCapturePointAttackTeam(CP, false)
		self:SetCapturePointAttackProgress(CP, false)
		self:SetCapturePointAttackBlocked(CP, false)

		-- Update the Radar
		setRadarAreaFlashing(Radar, false) 		-- Turn off blinking			
		setRadarAreaColor(Radar, r, g, b , 100) 	-- Set the color to team owner
		
		-- Update the Marker
		setMarkerColor(Marker, r, g, b, 100)	

		-- Announce the cancel (is this needed?)
		if (CappingTeam) then
			local r,g,b = getTeamColor(CappingTeam)
			self:Announce(r, g, b, getTeamName(CappingTeam) .. " stopped capturing the " .. capturePointName .. ".", 3000)
		end
		
		-- Hide the progress bar
		local playerList = self:GetCapturePointPlayers(CP)

		for k, selectedPlayer in ipairs ( playerList ) do
			triggerClientEvent( selectedPlayer,  "onTeamWarsCustomEvent",  Root, "captureProgress", fakeElement(Marker), false)
		end
	end
	
	-- Trigger this to block a CP capture
	function ModeCP:BlockCP(CP, BlockingTeam)
		if (not isElement(CP)) then return false end
		
		-- Retrieve the required objects
		local Owner = self:GetCapturePointOwner(CP)
		local CappingTeam = self:GetCapturePointAttackTeam(CP)
		local Radar = self:GetCapturePointRadar(CP)
		local Marker = self:GetCapturePointMarker(CP)
		local Markers = getElementsByType("marker")
		
		-- Retrieve other info
		local r,g,b = 255, 255, 255
		-- If we DO have an owner, extract the colors
		if (isElement(Owner)) then r,g,b = getTeamColor(Owner) end
		
		local capturePointName = self:GetCapturePointName(CP)		
			
		-- Unset attack info
		--self:SetCapturePointAttackTeam(CP, false)
		--self:SetCapturePointAttackProgress(CP, false)
		self:SetCapturePointAttackBlocked(CP, true)

		-- Update the Radar
		setRadarAreaFlashing(Radar, false) 		-- Turn off blinking			
		setRadarAreaColor(Radar, r, g, b , 100) 	-- Set the color to team owner
		
		-- Update the Marker
		setMarkerColor(Marker, r, g, b, 100)	

		-- Announce the block
		if ((isElement(CappingTeam)) and (isElement(BlockingTeam))) then
			self:Announce(r, g, b, getTeamName(BlockingTeam) .. " blocked " .. getTeamName(CappingTeam) .. " from capturing the " .. capturePointName .. ".", 3000)
		end
		
		-- Update the progress bar
		local playerList = self:GetCapturePointPlayers(CP)

		for k, selectedPlayer in ipairs ( playerList ) do
			triggerClientEvent( selectedPlayer,  "onTeamWarsCustomEvent",  Root, "captureProgress", fakeElement(Marker), -1) -- -1 => blocked
			self:DisableSpawnProtection(selectedPlayer) -- TODO Make more efficient!
		end
	end
	

