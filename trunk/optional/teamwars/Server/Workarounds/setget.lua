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

$Id: setget.lua 32 2007-12-10 01:37:43Z sinnerg $
]]


-- Work around for get/set functions, I might stick to this method (easy to set a default if not set)

--	Reassign the original functions
	_get = get
	_set = set
	
	function get(settingName, optionalDefault)
		local res = _get(settingName)
		if (not optionalDefault) then optionalDefault = res end
		if (not res) then return optionalDefault end
		
		return res
	end

	function set(settingName, settingValue)
		return _set(settingName, settingValue)
	end
