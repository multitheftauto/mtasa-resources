--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_client.lua
*
*	Original File by lil_Toady
*
**************************************]]

_DEBUG = false

_version = '1.2 Development Preview'
_root = getRootElement()
_flags = {}
_widgets = {}
_settings = nil

aWeathers = {}
_weathers_max = 0

function aClientAdminMenu ()
	guiSetInputEnabled ( false )
	if ( aAdminForm ) and ( guiGetVisible ( aAdminForm ) == true ) then
		for id, widget in pairs ( _widgets ) do
			widget.close ( false )
		end
		aAdminMenuClose ( false )
	else
		aAdminMenu ()
	end
end

addEvent ( "onAdminInitialize", true )
addEvent ( "aMessage", true )
addEvent ( "aClientLog", true )
addEvent ( "aClientSync", true )
addEvent ( "aClientPlayerJoin", true )
addEvent ( "aMessage", true )
addEvent ( "aClientAdminChat", true )
addEvent ( "aClientResourceStart", true )
addEvent ( "aClientResourceStop", true )
addEvent ( "aClientAdminMenu", true )
function aAdminResourceStart ()
	addEventHandler ( "aClientAdminMenu", _root, aClientAdminMenu )
	local node = xmlLoadFile ( "conf\\weathers.xml" )
	if ( node ) then
		while ( true ) do
			local weather = xmlFindSubNode ( node, "weather", _weathers_max )
			if ( not weather ) then break end
			local id = tonumber ( xmlNodeGetAttribute ( weather, "id" ) )
			local name = xmlNodeGetAttribute ( weather, "name" )
			aWeathers[id] = name
			_weathers_max = _weathers_max + 1
		end
		if ( _weathers_max >= 1 ) then _weathers_max = _weathers_max - 1 end
	end
	aLoadSettings ()
	triggerServerEvent ( "aPermissions", getLocalPlayer() )
end

function aAdminResourceStop ()
	showCursor ( false )
	guiSetInputEnabled ( false )
end

function aRegister ( name, welement, fopen, fclose )
	_widgets[name] = {}
	_widgets[name].element = welement
	_widgets[name].initialize = fopen
	_widgets[name].close = fclose
end

function aAdminDestroy ()
	if ( aAdminForm ) then
		for id, widget in pairs ( _widgets ) do
			widget.close ( true )
		end
		_widgets = {}
		aAdminMenuClose ( true )
	end
end

function aLoadSettings ()
	_settings = xmlLoadFile ( "admin.xml" )
	if ( not _settings ) then
		_settings = xmlCreateFile ( "admin.xml", "main" )
		xmlSaveFile ( _settings )
	end
end

function aGetSetting ( setting )
	local result = xmlFindSubNode ( _settings, tostring ( setting ), 0 )
	if ( result ) then
		result = xmlNodeGetValue ( result )
		if ( result == "true" ) then return true
		elseif ( result == "false" ) then return false
		else return result end
	end
	return false
end

function aSetSetting ( setting, value )
	local node = xmlFindSubNode ( _settings, tostring ( setting ), 0 )
	if ( not node ) then
		node = xmlCreateSubNode ( _settings, tostring ( setting ) )
	end
	xmlNodeSetValue ( node, tostring ( value ) )
	xmlSaveFile ( _settings )
end

function aRemoveSetting ( setting )
	local node = xmlFindSubNode ( _settings, tostring ( setting ), 0 )
	if ( node ) then
		xmlDestroyNode ( node )
	end
	xmlSaveFile ( _settings )
end

function getWeatherNameFromID ( weather )
	return iif ( aWeathers[weather], aWeathers[weather], "Unknown" )
end

function aExecute ( action, echo )
	local result = loadstring("return " .. action)()
	if ( echo == true ) then
		local restring = ""
		if ( type ( result ) == "table" ) then restring = "Table ("..unpack ( result )..")"
		elseif ( type ( result ) == "userdata" ) then restring = "Element ("..getElementType ( result )..")"
		else restring = tostring ( result ) end
		outputChatBox( "Command executed! Result: " ..restring, 0, 0, 255 )
	end
end

function iif ( cond, arg1, arg2 )
	if ( cond ) then
		return arg1
	end
	return arg2
end

function getPlayerFromNick ( nick )
	for id, player in ipairs(getElementsByType("player")) do
		if ( getPlayerName ( player ) == nick ) then return player end
	end
	return false
end

addEventHandler ( "onClientResourceStart", getResourceRootElement ( getThisResource() ), aAdminResourceStart )
addEventHandler ( "onClientResourceStop", getResourceRootElement ( getThisResource() ), aAdminResourceStop )