objects = {}
functions = {}


functions.removePedFromVehicleS = function ()
	removePedFromVehicle(client)
end

functions['ObjectS'] = function (selectedElements,id,replaceE,x,y,z)
	if replaceE then
		for i,v in pairs(selectedElements) do
			exports.ObjS:JsetElementModel(i,id)
		end
	else
		local obj = exports.ObjS:JcreateObject(id,x,y,z)
		table.insert(objects,obj)
		callC(client,'Select',obj)
	end
end

functions['freezeElement'] = function (element,boolen)
	setElementFrozen(element,boolen)
end

functions['setElementPositions'] = function (selectedElements,x,y,z,useElementData,mType,caX,caY,caZ)
	for i,v in pairs(selectedElements) do
		if useElementData then
			setElementPosition ( i, getElementData(i,'x'),getElementData(i,'y'),getElementData(i,'z'))
		else
			local xA,yA,zA = getElementPosition(i)
			if (mType == 'World' or not mType) then
				setElementPosition ( i, x+xA,y+yA,z+zA )
			elseif mType == 'Local' then
				local newPosition = i.matrix:transformPosition(Vector3(x,y,z))
				i.position = i.matrix:transformPosition(Vector3(x,y,z))
			elseif mType == 'Screen' then
				local cX,cY,cZ = getCameraMatrix(client)
				local fX,fY,fZ = cX-caX,cY-caY,cZ-caZ
				setElementPosition(i,xA-fX,yA-fY,zA+fZ)
			end
		end
	end
end

functions['setElementScales'] = function (selectedElements)
	for i,v in pairs(selectedElements) do
		if getElementType(i) == 'object' then
			setObjectScale(i,getElementData(i,'sX'),getElementData(i,'sY'),getElementData(i,'sZ')) -- WILL BE EXPANDED LATER
		end
	end
end


functions['setElementRotations'] = function (selectedElements,x,y,z,useElementData,mType,cx,cy,xz) --// Identical to setElementPositions, however uses matrix for the camera stuff.

	for i,v in pairs(selectedElements) do
		if useElementData then
			setElementRotation (i,getElementData(i,'xr'),getElementData(i,'yr'),getElementData(i,'zr'))
			setElementPosition (i,getElementData(i,'x'),getElementData(i,'y'),getElementData(i,'z'))
		else
			local xA,yA,zA = getElementRotation(i)
			if (mType == 'World' or not mType) then
				globalRotation(i,x,y,z,cx,cy,xz)
			elseif mType == 'Local' then
				ApplyElementRotation(i, x,y,z)
			end
		end
	end
end



--- Helpers
function callC(player,...)
	triggerClientEvent ( player,"functionC", player, ... )
end

function triggerFunction(name,...)
	if functions[name] then
		functions[name](...)
	end
end

addEvent( "functionS", true )
addEventHandler( "functionS", resourceRoot, triggerFunction )

function globalRotation(element,xr,yr,zr,x,y,z) --// Function orignally by MyOnLake
	local vec = Vector3(x,y,z)
	local vec2 = Vector3(xr,yr,zr)

	local matrix = Matrix(vec, vec2)
	local matrix2 = Matrix(matrix:transformPosition(element.position-vec), matrix:getRotation()+element.matrix:getRotation())

	element:setPosition(matrix2:getPosition())

	ApplyElementRotation(element, xr,yr,zr, true)
end


addEventHandler( "onResourceStop", resourceRoot,
function ( )
	for i,v in pairs(objects) do
		destroyElement(v)
	end
end
)