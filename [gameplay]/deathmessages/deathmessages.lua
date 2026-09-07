addEventHandler("onPlayerWasted", root,
	function (ammo, killer, weapon, bodypart)
		local r, g, b = getColorFromString(string.upper(get("color") or "#ffaa00"))
		local message
		if killer then
			if killer ~= source then
				local killerType = getElementType(killer)
				if killerType == "player" then
					message = getPlayerName(killer).." killed "..getPlayerName(source).."."
				elseif killerType == "vehicle" then
					local controller = getVehicleController(killer)
					if controller and getElementType(controller) == "player" then
						message = getPlayerName(controller).." killed "..getPlayerName(source).."."
					else
						message = "A vehicle killed "..getPlayerName(source).."."
					end

					if get("show_vehiclename") then
						message = message .. " ("..getVehicleName(killer)..")"
					end
				end
			else
				message = getPlayerName(source).." committed suicide."
			end
		end
		if not message then
			message = getPlayerName(source).." died."
		end
		if weapon and get("show_weapon") then
			local weaponName = getWeaponNameFromID(weapon)
			if weaponName then
				message = message.." ("..weaponName..")"
			end
		end
		if bodypart and get("show_bodypart") then
			local bodypartName = getBodyPartName(bodypart)
			if bodypartName then
				message = message.." ("..bodypartName..")"
			end
		end
		outputChatBox(message, root, r, g, b)
	end
)
