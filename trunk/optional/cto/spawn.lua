local root = getRootElement ()
local mapStarted = false
local resourceRoot = getResourceRootElement ( getThisResource () )
local teamGame = false
local teamSpawnpoints = {}

--function onResourceStart_spawn ( resource )
function onGamemodeMapStart_spawn ( resource )
	if (not mapStarted) then
	    mapStarted = true
	    local spawnpoints = getElementsByType ( "spawnpoint" )
	    local spawnpointCount = # spawnpoints
	    if ( spawnpointCount > 0 ) then
		    local teams = getElementsByType ( "team" )
			for teamIndex,teamValue in ipairs ( teams ) do
			    teamSpawnpoints[teamValue] = {}
				local teamChildren = getElementChildren ( teamValue )
				for childIndex,childValue in ipairs ( teamChildren ) do
				    if ( getElementType ( childValue ) == "spawnpoint" ) then
				        table.insert ( teamSpawnpoints[teamValue], childValue )
				    end
				end
			    if ( not teamGame ) then
					teamGame = true
				end
			end
			if ( teamGame ) then
			    outputConsole ( "(team game)", root, 255, 255, 255 )
			    addEventHandler ( "onPlayerWasted", root, onPlayerWasted_team )
			else
			    outputConsole ( "(free for all)", root, 255, 255, 255 )
			    local players = getElementsByType ( "player" )
			    local spawnpointIndex = 1
			    for k,v in ipairs ( players ) do
	   		     	spawnPlayerAtSpawnpoint ( v, spawnpoints[spawnpointIndex] )
	   		     	spawnpointIndex = spawnpointIndex + 1
	   		     	if ( spawnpointIndex > spawnpointCount ) then
	   		     	    spawnpointIndex = 1
	   		     	end
			    end
				addEventHandler ( "onPlayerJoin", root, onPlayerJoin_noteam )
				addEventHandler ( "onPlayerWasted", root, onPlayerWasted__noteam )
			end
		else
		    outputChatBox ( "Error: no spawnpoints" )
		end
	end
end

-- non-team functions

function onPlayerJoin_noteam () -- gets triggered even with teams???
    spawnPlayerAtRandomSpawnpoint ( source )  
end

function onPlayerWasted__noteam ( ammo, killer, killerWeapon, bodypart )
	setTimer ( spawnPlayerAtRandomSpawnpoint, 3000, 1, source )
end

function spawnPlayerAtRandomSpawnpoint ( player )
    local spawnpoints = getElementsByType ( "spawnpoint" )
    local spawnpointIndex = math.random ( # spawnpoints )
    spawnPlayerAtSpawnpoint ( player, spawnpoints[spawnpointIndex] )
end

-- team functions

function onPlayerWasted_team ( ammo, killer, killerWeapon, bodypart )
	if ( getPlayerTeam ( source ) ) then
		setTimer ( spawnPlayerAtRandomTeamSpawnpoint, 5000, 1, source )
	end
end

function spawnPlayerAtRandomTeamSpawnpoint ( player )
	local team = getPlayerTeam ( player )
    local spawnpointIndex = math.random ( # teamSpawnpoints[team] )
    spawnPlayerAtSpawnpoint ( player, teamSpawnpoints[team][spawnpointIndex] )
end

function consoleJoinTeam ( player, commandName, name1, name2 )
	if ( player ) then
	    local team
	    if ( name1 and name2 ) then
	        team = getTeamFromName ( name1 .. " " .. name2 )
		elseif ( name1 ) then
	        team = getTeamFromName ( name1 )
	    end
	    if ( team ) then
	        addPlayerToTeam ( player, team )
	        spawnPlayerAtRandomTeamSpawnpoint ( player )
		else
		    outputConsole ( "no such team", player )
		end
	end
end

addEventHandler ( "onGamemodeMapStart", root, onGamemodeMapStart_spawn )
--addEventHandler ( "onResourceStart", resourceRoot, onResourceStart_spawn )

addCommandHandler ( "jointeam", consoleJoinTeam )

function spawnPlayerAtSpawnpoint ( player, sp )
outputServerLog("GOING TO SPWAN PLAYER!")
	setCameraTarget ( player, player ) -- added 7/8/09, as when the player joins and you spawn him it doesn't set the camera on him
	fadeCamera ( player, true )
	return call(getResourceFromName"spawnmanager","spawnPlayerAtSpawnpoint",player,sp )
end

setPlayerHealth = setElementHealth
setVehicleHealth = setElementHealth

