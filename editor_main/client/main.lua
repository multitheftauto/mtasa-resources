local thisResource = getThisResource()
local g_suspendedCamera = {}
local g_screenX, g_screenY = guiGetScreenSize ()

local CAMERA_MODE = 1
local CURSOR_MODE = 2
local g_mode
local MOUSE_SUBMODE = 1
local KEYBOARD_SUBMODE = 2
local g_submode = MOUSE_SUBMODE
local g_maxSelectDistance = 155 --units
local g_moveDistance = 100 --move_cursor/freecam

g_workingInterior = 0

local g_suspended = false
local g_enableWorld = true
local g_sensitivityMode = false
local g_showingProperties = false

local g_selectedElement
local g_selectedPart
local g_targetedElement
local g_targetedPart

local g_colless = {}

local g_arrowMarkerSizeRatio = 0.4 --Multiplied by the element's radius
local g_arrowMarkerMinSize = 0.5 --The Absolute minimum size the marker can be
local g_arrowMarker
local g_editorBlip

local CROSSHAIR_NOTHING = 1
local CROSSHAIR_WORLD = 2
local CROSSHAIR_WATER = 3
local CROSSHAIR_MOUSEOVER = 4
local CROSSHAIR_SENSITIVE = 5
local g_showLabels = true
local g_showCrosshair = true

local g_mouseOver = true

local DISTANCE_DECIMAL_PLACES = 3
local INFO_COLOR = -3618561
local INFO_SCALE,INFO_FONT = 1,"default"
local START_X, START_Y, START_Z = 2483, -1666, 21
local START_LOOKX, START_LOOKY, START_LOOKZ = 2483, -1566, 21

local g_dragPosition = { }
local g_dragElement
local g_dragTimer
local DRAG_MINIMUM_CLICK_TIME = 300
local DRAG_CURSOR_MINIMAL_DISTANCE = 5
local DRAG_CAMERA_MINIMAL_DISTANCE = 2

local g_lastClick = { tick=getTickCount() }
local DOUBLE_CLICK_MAX_DELAY = 500 -- In ticks

local g_lock = {}

setCloudsEnabled(false) -- We don't need clouds.
setAmbientSoundEnabled("gunfire", false) -- We don't need random gun shots.

-- PRIVATE
local isColless = {
	marker = true,
	vehicle = true,
	pickup = true,
	ped = true,
	water = true,
}
local hasCol = {
	object = true,
}
local noInteriors = {
	marker = true,
	pickup = true,
	water = true,
}
local attachable = {
	marker = true,
	vehicle = true,
	pickup = true,
	object = true,
	ped = true,
	water = true,
}

local hitComponents = function (hit)
	if hit then return hit.x, hit.y, hit.z
	else return nil end
end

local commonIntersection = function (startX, startY, startZ, endX, endY, endZ, centerX, centerY, centerZ, element)
	local _start = Vector3D:new(startX, startY, startZ)
	local _end = Vector3D:new(endX, endY, endZ)
	local _center = Vector3D:new(centerX, centerY, centerZ)

	local elementType = getElementType(element)
	local radius
	if (elementType == "pickup") then
		radius = 1
	elseif (elementType == "marker") then
		radius = getMarkerSize(element)
	else
		radius = getElementRadius(element)
	end
	return hitComponents(collisionTest.Sphere(_start, _end, _center, radius))
end

local specialIntersections = {
	marker = function (startX, startY, startZ, endX, endY, endZ, centerX, centerY, centerZ, element)
		local markerType = getMarkerType(element)
		local _start = Vector3D:new(startX, startY, startZ)
		local _end = Vector3D:new(endX, endY, endZ)
		local _center = Vector3D:new(centerX, centerY, centerZ)
		local size = getMarkerSize(element)

		if markerType == "corona" or markerType == "ring" or markerType == "arrow" then
			return hitComponents(collisionTest.Sphere(_start, _end, _center, size))
		elseif markerType == "cylinder" then
			return hitComponents(collisionTest.Cylinder(_start, _end, _center, size, size))
		elseif markerType == "checkpoint" then
			return hitComponents(collisionTest.Cylinder(_start, _end, _center, size, 60 * size))
		end
	end,
	water = function (startX, startY, startZ, endX, endY, endZ, centerX, centerY, centerZ, element)
		local _start = Vector3D:new(startX, startY, startZ)
		local _end = Vector3D:new(endX, endY, endZ)
		local _center = Vector3D:new(centerX, centerY, centerZ)
		--
		local x1 = getWaterVertexPosition ( element, 1 )
		local x2,y1 = getWaterVertexPosition ( element, 2 )
		--
		sizeX = x2 - x1
		--
		local _,y2 = getWaterVertexPosition ( element, 3 )
		sizeY = y2 - y1

		return hitComponents(collisionTest.Rectangle(_start, _end, _center, sizeX, sizeY))
	end,
}

function startWhenLoaded()
	engineSetAsynchronousLoading ( false, true )
	if getElementData(resourceRoot,"g_in_test") then
		setElementData ( localPlayer, "waitingToStart", true, false )
		return
	end
	if isInterfaceLoaded() then
		removeEventHandler("onClientResourceStart", root, startWhenLoaded)
		loadRotationFixXML()
		startEditor()
	end
end
addEventHandler("onClientResourceStart", root, startWhenLoaded)

addEventHandler("doSelectElement", root,
	function (submode,shortcut)
		submode = submode or 1
		selectElement(source, submode,shortcut)
	end
)

