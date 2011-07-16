-- two parallel arrays, one with vehicle IDs and one with vehicle drop thresholds

local vehiclesByClass = {}
vehiclesByClass[1] = {441, 464, 501, 465, 564, 594, 510, 509, 481} -- rcs
vehiclesByClass[2] = {581, 522, 461, 521, 468, 523} -- fast bikes
vehiclesByClass[3] = {462, 448, 463, 586, 471, 457, 571} -- bikes + caddy + kart
vehiclesByClass[4] = {429, 411, 541, 559, 415, 480, 560, 562, 506, 565, 451, 494, 502, 477, 503, 587, 539, 568} -- fastest cars + vortex + bandito
vehiclesByClass[5] = {402, 603, 561, 434, 558} -- fast cars
vehiclesByClass[6] = {602, 496, 401, 410, 527, 436, 589, 526, 439, 542, 475, 424} -- two door cars + bf injection
vehiclesByClass[7] = {596, 597, 598, 420} -- fast four door cars
vehiclesByClass[8] = {555, 536, 575, 534, 567, 535, 576, 412, 545, 517, 518, 600, 419, 533, 549, 491, 474} -- heavy two door cars
vehiclesByClass[9] = {445, 426, 507, 547, 585, 405, 550, 492, 566, 546, 540, 551, 516, 529, 404, 479, 442, 458, 500} -- four door + mesa
vehiclesByClass[10] = {580, 467, 604, 409, 466, 421, 504, 438} -- heavy four door cars
vehiclesByClass[11] = {599, 490, 579, 400, 489, 505, 495} -- suvs
vehiclesByClass[12] = {459, 543, 422, 583, 482, 478, 605, 554, 530, 418, 572, 582, 413, 440, 485, 552, 574, 525, 470, 483} -- light trucks/vans
vehiclesByClass[13] = {588, 423, 573, 416, 427, 528, 601, 428, 508, 444, 556, 557} -- medium trucks
vehiclesByClass[14] = {499, 609, 403, 498, 514, 524, 532, 414, 578, 443, 486, 515, 406, 531, 456, 455, 431, 437, 408, 433, 432, 407, 544} -- heavy trucks

local dropThresholds = {}
dropThresholds[1] = 8
dropThresholds[2] = 10
dropThresholds[3] = 12
dropThresholds[4] = 20
dropThresholds[5] = 25
dropThresholds[6] = 30
dropThresholds[7] = 35
dropThresholds[8] = 35
dropThresholds[9] = 40
dropThresholds[10] = 45
dropThresholds[11] = 55
dropThresholds[12] = 65
dropThresholds[13] = 110
dropThresholds[14] = 300

function getDropThresholdFromVehicle(vehicle)
	local vehicleType = getVehicleType(vehicle)
	if (vehicleType == "Plane" or vehicleType == "Helicopter" or vehicleType == "Boat" or vehicleType == "Train" or vehicleType == "Trailer") then
		-- if big, unsupported vehicle
		return 120
	else -- if automobile/bike
		-- check if we have a value for our vehicle ID
		local vehID = getElementModel(vehicle)
		local index = false
		for i,v in ipairs(vehiclesByClass) do
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
		if (index and dropThresholds[index]) then
			return dropThresholds[index]
		else
--outputChatBox("damage required to drop: 1000 (unsupported vehicle 2)")
			return 40
		end
	end
end

addCommandHandler("printvehiclethresholds",
function (player, command)
	for i,vehArray in ipairs(vehiclesByClass) do
		outputConsole("Class " .. i .. " vehicles:", player)
		local vehString = ""
		for j,vehID in ipairs(vehArray) do
			vehString = vehString .. " " .. getVehicleNameFromModel(vehID)
		end
		outputConsole(vehString, player)
		outputConsole(" Threshold: " .. dropThresholds[i], player)
	end
end
)
