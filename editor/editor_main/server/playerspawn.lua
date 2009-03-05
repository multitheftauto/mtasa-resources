local disable = function() cancelEvent() end
addEventHandler ( "onResourceStart", getResourceRootElement(getThisResource()),
	function()
		for i,player in ipairs(getElementsByType"player") do
			spawnPlayer ( player, 2483, -1666, 21 )
			setElementDimension(player, getWorkingDimension())
		end
		disablePickups(true)
	end
)

addEventHandler ( "onPlayerJoin", getRootElement(),
	function()
		if not g_in_test then
			spawnPlayer ( source, 2483, -1666, 21 )
			setElementDimension(source, getWorkingDimension())
		end
	end
)

function disablePickups(bool)
	if bool then
		addEventHandler ( "onPickupHit", getRootElement(), disable )
	else
		removeEventHandler ( "onPickupHit", getRootElement(), disable )
	end
end
