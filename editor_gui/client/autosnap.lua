local camDistance = 5
local elementDiameter = 1
local snapElement

local visibleElements = { object=true, vehicle=true,marker=true,pickup=true,ped=true }

function autoSnap ( element )
	if not isElement ( element ) then return false end
	local edfElem   = edf.edfGetAncestor ( element )
	local edfHandle = edf.edfGetHandle ( edfElem )
	if ( edfElem ) then
		if ( edfHandle ) then
			element = edfHandle
		else
			element = edfElem
		end
	else return false end
	--Check if the element exists in the 3D word
	local elemX,elemY,elemZ = getElementPosition ( element )
	if not elemX or not elemY or not elemZ then return false end

	--check if its a visible element, if its not then leave the camera at its arbritrary position
	if not visibleElements[getElementType(element)] then return false end
	--
	local radius = edf.edfGetElementRadius ( element )
	if not radius then
		--Lets assume the radius is 5 and try again next frame
		radius = 5
		if not snapElement then
			addEventHandler ( "onClientRender", root, autoSnapNextFrame )
		end
		snapElement = element
	else
		snapElement = nil
	end
	local maxDist = radius
	--
	local realDistance = ( maxDist / elementDiameter ) * camDistance
	local camX,camY,camZ,cameraLookX,cameraLookY,cameraLookZ = getCameraMatrix()
	--we move backwards from the camera angle, invert the vector
	local distance = getDistanceBetweenPoints3D ( camX,camY,camZ,cameraLookX,cameraLookY,cameraLookZ )
	local vectorX = camX - cameraLookX
	local vectorY = camY - cameraLookY
	local vectorZ = camZ - cameraLookZ
	local ratio = realDistance / distance
	vectorX = vectorX * ratio
	vectorY = vectorY * ratio
	vectorZ = vectorZ * ratio
	-- calculate a camera position based on the current position and an offset based on the new vector
	local camPosX = elemX + vectorX
	local camPosY = elemY + vectorY
	local camPosZ = elemZ + vectorZ
	return setCameraMatrix ( camPosX, camPosY, camPosZ, elemX,elemY,elemZ )
end

function autoSnapNextFrame()
	autoSnap ( snapElement )
	removeEventHandler ( "onClientRender", root, autoSnapNextFrame )
end