addEventHandler("onClientRender", root,
	function ()
		if g_suspended or getElementData(resourceRoot,"g_in_test") then
			return
		end
		--
		local camX, camY, camZ, endX, endY, endZ = getCameraLine()
		local labelCenterX,labelCenterY,crosshairState
		if g_mode == CAMERA_MODE then
			crosshairState = setCrosshairState
			labelCenterX,labelCenterY = g_screenX/2, g_screenY/2
		else
			if editor_gui.guiGetMouseOverElement() then return end
			labelCenterX,labelCenterY, endX,endY,endZ = getCursorPosition()
			if not labelCenterX or labelCenterX == 0 or labelCenterX == 1 or labelCenterY == 0 or labelCenterY == 1 then
				return
			end
			labelCenterX = labelCenterX * g_screenX
			labelCenterY = labelCenterY * g_screenY
			crosshairState = setCursorCrosshairState
		end
		if not g_mouseOver or isMTAWindowActive() or guiGetInputEnabled() then
			if g_targetedElement then
				g_targetedPart = nil
				g_targetedElement = nil
				setCrosshairState(CROSSHAIR_NOTHING)
			end
			return
		end
		if g_dragElement and not g_selectedElement then
			local camX2, camY2, camZ2, lookX, lookY, lookZ = getCameraMatrix()
			local distance = math.sqrt((g_dragPosition.x - lookX)^2 +
									   (g_dragPosition.y - lookY)^2 +
				 (g_dragPosition.z and (g_dragPosition.z - lookZ)^2 or 0))

			if distance > DRAG_CAMERA_MINIMAL_DISTANCE then
				selectElement(g_dragElement, MOUSE_SUBMODE)
			end
			return
		end

		local targetElement, targetX, targetY, targetZ, buildingInfo = getTargetedElement()
		if targetElement and not g_SelectWorldBuildingMode_main then
			if targetElement ~= g_targetedPart then
				g_targetedPart = targetElement
				g_targetedElement = edf.edfGetAncestor(targetElement)
			end

			local camX2, camY2, camZ2 = getCameraMatrix()
			local distance = math.sqrt( (targetX - camX2)^2 + (targetY - camY2)^2 + (targetZ - camZ2)^2 )
			local roundedDistance = string.format("%." .. (DISTANCE_DECIMAL_PLACES) .. "f", distance)
			createHighlighterText ( labelCenterX,labelCenterY,
							getElementID(g_targetedElement) or "",
							"["..getElementType(g_targetedElement).."]",
							roundedDistance .. " m"
			)
		else
			if g_targetedElement then
				g_targetedPart = nil
				g_targetedElement = nil
			end
		end

        -- HUD when selecting a world building
		g_worldBuildingInfo = nil
        if g_SelectWorldBuildingMode_main then
            local line1 = ( not g_RemoveWorldBuildingMode_main and "[SELECT WORLD OBJECT]" or "[REMOVE WORLD OBJECT]" )
            local line2 = ""
            local line3 = ""
			if not targetElement and buildingInfo then
				local camX2, camY2, camZ2 = getCameraMatrix()
				local distance = math.sqrt( (targetX - camX2)^2 + (targetY - camY2)^2 + (targetZ - camZ2)^2 )
				local roundedDistance = string.format("%." .. (DISTANCE_DECIMAL_PLACES) .. "f", distance)
				local modelName = tostring( engineGetModelNameFromID( buildingInfo.id ) )
				if ( buildingInfo.LODid ~= nil ) then
					line1 = buildingInfo.id .. " (" .. modelName .. ")" .. " LOD: " .. buildingInfo.LODid
				else
					line1 = buildingInfo.id .. " (" .. modelName .. ")"
				end
				line2 = "[world]"
				line3 = roundedDistance .. " m"
				g_worldBuildingInfo = buildingInfo
			end
			createHighlighterText ( labelCenterX,labelCenterY, line1, line2, line3 )
        end

		if g_sensitivityMode then
			crosshairState(CROSSHAIR_SENSITIVE)
			return
		end

		if targetElement and not g_selectedElement then
			crosshairState(CROSSHAIR_MOUSEOVER)
		else
			local waterCollision, wCX, wCY, wCZ = testLineAgainstWater(camX, camY, camZ, endX, endY, endZ)
			local groundCollision, gCX, gCY, gCZ =
				processLineOfSight(camX, camY, camZ, endX, endY, endZ, true, true, true, true, true, true, false, true, localPlayer)

			if waterCollision and groundCollision then
				if getDistanceBetweenPoints3D(wCX, wCY, wCZ, camX, camY, camZ) <= getDistanceBetweenPoints3D(gCX, gCY, gCZ, camX, camY, camZ) then
					crosshairState(CROSSHAIR_WATER)
				else
					crosshairState(CROSSHAIR_WORLD)
				end
			elseif waterCollision then
				crosshairState(CROSSHAIR_WATER)
			elseif groundCollision then
				crosshairState(CROSSHAIR_WORLD)
			else
				crosshairState(CROSSHAIR_NOTHING)
			end
		end
	end
)

addEventHandler("onClientElementStreamIn", root,
	function ()
		if isColless[getElementType(source)] then
			g_colless[source] = true
		end
	end
)

addEventHandler("onClientElementStreamOut", root,
	function ()
		if isColless[getElementType(source)] then
			g_colless[source] = nil
		end
	end
)

function startEditor()
	setWorkingInterior(0)
	disableCharacterSounds()
	attachPlayers(true)
	--disable these for now
	-- disableGameHUD()
	-- setElementAlpha(localPlayer, 0)
	--showChat(false)  Uncomment this line for release


	-- set up camera and submodes
	createCrosshair()
	setCameraMatrix(START_X, START_Y, START_Z,START_LOOKX, START_LOOKY, START_LOOKZ)
	setMode(CAMERA_MODE)


	fadeCamera(true, 2)

	bindInput()

	-- loop through collisionless elements, get a table of streamed ones, and freeze vehicles
	for eType in pairs(isColless) do
		for k, element in pairs(getElementsByType(eType)) do
			if eType == "vehicle" then
				makeVehicleStatic(element)
			elseif eType == "ped" then
				makePedStatic ( element )
			end
			if isElementStreamedIn(element) then
				g_colless[element] = true
			end
		end
	end
	loadColPatchArchive()
	loadColPatchPlacements()
end

function stopEditor()
	attachPlayers(false)
	engineSetAsynchronousLoading ( true, false )
	resetWorldSounds()
end
addEventHandler("onClientResourceStop", resourceRoot, stopEditor)

function toggleMode(key, keyState)
	if (g_mode == CAMERA_MODE) then
		setMode(CURSOR_MODE)
	else
		setMode(CAMERA_MODE)
	end
end

function keyboardUndo()
	if getKeyState("lctrl") or getKeyState("rctrl") then
		return triggerServerEvent("doUndo", localPlayer)
	end
