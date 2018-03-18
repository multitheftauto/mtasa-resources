--+----------------------------+
--|     Scoreboard Editor      |
--|     Created By AlienX      |
--+----------------------------+

--Options:
gameShowKills = false
gameShowDeaths = false
gameShowStatus = false
gameShowHealth = false
gameShowMoney = false
gameShowWantedLevel = false
gameShowKDRatio = false

function onMapLoad ( name )
	if getThisResource() ~= name then return end

	--FOR MASS TESTS:
	showKills ( true )
	showDeaths ( true )
	showKDRatio ( true )

	for k,v in ipairs(getElementsByType("player")) do
		if ( v ) then
			setElementData ( v, "kills", 0 )
			setElementData ( v, "deaths", 0 )
			setElementData ( v, "status", "N/A" )
			setElementData ( v, "health", "N/A" )
			setElementData ( v, "money", "$0" )
			setElementData ( v, "wanted level", "0" )
			setElementData ( v, "kdr", 0.0 )
		end
	end

	setTimer ( gameTick, 1000, 0 )
end
addEventHandler( "onResourceStart", getResourceRootElement(getThisResource()), onMapLoad)

function onMapFinish ( name )
	if getThisResource() ~= name then return end
	showKills ( false )
	showDeaths ( false )
	showStatus ( false )
	showHealth ( false )
	showMoney ( false )
	showWantedLevel ( false )
	showKDRatio ( false )
end
addEventHandler( "onResourceStop", root, onMapFinish)

function onMapFinish ( name )
	if getThisResource() ~= name then return end

	showKills ( false )
	showDeaths ( false )
	showStatus ( false )
	showHealth ( false )
	showMoney ( false )
	showWantedLevel ( false )
	showKDRatio ( false )

end
addEventHandler( "onResourceStop", root, onMapFinish)

--Option Functions:
function showKills ( option )
	if not ( option ) then
		--Its on, lets turn it off
		gameShowKills = false
		call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "kills")
	else
		--Its off, turn it on
		gameShowKills = true
		call(getResourceFromName("scoreboard"), "addScoreboardColumn", "kills")
		outputDebugString ( "Showing kills now..." )
	end
end

function showDeaths ( option )
	if not ( option ) then
		--Its on, lets turn it off
		gameShowDeaths = false
		call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "deaths")
	else
		--Its off, turn it on
		gameShowDeaths = true
		call(getResourceFromName("scoreboard"), "addScoreboardColumn", "deaths")
	end
end

function showStatus ( option )
	if not ( option ) then
		--Its on, lets turn it off
		gameShowStatus = false
		call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "status")
	else
		--Its off, turn it on
		gameShowDeaths = true
		call(getResourceFromName("scoreboard"), "addScoreboardColumn", "status")
	end
end

function showHealth ( option )
	if not ( option ) then
		--Its on, lets turn it off
		gameShowHealth = false
		call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "health")
	else
		--Its off, turn it on
		gameShowHealth = true
		call(getResourceFromName("scoreboard"), "addScoreboardColumn", "health")
	end
end

function showMoney ( option )
	if not ( option ) then
		--Its on, lets turn it off
		gameShowMoney = false
		call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "money")
	else
		--Its off, turn it on
		gameShowMoney = true
		call(getResourceFromName("scoreboard"), "addScoreboardColumn", "money")
	end
end

function showWantedLevel ( option )
	if not ( option ) then
		--Its on, lets turn it off
		gameShowWantedLevel = false
		call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "wanted level")
	else
		--Its off, turn it on
		gameShowWantedLevel = true
		call(getResourceFromName("scoreboard"), "addScoreboardColumn", "wanted level")
	end
end

function showKDRatio ( option )
	if not ( option ) then
		--Its on, lets turn it off
		gameShowKDRatio = false
		call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "kdr")
	else
		--Its off, turn it on
		gameShowKDRatio = true
		call(getResourceFromName("scoreboard"), "addScoreboardColumn", "kdr")
	end
