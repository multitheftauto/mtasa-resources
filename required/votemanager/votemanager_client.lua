local rootElement = getRootElement()
local localPlayer = getLocalPlayer()

local voteWindow
local boundVoteKeys = {}
local nameFromVoteID = {}
local voteIDFromName = {}
local optionLabels = {}

local isVoteActive
local hasAlreadyVoted = false
local isChangeAllowed = false

local timeLabel
local finishTime

local layout = {}
layout.window = {
	width = 150,
	relative = false,
	alpha = 0.85,
}
layout.title = {
	posX = 10,
	posY = 25,
	width = layout.window.width,
	relative = false,
	alpha = 1,
	r = 100,
	g = 100,
	b = 250,
	font = "default-bold-small",
}
layout.option = {
	posX = 10,
	width = layout.window.width,
	relative = false,
	alpha = 1,
	r = 200,
	g = 200,
	b = 200,
	font = "default-normal",
	bottom_padding = 4, --px
}
layout.cancel = {
	posX = 10,
	width = layout.window.width,
	height = 16,
	relative = false,
	alpha = 1,
	r = 120,
	g = 120,
	b = 120,
	font = "default-normal",
}
layout.time = {
	posX = 0,
	width = layout.window.width,
	height = 16,
	relative = false,
	alpha = 1,
	r = 255,
	g = 255,
	b = 255,
	font = "default-bold-small",
}
layout.chosen = {
	alpha = 1,
	r = 255,
	g = 130,
	b = 130,
	font = "default-bold-small",
}
layout.padding = {
	bottom = 10,
}

local function updateTime()
	local seconds = math.ceil( (finishTime - getTickCount()) / 1000 )
	guiSetText(timeLabel, seconds)
end

addEvent("doShowPoll", true)
addEvent("doSendVote", true)
addEvent("doStopPoll", true)

addEventHandler("doShowPoll", rootElement,
	function (pollData, pollOptions, pollTime)
		--clear the bound keys table
		boundVoteKeys = {}
		--store the vote option names in the array nameFromVoteID
		nameFromVoteID = pollOptions
		--then build a reverse table
		voteIDFromName = {}
	    for id, name in ipairs(nameFromVoteID) do
			voteIDFromName[name] = id
		end
		
		--determine if we have to append nomination number
		local nominationString = ""
		if pollData.nomination > 1 then 
			nominationString = " (nomination "..pollData.nomination..")"
		end
		
		isChangeAllowed = pollData.allowchange
		
      local screenX, screenY = guiGetScreenSize()
		--create the window
		voteWindow = guiCreateWindow (
						screenX,
						screenY,
						layout.window.width,
						screenY, --!
						"Vote"..nominationString,
						layout.window.relative
					)
		guiSetAlpha(voteWindow, layout.window.alpha)
		
		--create the title label
		
		local titleLabel = guiCreateLabel(
						layout.title.posX,
						layout.title.posY,
						layout.title.width,
						0, --!
						pollData.title,
						layout.title.relative,
						voteWindow
					)
		local titleHeight = guiLabelGetFontHeight(titleLabel) * math.ceil(guiLabelGetTextExtent(titleLabel) / layout.title.width)
		guiSetSize(titleLabel, layout.title.width, titleHeight, false)
		guiLabelSetHorizontalAlign ( titleLabel, "left", true )
		
		guiLabelSetColor(titleLabel, layout.title.r, layout.title.g, layout.title.b)
		guiSetAlpha(titleLabel, layout.title.alpha)
		guiSetFont(titleLabel, layout.title.font)
		setElementParent(titleLabel, voteWindow)
		
		local labelY = layout.title.posY + titleHeight
		
		--for each option, bind its key and create its label
		for index, option in ipairs(pollOptions) do
			--bind the number key and add it to the bound keys table
			local optionKey = tostring(index)
			bindKey(optionKey, "down", sendVote_bind)
			unbindKey("num_"..optionKey, "down", sendVote_bind)
			
			table.insert(boundVoteKeys, optionKey)
		
			--create the option label
			optionLabels[index] = guiCreateLabel(
						layout.option.posX,
						labelY,
						layout.option.width,
						0,
						optionKey..". "..option,
						layout.option.relative,
						voteWindow
					)
			---[[ FIXME - wordwrap
			--local optionHeight = guiLabelGetFontHeight(optionLabels[index]) *
			--	math.ceil(guiLabelGetTextExtent(optionLabels[index]) / layout.option.width)
			local optionHeight = 16
			guiSetSize(optionLabels[index], layout.option.width, titleHeight, false)
			guiLabelSetHorizontalAlign ( optionLabels[index], "left", true )
			--]]
			
			guiLabelSetColor(optionLabels[index], layout.option.r, layout.option.g, layout.option.b)
			guiSetAlpha(optionLabels[index], layout.option.alpha)
			setElementParent(optionLabels[index], voteWindow)
			
			labelY = labelY + optionHeight + layout.option.bottom_padding
		end
		
		if isChangeAllowed then
			bindKey("backspace", "down", sendVote_bind)
			
			--create the cancel label
			cancelLabel = guiCreateLabel(
						layout.cancel.posX,
						labelY,
						layout.cancel.width,
						layout.cancel.height,
						"(Backspace to cancel)",
						layout.cancel.relative,
						voteWindow
					)
			guiLabelSetHorizontalAlign ( cancelLabel, "left", true )
			guiLabelSetColor(cancelLabel, layout.cancel.r, layout.cancel.g, layout.cancel.b)
			guiSetAlpha(cancelLabel, layout.cancel.alpha)
			setElementParent(cancelLabel, voteWindow)
				
			labelY = labelY + layout.cancel.height
		end
		
		--create the time label
		timeLabel = guiCreateLabel(
						layout.time.posX,
						labelY,
						layout.time.width,
						layout.time.height,
						"",
						layout.time.relative,
						voteWindow
					)
		guiLabelSetColor(timeLabel, layout.time.r, layout.time.g, layout.time.b)
		guiLabelSetHorizontalAlign(timeLabel, "center")
		guiSetAlpha(timeLabel, layout.time.alpha)
		guiSetFont(timeLabel, layout.time.font)
		setElementParent(timeLabel, voteWindow)
		
		labelY = labelY + layout.time.height
		
		--adjust the window to the number of options
		local windowHeight = labelY + layout.padding.bottom
		guiSetSize(voteWindow, layout.window.width, windowHeight, false)
		guiSetPosition(voteWindow, screenX - layout.window.width, screenY - windowHeight, false)
		
		isVoteActive = true
		
		finishTime = getTickCount() + pollTime
		addEventHandler("onClientRender", rootElement, updateTime)
	end
)