end

function keyboardRedo()
	if getKeyState("lctrl") or getKeyState("rctrl") then
		return triggerServerEvent("doRedo", localPlayer)
	end
end

function pickupSelectedElement()
	if ( g_submode == KEYBOARD_SUBMODE ) then
		local element = g_selectedElement
		selectElement(element,MOUSE_SUBMODE)
	end
end

function processLineForElements(startX, startY, startZ, endX, endY, endZ)
	local foundElement = false
	local hitX, hitY, hitZ = nil, nil, nil
	--limit foundElementDistance to distance to endpoint because the collision check goes past the endpoint for some reason
	local foundElementDistance = math.sqrt((endX-startX)^2 + (endY-startY)^2 + (endZ-startZ)^2)
	for v in pairs(g_colless) do
		while true do
			--forget elements that have been destroyed
			if not isElement(v) then
				g_colless[v] = nil
				break
			end
			--ignore if it's in a different dimension
			if getElementDimension(v) ~= getWorkingDimension() then
				break
			end

			--ignore if its not a valid type
			local strType = getElementType(v)
			if not isColless[strType] and strType ~= "object" then
				g_colless[v] = nil
				break
			end

			--ignore if it's in a different interior
			if not noInteriors[strType] and getElementInterior(v) ~= g_workingInterior then
				break
			end
			--ignore selection arrow marker
			if v == g_arrowMarker then
				break
			end
			local centerX, centerY, centerZ = getElementPosition(v)
			local distance = math.sqrt((centerX-startX)^2 + (centerY-startY)^2 + (centerZ-startZ)^2)

			if (distance <= foundElementDistance) then
				local intersection = specialIntersections[getElementType(v)] or commonIntersection
				local _hitX, _hitY, _hitZ = intersection(startX, startY, startZ, endX, endY, endZ, centerX, centerY, centerZ, v)

				if _hitX then
					foundElement = v
					foundElementDistance = distance
					hitX = _hitX
					hitY = _hitY
					hitZ = _hitZ
				end
			end
			break
		end
	end
	return foundElement, hitX, hitY, hitZ
end

-- selects element mouse is pointing to, or drops selected element (freecam mode)
function processFreecamClick(key, keyState)
	if g_mode ~= CAMERA_MODE then
		return
	end
	local drop
	if (not g_suspended) then
		local clickedElement, targetX, targetY, targetZ = getTargetedElement()
		
		local camX, camY, camZ, lookX, lookY, lookZ = getCameraMatrix()
		local distance = math.sqrt((targetX - camX)^2 + (targetY - camY)^2 + (targetZ - camZ)^2)

		if clickedElement and (distance > g_maxSelectDistance) then
			local elementType = (isElement(clickedElement) == true and ": " .. getElementType(clickedElement)) or ""
			outputDebugString("Cannot select out of range element" .. elementType .. " at distance: " .. distance)
			clickedElement = nil
		end
		processClick ( clickedElement, key, keyState, lookX, lookY, lookZ )
	end
end

function processClick ( clickedElement, key, keyState, lookX, lookY, lookZ )

    -- Hook for select a world building
	if handleWorldBuildingMode( keyState ) then
		return
	end

	if not isElement(clickedElement) then clickedElement = nil end
	if keyState == "down" then
		if ((getTickCount() - DOUBLE_CLICK_MAX_DELAY) <= g_lastClick.tick)
			and g_lastClick.key == key
			and g_lastClick.element == clickedElement then
			return processDoubleClick ( clickedElement, key )
		end
		g_lastClick = { key = key, element = clickedElement, tick = getTickCount()  }
		if clickedElement then
			g_dragTimer = setTimer ( function()
					g_dragPosition.x = lookX
					g_dragPosition.y = lookY
					g_dragPosition.z = lookZ
					g_dragElement = clickedElement
				end,
				DRAG_MINIMUM_CLICK_TIME,
				1
				)
		else
			g_dragElement = nil
		end
		return
	end
	for k,timer in ipairs(getTimers()) do
		if timer == g_dragTimer then
			killTimer ( timer )
			g_dragTimer = nil
			break
		end
	end

	-- attach element
	if (clickedElement) then
		if (g_selectedElement) then
			g_dragElement = nil
			if g_submode == MOUSE_SUBMODE then
				dropElement(true,true) --Drop it, and stop here
				return
			end
		end

		if g_selectedElement ~= clickedElement and g_lock[edf.edfGetAncestor(clickedElement)] then
			editor_gui.outputMessage("This element is locked, Press '"..cc["lock_selected_element"]:upper().."' to unlock it.", 255,255,255)
			return false
		end

		if (key == "select_target_mouse") then
			selectElement(clickedElement, MOUSE_SUBMODE, false, g_selectedElement, g_selectedElement)
		elseif (key == "select_target_keyboard") then
			selectElement(clickedElement, KEYBOARD_SUBMODE, false, g_selectedElement, g_selectedElement)
		end
	elseif (g_selectedElement) then
		if g_submode == MOUSE_SUBMODE then
			g_dragElement = nil
			if (key == "select_target_mouse") then
				dropElement(true,true)
			elseif (key == "select_target_keyboard") then
				local reselect = g_selectedElement
				selectElement(reselect, KEYBOARD_SUBMODE, false, true, true)
			end
		else
			dropElement(true,true)
			g_dragElement = nil
		end
	end
end

function processDoubleClick ( clickedElement, key )
	if not clickedElement then return end

	if g_selectedElement ~= clickedElement and g_lock[edf.edfGetAncestor(clickedElement)] then
		editor_gui.outputMessage("This element is locked, Press '"..cc["lock_selected_element"]:upper().."' to unlock it.", 255,255,255)
		return false
	end

	if triggerEvent ( "onClientElementDoubleClick", clickedElement, key ) then
		if key == "select_target_keyboard" then
			if ( selectElement(clickedElement, KEYBOARD_SUBMODE) ) then
				editor_gui.openPropertiesBox(g_selectedElement)
			end
		end
	end
end

