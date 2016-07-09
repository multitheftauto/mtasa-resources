addEvent ( "setupNewMissionTimer", true )
addEventHandler ( "setupNewMissionTimer", root,
	function(duration, countdown, timerFormat, x, y, bg, font, scale, r, g, b )
		setupMissionTimer ( source, duration, countdown, timerFormat, x, y, bg, font, scale, r, g, b )
	end
)

addEvent ( "setMissionTimerRemainingTime", true )
addEventHandler ( "setMissionTimerRemainingTime", root,
	function(remaining)
		setMissionTimerTime ( source, remaining )
	end
)

addEvent ( "setMissionTimerFrozen", true )
addEventHandler ( "setMissionTimerFrozen", root,
	function(frozen)
		setMissionTimerFrozen ( source, frozen )
	end
)

addEvent ( "setMissionTimerHurryTime", true )
addEventHandler ( "setMissionTimerHurryTime", root,
	function(time)
		setMissionTimerHurryTime ( source, time )
	end
)

addEvent ( "setMissionTimerFormat", true )
addEventHandler ( "setMissionTimerFormat", root,
	function(timerFormat)
		setMissionTimerFormat ( source, timerFormat )
	end
)
