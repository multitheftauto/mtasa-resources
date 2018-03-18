-- add a pretty picture of a briefcase!
local TEXT_Y_INTERVAL = 38
--local TEXT_Y_INTERVAL = .05

addEvent("doCreateTeamMenu", true)
addEvent("doShowPlayerTeamMenu", true)

local root = getRootElement()

local screenX, screenY

local teams = {}
local guiExists = false
local guiShowing = false

local defaultMenuData
local menuData = {}
local highlightedTeam = false
local lastSendTime = 0
local sendDelay = 1000

local notAllFit = false

addEventHandler("doCreateTeamMenu", root,
function (teamTable)
--outputChatBox("doCreateTeamMenu ...")
	-- check input
	assert(#teamTable > 1, "Briefcase Race - Teams menu: Failed to create menu, an array of at least 2 teams is required.")
	for i,v in ipairs(teamTable) do
		assert(isElement(v) and getElementType(v) == "team")
	end
	-- reset menu data
	menuData = {}
	teams = teamTable
	-- generate menu data
	local width, height = guiGetScreenSize()
	screenX, screenY = width, height
	local curX, curY = 0.4*width, 0.10*height
	local defaultText = "Join team [F3]:"
	defaultMenuData = {text = defaultText, color = {255, 127, 0}, x = math.floor(curX), width = math.floor(0.2*width), y = math.floor(curY), height = math.floor(TEXT_Y_INTERVAL)}
	curY = curY+5
	for i,v in ipairs(teams) do
		curY = curY + TEXT_Y_INTERVAL
		local name = getTeamName(v)
		local r, g, b = getTeamColor(v)
		menuData[v] = {text = name, color = {r, g, b}, x = math.floor(curX), width = math.floor(0.2*width), y = math.floor(curY), height = math.floor(TEXT_Y_INTERVAL)}
	end
	if (curY >= height) then
		-- not all teams fit on screen
		notAllFit = true
	else
		notAllFit = false
	end
	guiExists = true
end
)

addEventHandler("doShowPlayerTeamMenu", root,
function (show, playSoundID)
--outputChatBox("doShowPlayerTeamMenu ...")
	assert(guiExists) -- asserts when team map is stopped before gm creates a team menu for player (within first 5 seconds of map start).. but who cares
	if (show == nil) then -- toggle
		if (not guiShowing) then -- show it
			highlightedTeam = false
			addEventHandler("onClientRender", root, showTextOnFrame)
			addEventHandler("onClientClick", root, onMenuClick)
		else -- hide it
			highlightedTeam = false
			removeEventHandler("onClientRender", root, showTextOnFrame)
			removeEventHandler("onClientClick", root, onMenuClick)
		end
		showCursor(not guiShowing)
		guiShowing = not guiShowing
	elseif (show) then -- show
		if (not guiShowing) then
			showCursor(true)
			guiShowing = true
			highlightedTeam = false
			addEventHandler("onClientRender", root, showTextOnFrame)
			addEventHandler("onClientClick", root, onMenuClick)
		end
	else -- hide
		if (guiShowing) then
			showCursor(false)
			guiShowing = false
			highlightedTeam = false
			removeEventHandler("onClientRender", root, showTextOnFrame)
			removeEventHandler("onClientClick", root, onMenuClick)
		end
	end
	if (playSoundID) then
		playSoundFrontEnd(playSoundID)
	end
	if (guiShowing) then
		addCommandHandler("jointeam", commandJoinTeam)
		if (notAllFit) then
			outputChatBox("Warning: Some of the teams do not fit on your screen. To join one of those teams, open the team menu [F3] and type 'jointeam TEAMNAME' in the console.")
		end
	else
		removeCommandHandler("jointeam", commandJoinTeam)
	end
end
)

function onMenuClick(button, state, aX, aY, wX, wY, wZ, element)
	if (state == "down") then
		local curTick = getTickCount()
		if (highlightedTeam and curTick-lastSendTime > sendDelay) then
			local playerTeam = getPlayerTeam(localPlayer)
			if (playerTeam and highlightedTeam == playerTeam) then
				outputChatBox("You could not join team " .. getTeamName(playerTeam) .. " because you are already on it.")
				return
			end
			lastSendTime = curTick
			triggerServerEvent("onPlayerTeamSelect", localPlayer, highlightedTeam)
		end
	end
end

function showTextOnFrame()
	local cX, cY, wX, wY, wZ = getCursorPosition()
	cX = math.floor(screenX*cX)
	cY = math.floor(screenY*cY)
	local rolledOver = false
	-- draw teams
	for k,v in pairs(menuData) do
		local r, g, b = v.color[1], v.color[2], v.color[3]
		local size = 3
		if (not rolledOver and cX > v.x and cX < v.x+v.width and cY > v.y and cY < v.y+v.height) then
			--outputChatBox("mouse over team: " .. v.text)
			--r, g, b = 255, 255, 255
			size = 3.75
			rolledOver = k
		end
		--dxDrawText(v.text, v.x+1, v.y+1, v.x+v.width, v.y+v.height, tocolor(0, 0, 0), size, "default", "center", "center", false, false, false) -- shadow
		dxDrawText(v.text, v.x, v.y, v.x+v.width, v.y+v.height, tocolor(r, g, b), size, "default", "center", "center", false, false, false)
	end
	-- draw default text
	dxDrawText(defaultMenuData.text, defaultMenuData.x+2, defaultMenuData.y+3, defaultMenuData.x+defaultMenuData.width, defaultMenuData.y+defaultMenuData.height, tocolor(0, 0, 0), 3, "default", "center", "center", false, false, false)
	dxDrawText(defaultMenuData.text, defaultMenuData.x, defaultMenuData.y, defaultMenuData.x+defaultMenuData.width, defaultMenuData.y+defaultMenuData.height, tocolor(defaultMenuData.color[1], defaultMenuData.color[2], defaultMenuData.color[3]), 3, "default", "center", "center", false, false, false)
	if (rolledOver and (not highlightedTeam or highlightedTeam ~= rolledOver)) then
		-- just rolled over
		highlightedTeam = rolledOver
		playSoundFrontEnd(32)
	elseif (not rolledOver and highlightedTeam) then
		-- just rolled off
		highlightedTeam = false
	end
end

function commandJoinTeam(command, ...)
	if (#{...} == 0) then
		outputConsole("jointeam: you must enter a team name.")
	else
		local teamName = table.concat({...}, " ")
		local team = getTeamFromName(teamName)
		if (not team) then
			outputConsole("jointeam: team " .. teamName .. " does not exist.")
		else
			local found = false
			for i,v in ipairs(teams) do
				if (v == team) then
					found = true
					break
				end
			end
			if (not found) then
				outputConsole("jointeam: team " .. teamName .. " is not a participating team.")
			else
				local playerTeam = getPlayerTeam(localPlayer)
				if (playerTeam and team == playerTeam) then
					outputConsole("jointeam: you are already on team " .. teamName .. ".")
				else
					local curTick = getTickCount()
					if (curTick-lastSendTime > sendDelay) then
						lastSendTime = curTick
						triggerServerEvent("onPlayerTeamSelect", localPlayer, team)
					end
				end
			end
		end
	end
end
