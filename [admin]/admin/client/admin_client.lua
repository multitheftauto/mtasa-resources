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

_version = '1.3.1'
_root = getRootElement()
_flags = {}
_widgets = {}
_settings = nil

aWeathers = {}
_weathers_max = 0

function aClientAdminMenu ()
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
			local weather = xmlFindChild ( node, "weather", _weathers_max )
			if ( not weather ) then break end
			local id = tonumber ( xmlNodeGetAttribute ( weather, "id" ) )
			local name = xmlNodeGetAttribute ( weather, "name" )
			aWeathers[id] = name
			_weathers_max = _weathers_max + 1
		end
		if ( _weathers_max >= 1 ) then _weathers_max = _weathers_max - 1 end
		xmlUnloadFile ( node )
	end
	aLoadSettings ()
	triggerServerEvent ( "aPermissions", getLocalPlayer() )
	setTimer( function() triggerServerEvent ( "aPlayerVersion", getLocalPlayer(), getVersion() ) end, 2000, 1 )
	guiSetInputMode ( "no_binds_when_editing" )
end

function aAdminResourceStop ()
	showCursor ( false )
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
	if _settings then
		xmlUnloadFile ( _settings )
	end
	_settings = xmlLoadFile ( "admin.xml" )
	if ( not _settings ) then
		_settings = xmlCreateFile ( "admin.xml", "main" )
		xmlSaveFile ( _settings )
	end
end

function aGetSetting ( setting )
	local result = xmlFindChild ( _settings, tostring ( setting ), 0 )
	if ( result ) then
		result = xmlNodeGetValue ( result )
		if ( result == "true" ) then return true
		elseif ( result == "false" ) then return false
		else return result end
	end
	return false
end

function aSetSetting ( setting, value )
	local node = xmlFindChild ( _settings, tostring ( setting ), 0 )
	if ( not node ) then
		node = xmlCreateChild ( _settings, tostring ( setting ) )
	end
	xmlNodeSetValue ( node, tostring ( value ) )
	xmlSaveFile ( _settings )
end

function aRemoveSetting ( setting )
	local node = xmlFindChild ( _settings, tostring ( setting ), 0 )
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


--
-- Upgrade check message for 1.0 to 1.0.2
--
addEvent ( "aClientShowUpgradeMessage", true )
addEventHandler ( "aClientShowUpgradeMessage", _root,
	function()
		local xml = xmlLoadFile("upgrade_cookie.xml")
		if not xml then
			xml = xmlCreateFile("upgrade_cookie.xml", "settings")
		end
		if not xml then return end

		local node = xmlFindChild(xml, "upgradeMessage", 0)
		if not node then
			node = xmlCreateChild(xml, "upgradeMessage")
		end
		local timeNow = getRealTimeSeconds()
		local bShowConsoleText = true
		local bShowMessageBox = true

		if bShowConsoleText then
			local lastTime = xmlNodeGetAttribute(node, "lastConsoleTextTime")
			local age = timeNow - ( tonumber(lastTime) or 0 )
			if age > 60*60 then
				xmlNodeSetAttribute(node, "lastConsoleTextTime", tostring( timeNow ))
				xmlSaveFile(xml)
				outputConsole( "A new version of MTA:SA is available! - Please download from www.mtasa.com" )
			end
		end

		if bShowMessageBox then
			local lastTime = xmlNodeGetAttribute(node, "lastMessageBoxTime")
			local age = timeNow - ( tonumber(lastTime) or 0 )
			if age > 60*60*24 then
				xmlNodeSetAttribute(node, "lastMessageBoxTime", tostring( timeNow ))
				xmlSaveFile(xml)
				aMessageBox( "A new version of MTA:SA is available!",  "Please download from www.mtasa.com" )
				setTimer ( aMessageBoxClose, 15000, 1, true )
			end
		end
		xmlUnloadFile (xml)
	end
)


function getRealTimeSeconds()
	return realTimeToSeconds( getRealTime() )
end

function realTimeToSeconds( time )
	local leapyears = math.floor( ( time.year - 72 + 3 ) / 4 )
	local days = ( time.year - 70 ) * 365 + leapyears + time.yearday
	local seconds = days * 60*60*24
	seconds = seconds + time.hour * 60*60
	seconds = seconds + time.minute * 60
	seconds = seconds + time.second
	seconds = seconds - time.isdst * 60*60
	return seconds
end

function realTimeToSecondsTest()
	for i=1,100 do
		local time1 = getRealTime( math.random(0, 60*60*24*365*50) )	-- Get a random date between 1970 and 2020
		local time2 = getRealTime( realTimeToSeconds( time1 ) )
		assert( getRealDateTimeString( time1 ) == getRealDateTimeString( time2 ) )
	end
end

-- seconds to description i.e. "10 mins"
function secondsToTimeDesc( seconds )
	if seconds then
		local tab = { {"day",60*60*24},  {"hour",60*60},  {"min",60},  {"sec",1} }
		for i,item in ipairs(tab) do
			local t = math.floor(seconds/item[2])
			if t > 0 or i == #tab then
				return tostring(t) .. " " .. item[1] .. (t~=1 and "s" or "")
			end
		end
	end
	return ""
end

