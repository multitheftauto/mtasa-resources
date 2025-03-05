local getEnemyTeam = { RED = "BLUE", BLUE = "RED" }
local blipColors = { RED = {255,0,0}, BLUE = {0,0,255} }
local playerBlips = {}
local blipInfo = {}

--Setup our playerblips
addEventHandler ( "onClientPlayerSpawn", root,
	function()
		if isElement ( playerBlips[source] ) then
			destroyElement ( playerBlips[source] )
		end
		playerBlips[source] = createBlip ( 0, 0, 0, 0, 2, 255, 0, 0, 0 )
		attachElements ( playerBlips[source], source )
	end
)

addEventHandler ( "onClientPlayerQuit", root,
	function()
		destroyElement ( playerBlips[source] )
		playerBlips[source] = nil
	end
)

addEventHandler ( "onClientPlayerWasted", root,
	function()
		destroyElement ( playerBlips[source] )
		playerBlips[source] = nil
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
		local playerTeam = getPlayerTeam(player)
		if ( playerTeam ) then
			local teamName = getTeamName ( playerTeam )
			--Sort out our nametags
			if playerTeam == localTeam then
				setPlayerNametagShowing(player,true)
				if isElement ( playerBlips[player] ) then
					if soundlevel == 0 then
						setBlipColor ( playerBlips[player], blipColors[teamName][1],blipColors[teamName][2],blipColors[teamName][3], 255 )
						setBlipSize ( playerBlips[player], 1 )
					else
						setBlipSize ( playerBlips[player], 2 )
						setBlipColor ( playerBlips[player], blipColors[teamName][1],blipColors[teamName][2],blipColors[teamName][3], 255*(soundlevel/10) )
					end
				end
			else
				if soundlevel == 0 then
					setPlayerNametagShowing(player,false)
				else
					setPlayerNametagShowing(player,true)
				end
				if isElement ( playerBlips[player] ) then
					setBlipColor ( playerBlips[player], blipColors[teamName][1],blipColors[teamName][2],blipColors[teamName][3], 255*(soundlevel/10) )
				end
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
