-- change to x^2??

-- ignore: aircraft, boats, trains, trailers
-- sports cars, low riders, muscle cars, 2-door, 4-door, bikes, light trucks and vans, heavy and utility trucks, civil/public, govt, suvs, rec, rcs

--[[local rcs = {441, 464, 501, 465, 564, 594}
local bicycles = {510, 509, 481}
local kart = {571}
local vortex = {539}
local fast_bikes = {581, 522, 461, 521, 468, 523}
local bikes = {462, 448, 463, 586, 471}
local fast_and_light = {402, 603, 429, 411, 541, 559, 415, 561, 480, 560, 562, 506, 565, 451, 434, 558, 494, 502, 477, 503, 587, 457}
local two_door = {602, 496, 401, 410, 527, 436, 589, 526, 420}
local fast_four_door_and_rec = {596, 597, 598, 568, 424}
local heavy_two_door = {555, 475, 542, 536, 575, 534, 567, 535, 576, 412, 545, 517, 518, 600, 419, 439, 533, 549, 491, 474, 438}
local four_door_and_mesa = {445, 426, 507, 547, 585, 405, 550, 492, 566, 546, 540, 551, 516, 529, 404, 479, 442, 458, 500}
local heavy_four_door = {580, 467, 604, 409, 466, 421, 504}
local suvs = {599, 490, 579, 400, 489, 505, 495}
local light_trucks_vans = {459, 543, 422, 583, 482, 478, 605, 554, 530, 418, 572, 582, 413, 440, 485, 552, 574, 525, 470, 483}
local medium_trucks = {588, 423, 573, 416, 427, 528, 601, 428, 508, 444, 556, 557}
local heavy_trucks = {499, 609, 403, 498, 514, 524, 532, 414, 578, 443, 486, 515, 406, 531, 456, 455, 431, 437, 408, 433, 432, 407, 544}]]

local vehiclesByWeight = {}
vehiclesByWeight[1] = {441, 464, 501, 465, 564, 594, 510, 509, 481, 571} -- rcs and kart
vehiclesByWeight[2] = {581, 522, 461, 521, 468, 523, 539} -- fast bikes and vortex
vehiclesByWeight[3] = {462, 448, 463, 586, 471} -- bikes
vehiclesByWeight[4] = {402, 603, 429, 411, 541, 559, 415, 561, 480, 560, 562, 506, 565, 451, 434, 558, 494, 502, 477, 503, 587, 457} -- fast cars and very light cars
vehiclesByWeight[5] = {602, 496, 401, 410, 527, 436, 589, 526, 420} -- two door cars
vehiclesByWeight[6] = {596, 597, 598, 568, 424} -- fast four door cars and light recreational cars
vehiclesByWeight[7] = {555, 475, 542, 536, 575, 534, 567, 535, 576, 412, 545, 517, 518, 600, 419, 439, 533, 549, 491, 474, 438} -- heavy two door cars
vehiclesByWeight[8] = {445, 426, 507, 547, 585, 405, 550, 492, 566, 546, 540, 551, 516, 529, 404, 479, 442, 458, 500} -- four door + mesa
vehiclesByWeight[9] = {580, 467, 604, 409, 466, 421, 504} -- heavy four door cars
vehiclesByWeight[10] = {599, 490, 579, 400, 489, 505, 495} -- suvs
vehiclesByWeight[11] = {459, 543, 422, 583, 482, 478, 605, 554, 530, 418, 572, 582, 413, 440, 485, 552, 574, 525, 470, 483} -- light trucks/vans
vehiclesByWeight[12] = {588, 423, 573, 416, 427, 528, 601, 428, 508, 444, 556, 557} -- medium trucks
vehiclesByWeight[13] = {499, 609, 403, 498, 514, 524, 532, 414, 578, 443, 486, 515, 406, 531, 456, 455, 431, 437, 408, 433, 432, 407, 544} -- heavy trucks

--[[function getDropLossFromHealth(vehicle, health)
	local vehicleType = getVehicleType(vehicle)
	if (vehicleType == "Plane" or vehicleType == "Helicopter" or vehicleType == "Boat" or vehicleType == "Train" or vehicleType == "Trailer") then
--outputChatBox("damage required to drop: 1000 (unsupported vehicle)")
		return 150
	else
		local vehID = getElementModel(vehicle)
		local index = false
		for i,v in ipairs(vehiclesByWeight) do
			local found = false
			for j,id in ipairs(v) do
				if (id == vehID) then
					found = true
					break
				end
			end
			if (found) then
				index = i
				break
			end
		end
		if (index) then
			local denom = 0
			if (index == 1) then
				denom = 10000000
			elseif (index == 2) then
				denom = 9000000
			elseif (index == 3) then
				denom = 8750000
			elseif (index == 4) then
				denom = 8000000
			elseif (index == 5) then
				denom = 6500000
			elseif (index == 6) then
				denom = 5000000
			elseif (index == 7) then
				denom = 4250000
			elseif (index == 8) then
				denom = 4000000
			elseif (index == 9) then
				denom = 3750000
			elseif (index == 10) then
				denom = 3250000
			elseif (index == 11) then
				denom = 3000000
			elseif (index == 12) then
				denom = 2500000
			elseif (index == 13) then
				denom = 1500000
			end
			local val = health^3/denom
			if (val <= 20) then
				val = 20
			end
--outputChatBox("damage required to drop: " .. val)
			return val
		else
--outputChatBox("damage required to drop: 1000 (unsupported vehicle 2)")
			return 50
		end
	end
end]]

function getDropThresholdFromVehicle(vehicle)
	local vehicleType = getVehicleType(vehicle)
	if (vehicleType == "Plane" or vehicleType == "Helicopter" or vehicleType == "Boat" or vehicleType == "Train" or vehicleType == "Trailer") then
		-- if big, unsupported vehicle
		return 120
	else -- if automobile/bike
		-- check if we have a value for our vehicle ID
		local vehID = getElementModel(vehicle)
		local index = false
		for i,v in ipairs(vehiclesByWeight) do
			local found = false
			for j,id in ipairs(v) do
				if (id == vehID) then
					found = true
					break
				end
			end
			if (found) then
				index = i
				break
			end
		end
		if (index) then
			local amount = 0
			if (index == 1) then -- rcs and kart
				amount = 15
			elseif (index == 2) then  -- fast bikes and vortex
				amount = 15
			elseif (index == 3) then -- bikes
				amount = 15
			elseif (index == 4) then  -- fast cars and very light cars
				amount = 25
			elseif (index == 5) then -- two door cars
				amount = 35
			elseif (index == 6) then -- fast four door cars and light recreational cars
				amount = 40
			elseif (index == 7) then -- heavy two door cars
				amount = 45
			elseif (index == 8) then -- four door + mesa
				amount = 45
			elseif (index == 9) then -- heavy four door cars
				amount = 50
			elseif (index == 10) then -- suvs
				amount = 70
			elseif (index == 11) then -- light trucks/vans
				amount = 80
			elseif (index == 12) then -- medium trucks
				amount = 140
			elseif (index == 13) then -- heavy trucks
				amount = 300
			end
			return amount
		else
--outputChatBox("damage required to drop: 1000 (unsupported vehicle 2)")
			return 40
		end
	end
end
