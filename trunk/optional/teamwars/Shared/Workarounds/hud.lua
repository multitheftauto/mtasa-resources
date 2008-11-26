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

$Id: hud.lua 32 2007-12-10 01:37:43Z sinnerg $
]]

-- Work around since we lack a isPlayerHudComponentVisible kind of function ...
__showPlayerHudComponent  = showPlayerHudComponent 
__PLAYER_HUD_COMPONENTS = {}
if (getMaxPlayers == nil) then
-- Client
	function showPlayerHudComponent (component, visible)
		if (__showPlayerHudComponent(component, visible)) then			
			__PLAYER_HUD_COMPONENTS[component] = visible 
		end		
	end
	
	function isPlayerHudComponentVisible(component)
		if (__PLAYER_HUD_COMPONENTS[component] == nil) then
			return true
		end
		
		return __PLAYER_HUD_COMPONENTS[component]
	end
else
-- Server
	function showPlayerHudComponent (player, component, visible)
		if (__showPlayerHudComponent(player, component, visible)) then			
			outputDebugString("WARNING: Server set hud component visibility breaks client-side status.", 2)
		end		
	end
end
