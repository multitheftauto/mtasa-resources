local thisResource = getThisResource()
local bool = { [false]=true, [true]=true }
local missionTimers = {}
addEvent"onMissionTimerElapsed"

function createMissionTimer ( duration, countdown, showCS, x, y, bg, font, scale )
	sourceResource = sourceResource or thisResource
	local element = createElement ( "missiontimer" )
	setElementParent ( element, getResourceDynamicElementRoot(sourceResource) )
	--Setup data
	missionTimers[element] = {}
	missionTimers[element].duration = duration
	missionTimers[element].countdown = countdown
	missionTimers[element].originalTick = getTickCount()
	--
	missionTimers[element].timer = setTimer ( timeElapsed, duration, 1, element )
	addEventHandler ( "onElementDestroy", element, cleanupMissionTimer )
	triggerClientEvent ( "setupNewMissionTimer", element, duration, countdown, showCS, x, y, bg, font, scale )
	return element
end


function setMissionTimerTime ( timer, time )
	if missionTimers[timer] and tonumber(time) then
		missionTimers[timer].duration = tonumber(time) or missionTimers[timer].duration
		missionTimers[timer].originalTick = getTickCount()
		triggerClientEvent ( "setupNewMissionTimer", timer, time )
		return true
	end
	return false
end

function getMissionTimerTime ( timer )
	if missionTimers[timer] then
		if missionTimers[timer].countdown then
			return math.min(missionTimers[timer].duration - (getTickCount() - missionTimers[timer].originalTick),0)
		else
			return (getTickCount() - missionTimers[timer].originalTick)
		end
	end
	return false
end

function setMissionTimerFrozen ( timer, frozen )	
	if frozen == not not missionTimers[timer].frozen then return false end
	if not bool[frozen] then return false end
	if missionTimers[timer] then
		if frozen then
			killTimer ( missionTimers[source].timer )
			missionTimers[timer].duration = getMissionTimerRemainingTime ( timer )
		else
			missionTimers[timer].timer = setTimer ( timeElapsed, duration, 1, timer )
			missionTimers[timer].originalTick = getTickCount()
		end
		return triggerClientEvent ( "setMissionTimerFrozen", timer, frozen )
	end
	return false
end

function isMissionTimerFrozen ( timer )
	if not missionTimers[timer] then return nil end
	return not not missionTimers[timer].frozen
end

function setMissionTimerHurryTime ( timer, time )	
	if missionTimers[timer] then
		return triggerClientEvent ( "setMissionTimerFrozen", element, time )
	end
	return false
end

function cleanupMissionTimer()
	for i,timer in ipairs(getTimers()) do
		if timer == missionTimers[source].timer then
			killTimer ( timer )
			break
		end
	end
end

function timeElapsed ( timer )
	triggerEvent ( "onMissionTimerElapsed", timer )
	--triggerClientEvent ( "onClientMissionTimerElapsed", timer )
end
