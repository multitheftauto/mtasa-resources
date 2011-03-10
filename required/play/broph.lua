addEventHandler("onResourceStart", resourceRoot,
	function()
		for i,player in ipairs(getElementsByType("player")) do
			spawn(player)
		end
		setGravity(0.008)
		setGameSpeed(1)
		setTime(12, 0)
		setWeather(0)
	end
)

function spawn(player)
	if not isElement(player) then return end
	setElementInterior(player, 0)
	setElementDimension(player, 0)
	showPlayerHudComponent(player, "ammo", true)
	showPlayerHudComponent(player, "armour", true)
	showPlayerHudComponent(player, "breath", true)
	showPlayerHudComponent(player, "clock", true)
	showPlayerHudComponent(player, "health", true)
	showPlayerHudComponent(player, "money", true)
	showPlayerHudComponent(player, "radar", true)
	showPlayerHudComponent(player, "weapon", true)
	repeat until spawnPlayer ( player, -711+math.random(1,5), 957+math.random(5,9), 12.4, 90, math.random(9,288) )
	fadeCamera(player, true)
	setCameraTarget(player, player)
	showChat(player, true)
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