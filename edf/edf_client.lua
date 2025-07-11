addEvent ( "hideDummy", true )
addEvent ( "onClientElementPropertyChanged" )
local thisResource = getThisResource()

-- basic types list
local basicTypes = {
	"object","vehicle","pickup","marker","blip","colshape","radararea","ped","water",
}

-- basic types lookup table
local isBasic = {}
for k, theType in ipairs(basicTypes) do
	isBasic[theType] = true
end

local radiusFuncs = {
	object = getElementRadius,
	marker = getMarkerSize,
	ped = getElementRadius,
	vehicle = getElementRadius,
	pickup = function() return 0.5 end
}

local function getRadius ( element )
	local theType = getElementType ( element )
	if ( radiusFuncs[theType] ) then
		return radiusFuncs[theType](element)
	end
	return false
end


--Hide the dummy object
addEventHandler("onClientResourceStart",resourceRoot,
	function()
		for key,object in ipairs(getElementsByType"object") do
			if getElementData ( object, "edf:dummy" ) then
				setObjectScale ( object, 0 )
			end
		end
	end
)

addEventHandler ( "hideDummy",root,
	function()
		setObjectScale ( source, 0 )
	end
)

function edfGetHandle( edfElement )
	return getElementData( edfElement, "edf:handle") or false
end

function edfGetParent( repPart )
	if getElementData(repPart, "edf:rep") then
		return getElementParent(repPart)
	else
		return repPart
	end
end

function edfGetAncestor( repPart )
	if getElementData(repPart, "edf:rep") then
		return edfGetAncestor( getElementParent(repPart) )
	else
		return repPart
	end
end

function edfGetCreatorResource( edfElement )
	local resourceName = getElementData( edfElement, "edf:creatorResource" )
	if resourceName then
		return getResourceFromName( resourceName )
	else
		return thisResource
	end
end

--Returns an element's position, or its posX/Y/Z element data, or 0,0,0
function edfGetElementPosition(element)
	local px, py, pz
	if isBasic[getElementType(element)] then
		px, py, pz = getElementPosition(element)
	else
		local handle = edfGetHandle(element)
		if handle then
			return getElementPosition(handle)
		else
			px = tonumber(getElementData(element,"posX"))
			py = tonumber(getElementData(element,"posY"))
			pz = tonumber(getElementData(element,"posZ"))
		end
	end

	if px and py and pz then
		return px, py, pz
	else
		return false
	end
end

--Returns an element's rotation, or its rotX/Y/Z element data, or 0,0,0
function edfGetElementRotation(element)
	local etype = getElementType(element)
	local rx, ry, rz
	if etype == "object" or etype == "vehicle" or etype == "player" or etype == "ped" then
		rx, ry, rz = getElementRotation(element)
	else
		local handle = edfGetHandle(element)
		if handle then
			return getElementRotation(handle)
		else
			rx = tonumber(getElementData(element,"rotX"))
			ry = tonumber(getElementData(element,"rotY"))
			rz = tonumber(getElementData(element,"rotZ"))
		end
	end

	if rx and ry and rz then
		return rx, ry, rz
	else
		return false
	end
end

--Returns an element's scale, or its scale element data, or 1
function edfGetElementScale(element)
	local scale
	if isBasic[getElementType(element)] then
		scale = getElementData(element, "scale")
	else
		local handle = edfGetHandle(element)
		if handle then
			return getElementData(handle, "scale")
		else
			scale = getElementData(element, "scale")
		end
	end

	if scale then
		return scale
	else
		return 1
	end
end

--Setsan element's position, or its posX/Y/Z element data
function edfSetElementPosition(element, px, py, pz)
	if px and py and pz then
		if isBasic[getElementType(element)] then
			return setElementPosition(element, px, py, pz)
		else
			local handle = edfGetHandle(element)
			if handle then
				return setElementPosition(handle, px, py, pz)
			else
				setElementData(element, "posX", px or 0)
				setElementData(element, "posY", py or 0)
				setElementData(element, "posZ", pz or 0)
				return true
			end
		end
	end
end

--Sets an element's rotation, or its rotX/Y/Z element data
function edfSetElementRotation(element, rx, ry, rz)
	if rx and ry and rz then
		local etype = getElementType(element)
		if etype == "object" or etype == "vehicle" or etype == "player" or etype == "ped" then
			-- Clear the quat rotation when set manually
			exports.editor_main:clearElementQuat(element)
			
			return setElementRotation(element, rx, ry, rz)
		else
			local handle = edfGetHandle(element)
			if handle then
				return setElementRotation(handle, rx, ry, rz)
			else
				setElementData(element, "rotX", rx or 0)
				setElementData(element, "rotY", ry or 0)
				setElementData(element, "rotZ", rz or 0)
				return true
			end
		end
	end
end

--Sets an element's scale, or its scale element data
function edfSetElementScale(element, scale)
	if scale then
		if isBasic[getElementType(element)] then
			return setElementData(element, "scale", scale)
		else
			local handle = edfGetHandle(element)
			if handle then
				return setElementData(handle, "scale", scale)
			else
				setElementData(element, "scale", scale)
				return true
			end
		end
	end
end

function edfGetElementInterior(element)
	return getElementInterior(element) or tonumber(getElementData(element, "interior")) or 0
end

function edfSetElementInterior(element, interior)
	if interior then
		if isBasic[getElementType(element)] then
			return setElementInterior(element, interior)
		else
			local handle = edfGetHandle(element)
			if handle then
				return setElementInterior(handle, interior)
			else
				setElementData(element, "interior", interior or 0)
			end
		end
	end
end

function edfGetElementDimension(element)
	if isBasic[getElementType(element)] then
		return getElementDimension(element)
	else
		local handle = edfGetHandle(element)
		if handle then
			return getElementDimension(handle)
		else
			return getElementData(element, "edf:dimension")
		end
	end
