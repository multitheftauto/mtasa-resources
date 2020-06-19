g_ScreenX,g_ScreenY = guiGetScreenSize()
g_ResourceRoot = getResourceRootElement(getThisResource())
g_LocalPlayer = getLocalPlayer()
g_FragColor = tocolor(255,255,255,255)

local fragText,spreadText,rankText,respawnText,currentRank
--CONFIG
local fragWidth = 146
local fragHeight = 68
local fragTextScale = 2
local textScale = 1.5
local fragStartX = g_ScreenX - 20 - fragWidth
local fragStartY = g_ScreenY - 20 - fragHeight
----
----UTILITY FUNCS
local function sortingFunction (a,b)
	return (getElementData(a,"Score") or 0) > (getElementData(b,"Score") or 0)
end

local function dxSetYellowFrag ( dx, b )
	b = (b < 255) and (255 - b) or b
	g_FragColor = tocolor(255,255,b,255)
end
local function dxSetYellow ( dx, b )
	b = (b < 255) and (255 - b) or b
	dx:color(255,255,b,255)
end
local function dxSetAlpha ( dx, a )
	local r,g,b = dx:color()
	dx:color(r,g,b,a)
end

function updateScores()
	--if true then return end -- lol
	local currentScore = getElementData(g_LocalPlayer,"Score")
	if source == g_LocalPlayer then
		_hudElements.fragText:text(tostring(currentScore))
		if (currentScore < 0) then
			_hudElements.fragText:color(255,0,0,255)
		else
			_hudElements.fragText:color(255,255,255,255)
		end
		--Make the score smaller if the frag limit is 3 digits
		local length = #tostring(currentScore)
		if length >= 3 then
			_hudElements.fragText:scale(_hudElements.fragTextScale - ((length - _hudElements.fragTextScale)^0.7)*0.5)
		else
			_hudElements.fragText:scale(_hudElements.fragTextScale)
		end
		Animation.createAndPlay(
		  true,
		  {{ from = 510, to = 0, time = 400, fn = dxSetYellowFrag }}
		)
	end
	--Lets calculate local position
	local rank
	local players = getElementsByType"player"
	table.sort ( players, sortingFunction )
	for i,player in ipairs(players) do
		if player == g_LocalPlayer then
			rank = i
			break
		end
	end
	--Quickly account for drawing positions
	for i=rank,1,-1 do
		if currentScore == getElementData ( players[i], "Score" ) then
			rank = i
		else
			break
		end
	end
	--Calculate spread
	local spreadTargetScore = (rank == 1) and
				getElementData ( players[2] or players[1], "Score" )
				or getElementData ( players[1], "Score" ) or 0
	local spread = currentScore - spreadTargetScore
	_hudElements.spreadText:text("Spread: "..spread)
	if rank ~= currentRank then
		currentRank = rank
		_hudElements.rankText:text ( "Rank "..rank.."/"..#players )
		Animation.createAndPlay(
			_hudElements.rankText,
			{{ from = 0, to = 500, time = 600, fn = dxSetYellow }}
		)
	end
end
addEventHandler ( "onClientPlayerQuit", root, updateScores )
addEventHandler ( "onClientPlayerJoin", root, updateScores )

local countdownCR
local function countdown(time)
	for i=time,0,-1 do
		_hudElements.respawnText:text("You will respawn in "..i.." seconds")
		setTimer ( countdownCR, 1000, 1 )
		coroutine.yield()
	end
end

local function hideCountdown()
	setTimer (
		function()
			_hudElements.respawnText:visible(false)
		end,
		600, 1
	)
	Animation.createAndPlay(
	  _hudElements.respawnText,
	  {{ from = 255, to = 0, time = 400, fn = dxSetAlpha }}
	)
	removeEventHandler ( "onClientPlayerSpawn", g_LocalPlayer, hideCountdown )
end

function startCountdown(time)
		Animation.createAndPlay(
			_hudElements.respawnText,
		  {{ from = 0, to = 255, time = 600, fn = dxSetAlpha }}
		)
		addEventHandler ( "onClientPlayerSpawn", g_LocalPlayer, hideCountdown )
		_hudElements.respawnText:visible(true)
		time = math.floor(time/1000)
		countdownCR = coroutine.wrap(countdown)
		countdownCR(time)
	end
