--
-- racewar_server.lua
--

Racewar = {}
Racewar.__index = Racewar

local chooseTeamDisplay		= nil
local chooseTeamLines		= {}
local newsDisplay			= nil	-- messages go here instead of the chatbox
local newsDisplayLines		= {}
local statusDisplay			= nil	-- Score and rounds left
local statusDisplayLines	= {}
local playerlist			= {}	-- All Players
local teamlist				= {}	-- All teams
local teamdata				= {}	-- team={score=0,blah=0}
local newsText				= { "", "", "", }
local roundCurrent			= 0		-- eg 1,2,3
local roundsTotal			= 0		-- eg 3
local bRoundJustEnded		= false

---------------------------------------------------------------------------
--
-- Events
--
--
---------------------------------------------------------------------------

addEventHandler('onResourceStart', g_ResRoot,
	function()
		Racewar.startup()
		for _,player in ipairs(getElementsByType('player')) do
			Racewar.handlePlayerJoin(player)
		end
	end
)

addEventHandler('onResourceStop', g_Root,
	function(resource)
		if 'map' == getResourceInfo(resource,'type') then
			Racewar.setBigMessage('')
		end
	end
)

addEvent('onMapStarting')
addEventHandler('onMapStarting', g_Root,
	function(mapInfo)
		Racewar.setModeAndMap( mapInfo.modename, mapInfo.name )
	end
)

addEvent('onPlayerFinish')
addEventHandler('onPlayerFinish', g_Root,
	function(rank, time)
		Racewar.playerFinished( source, rank )
	end
)

addEventHandler('onResourceStop', g_ResRoot,
	function()
		Racewar.shutdown()
	end
)

addEventHandler('onPlayerJoined', g_Root,
	function()
		Racewar.handlePlayerJoin(source)
	end
)

addEventHandler('onPlayerQuit', g_Root,
	function()
		Racewar.handlePlayerQuit(source)
	end
)

addEvent('onPostFinish', true)
addEventHandler('onPostFinish', g_Root,
	function()
		Racewar.roundEnd()
	end
)


---------------------------------------------------------------------------
--
-- Commands
--
--
---------------------------------------------------------------------------
addCommandHandler('teamname',
	function(player,command,...)
		Racewar.startChangeTeamNameVote(player, table.concat({...}, " ") )
	end
)

addCommandHandler('newwar',
	function(player,command,...)
		Racewar.startNewWarVote(player, table.concat({...}, " ") )
	end
)


---------------------------------------------------------------------------
--
-- Startup / shutdown
--
--
--
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Racewar.startup()
---------------------------------------------------------------------------
function Racewar.startup()
	cacheSettings()
	Racewar.output( 'Startup' )
	teamlist = {}
	teamlist[1] = createTeam ( "Red", 255, 0, 0 )
	teamlist[2] = createTeam ( "Blue", 0, 0, 255 )
	teamlist[3] = createTeam ( "Green", 0, 255, 0 )
	teamdata = {}
	for _,team in ipairs(teamlist) do
		teamdata[team] = {}
		teamdata[team].score  = 0
	end
	Racewar.updateChooseTeamDisplay()
	Racewar.updateNewsDisplay()
	Racewar.updateStatusDisplay()
end

---------------------------------------------------------------------------
-- Racewar.shutdown()
---------------------------------------------------------------------------
function Racewar.shutdown()
	Racewar.output( 'Shutdown' )
	-- Remove display
	Racewar.destroyChooseTeamDisplay()
	-- Remove teams
	table.each( teamlist, destroyElement )
	teamlist = {}
	teamdata = {}
end

---------------------------------------------------------------------------
-- Racewar.initializeNewWar()
---------------------------------------------------------------------------
function Racewar.initializeNewWar()
	roundCurrent = 1
	roundsTotal = g_Settings.numrounds
	if teamlist then
		table.each( teamlist, setTeamScore, 0 )
	end
	Racewar.updateStatusDisplay()
end


---------------------------------------------------------------------------
--
-- Map loading
--
--
--
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Racewar.setModeAndMap() -- Called when a new map has been loaded
---------------------------------------------------------------------------
function Racewar.setModeAndMap( raceModeName, mapName )
	if raceModeName == 'Sprint' then
		Racewar.roundStart()
	end
