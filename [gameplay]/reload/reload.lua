local function reloadWeapon()
	if not isPedReloadingWeapon(client) then
		reloadPedWeapon(client)
	end
end
addEvent("relWep", true)
addEventHandler("relWep", root, reloadWeapon)