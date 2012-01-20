--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_network.lua
*
*	Original File by lil_Toady
*
**************************************]]

local aNetwork = {
	{ ip = "127.0.0.1", port = 22005, tag = "", linked = true, key = "881ff8ad00afad3d398f1fefee55d780" }
}

enum ({
	"EXCHANGE_INFO",
	"EXCHANGE_REQUEST",
	"EXCHANGE_LINK",
	"EXCHANGE_DELINK",
	"EXCHANGE_CHAT",
	"EXCHANGE_BAN"
})

addEventHandler ( "onResourceStart", getResourceRootElement(), function ()

end )

addCommandHandler ( "test", function ()
	dataSend ( "127.0.0.1", 22005, EXCHANGE_REQUEST, "sgdhgsdhsdhsdhsdhsdhsdhsdh", getServerHttpPort() )
end )

local networkFunctions = {
	[NETWORK_REQUEST] = function ()

	end,
}

addEvent ( EVENT_NETWORK, true )
addEventHandler ( EVENT_NETWORK, getRootElement(), function ( action, ... )
	if ( networkFunctions[action] ) then
		local c = coroutine.create ( networkFunctions[action] )
		sourceCoroutine = c
		local result, error = coroutine.resume ( c, ... )
		if ( not result ) then
			outputDebugString ( tostring ( error ) )
		end
		if ( sourceCoroutine == c ) then
			sourceCoroutine = nil
		end
	end
end )

local dataFunctions = {
	[EXCHANGE_INFO] = function ()
		return getServerName (), getServerPort(), getServerHttpPort()
	end,
	[EXCHANGE_REQUEST] = function ( key, http )
		local sender = hostname
		local success, name, port = dataGet ( sender, http, EXCHANGE_INFO )
		if ( success ) then
			print ( "succeed" )
			table.insert ( aNetwork, {
				ip = sender,
				port = http,
				tag = "",
				linked = false,
				awaiting = true,
				key = key,
				info = {
					name = name,
					port = port
				}
			})
			dataSend ( sender, http, EXCHANGE_LINK, key )
		end
	end,
	[EXCHANGE_LINK] = function ( key )
		for id, server in ipairs ( aNetwork ) do
			if ( server.ip == hostname and server.key == key and not server.linked ) then
				server.linked = true
				print ( "successfully linked with server #"..id.." ("..hostname..":"..server.port..")" )
			end
		end
	end,
	[EXCHANGE_DELINK] = function ()
		
	end,
	[EXCHANGE_CHAT] = function ()

	end,
	[EXCHANGE_BAN] = function ()

	end
}

function dataExchange ( action, ... )
	if ( dataFunctions[action] and hostname ) then
		local args = { ... }
		if ( action > EXCHANGE_DELINK ) then
			local found = false
			for id, server in ipairs ( aNetwork ) do
				if ( server.ip == hostname ) then
					if ( server.key == args[1] ) then
						table.remove ( args, 1 )
						found = true
					end
				end
			end
			if ( not found ) then
				return
			end
		end

		local c = coroutine.create ( dataFunctions[action] )
		sourceCoroutine = c
		local result = { coroutine.resume ( c, unpack ( args ) ) }
		if ( sourceCoroutine == c ) then
			sourceCoroutine = nil
		end
		if ( not result[1] ) then
			outputDebugString ( tostring ( result[2] ) )
		else
			table.remove ( result, 1 )
			return unpack ( result )
		end
	end
	return nil
end

function dataBroadcast ( action, ... )
	for id, server in ipairs ( aNetwork ) do
		if ( server.linked and not server.awaiting ) then
			local host = server.ip..":"..server.port
			local args = { ... }
			table.insert ( args, 1, server.key )
			callRemote ( host, "admin", "dataExchange", function ( error, code, ... )
				-- do something?
			end, action, unpack ( args ) )
		end
	end
end

function dataSend ( ip, port, ... )
	local host = tostring ( ip )..":"..tostring ( port )
	callRemote ( host, "admin", "dataExchange", function ( error, code, ... )
		-- do something?
	end, ... )
end

function dataGet ( ip, port, action, ... )
	local thread = sourceCoroutine
	local result = {}
	local host = tostring ( ip )..":"..tostring ( port )
	callRemote ( host, "admin", "dataExchange", function ( ... )
		local args = { ... }
		if ( args[1] == "ERROR" ) then
			return false
		end
		result = args
		coroutine.resume ( thread )
	end, action, ... )
	coroutine.yield ()
	return unpack ( result )
end

addEventHandler ( "onBan", getRootElement(), function ()

end )

addEventHandler ( "onPlayerBan", getRootElement(), function ()

end )

addEventHandler ( "onUnban", getRootElement(), function ()

end )

addEventHandler ( "onPlayerChat", getRootElement(), function ( message, type )
	if ( type == 0 ) then

	elseif ( type == 1 ) then

	end
end )