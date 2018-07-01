function reloadWeapon()
	reloadPedWeapon(client)
end
addEvent("relWep", true)
addEventHandler("relWep", resourceRoot, reloadWeapon)
