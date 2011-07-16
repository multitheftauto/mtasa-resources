addCommandHandler("giveme",
function (player, command)
	triggerClientEvent(root, "clientAddBriefCaseHolder", player)
end
)