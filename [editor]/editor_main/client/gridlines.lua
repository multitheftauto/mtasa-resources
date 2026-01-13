local MAX_THICKNESS = 1.2
local MAX_THICKNESS_AngleHelper = .8
--local c
local drawLine
--local color = 1694433280
local attachedToElement

--Element types to ignore the element matrix of.  They do not have rotation
local ignoreMatrix = {
	pickup = true
}

function showGridlines ( element )
	attachedToElement = element
	return true
end

local function renderGridlines()
	if not isElement(attachedToElement) then return end
	if getElementDimension(attachedToElement) ~= getElementDimension(localPlayer) then return end

	local x,y,z = edf.edfGetElementPosition(attachedToElement)
	if not x then return end

	local minX,minY,minZ,maxX,maxY,maxZ = edf.edfGetElementBoundingBox ( attachedToElement )
	if not minX then
		local radius = edf.edfGetElementRadius ( attachedToElement )
		if radius then
			minX,minY,minZ,maxX,maxY,maxZ = -radius,-radius,-radius,radius,radius,radius
		end
	end

	if not minX or not minY or not minZ or not maxX or not maxY or not maxZ then return end
	local camX,camY,camZ = getCameraMatrix()
	--Work out our line thickness
	local thickness = (100/getDistanceBetweenPoints3D(camX,camY,camZ,x,y,z)) * MAX_THICKNESS

	--Apply the adjustment for non-centered bounding box according to c++ implementaion
	--https://github.com/multitheftauto/mtasa-blue/blob/88d303c0bbcc0ed4fee958df2d16ace562ce0108/Client/mods/deathmatch/logic/CClientStreamElement.cpp#L224

	local halfCenterX = (minX + maxX) * 0.25
	local halfCenterY = (minY + maxY) * 0.25
	local halfCenterZ = (minZ + maxZ) * 0.25

	--subtracting half center
	minX = minX - halfCenterX
	minY = minY - halfCenterY
	minZ = minZ - halfCenterZ
	maxX = maxX - halfCenterX
	maxY = maxY - halfCenterY
	maxZ = maxZ - halfCenterZ

	--
	local elementMatrix = (getElementMatrix(attachedToElement) and not ignoreMatrix[getElementType(attachedToElement)])
							and matrix(getElementMatrix(attachedToElement))
	if not elementMatrix then
		--Make them into absolute coords
		minX,minY,minZ = minX + x,minY + y,minZ + z
		maxX,maxY,maxZ = maxX + x,maxY + y,maxZ + z
	end
	--
	local face1 = matrix{
			{minX,maxY,minZ,1},
			{minX,maxY,maxZ,1},
			{maxX,maxY,maxZ,1},
			{maxX,maxY,minZ,1},
		}
	local face2 = matrix{
			{minX,minY,minZ,1},
			{minX,minY,maxZ,1},
			{maxX,minY,maxZ,1},
			{maxX,minY,minZ,1},
		}
	if elementMatrix then
		face1 = face1*elementMatrix
		face2 = face2*elementMatrix
	end

	local faces = { face1,face2	}
	local drawLines,furthestNode,furthestDistance = {},{},0
	--Draw rectangular faces
	for k,face in ipairs(faces) do
		for i,coord3d in ipairs(face) do
			if not getScreenFromWorldPosition(coord3d[1],coord3d[2],coord3d[3],10) then return end
			local nextIndex = i + 1
			if not face[nextIndex] then nextIndex = 1 end
			local targetCoord3d  = face[nextIndex]
			table.insert ( drawLines, { coord3d, targetCoord3d } )
			local camDistance = getDistanceBetweenPoints3D(camX,camY,camZ,unpack(coord3d))
			if camDistance > furthestDistance then
				furthestDistance = camDistance
				furthestNode = faces[k][i]
			end
		end
	end
	--Connect these faces together with four lines
	for i=1,4 do
		table.insert ( drawLines, { faces[1][i], faces[2][i] } )
	end
	--
	for i,draw in ipairs(drawLines) do
		if ( not vectorCompare ( draw[1], furthestNode ) ) and ( not vectorCompare ( draw[2], furthestNode ) ) then
			drawLine (draw[1],draw[2],tocolor(200,0,0,180),thickness)
		end
	end
