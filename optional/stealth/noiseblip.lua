local getEnemyTeam = { RED = "BLUE", BLUE = "RED" }
local blipColors = { RED = {255,0,0}, BLUE = {0,0,255} }
local playerBlips = {}
local blipInfo = {}

--Setup our playerblips
addEventHandler ( "onClientPlayerSpawn", getRootElement(),
	function()
		--Create a blip is if it doesnt exist already
		playerBlips[source] = playerBlips[source] or createBlip ( 0, 0, 0, 0, 2, 255, 0, 0, 0 )
		attachElementToElement ( playerBlips[source], source )
	end
)

addEventHandler ( "onClientPlayerQuit", getRootElement(),
	function()
		destroyBlipsAttachedTo ( source )
	end
)

addEventHandler ( "onClientPlayerWasted", getRootElement(),
	function()
		destroyBlipsAttachedTo ( source )
	end
)
---

function updateRemoteSoundLevels ()
	local localTeam = getPlayerTeam ( thisplayer )
	if not localTeam then return end
	local localTeamName = getTeamName(localTeam)
	local enemyTeam = getTeamFromName( getEnemyTeam[localTeamName] )
	local enemyTeamName = getEnemyTeam[localTeamName]
	--
	for i,player in ipairs(getElementsByType"player") do
		local soundlevel = getElementData ( player, "noiselevel" )
		outputConsole ( getPlayerName(player).." "..tostring(soundlevel) )
		local playerTeam = getPlayerTeam(player)
		local teamName = getTeamName ( playerTeam )
		--Sort out our nametags
		if playerTeam == localTeam then
			setPlayerNametagShowing(player,true)
			if isElement(playerBlips[source]) then
				if soundlevel == 0 then
					setBlipColor ( playerBlips[source], unpack(blipColors[teamName]), 255 )
					setBlipSize ( playerBlips[source], 1 )
				else
					setBlipSize ( playerBlips[source], 2 )
					setBlipColor ( playerBlips[source], unpack(blipColors[teamName]), 255*(soundlevel/10) )
				end
			end
		else
			if soundlevel == 0 then
				setPlayerNametagShowing(player,false)
			end
			if isElement(playerBlips[source]) then
				setBlipColor ( playerBlips[source], unpack(blipColors[teamName]), 255*(soundlevel/10) )
			end
		end
	end
end

function table.find ( theTable, value )
	for i,v in pairs(theTable) do
		if v == value then
			return 
		end
	end
	return false
end


function destroyBlipsAttachedTo(player)
	if not isElement(player) then return false end
	--
	local attached = getAttachedElements ( player )
	if not attached then return false end
	for k,element in ipairs(attached) do
		if getElementType ( element ) == "blip" then
			destroyElement ( element )
		end
	end
	return true
end
