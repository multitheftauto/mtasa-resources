

function finished(objective)
	if (objective.id ~= "freight") then return end
	explosions()
end

function explosions()
	setTimer(createExplosion,1000,1,-1434.921021,1488.679077,1.8,10)
	setTimer(createExplosion,1100,1,-1434.921021,1488.679077,1.8,1)
	setTimer(createExplosion,1500,1,-1434.288,1490.60595,1.8,10)
	setTimer(createExplosion,1500,1,-1434.288,1490.60595,1.8,1)
	setTimer(createExplosion,1500,1,-1423.288,1483.60595,1.8,10)
	setTimer(createExplosion,1500,1,-1423.288,1483.60595,1.8,1)

	setTimer(createExplosion,1700,1,-1420.829,1496.80595,1.8,10)
	setTimer(createExplosion,1700,1,-1420.829,1496.80595,1.8,1)
	setTimer(createExplosion,1700,1,-1413.829,1496.80595,1.8,1)

	setTimer(createExplosion,2000,1,-1401.829,1496.80595,1.8,1)
	setTimer(createExplosion,2000,1,-1401.829,1496.80595,1.8,1)
end

addEventHandler("onAssaultObjectiveReached",getRootElement(),finished)
