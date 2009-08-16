-- add a pretty picture of a briefcase!
--local TEXT_Y_INTERVAL = 50
local TEXT_Y_INTERVAL = .05

addEvent("doCreateTeamMenu", true)
addEvent("doShowPlayerTeamMenu", true)

local root = getRootElement()
local localPlayer = getLocalPlayer()

local teams = {}
local guiExists = false
local guiShowing = false

local instructionsLabel
local teamLabels = {}
local rolledOverLabel

addEventHandler("doCreateTeamMenu", root,
function (teamTable)
--outputChatBox("doCreateTeamMenu ...")
	-- check input
	assert(#teamTable > 1, "Briefcase Race - Teams menu: Failed to create menu, an array of at least 2 teams is required.")
	for i,v in ipairs(teamTable) do
		assert(isElement(v) and getElementType(v) == "team")
	end
	-- destroy old labels if they exist
	if (instructionsLabel) then
		destroyElement(instructionsLabel)
		instructionsLabel = false
	end
	for i,v in ipairs(teams) do
		removeEventHandler("onClientGUIClick", teamLabels[v], onTeamLabelClick)
		destroyElement(teamLabels[v])
		teamLabels[v] = nil
	end
	-- create new labels
	teams = teamTable
	local width, height = guiGetScreenSize()
	local curX, curY = 0.25*width, 0.10*height
	-- create instructions label
	instructionsLabel = guiCreateLabel(curX, curY, 0.5*width, TEXT_Y_INTERVAL*height, "Select a team:", false)
	guiSetFont(instructionsLabel, "sa-header")
	guiLabelSetHorizontalAlign(instructionsLabel, "center")
	--guiLabelSetColor(instructionsLabel, 255, 127, 255)
	guiLabelSetColor(instructionsLabel, 255, 127, 0)
	guiSetVisible(instructionsLabel, guiShowing)
	-- create teams label
	for i,v in ipairs(teams) do
		curY = curY + TEXT_Y_INTERVAL*height
		local name = getTeamName(v)
		local r, g, b = getTeamColor(v)
		teamLabels[v] = guiCreateLabel(curX, curY, 0.5*width, TEXT_Y_INTERVAL*height, name, false)
		guiSetFont(teamLabels[v], "sa-header")
		guiLabelSetHorizontalAlign(teamLabels[v], "center")
		guiLabelSetColor(teamLabels[v], r, g, b)
		addEventHandler("onClientGUIClick", teamLabels[v], onTeamLabelClick)
		guiSetVisible(teamLabels[v], guiShowing)
	end
	guiExists = true
end
)

addEventHandler("doShowPlayerTeamMenu", root,
function (show)
--outputChatBox("doShowPlayerTeamMenu ...")
	assert(guiExists)
	if (show == nil) then -- toggle
		guiSetVisible(instructionsLabel, not guiShowing)
		for i,v in ipairs(teams) do
			guiSetVisible(teamLabels[v], not guiShowing)
		end
		showCursor(not guiShowing)
		guiShowing = not guiShowing
	elseif (show) then -- show
		if (not guiShowing) then
			guiSetVisible(instructionsLabel, true)
			for i,v in ipairs(teams) do
				guiSetVisible(teamLabels[v], true)
			end
			showCursor(true)
			guiShowing = true
		end
	else -- hide
		if (guiShowing) then
			guiSetVisible(instructionsLabel, false)
			for i,v in ipairs(teams) do
				guiSetVisible(teamLabels[v], false)
			end
			showCursor(false)
			guiShowing = false
		end
	end
end
)

function onTeamLabelClick(button, state, x, y)
--outputChatBox("Team Label Clicked!")
	if (button == "left" and state == "up") then
--outputChatBox("Team Label Clicked!")
		for k,v in pairs(teamLabels) do
			if (v == source) then
--outputChatBox("Team Label Clicked!")
				triggerServerEvent("onPlayerTeamSelect", localPlayer, k)
				break
			end
		end
	end
end

--[[-- need to detect when mouse moves off an element, so we can reset it
addEventHandler("onClientMouseMove", root,
function (absX, absY)
--outputChatBox(getElementType(source))
	local found = false
	for k,v in pairs(teamLabels) do
		if (v == source) then
			if (rolledOverLabel ~= source) then
				if (rolledOverLabel) then
					highLightLabel(rolledOverLabel, false)
				end
				rolledOverLabel = source
				highLightLabel(source, true)
			end
			found = true
			break
		end
	end
	if (not found) then
		if (rolledOverLabel) then
			highLightLabel(rolledOverLabel, false)
			rolledOverLabel = false
		end
	end
end
)

function highLightLabel(label, highlight)
	if (highlight) then
		guiSetAlpha(label, 150)
	else
		guiSetAlpha(label, 255)
	end
end]]