end


---------------------------------------------------------------------------
--
-- Points
--
--
--
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- convertPoints -- To look like something else, so it doesn't clash with other point systems
---------------------------------------------------------------------------
function convertPoints(pts)
	return g_Settings.ptsprefix .. pts .. g_Settings.ptspostfix
end


---------------------------------------------------------------------------
--
-- Players
--
--
--
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Racewar.handlePlayerJoin()
---------------------------------------------------------------------------
function Racewar.handlePlayerJoin( player )
	if isInPlayerList(player) then
		return
	end
	addToPlayerList(player)
	setTimer(
		function()
			if isInPlayerList(player) then
				Racewar.playerChooseTeam(player)
			end
		end,
		3000, 1 )
end

---------------------------------------------------------------------------
-- Racewar.playerFinished() -- Update team points
---------------------------------------------------------------------------
function Racewar.playerFinished( player, rank )
	local team = getPlayerTeam(player)
	if team then
		local othercount = 0
		-- count up others not finished who are not on the player's team
		for _,other in ipairs(playerlist) do
			if not isPlayerFinished(other) and team ~= getPlayerTeam(other) then
				othercount = othercount + 1
			end
		end
		--Racewar.outputChat( 'You beat ' .. othercount .. ' player' .. (othercount==1 and '' or 's') .. ' from other teams', player )
		local pointsEarned = othercount	-- getPlayerCount() - rank + 1
		Racewar.output( convertPoints(pointsEarned) .. " for '"..getTeamName(team).."' by "..getPlayerName(player) )
		addTeamScore(team,pointsEarned)
		Racewar.updateStatusDisplay()
	end
end

---------------------------------------------------------------------------
-- Racewar.handlePlayerQuit()
---------------------------------------------------------------------------
function Racewar.handlePlayerQuit( player )
	Racewar.changePlayerTeam( player, 0 )
	textDisplayRemoveObserver( chooseTeamDisplay, player )
	textDisplayRemoveObserver( newsDisplay, player )
	textDisplayRemoveObserver( statusDisplay, player )
	removeFromPlayerList(player)
end


---------------------------------------------------------------------------
--
-- Rounds
--
--
--
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Racewar.roundStart()
---------------------------------------------------------------------------
function Racewar.roundStart()
	local bNextRound		= roundCurrent > 0 and bRoundJustEnded
	local bRoundRestarted	= roundCurrent > 0 and not bRoundJustEnded
	local bNextWar			= roundCurrent == 0 or bNextRound and roundCurrent >= roundsTotal

	if bNextWar then
		Racewar.initializeNewWar()
		Racewar.output( 'Starting ' .. roundsTotal .. ' round war' )
	elseif bRoundRestarted then
		Racewar.output( 'Restarting round ' .. roundCurrent )
	elseif bNextRound then
		roundCurrent = roundCurrent + 1
		Racewar.output( 'Starting round ' .. roundCurrent )
	end
	Racewar.updateStatusDisplay()
	bRoundJustEnded = false
	bRoundJustStarted = true
end

---------------------------------------------------------------------------
-- Racewar.roundEnd()
---------------------------------------------------------------------------
function Racewar.roundEnd()
	if not bRoundJustStarted or roundCurrent == 0 then
		return
	end
	if roundCurrent >= roundsTotal then
		-- Show congrats message
		local ordered = getTeamsScoreSorted()
		local bestteam = ordered[1]
		local secondteam = ordered[2]
		if getTeamScore(bestteam) > getTeamScore(secondteam) then
			local congrats = getTeamName(bestteam) .. ' won the war'
			local teamplayers = ''
			local counter = 0
			--for i=1,30 do
				for _, player in ipairs(getPlayersInTeam(bestteam)) do
					counter = counter + 1
					if teamplayers ~= '' then
						if counter % 6 == 0 then
							teamplayers = teamplayers .. '\n'
						else
							teamplayers = teamplayers .. ', '
						end
					end
					teamplayers = teamplayers .. getPlayerName(player)
				end
			--end
			Racewar.output(congrats)
			local r,g,b = getTeamColor(bestteam)
			Racewar.setBigMessage( congrats, teamplayers, r,g,b )
		else
			Racewar.setBigMessage( 'War draw', '', 230,230,230 )
		end
	end
	bRoundJustEnded = true
	bRoundJustStarted = false
