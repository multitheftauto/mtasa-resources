--Mission timer by AlienX

--Usage:
--In your scripts you need to have added an event handle that the timer will call once the time is up...
--The event call will also have its own ID, so you will be able to use the same timer script, on more than 1 mission at one point in time
--Here goes!

misTmrRoot = getRootElement()
missionTimers = {}
local time = 0

function misTmrStart ( name )
	if ( name ~= getThisResource() ) then return end
	addEvent ( "missionTimerActivated", false )
	setTimer ( missionTimerTick, 1000, 0 )
end
addEventHandler ( "onResourceStart", getResourceRootElement(getThisResource()), misTmrStart )

function createMissionTimer ( player, timeSeconds, direction, textSize, textPosX, textPosY, textRed, textGreen, textBlue, showForAll )
	local missionTimersCount = #missionTimers + 1
	missionTimers[missionTimersCount] = {}
	missionTimers[missionTimersCount]["defaultTime"] = timeSeconds
	missionTimers[missionTimersCount]["started"] = false
	missionTimers[missionTimersCount]["player"] = player
	missionTimers[missionTimersCount]["id"] = missionTimersCount
	missionTimers[missionTimersCount]["showforall"] = showForAll

	--Extra stuff for on player join
	missionTimers[missionTimersCount]["textSize"] = textSize
	missionTimers[missionTimersCount]["textPosX"] = textPosX
	missionTimers[missionTimersCount]["textPosY"] = textPosY
	missionTimers[missionTimersCount]["textRed"] = textRed
	missionTimers[missionTimersCount]["textGreen"] = textGreen
	missionTimers[missionTimersCount]["textBlue"] = textBlue
	missionTimers[missionTimersCount]["showForAll"] = showForAll

	if ( direction == ">" ) then
		missionTimers[missionTimersCount]["time"] = "0"
	elseif ( direction == "<" ) then
		missionTimers[missionTimersCount]["time"] = timeSeconds
	else
		missionTimers[missionTimersCount]["time"] = timeSeconds
	end

	missionTimers[missionTimersCount]["direction"] = direction
	missionTimers[missionTimersCount]["textDisplay"] = 0
	missionTimers[missionTimersCount]["textItem"] = 0

	if ( timeSeconds < 1 ) then
		return false
	else
		missionTimers[missionTimersCount]["timeString"] = calcTime ( timeSeconds )
		showMisTextForPlayer ( player, missionTimersCount, time, textPosX, textPosY, textRed, textGreen, textBlue, textSize, missionTimers[missionTimersCount]["timeString"], showForAll )
		return missionTimersCount
	end
end

function onPlayerJoin ()
	local missionTimersCount = #missionTimers
	for k,v in ipairs(missionTimers) do
		if missionTimers[k]["started"] == true then
			showMisTextForPlayer ( source, missionTimersCount, time, missionTimers[k]["textPosX"], missionTimers[k]["textPosY"], missionTimers[k]["textRed"], missionTimers[k]["textGreen"], missionTimers[k]["textBlue"], missionTimers[k]["textSize"], missionTimers[k]["timeString"], false )
		end
	end
end
addEventHandler ( "onPlayerJoin", root, onPlayerJoin )


function startTimer ( timerID )
	missionTimers[timerID]["started"] = true
end

function stopTimer ( timerID )
	missionTimers[timerID]["started"] = false
end

function restartTimer ( timerID )
	missionTimers[timerID]["started"] = true
	missionTimers[timerID]["time"] = missionTimers[timerID]["defaultTime"]
end

function destroyMissionTimer ( timerID )
	for k,theTimer in ipairs(missionTimers) do
		if ( tostring(k) == tostring(timerID) ) then
			textDestroyTextItem ( theTimer["textItem"] )
			textDestroyDisplay ( theTimer["textDisplay"] )
			theTimer["started"] = false
		end
	end
end

function showMisTextForPlayer ( player, timerID, time, posx, posy, red, green, blue, scale, text, showForAll )
	local textDisplay = textCreateDisplay ()
	local textItem = textCreateTextItem ( text, posx, posy, 2, red, green, blue, 255, scale )
	textDisplayAddText ( textDisplay, textItem )
	if ( showForAll ) then
		local players = getElementsByType( "player" )
		for k,v in ipairs(players) do
			textDisplayAddObserver ( textDisplay, v )
		end
	else
		textDisplayAddObserver ( textDisplay, player )
	end
	missionTimers[timerID]["textDisplay"] = textDisplay
	missionTimers[timerID]["textItem"] = textItem
end

function setTimerText ( timerID )
	textItemSetText ( timerID["textItem"], timerID["timeString"] )
end

function calcTime ( timeLeft )
	local calcString = ""
	local timeHours = 0
	local timeMins = 0
	local timeSecs = 0

	timeLeft = tonumber(timeLeft)
	timeSecs = math.mod(timeLeft, 60)
	timeMins = math.mod((timeLeft / 60), 60)
	timeHours = (timeLeft / 3600)

	if ( timeHours >= 1 ) then
		calcString = formatStr(tostring(timeHours)) .. ":"
	end
	calcString = calcString .. formatStr(string.format("%.0d", tostring(timeMins))) .. ":" .. formatStr(tostring(timeSecs))

	return calcString
end

function formatStr ( formatString )
	local aString = tostring(formatString)

	if ( #aString == 1 ) then
		aString = "0" .. aString
	end

	if ( #aString == 0 ) then
		aString = "00"
	end

	return aString
end

function missionTimerTick()
	local k = 0
	for k,theTimer in ipairs(missionTimers) do
		if ( theTimer["started"] ) then
			if ( theTimer["direction"] == "<" ) then
				theTimer["time"] = ( tonumber(theTimer["time"]) - 1 )
				theTimer["timeString"] = calcTime ( theTimer["time"] )
				setTimerText ( theTimer )
				if ( theTimer["time"] == 0 ) then
					triggerEvent ( "missionTimerActivated", misTmrRoot, tostring(theTimer["id"]), theTimer["player"] )
					theTimer["started"] = false
				end
			elseif ( theTimer["direction"] == ">" ) then
				--Counting up has yet to be coded
			else
				theTimer["direction"] = "<"
			end
		end
	end
end
