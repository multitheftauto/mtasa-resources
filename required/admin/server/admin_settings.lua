--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_settings.lua
*
*	Original File by ccw
*
**************************************]]


-- Set a resource's public setting
function aSetResourceSetting( resName, name, value )
	return set('*'..resName..'.'..name,value)
end


-- Get a resource's public bool,number or string settings
function aGetResourceSettings( resName )
	allowedAccess = { ['*']=true }
	allowedTypes  = { ['boolean']=true, ['number']=true, ['string']=true }

	local rawsettings = get(resName..'.')
	if not rawsettings then
		return {}
	end
	local settings = {}
	-- Parse raw settings
	for rawname,value in pairs(rawsettings) do
		if allowedTypes[type(value)] then
--		if type(value) == 'boolean' or type(value) == 'number' or type(value) == 'string' then
			if allowedAccess[string.sub(rawname,1,1)] then
--			if string.sub(rawname,1,1) == '*' then
				-- Remove leading '*','#' or '@'
				local temp = string.gsub(rawname,'[%*%#%@](.*)','%1')
				-- Remove leading 'resName.'
				local name = string.gsub(temp,resName..'%.(.*)','%1')
				-- If name didn't have a leading 'resName.', then it must be the default setting
				local bIsDefault = ( temp == name )
				if settings[name] == nil then
					settings[name] = {}
				end
				if bIsDefault then
					settings[name].default = value
				else
					settings[name].current = value
				end
			end
		end
	end
	-- Copy to tableOut, setting 'current' from 'default' where appropriate
	local tableOut = {}
	for name,value in pairs(settings) do
		if value.default ~= nil then
			tableOut[name] = {}
			tableOut[name].default = value.default
			tableOut[name].current = value.current
			if value.current == nil then
				tableOut[name].current = value.default
			end
		end
	end
	return tableOut
end
