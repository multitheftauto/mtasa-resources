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

$Id: classes.lua 32 2007-12-10 01:37:43Z sinnerg $
]]

function onResourceStart(resource)
	if (resource == getThisResource()) then
        --node = xmlLoadFile ( "default_classes.xml" )
        ---- Check if the file was loaded ok
        --if ( node ) then
		--	-- Load the loaded xml file into the element tree
		---	loadMapData ( node, getRootElement() )
		--	-- Unload the xml file again
		--	xmlUnloadFile ( node )
			outputDebugString("Default TeamWars classed loaded.")
        --else
		--	outputDebugString("Could not load TeamWars classes!", 2)		
		--end
	end
end
addEventHandler ( "onResourceStart", getRootElement(), onResourceStart )