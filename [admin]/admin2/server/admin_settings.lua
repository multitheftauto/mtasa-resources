--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	server/admin_settings.lua
*
*	Original File by lil_Toady
*
**************************************]]

local aSettings = {
	File = nil,
	Cache = {}
}

addEventHandler ( "onResourceStart", getResourceRootElement ( getThisResource() ), function ()
	aSettings.File = xmlLoadFile ( "conf\\settings.xml" )
	if ( not aSettings.File ) then
		aSettings.File = xmlCreateFile ( "conf\\settings.xml", "main" )
		xmlSaveFile ( aSettings.File )
	end
end )

function aGetSetting ( setting )
	local cache = aSettings.Cache[setting]
	if ( cache ~= nil ) then
		return cache
	end

	local result = xmlFindChild ( aSettings.File, tostring ( setting ), 0 )
	if ( result ) then
		result = xmlNodeGetValue ( result )
		if ( result == "true" ) then return true
		elseif ( result == "false" ) then return false
		else return result end
	end
	return false
end

function aSetSetting ( setting, value )
	aSettings.Cache[setting] = value
	setting = tostring ( setting )
	local node = xmlFindChild ( aSettings.File, setting, 0 )
	if ( not node ) then
		node = xmlCreateChild ( aSettings.File, setting )
	end
	xmlNodeSetValue ( node, tostring ( value ) )
	xmlSaveFile ( aSettings.File )
end

function aRemoveSetting ( setting )
	aSettings.Cache[setting] = nil
	local node = xmlFindChild ( aSettings.File, tostring ( setting ), 0 )
	if ( node ) then
		xmlDestroyNode ( node )
	end
	xmlSaveFile ( aSettings.File )
end