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

function doBasicElementRenders()
	if not isElement(attachedToElement) then return end
	if exports["editor_gui"]:sx_getOptionData("enableBox") then renderGridlines() end
	if exports["editor_gui"]:sx_getOptionData("enableXYZlines") then drawXYZLines() end

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
