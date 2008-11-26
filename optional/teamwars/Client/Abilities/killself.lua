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

$Id: killself.lua 32 2007-12-10 01:37:43Z sinnerg $
]]

-- Ability: killself
-- Allows a player to kill himself by typing /kill
-- Author: SinnerG

Ability_KillSelf = class("Ability_KillSelf", Ability)

function Ability_KillSelf:__init(name, element)
	self.Ability:__init(name, element)
	
	-- Add the required command handler
	addCommandHandler("kill", TW_OnCommand)
end

function Ability_KillSelf:OnCommand(command, arg1, arg2, arg3)	
	if (command == "kill") then
		if (not isPlayerDead(getLocalPlayer())) then
			setElementHealth(getLocalPlayer(), -1) -- This forces a kill :P
		end
	end
end

local function OnClientResourceStart(resource)
	if (resource == getThisResource()) then			
		-- Register the ability in the 'register'
		registerAbility("killself", Ability_KillSelf)					
	end
end

addEventHandler("onClientResourceStart", getRootElement(), OnClientResourceStart )