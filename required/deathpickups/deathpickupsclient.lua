
function GetPlayerWeapons ()
	local droppedWeapons = {}
	local weaponSlots = {0,1,2,3,4,5,6,7,8,9,10,11,12}
	
	for i, slot in ipairs(weaponSlots) do
		local ammo = getPedTotalAmmo ( localPlayer, slot ) 
		if ( getPedWeapon ( localPlayer, slot ) ~= 0 ) then
			local weapon = getPedWeapon ( localPlayer, slot )
			local ammo = getPedTotalAmmo ( localPlayer, slot )
			table.insert(droppedWeapons, {weapon, ammo})		
		end
	end	
	triggerServerEvent ( "serverDropAllWeapons", localPlayer, droppedWeapons )
    droppedWeapons = {}
end				
				
function onDeathPickupsStart ( startedResource )
	localPlayer = getLocalPlayer()
	addEvent("clientGetPlayerWeapons",true)	
	addEventHandler("clientGetPlayerWeapons", getRootElement(), GetPlayerWeapons)
end
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), onDeathPickupsStart)	