function getTargetedElement(hitX, hitY, hitZ)
	local targetX, targetY, targetZ, targetedElement

	if (g_mode == CAMERA_MODE) then
		targetX, targetY, targetZ, targetedElement, buildingInfo = processCameraLineOfSight()
	elseif (g_mode == CURSOR_MODE) then
		targetX, targetY, targetZ, targetedElement, buildingInfo = processCursorLineOfSight()
	end

	local camX, camY, camZ = getCameraMatrix()

	-- check for collisionless elements between camera and collision point
	local tempElement, tempHitX, tempHitY, tempHitZ =
		processLineForElements(camX, camY, camZ, targetX, targetY, targetZ)

	-- if collisionless element was found in front of the collision point, use it
	if (tempElement) then
		targetedElement = tempElement
		targetX, targetY, targetZ = tempHitX, tempHitY, tempHitZ
	end

	if targetedElement then
		if getElementType(targetedElement) == "player" then
			targetedElement = false
		end
	end

	return targetedElement, targetX, targetY, targetZ, buildingInfo
end

function createCrosshair()
	g_showLabels = true
	setCrosshairState(CROSSHAIR_NOTHING)
end

function createHighlighterText ( absX,absY,text1,text2,text3 )
	if not g_showLabels then return false end
	local height = dxGetFontHeight ( INFO_SCALE, INFO_FONT )
	--
	local extent = dxGetTextWidth ( text1, INFO_SCALE, INFO_FONT )
	local xPos = absX - (extent/2)
	local yPos = absY - 48
	--First one is for the shaddow
	dxDrawText ( text1, xPos + 1, yPos + 1, xPos + extent, yPos + height, -16777216, INFO_SCALE, INFO_FONT )
	dxDrawText ( text1, xPos, yPos, xPos + extent, yPos + height, INFO_COLOR, INFO_SCALE, INFO_FONT )
	--
	extent = dxGetTextWidth ( text2, INFO_SCALE, INFO_FONT )
	xPos = absX - (extent/2)
	yPos = absY - 32
	dxDrawText ( text2, xPos + 1, yPos + 1, xPos + extent, yPos + height, -1728053248, INFO_SCALE, INFO_FONT )
	dxDrawText ( text2, xPos, yPos, xPos + extent, yPos + height, -1714894593, INFO_SCALE, INFO_FONT )
	--
	extent = dxGetTextWidth ( text3, INFO_SCALE, INFO_FONT )
	xPos = absX - (extent/2)
	yPos = absY + 16
	dxDrawText ( text3, xPos + 1, yPos + 1, xPos + extent, yPos + height, -16777216, INFO_SCALE, INFO_FONT )
	dxDrawText ( text3, xPos, yPos, xPos + extent, yPos + height, INFO_COLOR, INFO_SCALE, INFO_FONT )
	return true
end


function setCrosshairState(state)
	if not g_showCrosshair then return end
	local color = tocolor(255,255,255,102)
	if state == CROSSHAIR_WORLD then
		color = tocolor(255,255,255,255)
	elseif state == CROSSHAIR_WATER then
		color = tocolor(80,203,227,255)
	elseif state == CROSSHAIR_MOUSEOVER then
		color = tocolor(191,203,134,255)
	elseif state == CROSSHAIR_SENSITIVE then
		color = tocolor(255,0,0,255)
	end
	dxDrawImage ( g_screenX/2 - 16, g_screenY/2 - 16, 32, 32, "client/images/crosshair.png",0,0,0,color,false)
end

function setCursorCrosshairState(state)
	-- if not g_showCrosshair then return end
	if state == CROSSHAIR_NOTHING or state == CROSSHAIR_WORLD then
		return
	elseif state == CROSSHAIR_WATER then
		color = tocolor(80,203,227,255)
	elseif state == CROSSHAIR_MOUSEOVER then
		color = tocolor(191,203,134,255)
	elseif state == CROSSHAIR_SENSITIVE then
		color = tocolor(255,0,0,255)
	end
	local x,y = getCursorPosition()
	dxDrawImage ( g_screenX*x - 2, g_screenY*y - 1, 15, 15,  "client/images/cursor.png", 0,0,0,color,true )
end

function makeVehicleStatic(vehicle)
	vehicle = vehicle or source
	setVehicleDamageProof(vehicle, true)
	setElementFrozen(vehicle, true)
	setElementCollisionsEnabled(vehicle, false)
end
addEventHandler("doSetVehicleStatic", root, makeVehicleStatic)

function makePedStatic(ped)
	ped = ped or source
	setElementCollisionsEnabled ( ped, false )
end
addEventHandler("doSetPedStatic", root, makePedStatic)

function setRepresentationCollisionsEnabled(element, state)
	for k, child in ipairs(getElementChildren(element)) do
		if edf.edfGetParent(child) == element then
			if hasCol[getElementType(child)] then
				setElementCollisionsEnabled(child, state)
			end
			setRepresentationCollisionsEnabled(child, state)
		end
	end
end

-- Drag and drop
function processCursorMove(cursorX, cursorY, absoluteX, absoluteY, worldX, worldY, worldZ)
	if g_dragElement then
		local distance = math.sqrt((absoluteX - g_dragPosition.x)^2 + (absoluteY - g_dragPosition.y)^2)
		if distance > DRAG_CURSOR_MINIMAL_DISTANCE
		then
			selectElement(g_dragElement, MOUSE_SUBMODE)
			g_dragPosition = { }
			g_dragElement = nil
		end
	end
end

-- selects element mouse is pointing to, or drops selected element (cursor mode)
function processCursorClick(button, keyState,cursorX, cursorY, worldX, worldY, worldZ, clickedElement)
	local clickedGUI
	if editor_gui then
		clickedGUI = editor_gui.guiGetMouseOverElement()
	end

	local key = getControlFromMouseKey(mouseButtonToKeyName(button))
	if ( clickedGUI ) or g_suspended or not g_enableWorld or not key then
        maybeCancelWorldBuildingMode(keyState)
		return
	end

	local targetElement, targetX, targetY, targetZ = getTargetedElement(worldX, worldY, worldZ)
	clickedElement = targetElement or clickedElement

	if clickedElement then
		-- get start point of vector
		local camX, camY, camZ = getCameraMatrix()
		-- get end point of vector
		local hitX, hitY, hitZ = targetX, targetY, targetZ--worldX, worldY, worldZ
		local distance = math.sqrt((hitX - camX)^2 + (hitY - camY)^2 + (hitZ - camZ)^2)
		if (distance > g_maxSelectDistance) then
			local elementType = (isElement(clickedElement) == true and ": " .. getElementType(clickedElement)) or ""
			outputDebugString("Cannot select out of range element" .. elementType .. " at distance: " .. distance)
			clickedElement = nil
		end
	end
	processClick ( clickedElement, key, keyState, cursorX, cursorY )