addEventHandler("doStopPoll", rootElement,
	function ()
		isVoteActive = false
		hasAlreadyVoted = false

		for i, key in ipairs(boundVoteKeys) do
			unbindKey(key, "down", sendVote_bind)
			unbindKey("num_"..key, "down", sendVote_bind)
		end
		
		unbindKey("backspace", "down", sendVote_bind)
		
		removeEventHandler("onClientRender", rootElement, updateTime)
		destroyElement(voteWindow)
	end
)

function sendVote_bind(key)
	if key ~= "backspace" then
		return sendVote(tonumber(key))
	else
		return sendVote(-1)
	end
end

function sendVote(voteID)
	if not isVoteActive then
		return
	end
	
	--if option changing is not allowed, unbind the keys
	if not isChangeAllowed and voteID ~= -1 then
		for i, key in ipairs(boundVoteKeys) do
			unbindKey(key, "down", sendVote_bind)
			unbindKey("num_"..key, "down", sendVote_bind)
		end
	end
	
	--if the player hasnt voted already (or if vote change is allowed anyway), update the vote text
	if not hasAlreadyVoted or isChangeAllowed then
		if hasAlreadyVoted then
			guiSetFont(optionLabels[hasAlreadyVoted], layout.option.font)
			guiSetAlpha(optionLabels[hasAlreadyVoted], layout.option.alpha)
			guiLabelSetColor(optionLabels[hasAlreadyVoted], layout.option.r, layout.option.g, layout.option.b)
		end
		if voteID ~= -1 then
			guiSetFont(optionLabels[voteID], layout.chosen.font)
			guiSetAlpha(optionLabels[voteID], layout.chosen.alpha)
			guiLabelSetColor(optionLabels[voteID], layout.chosen.r, layout.chosen.g, layout.chosen.b)
		end
	end
	
	hasAlreadyVoted = voteID
	
	--send the vote to the server
	triggerServerEvent("onClientSendVote", localPlayer, voteID)
end
addEventHandler("doSendVote", rootElement, sendVote)

addCommandHandler("vote",
	function (command, ...)
		--join all passed parameters separated by spaces
		local voteString = table.concat({...}, ' ')
		--try to get the voteID number
		local voteID = tonumber(voteString) or voteIDFromName[voteString]
		--if vote number is valid, send it
		if voteID and (nameFromVoteID[voteID] or voteID == -1) then
			sendVote(voteID)
		end
	end
)

addCommandHandler("cancelvote",
	function ()
		sendVote(-1)
	end
)


