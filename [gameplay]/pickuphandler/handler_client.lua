local screenX, screenY = guiGetScreenSize ()
local lastPickup,overlayText,overlayShowing
---
local BG_COLOR = tocolor(0,0,0,130)
local TEXT_COLOR = tocolor(255,255,255,255)

addEventHandler ( "onClientResourceStart", getResourceRootElement ( getThisResource() ),
	function()
		bindKey ( "tab", "down", "Replace weapon", "" )
	end
)

local function hideOverlay()
	if overlayShowing then
		removeEventHandler ( "onClientRender", root, drawOverlay )
	end
	overlayShowing = nil
end

addEvent ( "ph_onClientPickupHit", true )
addEventHandler ( "ph_onClientPickupHit", root,
	function ()
		local p_weapon = getPickupWeapon ( source )
		local p_slot = getSlotFromWeapon ( p_weapon )
		local weapon = getPedWeapon ( localPlayer, p_slot )
		if ( not weapon ) or ( weapon == 0 ) or ( getPedTotalAmmo ( localPlayer, p_slot ) == 0 ) or ( weapon == p_weapon ) then
			triggerServerEvent ( "ph_onPlayerPickupAccept", source, localPlayer )
		else
			local key = next(getBoundKeys"Replace weapon") or 'Replace Weapon'
			overlayText = "Press '"..key.."' to switch '"..getWeaponNameFromID ( weapon ).."' for '"..getWeaponNameFromID ( p_weapon ).."'"
			if not overlayShowing then
				addEventHandler ( "onClientRender", root, drawOverlay )
				overlayShowing = true
			end
			setTimer ( hideOverlay, 3000, 1 )
			lastPickup = source
		end
	end
)

function pickupWeapon ()
	if ( lastPickup ) then
		if ( isElement ( lastPickup ) ) then
			local x, y, z = getElementPosition ( lastPickup )
			if ( getDistanceBetweenPoints3D ( x, y, z, getElementPosition ( localPlayer ) ) < 2 ) then
				hideOverlay()
				triggerServerEvent ( "ph_onPlayerPickupAccept", lastPickup, localPlayer )
				lastPickup = nil
			end
		end
	end
end
addCommandHandler ( "Replace weapon", pickupWeapon )


function drawOverlay()
	--Draw our background
	dxDrawRectangle ( screenX - 170, screenY / 4, 170, 70, BG_COLOR, false )
	--Draw our text
	 dxDrawText ( overlayText, screenX - 165, screenY / 4 + 5, screenX - 5, screenY / 4 + 65, TEXT_COLOR, 1,
			"default-bold-small", "left", "center", false, true, false )
end