end


---------------------------------------------------------------------------
--
-- Status Display
--
--
--
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Racewar.updateStatusDisplay()
---------------------------------------------------------------------------
function Racewar.updateStatusDisplay()
	if not statusDisplay then
		statusDisplay = textCreateDisplay()
		local x=0.90
		local y=0.01 + 0.15
		statusDisplayLines[1] = textCreateTextItem ( '  RACEWAR Standings',		x, y, 'low', 255, 255, 160, 255, 1.2, 'center' )
		y = y + 0.017
		statusDisplayLines[2] = textCreateTextItem ( '	Round 1 of 3',			x, y, 'low', 160, 160, 160, 255, 1.0, 'center' )
		y = y + 0.014
		statusDisplayLines[3] = textCreateTextItem ( '1st  40 pts  Red team',	x, y, 'low', 240, 240, 240, 255, 1.4, 'center' )
		y = y + 0.02
		statusDisplayLines[4] = textCreateTextItem ( '2nd  10 pts  Green team',	x, y, 'low', 230, 230, 230, 255, 1.2, 'center' )
		y = y + 0.019
		statusDisplayLines[5] = textCreateTextItem ( '3rd   4 pts  Blue team',	x, y, 'low', 220, 220, 220, 255, 1.0, 'center' )
		statusDisplayLines[6] = textCreateTextItem ( '',					0.5, 0.6, 'low', 220, 220, 220, 255, 4.0, 'center' )
		statusDisplayLines[7] = textCreateTextItem ( '',					0.5, 0.7, 'low', 220, 220, 220, 255, 1.2, 'center' )
		for i,line in ipairs(statusDisplayLines) do
			textDisplayAddText ( statusDisplay, line )
		end
	end

	if roundCurrent == 0 then
		textItemSetText ( statusDisplayLines[2], '' )
		textItemSetText ( statusDisplayLines[3], 'Starts next map' )
		textItemSetText ( statusDisplayLines[4], '' )
		textItemSetText ( statusDisplayLines[5], '' )
	else
		textItemSetText ( statusDisplayLines[2], '	Round ' .. roundCurrent .. ' of ' .. roundsTotal .. '' )

		-- Order teams by points
		local ordered = getTeamsScoreSorted()

		local rank = 1
		local rankNext = 1
		for idx=1,#ordered do
			local team = ordered[idx]
			local r,b,g = getTeamColor(team)
			local grey = 250-idx*10
			r = math.lerp(r,grey,0.75)
			g = math.lerp(g,grey,0.75)
			b = math.lerp(b,grey,0.75)
			local score = getTeamScore(team)
			local name = getTeamName(team)
			local pos = idx==1 and '1st' or idx==2 and '2nd' or idx==3 and '3rd'
			local rankText = rank .. ( (rank < 10 or rank > 20) and ({ [1] = 'st', [2] = 'nd', [3] = 'rd' })[rank % 10] or 'th' )

			textItemSetText ( statusDisplayLines[2+idx], rankText..'  '..convertPoints(score)..'  '..name )
			textItemSetColor ( statusDisplayLines[2+idx], r,b,g,255 )

			rankNext = rankNext + 1
			if idx >= #ordered or getTeamScore(ordered[idx+1]) < score then
				rank = rankNext
			end
		end
	end
end

---------------------------------------------------------------------------
-- Racewar.destroyStatusDisplay()
---------------------------------------------------------------------------
function Racewar.destroyStatusDisplay()
	for i,line in ipairs(statusDisplayLines) do
		textDisplayRemoveText ( statusDisplay, line )
		textDestroyTextItem( line )
	end
	statusDisplayLines = {}
	textDestroyDisplay( statusDisplay )
	statusDisplay = nil
end

---------------------------------------------------------------------------
-- Racewar.setBigMessage()
---------------------------------------------------------------------------
function Racewar.setBigMessage(line1,line2,r,g,b)
	textItemSetText ( statusDisplayLines[6], line1 or '' )
	textItemSetText ( statusDisplayLines[7], line2 or '' )
	textItemSetColor ( statusDisplayLines[6], r or 255,g or 255,b or 255,255 )
	textItemSetColor ( statusDisplayLines[7], r or 255,g or 255,b or 255,210 )
