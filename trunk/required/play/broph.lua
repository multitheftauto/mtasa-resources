addEventHandler("onResourceStart", resourceRoot,
	function()
		for i,player in ipairs(getElementsByType("player")) do
			spawn(player)
		end
	end
)

function spawn(player)
	if not isElement(player) then return end
	repeat until spawnPlayer ( player, -711+math.random(1,5), 957+math.random(5,9), 12.4, 90, math.random(9,288) )
	fadeCamera(player, true)
	setCameraTarget(player, player)
end

addEventHandler("onPlayerJoin", root,
	function()
		spawn(source)
	end
)

addEventHandler("onPlayerWasted", root,
	function()
		setTimer(spawn, 1800, 1, source)
	end
)