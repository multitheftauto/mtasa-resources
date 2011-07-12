local stats = {
    [ 69 ] = 500,
    [ 70 ] = 999,
    [ 71 ] = 999,
    [ 72 ] = 999,
    [ 73 ] = 500,
    [ 74 ] = 999,
    [ 75 ] = 500,
    [ 76 ] = 999,
    [ 77 ] = 999,
    [ 78 ] = 999,
    [ 79 ] = 999,
	[ 160 ] = 999,
	[ 229 ] = 999,
	[ 230 ] = 999
}

local function applyStats(player)
	for stat,value in pairs(stats) do
		setPedStat(player, stat, value)
	end
end

addEventHandler('onResourceStart', resourceRoot,
	function()
		for i,player in ipairs(getElementsByType('player')) do
			applyStats(player)
		end
	end
)

addEventHandler('onPlayerJoin', root,
	function()
		applyStats(source)
	end
)

addEventHandler('onGamemodeMapStart', root,
	function()
		for _,player in ipairs(getElementsByType('player')) do
			applyStats(player)
		end	
	end
)

addEventHandler('onPlayerSpawn', root,
	function()
		applyStats(source)
	end
)