end

function getCameraLine()
	-- get start point of vector
	 camX, camY, camZ, endX, endY, endZ = getCameraMatrix()

	-- alter the vector length to fit the maximum distance
	local distance = getDistanceBetweenPoints3D ( camX, camY, camZ, endX, endY, endZ )
	targetX = camX + ((endX - camX)/distance) * g_maxSelectDistance
	targetY = camY + ((endY - camY)/distance) * g_maxSelectDistance
	targetZ = camZ + ((endZ - camZ)/distance) * g_maxSelectDistance

	return camX, camY, camZ, endX, endY, endZ
end

function mouseButtonToKeyName( buttonName )
	if buttonName == "left" then
		return "mouse1"
	elseif buttonName == "right" then
		return "mouse2"
	elseif buttonName == "middle" then
		return "mouse3"
	end
end

function getControlFromMouseKey( mouseKey )
	if mouseKey == cc.select_target_keyboard then return "select_target_keyboard"
	elseif mouseKey == cc.select_target_mouse then return "select_target_mouse"
	end
end

function disableGameHUD()
	setPlayerHudComponentVisible("area_name", false)
	setPlayerHudComponentVisible("armour", false)
	setPlayerHudComponentVisible("breath", false)
	setPlayerHudComponentVisible("clock", false)
	setPlayerHudComponentVisible("health", false)
	setPlayerHudComponentVisible("money", false)
	setPlayerHudComponentVisible("vehicle_name", false)
	setPlayerHudComponentVisible("weapon", false)
end

-- PUBLIC
function selectElement(element, submode, shortcut, dropreleaseLock, dropclonedrop, ignoreProperties)
	local openProperties
	submode = submode or g_submode

	if not isElement(element) then return end
	
	if isColPatchObject(element) then return end

	if getElementType(element) == "vehicle" and getVehicleType(element) == "Train" then
		setTrainDerailed(element, true)
	end

	if not triggerEvent ( "onClientElementSelect", element, submode, shortcut ) then return false end

	if g_selectedElement then
		dropElement(dropreleaseLock, dropclonedrop)
	end

	-- check the editing lock
	local locked = getElementData(element, "me:locked")
	if locked and locked ~= localPlayer then
		assert(isElement(locked), "Bad lock owner ["..tostring(locked).."] for element: "..getElementType(element))
		editor_gui.outputMessage("Cannot select element, it is being controlled by " .. getPlayerName(locked), 255,255,255)
		return false
	end

	-- check if the element is, or is part of, an EDF element
	element = edf.edfGetAncestor(element)
	local handle  = edf.edfGetHandle(element)

	if not handle then
		if attachable[getElementType(element)] then
			handle = element
		else
			handle = nil
		end
	end

	assert(handle == nil or isElement(handle), "Bad handle ["..tostring(handle).."] for element: "..getElementType(element))

	-- if we can position this element, grab it and add the markers
	if handle then
		local move_resource
		if (submode == MOUSE_SUBMODE) then
			if (g_mode == CAMERA_MODE) then
				move_resource = move_freecam
			elseif (g_mode == CURSOR_MODE) then
				move_resource = move_cursor
			end
			move_resource.setMaxMoveDistance(g_moveDistance)
			-- if we're dragging the object, disable collisions for all parts so the cursor can point through it
			setRepresentationCollisionsEnabled(element, false)
		elseif (submode == KEYBOARD_SUBMODE) then
			move_resource = move_keyboard
		else
			error("Element selection submode is invalid",2)
		end

		assert(move_resource.attachElement(handle), "move resource call failed when attaching element: " .. tostring(getElementType(element)))
	end

	g_submode = submode
	g_selectedPart = handle
	g_selectedElement = element

	if handle then
		--create the editor blip and keyboard arrow pointing to the handle
		g_editorBlip = createBlipAttachedTo(handle, 0, 2, 255, 255, 0, 255)
		if (submode == KEYBOARD_SUBMODE) then
			createArrowMarker(handle)
		end
	else
		if not ignoreProperties then
			editor_gui.openPropertiesBox( element, false, shortcut )
			openProperties = true
		end
	end

	-- fix for local elements
	if not isElementLocal(element) then
		triggerServerEvent("doLockElement", element)
	
		-- trigger server selection events
		triggerServerEvent("onElementSelect", element)
	end

	--Emulate a fake mouse  move to get the element to position properly
	-- if not openProperties then
		-- local cursorX, cursorY = 0.5,0.5
		-- local absoluteX = math.ceil(g_screenX*cursorX)
		-- local absoluteY = math.ceil(g_screenY*cursorY)
		-- worldX, worldY, worldZ = getWorldFromScreenPosition ( absoluteX, absoluteY, 100 )
		-- triggerEvent ( "onClientCursorMove", root, cursorX, cursorY, absoluteX, absoluteY, worldX, worldY, worldZ )
	-- end

	if ( shortcut ) then
		if not openProperties then
			editor_gui.openPropertiesBox( element, false, shortcut )
		end
	end

	outputConsole("Attached element: " .. getElementType(element))
	return true
end

