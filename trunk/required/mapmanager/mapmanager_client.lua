local MINUTE_DURATION = 2147483647
local freezeTimer

addEvent("mm.doFreezeTime", true)
addEvent("mm.doUnfreezeTime", true)

addEventHandler("mm.doFreezeTime", getRootElement(),
	function(hr, mn)
		freezeTime ( true, hr, mn )
	end
)

addEventHandler("mm.doUnfreezeTime", getRootElement(),
	function(hr, mn)
		freezeTime ( false, hr, mn )
	end
)

function freezeTime ( enabled, hr, mn )
	if enabled then
		setTime ( hr, mn )
		
		if ( freezeTimer ) then
			for i,timer in ipairs(getTimers()) do
				if timer == freezeTimer then
					killTimer ( timer )
					break
				end
			end
		end
		
		freezeTimer = setTimer(
			function() 
				setTime(currentMapSettings.timeHour, currentMapSettings.timeMinute) 
			end, 
		MINUTE_DURATION, 0)
		
		return setMinuteDuration ( MINUTE_DURATION )
	else
		if ( freezeTimer ) then
			for i,timer in ipairs(getTimers()) do
				if timer == freezeTimer then
					killTimer ( timer )
					break
				end
			end
		end
		setMinuteDuration ( 1000 )
		if hr and mn then
			return setTime ( hr, mn )
		end
	end
end