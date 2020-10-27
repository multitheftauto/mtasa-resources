local interiorAnims = {}
local setInteriorMarkerZ = {
	interiorEntry = function(marker,z)
		local interiorElement = getElementParent(marker)
		local vx = getElementData ( interiorElement,"posX" )
		local vy = getElementData ( interiorElement,"posY" )
		local vz = getElementData ( interiorElement,"posZ" )
		--
	 	setElementPosition(marker, vx, vy, vz + z/2 + 2.4)
	end,
	interiorReturn = function(marker,z)
		local interiorElement = getElementParent(marker)
		local vx = getElementData ( interiorElement,"posX" )
		local vy = getElementData ( interiorElement,"posY" )
		local vz = getElementData ( interiorElement,"posZ" )
		--
	 	setElementPosition(marker, vx, vy, vz + z/2 + 2.4)
	end
}

-- addEventHandler("onClientElementStreamIn",getRootElement(),
	-- function()
		-- if getElementType ( source ) == "marker" then
			-- local parent = getElementParent ( source )
			-- local parentType = getElementType(parent)
			-- if parentType == "interiorEntry" or parentType == "interiorReturn" then
				-- interiorAnims[source] = Animation.createAndPlay(
		-- source,
 		-- { from = 0, to = 2*math.pi, time = 2000, repeats = 0, transform = math.sin, fn = setInteriorMarkerZ[parentType] }
-- )
			-- end
		-- end
	-- end
-- )

-- addEventHandler("onClientElementStreamOut",getRootElement(),
	-- function()
		-- if getElementType ( source ) == "marker" then
			-- local parent = getElementParent ( source )
			-- local parentType = getElementType(parent)
			-- if parentType == "interiorEntry" or parentType == "interiorReturn" then
				-- if (interiorAnims[source] ) then
					-- interiorAnims[source]:remove()
				-- end
			-- end
		-- end
	-- end
-- )

----Main
local interiors = {}
local interiorCols = {}
local interiorFromCol = {}
local resourceFromInterior = {}
local blockPlayer
addEvent ( "doWarpPlayerToInterior", true )
addEvent ( "onClientInteriorHit" )
addEvent ( "onClientInteriorWarped" )

addEventHandler ( "onClientResourceStart", getRootElement(),
function ( resource )
	interiorLoadElements ( getResourceRootElement(resource), resource )
	interiorCreateMarkers ( resource )
end )

addEventHandler ( "onClientResourceStop", getRootElement(),
function ( resource )
	if not interiors[resource] then return end
	for id,interiorTable in pairs(interiors[resource]) do
		local interior1 = interiorTable["entry"]
		local interior2 = interiorTable["return"]
		destroyElement ( interiorCols[interior1] )
		destroyElement ( interiorCols[interior2] )
	end
	interiors[resource] = nil
end )

function interiorLoadElements ( rootElement, resource )
	---Load the exterior markers
	local entryInteriors = getElementsByType ( "interiorEntry", rootElement )
	for key, interior in pairs (entryInteriors) do
		local id = getElementData ( interior, "id" )
		if not interiors[resource] then interiors[resource] = {} end
		if not id then outputDebugString ( "Interiors: Error, no ID specified on entryInterior.  Trying to load anyway.", 2 )
		end
		interiors[resource][id] = {}
		interiors[resource][id]["entry"] = interior
		resourceFromInterior[interior] = resource
	end
	--Load the interior markers
	local returnInteriors = getElementsByType ( "interiorReturn", rootElement )
	for key, interior in pairs (returnInteriors) do
		local id = getElementData ( interior, "refid" )
		if not interiors[resource][id] then outputDebugString ( "Interiors: Error, no refid specified to returnInterior.", 1 )
			return
		else
			interiors[resource][id]["return"] = interior
			resourceFromInterior[interior] = resource
		end
	end
end

function interiorCreateMarkers ( resource )
	if not interiors[resource] then return end
	for interiorID, interiorTypeTable in pairs(interiors[resource]) do
		local entryInterior = interiorTypeTable["entry"]
		local entX,entY,entZ = getElementData ( entryInterior, "posX" ),getElementData ( entryInterior, "posY" ),getElementData ( entryInterior, "posZ" )
		entX,entY,entZ = tonumber(entX),tonumber(entY),tonumber(entZ)
		--
		local col = createColSphere ( entX, entY, entZ, 1.5 )
		setElementParent ( col, entryInterior )
		interiorCols[entryInterior] = col
		interiorFromCol[col] = entryInterior
		addEventHandler ( "onClientColShapeHit", col, colshapeHit )
		--
		local dimension = tonumber(getElementData ( entryInterior, "dimension" ))
		local interior = tonumber(getElementData ( entryInterior, "interior" ))
		if not dimension then dimension = 0 end
		if not interior then interior = 0 end
		--
		setElementInterior ( col, interior )
		setElementDimension ( col, dimension )
		---create return markers
		local returnInterior = interiorTypeTable["return"]
		local retX,retY,retZ = getElementData ( returnInterior, "posX" ),getElementData ( returnInterior, "posY" ),getElementData ( returnInterior, "posZ" )
		retX,retY,retZ = tonumber(retX),tonumber(retY),tonumber(retZ)
		--
		local oneway = getElementData ( entryInterior, "oneway" )
		if oneway == "true" then return end
		--
		local col1 = createColSphere ( retX, retY, retZ, 1.5 )
		interiorFromCol[col1] = returnInterior
		interiorCols[returnInterior] = col1
		setElementParent ( col1, returnInterior )
		addEventHandler ( "onClientColShapeHit", col1, colshapeHit )
		--
		local dimension1 = tonumber(getElementData ( returnInterior, "dimension" ))
		local interior1 = tonumber(getElementData ( returnInterior, "interior" ))
		if not dimension1 then dimension1 = 0 end
		if not interior1 then interior1 = 0 end
		--
		setElementInterior ( col1, interior1 )
		setElementDimension ( col1, dimension1 )
	end
