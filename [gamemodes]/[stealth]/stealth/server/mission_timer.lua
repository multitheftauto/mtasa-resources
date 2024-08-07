--Mission timer by AlienX

--Usage:
--In your scripts you need to have added an event handle that the timer will call once the time is up...
--The event call will also have its own ID, so you will be able to use the same timer script, on more than 1 mission at one point in time
--Here goes!

missionTimers = {}

function misTmrStart ( name )
	if ( name ~= getThisResource() ) then return end
	addEvent ( "missionTimerActivated", true )
	keytimer = setTimer ( missionTimerTick, 1000, 0 )
end
addEventHandler ( "onResourceStart", resourceRoot, misTmrStart )

function createMissionTimer ( player, timeSeconds, direction, textSize, textPosX, textPosY, textRed, textGreen, textBlue, showForAll )
	local missionTimersCount = #missionTimers + 1
	missionTimers[missionTimersCount] = {}
	missionTimers[missionTimersCount]["defaultTime"] = timeSeconds
	missionTimers[missionTimersCount]["started"] = false
	missionTimers[missionTimersCount]["player"] = player
	missionTimers[missionTimersCount]["id"] = missionTimersCount
	missionTimers[missionTimersCount]["showforall"] = showForAll

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
	--outputDebugString ( "Attempting to delete mission timer for id " .. timerID )
	for k,theTimer in ipairs(missionTimers) do
		if ( tostring(k) == tostring(timerID) ) then
			textDestroyTextItem ( theTimer["textItem"] )
			textDestroyDisplay ( theTimer["textDisplay"] )
			theTimer["started"] = false
		end
	end
end

function showMisTextForPlayer ( player, timerID, time, posx, posy, red, green, blue, scale, text, showForAll )
	textDisplay = textCreateDisplay ()
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
	local timeHours
	local timeMins
	local timeSecs

	timeLeft = tonumber(timeLeft)
	----outputDebugString ( "timeLeft = " .. timeLeft )

	timeSecs = math.mod(timeLeft, 60)
	----outputDebugString ( "timeSeconds = " .. timeSecs )

	timeMins = math.mod((timeLeft / 60), 60)
	----outputDebugString ( "timeMins = " .. timeMins )

	timeHours = (timeLeft / 3600)
	----outputDebugString ( "timeHours = " .. timeHours )

	if ( timeHours >= 1 ) then
		----outputDebugString ( "Time hours is above or equal too 1" )
		calcString = formatStr(tostring(timeHours)) .. ":"
	end
	calcString = calcString .. formatStr(string.format("%.0d", tostring(timeMins))) .. ":" .. formatStr(tostring(timeSecs))

	----outputDebugString ( "calcString = " .. calcString )
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
	for k,theTimer in ipairs(missionTimers) do
		if ( theTimer["started"] ) then
			if ( theTimer["direction"] == "<" ) then
				--Counting Down
				theTimer["time"] = ( tonumber(theTimer["time"]) - 1 )
				theTimer["timeString"] = calcTime ( theTimer["time"] )
				setTimerText ( theTimer )
				if ( theTimer["time"] == 0 ) then
					--Counter has finished, set it to not be started and start the thread
					--outputDebugString ( "MISSION TIMER HAS GOT TO 0!" )
					triggerEvent ( "missionTimerActivated", root, tostring(theTimer["id"]), theTimer["player"] )
					theTimer["started"] = false
				end
			elseif ( theTimer["direction"] ~= ">" ) then
				--Set a default value of Down.
				theTimer["direction"] = "<"
			end
		end
	end
end


function onNewPlayerJoin ()
	textDisplayAddObserver ( textDisplay, source )
end

addEventHandler ( "onPlayerJoin", root, onNewPlayerJoin )
