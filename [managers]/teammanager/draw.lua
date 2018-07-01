local definition,teamsTable
local xAbsOffset = 0
local scriptRequestedMenu

if screenY*presetSpawnScreen.aspect < screenX then --Widescreen
	xAbsOffset = (screenX - screenY*presetSpawnScreen.aspect)/2
	screenX = screenY*presetSpawnScreen.aspect
end
local window, gridlist, panel
local drawColor = tocolor(0,0,0,185)
local fullDrawColor = tocolor(0,0,0,50)
local drawGamemodeName
local drawTextFont = "default-bold"
local highlighter

local white,black = tocolor(255,255,255,255),tocolor(0,0,0,255)
 x = {[getTeamFromName"blue"]=true,[getTeamFromName"red"]=true}
 y = {[getTeamFromName"blue"]=true,[getTeamFromName"red"]=true,[getTeamFromName"green"]=true,[getTeamFromName"yellow"]=true}
 z = {[getTeamFromName"blue"]=true,[getTeamFromName"red"]=true,[getTeamFromName"green"]=true}

local function drawPresetMenu ()
	local yOffset = 0
	local mouseOvered
	local cursorX,cursorY = getCursorPosition()
	cursorX,cursorY = cursorX and cursorX*screenX,cursorY and cursorY*screenY
	local fullTeams = getFullTeams()
	for team,teamData in pairs(teamsTable) do
		local r,g,b = getTeamColor(team)
		local teamColor = fullTeams[team] and tocolor(r,g,b,90) or tocolor(r,g,b,255)
		--Draw the backdrop
		local x,y = (definition.backdrop[1])*screenX + xAbsOffset, (definition.backdrop[2] + yOffset)*screenY
		local width,height = definition.backdrop[3]*screenX,definition.backdrop[4]*screenY
		--Before we draw our main backdrop, draw the highlighter if applicable
		if not fullTeams[team] and cursorX and cursorX > x and cursorX < (x+width) and cursorY > y and cursorY < (y+height) then
			local offX,offY = height*0.04,height*0.04
			dxDrawImage ( x - offX, y - offY, width, height, "images/backdrop.png", 0, 0, 0 )
			dxDrawImage ( x + offX, y - offY, width, height, "images/backdrop.png", 0, 0, 0 )
			dxDrawImage ( x + offX, y + offY, width, height, "images/backdrop.png", 0, 0, 0 )
			dxDrawImage ( x - offX, y + offY, width, height, "images/backdrop.png", 0, 0, 0 )
			if highlighter ~= team then
				playSoundFrontEnd ( 3  )
				highlighter = team
			end
			mouseOvered = highlighter
		end
		dxDrawImage ( x, y, width, height, "images/backdrop.png", 0, 0, 0, fullTeams[team] and fullDrawColor or drawColor, false )
		--Draw the icon
		x,y = (definition.icon[1])*screenX + xAbsOffset, (definition.icon[2] + yOffset)*screenY
		width,height = definition.icon[3]*screenX,definition.icon[4]*screenY
		dxDrawImage ( x, y, width, height, "images/team.png", 0, 0, 0, teamColor, false )
		--Draw the text
		x,y = (definition.text[1])*screenX + xAbsOffset, (definition.text[2] + yOffset)*screenY
		width,height = definition.text[3]*screenX,definition.text[4]*screenY
		local text = getTeamName ( team )
		local scale = height/15
		if dxGetTextWidth(text,scale,drawTextFont) > width then
			scale = scale*(math.max ( 0.3, (width/dxGetTextWidth(text,scale,drawTextFont))*0.9 ) )
		end
		dxDrawText ( text, x, y, x+width, y+height, teamColor, scale, drawTextFont, "left", "center", false, true, false )
		--Increment our y draw position
		yOffset = yOffset + definition.interval
	end
	-- if not mouseOvered then highlighter = nil end
	highlighter = mouseOvered
end