end

function getInteriorMarker ( elementInterior )
	if not isElement ( elementInterior ) then outputDebugString("getInteriorName: Invalid variable specified as interior.  Element expected, got "..type(elementInterior)..".",0,255,128,0) return false end
	local elemType = getElementType ( elementInterior )
	if elemType == "interiorEntry" or elemType == "interiorReturn" then
		return interiorMarkers[elementInterior] or false
	end
	outputDebugString("getInteriorName: Bad element specified.  Interior expected, got "..elemType..".",0,255,128,0)
	return false
end

local opposite = { ["interiorReturn"] = "entry",["interiorEntry"] = "return" }
local idLoc = { ["interiorReturn"] = "refid",["interiorEntry"] = "id" }
function colshapeHit( player, matchingDimension )
	if not isElement ( player ) or getElementType ( player ) ~= "player" then return end
	if player ~= localPlayer then return end
	if ( not matchingDimension ) or ( getPedOccupiedVehicle ( player ) ) or
	( doesPedHaveJetPack ( player ) ) or ( not isPedOnGround ( player ) ) or
	( getPedControlState ( player, "aim_weapon" ) ) or ( blockPlayer ) or
	( isPedDoingTask ( player, "TASK_COMPLEX_ENTER_CAR_AS_DRIVER") ) or
	( isPedDoingTask ( player, "TASK_COMPLEX_ENTER_CAR_AS_PASSENGER") )
	then return end
	local interior = interiorFromCol[source]
	local id = getElementData ( interior, idLoc[getElementType(interior)] )
	local resource = resourceFromInterior[interior]
	eventCanceled = triggerEvent ( "onClientInteriorHit", interior )
	if ( eventCanceled ) then
		triggerServerEvent ( "doTriggerServerEvents", localPlayer, interior, getResourceName(resource), id )
	end
end

addEventHandler ( "doWarpPlayerToInterior",localPlayer,
	function ( interior, resource, id )
		resource = getResourceFromName(resource)
		local oppositeType = opposite[getElementType(interior)]
		local targetInterior = interiors[resource][id][oppositeType]

		local x = getElementData ( targetInterior, "posX" )
		local y = getElementData ( targetInterior, "posY" )
		local z = getElementData ( targetInterior, "posZ" ) + 1
		local dim = getElementData ( targetInterior, "dimension" )
		local int = getElementData ( targetInterior, "interior" )
		local rot = getElementData ( targetInterior, "rotation" )
		toggleAllControls ( false, true, false )
		fadeCamera ( false, 1.0 )
		setTimer ( setPlayerInsideInterior, 1000, 1, source, int,dim,rot,x,y,z, interior )
		blockPlayer = true
		setTimer ( function() blockPlayer = nil end, 3500, 1 )
	end
)

function setPlayerInsideInterior ( player, int,dim,rot,x,y,z, interior )
	setElementInterior ( player, int )
	setCameraInterior ( int )
	setElementDimension ( player, dim )
	setPedRotation ( player, rot%360 )
	setTimer ( function(p) if isElement(p) then setCameraTarget(p) end end, 200,1, player )
	setElementPosition ( player, x, y, z )
	toggleAllControls ( true, true, false )
	setTimer ( fadeCamera, 500, 1, true, 1.0 )
	triggerEvent ( "onClientInteriorWarped", interior )
	triggerServerEvent ( "onInteriorWarped", interior, player )
	triggerServerEvent ( "onPlayerInteriorWarped", player, interior )
end

function getInteriorName ( interior )
	if not isElement ( interior ) then outputDebugString("getInteriorName: Invalid variable specified as interior.  Element expected, got "..type(interior)..".",0,255,128,0) return false end
	local elemType = getElementType ( interior )
	if elemType == "interiorEntry" then
		return getElementData ( interior, "id" )
	elseif elemType == "interiorReturn" then
		return getElementData ( interior, "refid" )
	else
		outputDebugString("getInteriorName: Bad element specified.  Interior expected, got "..elemType..".",0,255,128,0)
		return false
	end
end


