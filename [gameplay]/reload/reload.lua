local function reloadWeapon()
	if client then
		reloadPedWeapon(client)
	end
end
addEvent("relWep", true)
addEventHandler("relWep", root, reloadWeapon)