function dropElement(releaseLock,clonedrop)
	if not g_selectedElement or not isElement(g_selectedElement) then
		return false
	end

	-- trigger client selection events
	if not triggerEvent("onClientElementDrop", g_selectedElement) then return false end

	if releaseLock ~= false then
		releaseLock = true
	end

	-- re-enable collisions for all parts
	setRepresentationCollisionsEnabled(g_selectedElement, true)

	if g_selectedPart then
		local move_resource
		if (g_submode == MOUSE_SUBMODE) then
			if (g_mode == CAMERA_MODE) then
				move_resource = move_freecam
			elseif (g_mode == CURSOR_MODE) then
				move_resource = move_cursor
			end
			g_moveDistance = move_resource.getMaxMoveDistance()
		elseif (g_submode == KEYBOARD_SUBMODE) then
			move_resource = move_keyboard
		end

		assert(move_resource.detachElement(), "move resource call failed when detaching element: " .. tostring(getElementType(g_selectedElement)))

		--destroy the editor blip and keyboard arrow pointing to the handle
		destroyElement(g_editorBlip)
		if (g_submode == KEYBOARD_SUBMODE) then
			showGridlines ( false )
			destroyElement(g_arrowMarker)
			g_arrowMarker = nil
		end
	end

	if releaseLock then
		-- fix for local elements
		if not isElementLocal(g_selectedElement) then
			triggerServerEvent("doUnlockElement", g_selectedElement)
		end
	end

	-- fix for local elements
	if not isElementLocal(g_selectedElement) then
		-- trigger server selection events
		triggerServerEvent("onElementDrop", g_selectedElement)
	end
	
	-- Clear rotation as it can be rotated by other players
	clearElementQuat(g_selectedElement)

	local droppedElement = g_selectedElement
	g_selectedElement = false
	g_selectedPart = false

	outputConsole("Detached element.")

	if getCommandState("clone_drop_modifier") and clonedrop then
		return doCloneElement(droppedElement)
	else
		return true
	end
end

-- sets the camera mode to cursor or freecam
function setMode(newMode)
	if g_suspended then
		return
	end
	
	if not isElement(g_selectedElement) then
		g_selectedElement = nil
	end

	if newMode == CAMERA_MODE then
		if (g_selectedElement and g_submode == MOUSE_SUBMODE) then
			move_cursor.detachElement()
			g_moveDistance = move_cursor.getMaxMoveDistance()
			showCursor(false)
			move_freecam.attachElement(edf.edfGetHandle(g_selectedElement) or g_selectedElement)
			move_freecam.setMaxMoveDistance(g_moveDistance)
		else
			showCursor(false)
		end

		triggerEvent("onFreecamMode", root)
		freecam.setFreecamEnabled(false, false, false, true)

		bindControl("select_target_mouse", "both", processFreecamClick)
		bindControl("select_target_keyboard", "both", processFreecamClick)

		if g_mode == CURSOR_MODE then
			removeEventHandler("onClientCursorMove", root, processCursorMove)
			removeEventHandler("onClientClick", root, processCursorClick)
		end

		showCrosshair(true,true)
		g_mode = newMode

		return true
	elseif newMode == CURSOR_MODE then
		if (g_selectedElement and g_submode == MOUSE_SUBMODE) then
			move_freecam.detachElement()
			g_moveDistance = move_freecam.getMaxMoveDistance()
			showCursor(true)
			move_cursor.attachElement(edf.edfGetHandle(g_selectedElement) or g_selectedElement)
			move_cursor.setMaxMoveDistance(g_moveDistance)
		else
			showCursor(true)
		end

		triggerEvent("onCursorMode", root)
		freecam.setFreecamDisabled(true)

		addEventHandler("onClientCursorMove", root, processCursorMove)
		addEventHandler("onClientClick", root, processCursorClick)

		if g_mode == CAMERA_MODE then
			unbindControl("select_target_mouse", "both", processFreecamClick)
			unbindControl("select_target_keyboard", "both", processFreecamClick)
		end

		showCrosshair(false)
		g_mode = newMode

		return true
	else
		error("Requested mode is invalid", 2)
	end
end

-- sets the maximum distance at which an element can be selected
function setMaxSelectDistance(distance)
	assert((distance >= 0), "Distance must be a positive number.")
	g_maxSelectDistance = distance
	return true
end

function getSelectedElement()
	return g_selectedElement or false
end

function getMode()
	return g_mode
end

function getSubmode()
	return g_submode
end

function getMaxSelectDistance()
	return g_maxSelectDistance
end

function destroySelectedElement(key)
	if key then
		editor_gui.restoreSelectedElement()
	end
	if g_selectedElement then
		local element = g_selectedElement
		dropElement(false)
		
		-- fix for local elements
		if isElementLocal(element) then
			outputDebugString("Cannot destroy local element.")
			return false
		end
		
		return triggerServerEvent("doDestroyElement", element)
	end
end

function createElement_cmd(cmd, elementType, resourceName)
	if elementType and resourceName then
		doCreateElement(elementType, resourceName)
	else
		outputConsole("* Syntax: /"..cmd.." <type> <from-definition>")
	end
end

function cloneSelectedElement()
	if g_selectedElement then
		if g_submode == KEYBOARD_SUBMODE then
			editor_gui.outputMessage ( "WARNING: The selected element has been cloned on top of itself.", 255, 130, 0 )
		end
		doCloneElement ( g_selectedElement, g_submode )
	end
end

function lockSelectedElement(element,state)
	local targetElement = isElement(element) and element or getTargetedElement()
	if targetElement then
		if isElementLocked(targetElement) == state then return end
		if g_lock[targetElement] then
			g_lock[targetElement] = nil
			editor_gui.outputMessage("You have unlocked this element.", 50,255,50)
		else
			g_lock[targetElement] = true
			editor_gui.outputMessage("You have locked this element.", 50,255,50)
		end
	end
end

function isElementLocked(element)
	if isElement(element) then
		return g_lock[element] or false
	end
end

addEventHandler("onClientElementDestroy",resourceRoot,
function ()
	if g_lock[source] then
		g_lock[source] = nil
	end
end)

function showCrosshair(status,labelStatus)
	g_showCrosshair = status
	-- g_showLabels = labelStatus
	return true
end

function getWorkingInterior()
	return g_workingInterior
end

function setWorkingInterior( interior )
	setCameraInterior( interior )
	setElementInterior(localPlayer, interior)
	g_workingInterior = interior
	return true
end

