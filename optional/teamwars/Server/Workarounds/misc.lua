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

$Id: misc.lua 40 2007-12-31 00:46:26Z sinnerg $
]]

function getSpawnpointRotation(anyElement)
	return getElementData(anyElement, "rot")
end


if (destroyBlipsAttachedTo == nil) then
	function destroyBlipsAttachedTo(element)
		if (not isElement(element)) then return false end
		
		local allBlips = getAttachedElements(element)
		
		if (allBlips) then -- MTA bug workaround
			for k,v in ipairs(allBlips) do 
				if ((isElement(v)) and (getElementType(v) == "blip")) then
					destroyElement(v)
				end
			end
		end
		
		return true
	end
end
