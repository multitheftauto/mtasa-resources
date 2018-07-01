local carrierLabel

addEventHandler("onClientResourceStart", getResourceRootElement(),
function (resource)
	local x, y = guiGetScreenSize()
	carrierLabel = guiCreateLabel(math.ceil(.25*x), 35, math.ceil(.5*x), 50, "The briefcase is idle.", false)
	guiLabelSetHorizontalAlign(carrierLabel, "center")
	guiLabelSetColor(carrierLabel, 255, 127, 0)
	guiSetFont(carrierLabel, "clear-normal")
	guiSetVisible(carrierLabel, false)
	bindKey("tab", "down", toggleShowCarrier, true)
	bindKey("tab", "up", toggleShowCarrier, false)
end
)

function guiShowBriefcaseGuy(player)
	local yourTeam = getPlayerTeam(localPlayer)
	local hisTeam = getPlayerTeam(player)
	if (player == localPlayer) then
		guiSetText(carrierLabel, "You have the briefcase!")
	elseif (yourTeam and hisTeam and yourTeam == hisTeam) then
		guiSetText(carrierLabel, "Your team has the briefcase!")
	elseif (yourTeam and hisTeam) then
		guiSetText(carrierLabel, "The enemy has the briefcase (" .. getTeamName(hisTeam) .. ").")
	else
		guiSetText(carrierLabel, "The enemy has the briefcase (" .. getPlayerName(player) .. ").")
	end
end

function guiShowIdle()
	guiSetText(carrierLabel, "The briefcase is idle.")
end

function toggleShowCarrier(key, keyState, show)
	guiSetVisible(carrierLabel, show)
end