function suspend(leavePlayersAttached)
	if g_suspended then
		return false
	end

	outputConsole("Suspending editor_main.")

	local move_resource
	if (g_submode == MOUSE_SUBMODE) then
		if (g_mode == CAMERA_MODE) then
			move_resource = move_freecam
		elseif (g_mode == CURSOR_MODE) then
			move_resource = move_cursor
		end
	elseif (g_submode == KEYBOARD_SUBMODE) then
		move_resource = move_keyboard
	end

	move_resource.disable()
	unbindInput(true)
	triggerEvent("onEditorSuspended",root)
	editor_gui.setGUIShowing(false)
	showCrosshair(false,false)

	if (g_mode == CAMERA_MODE) then
		triggerEvent("doSetFreecamDisabled", root, true)
		unbindControl("select_target_mouse", "both", processFreecamClick)
	elseif (mode == CURSOR_MODE) then
		showCursor(false,false)
	end
	g_suspendedCamera = { getCameraMatrix() }
	if not leavePlayersAttached then
		attachPlayers(false)
	end
	g_suspended = true
end

function resume(dontEnableMove)
	if (not g_suspended) then
		return false
	end

	outputConsole("Resuming editor_main.")

	local move_resource
	if (g_submode == MOUSE_SUBMODE) then
		if (g_mode == CAMERA_MODE) then
			move_resource = move_freecam
			bindControl("select_target_mouse", "both", processFreecamClick)
			bindControl("select_target_keyboard", "both", processFreecamClick)
		elseif (g_mode == CURSOR_MODE) then
			move_resource = move_cursor
		end
	elseif (g_submode == KEYBOARD_SUBMODE) then
		move_resource = move_keyboard
	end

	if not dontEnableMove then
		move_resource.enable()
	end
	bindInput(true)
	triggerEvent("onEditorResumed",root)
	editor_gui.setGUIShowing(true)

	setElementInterior ( localPlayer, getWorkingInterior() )
	setCameraInterior ( getWorkingInterior() )
	setCameraMatrix ( unpack(g_suspendedCamera) )

	if (g_mode == CAMERA_MODE) then
		triggerEvent("doSetFreecamEnabled", root, false, false, false, true)
		showCrosshair(true,true)
	elseif (g_mode == CURSOR_MODE) then
		showCursor(true)
		showCrosshair(false,true)
	end
	attachPlayers(true)
	disableCharacterSounds()
	g_suspended = false
end

function bindInput(commandsOnly)
	addCommandHandler("clone", cloneSelectedElement)
	addCommandHandler("create", createElement_cmd)
	addCommandHandler("destroy", destroySelectedElement)
	addCommandHandler("delete", destroySelectedElement)
	addCommandHandler("lock", lockSelectedElement)
	if ( commandsOnly ) then
		return true
	end

	bindControl("toggle_cursor", "down", toggleMode)
	bindControl("pickup_selected_element", "down", pickupSelectedElement)
	bindControl("destroy_selected_element", "down", destroySelectedElement)
	bindControl("clone_selected_element", "down", cloneSelectedElement)
	bindControl("drop_selected_element", "down", dropElement)
	bindControl("undo", "down", keyboardUndo)
	bindControl("redo", "down", keyboardRedo)
	bindControl("high_sensitivity_mode", "down", toggleSensitivityMode)
	bindControl("lock_selected_element", "down", lockSelectedElement)
end

function unbindInput(commandsOnly)
	removeCommandHandler("clone", cloneSelectedElement)
	removeCommandHandler("create", createElement_cmd)
	removeCommandHandler("destroy", destroySelectedElement)
	removeCommandHandler("delete", destroySelectedElement)
	removeCommandHandler("lock", lockSelectedElement)

	if ( commandsOnly ) then
		return true
	end
	unbindControl("toggle_cursor", "down", toggleMode)
	unbindControl("pickup_selected_element", "down", pickupSelectedElement)
	unbindControl("destroy_selected_element", "down", destroySelectedElement)
	unbindControl("clone_selected_element", "down", cloneSelectedElement)
	unbindControl("drop_selected_element", "down", dropElement)
	unbindControl("undo", "down", keyboardUndo)
	unbindControl("redo", "down", keyboardRedo)
	unbindControl("high_sensitivity_mode", "down", toggleSensitivityMode)
	unbindControl("lock_selected_element", "down", lockSelectedElement)
end

-- get the point and element targeted by the camera
function processCameraLineOfSight()
	local camX, camY, camZ, endX, endY, endZ = getCameraLine()

	-- get collision point on the line
	local surfaceFound, targetX, targetY, targetZ, targetElement,
            nx, ny, nz, material, lighting, piece,
            buildingId, bx, by, bz, brx, bry, brz, buildingLOD
		= processLineOfSight(camX, camY, camZ, endX, endY, endZ, true, true, true, true, true, false, false, false, localPlayer, true)
	
	-- Is this a collision patch object
	if targetElement and isColPatchObject(targetElement) then
		local cp = isColPatchObject(targetElement)
		-- Make it look like we hit a world model
		buildingId, bx, by, bz, brx, bry, brz = cp.id, cp.x, cp.y, cp.z, cp.rx, cp.ry, cp.rz
		targetElement = nil
	end
	
	-- if there is none, use the end point of the vector as the collision point
	if not surfaceFound then
	    targetX, targetY, targetZ = endX, endY, endZ
	end

	local buildingInfo = buildingId and { LODid=buildingLOD, id=buildingId, x=( bx == 0 and targetX or bx ), y=( by == 0 and targetY or by ), z=( bz == 0 and targetZ or bz ), rx=brx, ry=bry, rz=brz }

	return targetX, targetY, targetZ, targetElement, buildingInfo
end

