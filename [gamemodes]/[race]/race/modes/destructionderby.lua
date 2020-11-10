DestructionDerby = setmetatable({}, RaceMode)
DestructionDerby.__index = DestructionDerby

DestructionDerby:register('Destruction derby')

function DestructionDerby:isApplicable()
	return not RaceMode.checkpointsExist() and RaceMode.getMapOption('respawn') == 'none'
end

function DestructionDerby:getPlayerRank(player)
	return #getActivePlayers()
end

-- Copy of old updateRank
function DestructionDerby:updateRanks()
	for i,player in ipairs(g_Players) do
		if not isPlayerFinished(player) then
			local rank = self:getPlayerRank(player)
			if not rank or rank > 0 then
				setElementData(player, 'race rank', rank)
			end
		end
	end
	-- Make text look good at the start
	if not self.running then
		for i,player in ipairs(g_Players) do
			setElementData(player, 'race rank', '' )
			setElementData(player, 'checkpoint', '' )
		end
	end
end

function DestructionDerby:onPlayerWasted(player)
	if isActivePlayer(player) then
		self:handleFinishActivePlayer(player)
		if getActivePlayerCount() <= 1 then
			RaceMode.endMap()
		else
			TimerManager.createTimerFor("map",player):setTimer(clientCall, 2000, 1, player, 'Spectate.start', 'auto')
		end
	end
	RaceMode.setPlayerIsFinished(player)
	showBlipsAttachedTo(player, false)
end

function DestructionDerby:onPlayerQuit(player)
	if isActivePlayer(player) then
		self:handleFinishActivePlayer(player)
		if getActivePlayerCount() <= 1 then
			RaceMode.endMap()
		end
	end
end

function DestructionDerby:handleFinishActivePlayer(player)
	-- Update ranking board for player being removed
	if not self.rankingBoard then
		self.rankingBoard = RankingBoard:create()
		self.rankingBoard:setDirection( 'up', getActivePlayerCount() )
	end
	local timePassed = self:getTimePassed()
	self.rankingBoard:add(player, timePassed)
	-- Do remove
	local rank = self:getPlayerRank(player)
	finishActivePlayer(player)
	if rank and rank > 1 then
		triggerEvent( "onPlayerFinishDD",player,tonumber( rank ) )
	end
	-- Update ranking board if one player left
	local activePlayers = getActivePlayers()
	if #activePlayers == 1 then
		self.rankingBoard:add(activePlayers[1], timePassed)
		showMessage(getPlayerName(activePlayers[1]) .. ' is the final survivor!', 0, 255, 0)
		triggerEvent( "onPlayerWinDD",activePlayers[1] )
	end
end


------------------------------------------------------------
-- activePlayerList stuff
--

function isActivePlayer( player )
	return table.find( g_CurrentRaceMode.activePlayerList, player )
end

function addActivePlayer( player )
	table.insertUnique( g_CurrentRaceMode.activePlayerList, player )
end

function removeActivePlayer( player )
	table.removevalue( g_CurrentRaceMode.activePlayerList, player )
end

function finishActivePlayer( player )
	table.removevalue( g_CurrentRaceMode.activePlayerList, player )
	table.insertUnique( g_CurrentRaceMode.finishedPlayerList, _getPlayerName(player) )
end

function getFinishedPlayerCount()
	return #g_CurrentRaceMode.finishedPlayerList
end

function getActivePlayerCount()
	return #g_CurrentRaceMode.activePlayerList
end

function getActivePlayers()
	return g_CurrentRaceMode.activePlayerList
end

