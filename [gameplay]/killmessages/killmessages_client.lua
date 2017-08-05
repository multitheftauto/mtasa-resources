local specialVehicleDamagerModels =
{
	[520] = true,
	[425] = true,
}

function onAirstrikeDamaged(att, wep, loss)
	local localVeh = getPedOccupiedVehicle(localPlayer)
	if att and getElementType(att) == "player" and att ~= localPlayer and localVeh and source == localVeh and loss > 0 then
		if isPedInVehicle(att) and specialVehicleDamagerModels[getElementModel(getPedOccupiedVehicle(att))] then
			if not isTimer(hydradmgcd) then
				hydradmgcd = setTimer(function() end, 100, 1)
				setElementData(localPlayer, "km.hydradmg", att, false)
				setTimer(setElementData, 500, 1, localPlayer, "km.hydradmg", false)
			end
		end
	end
end
addEventHandler ("onClientVehicleDamage", root, onAirstrikeDamaged)
	
function onClientWasted(killer, weapon, bodypart)
	if isPedInVehicle(source) and getElementData(source, "km.hydradmg") then
		return triggerServerEvent("onWastedPlayerKillMessageRequest", localPlayer, getElementData(source, "km.hydradmg"), 59, 0)
	else
		triggerServerEvent("onWastedPlayerKillMessageRequest", source, killer, weapon, bodypart)
	end
end
addEventHandler ("onClientPlayerWasted", localPlayer, onClientWasted)

addEvent ("onClientPlayerKillMessage",true)
function onClientPlayerKillMessage ( killer,weapon,wr,wg,wb,kr,kg,kb,width,resource )
	if wasEventCancelled() then return end
	outputKillMessage ( source, wr,wg,wb,killer,kr,kg,kb,weapon,width,resource )
end
addEventHandler ("onClientPlayerKillMessage",getRootElement(),onClientPlayerKillMessage)

function outputKillMessage ( source, wr,wg,wb,killer,kr,kg,kb,weapon,width,resource )
	if not iconWidths[weapon] then 
		if type(weapon) ~= "string" then
			weapon = 999 
		end
	end
	local killerName
	local wastedName
	if not tonumber(wr) then wr = 255 end
	if not tonumber(wg) then wg = 255 end
	if not tonumber(wb) then wb = 255 end
	if not tonumber(kr) then kr = 255 end
	if not tonumber(kg) then kg = 255 end
	if not tonumber(kb) then kb = 255 end
	if ( source ) then
		if isElement ( source ) then
			if getElementType ( source ) == "player" then 
				wastedName = getPlayerName ( source )
			else 
			outputDebugString ( "outputKillMessage - Invalid 'wasted' player specified",0,0,0,100)
			return false end
		elseif type(source) == "string" then
			wastedName = source
		end
	else 
		outputDebugString ( "outputKillMessage - Invalid 'wasted' player specified",0,0,0,100)
	return false end
	if ( killer ) then
		if isElement ( killer ) then
			if getElementType ( killer ) == "player" then
				killerName = getPlayerName ( killer )
			else 
				outputDebugString ( "outputKillMessage - Invalid 'killer' player specified",0,0,0,100)
			return false end
		elseif type(killer) == "string" then
			killerName = killer
		else
			killerName = ""
		end
	else killerName = "" end
	--create the new text
	if not killerName then
		killerName = ""
	end
	return outputMessage ( {killerName, {"padding",width=3}, {"icon",id=weapon},
		{"padding",width=3},{"color",r=wr,g=wg,b=wb}, wastedName},
		kr,kg,kb )
end
