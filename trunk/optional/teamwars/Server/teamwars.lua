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

$Id: teamwars.lua 39 2007-12-18 21:50:11Z sinnerg $
]]

-- 	Server side

-- 	Globals
	Root = getRootElement()
	GameMode = nil
	Timer = nil
	
--	Resource related events
	function TW_OnResourceStart(resource)
		if (resource == getThisResource()) then
			-- We got loaded!
			Timer = setTimer ( TW_OnTick, 50, 1)
		end
	end

	function TW_OnGamemodeStart(resource)
	
	end	

	function TW_OnGamemodeStop(resource)
		-- TW_OnResourceStop(resource)
	end
	
	function TW_OnResourceStop(resource)
		if (resource == getThisResource()) then
			-- We got stopped!
			
			if (Timer) then
				killTimer(Timer)
				Timer = nil			
			end
			
			if (GameMode) then
				GameMode:OnMapStop()
				GameMode:OnModeStop()
				GameMode = nil
			end
		end
	end
	
	function TW_OnGamemodeMapStart(resource) -- source		
		--	if (not (resource == getThisResource())) then
		--triggerClientEvent("onTeamWarsGamemodeMapStart",source, true) -- not possible to send resource
		
		-- Extract what game mode to run! (ctf, ...)
		local settings = getElementsByType( "settings" )
		if (not settings) then return end -- ERROR
		
		local setting = settings[1]
		local mode = getElementData(setting, "mode")
		if (not mode) then return end -- ERROR
		
		if (mode == "cp") then
			if (GameMode) then
				if (GameMode:is_a(ModeCP)) then
					-- Already loaded the mode - just feed it the map
					--GameMode:OnMapStop()
					GameMode:OnMapStart(source, resource) -- Tell the mode a map got loaded as well :P
					return -- Already loded
				else
					GameMode:OnModeStop()
					GameMode = nil -- Clean up
				end
			end
			GameMode = ModeCP("cp") -- CTF mode	
		else
			-- NOT SUPPORTED MODE
			return -- Do something else on here?
		end		
		
		if (not GameMode) then return end
		GameMode:OnModeStart() -- Start up the mode
		GameMode:OnMapStart(source, resource) -- Tell the mode a map got loaded as well :P

	end
	
	function TW_OnGamemodeMapStop(resource)
		triggerClientEvent("onTeamWarsGamemodeMapStop", source, true) -- not possible to send resource
		
		-- source
		if (not GameMode) then return end
		GameMode:OnMapStop(source, resource)
	end
	
--	Player related events
	function TW_OnPlayerQuit(reason)
		-- source
		if (not GameMode) then return end
		
		GameMode:OnPlayerQuit(source, reason)
	end

	function TW_OnPlayerWasted(ammo, attacker, weapon, bodypart)
		-- source
		if (not GameMode) then return end
		
		GameMode:OnPlayerDead(source, ammo, attacker, weapon, bodypart)
	end
	
	function TW_OnPlayerJoin()
		-- source
		if (not GameMode) then return end
		
		GameMode:OnPlayerJoin(source)
	end
	function TW_OnPlayerJoined()
		-- source
		if (not GameMode) then return end
		
		GameMode:OnPlayerJoined(source)
	end

	function TW_OnPlayerDamage (attacker, weapon, bodypart, loss)
		if (not GameMode) then return end
		
		GameMode:OnPlayerDamage(source, attacker, weapon, bodypart, loss)
	end	

	function TW_OnVehicleDamage (loss)
		if (not GameMode) then return end
		
		GameMode:OnVehicleDamage(source, false, 0, loss)
	end	
	
