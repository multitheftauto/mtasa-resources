g_ServerVars = {
	announce = true,
	anticheat = false,
	bind = '',
	filterscripts = get('amx.filterscripts') or '',
	gamemode0 = '',
	gamemode1 = '',
	gamemode2 = '',
	gamemode3 = '',
	gamemode4 = '',
	gamemode5 = '',
	gamemode6 = '',
	gamemode7 = '',
	gamemode8 = '',
	gamemode9 = '',
	gamemode10 = '',
	gamemode11 = '',
	gamemode12 = '',
	gamemode13 = '',
	gamemode14 = '',
	gamemode15 = '',
	gamemodetext = '',
	gravity = {
		get = function()
			return tostring(getGravity())
		end,
		set = function(grav)
			grav = grav and tonumber(grav)
			if grav then
				setGravity(grav)
			end
		end
	},
	hostname = { get = getServerName },
	instagib = false,
	lanmode = false,
	mapname = { get = function() return getMapName() or '' end, set = setMapName },
	maxplayers = { get = getMaxPlayers },
	myriad = false,
	nosign = '',
	password = { get = function() return getServerPassword() or '' end },
	plugins = get('amx.plugins') or '',
	port = { get = getServerPort },
	query = true,
	rcon_password = '',
	timestamp = true,
	version = amxVersionString(),
	weather = {
		get = function()
			return tostring(getWeather())
		end,
		set = function(weather)
			weather = weather and tonumber(weather)
			if weather then
				setWeather(weather)
			end
		end
	},
	weburl = 'www.mtasa.com',
	worldtime = {
		get = function()
			local h, m = getTime()
			return h .. ':' .. m
		end,
		set = function(str)
			local h, m = str:match('^(%d+):(%d+)$')
			if h then
				setTime(tonumber(h), tonumber(m))
			end
		end
	}
}

local readOnlyVars = table.create({ 'announce', 'anticheat', 'bind', 'filterscripts', 'hostname', 'maxplayers', 'nosign', 'plugins', 'port', 'version' }, true)
g_ServerVars = { shadow = g_ServerVars }
setmetatable(
	g_ServerVars,
	{
		__index = function(t, k)
			local v = g_ServerVars.shadow[k]
			if v == nil then
				return
			end
			if type(v) == 'function' then
				return v()
			elseif type(v) == 'table' then
				return v.get()
			else
				return v
			end
		end,
		__newindex = function(t, k, v)
			local oldV = g_ServerVars.shadow[k]
			if oldV == nil then
				return
			end
			if type(oldV) == 'table' then
				if oldV.set then
					oldV.set(v)
				end
			else
				g_ServerVars.shadow[k] = v
			end
		end
	}
)

local function presentServerVar(k)
	local v = g_ServerVars[k]
	local t = type(v)
	if t == 'boolean' then
		v = v and 1 or 0
	elseif t == 'string' then
		v = '"' .. v .. '"'
	end
	local result = ('  %15s = %s (%s)'):format(k, v, t)
	if readOnlyVars[k] then
		result = result .. ' (read-only)'
	end
	return result
end

local function cmdBan(id)
	if not id then
		return 'ban <playerid>'
	end
	id = tonumber(id)
	if not id or not g_Players[id] then
		return
	end
	local name = getPlayerName(g_Players[id].elem)
	if banPlayer(g_Players[id].elem) then
		return 'Added ' .. id .. ' (' .. name .. ') to the ban list'
	else
		return 'Failed to ban ' .. id .. ' (' .. name .. ')'
	end
end

local function cmdBanIP(ip)
	if not ip then
		return 'banip <ip>'
	end
	if banIP(ip) then
		return 'Added ' .. ip .. ' to the ban list'
	else
		return 'Failed to ban ' .. ip
	end
end

local function cmdCmdList()
	return table.concat(table.sort(table.keys(g_RCONCommands)), '\n')
end

local function cmdEcho(str)
	print(str or '')
end

local function cmdExec(fname)
	if not fname then
		return 'exec <filename>'
	end
	return doRCONFromFile(fname) or ('exec: invalid file name ' .. fname)
end

local function cmdChangeMode(mode)
	if not mode then
		return 'changemode <modename>'
	end
	local newRes = getResourceFromName('amx-' .. mode)
	if not newRes then
		return 'No gamemode named ' .. mode
	end
	local amx = getRunningGameMode(mode)
	if amx then
		unloadAMX(amx)
	end
	startResource(newRes)
end

local function cmdGMX()
	local mapcycler = getResourceFromName('mapcycler')
	if not mapcycler then
		return 'The mapcycler resource, which is required for amx mode cycling, is not installed'
	end
	if getResourceState(mapcycler) == 'running' then
		restartResource(mapcycler)
	else
		startResource(mapcycler)
	end
end

local function cmdGravity(grav)
	grav = grav and tonumber(grav)
	if not grav then
		return 'gravity <grav>'
	end
	setGravity(grav)
