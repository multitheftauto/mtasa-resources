g_Root = getRootElement()
local CAMERA_LOAD_DELAY = 6000 --Time left for the camera to stream in the map.
local g_FragLimit,g_TimeLimit,g_RespawnTime,g_default_deathpickups,g_MissionTimer,g_FragLimitText,g_ProcessWastedHandler
local announcementText,processWasted
mapTimers = {}

local defaults = {
	fragLimit = 10,
	timeLimit = 600, --10 minutes
	respawnTime = 10,
	spawn_weapons = "22:100",
}

local function sortingFunction (a,b)
	return (getElementData(a,"Score") or 0) > (getElementData(b,"Score") or 0)
end

addEventHandler ( "onGamemodeStart", g_Root,
	function()
		g_default_deathpickups = get"deathpickups.only_current"
		set("*deathpickups.only_current",true)
		exports.scoreboard:addScoreboardColumn ( "Rank", g_Root, 1, 0.05 )
		exports.scoreboard:addScoreboardColumn ( "Score" )
		announcementText = dxText:create("",0.5,0.1)
		announcementText:font("bankgothic")
		announcementText:type("stroke",1)
	end
)

addEventHandler ( "onGamemodeStop", g_Root,
	function()
		set("deathpickups.only_current",g_default_deathpickups)
		for i,player in ipairs(getElementsByType"player") do
			removeElementData ( player, "Score" )
			removeElementData ( player, "Rank" )
		end
	end
)

function dmMapStart(resource,mapRoot)
	local resourceName = getResourceName ( resource )
	for i,player in ipairs(getElementsByType"player") do
		setElementData ( player, "Score", 0 )
		setElementData ( player, "Rank", "-" )
	end
	g_MapResource = resource
	g_MapRoot = source or mapRoot
	g_FragLimit = tonumber(get(resourceName..".frag_limit")) and math.floor(tonumber(get(resourceName..".frag_limit"))) or defaults.fragLimit
	g_TimeLimit = (tonumber(get(resourceName..".time_limit")) and math.floor(tonumber(get(resourceName..".time_limit"))) or defaults.timeLimit)*1000
	g_RespawnTime = (tonumber(get(resourceName..".respawn_time")) and math.floor(tonumber(get(resourceName..".respawn_time"))) or defaults.respawnTime)*1000
	g_Weapons = {}
	local weaponsString = get(resourceName..".spawn_weapons") or defaults.spawn_weapons
	for i,weaponSub in ipairs(split(weaponsString,44)) do
		local weapon = tonumber(gettok ( weaponSub, 1, 58 ))
		local ammo = tonumber(gettok ( weaponSub, 2, 58 ))
		if weapon and ammo then
			g_Weapons[weapon] = ammo
		end
	end
	if (not g_ProcessWastedHandler) then
		addEventHandler ( "onPlayerWasted", g_Root, processWasted )
	end
	g_ProcessWastedHandler = true
	processSpawnStart(CAMERA_LOAD_DELAY)
	setTimer ( initiateGame, CAMERA_LOAD_DELAY, 1 )
end
addEventHandler ( "onGamemodeMapStart", g_Root, dmMapStart )

function initiateGame()
	--Start our timer
	g_MissionTimer = exports.missiontimer:createMissionTimer (g_TimeLimit,true,true,0.5,20,true,"default-bold",1)
	addEventHandler ( "onMissionTimerElapsed", g_MissionTimer, onTimeElapsed )
	g_FragLimitText = dxText:create ( "Frag Limit: "..g_FragLimit, 0.5, 35, "default-bold", 1 )
	g_FragLimitText:align("center","top")
	g_FragLimitText:type("stroke",1)
	g_FragLimitText:sync()
end

addEventHandler ( "onPlayerJoin", g_Root,
	function()
		setCameraMatrix ( source, camX, camY, camZ, lookX, lookY, lookZ )
		processRanks()
		if g_FragLimitText then
			g_FragLimitText:sync(source)
		end
		if announcementText then
			announcementText:sync(source)
		end
	end
)

