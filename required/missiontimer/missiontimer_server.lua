local thisResource = getThisResource()
local bool = { [false]=true, [true]=true }
local missionTimers = {}
addEvent"onMissionTimerElapsed"

addEventHandler ("onResourceStop",root,
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
	--Setup data
	missionTimers[element] = { duration = duration, countdown = countdown, showCS = showCS, x = x, y = y,
								bg = bg, font = font, scale = scale, prefix = prefix }
	missionTimers[element].originalTick = getTickCount()
	--
	missionTimers[element].timer = setTimer ( timeElapsed, duration, 1, element )
	addEventHandler ( "onElementDestroy", element, cleanupMissionTimer )
	triggerClientEvent ( "setupNewMissionTimer", element, duration, countdown, showCS, x, y, bg, font, scale, prefix )
	return element
end


function setMissionTimerTime ( timer, time )
	if missionTimers[timer] and tonumber(time) then
		missionTimers[timer].duration = tonumber(time) or missionTimers[timer].duration
		missionTimers[timer].originalTick = getTickCount()
		triggerClientEvent ( "setMissionTimerRemainingTime", timer, time )
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
	if not bool[frozen] then return false end

	if missionTimers[timer] then
		if frozen == missionTimers[timer].frozen then return false end
		
		missionTimers[timer].frozen = frozen

		if frozen then
			if isTimer(missionTimers[timer].timer) then
				killTimer ( missionTimers[timer].timer )
			end
			missionTimers[timer].timer = nil
			missionTimers[timer].duration = getMissionTimerTime ( timer )
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
	if not time or not tonumber(time) then return nil end
	
	if missionTimers[timer] then
		return triggerClientEvent ( "setMissionTimerHurryTime", timer, time )
	end
	return false
end


function setMissionTimerPrefix( timer, prefix )
	if type( prefix ) ~= "string" then return false end
	
	if missionTimers[timer] then
		missionTimers[timer].prefix = prefix
		
		return triggerClientEvent ( "setMissionTimerPrefix", timer, prefix )
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
	
	missionTimers[source] = nil
end

function timeElapsed ( timer )
	triggerEvent ( "onMissionTimerElapsed", timer )
end

addEvent("onClientMissionTimerDownloaded",true)
addEventHandler ( "onClientMissionTimerDownloaded", root, 
	function()
		for timer,data in pairs(missionTimers) do
			triggerClientEvent ( source, "setupNewMissionTimer", timer, getMissionTimerTime(timer), data.countdown, data.showCS, data.x, data.y, data.bg, data.font, data.scale, data.prefix )
		end
	end
)