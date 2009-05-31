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
	missionTimers[element].originalTick = getTickCount()
	--
	missionTimers[element].timer = setTimer ( timeElapsed, duration, 1, element )
	addEventHandler ( "onElementDestroy", element, cleanupMissionTimer )
	triggerClientEvent ( "setupNewMissionTimer", element, duration, countdown, showCS, x, y, bg, font, scale )
	return element
end


function setMissionTimerRemainingTime ( timer, time )
	if missionTimers[timer] and tonumber(time) then
		missionTimers[timer].duration = tonumber(time) or missionTimers[timer].duration
		missionTimers[timer].originalTick = getTickCount()
		triggerClientEvent ( "setupNewMissionTimer", element, time )
		return true
	end
	return false
end

function getMissionTimerRemainingTime ( timer )
	return missionTimers[timer] and (missionTimers[timer].duration - (missionTimers[element].originalTick - getTickCount())) or false
end

function setMissionTimerFrozen ( timer, frozen )	
	if frozen == not not missionTimers[timer].frozen then return false end
	if not bool[frozen] then return false end
	if missionTimers[timer] then
		if frozen then
			killTimer ( missionTimers[source].timer )
			missionTimers[timer].duration = getMissionTimerRemainingTime ( timer )
		else
			missionTimers[element].timer = setTimer ( timeElapsed, duration, 1, element )
			missionTimers[timer].originalTick = getTickCount()
		end
		return triggerClientEvent ( "setMissionTimerFrozen", element, frozen )
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
