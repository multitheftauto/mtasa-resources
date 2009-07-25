--BUGS
-- line 43 onClientElementColShapeHit_cto already handled error on start (or just restart?)

--outputChatBox("CTO CLIENT LOADED")
local MAX_CARRIER_SPEED = .6

local root = getRootElement ()
local thisResourceRoot = getResourceRootElement(getThisResource())

local orbCol

local objectiveBlip

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
function doSetOrbHittable_cto ( hittable, x, y, z )
	if ( hittable ) then
outputDebugString(" setting orb hittable (client)")
		if ( orbCol ) then
			--??????
		end
		orbCol = createColSphere ( x, y, z, 1.5 ) -- size changed from 1 to 1.5
		addEventHandler ( "onClientElementColShapeHit", localPlayer, onClientElementColShapeHit_cto )
	else
outputDebugString(" removing orb hittable (client)")
		removeEventHandler ( "onClientElementColShapeHit", localPlayer, onClientElementColShapeHit_cto )
		destroyElement ( orbCol )
		orbCol = nil
	end
end

function onClientElementColShapeHit_cto ( colshape, matchingDimension ) -- can get called lots of times tho
	if (orbCol and colshape == orbCol) then
outputDebugString ( "You hit the colshape!" )---
		if ( not isPlayerDead ( localPlayer ) ) then
			triggerServerEvent ( "onPlayerOrbHit", localPlayer )
		end
	end
end

addEvent ( "onClientCarrier", true )
function onClientCarrier_cto ( status, objectiveBlipStatus, blipX, blipY, blipZ )
	if ( status ) then
outputDebugString ( "You are the carrier!" )---
		addEventHandler ( "onClientResourceStop", root, onClientResourceStop_cto )
		addEventHandler ( "onClientRender", root, onClientRender_cto )
		if ( isPedInVehicle ( localPlayer ) ) then
			setGravity ( carrierGravity )
		end
		-- make an objective blip?
		if (objectiveBlipStatus) then
			objectiveBlip = createBlip ( blipX, blipY, blipZ, 53, 4, 255, 0, 0, 255, 32767 )
		end
	else
outputDebugString ( "You are no longer the carrier" )---
		removeEventHandler ( "onClientRender", root, onClientRender_cto )
		removeEventHandler ( "onClientResourceStop", root, onClientResourceStop_cto )
		if ( isPedInVehicle ( localPlayer ) ) then
			setGravity ( normalGravity )
		end
		-- delete the objective blip?
		if (objectiveBlip) then
		    destroyElement(objectiveBlip)
		    objectiveBlip = nil
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
	    -- slow vehicle down if it's going over MAX_CARRIER_SPEED m/s
		if ( math.sqrt ( origVX^2 + origVY^2 ) > MAX_CARRIER_SPEED ) then
		
			-- get original angle
			local angle
			if ( origVX > 0 ) then -- I or IV
				angle = math.atan ( origVY / origVX )
			elseif ( origVX < 0 ) then -- II or III
				angle = math.pi + math.atan ( origVY / origVX )
			end

			-- get new X and Y velocity
			local newVX = MAX_CARRIER_SPEED * math.cos ( angle )
			local newVY = MAX_CARRIER_SPEED * math.sin ( angle )
			
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
			triggerServerEvent ( "onPlayerOrbHit", localPlayer )
		end
	end
end
)



-- disable marker collisions
addEvent ( "doDisableOrbCollisions", true )
addEventHandler ( "doDisableOrbCollisions", root,
function ()
	setElementCollisionsEnabled ( source, false )
end
)