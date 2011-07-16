addEvent ( "setupNewMissionTimer", true )
addEventHandler ( "setupNewMissionTimer", rootElement,
	function(duration, countdown, timerFormat, x, y, bg, font, scale, r, g, b )
		setupMissionTimer ( source, duration, countdown, timerFormat, x, y, bg, font, scale, r, g, b )
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


addEvent ( "setMissionTimerFormat", true )
addEventHandler ( "setMissionTimerFormat", rootElement,
	function(timerFormat)
		setMissionTimerFormat ( source, timerFormat )
	end
)