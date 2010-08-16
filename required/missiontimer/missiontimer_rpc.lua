addEvent ( "setupNewMissionTimer", true )
addEventHandler ( "setupNewMissionTimer", rootElement,
	function(duration, countdown, showCS, x, y, bg, font, scale, prefix)
		setupMissionTimer ( source, duration, countdown, showCS, x, y, bg, font, scale, prefix )
	end
)

addEvent ( "setMissionTimerRemainingTime", true )
addEventHandler ( "setMissionTimerRemainingTime", rootElement,
	function(remaining)
		setMissionTimerTime ( source, remaining )
	end
)

addEvent ( "setMissionTimerFrozen", true )
addEventHandler ( "setMissionTimerFrozen", rootElement,
	function(frozen)
		setMissionTimerFrozen ( source, frozen )
	end
)

addEvent ( "setMissionTimerHurryTime", true )
addEventHandler ( "setMissionTimerHurryTime", rootElement,
	function(time)
		setMissionTimerHurryTime ( source, time )
	end
)


addEvent ( "setMissionTimerPrefix", true )
addEventHandler ( "setMissionTimerPrefix", rootElement,
	function(prefix)
		setMissionTimerPrefix ( source, prefix )
	end
)