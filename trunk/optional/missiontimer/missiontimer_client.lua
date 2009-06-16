rootElement = getRootElement()
thisResource = getThisResource()
missionTimers = {}
bool = { [false]=true, [true]=true }
addEvent ( "onClientMissionTimerElapsed", true )

addEventHandler("onClientResourceStart",resourceRoot,
	function()
		triggerServerEvent ( "onClientMissionTimerDownloaded", getLocalPlayer() )
	end
)


function createMissionTimer ( duration, countdown, showCS, x, y, bg, font, scale )
	sourceResource = sourceResource or thisResource
	local element = createElement ( "missiontimer" )
	setElementParent ( element, getResourceDynamicElementRoot(sourceResource) )
	setupMissionTimer ( element, duration, countdown, showCS, x, y, bg, font, scale )
	return element
end

function setupMissionTimer ( element, duration, countdown, showCS, x, y, bg, font, scale )
	addEventHandler ( "onClientElementDestroy", element, onMissionTimerDestroy )
	missionTimers[element] = {}
	missionTimers[element].x = tonumber(x) or 0
	missionTimers[element].y = tonumber(y) or 0
	missionTimers[element].countdown = countdown
	missionTimers[element].duration = duration
	missionTimers[element].originalTick = getTickCount()
	missionTimers[element].showCS = (bool[showCS] == nil and true) or showCS
	missionTimers[element].bg = bool[bg] or true
	missionTimers[element].font = font or "default-bold"
	missionTimers[element].scale = tonumber(scale) or 1
	missionTimers[element].hurrytime = 15000
	missionTimers[element].timer = setTimer ( triggerEvent, duration, 1, "onClientMissionTimerElapsed", element )
end

function setMissionTimerTime ( timer, time )
	if missionTimers[timer] then
		missionTimers[timer].duration = tonumber(time) or missionTimers[timer].remaining
		missionTimers[timer].originalTick = getTickCount()
		return true
	end
	return false
end

function getMissionTimerTime ( timer )
	if missionTimers[timer] then
		if missionTimers[timer].countdown then
			return math.max(missionTimers[timer].duration - (getTickCount() - missionTimers[timer].originalTick),0)
		else
			return (getTickCount() - missionTimers[timer].originalTick)
		end
	end
	return false
end

function setMissionTimerFrozen ( timer, frozen )
	if frozen == not not missionTimers[timer].frozen then return false end
	if missionTimers[timer] and bool[frozen] then
		missionTimers[timer].frozen = frozen or nil
		if frozen then
			killTimer ( missionTimers[source].timer )		
			missionTimers[timer].duration = getMissionTimerRemainingTime ( timer )
		else
			missionTimers[timer].timer = setTimer ( triggerEvent, missionTimers[timer].duration, 1, "onClientMissionTimerElapsed", timer )		
			missionTimers[timer].originalTick = getTickCount()
		end
		return true
	end
	return false
end

function isMissionTimerFrozen ( timer )
	return not not missionTimers[timer].frozen
end

function setMissionTimerHurryTime ( timer, time )
	missionTimers[timer].hurrytime = tonumber(time) or 15000
end

function onMissionTimerDestroy()
	for i,timer in ipairs(getTimers()) do
		if timer == missionTimers[source].timer then
			killTimer ( timer )
			break
		end
	end
	missionTimers[source] = nil
end

