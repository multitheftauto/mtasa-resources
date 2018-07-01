local rootElement = getRootElement()

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

local cacheVoteNumber
local cacheTimer

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
		--clear the send vote cache
		cacheVoteNumber = ""
		--clear the bound keys table
		boundVoteKeys = {}
		--store the vote option names in the array nameFromVoteID
		nameFromVoteID = pollOptions
		--then build a reverse table
		voteIDFromName = {}
		local width
	    for id, name in ipairs(nameFromVoteID) do
			voteIDFromName[name] = id
            width = dxGetTextWidth("1. "..name) + 20
            --check if the name width is higher than the current width
            if layout.window.width < width then
                --set the curent width to the width of the name
                layout.window.width = width
            end
		end

		for word in string.gfind(pollData.title, "[^%s]+") do
            width = dxGetTextWidth(word) + 20
            if layout.window.width < width then
                layout.window.width = width
            end
        end

		--determine if we have to append nomination number
		local nominationString = ""
		if pollData.nomination > 1 then
			nominationString = " (nomination "..pollData.nomination..")"
		end

		isChangeAllowed = pollData.allowchange

        layout.title.width  = layout.window.width - 20
        layout.option.width = layout.window.width
        layout.cancel.width = layout.window.width
        layout.time.width   = layout.window.width

        local screenX, screenY = guiGetScreenSize()

		--create the window
		voteWindow = guiCreateWindowFromCache (
						screenX,
						screenY,
						layout.window.width,
						screenY, --!
						"Vote"..nominationString,
						layout.window.relative
					)
		guiSetAlpha(voteWindow, layout.window.alpha)

		--create the title label

		local titleLabel = guiCreateLabelFromCache(
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
			bindKey("num_"..optionKey, "down", sendVote_bind)

			table.insert(boundVoteKeys, optionKey)

			--create the option label
			optionLabels[index] = guiCreateLabelFromCache(
						layout.option.posX,
						labelY,
						layout.option.width,
						0,
						optionKey..". "..option,
						layout.option.relative,
						voteWindow
					)
			-- -[[ FIXME - wordwrap
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

		--bind 0 keys if there are more than 9 options
		if #pollOptions > 9 then
			bindKey("0", "down", sendVote_bind)
			bindKey("num_0", "down", sendVote_bind)
			table.insert(boundVoteKeys, "0")
		end

		if isChangeAllowed then
			bindKey("backspace", "down", sendVote_bind)

			--create the cancel label
			cancelLabel = guiCreateLabelFromCache(
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
		timeLabel = guiCreateLabelFromCache(
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

        --set the default value after creating gui
        layout.window.width = 150

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
		destroyElementToCache(voteWindow)
	end
)

function sendVote_bind(key)
	if key ~= "backspace" then
		key = key:gsub('num_', '')
		if #nameFromVoteID < 10 then
			return sendVote(tonumber(key))
		else
			cacheVoteNumber = cacheVoteNumber..key
			if #cacheVoteNumber > 1 then
				if isTimer(cacheTimer) then
					killTimer(cacheTimer)
				end
				cacheVoteNumber = tonumber(cacheVoteNumber)
				if nameFromVoteID[cacheVoteNumber] then
					if cacheVoteNumber < 10 then
						return sendVote(cacheVoteNumber)
					else
						cacheTimer = setTimer(sendVote, 500, 1, cacheVoteNumber)
					end
					cacheVoteNumber = key
				else
					cacheVoteNumber = ""
				end
			else
				cacheTimer = setTimer(sendVote, 500, 1, tonumber(cacheVoteNumber))
			end
		end
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

	--clear the send vote cache
	cacheVoteNumber = ""
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


--
-- Label cache
--
-- This code is tuned for the current votemanager setup and gui.
-- If things change, and this code breaks, it might be easier just to remove it.
--

addEventHandler('onClientResourceStart', getRootElement(), function() precreateGuiElements() end )

local unusedWindows = {}
local unusedLabels = {}
local donePrecreate = false

function precreateGuiElements()
    if donePrecreate then
        return
    end
    --outputDebugString( 'votemanager precreateGuiElements' )
    local window = guiCreateWindowFromCache(10,10,100,100,'a',false )
    if not window then
        return
    end
    if #unusedWindows ~= 0 or #unusedLabels ~= 0 then
        outputConsole( 'WARNING: Unexpected values at start of precreateGuiElements: #unusedWindows:' .. tostring(#unusedWindows) .. ' #unusedLabels:' .. tostring(#unusedLabels) )
    end
    for i=1,12 do
        guiCreateLabelFromCache(10, i, 20, 10, 'a', false, window )
	end
    donePrecreate = true
    destroyElementToCache(window)
    if #unusedWindows ~= 1 or #unusedLabels ~= 12 then
        outputConsole( 'WARNING: Unexpected values at end of precreateGuiElements: #unusedWindows:' .. tostring(#unusedWindows) .. ' #unusedLabels:' .. tostring(#unusedLabels) )
    end
end


function guiCreateWindowFromCache(x, y, width, height, text, relative)
    if #unusedWindows < 1 then
        if donePrecreate then
            outputConsole( 'WARNING: Unexpected call to guiCreateWindowFromCache: #unusedWindows:' .. tostring(#unusedWindows) .. ' #unusedLabels:' .. tostring(#unusedLabels) )
        end
	    return guiCreateWindow(x, y, width, height, text, relative )
    else
        local window = unusedWindows[#unusedWindows]
        table.remove( unusedWindows )
        guiSetSize(window, width, height, relative)
        guiSetText(window, text)
        guiSetPosition(window, x, y, relative)
        guiSetAlpha(window, 1)
        guiSetVisible(window, true)
        guiBringToFront(window)
        return window
    end
end


function guiCreateLabelFromCache(x, y, width, height, text, relative, parent)
    if #unusedLabels < 1 then
        if donePrecreate then
            outputConsole( 'WARNING: Unexpected call to guiCreateLabelFromCache: #unusedWindows:' .. tostring(#unusedWindows) .. ' #unusedLabels:' .. tostring(#unusedLabels) )
        end
	    return guiCreateLabel(x, y, width, height, text, relative, parent )
    else
        local label = unusedLabels[#unusedLabels]
        table.remove( unusedLabels )
        --setElementParent(label,parent)
	    guiSetSize(label, width, height, relative)
	    guiSetFont(label,"default-normal")
	    guiSetText(label, text)
	    guiLabelSetColor(label, 255, 255, 0)
	    guiSetPosition(label, x, y, relative)
        guiSetAlpha(label, 1)
        guiSetVisible(label, true)
        return label
    end
end


function destroyElementToCache(elem)
    local etype = getElementType(elem)
    if etype == 'gui-window' then
        local itemList = getElementChildren(elem)
        if itemList then
            for i,item in pairs(itemList) do
                destroyElementToCache(item)
            end
        end
        table.insertUnique(unusedWindows,elem)
        guiSetVisible(elem, false)
        if #unusedWindows ~= 1 or #unusedLabels ~= 12 then
            outputConsole( 'WARNING: Unexpected values in destroyElementToCache: #unusedWindows:' .. tostring(#unusedWindows) .. ' #unusedLabels:' .. tostring(#unusedLabels) )
        end
    elseif etype == 'gui-label' then
        table.insertUnique(unusedLabels,elem)
        guiSetVisible(elem, false)
    end
end


function table.insertUnique(t,val)
	for k,v in pairs(t) do
        if v == val then
			return
		end
	end
    table.insert(t,val)
end
