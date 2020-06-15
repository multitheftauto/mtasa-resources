g_ScreenX,g_ScreenY = guiGetScreenSize()
g_Root = getRootElement()
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
----

addEventHandler ( "onClientResourceStart", g_ResourceRoot,
	function()
		respawnText = dxText:create( "", 0.5, 0.5, true, "pricedown", 2 )
		respawnText:type("stroke",1.2)
		respawnText:color ( 255,0,0, 0 )
		respawnText:visible(false)
		--
		fragText = dxText:create( "0", 0, 0, true, "pricedown", fragTextScale )
		fragText:type("stroke",fragTextScale)
		fragText:boundingBox(fragStartX + 65,fragStartY + 15,fragStartX + 131,fragStartY + fragHeight - 10, false)
		--
		spreadText = dxText:create( "Spread: 0", 0, 0, true, "Arial", textScale )
		spreadText:align("right","bottom")
		spreadText:type("shadow",2,2)
		spreadText:boundingBox(0,0,fragStartX + fragWidth - 20,fragStartY - 2, false)
		--
		rankText = dxText:create( "Rank:  -/-", 0, 0, true, "Arial", textScale )
		rankText:align("right","bottom")
		rankText:type("shadow",2,2)
		rankText:boundingBox(0,0,fragStartX + fragWidth - 20,fragStartY - 2 - dxGetFontHeight ( textScale, "Arial" ), false )
	end
)

addEventHandler ( "onClientRender", g_Root,
	function()
		dxDrawImage ( fragStartX, fragStartY, fragWidth, fragHeight, "images/frag.png", 0, 0, 0, g_FragColor )
	end
)

addEventHandler ( "onClientElementDataChange", g_Root,
	function ( dataName )
		if dataName == "Score" then
			updateScores()
		end
	end
)

function updateScores()
	local currentScore = getElementData(g_LocalPlayer,"Score")
	if source == g_LocalPlayer then
		fragText:text(tostring(currentScore))
		if (currentScore < 0) then
			fragText:color(255,0,0,255)
		else
			fragText:color(255,255,255,255)
		end
		--Make the score smaller if the frag limit is 3 digits
		local length = #tostring(currentScore)
		if length >= 3 then
			fragText:scale(fragTextScale - ((length - fragTextScale)^0.7)*0.5)
		else
			fragText:scale(fragTextScale)
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
	spreadText:text("Spread: "..spread)
	if rank ~= currentRank then
		currentRank = rank
		rankText:text ( "Rank "..rank.."/"..#players )
		Animation.createAndPlay(
			rankText,
			{{ from = 0, to = 500, time = 600, fn = dxSetYellow }}
		)
	end
end
addEventHandler ( "onClientPlayerQuit", g_Root, updateScores )
addEventHandler ( "onClientPlayerJoin", g_Root, updateScores )

local countdownCR
local function countdown(time)
	for i=time,0,-1 do
		respawnText:text("You will respawn in "..i.." seconds")
		setTimer ( countdownCR, 1000, 1 )
		coroutine.yield()
	end
end

local function hideCountdown()
	setTimer (
		function()
			respawnText:visible(false)
		end,
		600, 1
	)
	Animation.createAndPlay(
	  respawnText,
	  {{ from = 255, to = 0, time = 400, fn = dxSetAlpha }}
	)
	removeEventHandler ( "onClientPlayerSpawn", g_LocalPlayer, hideCountdown )
end

addEvent ( "requestCountdown", true )
addEventHandler ( "requestCountdown", g_Root,
	function(time)
		Animation.createAndPlay(
		  respawnText,
		  {{ from = 0, to = 255, time = 600, fn = dxSetAlpha }}
		)
		addEventHandler ( "onClientPlayerSpawn", g_LocalPlayer, hideCountdown )
		respawnText:visible(true)
		time = math.floor(time/1000)
		countdownCR = coroutine.wrap(countdown)
		countdownCR(time)
	end
)

addEvent ( "onColtPickup", true )
addEventHandler ( "onColtPickup", g_Root,
	function()
		if getPedWeapon ( source, 2 ) == 22 and getPedTotalAmmo ( source, 2 ) ~= 0 then
			triggerServerEvent ( "doSetColtStat", g_LocalPlayer, true )
		elseif getPedStat ( source, 69 ) >= 999 then
			triggerServerEvent ( "doSetColtStat", g_LocalPlayer, false )
		end
	end
)
