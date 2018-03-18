----------------------------------- D E B U G -----------------------------------
local bcCarriedText = 	guiCreateLabel(100, 425, 500, 100, "Briefcase carrier :  none", false); 				guiSetVisible(bcCarriedText, false)
local bcIdleText = 		guiCreateLabel(100, 450, 500, 100, "Briefcase idle :  false", false); 					guiSetVisible(bcIdleText, false)
local obExistsText = 	guiCreateLabel(100, 487.5, 500, 100, "Objective exists :  false", false); 				guiSetVisible(obExistsText, false)
local obHitterText = 	guiCreateLabel(100, 512.5, 500, 100, "Objective hitter :  none or not you", false); 	guiSetVisible(obHitterText, false)
local obsHitterText = 	guiCreateLabel(100, 550, 500, 100, "Team objective hitter :  none or not you", false); 	guiSetVisible(obsHitterText, false)
addCommandHandler("dbg",
function (command, arg)
	local vis = true
	if (arg == "0") then  vis = false  end
	guiSetVisible(bcCarriedText, vis)
	guiSetVisible(bcIdleText, vis)
	guiSetVisible(obExistsText, vis)
	guiSetVisible(obHitterText, vis)
	guiSetVisible(obsHitterText, vis)
end
)
---------------------------------------------------------------------------------
---- Assert Checks ----
local bcCarried = false
local bcIdle = false
local obExists = false
local obHittable = false
local obsExist = {} -- at least 1 team obj exists
local ob2Hittable = false -- a team objective is hittable
-----------------------

-- server events:
--  onClientResourceLoad
--  onPlayerBriefcaseHit
--  onPlayerObjectiveHit

BRIEFCASE_BLIP_ID = 56--41
BRIEFCASE_BLIP_SIZE = 4
OBJECTIVE_BLIP_ID = 53
ENEMY_OBJECTIVE_BLIP_ID = 0
BLIP_DISTANCE_LIMIT = 250
TEAM_BLIP_DISTANCE_LIMIT = 150

local root = getRootElement()
local indicator = false
local briefcaseBlip = false

local objective = false
local objectiveBlip = false

local teamObjectives = {}
local teamObjectiveBlips = {}

addEvent("clientGiveBriefcaseToPlayer", true)
addEvent("clientTakeBriefcaseFromPlayer", true)
addEvent("clientCreateIdleBriefcase", true)
addEvent("clientDestroyIdleBriefcase", true)
addEvent("clientCreateObjective", true)
addEvent("clientSetObjectiveHittable", true)
addEvent("clientDestroyObjective", true)
addEvent("clientCreateTeamObjective", true)
addEvent("clientSetTeamObjectiveHittable", true)
addEvent("clientDestroyTeamObjective", true)

addEventHandler("clientGiveBriefcaseToPlayer", root,
function (r, g, b)
	assert(not bcCarried)
	r = r or 255
	g = g or 0
	b = b or 0
	bcCarried = true
--outputDebugString("in client clientGiveBriefcaseToPlayer")
	-- source is the player to give to, coords are the location of the objective, hideObjective is whether to hide the objective from everyone else
	--exports.briefcase:addBriefcaseHolder(source)
	scheduleBriefcaseCall("addBriefcaseHolder", source)
	-- create blip attached to player
	briefcaseBlip = createBlip(0, 0, 0, BRIEFCASE_BLIP_ID, BRIEFCASE_BLIP_SIZE, 255, 0, 0, 255, 32766)
	attachElements(briefcaseBlip, source)
	-- create gui indicating the briefcase carrier
	guiShowBriefcaseGuy(source)
	-- create indicator for easy identification of the briefcase guy
	indicator = createMarker(0, 0, 0, "arrow", 1, r, g, b, 200)
	attachElements(indicator, source, 0, 0, 2.5)
	if (source == localPlayer) then
		-- add vehicle events and gui for briefcase guy
		addVehicleEffects()
	end
	-- debug --
	guiSetText(bcCarriedText, "Briefcase carrier :  " .. getPlayerName(source))
end
)

addEventHandler("clientTakeBriefcaseFromPlayer", root,
function ()
	assert(bcCarried)
	bcCarried = false
--outputDebugString("in client clientTakeBriefcaseFromPlayer")
	-- source is the player to give to
	--exports.briefcase:removeBriefcaseHolder(source)
	scheduleBriefcaseCall("removeBriefcaseHolder", source)
	-- remove blip from player
	destroyElement(briefcaseBlip)
	-- remove gui indicating the briefcase carrier
	guiShowIdle()
	-- remove indicator for briefcase guy
	destroyElement(indicator)
	indicator = false
	if (source == localPlayer) then
		-- remove vehicle events and gui for briefcase guy
		removeVehicleEffects()
	end
	-- debug --
	guiSetText(bcCarriedText, "Briefcase carrier :  none")
end
)

