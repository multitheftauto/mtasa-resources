-- defines
local localplayer = getLocalPlayer()
local onrope = false
local colshape
local timer
-- disable falling damage when they land
local function disableFallDamage(attacker, weapon, bodypart, loss)
	if ( source == localPlayer and weapon == 54 and onrope == true ) then
		-- Disable falling damage while on the rope
		cancelEvent()
	end
end
-- set on rope to false
local function setOffRope ( )
	if ( source == localPlayer and onrope == true ) then
		triggerServerEvent("frope_animoff", resourceRoot)
		setTimer(cleanUp, 1000, 1)
	end
end
-- handle ground hit
local function groundhit(ped)
	if ( ped == localPlayer and onrope == true) then
		triggerServerEvent("frope_animoff", resourceRoot)
		setTimer(cleanUp, 1000, 1)
	end
end
-- reduced code duplication here
function cleanUp ( )
	-- no longer on the rope so unset our variables and remove our handlers
	onrope = false
	removeEventHandler("onClientColShapeHit", colshape, groundhit)
	if ( timer ) then
		killTimer ( timer )
	end
end

-- remote calls

function create_FastRope ( x, y, z, time )
	-- simple wrapper
	createSWATRope(x,y,z,time)
end
addEvent( "frope_createFastRope", true )
addEventHandler("frope_createFastRope", getRootElement(), create_FastRope)
local function createLandingSphere( x, y, z, forceWait )
	-- get the ground position
	local groundPos = getGroundPosition ( x, y, z )
	-- get the water position
	local waterPos = getWaterLevel ( x, y, z, true )
	-- ground not loaded... wait
	if ( forceWait or groundPos == 0 ) then
		-- wait 500ms for it to load then try again ( should only take 1 attempt but even so it'l be handled if not)
		setTimer(createLandingSphere, 500, 1, x, y, z)
		return
	end
	-- prevent people from being able to heli drop from any height and not die
	local pX, pY, pZ = getElementPosition(localPlayer)
	if (groundPos < pZ - 10) then
		groundPos = pZ - 10
	end
	-- if the ground position is < 0 it's likely we are about to land in water though make sure the water level here is higher as well (area 51 e.g.)
	if ( groundPos < 0 and waterPos > groundPos ) then
		-- Create our sphere here and setup a hit event so we can cleanup
		colshape = createColSphere(x,y,waterPos, 3)
	else
		-- Create our sphere here and setup a hit event so we can cleanup
		colshape = createColSphere(x,y,groundPos, 3)
	end
	addEventHandler("onClientColShapeHit", colshape, groundhit)
end
function smartanimbreak ( x, y, z )
	-- don't create 2 colspheres or we end up with a leak
	if ( onrope == true ) then
		return
	end
	-- check position against rope position.
	local x2, y2, z2 = getElementPosition(localPlayer)
	-- force a 500ms wait so we load collisions
	local forceWait = true
	-- create our colsphere for the landing.
	createLandingSphere ( x, y, z, forceWait )
	-- We are on the ropes now!
	onrope = true
	-- Disable damage and make sure we cleanup if we die on the rope
	-- Allow 4 seconds then force them to disable in case we don't hit the landing sphere
	--timer = setTimer(groundhit, 4000, 1, localPlayer)
end
addEvent("frope_smartAnimBreak", true)
addEventHandler("onClientPlayerDamage", getRootElement(), disableFallDamage)
addEventHandler("onClientPlayerWasted", getRootElement(), setOffRope)
addEventHandler("frope_smartAnimBreak", getRootElement(), smartanimbreak)