end

--Game tick function
function gameTick ()
	for k,v in ipairs(getElementsByType("player")) do
		if ( v ) then
			--Need to check:
			--Health - Done
			--status - Done
			--Money - Done
			--WantedLevel - Done
			local playerHP = getElementHealth(v)
			if ( playerHP ) then
				if ( playerHP == 0 ) then
					setElementData ( v, "health", "Dead" )
				else
					setElementData ( v, "health", playerHP .. "%" )
				end
			end

			local playerVehicle = getPedOccupiedVehicle(v)
			if ( playerVehicle ) then
				--Inside one
				setElementData ( v, "status", "Vehicle" )
			else
				--On foot
				setElementData ( v, "status", "Foot" )
			end

			local playerMoney = getPlayerMoney(v)
			if ( playerMoney ) then
				setElementData ( v, "money", "$" .. playerMoney )
			end

			local playerWantedLevel = getPlayerWantedLevel(v)
			if ( playerWantedLevel ) then
				setElementData ( v, "wanted level", playerWantedLevel )
			end

			local playerDeaths = getElementData ( v, "deaths" )
			local playerKills = getElementData ( v, "kills" )
			if ( playerDeaths == 0 and playerKills == 0 ) then
				setElementData ( v, "kdr", 0.0 )
			else
				local xplayerDeaths = playerDeaths
				local xplayerKills = playerKills
				if xplayerDeaths == 0 then xplayerDeaths = 1 end
				local xplayerKills = tonumber(xplayerKills)
				local xplayerDeaths = tonumber(xplayerDeaths)
				if (not xplayerKills) then
					xplayerKills = 0
				end
				if (not xplayerDeaths) then
					xplayerDeaths = 0
				end
				local playerkdr = tostring(( xplayerKills / xplayerDeaths ))
				setElementData ( v, "kdr", math.ceil(playerkdr) )
			end
		end
	end
end

--Event functions
function onPlayerJoin ()
	setElementData ( source, "kills", 0 )
	setElementData ( source, "deaths", 0 )
	setElementData ( source, "status", "N/A" )
	setElementData ( source, "health", "N/A" )
	setElementData ( source, "money", "$0" )
	setElementData ( source, "wanted level", "0" )
	setElementData ( source, "kdr", 0.0 )

	if ( gameShowKills ) then
		showKills ( false )
		showKills ( true )
	end
	if ( gameShowDeath ) then
		showDeath ( false )
		showDeath ( true )
	end
	if ( gameShowStatus ) then
		showStatus ( false )
		showStatus ( true )
	end
	if ( gameShowHealth ) then
		showHealth ( false )
		showHealth ( true )
	end
	if ( gameShowMoney ) then
		showMoney ( false )
		showMoney ( true )
	end
	if ( gameShowWantedLevel ) then
		showWantedLevel ( false )
		showWantedLevel ( true )
	end
	if ( gameShowKDRatio ) then
		showKDRatio ( false )
		showKDRatio ( true )
	end
end
addEventHandler ( "onPlayerJoin", root, onPlayerJoin )

function xonPlayerWasted ( ammo, attacker, weapon, bodypart )
	--Source = person who was wasted
	--Attacker = person who did the killing

	local wastedDeaths = getElementData ( source, "deaths" )
	wastedDeaths = wastedDeaths + 1
	setElementData ( source, "deaths", wastedDeaths )

	if ( attacker ) then
		if not ( attacker == source ) then
		    if ( getPlayerTeam(attacker) ~= getPlayerTeam(source) ) then
			    local attackerKills = getElementData ( attacker, "kills" )
			    attackerKills = attackerKills + 1
			    setElementData ( attacker, "kills", attackerKills )
			end
		end
	end
end
addEventHandler ( "onPlayerWasted", root, xonPlayerWasted )