addEventHandler("clientCreateIdleBriefcase", root,
function (x, y, z)
	assert(not bcIdle)
	bcIdle = true
	-- source is the root element
	--exports.briefcase:createIdleBriefcase(x, y, z, 3, 1)
	scheduleBriefcaseCall("createIdleBriefcase", x, y, z, 2.5, 1)
	-- create blip at this location
	briefcaseBlip = createBlip(x, y, z, BRIEFCASE_BLIP_ID, BRIEFCASE_BLIP_SIZE, 255, 0, 0, 255, 32766)
	-- make briefcase hittable
	createHittableBriefcaseCol(x, y, z-1, 1.25, 2)
	-- debug --
	guiSetText(bcIdleText, "Briefcase idle :  true")
end
)

addEventHandler("clientDestroyIdleBriefcase", root,
function ()
	assert(bcIdle)
	bcIdle = false
	-- source is the root element
	--exports.briefcase:destroyIdleBriefcase()
	scheduleBriefcaseCall("destroyIdleBriefcase")
	-- remove blip
	destroyElement(briefcaseBlip)
	briefcaseBlip = false
	-- make briefcase not hittable
	destroyHittableBriefcaseCol()
	-- debug --
	guiSetText(bcIdleText, "Briefcase idle :  false")
end
)

addEventHandler("clientCreateObjective", root,
function (x, y, z, showBlip)
	assert(not obExists)
	obExists = true
	objective = createMarker(x, y, z, "cylinder", 3, 137, 112, 219, 170)
	if (showBlip) then
		objectiveBlip = createBlip(x, y, z, OBJECTIVE_BLIP_ID, 4, 255, 0, 0, 255, 32767)
	else
		objectiveBlip = createBlip(x, y, z, OBJECTIVE_BLIP_ID, 4, 255, 0, 0, 255, 32767, BLIP_DISTANCE_LIMIT)
	end
	-- debug --
	guiSetText(obExistsText, "Objective exists :  true")
end
)

addEventHandler("clientSetObjectiveHittable", root,
function (hittable, showBlip)
	assert(obExists)
	if (hittable) then
		assert(not obHittable)
		obHittable = true
		-- make the objective hittable
		local x, y, z = getElementPosition(objective)
		createHittableObjectiveCol(x, y, z, 1.5, 3)
		if (not showBlip) then
			destroyElement(objectiveBlip)
			objectiveBlip = createBlip(x, y, z, OBJECTIVE_BLIP_ID, 4, 255, 0, 0, 255, 32767)
		end
		-- debug --
		guiSetText(obHitterText, "Objective hitter :  you")
	else
		assert(obHittable)
		obHittable = false
		destroyHittableObjectiveCol()
		if (not showBlip) then
			local x, y, z = getElementPosition(objective)
			destroyElement(objectiveBlip)
			objectiveBlip = createBlip(x, y, z, OBJECTIVE_BLIP_ID, 4, 255, 0, 0, 255, 32767, BLIP_DISTANCE_LIMIT)
		end
		-- debug --
		guiSetText(obHitterText, "Objective hitter :  none or not you")
	end
end
)

addEventHandler("clientDestroyObjective", root,
function ()
	assert(not obHittable)
	assert(obExists)
	obExists = false
	destroyElement(objective)
	destroyElement(objectiveBlip)
	objectiveBlip = false
	-- debug --
	guiSetText(obExistsText, "Objective exists :  false")
end
)

addEventHandler("clientCreateTeamObjective", root,
function (team, friendly, x, y, z)
	assert(not obsExist[team])
	obsExist[team] = true
	local r, g, b = getTeamColor(team)
	teamObjectives[team] = createMarker(x, y, z, "cylinder", 3, r, g, b, 85)
	if (friendly) then
		teamObjectiveBlips[team] = createBlip(x, y, z, OBJECTIVE_BLIP_ID, 4, 255, 0, 0, 255, 32767)
	else
		teamObjectiveBlips[team] = createBlip(x, y, z, ENEMY_OBJECTIVE_BLIP_ID, 3, r, g, b, 255, 32767, TEAM_BLIP_DISTANCE_LIMIT)
	end
end
)

addEventHandler("clientSetTeamObjectiveHittable", root,
function (team, hittable)
	assert(obsExist[team])
	if (hittable) then
		assert(not ob2Hittable)
		ob2Hittable = true
		-- make the objective hittable
		local x, y, z = getElementPosition(teamObjectives[team])
		createHittableObjectiveCol(x, y, z, 1.5, 3)
		-- debug --
		guiSetText(obsHitterText, "Team objective hitter :  you")
	else
		assert(ob2Hittable)
		ob2Hittable = false
		destroyHittableObjectiveCol()
		-- debug --
		guiSetText(obsHitterText, "Team objective hitter :  none or not you")
	end
end
)

addEventHandler("clientDestroyTeamObjective", root,
function (team)
	assert(obsExist[team])
	obsExist[team] = false
	destroyElement(teamObjectives[team])
	destroyElement(teamObjectiveBlips[team])
	teamObjectives[team] = nil
	teamObjectiveBlips[team] = nil
end
)