local function drawInfo()
	--First draw the "Select your team" text
	local text = drawGamemodeName.."\nSelect your team:"
	--Draw the border first
	dxDrawText ( text, infoTextX - infoTextScale, infoTextY - infoTextScale, infoTextX, infoTextY,
			infoTextOutlineColour, infoTextScale, infoTextFont, "center", "center", false, false, true )
	dxDrawText ( text, infoTextX + infoTextScale, infoTextY + infoTextScale, infoTextX, infoTextY,
			infoTextOutlineColour, infoTextScale, infoTextFont, "center", "center", false, false, true )
	dxDrawText ( text, infoTextX - infoTextScale, infoTextY + infoTextScale, infoTextX, infoTextY,
			infoTextOutlineColour, infoTextScale, infoTextFont, "center", "center", false, false, true )
	dxDrawText ( text, infoTextX + infoTextScale, infoTextY - infoTextScale, infoTextX, infoTextY,
			infoTextOutlineColour, infoTextScale, infoTextFont, "center", "center", false, false, true )
	dxDrawText ( text, infoTextX, infoTextY, infoTextX, infoTextY,
			infoTextColor, infoTextScale, infoTextFont, "center", "center", false, false, true )
	--Next, draw the help text
	local key = next(getBoundKeys("changeteam") or {})
	if key then
		text = 'Press "'..key..'" at anytime to change your team'
		--Draw the border first
		dxDrawText ( text, changeTeamX - 1, changeTeamY - 1, changeTeamX - 1, changeTeamY - 1, black, 1, "default", "center", "center" )
		dxDrawText ( text, changeTeamX + 1, changeTeamY + 1, changeTeamX + 1, changeTeamY + 1, black, 1, "default", "center", "center" )
		dxDrawText ( text, changeTeamX + 1, changeTeamY - 1, changeTeamX + 1, changeTeamY - 1, black, 1, "default", "center", "center" )
		dxDrawText ( text, changeTeamX - 1, changeTeamY + 1, changeTeamX - 1, changeTeamY + 1, black, 1, "default", "center", "center" )
		dxDrawText ( text, changeTeamX, changeTeamY, changeTeamX, changeTeamY, white, 1, "default", "center", "center" )
	end
end

function presetClicked()
	if highlighter then
		playSoundFrontEnd ( 1 )
		if  highlighter == getPlayerTeam(localPlayer) or
			triggerServerEvent ( "rpc_playerTeamSwitch", localPlayer, highlighter, scriptRequestedMenu ) then

			removeEventHandler ( "onClientRender", root, drawPresetMenu )
			removeEventHandler ( "onClientRender", root, drawInfo )
			unbindKey ( "mouse1", "down", presetClicked )
			showCursor(false)
			menuShowing = nil
		end
	end
end

function guiClicked()
	local row = guiGridListGetSelectedItem ( gridlist )
	if row == -1 then return end
	local teamName = guiGridListGetItemText ( gridlist, row, 1 )
	local team = getTeamFromName(teamName)
	if  team == getPlayerTeam(localPlayer) or
		triggerServerEvent ( "rpc_playerTeamSwitch", localPlayer, team ) then

		guiSetVisible ( panel, false )
		removeEventHandler ( "onClientRender", root, drawInfo )
		showCursor(false)
		menuShowing = nil
	end
end

function drawMenu ( teams, gamemodeName, scriptEnforced )
	scriptRequestedMenu = scriptEnforced
	if menuShowing then return end
	drawGamemodeName = gamemodeName or ""
	--Work out how many teams we've got
	local i = 0
	for _ in pairs(teams) do
		i = i + 1
	end
	if i == 0 then
		outputDebugString ( "teammanager: Error, teams table only has one entry" )
		return false
	end
	showCursor(true, false)
	teamsTable = teams
	definition = presetSpawnScreen[i]
	addEventHandler ( "onClientRender", root, drawInfo )
	if not definition then
		--Draw a gridlist
		local button
		if not window then
			panel = guiCreateTabPanel ( guiX, guiY, guiWidth, guiHeight, false )
			window = guiCreateTab( string.rep(" ",1000), panel )
			gridlist = guiCreateGridList ( 5, 5, guiWidth - 10, guiHeight - 75, false, window )
			guiGridListAddColumn ( gridlist, "Teams", 0.9 )
			button = guiCreateButton ( 5, guiHeight - 70, guiWidth - 10, 40, "OK", false, window )
			addEventHandler ( "onClientGUIClick", button, guiClicked )
			addEventHandler ( "onClientGUIDoubleClick", gridlist, guiClicked )
		end
		guiGridListClear ( gridlist )
		guiSetVisible ( panel, true )
		for team,teamData in pairs(teamsTable) do
			local row = guiGridListAddRow ( gridlist )
			guiGridListSetItemText ( gridlist, row, 1, getTeamName(team), false, false )
		end
	else
		bindKey ( "mouse1", "down", presetClicked )
		addEventHandler ( "onClientRender", root, drawPresetMenu )
	end
	menuShowing = true
end

--The balancing mechanism.  Works out what teams shouldn't be joined
function getFullTeams()
	local teams = {}
	if not getElementData(resourceRoot,"balance_teams") then return {} end
	local smallest = math.huge
	for team in pairs(teamsTable) do
		smallest = math.min ( smallest, countPlayersInTeam(team) )
	end
	for team in pairs(teamsTable) do
		local count = countPlayersInTeam(team)
		--If its the local player's team, assume he's "teamless" during selection by taking him out of the equation
		count = (getPlayerTeam(localPlayer) == team) and count-1 or count
		if count - smallest >  getElementData(resourceRoot,"balance_threshold") then
			teams[team] = true
		end
	end
	return teams
end


