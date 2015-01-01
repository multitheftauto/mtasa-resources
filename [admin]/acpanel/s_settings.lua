--
-- Anti-Cheat Control Panel
--
-- s_settings.lua
--


local aSettings = {
	File = nil,
	Cache = {}
}


serverCachedSettings = {}

function sendAllSettingsToClient()
	triggerClientEvent(player, 'onAcpClientSettingsChanged', resourceRoot, aSettings.Cache )
end


---------------------------------------------------------
-- Change from client
---------------------------------------------------------
addEvent( "onAcpSettingsChange", true )
addEventHandler( "onAcpSettingsChange", resourceRoot,
	function( name, value )
		if not isPlayerAllowedHere(client) then return false end
		setPanelSetting( name, value )
	end
)

---------------------------------------------------------
-- getPanelSetting
---------------------------------------------------------
function getPanelSetting(name)
	return aSettings.Cache[name]
end

---------------------------------------------------------
-- setPanelSetting
---------------------------------------------------------
function setPanelSetting(name, value)
	name = tostring ( name )
	value = tostring ( value )
	aSettings.Cache[name] = value
	local node = xmlFindChild ( aSettings.File, name, 0 )
	if ( not node ) then
		node = xmlCreateChild ( aSettings.File, name )
	end
	xmlNodeSetValue ( node, tostring ( value ) )
	startDelayedSave()

	local minclientconfig_type = getPanelSetting("minclientconfig.type")
	-- If name is "lastFetchedLatestVersion" and minclientconfig.type is "latest"
	--		Then set minclientversion
	-- If name is "lastFetchedReleaseVersion" and minclientconfig.type is "release"
	--		Then set minclientversion
	-- If name is "minclientconfig.customText" and minclientconfig.type is "custom"
	--		Then set minclientversion
	if
		( name == "lastFetchedLatestVersion" and minclientconfig_type == "latest" )
		or
		( name == "lastFetchedReleaseVersion" and minclientconfig_type == "release" )
		or
		( name == "minclientconfig.customText" and minclientconfig_type == "custom" )
	then
		--outputDebug("Setting minclientversion to " .. value )
		setServerConfigSetting( "minclientversion", value, true )
	end

	if name == "minclientconfig.type" or name == "blockmods.type" then

		if minclientconfig_type == "latest" then
			setServerConfigSetting( "minclientversion", getPanelSetting("lastFetchedLatestVersion"), true )
		end

		if minclientconfig_type == "release" then
			setServerConfigSetting( "minclientversion", getPanelSetting("lastFetchedReleaseVersion"), true )
		end

		if minclientconfig_type == "custom" then
			setServerConfigSetting( "minclientversion", getPanelSetting("minclientconfig.customText"), true )
		end

		if minclientconfig_type == "none" then
			setServerConfigSetting( "minclientversion", "", true )
		end

	end
--[[
	if name == "minclientconfig.type" and minclientconfig_type == "latest" then
		setServerConfigSetting( "minclientversion", getPanelSetting("lastFetchedLatestVersion"), true )
	end

	if name == "minclientconfig.type" and minclientconfig_type == "release" then
		setServerConfigSetting( "minclientversion", getPanelSetting("lastFetchedReleaseVersion"), true )
	end

	if name == "minclientconfig.type" and minclientconfig_type == "custom" then
		setServerConfigSetting( "minclientversion", getPanelSetting("minclientconfig.customText"), true )
	end

	if name == "minclientconfig.type" and minclientconfig_type == "none" then
		setServerConfigSetting( "minclientversion", "", true )
	end

	if name == "blockmods.type" and minclientconfig_type == "none" then
		setServerConfigSetting( "minclientversion", "", true )
	end
--]]
end



---------------------------------------------------------
-- Enforce min client override
---------------------------------------------------------
_setServerConfigSetting = setServerConfigSetting
function setServerConfigSetting( name, value, save )
	if name == "minclientversion" then
		local type = getPanelSetting( "blockmods.type" )
		if type and type ~= "none" then
			if value < MIN_CLIENT_VERSION_FOR_MOD_BLOCKS then
				--outputDebug("Enforcing minclientversion from " .. value .. " to " .. MIN_CLIENT_VERSION_FOR_MOD_BLOCKS )
				value = MIN_CLIENT_VERSION_FOR_MOD_BLOCKS
			end
		end
	end
	_setServerConfigSetting( name, value, save )
	--outputDebug("setServerConfigSetting( " .. name .. ", " .. value .. ", " .. tostring(save) )
end


