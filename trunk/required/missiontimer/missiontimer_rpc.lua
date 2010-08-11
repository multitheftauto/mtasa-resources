addEvent ( "setupNewMissionTimer", true )
addEventHandler ( "setupNewMissionTimer", rootElement,
	function(duration, countdown, showCS, x, y, bg, font, scale)
		setupMissionTimer ( source, duration, countdown, showCS, x, y, bg, font, scale )
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
	function(r,g,b)
		setMissionTimerHurryTime ( source, r,g,b )
	end
)