end

function getElementBoundRadius(elem)
	local x0, y0, z0, x1, y1, z1 = edf.edfGetElementBoundingBox(elem)
	return math.max(x0+x1,y0+y1,z0+z1)*1.3
end

function drawXYZLines()
	if not isElement(attachedToElement) then return end
	local camX,camY,camZ = getCameraMatrix()
	if getElementDimension(attachedToElement) ~= getElementDimension(localPlayer) then return end
	local radius = (tonumber(edf.edfGetElementRadius(attachedToElement)) or .3)*1.2
	local x,y,z = getElementPosition(attachedToElement)
	local xx,xy,xz = getPositionFromElementAtOffset(attachedToElement,radius,0,0)
	local yx,yy,yz = getPositionFromElementAtOffset(attachedToElement,0,radius,0)
	local zx,zy,zz = getPositionFromElementAtOffset(attachedToElement,0,0,radius)
	local thickness = (100/getDistanceBetweenPoints3D(camX,camY,camZ,x,y,z)) * MAX_THICKNESS_AngleHelper
	drawLine({x,y,z},{xx,xy,xz},tocolor(200,0,0,200),thickness)
	drawLine({x,y,z},{yx,yy,yz},tocolor(0,200,0,200),thickness)
	drawLine({x,y,z},{zx,zy,zz},tocolor(0,0,200,200),thickness)
end

