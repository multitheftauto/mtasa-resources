function forceReload(p)
	local weapon=getPlayerWeapon(p)
	local totalAmmo=getPlayerTotalAmmo(p)
	setWeaponAmmo(p,weapon,totalAmmo,0)
end
addCommandHandler("Reload weapon",forceReload)

function bindPlayerReloadKey(p)
	bindKey(p,"r","down","Reload weapon")
end

function bindReloadForAllPlayers()
	for k,v in ipairs(getElementsByType("player")) do
		bindPlayerReloadKey(v)
	end
end
--addEventHandler("onResourceStart",getResourceRootElement(),bindReloadForAllPlayers) -- Enable when issue 4532 is fixed

--Please remove the following when issue 4532 is fixt:

addEvent("onPlayerReload",true)
addEventHandler("onPlayerReload",getRootElement(),
	function()
		forceReload(source)
	end
)