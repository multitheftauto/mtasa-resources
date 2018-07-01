local disable = function() cancelEvent() end
local pickupsDisabled = false

addEventHandler ( "onResourceStart", getResourceRootElement(getThisResource()),
	function()
		for i,player in ipairs(getElementsByType"player") do
			spawnPlayer ( player, 2483, -1666, 21, 0, 0, 0, getWorkingDimension() )
		end
		disablePickups(true)
	end
)

addEventHandler ( "onPlayerJoin", getRootElement(),
	function()
		if not g_in_test then
			spawnPlayer ( source, 2483, -1666, 21, 0, 0, 0, getWorkingDimension() )
		end
	end
)

function disablePickups(bool)
	if bool and not pickupsDisabled then
		pickupsDisabled = true
		addEventHandler ( "onPickupHit", getRootElement(), disable )
	else
		pickupsDisabled = false
		removeEventHandler ( "onPickupHit", getRootElement(), disable )
	end
end
