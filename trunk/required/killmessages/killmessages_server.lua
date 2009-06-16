local config = {
["lines"] = 5,
["startY"] = 0.35,
["textHeight"] = 16,
["iconHeight"] = 20,
["iconSpacing"] = 4,
["defaultWeapon"] = 255,
["fadeTime"] = 5000,
["startFade"] = 15000,
["align"] = "right",
["startX"] = -10
}
local default = {
["lines"] = 5,
["startY"] = 0.25,
["textHeight"] = 16,
["iconHeight"] = 20,
["iconSpacing"] = 4,
["defaultWeapon"] = 255,
["fadeTime"] = 5000,
["startFade"] = 15000,
["align"] = "right",
["startX"] = -10
}

local vehicleIDs = { [50]=true,[49]=true,[31]=true,[38]=true,[52]=true }
function KillMessages_onPlayerWasted ( totalammo, killer, killerweapon, bodypart )
	---These are special checks for certain kill types
	local usedVehicle
	if killerweapon == 19 then --rockets
		killerweapon = getPlayerWeapon(killer)
		if not killerweapon then
			killerweapon = 51
		end
	elseif vehicleIDs[killerweapon] then --heliblades/rammed
		if ( getElementType ( killer ) == "vehicle" ) then
			usedVehicle = getElementModel ( killer )
			killer = getVehicleOccupant ( killer, 0 )
		end
	elseif ( killerweapon == 59 ) then
		if ( getElementType ( killer ) == "player" ) then
			local vehicle = getPedOccupiedVehicle(killer)
			if ( vehicle ) then
				usedVehicle = getElementModel ( vehicle )
			end
		end
	end
	--finish this
	-- Got a killer? Print the normal "* X died" if not
	if ( killer ) then
		local kr,kg,kb = getPlayerNametagColor	( killer )
		if getPlayerTeam ( source ) then
			kr,kg,kb = getTeamColor ( getPlayerTeam ( killer ) )
		end
		-- Suicide?
		if (source == killer) then
			if not killerweapon then killerweapon = 255 end
			local triggered = triggerEvent ( "onPlayerKillMessage", source,false,killerweapon,bodypart )
			--outputDebugString ( "Cancelled: "..tostring(triggered) )
			if ( triggered ) then
				eventTriggered ( source,false,killerweapon,bodypart,true,usedVehicle)
				return
			end
		end
		local triggered = triggerEvent ( "onPlayerKillMessage", source,killer,killerweapon,bodypart )
		--outputDebugString ( "Cancelled: "..tostring(triggered) )
		if ( triggered ) then
			eventTriggered ( source,killer,killerweapon,bodypart,false,usedVehicle)
		end
	else
		local triggered = triggerEvent ( "onPlayerKillMessage", getRandomPlayer(),false,killerweapon,bodypart )
		--outputDebugString ( "Cancelled: "..tostring(triggered) )
		if ( triggered ) then
			eventTriggered ( source,false,killerweapon,bodypart,false,usedVehicle)
		end
	end
end
addEventHandler ( "onPlayerWasted", getRootElement(), KillMessages_onPlayerWasted )

addEvent ( "onPlayerKillMessage", "wasted,killer,weapon" )
function eventTriggered ( source,killer,weapon,bodypart,suicide,usedVehicle )
	local wr,wg,wb = getPlayerNametagColor	( source )
	if getPlayerTeam ( source ) then
		wr,wg,wb = getTeamColor ( getPlayerTeam ( source ) )
	end
	local kr,kg,kb = false,false,false
	if ( killer ) then
		kr,kg,kb = getPlayerNametagColor	( killer )
		if getPlayerTeam ( source ) then
			kr,kg,kb = getTeamColor ( getPlayerTeam ( killer ) )
		end
	end
	if ( usedVehicle ) then
		weapon = usedVehicle
	end
	outputKillMessage ( source, wr,wg,wb,killer,kr,kg,kb,weapon )
	--
	local extra = ""
	if ( usedVehicle ) then
	extra = " (Vehicle)"
	end
	if ( killer ) then
		if suicide then
			local weaponName = getWeaponNameFromID ( weapon )
			if weaponName then
				outputConsoleKillMessage ( "* "..getPlayerName(source).." killed himself. ("..weaponName..")" )
			else
				outputConsoleKillMessage ( "* "..getPlayerName(source).." killed himself."..extra )
			end
		else
			local weaponName = getWeaponNameFromID ( weapon )
			if weaponName then
				outputConsoleKillMessage ( "* "..getPlayerName(killer).." killed "..getPlayerName(source)..". ("..weaponName..")" )
			else
				outputConsoleKillMessage ( "* "..getPlayerName(killer).." killed "..getPlayerName(source).."."..extra )
			end
		end
	else
		outputConsoleKillMessage ( "* "..getPlayerName(source).." died."..extra )
	end
	--
end

function outputConsoleKillMessage ( text )
	outputConsole ( text )
end

function outputKillMessage ( killed, wr,wg,wb,killer,kr,kg,kb,weapon,width,resource )
	if ( resource ) then resource = getResourceName(resource) end
	if not isElement(killed) then
		outputDebugString ( "outputKillMessage - Invalid 'wasted' player specified",0,0,0,100)
		return false
	end
	if not getElementType(killed) == "player" then
		outputDebugString ( "outputKillMessage - Invalid 'wasted' player specified",0,0,0,100)
		return false
	end
	return triggerClientEvent(getRootElement(),"onClientPlayerKillMessage",killed,killer,weapon,wr,wg,wb,kr,kg,kb,width,resource )
end

function outputMessage ( message, visibleTo, r, g, b, font )
	if type(message) ~= "string" and type(message) ~= "table" then
		outputDebugString ( "outputMessage - Bad 'message' argument", 0, 112, 112, 112 ) 
		return false 
	end
	if not isElement(visibleTo) then 
		outputDebugString ( "outputMessage - Bad argument", 0, 112, 112, 112 ) 
		return false 
	end
	--Turn any resources into resource names
	if type(message) == "table" then
		for i,part in ipairs(message) do
			if type(part) == "table" and part[1] == "image" then
				if part.resource then
					message[i].resourceName = getResourceName(part.resource)
				else
					part.resourceName = getResourceName(sourceResource)
				end
			end
		end
	end
	return triggerClientEvent ( visibleTo, "doOutputMessage", visibleTo, message, r, g, b, font )
end

function setKillMessageStyle ( startX,startY,align,lines,fadeStart,fadeAnimTime )
	if ( not startX ) then startX = default.startX end
	if ( not startY ) then startY = default.startY end
	if ( not align ) then startY = align.startY end
	if ( not lines ) then lines = default.lines end
	if ( not fadeStart ) then fadeStart = default.startFade end
	if ( not fadeAnimTime ) then fadeAnimTime = default.fadeTime end
	config.startX = startX
	config.startY = startY
	config.align = align
	config.lines = lines
	config.startFade = fadeStart
	config.fadeTime = fadeAnimTime
	for k,v in ipairs(getElementsByType"player") do
		triggerClientEvent(v,"doSetKillMessageStyle",v,config.startX,config.startY,config.alignX,config.lines,config.startFade,config.fadeTime)
	end
	return true
end

addEvent ("onClientKillmessagesLoaded",true)
addEventHandler ( "onClientKillmessagesLoaded", getRootElement(),
function()
	triggerClientEvent(source,"doSetKillMessageStyle",source,config.startX,config.startY,config.alignX,config.lines,config.startFade,config.fadeTime)
end )
