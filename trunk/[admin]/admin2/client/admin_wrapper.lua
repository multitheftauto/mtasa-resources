--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client/admin_wrapper.lua
*
*	Original File by lil_Toady
*
**************************************]]

local _getVehicleNameFromModel = getVehicleNameFromModel
function getVehicleNameFromModel ( id )
	local avehspecial = { [596] = "Police LS",
				    [597] = "Police SF",
				    [598] = "Police LV",
				    [556] = "Monster 2",
				    [557] = "Monster 3",
				    [609] = "Black Boxville",
				    [604] = "Damaged Glendale",
				    [544] = "Fire Truck (Ladder)",
				    [502] = "Hotring Racer 2",
				    [503] = "Hotring Racer 3",
				    [505] = "Rancher (From \"Lure\")",
				    [605] = "Damaged Sadler"
				  }
	if ( avehspecial[id] ) then
		return avehspecial[id]
	end
	return _getVehicleNameFromModel ( id )
end

local _getVehicleModelFromName = getVehicleModelFromName
function getVehicleModelFromName ( name )
	local avehspecial = { ["Police LS"] = 596,
				    ["Police SF"] = 597,
				    ["Police LV"] = 598,
				    ["Monster 2"] = 556,
				    ["Monster 3"] = 557,
				    ["Black Boxville"] = 609,
				    ["Damaged Glendale"] = 604,
				    ["Fire Truck (Ladder)"] = 544,
				    ["Hotring Racer 2"] = 502,
				    ["Hotring Racer 3"] = 503,
				    ["Rancher (From \"Lure\")"] = 505,
				    ["Damaged Sadler"] = 605
				  }
	if ( avehspecial[name] ) then
		return avehspecial[name]
	end
	return _getVehicleModelFromName ( name )
end

function getMonthName ( month )
	local names = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
	return names[month]
end

function iif ( cond, arg1, arg2 )
	if ( cond ) then
		return arg1
	end
	return arg2
end

function getPlayerFromNick ( nick )
	for id, player in ipairs ( getElementsByType ( "player" ) ) do
		if ( getPlayerName ( player ) == nick ) then return player end
	end
	return false
end

function stripColorCodes ( text )
	return string.gsub ( text, '#%x%x%x%x%x%x', '' )
end