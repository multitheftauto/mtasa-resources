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

addEventHandler ("onClientResourceStop",rootElement,
	function()
		for i,timer in ipairs(getElementsByType("missiontimer",source)) do
			destroyElement(timer)
		end
	end
)

function createMissionTimer ( duration, countdown, showCS, x, y, bg, font, scale, prefix )
	sourceResource = sourceResource or thisResource
	local element = createElement ( "missiontimer" )
	setElementParent ( element, getResourceDynamicElementRoot(sourceResource) )
	setupMissionTimer ( element, duration, countdown, showCS, x, y, bg, font, scale, prefix )
	return element
end

function setupMissionTimer ( element, duration, countdown, showCS, x, y, bg, font, scale, prefix )
	if missionTimers[element] then return end
	addEventHandler ( "onClientElementDestroy", element, onMissionTimerDestroy )
	missionTimers[element] = {}
	missionTimers[element].x = tonumber(x) or 0
	missionTimers[element].y = tonumber(y) or 0
	missionTimers[element].countdown = countdown
	missionTimers[element].duration = duration
	missionTimers[element].originalTick = getTickCount()
	missionTimers[element].showCS = (bool[showCS] == nil and true) or showCS
	missionTimers[element].bg = (bool[bg] == nil and true) or bg
	missionTimers[element].font = font or "default-bold"
	missionTimers[element].scale = tonumber(scale) or 1
	missionTimers[element].prefix = prefix or ""
	missionTimers[element].hurrytime = 15000
	missionTimers[element].pWidth = dxGetTextWidth(missionTimers[element].prefix, missionTimers[element].scale, missionTimers[element].font)
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
			if isTimer( missionTimers[timer].timer ) then
				killTimer ( missionTimers[timer].timer )
			end
			missionTimers[timer].timer = nil
			missionTimers[timer].duration = getMissionTimerTime ( timer )
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

function setMissionTimerPrefix( timer, prefix )
	if type( prefix ) ~= "string" then return false end
	
	if missionTimers[timer] then
		missionTimers[timer].prefix = prefix
		missionTimers[timer].pWidth = dxGetTextWidth(missionTimers[timer].prefix, missionTimers[timer].scale, missionTimers[timer].font)
	end
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

