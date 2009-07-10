--BUGS
-- line 43 onClientElementColShapeHit_cto already handled error on start (or just restart?)

--outputChatBox("CTO CLIENT LOADED")

local root = getRootElement ()
local thisResourceRoot = getResourceRootElement(getThisResource())

local orbMarker
local orbCol

local localPlayer
local vehicle
local normalGravity
local carrierGravity

function onClientResourceStart_cto ( resource )
    localPlayer = getLocalPlayer ()
    vehicle = getPedOccupiedVehicle ( localPlayer )
	triggerServerEvent ( "onPlayerClientScriptLoad", localPlayer )
	normalGravity = .008
	carrierGravity = .005
end

function onClientResourceStop_cto ( resource )
	if ( resource == getThisResource () ) then
		setGravity ( normalGravity )
	end
end

-- gets called twice for some reason on restart (once right away, once when it should)
-- collision shape probably gets created twice
addEvent ( "doSetOrbHittable", true )
function doSetOrbHittable_cto ( hittable, theOrbMarker )
outputDebugString("doSetOrbHittable_cto entered, hittable: " .. tostring(hittable))
if (hittable) then
assert(theOrbMarker, "theOrbMarker doesn't exist") -- appears...
assert(isElement(theOrbMarker), "theOrbMarker isn't an element")
end
	if ( hittable ) then
outputDebugString(" setting orb hittable (client)")
		orbMarker = theOrbMarker
		local x, y, z = getElementPosition ( theOrbMarker )
		orbCol = createColSphere ( x, y, z, 1.5 ) -- size changed from 1 to 1.5
		addEventHandler ( "onClientElementColShapeHit", localPlayer, onClientElementColShapeHit_cto )
	else
outputDebugString(" removing orb hittable (client)")
		orbMarker = nil
		removeEventHandler ( "onClientElementColShapeHit", localPlayer, onClientElementColShapeHit_cto )
		destroyElement ( orbCol )
		orbCol = nil
	end
end

function onClientElementColShapeHit_cto ( colshape, matchingDimension ) -- can get called lots of times tho
	if (orbCol and colshape == orbCol) then
outputDebugString ( "You hit the colshape!" )---
		if ( not isPlayerDead ( localPlayer ) ) then
			triggerServerEvent ( "onPlayerOrbHit", localPlayer, orbMarker )
		end
	end
end

addEvent ( "onClientCarrier", true )
function onClientCarrier_cto ( status )
	if ( status ) then
outputDebugString ( "You are the carrier!" )---
		addEventHandler ( "onClientResourceStop", root, onClientResourceStop_cto )
		addEventHandler ( "onClientRender", root, onClientRender_cto )
		if ( isPedInVehicle ( localPlayer ) ) then
			setGravity ( carrierGravity )
		end
	else
outputDebugString ( "You are no longer the carrier" )---
		removeEventHandler ( "onClientRender", root, onClientRender_cto )
		removeEventHandler ( "onClientResourceStop", root, onClientResourceStop_cto )
		if ( isPedInVehicle ( localPlayer ) ) then
			setGravity ( normalGravity )
		end
	end
end

function onClientRender_cto ()
	local inVehicle = isPedInVehicle ( localPlayer )
	if ( inVehicle and not vehicle ) then
	    -- player got in
outputDebugString ( "You entered a vehicle" )---
		vehicle = getPedOccupiedVehicle ( localPlayer )
		setGravity ( carrierGravity )
	elseif ( not inVehicle and vehicle ) then
		-- player got out
outputDebugString ( "You exitted a vehicle" )---
		vehicle = false
		setGravity ( normalGravity )
	elseif ( vehicle ) then
--outputDebugString ( "Speed limiter enabled" )---
		local origVX, origVY, origVZ = getElementVelocity ( vehicle )
	    -- slow vehicle down if it's going over .5 m/s
		if ( math.sqrt ( origVX^2 + origVY^2 ) > .6 ) then
		
			-- get original angle
			local angle
			if ( origVX > 0 ) then -- I or IV
				angle = math.atan ( origVY / origVX )
			elseif ( origVX < 0 ) then -- II or III
				angle = math.pi + math.atan ( origVY / origVX )
			end

			-- get new X and Y velocity
			local newVX = .6 * math.cos ( angle )
			local newVY = .6 * math.sin ( angle )
			
			-- set new velocity
			setElementVelocity ( vehicle, newVX, newVY, origVZ )
			
		end
	end
end

addEventHandler ( "onClientResourceStart", thisResourceRoot, onClientResourceStart_cto )
addEventHandler ( "doSetOrbHittable", root, doSetOrbHittable_cto )
addEventHandler ( "onClientCarrier", root, onClientCarrier_cto )


-- code for making orb hittable by vehicle
-- messy but quick fix
addEventHandler ( "onClientElementColShapeHit", getRootElement(),
function ( colShape, matchingDimension )
	if (orbCol and colShape == orbCol and isPedInVehicle(localPlayer) and getPedOccupiedVehicle(localPlayer) == source) then
outputDebugString ( "Your vehicle hit the colshape!" )---
		if ( not isPlayerDead ( localPlayer ) ) then
			triggerServerEvent ( "onPlayerOrbHit", localPlayer, orbMarker )
		end
	end
end
)