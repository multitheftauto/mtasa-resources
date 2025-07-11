local disable = function() cancelEvent() end
local pickupsDisabled = false

addEventHandler ( "onResourceStart", resourceRoot,
	function()
		for i,player in ipairs(getElementsByType"player") do
			spawnPlayer ( player, 2483, -1666, 21, 0, 0, 0, getWorkingDimension() )
		end
		disablePickups(true)
	end
)

addEventHandler ( "onPlayerJoin", root,
	function()
		if not g_in_test then
			spawnPlayer ( source, 2483, -1666, 21, 0, 0, 0, getWorkingDimension() )
		end
	end
)

function disablePickups(bool)
	if bool and not pickupsDisabled then
		pickupsDisabled = true
		addEventHandler ( "onPickupHit", root, disable )
	else
		pickupsDisabled = false
		removeEventHandler ( "onPickupHit", root, disable )
	end
end