end


---------------------------------------------------------------------------
--
-- News area
--
--
--
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Racewar.ouputNews()
---------------------------------------------------------------------------
function Racewar.ouputNews(text)
	table.remove( newsText, 1 )
	table.insert( newsText, text )
	Racewar.updateNewsDisplay()
end

---------------------------------------------------------------------------
-- Racewar.updateNewsDisplay()
---------------------------------------------------------------------------
function Racewar.updateNewsDisplay()
	if not newsDisplay then
		newsDisplay = textCreateDisplay()
		local x=0.85
		local y=0.182 + 0.1
		newsDisplayLines[1] = textCreateTextItem ( '1',	 x, y+0.000, 'low', 255, 255, 240, 132, 1, 'left' )
		newsDisplayLines[2] = textCreateTextItem ( '2',	 x, y+0.015, 'low', 255, 255, 240, 162, 1, 'left' )
		newsDisplayLines[3] = textCreateTextItem ( '3',	 x, y+0.030, 'low', 255, 255, 240, 192, 1, 'left' )
		for i,line in ipairs(newsDisplayLines) do
			textDisplayAddText ( newsDisplay, line )
		end
	end
	textItemSetText ( newsDisplayLines[1], newsText[1] )
	textItemSetText ( newsDisplayLines[2], newsText[2] )
	textItemSetText ( newsDisplayLines[3], newsText[3] )
end

---------------------------------------------------------------------------
-- Racewar.destroyNewsDisplay()
---------------------------------------------------------------------------
function Racewar.destroyNewsDisplay()
	for i,line in ipairs(newsDisplayLines) do
		textDisplayRemoveText ( newsDisplay, line )
		textDestroyTextItem( line )
	end
	newsDisplayLines = {}
	textDestroyDisplay( newsDisplay )
	newsDisplay = nil
end


---------------------------------------------------------------------------
--
-- Choosing teams
--
--
--
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Racewar.playerChooseTeam()
---------------------------------------------------------------------------
function Racewar.playerChooseTeam( player )
	textDisplayAddObserver( chooseTeamDisplay, player )
	bindKey ( player, "1", "down", Racewar.playerTeamChosen, 1 )
	bindKey ( player, "2", "down", Racewar.playerTeamChosen, 2 )
	bindKey ( player, "3", "down", Racewar.playerTeamChosen, 3 )
	bindKey ( player, "F3", "down", Racewar.playerTeamChosen, 0 )
end

---------------------------------------------------------------------------
-- Racewar.playerTeamChosen()
---------------------------------------------------------------------------
function Racewar.playerTeamChosen( player, key, keyState, teamIndex )
	textDisplayRemoveObserver( chooseTeamDisplay, player )
	unbindKey ( player, "1", "down", Racewar.playerTeamChosen )
	unbindKey ( player, "2", "down", Racewar.playerTeamChosen )
	unbindKey ( player, "3", "down", Racewar.playerTeamChosen )
	unbindKey ( player, "F3", "down", Racewar.playerTeamChosen )

	if not getPlayerTeam(player) then
		Racewar.outputChat( convertPoints(1) .." per enemy team player you beat to the finish line.", player )
	end

	Racewar.changePlayerTeam( player, teamIndex )

	bindKey ( player, "F3", "down", Racewar.playerChooseTeam )
end


---------------------------------------------------------------------------
-- Racewar.changePlayerTeam()
---------------------------------------------------------------------------
function Racewar.changePlayerTeam( player, newTeamIndex )
	local newTeam = teamlist[newTeamIndex]
	local oldTeam = getPlayerTeam(player)
	if newTeam ~= oldTeam then
		if newTeam then
			setPlayerTeam(player, newTeam )
			Racewar.output( getPlayerName(player) .. " has joined '" .. getTeamName(newTeam).. "'" )
			textDisplayAddObserver( newsDisplay, player )
			textDisplayAddObserver( statusDisplay, player )
		elseif oldTeam and isElement(oldTeam) then
			setPlayerTeam(player, nil )
			Racewar.output( getPlayerName(player) .. " has left '" .. getTeamName(oldTeam).. "'")
			textDisplayRemoveObserver( newsDisplay, player )
		end
	end
