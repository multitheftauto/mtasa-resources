local interiors = {}
local interiorMarkers = {}
local resourceFromInterior = {}
--format interior = { [resource] = { [id] = { return= { [element],[element] }, entry=[element] } }

addEvent ( "doTriggerServerEvents", true )
addEvent ( "onPlayerInteriorHit" )
addEvent ( "onPlayerInteriorWarped", true )
addEvent ( "onInteriorHit" )
addEvent ( "onInteriorWarped", true )

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
		destroyElement ( interiorMarkers[interior1] )
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
		local dimension = tonumber(getElementData ( entryInterior, "dimension" ))
		local interior = tonumber(getElementData ( entryInterior, "interior" ))
		if not dimension then dimension = 0 end
		if not interior then interior = 0 end
		--
		setElementInterior ( marker, interior )
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
		local dimension1 = tonumber(getElementData ( returnInterior, "dimension" ))
		local interior1 = tonumber(getElementData ( returnInterior, "interior" ))
		if not dimension1 then dimension1 = 0 end
		if not interior1 then interior1 = 0 end
		--
		setElementInterior ( marker1, interior1 )
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
addEventHandler ( "doTriggerServerEvents",getRootElement(),
	function( interior, resource, id )
		local eventCanceled1,eventCanceled2 = false,false
		eventCanceled1 = triggerEvent ( "onPlayerInteriorHit", client, interior, resource, id )
		eventCanceled2 = triggerEvent ( "onInteriorHit", interior, client )
		if ( eventCanceled2 ) and ( eventCanceled1 ) then
			triggerClientEvent ( client, "doWarpPlayerToInterior", client, interior, resource, id )
			setTimer ( setPlayerInsideInterior, 1000, 1, client, interior, resource, id )
		end
	end
)

local opposite = { ["interiorReturn"] = "entry",["interiorEntry"] = "return" }
function setPlayerInsideInterior ( player, interior, resource, id )
	local oppositeType = opposite[getElementType(interior)]
	local targetInterior = interiors[getResourceFromName(resource) or getThisResource()][id][oppositeType]
	local dim = getElementData ( targetInterior, "dimension" )
	local int = getElementData ( targetInterior, "interior" )
	if (isElement(player)) then
		setElementInterior ( player, int )
		setElementDimension ( player, dim )
	end
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


