local root = getRootElement()

local idleBriefcase = false
local streamedIn = false
local spin = false

local briefcaseCarriers = {} -- player = player thePlayer, object = object briefcase, hidden = bool hidden

function addBriefcaseHolder(player)
	local briefcase = createObject(1210, 0, 0, 0)
	setElementCollisionsEnabled(briefcase, false)
	table.insert(briefcaseCarriers, {player = player, briefcase = briefcase, hidden = false})
	return true
end

function removeBriefcaseHolder(player)
	local found = false
	for i,v in ipairs(briefcaseCarriers) do
		if (v.player == player) then
			destroyElement(v.briefcase)
			table.remove(briefcaseCarriers, i)
			found = true
			break
		end
	end
	return found
end

function createIdleBriefcase(x, y, z, scale, rotationPerFrame)
	if (idleBriefcase) then
		destroyElement(idleBriefcase)
	end
	idleBriefcase = createObject(1210, x, y, z)
	setElementCollisionsEnabled(idleBriefcase, false)
	if (scale) then
		setObjectScale(idleBriefcase, scale)
	end
	if (rotationPerFrame) then
		if (not tonumber(rotationPerFrame)) then
			spin = 1
		else
			spin = rotationPerFrame
		end
	end
	return true
end

function destroyIdleBriefcase()
	if (idleBriefcase) then
		destroyElement(idleBriefcase)
		idleBriefcase = false
		spin = false
		return true
	else
		return false
	end
end

addEventHandler("onClientPreRender", root,
function ()
	-- attach briefcase to players' hands
	for i,v in ipairs(briefcaseCarriers) do
		if (not isElement(v.player)) then -- perhaps the player has left unexpectedly
			removeBriefcaseHolder(v.player)
			break
		end
		if (isElementStreamedIn(v.player)) then
			if (not isPedInVehicle(v.player) and not isPedDead(v.player)) then -- not isPedInVehicle(v.player) and
				local rotationOffset = -90
				local weapID = getPedWeapon(v.player)
				--local ammo = getPedTotalAmmo(v.player) -- this might not work on remote players?
				--if (ammo > 0) then
					if (weapID == 9) then
						-- always flip it sideways
						rotationOffset = 0
					elseif (weapID == 25 or weapID == 27 or weapID == 30 or weapID == 31 or weapID == 33 or weapID == 34 or weapID == 37 or weapID == 38) then -- problem ids: 9, 37, 38
						-- flip it sideways if not aiming
						if (not isPedDoingTask(v.player, "TASK_SIMPLE_USE_GUN")) then
							rotationOffset = 0
						end
					end
				--end
				local x, y, z = getPedBonePosition(v.player, 35)
				local rx, ry, rz = getElementRotation(v.player)
				local xOffset = .1 * math.cos(math.rad(rz+90-90))
				local yOffset = .1 * math.sin(math.rad(rz+90-90))
				setElementPosition(v.briefcase, x+xOffset, y+yOffset, z-.2)
				setElementRotation(v.briefcase, rx, ry, rz+rotationOffset)
				if (v.hidden) then
					v.hidden = false
				end
			elseif (not v.hidden) then
				setElementPosition(v.briefcase, 0, 0, 0)
				v.hidden = true
			end
		end
	end
	if (spin and idleBriefcase and isElementStreamedIn(idleBriefcase)) then
		local rx, ry, rz = getElementRotation(idleBriefcase)
		setElementRotation(idleBriefcase, rx, ry, rz + spin)
	end
end
)


addEvent("clientAddBriefcaseHolder", true)
addEvent("clientRemoveBriefcaseHolder", true)
addEvent("clientCreateIdleBriefcase", true)
addEvent("clientRemoveCreateIdleBriefcase", true)

addEventHandler("clientAddBriefcaseHolder", root,
function ()
	addBriefcaseHolder(source)
end
)

addEventHandler("clientRemoveBriefcaseHolder", root,
function ()
	removeBriefcaseHolder(source)
end
)

addEventHandler("clientCreateIdleBriefcase", root,
function (x, y, z, scale, rotationPerFrame)
	createIdleBriefcase(x, y, z, scale, rotationPerFrame)
end
)

addEventHandler("clientRemoveCreateIdleBriefcase", root,
function ()
	removeIdleBriefcase()
end
)