--[[
	Draws the where the object will be moved to.
]]
function drawObjectMoveLines()
	if not isElement(attachedToElement) then return end
	if getElementType(attachedToElement) ~= "object" then return end
	if getElementDimension(attachedToElement) ~= getElementDimension(localPlayer) then return end
	local x,y,z = edf.edfGetElementPosition(attachedToElement)
	if not x then return end

	local offsetX = edf.edfGetElementProperty(attachedToElement, "moveX")
	local offsetY = edf.edfGetElementProperty(attachedToElement, "moveY")
	local offsetZ = edf.edfGetElementProperty(attachedToElement, "moveZ")

	if offsetX and math.abs(offsetX) > 0 or offsetY and math.abs(offsetY) > 0 or offsetZ and math.abs(offsetZ) > 0 then
		if not offsetX then offsetX = 0 end
		if not offsetY then offsetY = 0 end
		if not offsetZ then offsetZ = 0 end

		local speed = tonumber(edf.edfGetElementProperty(attachedToElement, "moveSpeed"))
		if not speed then speed = 1 end
		local delay = tonumber(edf.edfGetElementProperty(attachedToElement, "moveDelay"))
		if not delay then delay = 0 end
		local time = getDistanceBetweenPoints3D(x,y,z,x + offsetX,y + offsetY,z + offsetZ) / speed * 1000
		local lineStartPos = {x,y,z}
		local lineEndPos = {x + offsetX,y + offsetY,z + offsetZ}
		local timeNow = getTickCount()

		local fullCycle = 2 * time + 2 * delay
		local cyclePos = timeNow % fullCycle
		local progress
		if cyclePos < delay then
			-- Delay at 0
			progress = 0
		elseif cyclePos < delay + time then
			-- Forward: 0 to 1 over 'time' milliseconds
			progress = (cyclePos - delay) / time
		elseif cyclePos < delay + time + delay then
			-- Delay at 1
			progress = 1
		else
			-- Backward: 1 to 0 over 'time' milliseconds
			progress = 1 - (cyclePos - delay - time - delay) / time
		end

		local movementAnimationOffset = {
			(lineEndPos[1] - lineStartPos[1]) * progress,
			(lineEndPos[2] - lineStartPos[2]) * progress,
			(lineEndPos[3] - lineStartPos[3]) * progress
		}


		local minX,minY,minZ,maxX,maxY,maxZ = edf.edfGetElementBoundingBox ( attachedToElement )
		if not minX then
			local radius = edf.edfGetElementRadius ( attachedToElement )
			if radius then
				minX,minY,minZ,maxX,maxY,maxZ = -radius,-radius,-radius,radius,radius,radius
			end
		end

		if minX and minY and minZ and maxX and maxY and maxZ then
			local halfCenterX = (minX + maxX) * 0.25
			local halfCenterY = (minY + maxY) * 0.25
			local halfCenterZ = (minZ + maxZ) * 0.25

			--subtracting half center
			minX = minX - halfCenterX
			minY = minY - halfCenterY
			minZ = minZ - halfCenterZ
			maxX = maxX - halfCenterX
			maxY = maxY - halfCenterY
			maxZ = maxZ - halfCenterZ

			-- Define the 8 corners in relative coordinates
			local relativeCorners = {
				{minX, minY, minZ}, -- 1: min corner
				{maxX, minY, minZ}, -- 2
				{maxX, maxY, minZ}, -- 3
				{minX, maxY, minZ}, -- 4
				{minX, minY, maxZ}, -- 5
				{maxX, minY, maxZ}, -- 6
				{maxX, maxY, maxZ}, -- 7
				{minX, maxY, maxZ}  -- 8: max corner
			}

			-- Draw the bounding box moving to the destination position
			do
				local corners = {}
				for i, relCorner in ipairs(relativeCorners) do
					local worldX, worldY, worldZ = getPositionFromElementAtOffset(attachedToElement, relCorner[1], relCorner[2], relCorner[3])
					corners[i] = {worldX + movementAnimationOffset[1], worldY + movementAnimationOffset[2], worldZ + movementAnimationOffset[3]}
				end
				
				local boxColor = tocolor(255, 255, 255, 100)
				local lineWidth = 2
				
				-- Bottom face (z = minZ)
				dxDrawLine3D(corners[1][1], corners[1][2], corners[1][3], corners[2][1], corners[2][2], corners[2][3], boxColor, lineWidth)
				dxDrawLine3D(corners[2][1], corners[2][2], corners[2][3], corners[3][1], corners[3][2], corners[3][3], boxColor, lineWidth)
				dxDrawLine3D(corners[3][1], corners[3][2], corners[3][3], corners[4][1], corners[4][2], corners[4][3], boxColor, lineWidth)
				dxDrawLine3D(corners[4][1], corners[4][2], corners[4][3], corners[1][1], corners[1][2], corners[1][3], boxColor, lineWidth)
				
				-- Top face (z = maxZ)
				dxDrawLine3D(corners[5][1], corners[5][2], corners[5][3], corners[6][1], corners[6][2], corners[6][3], boxColor, lineWidth)
				dxDrawLine3D(corners[6][1], corners[6][2], corners[6][3], corners[7][1], corners[7][2], corners[7][3], boxColor, lineWidth)
				dxDrawLine3D(corners[7][1], corners[7][2], corners[7][3], corners[8][1], corners[8][2], corners[8][3], boxColor, lineWidth)
				dxDrawLine3D(corners[8][1], corners[8][2], corners[8][3], corners[5][1], corners[5][2], corners[5][3], boxColor, lineWidth)
				
				-- Vertical edges connecting bottom to top
				dxDrawLine3D(corners[1][1], corners[1][2], corners[1][3], corners[5][1], corners[5][2], corners[5][3], boxColor, lineWidth)
				dxDrawLine3D(corners[2][1], corners[2][2], corners[2][3], corners[6][1], corners[6][2], corners[6][3], boxColor, lineWidth)
				dxDrawLine3D(corners[3][1], corners[3][2], corners[3][3], corners[7][1], corners[7][2], corners[7][3], boxColor, lineWidth)
				dxDrawLine3D(corners[4][1], corners[4][2], corners[4][3], corners[8][1], corners[8][2], corners[8][3], boxColor, lineWidth)
			end
			
			-- Draw the bounding box at the destination position
			do
				local corners = {}
				for i, relCorner in ipairs(relativeCorners) do
					local worldX, worldY, worldZ = getPositionFromElementAtOffset(attachedToElement, relCorner[1], relCorner[2], relCorner[3])
					corners[i] = {worldX + offsetX, worldY + offsetY, worldZ + offsetZ}
				end
				
				local boxColor = tocolor(255, 255, 0, 200)
				local lineWidth = 2
				
				-- Bottom face (z = minZ)
				dxDrawLine3D(corners[1][1], corners[1][2], corners[1][3], corners[2][1], corners[2][2], corners[2][3], boxColor, lineWidth)
				dxDrawLine3D(corners[2][1], corners[2][2], corners[2][3], corners[3][1], corners[3][2], corners[3][3], boxColor, lineWidth)
				dxDrawLine3D(corners[3][1], corners[3][2], corners[3][3], corners[4][1], corners[4][2], corners[4][3], boxColor, lineWidth)
				dxDrawLine3D(corners[4][1], corners[4][2], corners[4][3], corners[1][1], corners[1][2], corners[1][3], boxColor, lineWidth)
				
				-- Top face (z = maxZ)
				dxDrawLine3D(corners[5][1], corners[5][2], corners[5][3], corners[6][1], corners[6][2], corners[6][3], boxColor, lineWidth)
				dxDrawLine3D(corners[6][1], corners[6][2], corners[6][3], corners[7][1], corners[7][2], corners[7][3], boxColor, lineWidth)
				dxDrawLine3D(corners[7][1], corners[7][2], corners[7][3], corners[8][1], corners[8][2], corners[8][3], boxColor, lineWidth)
				dxDrawLine3D(corners[8][1], corners[8][2], corners[8][3], corners[5][1], corners[5][2], corners[5][3], boxColor, lineWidth)
				
				-- Vertical edges connecting bottom to top
				dxDrawLine3D(corners[1][1], corners[1][2], corners[1][3], corners[5][1], corners[5][2], corners[5][3], boxColor, lineWidth)
				dxDrawLine3D(corners[2][1], corners[2][2], corners[2][3], corners[6][1], corners[6][2], corners[6][3], boxColor, lineWidth)
				dxDrawLine3D(corners[3][1], corners[3][2], corners[3][3], corners[7][1], corners[7][2], corners[7][3], boxColor, lineWidth)
				dxDrawLine3D(corners[4][1], corners[4][2], corners[4][3], corners[8][1], corners[8][2], corners[8][3], boxColor, lineWidth)
			end
		end
	end
