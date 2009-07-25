local localPlayer = getLocalPlayer()
local briefcaseTube = false
local objectiveTube = false

-- briefcase col

function createHittableBriefcaseCol(x, y, z, radius, height)
	assert(not briefcaseTube)
	briefcaseTube = createColTube(x, y, z, radius, height)
	addEventHandler("onClientColShapeHit", briefcaseTube, onBriefcaseTubeHit)
end

function destroyHittableBriefcaseCol()
	assert(briefcaseTube)
	removeEventHandler("onClientColShapeHit", briefcaseTube, onBriefcaseTubeHit)
	destroyElement(briefcaseTube)
	briefcaseTube = false
end

function onBriefcaseTubeHit(hitElement, matchingDimension)
outputDebugString("briefcase hit, hitElement: " .. tostring(hitElement))
-- gets called a several times when this event is added, the last time hitElement is not an element
--if (isElement(hitElement)) then
--outputDebugString(" is element")
--else
--outputDebugString(" is not element")
--end
assert(isElement(hitElement))
assert(getElementType(hitElement))
--outputDebugString("briefcase hit client-side!")
	-- see if it's the local player or their vehicle
	if (getElementType(hitElement) == "player" and hitElement == localPlayer) then
		triggerServerEvent("onPlayerBriefcaseHit", getLocalPlayer())
	elseif (getElementType(hitElement) == "vehicle" and isPedInVehicle(localPlayer) and getPedOccupiedVehicle(localPlayer) == hitElement) then
		triggerServerEvent("onPlayerBriefcaseHit", getLocalPlayer())
	end
end

-- objective col

function createHittableObjectiveCol(x, y, z, radius, height)
	assert(not objectiveTube)
	objectiveTube = createColTube(x, y, z, radius, height)
	addEventHandler("onClientColShapeHit", objectiveTube, onObjectiveTubeHit)
end

function destroyHittableObjectiveCol()
	assert(objectiveTube)
	removeEventHandler("onClientColShapeHit", objectiveTube, onObjectiveTubeHit)
	destroyElement(objectiveTube)
	objectiveTube = false
end

function onObjectiveTubeHit(hitElement, matchingDimension)
outputDebugString("objective hit, hitElement: " .. tostring(hitElement))
	-- see if it's the local player or their vehicle
	if (getElementType(hitElement) == "player" and hitElement == localPlayer) then
		triggerServerEvent("onPlayerObjectiveHit", getLocalPlayer())
	elseif (getElementType(hitElement) == "vehicle" and isPedInVehicle(localPlayer) and getPedOccupiedVehicle(localPlayer) == hitElement) then
		triggerServerEvent("onPlayerObjectiveHit", getLocalPlayer())
	end
end