end

---------------------------------------------------------------------------
-- Racewar.updateChooseTeamDisplay()
---------------------------------------------------------------------------
function Racewar.updateChooseTeamDisplay()
	if not chooseTeamDisplay then
		local x=0.8
		local y=0.282
		chooseTeamDisplay = textCreateDisplay()
		chooseTeamLines[1] = textCreateTextItem ( 'R A C E W A R',					x, y+0.000, 'low', 255, 0, 0, 255, 3, 'center' )
		chooseTeamLines[2] = textCreateTextItem ( 'Select your team',				x, y+0.070, 'low', 255, 255, 0, 255, 2, 'center' )
		chooseTeamLines[3] = textCreateTextItem ( 'Press 1 to join A',				x, y+0.119, 'low', 255, 255, 255, 255, 1.4, 'center' )
		chooseTeamLines[4] = textCreateTextItem ( 'Press 2 to join B',				x, y+0.149, 'low', 255, 255, 255, 255, 1.4, 'center' )
		chooseTeamLines[5] = textCreateTextItem ( 'Press 3 to join C',				x, y+0.178, 'low', 255, 255, 255, 255, 1.4, 'center' )
		chooseTeamLines[6] = textCreateTextItem ( 'Press F3 not to join a team',	x, y+0.209, 'low', 200, 200, 200, 255, 1.4, 'center' )
		chooseTeamLines[7] = textCreateTextItem ( 'Press F3 to change team later',		x, y+0.239, 'low', 200, 200, 0, 255, 1.4, 'center' )
		chooseTeamLines[8] = textCreateTextItem ( 'Press F9 for help',				x, y+0.269, 'low', 200, 200, 0, 255, 1.4, 'center' )
		for i,line in ipairs(chooseTeamLines) do
			textDisplayAddText ( chooseTeamDisplay, line )
		end
	end
	textItemSetText ( chooseTeamLines[3], "Press 1 to join '" ..getTeamName(teamlist[1]).. "'" )
	textItemSetText ( chooseTeamLines[4], "Press 2 to join '" ..getTeamName(teamlist[2]).. "'" )
	textItemSetText ( chooseTeamLines[5], "Press 3 to join '" ..getTeamName(teamlist[3]).. "'" )
end

---------------------------------------------------------------------------
-- Racewar.destroyChooseTeamDisplay()
---------------------------------------------------------------------------
function Racewar.destroyChooseTeamDisplay()
	for i,line in ipairs(chooseTeamLines) do
		textDisplayRemoveText ( chooseTeamDisplay, line )
		textDestroyTextItem( line )
	end
	chooseTeamLines = {}
	textDestroyDisplay( chooseTeamDisplay )
	chooseTeamDisplay = nil
end


----------------------------------------------------------------------------
--
-- Changing Team Name
--
--
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Racewar.startChangeTeamNameVote
----------------------------------------------------------------------------
function Racewar.startChangeTeamNameVote(player, newName)

	local team = getPlayerTeam(player)
	if not team then
		Racewar.outputChat( 'You are not in a team.', player )
		return
	end

	newName = tostring(newName)
	if newName:len() < 3 or newName:len() > 50 then
		Racewar.outputChat( 'Team name must be between 3 and 50 characters long.', player )
		return
	end


	local result, code = exports.votemanager:startPoll({})

	if code == 10 then	-- pollAlreadyRunning = 10
		Racewar.outputChat( "Can't change team name while a vote is running.", player )
		return
	end

	exports.votemanager:stopPoll()

	-- Actual vote started here
	local pollDidStart = exports.votemanager:startPoll {
			title="Do you want to change the team name to '" .. newName.. "'",
			percentage=51,
			timeout=10,
			allowchange=true,
			adjustwidth=50,
			visibleTo=team,
			[1]={'Yes', 'teamNameVoteResult', team, true, team, newName },
			[2]={'No', 'teamNameVoteResult', team, false;default=true},
	}

end

