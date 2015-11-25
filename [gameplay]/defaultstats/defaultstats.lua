local stats = {
	[69] = 500,  -- Pistol
	[70] = 999,  -- Silenced pistol
	[71] = 999,  -- Desert eagle
	[72] = 999,  -- Shotgun
	[73] = 500,  -- Sawnoff, 999 for duel wield
	[74] = 999,  -- Spas-12
	[75] = 500,  -- Micro-uzi & Tec-9, 999 for duel wield
	[76] = 999,  -- MP5
	[77] = 999,  -- AK-47
	[78] = 999,  -- M4
	[79] = 999,  -- Sniper rifle & country rifle
	[160] = 999, -- Driving
	[229] = 999, -- Biking
	[230] = 999  -- Cycling
}

local function applyStatsForPlayer(player)
	for stat, value in pairs(stats) do
		player:setStat(stat, value)
	end
end

local function applyStatsForEveryone()
	for _, player in pairs(Element.getAllByType "player") do
		applyStatsForPlayer(player)
	end
end
addEventHandler("onResourceStart", resourceRoot, applyStatsForEveryone)
addEventHandler("onGamemodeMapStart", root, applyStatsForEveryone)

local function applyStatsForSource()
	applyStatsForPlayer(source)
end
addEventHandler("onPlayerJoin", root, applyStatsForSource)
addEventHandler("onPlayerSpawn", root, applyStatsForSource)
