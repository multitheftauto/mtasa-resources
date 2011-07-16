--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_community.lua
*
*	Original File by lil_Toady
*
**************************************]]

local aCommunity = {
	players = {},
	groups = {},
	resources = {}
}

addEventHandler ( "onPlayerConnect", _root, function ( nick, username, serial, ip )
  --cancelEvent()
end )

function aCommunityValidate ( player, username, serial )

	local function kill ( player )
		local cr = aCommunity.players[player].cr
		coroutine.resume ( cr, true )
		aCommunity.players[player] = nil
	end

	local function result ( player, res )
		local cr = aCommunity.players[player].cr
		coroutine.resume ( cr, result ~= 0 )
		killTimer ( aCommunity.players[player].t )
		aCommunity.players[player] = nil
	end

	local c = coroutine.running()
	aCommunity.players[player] = {}
	aCommunity.players[player].cr = c
	aCommunity.players[player].t = setTimer ( kill, 2000, 1, player )

	callRemote ( "http://community.mtasa.com/mta/verify.php", result, player, username, serial )
	return coroutine.yield()
end

--[[
addCommandHandler ( "t", function ( player )
	local res = aCommunityValidate ( player, getPlayerUserName ( player ), getPlayerSerial ( player ) )
	outputChatBox ( "result: "..tostring ( res ) )
end )

function communityCall ( file, ... )

	c = coroutine.running()
	t = setTimer ( communityKill, 2000, 1, c )

	function temp ( ... )
		coroutine.resume ( c, ... )
		killTimer ( t )
	end

	callRemote ( file, temp, ... )
	return coroutine.yield()
end

]]