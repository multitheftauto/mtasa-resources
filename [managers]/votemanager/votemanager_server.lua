local activePoll

local pollTimer
local defaultConfig = {}
local rootElement = getRootElement()
local thisResourceRoot = getResourceRootElement(getThisResource())

addEvent "onPollStart"
addEvent "onPollStop"
addEvent "onPollEnd"
addEvent("onClientSendVote", true)

--this handler stores the default manager config
addEventHandler("onResourceStart", thisResourceRoot,
	function ()
		defaultConfig.timeout = get("default_timeout")
		defaultConfig.percentage = get("default_percentage")
		defaultConfig.maxnominations = get("default_maxnominations")
		defaultConfig.allowchange = get("default_allowchange")
	end
)

-- getPlayerUserName can return false. Make sure something useful is returned.
function getPlayerUserNameSafe(client)
    return getPlayerUserName(client) or getPlayerName(client)
end

function startPoll(pollData)
	--if there's a poll already
	if activePoll then
		return false, errorCode.pollAlreadyRunning
	end

	--check there's at least two options
	if #pollData < 2 then
		return false, errorCode.lessThanTwoOptions
	end

	--save this incase a random item needs to be selected after this poll has finished
	setCurrentPollSize( #pollData )

	--check there's a title
	if type(pollData.title) ~= "string" then
		return false, errorCode.invalidTitle
	end

	--check timeout's not invalid
	if type(pollData.timeout) ~= "number" or pollData.timeout < 0 then
		pollData.timeout = defaultConfig.timeout
	end
	--check allowchange's not invalid
	if type(pollData.allowchange) ~= "boolean" then
		pollData.allowchange = defaultConfig.allowchange
	end
	--check percentage's not invalid
	if type(pollData.percentage) ~= "number" or pollData.percentage <= 0 or pollData.percentage > 100 then
		pollData.percentage = defaultConfig.percentage
	end
	--check percentage's not invalid
	if type(pollData.maxnominations) ~= "number" or pollData.maxnominations < 1 then
		pollData.maxnominations = defaultConfig.maxnominations
	end
	--create the table of voted options
	pollData.votedOption = {}
	--create the table of allowed players
	local allowedPlayers = {}
	local playerAmount = 0
	if type(pollData.visibleTo) == "table" then
		for k,player in ipairs(pollData.visibleTo) do
			if isElement(player) and getElementType(player) == "player" then
				allowedPlayers[player] = true
				playerAmount = playerAmount + 1
			end
		end
	elseif isElement(pollData.visibleTo) and getElementType(pollData.visibleTo) == "team"  then
		for k,player in ipairs(getPlayersInTeam(pollData.visibleTo)) do
			allowedPlayers[player] = true
			playerAmount = playerAmount + 1
		end
	elseif isElement(pollData.visibleTo) or pollData.visibleTo == nil then
		for k,player in ipairs(getElementsByType("player",pollData.visibleTo or rootElement)) do
			allowedPlayers[player] = true
			playerAmount = playerAmount + 1
		end
	else
		return false, errorCode.invalidVisibleTo
	end

	--check that there's at least one voter
	if playerAmount < 1 then
		return false, errorCode.noVoters
	end

	--fire the poll start event, and stop here if it was cancelled
	local result = triggerEvent("onPollStart", thisResourceRoot)
	if result == false then
		return false, errorCode.startCancelled
	end

	outputServerLogMaybe( string.format("Vote started '%s'", pollData.title) )

	pollData.playersWhoVoted = 0
	pollData.maxVoters = playerAmount
	--make pollData.allowedPlayers a reference to the player table
	pollData.allowedPlayers = allowedPlayers
	--set as first nomination if it is
	pollData.nomination = pollData.nomination or 1

	--set as the current active poll
	activePoll = pollData
	activePoll.finishesAt = getTickCount() + activePoll.timeout * 1000

	--create the poll tables that will be sent to the clients
	activePoll.clientData = {
		title=activePoll.title,
		allowchange=activePoll.allowchange,
		nomination=activePoll.nomination,
	}
	activePoll.clientOptions = {}
	for i,option in ipairs(activePoll) do
		--initialize the vote count
		option.votes = 0
		--if the option's well-formed, insert it
		if type(option) == "table" and type(option[1]) == "string" then
			table.insert(activePoll.clientOptions, option[1])
		end
	end

	--send the poll data (players are its keys, not values)
	for player in pairs(activePoll.allowedPlayers) do
		sendPoll(player)
	end

	--prepare to end the poll
	pollTimer = setTimer(endPoll, activePoll.timeout * 1000, 1)
	return true
end

function stopPoll()
	--ignore if there's no poll
	if not activePoll then
		return false, errorCode.noPollRunning
	end

	--fire the poll stop event, and stop here if it was cancelled
	local result = triggerEvent("onPollStop", thisResourceRoot)
	if result == false then
		return false, errorCode.stopCancelled
	end

	--send the signal to all viewers
	for player in pairs(activePoll.allowedPlayers) do
		triggerClientEvent(player, "doStopPoll", rootElement)
	end

	--unload the poll
	activePoll = nil
	if pollTimer then
		killTimer(pollTimer)
		pollTimer = nil
	end
	return true
end

function sendPoll(element)
	local timeLeft = activePoll.finishesAt - getTickCount()
	triggerClientEvent(element, "doShowPoll", rootElement, activePoll.clientData, activePoll.clientOptions, timeLeft)
end

function recheckVotes()
	--quit without checking if there aren't enough votes yet
	if (activePoll.playersWhoVoted / activePoll.maxVoters)*100 < activePoll.percentage then
		return
	end
	--get the number of votes needed
	local votesNeeded = activePoll.maxVoters * activePoll.percentage / 100
	--if any option exceeds that number, it wins
	for index,option in ipairs(activePoll) do
		if option.votes >= votesNeeded then
			local percent = option.votes * 100 / math.max(1,activePoll.maxVoters)
			outputServerLogMaybe( string.format("Vote finished early as %d%% (%d/%d players) reached for option [%s]", percent, option.votes, activePoll.maxVoters, tostring(option[1])) )
			endPoll(index)
			break
		end
	end

    -- If no change allowed and everyone has voted, end poll quicker
    if activePoll and not activePoll.allowchange then
        if activePoll.playersWhoVoted == activePoll.maxVoters then
            if pollTimer then
                killTimer(pollTimer)
                pollTimer = setTimer(endPoll, 500, 1)
            end
        end
    end
end

function endPoll(chosenOption)
	--ignore if there's no poll
	if not activePoll then
		return false
	end

	--kill the timer to the function
	if pollTimer then
		killTimer(pollTimer)
		pollTimer = nil
	end

	--stop client polls
	for player in pairs(activePoll.allowedPlayers) do
		triggerClientEvent(player, "doStopPoll", rootElement)
	end

	--if any option was elected, finish
	if chosenOption then
		return applyPollResults(chosenOption)
	else
		-- No option has enough percent using votes/totalplayers - See if any option will win using votes/totalvoters

		-- Make a list of the highest scoring options
		local winningIndices = {}
		local highestVotes = 0
		for idx, option in ipairs(activePoll) do
			if option.votes > highestVotes then
				highestVotes = option.votes
				winningIndices = {}
			end
			if option.votes == highestVotes then
				table.insert( winningIndices, idx )
			end
		end

		-- Output some stuff for the server log
		local winningNames = ""
		for _,indici in ipairs(winningIndices) do
			winningNames = winningNames .. "[" .. activePoll[indici][1] .. "]"
		end
		local percent = highestVotes * 100 / math.max(1,activePoll.playersWhoVoted)
		outputServerLogMaybe( string.format("Vote finished with %d%% (%d/%d voters) for the most popular option(s). %s", percent, highestVotes, activePoll.playersWhoVoted, winningNames) )

		-- if top option has enough percent, use it
		if percent >= activePoll.percentage then
			return applyPollResults( winningIndices[1] )
		end

		-- Now use default option if defined
		for index,option in ipairs(activePoll) do
			if option.default then
				outputServerLogMaybe( "Vote using default option" )
				return applyPollResults(index)
			end
		end

		--if there's no draw, finish with the one with the greater number of votes
		if #winningIndices == 1 then
			outputServerLogMaybe( "Vote using highest number of votes" )
			return applyPollResults( winningIndices[1] )
		--if there's a draw,
		else
			--if the next nomination exceeds the max or doesn't reduce option count, make a casting vote using super-computer heuristic algorithms
			if activePoll.nomination+1 > activePoll.maxnominations or #winningIndices == #activePoll then
				outputServerLogMaybe( "Vote using CPU casting vote" )
				return applyPollResults( winningIndices[ math.random( 1, #winningIndices ) ] )
			else
				--copy the poll settings and increase nomination number
				local drawPoll = {
					title=activePoll.title,
					timeout=activePoll.timeout,
					percentage=activePoll.percentage,
					allowchange=activePoll.allowchange,
					visibleTo=activePoll.visibleTo,
					maxnominations=activePoll.maxnominations,
					nomination=activePoll.nomination+1,
				}
				--insert the options with equal number of votes
				for _,indici in ipairs(winningIndices) do
					table.insert(drawPoll,activePoll[indici])
				end
				--delete the current active poll
				activePoll = nil
				--start the new nomination
				startPoll(drawPoll)
			end
		end
	end
	return true
end

function finishPoll(chosenOption)
	if not activePoll then
		return false, errorCode.noPollRunning
	end

	if chosenOption then
		return endPoll(chosenOption)
	else
		return nil
	end
end

function applyPollResults(chosenOption)
	local optionTable = activePoll[chosenOption]
	activePoll = nil

	local result = triggerEvent("onPollEnd", thisResourceRoot, chosenOption)

	if result == true then
		outputVoteManager("Vote ended! ["..optionTable[1].."]",rootElement)

		local optionExecutorType = type(optionTable[2])
		if optionExecutorType == "function" then --it is a function
			optionTable[2](unpack(optionTable,3))
		elseif optionExecutorType == "string" then --it is an event
			triggerEvent(optionTable[2], optionTable[3] or rootElement, unpack(optionTable,4))
			--assert(loadstring(optionTable[2]))(unpack(optionTable,3))
		end
	end
end

--this handler processes client votes
addEventHandler("onClientSendVote", rootElement,
	function (voteID)
		--ignore the client request if the event was cancelled
		if wasEventCancelled() then
			return false
		end
		--check there's a poll
		if not activePoll then
			return false
		end
		--check the player's allowed to vote in it
		if not activePoll.allowedPlayers[client] then
			return false
		end
		--check the vote option is valid
		if not (activePoll[voteID] or voteID == -1) then
			return false
		end

		local previousVote = activePoll.votedOption[getPlayerUserNameSafe(client)]

		--check if player wants to cancel his non-existing vote
		if voteID == -1 and not previousVote then
			return
		end

        --check if player wants to change to his previous vote
        if previousVote and voteID == previousVote then
			return
		end

		--check if he just wants to cancel his vote
		if voteID == -1 and previousVote then
			if not activePoll.allowchange then
				outputVoteManager("You are not allowed to cancel your vote.",client)
				return false
			end

			if get("log_votes") then
				outputServerLog(getPlayerName(client).." cancelled his vote, was "..previousVote.." ("..activePoll[previousVote][1]..")")
			end

			activePoll.votedOption[getPlayerUserNameSafe(client)] = nil
			activePoll.playersWhoVoted = activePoll.playersWhoVoted - 1
			activePoll[previousVote].votes = activePoll[previousVote].votes - 1
			return
		end

		--else, check if he can change his vote
		if previousVote then
			if not activePoll.allowchange then
				outputVoteManager("You are not allowed to change your vote.",client)
				return false
			end
			if get("log_votes") then
				outputServerLog(getPlayerName(client).." changed his vote to "..voteID.." ("..activePoll[voteID][1]..") from "..previousVote.." ("..activePoll[previousVote][1]..")")
			end
			activePoll[previousVote].votes = activePoll[previousVote].votes - 1
			activePoll[voteID].votes = activePoll[voteID].votes + 1
		else
			if get("log_votes") then
				outputServerLog(getPlayerName(client).." voted "..voteID.." ("..activePoll[voteID][1]..")")
			end
			activePoll[voteID].votes = activePoll[voteID].votes + 1
		end

		activePoll.playersWhoVoted = activePoll.playersWhoVoted + 1
		activePoll.votedOption[getPlayerUserNameSafe(client)] = voteID

		recheckVotes()
	end
)

--this handler allows new players to vote if visibleTo is root
addEventHandler("onPlayerJoin", rootElement,
	function ()
		--if there is a poll and visibleTo is the root element
		if activePoll and activePoll.visibleTo == rootElement then
			activePoll.maxVoters = activePoll.maxVoters + 1
			activePoll.allowedPlayers[source] = true
			sendPoll(source)
		end
	end
)

--this handler removes votes from players who left
addEventHandler("onPlayerQuit", rootElement,
	function ()
		--if there is a poll and the player was allowed to vote on it
		if activePoll and activePoll.allowedPlayers[source] then
			activePoll.maxVoters = activePoll.maxVoters - 1
			activePoll.allowedPlayers[source] = nil
			--if he had voted, we'll have to substract his vote
			local voteID = activePoll.votedOption[getPlayerUserNameSafe(source)]
			if voteID then
				activePoll[voteID].votes = activePoll[voteID].votes - 1
				activePoll.playersWhoVoted = activePoll.playersWhoVoted - 1
				activePoll.votedOption[getPlayerUserNameSafe(source)] = nil
			end

			recheckVotes()
		end
	end
)

function outputVoteManager(message, toElement)
	toElement = toElement or rootElement
	local r, g, b = getColorFromString(string.upper(get("color")))
	if getElementType(toElement) == "console" then
		outputServerLog(message)
	else
		outputChatBox(message, toElement, r, g, b)
		if toElement == rootElement then
			outputServerLog(message)
		end
	end
end

function outputServerLogMaybe(message)
	if get("log_votes") then
		outputServerLog(message)
	end
end
