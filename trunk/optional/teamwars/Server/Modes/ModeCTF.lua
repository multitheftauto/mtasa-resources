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

$Id: ModeCTF.lua 32 2007-12-10 01:37:43Z sinnerg $
]]

	ModeCTF = class('ModeCTF', ModeBase)
	
--	Mode related events
	function ModeCTF:OnModeStart()	
		self.ModeBase:OnModeStart()
		
		self.teamTable = {}			
		self.respawnTimers = {}
		self:Announce(0, 0, 255, "Welcome to Team Wars!\nMode: Capture The Flag", 10000)
	end

	function ModeCTF:OnModeStop()
		self.ModeBase:OnModeStop()
		
		-- Loop through all arrays and clean up
		self.respawnTimers = nil
		
		--
		outputDebugString("TeamWars: CTF Mode Stopped.")
	end
	
--	Map related events
	function ModeCTF:OnMapStart(source, startedMap)
		self.ModeBase:OnMapStart(source, startedMap)
		
		self.teamTable = {}			
		self.respawnTimers = {}

		local teams = getElementsByType ( "team" )
		
		if (table.getn( teams ) <2 ) then
			outputDebugString("CTF * Map needs atleast 2 teams to be playable.", 1 )
			return
		end
		
		for teamKey,teamValue in ipairs(teams) do
			local flags = getChildren ( teamValue, "flag" )
			local spawnpoints = getChildren ( teamValue, "spawnpoint" )	
			
		-- 	Link the team to the spawn point 
			for spawnpointKey,spawnpointValue in ipairs(spawnpoints) do
				setElementData( spawnpointValue, "teamwars_team", teamValue )
				local x,y,z = getElementData(spawnpointValue, "posX"), getElementData(spawnpointValue, "posY"), getElementData(spawnpointValue, "posZ")
				if (not x) then x = 0 end
				if (not y) then y = 0 end
				if (not z) then z = 0 end
				setElementPosition(spawnpointValue, x, y, z)
			end
			
			local r,g,b = getTeamColor( teamValue )
			

		-- 	Some more checks (TODO - Handling of more then 1 flag?)
			if ( #flags < 1 ) then
				outputDebugString("CTF * Each team must have atleast one flag.", 1 )
				return
			elseif ( #spawnpoints < 1) then
				outputDebugString("CTF * Each team must have atleast one spawnpoint.", 1 )
				return
			end
			
		--	Retrieve camera location
			local camera = getElementsByType( "camera" )
			if (camera) then
				self.cameraPosX, self.cameraPosY, self.cameraPosZ, self.cameraLookX, self.cameraLookY, self.cameraLookZ = tonumber(getElementData( camera[1], "posX" )), tonumber(getElementData( camera[1], "posY" )), tonumber(getElementData( camera[1], "posZ" )), tonumber(getElementData( camera[1], "lookX" )), tonumber(getElementData( camera[1], "lookY" )), tonumber(getElementData( camera[1], "lookZ" ))
			end
			if ( not self.cameraPosX ) or ( not self.cameraPosY ) or ( not self.cameraPosZ ) or ( not self.cameraLookX ) or ( not self.cameraLookY ) or ( not self.cameraLookZ ) then
				local flagss = getElementsByType( "flag" )
				local xi, yi, zi = 0, 0, 0
				for p,f in ipairs(flagss) do
					xi = xi + getElementData( f, "posX" )
					yi = yi + getElementData( f, "posY" )
					zi = zi + getElementData( f, "posZ" )
				end
				xi, yi, zi = xi/#flagss, yi/#flagss, zi/#flagss
				self.cameraPosX, self.cameraPosY, self.cameraPosZ, self.cameraLookX, self.cameraLookY, self.cameraLookZ = xi, yi, zi, xi, yi, zi
				outputDebugString( "CTF * Cameras are set wrong. Defaulting to " .. xi .. ", " .. yi .. ", " .. zi .. ".", 2 )
			end
			
		-- 	Spawn flags ?
			for flagKey,flagValue in ipairs(flags) do			
				local x,y,z = tonumber( getElementData ( flagValue, "posX" ) ), tonumber( getElementData ( flagValue, "posY" ) ), tonumber( getElementData ( flagValue, "posZ" ) )
				local object = createObject( 2993, x, y, z )		
				local marker = createMarker( x, y, z, "arrow", 2, r, g, b, 255 )
				local col = createColSphere( x, y, z, 1 )
				local col2 = createColSphere( x, y, z, 1 ) -- Flag capture point
				local sblip = createBlip ( x, y, z, 0, 3, r, g, b, 25 )		
				
				setElementData(col, "teamwars_type", "flag_col")
				setElementData(col2, "teamwars_type", "cp_col")
				
			-- 	Create the 'capture points'
				local capPoint = createMarker(x, y, z, "corona", 2, r, g, b, 200) 
				setElementData( col, "teamwars_cp_corona", capPoint)
				
				if ( true ) then -- Make this configurable? was TFC_CTF_Blips
					local blip = createBlipAttachedTo ( object, 56, 1 )
					local blipTwo = createBlipAttachedTo ( object, 0, 2, r, g, b, 255 )
					setElementData( col, "teamwars_blip", blip )
					setElementData( col, "teamwars_blipTwo", blipTwo )
					if ( false ) then
						setElementVisibleTo ( blip, Root, false )
						setElementVisibleTo ( blipTwo, Root, false )
					end
				end
				
				setElementData( col, "teamwars_flag_object", object )
				setElementData( col, "teamwars_flag_element", flagValue )
				setElementData( col, "teamwars_flag_marker", marker )
				-- setElementData( col, "teamwars_cp_blip", sblip )
				setElementData( col, "teamwars_team", teamValue )
				setElementData( col2, "teamwars_team", teamValue )
				setElementData( col, "teamwars_cp_blip", sblip )
				
			-- 	Set flag info
				setElementData( flagValue, "teamwars_flag_status", 0 ) -- 0 == in base / 1 == on ground / 2 == someone has it
				setElementData( flagValue, "teamwars_flag_colshape", col )
			end
			
		--	Reset score
			setElementData( teamValue, "score", 0 )
			setElementData( teamValue, "captures", 0 )
			
		-- 	Extra 'info' display (Actually used for respawning countdown)
			local textRespawnTimeDisplay = textCreateDisplay ()
			local textRespawnTimeLabel = textCreateTextItem ("", 0.50, 0.50, 1, 255, 255, 255, 255, 2, "center", "center" )    
			textDisplayAddText(textRespawnTimeDisplay, textRespawnTimeLabel)
			
		-- 	Add it to the team table
			self.teamTable[teamValue] = {}
			self.teamTable[teamValue].respawnDisplay = textRespawnTimeDisplay
			self.teamTable[teamValue].respawnDisplayLabel = textRespawnTimeLabel
			
			outputDebugString("TeamWars: CTF * Created respawn textDisplay and textItem for team " .. getTeamName ( teamValue ))
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
			setElementData(player, "teamwars_flag_colshape", nil) 
		end
		
		-- Initiate the round (respawn first time, ..)
		self:BeginRound()	
		
		-- Show the team selection to all players
		triggerClientEvent("onTeamWarsShowTeamSelection", Root, true)
	end

	function ModeCTF:OnMapStop(source, startedMap)
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
	end
	
--	Misc events
	function ModeCTF:OnTick()
		self.ModeBase:OnTick()

		if (not self.onTick100) then
			self.onTick100 = getTickCount() + 100
		end
	
		local ticks = getTickCount()
		
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
					
					self:RespawnTeam(team)
				else
					-- Not the time to respawn.. update the respawn 'counter'
					local secondsLeft = round((self.respawnTimers[team] - getTickCount()) / 1000, 0)
					local textRespawnTimeLabel = self.teamTable[team].respawnDisplayLabel
					textItemSetText(textRespawnTimeLabel, "Respawning in " .. secondsLeft .. " second(s).")			
				end
			end		
		end	
		
		if (getTickCount() >= self.onTick100) then
			self.onTick100 = getTickCount() + 100
			
			if (self.roundIsActive) then
				local players = getElementsByType ( "player" )
				for playerKey,playerValue in ipairs(players) do
					local playerClass = getElementData(playerValue, "teamwars_class")
					if (playerClass) then
						local classInfo = self:GetClassInfo(playerClass)
						
						-- Check sprint status and disable if needed
						local sprintTime = INT(classInfo["stats"]["sprintTime"])
						local sprintLeft = getElementData(playerValue, "teamwars_sprint_left")				
						local isSprinting = getElementData(playerValue, "teamwars_is_sprinting")
						local oldSprintLeft = sprintLeft
						if (not sprintLeft) then 
							sprintLeft = sprintTime 
							setElementData(playerValue, "teamwars_sprint_left", sprintLeft)
						end
						if (sprintTime == -1) then
							if (not isControlEnabled(playerValue, "sprint")) then -- If we can always sprint, enable it if not yet so
								toggleControl (playerValue, "sprint", true)
								sprintLeft = -1
								setElementData(playerValue, "teamwars_sprint_left", sprintLeft)
							end
						elseif (sprintTime == 0) then
							if (isControlEnabled(playerValue, "sprint")) then -- If we can never sprint, disable it if not yet so
								toggleControl (playerValue, "sprint", false)
								sprintLeft = 0
								setElementData(playerValue, "teamwars_sprint_left", sprintLeft)
							end
						else
							-- Check status
							if (getControlState(playerValue, "sprint")) then
								if (isSprinting) then
									-- running
									sprintLeft = sprintLeft - 0.05						
								else
									-- started running
									sprintLeft = sprintLeft - 0.50 -- Remove half a second
									setElementData(playerValue, "teamwars_is_sprinting", true)
								end
							else
								if (isSprinting) then							
									setElementData(playerValue, "teamwars_is_sprinting", false)
								end
								
								-- not running
								sprintLeft = sprintLeft + 0.05
							end
							if (sprintLeft > sprintTime) then
								sprintLeft = sprintTime
							end
							
							if ((sprintLeft < 0) and (sprintLeft ~= -1)) then
								sprintLeft = 0
								toggleControl (playerValue, "sprint", false)
							elseif ((sprintLeft > 1.5) and (not isControlEnabled(playerValue, "sprint"))) then
								toggleControl (playerValue, "sprint", true) -- Reenable sprint since we stored 1.5 sec of run					
							end
							
							if (sprintLeft ~= oldSprintLeft) then
								setElementData(playerValue, "teamwars_sprint_left", sprintLeft)
							end
						end
						
						-- Check armour of players and enforce limits
						if (not isPedDead(playerValue)) then
							if (getPedArmor(playerValue) > INT(classInfo["stats"]["maxArmor"])) then
								setPlayerArmour(playerValue, INT(classInfo["stats"]["maxArmor"]))
							end
						end
						
						-- Check health of players and enforce limits
						if (not isPedDead(playerValue)) then
							if (getElementHealth(playerValue) > INT(classInfo["stats"]["maxHealth"])) then
								setElementHealth(playerValue,INT( classInfo["stats"]["maxHealth"]))
							end
						end
					end
				end
			
			end
		end
	end

	function ModeCTF:OnPlayerDamage(source, attacker, weapon, bodypart, loss)
		self.ModeBase:OnPlayerDamage(source, attacker, weapon, bodypart, loss)
		
	end

	function ModeCTF:OnPlayerJoin(source)
		self.ModeBase:OnPlayerJoin(source)
		
		setElementData( source, "score", 0 )
		setElementData( source, "captures", 0 )
	end



	function ModeCTF:OnColShapeHit(colshape, player, matchedDimension)
		self.ModeBase:OnColShapeHit(colshape, player, matchedDimension)
		local source = colshape
		if (self.roundIsActive) then
			if ( getPlayerName( player ) ~= false ) then -- no idea why it would need this, but ctf uses this so.. ;p
				local colType = getElementData(source, "teamwars_type")
				if ((colType) and (colType == "flag_col")) then 
					
					local playerTeam = getPlayerTeam( player )
					local playerCol = getElementData( player, "teamwars_flag_colshape" )
					local colObject = getElementData( source, "teamwars_flag_object" )
					local colFlag = getElementData( source, "teamwars_flag_element" )
					local colMarker = getElementData( source, "teamwars_flag_marker" )
					local colTeam = getElementData( source, "teamwars_team" )
					local r,g,b = getTeamColor ( playerTeam ) 	
					
					if (( playerTeam == colTeam ) and (colFlag)) then

						local x,y,z = tonumber( getElementData ( colFlag, "posX" ) ), tonumber( getElementData ( colFlag, "posY" ) ), tonumber( getElementData ( colFlag, "posZ" ) )
						local x2,y2,z2 = getElementPosition( colObject )
						x1,y1,z1 = math.ceil(x),math.ceil(y),math.ceil(z)
						x2,y2,z2 = math.ceil(x2),math.ceil(y2),math.ceil(z2)
						if (( x1 ~= x2) or ( y1 ~= y2 ) or ( z1 ~= z2 )) then
							-- Dont allow returns for now (make it a map option?)
							if (self.optionCanReturn) then
								detachElements ( colObject, player )
								detachElements ( colMarker, player )
								setElementPosition( source, x, y, z )
								setElementPosition( colObject, x, y, z )
								setElementPosition( colMarker, x, y, z )
								self:Announce ( r, g, b, getPlayerName( player ) .. " returned the " .. getTeamName( colTeam ) .. " teams' " .. getElementData( colFlag, "name" ) .. "!", 4000 )
								setElementData( playerColFlag, "teamwars_flag_status", 0 )-- 0 - back in base
								setElementData( playerColFlag, "teamwars_flag_return", false )
								setElementData(player, "teamwars_flag_colshape", nil)
							end
						elseif ((playerCol ~= nil) and (playerCol)) then
							
							setElementData( player, "flag_colshape", nil )
							local playerColObject = getElementData( playerCol, "teamwars_flag_object" )
							local playerColFlag = getElementData( playerCol, "teamwars_flag_element" )
							local playerColMarker = getElementData ( playerCol, "teamwars_flag_marker" )
							local playerColTeam = getElementData( playerCol, "teamwars_team" )
							x,y,z = tonumber( getElementData ( playerColFlag, "posX" ) ), tonumber( getElementData ( playerColFlag, "posY" ) ), tonumber( getElementData ( playerColFlag, "posZ" ) )
							detachElements ( playerColObject, player )
							detachElements ( playerColMarker, player )
							setElementPosition( playerCol, x, y, z )
							setElementPosition( playerColMarker, x, y, z )
							setElementPosition( playerColObject, x, y, z )
							setElementData( playerTeam, "score", getElementData( playerTeam, "score" ) + 1 )
							setElementData( player, "score", getElementData( player, "score" ) + 5 )
							self:Announce ( r, g, b, getPlayerName( player ) .. " scores the " .. getTeamName( playerColTeam ) .. " teams' " .. getElementData( playerColFlag, "name" ) .. "!", 4000 )
							setElementData( playerColFlag, "teamwars_flag_return", false )
							setElementData( playerColFlag, "teamwars_flag_status", 0 )-- 0 - back in base
							setElementData(player, "teamwars_flag_colshape", nil) 
						end
					elseif ((not playerCol) and (colFlag)) then
						setElementPosition( source, 0, 0, 0 )
						setElementData( player, "teamwars_flag_colshape", source )
						attachElements ( colObject, player, 0, 0, 0, 0, 0, math.rad(-90) )
						attachElements ( colMarker, player, 0, 0, 0, 0, 0, 0 )
						-- toggleControl ( player, "sprint", false )
						self:Announce ( r, g, b, getPlayerName( player ) .. " took the " .. getTeamName( colTeam ) .. " teams' " .. getElementData( colFlag, "name" ) .. "!", 4000 )
						setElementData( colFlag, "teamwars_flag_return", false )
						setElementData( colFlag, "teamwars_flag_status", 2 )-- 2 - Someone has it!
						setElementData(player, "teamwars_flag_colshape", nil) 
					end
				end
			end
		end
	end
	
	function ModeCTF:OnPickupUse(thePickup, thePlayer)
		self.ModeBase:OnPickupUse(thePickup, thePlayer)
		
	end

	function ModeCTF:OnPlayerQuit(source, reason)
		self.ModeBase:OnPlayerQuit(source, reason)

	end

	function ModeCTF:OnPlayerDead(source, ammo, attacker, weapon, bodypart)
		self.ModeBase:OnPlayerDead(source, ammo, attacker, weapon, bodypart)
		
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
			-- Destroy the 'player marker' if player has one
			local playerCorona = getElementData(source, "teamwars_player_corona")
			if (playerCorona) then
				destroyElement(playerCorona)
				setElementData(source, "teamwars_player_corona", nil) -- can we unset it this way?
			end
			
			self:CheckFlag(source, ammo, attacker, weapon, bodypart)	
		end
		
		destroyBlipsAttachedTo (source )
	end

	function ModeCTF:OnKeyInput( source, key, keyState)
		self.ModeBase:OnKeyInput(source, key, keyState)

	end
	
--	Custom functions

	-- Called to start a new round
	function ModeCTF:BeginRound()
		self.roundIsActive = true
	end
	
	-- Called to start a new round
	function ModeCTF:EndRound()
		triggerEvent("onRoundFinished", getResourceRootElement(getThisResource()))
		self.roundIsActive = false
	end
	
	-- Respawn a team
	function ModeCTF:RespawnTeam(team)
		if (team) then
			local players = getPlayersInTeam(team)
			for playerKey, playerValue in ipairs ( players ) do
				self:SpawnPlayer(playerValue)
			end
		end
	end	

	-- call this to see if a player was carrying a flag when he died
	function ModeCTF:CheckFlag(source, ammo, attacker, weapon, bodypart)	
		local killer = attacker
		local scoringPlayer = attacker
		-- Now, lets see who got killed / attacker and give proper scoring
		-- TODO Check for tfc_fragscoring
		-- This give an extra score for killing a flag carrier
		
		if ((attacker == nil) or (attacker == source) or (not isElement(attacker)) ) then
			-- Suicide ;p			
		elseif ( getElementType ( attacker ) == "player" ) then
			if ( getPlayerTeam( killer ) ~= getPlayerTeam( source ) ) then
				setElementData( killer, "score", getElementData( killer, "score" ) + 1 )		
			end
		elseif ( getElementType ( attacker ) == "vehicle" ) then
			scoringPlayer = getVehicleController ( attacker )
			setElementData(scoringPlayer, "score", getElementData(scoringPlayer, "score") + 1)		
		end

		local playerCol = getElementData( source, "teamwars_flag_colshape" )
		local player = source
		if ( playerCol ~= nil ) then
			local playerColObject = getElementData( playerCol, "teamwars_flag_object" )
			local playerColMarker = getElementData( playerCol, "teamwars_flag_marger" ) 
			local playerColTeam = getElementData( playerCol, "teamwars_team" )
			local playerColFlag = getElementData( playerCol, "teamwars_flag_element" ) 
			local r,g,b = getTeamColor ( getPlayerTeam( source ) )
		    local x,y,z = getElementPosition( source )
			detachElements ( playerColObject, source )
			detachElements ( playerColMarker, source )
			setElementPosition( playerCol, x, y, z )
		    setElementPosition( playerColObject, x, y, z )
		    setElementPosition( playerColMarker, x, y, z )
			self:Announce ( r, g, b, getPlayerName( player ) .. " dropped the " .. getTeamName( playerColTeam ) .. " teams' " .. getElementData( playerColFlag, "name" ) .. "!", 4000 )
			setElementData( player, "teamwars_flag_colshape", nil )
			setElementData( playerColFlag, "teamwars_flag_status", 1 )-- 1, on the floor
			setElementData( playerColFlag, "teamwars_flag_return", getTickCount() + 30000) -- TODO Make this an option (return time)
		end
	end
	-- Respawn a single player
	function ModeCTF:SpawnPlayer( player )
		if ( player ) then
			local team = getPlayerTeam( player )
			local spawnpoints = getChildren ( team, "spawnpoint" )
			local r,g,b = getTeamColor( team )
			local spawnpoint = spawnpoints[ math.random( 1, #spawnpoints ) ] 
			
			setPlayerNametagColor ( player, r, g, b )		

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
			local playerCorona = createMarker(x, y, z, "corona", 1.5, r, g, b, 125) 
			attachElements(playerCorona, player)
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
			
			-- Class stuff
			local className = getElementData(player, "teamwars_selected_class")
			local randomClass = getElementData(player, "teamwars_random_class")
			if (randomClass) then className = "Scout" end -- Make really random
			
			local classInfo 
			classInfo = self:GetClassInfo(className)
			
			setElementData(player, "teamwars_class", className)
			setElementData(player, "teamwars_classInfo", classInfo) -- Just for easy access, but is it needed?
			
			local x,y,z = getElementPosition(spawnpoint)
			local randx = getElementData(spawnpoint, "randx"); if (not randx) then randx = 0 end
			local randy = getElementData(spawnpoint, "randy"); if (not randy) then randy = 0 end
			local randz = getElementData(spawnpoint, "randz"); if (not randz) then randz = 0 end
		
			x = x + math.random(0, randx)
			y = y + math.random(0, randy)
			z = z + math.random(0, randz)
			
			-- Load CJ first to apply MAX_HEALTH (stupid mta core bug)
			-- BUG The class skin is not visible until rejoining (other their skin)
			
			-- Apply MAX_HEALTH
			setElementData(player, "teamwars_sprint_left", INT(classInfo["stats"]["sprintTime"]))
			
			spawnPlayer(player, x, y, z, getSpawnpointRotation(spawnpoint), INT(classInfo["stats"]["skinID"]))
			
			-- setPlayerStat (player, 24, classInfo["MaxHealth"] * 5) -- DOES NOT WORK :(
			
			setElementHealth (player, INT(classInfo["stats"]["startHealth"]))
			setPedArmor(player, INT(classInfo["stats"]["startArmor"]))
			
			-- Give weapons
			-- loop -- giveWeapon ( player thePlayer, int weapon, [ int ammo=30, bool setAsCurrent=false ] )
			for weaponID,weaponInfo in pairs(classInfo["weapons"]) do 
				if (not weaponInfo["startAmmo"]) then weaponInfo["startAmmo"] = 1 end -- For melee (TODO Fix boog)
				
				giveWeapon(player, weaponID, weaponInfo["startAmmo"], weaponInfo["default"]) -- so last one set is default ^^
			end
			
			--setCameraMode ( player, "player" )
			setCameraTarget( player, player )
			toggleAllControls ( player, true, true, false )
			
			if (self.teamTable[team].respawnDisplay) then
				textDisplayRemoveObserver(self.teamTable[team].respawnDisplay, player)
			end
		end
	end
		
	function ModeCTF:OnClassSelection(player, className, randomSelect)
		self.ModeBase:OnClassSelection(player, className, randomSelect) -- This handles class selection
		
		if (not player) then return end
	
		local randomClass = getElementData(player, "teamwars_random_class")
		local selectedClass = getElementData(player, "teamwars_selected_class")
		local playerTeam = getPlayerTeam(player)
		
		if (playerTeam) then
			if (not self.respawnTimers[playerTeam]) then 			
				self.respawnTimers[playerTeam] = getTickCount()  + (INT(get("teamwars_respawn", 10)) * 1000) 
			end
			
			-- Show the respawn label
			if (self.teamTable[playerTeam].respawnDisplay) then
				textDisplayAddObserver(self.teamTable[playerTeam].respawnDisplay, player)
			end			
		end
	end
	