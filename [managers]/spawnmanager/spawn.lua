local spawnWave = false
local spawnWaveTimer = false
local quedSpawns = {}
addEvent ( "onSpawnpointUse" )

function createSpawnpoint ( x, y, z, rot, skin, interior, dimension )
	if not tonumber(x) then outputDebugString("createSpawnpoint: Bad 'x' position specified",0,255,128,0) return false end
	if not tonumber(y) then outputDebugString("createSpawnpoint: Bad 'y' position specified",0,255,128,0) return false end
	if not tonumber(z) then outputDebugString("createSpawnpoint: Bad 'z' position specified",0,255,128,0) return false end
	if not tonumber(rot) then rot = 0 return false end
	if not tonumber(skin) then skin = 0 return false end
	if not tonumber(interior) then interior = 0 return false end
	if not tonumber(skin) then dimension = 0 return false end
	skin = math.ceil(skin)
	local sp = createElement ( "spawnpoint" )
	setElementData ( sp, "posX", x )
	setElementData ( sp, "posY", y )
	setElementData ( sp, "posZ", z )
	setElementData ( sp, "rot", rot )
	setElementData ( sp, "skin", skin )
	setElementData ( sp, "interior", interior )
	setElementData ( sp, "dimension", dimension )
	return sp
end

function setSpawnpointRotation ( spawnpoint, rotation )
	if not isElement ( spawnpoint ) then outputDebugString("setSpawnpointRotation: Invalid variable specified as spawnpoint.  Element expected, got "..type(spawnpoint)..".",0,255,128,0) return false end
	if getElementType ( spawnpoint ) ~= "spawnpoint" then outputDebugString("setSpawnpointRotation: Bad element specified",0,255,128,0) return false end
	if not tonumber(rotation) then outputDebugString("setSpawnpointRotation: Bad rotation specified",0,255,128,0) return false end
	setElementData ( spawnpoint, "rot", rotation )
	return true
end

function setSpawnpointSkin ( spawnpoint, skin )
	if not isElement ( spawnpoint ) then outputDebugString("setSpawnpointSkin: Invalid variable specified as spawnpoint.  Element expected, got "..type(spawnpoint)..".",0,255,128,0) return false end
	if getElementType ( spawnpoint ) ~= "spawnpoint" then outputDebugString("setSpawnpointSkin: Bad element specified",0,255,128,0) return false end
	if not tonumber(skin) then outputDebugString("setSpawnpointSkin: Bad skin id specified.",0,255,128,0) return false end
	skin = math.ceil(skin)
	setElementData ( spawnpoint, "skin", skin )
	return true
end

function setSpawnpointTeam ( spawnpoint, team )
	if not isElement ( spawnpoint ) then outputDebugString("setSpawnpointTeam: Invalid variable specified as spawnpoint.  Element expected, got "..type(spawnpoint)..".",0,255,128,0) return false end
	if getElementType ( spawnpoint ) ~= "spawnpoint" then outputDebugString("setSpawnpointTeam: Bad spawnpoint element specified",0,255,128,0) return false end
	if not isElement ( team ) then outputDebugString("setSpawnpointTeam: Invalid variable specified as team.  Element expected, got "..type(team)..".",0,255,128,0) return false end
	if getElementType ( team ) ~= "team" then outputDebugString("setSpawnpointTeam: Bad team element specified",0,255,128,0) return false end
	skin = math.ceil(skin)
	setElementData ( spawnpoint, "team", skin )
	return true
end

function getSpawnpointRotation ( spawnpoint )
	if not isElement ( spawnpoint ) then outputDebugString("setSpawnpointRotation: Invalid variable specified as spawnpoint.  Element expected, got "..type(spawnpoint)..".",0,255,128,0) return false end
	if getElementType ( spawnpoint ) ~= "spawnpoint" then outputDebugString("setSpawnpointRotation: Bad element specified",0,255,128,0) return false end
	return getElementData ( spawnpoint, "rot" ) or 0
end

function getSpawnpointSkin ( spawnpoint )
	if not isElement ( spawnpoint ) then outputDebugString("setSpawnpointSkin: Invalid variable specified as spawnpoint.  Element expected, got "..type(spawnpoint)..".",0,255,128,0) return false end
	if getElementType ( spawnpoint ) ~= "spawnpoint" then outputDebugString("setSpawnpointSkin: Bad element specified",0,255,128,0) return false end
	return getElementData ( spawnpoint, "skin" ) or 0
end