end

function doBasicElementRenders()
	if not isElement(attachedToElement) then return end
	if exports["editor_gui"]:sx_getOptionData("enableBox") then renderGridlines() end
	if exports["editor_gui"]:sx_getOptionData("enableXYZlines") then drawXYZLines() end
	drawObjectMoveLines()
end
addEventHandler ( "onClientRender", root, doBasicElementRenders )

function getPositionFromElementAtOffset(element,x,y,z)
   if not x or not y or not z then
      return false
   end
		local ox,oy,oz = getElementPosition(element)
        local matrix = getElementMatrix ( element )
		if not matrix then return ox+x,oy+y,oz+z end
        local offX = x * matrix[1][1] + y * matrix[2][1] + z * matrix[3][1] + matrix[4][1]
        local offY = x * matrix[1][2] + y * matrix[2][2] + z * matrix[3][2] + matrix[4][2]
        local offZ = x * matrix[1][3] + y * matrix[2][3] + z * matrix[3][3] + matrix[4][3]
        return offX, offY, offZ
end

function drawLine(vecOrigin, vecTarget,color,thickness)
	local startX,startY = getScreenFromWorldPosition(vecOrigin[1],vecOrigin[2],vecOrigin[3],10)
	if (not vecTarget[1]) then return false end
	local endX,endY = getScreenFromWorldPosition(vecTarget[1],vecTarget[2],vecTarget[3],10)
	if not startX or not startY or not endX or not endY then
		return false
	end

	return dxDrawLine ( startX,startY,endX,endY,color,thickness, false)
end

function vectorCompare ( vec1,vec2 )
	if vec1[1] == vec2[1] and vec1[2] == vec2[2] and vec1[3] == vec2[3] then return true end
end

function getOffsetRelativeToElement ( element, x, y, z )
	local elementMatrix = matrix{getElementMatrix(element)}
	elementMatrix = matrix{x,y,z} * elementMatrix
	return elementMatrix
end
