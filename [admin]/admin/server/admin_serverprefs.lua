--
--
-- admin_serverprefs.lua
--
--

---------------------------------------------------------------------------
--
-- Prefs
--
--
--
---------------------------------------------------------------------------
function cachePrefs()
	g_Prefs = {}
	g_Prefs.maxmsgs			= getNumber('maxmsgs',99)
	g_Prefs.bandurations	= getString('bandurations','60,3600,43200,0')
	g_Prefs.mutedurations	= getString('mutedurations','60,120,300,600,0')
	g_Prefs.clientcheckban	= getBool('clientcheckban',false)
	g_Prefs.securitylevel	= getNumber('securitylevel',2)
	triggerClientEvent( root, "onClientUpdatePrefs", resourceRoot, g_Prefs )
end

-- Initial cache
addEventHandler('onResourceStart', resourceRoot,
	function()
		cachePrefs()
	end
)

-- React to admin panel changes
addEvent ( "onSettingChange", false )
addEventHandler('onSettingChange', resourceRoot,
	function(name, oldvalue, value, playeradmin)
		cachePrefs()
	end
)

addEventHandler('onPlayerJoin', root,
	function()
		triggerClientEvent( source, "onClientUpdatePrefs", resourceRoot, g_Prefs )
	end
)


---------------------------------------------------------------------------
--
-- gets
--
---------------------------------------------------------------------------

-- get string or default
function getString(var,default)
	local result = get(var)
	if not result then
		return default
	end
	return tostring(result)
end

-- get number or default
function getNumber(var,default)
	local result = get(var)
	if not result then
		return default
	end
	return tonumber(result)
end

-- get true or false or default
function getBool(var,default)
	local result = get(var)
	if not result then
		return default
	end
	return result == 'true'
end


--------------------------------------------------------------------------------
-- Coroutines
--------------------------------------------------------------------------------
-- Make sure errors inside coroutines get printed somewhere
_coroutine_resume = coroutine.resume
function coroutine.resume(...)
	local state,result = _coroutine_resume(...)
	if not state then
		outputDebugString( tostring(result), 1 )	-- Output error message
	end
	return state,result
end