end

local function cmdKick(id)
	if not id then
		return 'kick <id>'
	end
	id = tonumber(id)
	if not id or not g_Players[id] then
		return 'Invalid player id'
	end
	local name = getPlayerName(g_Players[id].elem)
	if kickPlayer(g_Players[id].elem) then
		return 'Kicked ' .. id .. ' (' .. name .. ')'
	else
		return 'Failed to kick ' .. id .. ' (' .. name .. ')'
	end
end

local function cmdLoadFS(fsname)
	if not fsname then
		return 'loadfs <fsname>'
	end
	local res = getResourceFromName('amx-fs-' .. fsname)
	if not res then
		return 'No such filterscript: ' .. fsname
	end
	startResource(res)
end

local function cmdLoadPlugin(pluginName)
	if not pluginName then
		return 'loadplugin <pluginname>'
	end
	if amxIsPluginLoaded(pluginName) then
		return 'Plugin ' .. pluginName .. ' is already loaded'
	end
	if amxLoadPlugin(pluginName) then
		return 'Plugin ' .. pluginName .. ' loaded'
	else
		return 'Failed loading plugin ' .. pluginName
	end
end

local function cmdPlayers()
	local result = ''
	for id,data in pairs(g_Players) do
		result = result .. ('%5d  %s\n'):format(id, getPlayerName(data.elem))
	end
	return result
end

local function cmdReloadFS(fsname)
	if not fsname then
		return 'reloadfs <fsname>'
	end
	local res = getResourceFromName('amx-fs-' .. fsname)
	if not res then
		return 'No such filterscript: ' .. fsname
	end
	restartResource(res)
end

local function cmdUnbanIP(ip)
	if not ip then
		return 'unbanip <ip>'
	end
	if unbanIP(ip) then
		return 'Removed ' .. ip .. ' from the ban list'
	else
		return 'Failed to unban ' .. ip
	end
end

local function cmdUnloadFS(fsname)
	if not fsname then
		return 'unloadfs <fsname>'
	end
	local res = getResourceFromName('amx-fs-' .. fsname)
	if not res then
		return 'No such filterscript: ' .. fsname
	end
	stopResource(res)
end

local function cmdVarList()
	local result = ''
	local keys = table.sort(table.keys(g_ServerVars.shadow))
	for i,k in ipairs(keys) do
		result = result .. presentServerVar(k) .. '\n'
	end
	return result
end

g_RCONCommands = {
	ban = cmdBan,
	banip = cmdBanIP,
	changemode = cmdChangeMode,
	cmdlist = cmdCmdList,
	echo = cmdEcho,
	exec = cmdExec,
	gravity = cmdGravity,
	gmx = cmdGMX,
	kick = cmdKick,
	loadfs = cmdLoadFS,
	loadplugin = cmdLoadPlugin,
	players = cmdPlayers,
	reloadfs = cmdReloadFS,
	unbanip = cmdUnbanIP,
	unloadfs = cmdUnloadFS,
	varlist = cmdVarList
}

function doRCON(str, overrideReadOnly)
	local cmd, args = str:match('^([^%s]+)%s*(.*)$')
	if not cmd then
		return
	end
	if #args == 0 then
		args = false
	end
	if g_RCONCommands[cmd] then
		return g_RCONCommands[cmd](args)
	elseif g_ServerVars[cmd] ~= nil then
		local oldV = g_ServerVars[cmd]
		local newV = args
		if not newV then
			return presentServerVar(cmd)
		elseif overrideReadOnly or not readOnlyVars[cmd] then
			local t = type(oldV)
			if t == 'boolean' then
				if newV == '0' then
					newV = false
				elseif newV == '1' then
					newV = true
				else
					return
				end
			elseif t == 'number' then
				newV = tonumber(newV)
				if not newV then
					return
				end
			end
			g_ServerVars[cmd] = newV
		end
	end
end

function doRCONFromFile(fname)
	local hFile = fileOpen(fname)
	if not hFile then
		return false
	end
	local result = ''
	local line
	while true do
		line = fileReadLine(hFile)
		if not line then
			break
		end
		line = doRCON(line, true)
		if line then
			result = result .. line .. '\n'
		end
	end
	fileClose(hFile)
	return result
end

addCommandHandler('rcon',
	function(player, command, ...)
		if not isPlayerInACLGroup(player, 'Admin') then
			return
		end
		local str = table.concat({ ... }, ' ')
		local result = doRCON(str)
		if result then
			local lines = result:split('\n')
			for i,line in ipairs(lines) do
				outputConsole(line)
			end
		end
	end
)

addEventHandler('onConsole', root,
	function(str)
		if getAccountName(getPlayerAccount(source)) ~= 'Console' then
			return
		end
		local result = doRCON(str)
		if result then
			print(result)
		end
	end
)