---------------------------------------------------------
-- Save settings in 2 seconds
---------------------------------------------------------
function startDelayedSave()
	if isTimer(saveTimer) then
		killTimer(saveTimer)
		saveTimer = nil
	end
	saveTimer = setTimer( doSave, 2000, 1 )
end

---------------------------------------------------------
-- Make sure we save on exit
---------------------------------------------------------
addEventHandler ( "onResourceStop", resourceRoot,
	function ()
		doSave()
		xmlUnloadFile( aSettings.File )
	end
)


---------------------------------------------------------
-- Set default if name not set
---------------------------------------------------------
function maybeSetDefault( name, value )
	if aSettings.Cache[name] == nil then
		aSettings.Cache[name] = value
	end
end

---------------------------------------------------------
-- Actually do load
---------------------------------------------------------
function doLoad()
	aSettings.File = xmlLoadFile( "settings.xml" )
	if ( not aSettings.File ) then
		aSettings.File = xmlCreateFile( "settings.xml", "main" )
		xmlSaveFile( aSettings.File )
	end
	local messageNodes = xmlNodeGetChildren( aSettings.File )
    for _,node in ipairs( messageNodes ) do
		local name = xmlNodeGetName( node )
        local value = xmlNodeGetValue( node )
		aSettings.Cache[name] = value
    end
	-- Defaults
	maybeSetDefault( "blockmods.type", "none" )
	maybeSetDefault( "blockmods.customText", "Enter your matches" )
	maybeSetDefault( "lastFetchedReleaseVersion", "1.3.2" )
	maybeSetDefault( "lastFetchedLatestVersion", "1.3.2" )

	local minclientversion = getServerConfigSetting("minclientversion")
	if minclientversion == "" then
		maybeSetDefault( "minclientconfig.type", "none" )
		maybeSetDefault( "minclientconfig.customText", "1.3.2-9.01234" )
	else
		maybeSetDefault( "minclientconfig.type", "custom" )
		maybeSetDefault( "minclientconfig.customText", minclientversion )
	end
	GetVersInfoFromRemoteServer()
end


---------------------------------------------------------
-- Actually do save
---------------------------------------------------------
function doSave()
	if isTimer(saveTimer) then
		killTimer(saveTimer)
		saveTimer = nil
	end
	xmlSaveFile ( aSettings.File )
end


---------------------------------------------------------
-- Get version data from remote server
---------------------------------------------------------
function GetVersInfoFromRemoteServer()
	fetchRemote( "http://nightly.mtasa.com/ver/", onGotVersInfo )
end

function onGotVersInfo( responseData, errno )
	if errno == 0 then

		local ver = string.sub( getVersion().sortable, 0, 3 )

		releaseMinVersion = string.match( responseData, "default: " ..ver .. ".(.-)[^0-9.-]" )
		latestMinVersion = string.match( responseData, "minclientversion: " .. ver .. ".(.-)[^0-9.-]" )

		if releaseMinVersion and latestMinVersion then
			releaseMinVersion = ver .. "." .. releaseMinVersion
			latestMinVersion = ver .. "." .. latestMinVersion

			if isValidVersionString(releaseMinVersion) and isValidVersionString(latestMinVersion) then
				setPanelSetting( "lastFetchedReleaseVersion", releaseMinVersion )
				setPanelSetting( "lastFetchedLatestVersion", latestMinVersion )
				sendAllSettingsToClient()
				--outputDebug("valid version datas")
			end
		end
	end
	GetAcPanelVersInfoFromRemoteServer()
end

function isValidVersionString( text )
	return string.match(text, "%d%.%d%.%d%-%d%.%d%d%d%d%d%.%d") ~= nil
end

---------------------------------------------------------
-- Get version info about this resource
---------------------------------------------------------
function GetAcPanelVersInfoFromRemoteServer()
	fetchRemote( "http://nightly.mtasa.com/ver/acpanel/", onGotAcPanelVersInfo )
end


function onGotAcPanelVersInfo( responseData, errno )
	if errno == 0 then

		acpanelVersion = string.match( responseData, "acpanel ver:(.-)[^0-9.-]" )
		acpanelUrl = string.match( responseData, "acpanel url:(.-)[^A-z0-9.-:/?=&]" )
		--outputDebug("acpanelVersion:" .. acpanelVersion)
		--outputDebug("acpanelUrl:" .. acpanelUrl)
		if acpanelVersion and acpanelUrl then
			setPanelSetting( "acpanelVersion", acpanelVersion )
			setPanelSetting( "acpanelUrl", acpanelUrl )
			if acpanelVersion > _version then
				outputChatBox("New version of Anti-Cheat panel is available!")
			end
		end
	end
end


doLoad()	-- Load during resource startup
