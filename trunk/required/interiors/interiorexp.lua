local interiors = {}
local interiorMarkers = {}
local interiorCols = {}
local interiorFromCol = {}
local resourceFromInterior = {}
local blockPlayer = {}
--format interior = { [resource] = { [id] = { return= { [element],[element] }, entry=[element] } }
addEvent ( "onPlayerInteriorHit" )
addEvent ( "onPlayerInteriorWarped" )
addEvent ( "onInteriorHit" )
addEvent ( "onInteriorWarped" )

addEventHandler ( "onResourceStart", getRootElement(),
function ( resource )
	interiorLoadElements ( getResourceRootElement(resource), resource )
	interiorCreateMarkers ( resource )
end )

addEventHandler ( "onResourceStop", getRootElement(),
function ( resource )
	if not interiors[resource] then return end
	for id,interiorTable in pairs(interiors[resource]) do
		local interior1 = interiorTable["entry"]
		local interior2 = interiorTable["return"]
		destroyElement ( interiorCols[interior1] )
		destroyElement ( interiorMarkers[interior1] )
		destroyElement ( interiorCols[interior2] )
		destroyElement ( interiorMarkers[interior2] )
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
		local marker = createMarker ( entX, entY, entZ + 2.2, "arrow", 2, 255, 255, 0, 200 )
		setElementParent ( marker, entryInterior )
		interiorMarkers[entryInterior] = marker
		--
		local col = createColSphere ( entX, entY, entZ, 1.5 )
		setElementParent ( col, entryInterior )
		interiorCols[entryInterior] = col
		interiorFromCol[col] = entryInterior
		--
		local dimension = tonumber(getElementData ( entryInterior, "dimension" ))
		local interior = tonumber(getElementData ( entryInterior, "interior" ))
		if not dimension then dimension = 0 end
		if not interior then interior = 0 end
		--
		setElementInterior ( marker, interior )
		setElementInterior ( col, interior )
		setElementDimension ( col, dimension )
		setElementDimension ( marker, dimension )
		---create return markers
		local returnInterior = interiorTypeTable["return"]
		local retX,retY,retZ = getElementData ( returnInterior, "posX" ),getElementData ( returnInterior, "posY" ),getElementData ( returnInterior, "posZ" )
		retX,retY,retZ = tonumber(retX),tonumber(retY),tonumber(retZ)		
		--
		local oneway = getElementData ( entryInterior, "oneway" )
		if oneway == "true" then return end
		local marker1 = createMarker ( retX, retY, retZ + 2.2, "arrow", 2, 255, 255, 0, 200 )
		interiorMarkers[returnInterior] = marker1
		setElementParent ( marker1, returnInterior )
		--
		local col1 = createColSphere ( retX, retY, retZ, 1.5 )
		interiorFromCol[col1] = returnInterior
		interiorCols[returnInterior] = col1
		setElementParent ( col1, returnInterior )
		--
		local dimension1 = tonumber(getElementData ( returnInterior, "dimension" ))
		local interior1 = tonumber(getElementData ( returnInterior, "interior" ))
		if not dimension1 then dimension1 = 0 end
		if not interior1 then interior1 = 0 end
		--
		setElementInterior ( marker1, interior1 )
		setElementInterior ( col1, interior1 )
		setElementDimension ( col1, dimension1 )
		setElementDimension ( marker1, dimension1 )
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
addEventHandler ( "onColShapeHit", getResourceRootElement(getThisResource()), --flawed
function ( player, matchingDimension )
	if getElementType ( player ) ~= "player" then return end
	if ( not matchingDimension ) or ( isPlayerInVehicle ( player ) ) or 
	( doesPlayerHaveJetPack ( player ) ) or ( not isPlayerOnGround ( player ) ) or 
	( getControlState ( player, "aim_weapon" ) ) or ( blockPlayer[player] ) 
	then return end
	local interior = interiorFromCol[source]
	local id = getElementData ( interior, idLoc[getElementType(interior)] ) 
	local resource = resourceFromInterior[interior]
	local eventCanceled1,eventCanceled2 = false,false
	eventCanceled1 = triggerEvent ( "onPlayerInteriorHit", player, interior, resource, id )
	eventCanceled2 = triggerEvent ( "onInteriorHit", interior, player )
	if ( eventCanceled2 ) and ( eventCanceled1 ) then
		warpPlayerToInterior ( player, interior, resource, id )
	end
end )

function warpPlayerToInterior ( player, interior, resource, id )
		local oppositeType = opposite[getElementType(interior)]
		local targetInterior = interiors[resource][id][oppositeType]
		
		local x = getElementData ( targetInterior, "posX" )
		local y = getElementData ( targetInterior, "posY" )
		local z = getElementData ( targetInterior, "posZ" ) + 1
		local dim = getElementData ( targetInterior, "dimension" )
		local int = getElementData ( targetInterior, "interior" )
		local rot = getElementData ( targetInterior, "rotation" )
		toggleAllControls ( player, false )
		fadeCamera ( player, false, 1.0 )
		setTimer ( setPlayerInsideInterior, 1000, 1, player, int,dim,rot,x,y,z, interior )
		blockPlayer[player] = true
		setTimer ( function() blockPlayer[player] = nil end, 3500, 1, player, false )
end

function setPlayerInsideInterior ( player, int,dim,rot,x,y,z, interior )
	setElementInterior ( player, int )
	setElementDimension ( player, dim )
	setPlayerRotation ( player, rot )
	setElementPosition ( player, x, y, z )
	toggleAllControls ( player, true )
	setTimer ( fadeCamera, 500, 1, player, true, 1.0 )
	triggerEvent ( "onInteriorWarped", interior, player )
	triggerEvent ( "onPlayerInteriorWarped", player, interior )
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