-- 	Misc events	
	function TW_OnPickupUse(player)
		if (not GameMode) then return end
		GameMode:OnPickupUse( source, player)
	end 

	function TW_OnKeyInput(source, key, keyState) -- nArguments, ..	
		if (not GameMode) then return end
		GameMode:OnKeyInput( source, key, keyState)
	end
	
	function TW_OnColShapeHit(player, matchedDimension)
		-- source
		if (not GameMode) then return end
		
		GameMode:OnColShapeHit(source, player, matchedDimension)
	end
	
	function TW_OnMarkerHit(player, matchedDimension)
		-- source
		if (not GameMode) then return end
		
		GameMode:OnMarkerHit(source, player, matchedDimension)
	end
	
	function TW_OnMarkerLeave(player, matchedDimension)
		-- source
		if (not GameMode) then return end
		
		GameMode:OnMarkerLeave(source, player, matchedDimension)
	end
	
	function TW_OnVehicleExit( player, seat, jacker )
		-- source
		if (not GameMode) then return end
		
		GameMode:OnVehicleExit(source, player, seat, jacker)		
	end
	
	function TW_OnPlayerSpawn(...)
		-- source
		if (not GameMode) then return end
		
		GameMode:OnPlayerSpawn(source, ...)		
	end
	
--	Custom events
	function TW_OnTick()
		Timer = setTimer ( TW_OnTick, 50, 1)
		if (not GameMode) then return end
		GameMode:OnTick()
		
	end
	
	function TW_OnCustomEvent(...)
		-- source
		if (not GameMode) then return end
		GameMode:OnCustomEvent(...)
	end
	
	
	function TW_OnTeamSelection(player, teamName, autoAssign)
		if (not GameMode) then return end
		GameMode:OnTeamSelection(player, teamName, autoAssign)	
	end
	
	function TW_OnClassSelection(player, className, randomSelect)
		if (not GameMode) then return end
		GameMode:OnClassSelection(player, className, randomSelect)	
	end

	addEventHandler( "onResourceStart", Root, TW_OnResourceStart )
	addEventHandler( "onResourceStop", Root, TW_OnResourceStop )
	addEventHandler( "onPlayerJoin", Root, TW_OnPlayerJoin )
	addEventHandler( "onPlayerQuit", Root, TW_OnPlayerQuit )
	addEventHandler( "onPlayerWasted", Root, TW_OnPlayerWasted )
	addEventHandler( "onColShapeHit", Root, TW_OnColShapeHit )
	addEventHandler( "onMarkerHit", Root, TW_OnMarkerHit )
	addEventHandler( "onMarkerLeave", Root, TW_OnMarkerLeave )
	addEventHandler( "onGamemodeMapStart", Root, TW_OnGamemodeMapStart )	
	addEventHandler( "onGamemodeMapStop", Root, TW_OnGamemodeMapStop )		
	addEventHandler( "onGamemodeStart", Root, TW_OnGamemodeStart )
	addEventHandler( "onGamemodeStop", Root, TW_OnGamemodeStop )
	addEventHandler( "onPickupUse", Root, TW_OnPickupUse  )
	addEventHandler( "onPlayerDamage", Root, TW_OnPlayerDamage) 
	addEventHandler( "onVehicleDamage", Root, TW_OnVehicleDamage) 
	addEventHandler( "onVehicleExit", Root, TW_OnVehicleExit)  
	addEventHandler( "onPlayerSpawn", Root, TW_OnPlayerSpawn)
--	Custom events
	addEvent("onTeamWarsTeamSelection", true)
	addEvent("onTeamWarsClassSelection", true)
	addEvent("onTeamWarsCustomEvent", true)
	addEvent("onTeamWarsPlayerJoined", true)
--	Custom event handlers
	addEventHandler( "onTeamWarsTeamSelection", Root, TW_OnTeamSelection)
	addEventHandler( "onTeamWarsClassSelection", Root, TW_OnClassSelection)
	addEventHandler("onTeamWarsCustomEvent", Root, TW_OnCustomEvent )
	addEventHandler("onTeamWarsPlayerJoined", Root, TW_OnPlayerJoined )
-- 	Misc Functions
	_OutputDebugString = outputDebugString; function outputDebugString(str, level) _OutputDebugString('TeamWars(Server): ' .. str, level) end
--	function outputDebugString(str, level) _OutputDebugString('TeamWars(Server): ' .. str ) end --debug (we need ERRORS)

--	_DestroyElement = destroyElement
--	function destroyElement(element)
--		outputChatBox("Destroying element type: " .. getElementType(element))
--		if (getElementData(element, "teamwars_cp")) then
--			outputChatBox("CP MARKER!!")
--		end
--		_DestroyElement(element)
--	end
 