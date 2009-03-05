local localPlayer  = getLocalPlayer()
local MAX_THICKNESS = 1.2
local thickness
local drawLine
local color = 1694433280
local attachedToElement

function showGridlines ( element )
	attachedToElement = element
	return true
end

local function renderGridlines()
	if not isElement(attachedToElement) then return end
	if getElementDimension(attachedToElement) ~= getElementDimension(localPlayer) then return end
	
	local x,y,z = edf.edfGetElementPosition(attachedToElement)
	if not x then return end

	local radius = edf.edfGetElementRadius ( attachedToElement )
	
	if not radius then return end
	local camX,camY,camZ = getCameraMatrix()
	--Work out our line thickness
	thickness = (100/getDistanceBetweenPoints3D(camX,camY,camZ,x,y,z)) * MAX_THICKNESS
	--
	--local minX,minY,minZ,maxX,maxY,maxZ = getElementBoundingBox ( attachedToElement )
	--Make them into relative offsets first
	-- minX,minY,minZ = getOffsetRelativeToElement(attachedToElement,minX,minY,minZ)
	-- maxX,maxY,maxZ = getOffsetRelativeToElement(attachedToElement,maxX,maxY,maxZ)
	minX,minY,minZ,maxX,maxY,maxZ = -radius,-radius,-radius,radius,radius,radius
	--Make them into absolute coords
	minX,minY,minZ = minX + x,minY + y,minZ + z
	maxX,maxY,maxZ = maxX + x,maxY + y,maxZ + z
	--
	local faces = { 
		{ {minX,maxY,minZ}, {minX,maxY,maxZ}, {maxX,maxY,maxZ}, {maxX,maxY,minZ}  },
		{ {minX,minY,minZ}, {minX,minY,maxZ}, {maxX,minY,maxZ}, {maxX,minY,minZ}  },
	}
	local drawLines,furthestNode,furthestDistance = {},{},0
	--Draw rectangular faces
	for k,face in ipairs(faces) do
		for i,coord3d in ipairs(face) do
			if not getScreenFromWorldPosition(unpack(coord3d)) then return end
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
			drawLine ( unpack(draw) )
		end
	end
end
addEventHandler ( "onClientRender", getRootElement(), renderGridlines )

function drawLine ( vecOrigin, vecTarget )
	local startX,startY = getScreenFromWorldPosition(unpack(vecOrigin))
	local endX,endY = getScreenFromWorldPosition(unpack(vecTarget))
	if not startX or not startY or not endX or not endY then 
		return false
	end
	
	return dxDrawLine ( startX,startY,endX,endY,color,thickness, false)
end

function vectorCompare ( vec1,vec2 )
	if vec1[1] == vec2[1] and vec1[2] == vec2[2] and vec1[3] == vec2[3] then return true end
end