end

function edfGetElementAlpha(element)
	if isBasic[getElementType(element)] then
		return getElementAlpha(element)
	else
		local handle = edfGetHandle(element)
		if handle then
			return getElementAlpha(handle)
		else
			return getElementData(element, "alpha")
		end
	end
end

function edfSetElementDimension(element, dimension)
        if dimension then
                if isBasic[getElementType(element)] then
                        return setElementDimension(element, dimension)
                else
                        local handle = edfGetHandle(element)
                        if handle then
                                return setElementDimension(handle, dimension)
                        else
                                setElementData(element, "edf:dimension", dimension or 0)
                        end
                end
        end
end

function edfSetElementAlpha(element, alpha)
        if alpha then
                if isBasic[getElementType(element)] then
                        return setElementAlpha(element, alpha)
                else
                        local handle = edfGetHandle(element)
                        if handle then
                                return setElementAlpha(handle, alpha)
                        else
                                setElementData(element, "alpha", alpha or 255)
                        end
                end
        end
end

function edfSetElementProperty(element, property, value)
	--Set the value for any representations
	edfSetElementPropertyForRepresentations(element,property,value)

	local elementType = getElementType(element)
	-- if our property is an entity attribute we have access to, set it
	if propertySetters[elementType] and propertySetters[elementType][property] then
		local wasSet = propertySetters[elementType][property](element, value)
		-- don't do anything else if this failed
		if not wasSet then
			return false
		end
	end
	setElementData(element, property, value)
	triggerEvent ( "onClientElementPropertyChanged", element, property )
	return true
end

function edfSetElementPropertyForRepresentations(element,property,value)
	--Check if the property is inherited to reps
	for k,child in ipairs(getElementChildren(element)) do
		if edfGetAncestor(child) == element then --Check that the child is a representation of the element
			local inherited = getElementData(child,"edf:inherited")
			if inherited then
				--Check that the property is inherited to this child
				if inherited[property] then
					local elementType = getElementType(child)
					local dataField = inherited[property]
					if propertySetters[elementType] and propertySetters[elementType][dataField] then
						propertySetters[elementType][dataField](child, value)
					else --If this representation inherits data from another element
						edfSetElementPropertyForRepresentations(child,dataField,value)
					end
				end
			end
		end
	end
end

function edfGetElementProperty(element, property)
	local elementType = getElementType(element)
	-- if our property is an entity attribute we have access to, get it
	if propertyGetters[elementType] and propertyGetters[elementType][property] then
		return propertyGetters[elementType][property](element)
	else
		return getElementData(element, property)
	end
end

--This function returns an estimated radius, my calculating the peak and base of an edf element.  "wide" elements are not accounted for due to glue positioning.
function edfGetElementRadius(element,forced)
	--If its a basic, non-representative element
	if isBasic[getElementType(element)] and ( forced or edfGetParent(element) == element ) then
		return getRadius(element)
	else
		local handleRadius = 0
		if isBasic[getElementType(edfGetHandle(element))] then
			handleRadius = getRadius(edfGetHandle(element))
		end

		local maxZ,minZ,maxXY = -math.huge,math.huge,0
		local handle = edfGetHandle(element)
		--get the centre point to calculate our radius
		local centreX,centreY,centreZ = getElementPosition(handle)
		--do a loop of all representation elements
		for i,representation in ipairs(getElementChildren(edfGetParent(element))) do
			local x,y,z = getElementPosition(representation)
			local radius = edfGetElementRadius(representation,true) or 0
			local xyDistance = getDistanceBetweenPoints2D(x,y,centreX,centreY)
			--maxXY = math.max (maxXY,xyDistance+radius)
			maxZ = math.max  (maxZ,z+radius)
			minZ = math.min  (minZ,z-radius)
		end
		--make them relative measurements rather than absolute coordinates
		maxZ = maxZ - centreZ
		minZ = centreZ - minZ
		--Return the largest radius, whether that is the lower bound or upper bound
		return math.max ( maxZ, minZ, handleRadius )
	end
end

--This function grabs the element with the biggest radius, and uses that bounding box
function edfGetElementBoundingBox ( element )
	local biggestElement,biggestRadius
	if isBasic[getElementType(element)] and ( edfGetParent(element) == element ) then
		return getElementBoundingBox(element)
	else
		local handle = edfGetHandle(element)
		--do a loop of all representation elements
		for i,representation in ipairs(getElementChildren(edfGetParent(element))) do
			biggestElement = biggestElement or representation
			local radius = getRadius(representation,true) or 0
			biggestRadius = biggestRadius or radius
			--maxXY = math.max (maxXY,xyDistance+radius)
			if radius > biggestRadius then
				biggestRadius = radius
				biggestElement = representation
			end
		end
	end
	local a,b,c,d,e,f = getElementBoundingBox(biggestElement)
	if a then
		return a,b,c,d,e,f
	else
		return -biggestRadius,-biggestRadius,-biggestRadius,biggestRadius,biggestRadius,biggestRadius
	end
end

--This function returns an estimated radius, my calculating the peak and base of an edf element.  "wide" elements are not accounted for due to glue positioning.
function edfGetElementDistanceToBase(element,forced)
	--If its a basic, non-representative element
	if isBasic[getElementType(element)] and ( forced or edfGetParent(element) == element ) then
		return getElementDistanceFromCentreOfMassToBaseOfModel(element)
	else
		local maxDistance = 0
		--do a loop of all representation elements
		for i,representation in ipairs(getElementChildren(edfGetParent(element))) do
			maxDistance = math.max  (maxDistance,edfGetElementDistanceToBase(representation,true) or 0)
		end
		return maxDistance
	end
end