function onTimeElapsed()
	local players = getElementsByType"player"
	table.sort ( players, sortingFunction )
	if players[2] and getElementData ( players[1], "Score" ) == getElementData ( players[2], "Score" ) then
		processEnd ( false, true )
		return
	end
	processEnd(players[1],false)
end

--Process deaths
function processWasted( totalammo, killer, killerweapon, bodypart )
	if killer and (getElementType(killer) == "player" or getElementType(killer) == "vehicle") then --Give the killer credit
		killer = (getElementType(killer) == "player") and killer or getVehicleOccupant(killer)
		if killer == source then --He killed himself.
			setElementData ( killer, "Score", getElementData(killer,"Score") - 1 )
		else
			local newScore = getElementData(killer,"Score") + 1
			setElementData ( killer, "Score", newScore )
			if newScore == g_FragLimit then
				return processEnd(killer)
			end
		end
	else
		--Died of other causes
		setElementData ( source, "Score", getElementData(source,"Score") - 1 )
	end
	processRanks()
	triggerClientEvent ( source, "requestCountdown", source, g_RespawnTime )
	table.insert ( mapTimers, setTimer ( processPlayerSpawn, g_RespawnTime, 1, source ) )
end

--Calculate the ranks
function processRanks()
	local ranks = {}
	local players = getElementsByType"player"
	table.sort ( players, sortingFunction )
	--Take into account people with the same score
	for i,player in ipairs(players) do
		local previousPlayer = players[i-1]
		if players[i-1] then
			local previousScore = getElementData ( previousPlayer, "Score" )
			local playerScore = getElementData ( player, "Score" )
			if previousScore == playerScore then
				setElementData ( player, "Rank", getElementData( previousPlayer, "Rank" ) )
			else
				setElementData ( player, "Rank", i )
			end
		else
			setElementData ( player, "Rank", 1 )
		end
	end
end


function processEnd(winner,draw)
	removeEventHandler ( "onPlayerWasted", g_Root, processWasted )
	g_FragLimitText:visible(false)
	g_FragLimitText:sync()
	g_FragLimitText = nil
	for i,timer in ipairs(mapTimers) do
		killTimer ( timer )
	end
	mapTimers = {}
	destroyElement(g_MissionTimer)
	setTimer ( reboot, 15000, 1 )
	if not winner then
		if draw then
			for i,player in ipairs(getElementsByType"player") do
				toggleAllControls(player,true,true,false)
				exports.scoreboard:setPlayerScoreboardForced ( player, true )
				fadeCamera(player,false,10,0,0,0)
			end
			announcementText:visible(true)
			announcementText:text("The match was a draw!")
			announcementText:color(255,255,255,255)
			announcementText:sync()
			return
		else
			return
		end
	end
	--Freeze all players,except the winner
	for i,player in ipairs(getElementsByType"player") do
		if player ~= winner then
			setCameraTarget(player,winner)
			toggleAllControls(player,true,true,false)
		end
		exports.scoreboard:setPlayerScoreboardForced ( player, true )
		fadeCamera(player,false,10,0,0,0)
	end
	announcementText:visible(true)
	announcementText:text(getPlayerName(winner).." has won the match!")
	announcementText:color(getPlayerNametagColor(winner))
	announcementText:sync()
end

function reboot()
	for i,player in ipairs(getElementsByType"player") do
		exports.scoreboard:setPlayerScoreboardForced ( player, false )
	end
	announcementText:visible(false)
	announcementText:sync()
	dmMapStart(g_MapResource,g_MapRoot)
end

addEventHandler ( "onPickupUse", root,
	function ( player )
		if getPickupType ( source ) == 2 and getPickupWeapon ( source ) == 22 then
			if getPedWeapon ( player ) == 22 and getPedTotalAmmo ( player ) ~= 0 then
				setColtStat ( true, player )
			else
				triggerClientEvent ( player, "onColtPickup", player, source )
			end
		end
	end
)

addEvent ( "doSetColtStat", true )
function setColtStat ( fullSkill, player )
	local stat = fullSkill and 999 or 900
	player = player or source
	setPedStat ( player, 69, stat )
end
addEventHandler ( "doSetColtStat", g_Root, setColtStat )