-- get the point and element targeted by the cursor
function processCursorLineOfSight()
	-- get start point of vector
	local camX, camY, camZ = getCameraMatrix()

	--! getCursorPosition is innacurate, so we get the coordinates from the click event
	local cursorX, cursorY, endX, endY, endZ = getCursorPosition()

	local surfaceFound, targetX, targetY, targetZ, targetElement,
            nx, ny, nz, material, lighting, piece,
            buildingId, bx, by, bz, brx, bry, brz, buildingLOD
        = processLineOfSight(camX, camY, camZ, endX, endY, endZ, true, true, true, true, true, false, false, false, localPlayer, true)

	-- Is this a collision patch object
	if targetElement and isColPatchObject(targetElement) then
		local cp = isColPatchObject(targetElement)
		-- Make it look like we hit a world model
		buildingId, bx, by, bz, brx, bry, brz = cp.id, cp.x, cp.y, cp.z, cp.rx, cp.ry, cp.rz
		targetElement = nil
	end

	-- if there is none, use the end point of the vector as the collision point
	if not surfaceFound then
	    targetX, targetY, targetZ = endX, endY, endZ
	end

	local buildingInfo = buildingId and { LODid=buildingLOD, id=buildingId, x=( bx == 0 and targetX or bx ), y=( by == 0 and targetY or by ), z=( bz == 0 and targetZ or bz ), rx=brx, ry=bry, rz=brz }

	return targetX, targetY, targetZ, targetElement, buildingInfo
end

function setWorldClickEnabled ( bool )
	g_enableWorld = bool
	return true
end

function toggleEditorKeys ( bool )
	if bool then
		bindControl("toggle_cursor", "down", toggleMode) --possibly add a check to check if its already bound
	else
		unbindControl("toggle_cursor", "down", toggleMode) --possibly add a check to check if its already bound
	end
end

function enableMouseOver ( bool )
	g_mouseOver = bool
	return
end

function updateArrowMarker( element )
	if not g_arrowMarker then return end

	element = element or g_selectedElement
	if not element then return end

	local radius = edf.edfGetElementRadius(element) or 1

	local offsetZ = radius + 1
	local markerSize = math.max(g_arrowMarkerMinSize,g_arrowMarkerSizeRatio*radius)

	if isElementAttached(g_arrowMarker) then
		detachElements(g_arrowMarker, getElementAttachedTo(g_arrowMarker))
	end
	setMarkerSize(g_arrowMarker, markerSize)
	attachElements(g_arrowMarker, element, 0, 0, offsetZ)
	showGridlines ( element )
end

function createArrowMarker( handle )
	if not handle or not isElement(handle) then return end

	if g_arrowMarker then destroyElement(g_arrowMarker) end

	g_arrowMarker = createMarker(0, 0, 0, "arrow", .5, 255, 255, 0, 255)
	setElementDimension(g_arrowMarker, getWorkingDimension())
	updateArrowMarker( handle )
end

function setMovementType( movementType )
	if g_arrowMarker then
		if movementType == "move" then
			setMarkerColor(g_arrowMarker, 255, 255, 0)
		elseif movementType == "rotate" or movementType == "rotate_world" then
			setMarkerColor(g_arrowMarker, 0, 255, 0)
		elseif movementType == "rotate_local" then
			setMarkerColor(g_arrowMarker, 0, 255, 255)
		end
	end
end

function toggleSensitivityMode ()
	g_sensitivityMode = not g_sensitivityMode
	--Only with objects for now
	for i,element in ipairs(getElementsByType"object") do
		if isElementStreamedIn(element) then
			g_colless[element] = g_sensitivityMode or nil
		end
	end
	if g_sensitivityMode then
		addEventHandler ( "onClientElementStreamIn", root, streamInCollessObjects )
		addEventHandler ( "onClientElementStreamOut", root, streamOutCollessObjects )
	else
		removeEventHandler ( "onClientElementStreamIn", root, streamInCollessObjects )
		removeEventHandler ( "onClientElementStreamOut", root, streamOutCollessObjects )
	end
end

function streamInCollessObjects()
	if getElementType(source) == "object" then
		g_colless[source] = true
	end
end

function streamOutCollessObjects()
	if getElementType(source) == "object" then
		g_colless[source] = nil
	end
end


--
-- World building clone functions
--

-- Catch create event and switch on 'Select World Building Mode'
addEvent ( "onClientElementPreCreate" )
addEventHandler( "onClientElementPreCreate", root,
	function ( elementType, resourceName, creationParameters, attachLater, shortcut )
		if ( shortcut == "selworld" or elementType == "removeWorldObject" ) then
			g_SelectWorldBuildingMode_main = true
			g_RemoveWorldBuildingMode_main = ( elementType == "removeWorldObject" )
			cancelEvent ( )
		end
	end
)

-- Catch click and create copy of a world building
function handleWorldBuildingMode(keyState)
	if ( keyState == "down" ) then
		if g_SelectWorldBuildingMode_main then
			if g_worldBuildingInfo then
				if ( g_RemoveWorldBuildingMode_main ) then
					local tempElement = createObject ( g_worldBuildingInfo.id, g_worldBuildingInfo.x, g_worldBuildingInfo.y, g_worldBuildingInfo.z )
					local radius = ( edf.edfGetElementRadius ( tempElement ) or 15 ) + 2
					destroyElement ( tempElement )
					creationParameters = {}
					creationParameters.model = g_worldBuildingInfo.id
					creationParameters.lodModel = g_worldBuildingInfo.LODid
					creationParameters.radius = radius
					creationParameters.position = { g_worldBuildingInfo.x, g_worldBuildingInfo.y, g_worldBuildingInfo.z }
					creationParameters.interior = g_workingInterior
					if creationParameters.interior == 0 then
						creationParameters.interior = -1
					end
					triggerServerEvent ( "doCreateElement", localPlayer, "removeWorldObject", "editor_main", creationParameters, false )
				else
					creationParameters = {}
					creationParameters.model = g_worldBuildingInfo.id
					creationParameters.position = { g_worldBuildingInfo.x, g_worldBuildingInfo.y, g_worldBuildingInfo.z }
					creationParameters.rotation = { g_worldBuildingInfo.rx, g_worldBuildingInfo.ry, g_worldBuildingInfo.rz }
					doCreateElement("object", "editor_main", creationParameters)
				end
			end
			g_SelectWorldBuildingMode_main = false
			g_RemoveWorldBuildingMode_main = false
			return true
		end
	end
	return false
end

-- Catch click and cancel 'Select World Building Mode'
function maybeCancelWorldBuildingMode(keyState)
	if keyState == "down" then
		g_SelectWorldBuildingMode_main = false
		g_RemoveWorldBuildingMode_main = false
	end
end

function disableCharacterSounds()
	-- CJ stealth breathing, fall screaming etc.
	setWorldSoundEnabled ( 25, false )
end