function getSpawnpointTeam ( spawnpoint )
	if not isElement ( spawnpoint ) then outputDebugString("setSpawnpointTeam: Invalid variable specified as spawnpoint.  Element expected, got "..type(spawnpoint)..".",0,255,128,0) return false end
	if getElementType ( spawnpoint ) ~= "spawnpoint" then outputDebugString("setSpawnpointTeam: Bad spawnpoint element specified",0,255,128,0) return false end
	return getElementData ( spawnpoint, "team" )
end

function setSpawnWave ( enabled, wavetime )
	if ( enabled ) then
		if not wavetime then wavetime = 15000 end
		spawnWave = wavetime
		if spawnWaveTimer then
			for k,v in pairs(getTimers()) do
				if v == spawnWaveTimer then killTimer ( v ) end
			end
		end
		spawnWaveTimer = setTimer ( waveSpawnPlayers, spawnWave, 0 )
		return true
	elseif enabled == false then
		if spawnWaveTimer then
			for k,v in pairs(getTimers()) do
				if v == spawnWaveTimer then killTimer ( v ) end
			end
		end
		spawnWave = false
		return true
	else
		outputDebugString("setSpawnWave: Invalid variable specified as bool.  Boolean expected, got "..type(enabled)..".",0,255,128,0)
		return false
	end
end

function spawnPlayerAtSpawnpoint ( player, spawnpoint, useWave )
	if not isElement ( spawnpoint ) then spawnpoint = getRandomSpawnpoint() else
		if getElementType ( spawnpoint ) ~= "spawnpoint" then
			spawnpoint = getRandomSpawnpoint()
		end
	end
	if not isElement ( player ) then outputDebugString("spawnPlayerAtSpawnpoint: Invalid variable specified as player.  Element expected, got "..type(player)..".",0,255,128,0) return false end
	if getElementType ( player ) ~= "player" then outputDebugString("spawnPlayerAtSpawnpoint: Bad player element specified",0,255,128,0) return false end
	local x,y,z = getElementData ( spawnpoint, "posX" ),getElementData ( spawnpoint, "posY" ),getElementData ( spawnpoint, "posZ" )
	if not tonumber(x) then outputDebugString("spawnPlayerAtSpawnpoint: Specified spawnpoint lacks proper 'x' position",0,255,128,0) return false end
	if not tonumber(y) then outputDebugString("spawnPlayerAtSpawnpoint: Specified spawnpoint lacks proper 'y' position",0,255,128,0) return false end
	if not tonumber(z) then outputDebugString("spawnPlayerAtSpawnpoint: Specified spawnpoint lacks proper 'z' position",0,255,128,0) return false end
	local skin = getElementData ( spawnpoint, "skin" )
	local rot = getElementData ( spawnpoint, "rot" ) or getElementData ( spawnpoint, "rotation" ) or getElementData ( spawnpoint, "rotZ" )
	local interior = getElementData ( spawnpoint, "interior" )
	local dimension = getElementData ( spawnpoint, "dimension" )
	local team = getElementData ( spawnpoint, "team" )
	if not ( skin ) then skin = 0 end
	if not ( rot ) then rot = 0 end
	if not ( interior ) then interior = 0 end
	if not ( dimension ) then dimension = 0 end
	if not ( team ) then team = nil end
	if ( useWave ) and ( spawnWave ) then
		quedSpawns[player] = {}
		quedSpawns[player].x = x
		quedSpawns[player].y = y
		quedSpawns[player].z = z
		quedSpawns[player].rot = rot
		quedSpawns[player].skin = skin
		quedSpawns[player].interior = interior
		quedSpawns[player].dimension = dimension
		quedSpawns[player].team = team
		return true
	else
		if (type(team) == "string") then
			team = getTeamFromName(team)
		end
		spawnPlayer ( player, x, y, z, rot, skin, interior, dimension, team )
		triggerEvent ( "onSpawnpointUse", spawnpoint, player )
		return true
	end
end

function waveSpawnPlayers ( )
	for player, info in pairs(quedSpawns) do
		spawnPlayer ( player, quedSpawns[player].x, quedSpawns[player].y, quedSpawns[player].z, quedSpawns[player].rot, quedSpawns[player].skin, quedSpawns[player].interior, quedSpawns[player].dimension, quedSpawns[player].team )
	end
	quedSpawns = {}
end

function getRandomSpawnpoint()
	local spawnpoints = getElementsByType("spawnpoint")
	local randNumber = math.random ( 1, #spawnpoints )
	return spawnpoints[randNumber]
end