----------------------------------------------------------------------------
-- event teamNameVoteResult -- Called from the votemanager when the poll has completed
----------------------------------------------------------------------------
addEvent('teamNameVoteResult')
addEventHandler('teamNameVoteResult', getRootElement(),
	function( votedYes, team, newName )
		if votedYes and team and newName then
			Racewar.output( "Team '"..getTeamName(team).."' is now called '"..newName.."'" )
			setTeamName(team,newName)
			Racewar.updateChooseTeamDisplay()
			Racewar.updateStatusDisplay()
		else
			Racewar.outputChat( 'Team name vote result was [No].', team )
		end
	end
)


----------------------------------------------------------------------------
--
-- Start new war vote
--
--
--
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Racewar.startNewWarVote
----------------------------------------------------------------------------
function Racewar.startNewWarVote(player)

	local result, code = exports.votemanager:startPoll({})

	if code == 10 then	-- pollAlreadyRunning = 10
		Racewar.outputChat( "Can't start a new war vote while another vote is running.", player )
		return
	end

	exports.votemanager:stopPoll()

	-- Actual vote started here
	local pollDidStart = exports.votemanager:startPoll {
			title="Do you want to start a new war?",
			percentage=51,
			timeout=10,
			allowchange=true,
			adjustwidth=50,
			visibleTo=getRootElement(),
			[1]={'Yes', 'newWarVoteResult', getRootElement(), true},
			[2]={'No', 'newWarVoteResult', getRootElement(), false;default=true},
	}

end

----------------------------------------------------------------------------
-- event teamNameVoteResult -- Called from the votemanager when the poll has completed
----------------------------------------------------------------------------
addEvent('newWarVoteResult')
addEventHandler('newWarVoteResult', getRootElement(),
	function( votedYes )
		if votedYes then
			Racewar.initializeNewWar()
			Racewar.output( 'Starting new ' .. roundsTotal .. ' round war' )
		else
			Racewar.outputChat( 'New war vote result was [No].', g_Root )
		end
	end
)


---------------------------------------------------------------------------
--
-- Player List
--
--
--
---------------------------------------------------------------------------
function addToPlayerList( player )
	table.insert(playerlist,player)
end

function removeFromPlayerList( player )
	table.removevalue(playerlist,player)
end

function isInPlayerList( player )
	return table.find(playerlist,player)
end


---------------------------------------------------------------------------
--
-- Team Score
--
--
--
---------------------------------------------------------------------------
function getTeamScore( team )
	return teamdata[team].score
end

function setTeamScore( team, score )
	teamdata[team].score = score
end

function addTeamScore( team, score )
	teamdata[team].score = teamdata[team].score + score
end

function getTeamsScoreSorted()
	local ordered = table.deepcopy(teamlist)
	table.sort(ordered, function(a,b) return(getTeamScore(a) > getTeamScore(b)) end)
	return ordered
end


---------------------------------------------------------------------------
--
-- Misc
--
--
--
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Racewar.output()
---------------------------------------------------------------------------
function Racewar.output(text)
	--outputChatBox ( "#C0C0C0Racewar: #FFFF00" .. text, getRootElement(), 255, 255, 255, true )
	Racewar.ouputNews(text)
end

function Racewar.outputChat(text,visibleTo)
	outputChatBox ( "#C0C0C0Racewar: #FFFF00" .. text, visibleTo or getRootElement(), 255, 255, 255, true )
end

function isPlayerFinished(player)
	return getElementData(player, 'race.finished')
end


---------------------------------------------------------------------------
--
-- Settings
--
--
--
---------------------------------------------------------------------------
function cacheSettings()
	g_Settings = {}
	g_Settings.numrounds	= getNumber('numrounds','3')
	g_Settings.ptsprefix	= getString('ptsprefix','$')
	g_Settings.ptspostfix	= getString('ptspostfix',',000')
end

-- Initial cache
addEventHandler('onResourceStart', g_ResRoot,
	function()
		cacheSettings()
	end
)

-- React to admin panel changes
addEvent ( "onSettingChange" )
addEventHandler('onSettingChange', g_ResRoot,
	function(name, oldvalue, value, playeradmin)
		cacheSettings()
		Racewar.updateStatusDisplay()
	end
)

