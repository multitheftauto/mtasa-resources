g_Root = getRootElement()
local g_FragLimit,g_TimeLimit,g_RespawnTime,g_default_deathpickups,g_MissionTimer,g_FragLimitText
local announcementText,processWasted

local defaults = {
	fragLimit = 10,
	timeLimit = 600000, --15 minutes
	respawnTime = 10000,
}

local function sortingFunction (a,b)
	return (getElementData(a,"Score") or 0) > (getElementData(b,"Score") or 0)
end

addEventHandler ( "onGamemodeStart", g_Root,
	function()
		teams = {
			createTeam ( "Red", 255, 0, 0 ),
			createTeam ( "Blue", 0, 0, 255 ),
		}
		g_default_deathpickups = get"deathpickups.only_current"
		set("*deathpickups.only_current",true)
		exports.scoreboard:addScoreboardColumn ( "Rank", g_Root, 1, 0.05 )
		exports.scoreboard:addScoreboardColumn ( "Score" )
		announcementText = dxText:create("",0.5,0.1)
		announcementText:font("bankgothic")
		announcementText:type("stroke",1)
		addEventHandler ( "onPlayerTeamSwitch", g_Root, processPlayerSpawn )
	end
)

addEventHandler ( "onGamemodeStop", g_Root,
	function()
		set("deathpickups.only_current",g_default_deathpickups)
	end
)

function dmMapStart(resource,mapRoot)
	local resourceName = getResourceName ( resource )
	for i,player in ipairs(getElementsByType"player") do
		setElementData ( player, "Score", 0 )
	end
	g_MapResource = resource
	g_MapRoot = source or mapRoot
	g_FragLimit = tonumber(get("frag_limit")) and math.floor(tonumber(get("dm_frag_limit"))) or defaults.fragLimit
	g_TimeLimit = tonumber(get("time_limit")) and math.floor(tonumber(get("dm_time_limit"))) or defaults.timeLimit
	g_RespawnTime = tonumber(get("respawn_time")) and math.floor(tonumber(get("dm_respawn_time"))) or defaults.respawnTime
	addEventHandler ( "onPlayerWasted", g_Root, processWasted )
	processSpawnStart()
	--Start our timer
	g_MissionTimer = exports.missiontimer:createMissionTimer (g_TimeLimit,true,true,0.5,20,true,"default-bold",1)
	addEventHandler ( "onMissionTimerElapsed", g_MissionTimer, onTimeElapsed )
	g_FragLimitText = dxText:create ( "Frag Limit: "..g_FragLimit, 0.5, 35, "default-bold", 1 )
	g_FragLimitText:align("center","top")
	g_FragLimitText:type("stroke",1)
	g_FragLimitText:sync()
	setElementData ( teams[1], "Score", 0 )
	setElementData ( teams[2], "Score", 0 )
	setElementData ( teams[1], "Rank", "-" )
	setElementData ( teams[2], "Rank", "-" )
end
addEventHandler ( "onGamemodeMapStart", g_Root, dmMapStart )

addEventHandler ( "onPlayerJoin", g_Root,
	function()
		processRanks()
		if g_FragLimitText then
			g_FragLimitText:sync(source)
		end
		if announcementText then
			announcementText:sync(source)
		end
		exports.teammanager:handlePlayer ( source, teams, "Team Deathmatch" )
	end
)

function onTimeElapsed()
	local teams = getElementsByType"team"
	table.sort ( teams, sortingFunction )
	if getElementData ( teams[1], "Score" ) == getElementData ( teams[2], "Score" ) then
		processEnd ( false, true )
		return
	end
	processEnd(teams[1],false)
end

--Process deaths
function processWasted( totalammo, killer, killerweapon, bodypart )
	if killer then --Give the killer credit
		local killerTeam = getPlayerTeam(killer)
		killer = (getElementType(killer) == "player") and killer or getVehicleOccupant(killer)
		if killer == source then --He killed himself. 
			setElementData ( killerTeam, "Score", getElementData(killerTeam,"Score") - 1 )
			setElementData ( killer, "Score", getElementData(killer,"Score") - 1 )
		else
			local newScore = getElementData(killerTeam,"Score") + 1
			setElementData ( killerTeam, "Score", newScore )
			setElementData ( killer, "Score",  getElementData(killer,"Score") )
			if newScore == g_FragLimit then
				return processEnd(killerTeam)
			end
		end
	else
		local sourceTeam = getPlayerTeam(source)
		--Died of other causes
		setElementData ( sourceTeam, "Score", getElementData(sourceTeam,"Score") - 1 )
	end
	processRanks()
	triggerClientEvent ( source, "requestCountdown", source, g_RespawnTime )
	setTimer ( processPlayerSpawn, g_RespawnTime, 1, source )
end

--Calculate the ranks
function processRanks()
	local ranks = {}
	local teams = getElementsByType"team"
	table.sort ( teams , sortingFunction )
	--Take into account people with the same score
	for i,team in ipairs(teams ) do
		local previousPlayer = teams [i-1]
		if teams[i-1] then
			local previousScore = getElementData ( previousPlayer, "Score" )
			local playerScore = getElementData ( team, "Score" ) 
			if previousScore == playerScore then
				setElementData ( team, "Rank", previousScore )
			else
				setElementData ( team, "Rank", i )
			end
		else
			setElementData ( team, "Rank", 1 )
		end
	end	
end


function processEnd(winner,draw)
	removeEventHandler ( "onPlayerWasted", g_Root, processWasted )
	g_FragLimitText:visible(false)
	g_FragLimitText:sync()
	g_FragLimitText = nil
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
	announcementText:text(getTeamName(winner).." has won the match!")
	announcementText:color(getTeamColor(winner))
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
