tx,ty,tz = 91,100,502 --The position of 	the element
local hideX,hideY,hideZ = 0,0,0 --where to hide the local player
local rz = 0 -- The current rotation
local maxRadius = 5
local camDistance = 4
--vehicle elevation calculation
local baseRadius = 3
local vehicleElevation = 1.8
--vehicle moveleft offset (to compensate for the browser window)
local moveLeftBaseRadius = 4
local vehicleMoveLeft = 0.8
local rotateSpeed = 4000 --once every x seconds
local rotateRate = 360/rotateSpeed
local rotX,rotY
originalRotateTick = getTickCount()

setModel = {}

----ALL THE SETMODEL FUNCS
function browserSetElementModel ( elemID, model )
	disableElementLook(true)
	if ( elemID ) and ( model ) then
		setModel[elemID](model)
	end
end
function setModel.vehicleID ( model )
	local randomOffset = ((getTickCount() % 20) / 100) + 0.001

	if not browser.mainElement then
		browser.mainElement = createVehicle(model, tx, ty, tz, 0, 0, rz, "MAP EDIT")
		setElementDimension ( browser.mainElement, BROWSER_DIMENSION )
		setElementStreamable( browser.mainElement, false)
		setElementCollisionsEnabled( browser.mainElement, false) --this prevents them from jittering
		setElementFrozen( browser.mainElement, true)
		setElementInterior( browser.mainElement, 14)
		for i=0,5 do
			setVehicleDoorState ( browser.mainElement, i, 0 )
		end
	else
		for i=0,5 do
			setVehicleDoorState ( browser.mainElement, i, 0 )
		end
		setElementModel(browser.mainElement, model)
		fixVehicle ( browser.mainElement )
	end

	if (getElementType(browser.mainElement) == "vehicle" and getVehicleType(browser.mainElement) == "Train") then
		setTrainDerailed(browser.mainElement, true)
	end

	setElementPosition(browser.mainElement, tx, ty, tz + randomOffset)
	setElementAlpha(browser.mainElement, 255)

	local radius = getElementRadius (browser.mainElement)
	local realDistance = ( radius * 3 / maxRadius ) * camDistance
	local elevation = radius / baseRadius * vehicleElevation
	local moveLeft = radius / moveLeftBaseRadius * vehicleMoveLeft

	browserElementLookOptions.distance = radius * 2
	setCameraMatrix ( tx - realDistance, ty, tz + elevation + randomOffset,
	                  tx, ty + moveLeft, tz + randomOffset)
end
function setModel.objectID ( model )
	local randomOffset = ((getTickCount() % 20) / 100) + 0.001

	if not browser.mainElement then
		browser.mainElement = createObject(model, tx, ty, tz, 0, 0, rz)
		setElementDimension ( browser.mainElement, BROWSER_DIMENSION )
		setElementInterior(browser.mainElement, 14)
	else
		setElementModel(browser.mainElement, model)
	end

	setElementPosition(browser.mainElement, tx, ty, tz + randomOffset)
	setElementAlpha(browser.mainElement, 255)

	local radius = getElementRadius(browser.mainElement)
	browserElementLookOptions.distance = 14
	setObjectScale ( browser.mainElement, maxRadius / radius )
	setCameraMatrix ( tx - 17, ty, tz + 3 + randomOffset,
			  tx, ty + 2, tz + randomOffset)
end
function setModel.skinID ( model )
	local randomOffset = (getTickCount() % 20) / 100

	if isElement( browser.mainElement ) then
		setElementModel ( browser.mainElement, model )
	else
		browser.mainElement = createPed(model,tx,ty,tz + randomOffset,rz)
		setElementDimension ( browser.mainElement, BROWSER_DIMENSION )
		setElementCollisionsEnabled( browser.mainElement, false)
		setElementInterior(browser.mainElement, 14)
	end
	setElementAlpha(browser.mainElement, 255)

	setTimer( setPedRotation,50,1, browser.mainElement,rz)
	browserElementLookOptions.distance = 3
	setCameraMatrix ( tx-5,ty,tz + randomOffset, tx,ty,tz + randomOffset )
end

function rotateMesh ()
	if not ( isElement(browser.mainElement) ) then return end
	local newTick = getTickCount()
	previewTickDifference = newTick - originalRotateTick
	local newRotation = rotateRate*previewTickDifference
	newRotation = math.mod(newRotation,360)
	rz = newRotation
	if ( initiatedType ) == "vehicleID" then
		setElementRotation ( browser.mainElement,0,0,newRotation)
	elseif ( initiatedType ) == "objectID" then
		setElementRotation ( browser.mainElement,0,0,newRotation)
	elseif ( initiatedType ) == "skinID" then
		setPedRotation ( browser.mainElement,newRotation )
	end
end

