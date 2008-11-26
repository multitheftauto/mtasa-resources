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

--	Client Side

-- 	Globals
	Root = getRootElement()
	GameMode = nil
	Timer = nil
	
--	Resource related events
	function TW_OnClientResourceStart(resource)
		if (resource == getThisResource()) then
			-- We got loaded!
			Timer = setTimer ( TW_OnTick, 50, 1)
			outputDebugString("TeamWars starting up ...")
			
			-- Tell server we joined fully
			triggerServerEvent ("onTeamWarsPlayerJoined", getLocalPlayer())
		end
	end

	function TW_OnClientResourceStop(resource)
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
			
			unregisterAbilitiesHandlers() -- Destroy them now, since our resource is being unloaded
		end
	end
--	Regular event handlers
	function TW_OnClientGUIClick ( )
		if (not GameMode) then return end
		GameMode:OnClientGUIClick(source)
	end
--	Misc event handlers
	function TW_OnClientElementDataChange(...)
		if (not GameMode) then return end
		GameMode:OnClientElementDataChange(source, ...)	
	end

	function TW_OnKeyInput(key, state) --  ... )	
		if (not GameMode) then return end
		GameMode:OnKeyInput( key, state )	
	end
	
--	Custom event handlers
	function TW_OnTick()
		Timer = setTimer ( TW_OnTick, 50, 1)
		if (not GameMode) then return end
		GameMode:OnTick()		
	end
	function TW_OnRender()
		if (not GameMode) then return end
		GameMode:OnRender()		
	end

	function TW_OnGamemodeMapStart(source, resource)
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
					GameMode:OnMapStart(source, resource)
					fadeCamera(true) -- Show our camera now
					return -- Already loded
				else
					GameMode:OnModeStop()
					GameMode = nil -- Clean up
				end
			end
			GameMode = ModeCP("cp") -- CTF mode	
		else
			-- NOT SUPPORTED MODE
		end		
		
		if (not GameMode) then return end
		GameMode:OnModeStart() -- Start up the mode
		GameMode:OnMapStart(source, resource) -- Tell the mode a map got loaded as well :P	
		fadeCamera(true) -- Show our camera now	
	end
	
	function TW_OnGamemodeMapStop(source, resource)		
		-- source
		if (not GameMode) then return end
		
		GameMode:OnMapStop(source, resource)
	end
	
	function TW_OnShowTeamSelection(...)	
		-- source
		if (not GameMode) then return end
		GameMode:guiShowTeamSelection(...)
	end
	
	function TW_OnShowClassSelection(...)	
		-- source
		if (not GameMode) then return end
		GameMode:guiShowClassSelection(...)
	end
	
	function TW_OnPlayerDamage(source, ...)
		-- source
		if (not GameMode) then return end
		GameMode:OnPlayerDamage(source, ...)	

	end
	
	function TW_OnClienPlayerDamage(...)
		-- source
		if (not GameMode) then return end
		GameMode:OnClienPlayerDamage(source, ...)		
	end
	
	function TW_OnClientPlayerWeaponSwitch(...)
		-- source
		if (not GameMode) then return end
		GameMode:OnClientPlayerWeaponSwitch(...)	
	end
	
	function TW_OnPlayerSpawn(team)
		-- source
		if (not GameMode) then return end
		GameMode:OnPlayerSpawn(source, team)
		
	end
	
	function TW_OnPlayerDead(...)
		-- source
		if (not GameMode) then return end
		GameMode:OnPlayerDead(source, ...)
	end
	
	function TW_OnCustomEvent(...)
		-- source
		if (not GameMode) then return end
		GameMode:OnCustomEvent(...)
	end
	
	function TW_OnCommand(...)
		-- source
		if (not GameMode) then return end
		GameMode:OnCommand(...)

	end
	
	
--	Create custom events
	addEvent("onTeamWarsGamemodeMapStart", true)
	addEvent("onTeamWarsGamemodeMapStop", true)
	addEvent("onTeamWarsShowTeamSelection", true)
	addEvent("onTeamWarsShowClassSelection", true)
	addEvent("onTeamWarsCustomEvent", true)
	addEvent("onTeamWarsPlayerDamage", true)
	
--	Link custom events
	addEventHandler("onTeamWarsGamemodeMapStart", Root, TW_OnGamemodeMapStart )
	addEventHandler("onTeamWarsGamemodeMapStop", Root, TW_OnGamemodeMapStop )
	addEventHandler("onTeamWarsShowTeamSelection", Root, TW_OnShowTeamSelection )
	addEventHandler("onTeamWarsShowClassSelection", Root, TW_OnShowClassSelection )
	addEventHandler("onTeamWarsCustomEvent", Root, TW_OnCustomEvent )
	addEventHandler("onTeamWarsPlayerDamage", Root, TW_OnPlayerDamage)
	
--	Link regular events
	addEventHandler("onClientResourceStart", Root, TW_OnClientResourceStart )
	addEventHandler("onClientResourceStop", Root, TW_OnClientResourceStop )
	addEventHandler("onClientElementDataChange", Root, TW_OnClientElementDataChange)
	addEventHandler("onClientGUIClick", Root, TW_OnClientGUIClick)
	addEventHandler("onClientRender", Root, TW_OnRender)
	addEventHandler("onClientPlayerSpawn", Root, TW_OnPlayerSpawn)
	addEventHandler("onClientPlayerWeaponSwitch", Root, TW_OnClientPlayerWeaponSwitch )
	addEventHandler("onClientPlayerDamage", Root, TW_OnClienPlayerDamage)
	addEventHandler("onClientPlayerWasted", Root, TW_OnPlayerDead)
-- Misc Functions
	_OutputDebugString = outputDebugString; function outputDebugString(str, level) _OutputDebugString('TeamWars(Client):  ' .. str, level) end
	
	
	-- TEST ONLY STUFF
	function testCmd ( name, commandType )

		if (commandType == "team") then		
			if (not GameMode) then return end
			GameMode:guiShowClassSelection(false)
			GameMode:guiShowTeamSelection(true)
		elseif (commandType == "class") then		
			if (not GameMode) then return end
			local team = getPlayerTeam(getLocalPlayer())
			if (not team) then
				GameMode:guiShowTeamSelection(true)
				GameMode:guiShowClassSelection(false)
				outputChatBox("You have to join a team first!")
			else
				GameMode:guiShowTeamSelection(false)
				GameMode:guiShowClassSelection(true)
			end
		end
	end
	addCommandHandler ( "select", testCmd )
--	helpmanager
--	helpTab = call(getResourceFromName("helpmanager"), "addHelpTab", getThisResource(), true)