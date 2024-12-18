-- https://wiki.multitheftauto.com/wiki/OnPlayerTriggerInvalidEvent
-- gets triggered when a remote clients triggers an invalid event on server
function clientTriggersInvalidEvent(strEventName, bIsAdded, bIsRemote)
	logViolation(source, "Triggered invalid event \""..strEventName.."\" - bIsAdded: "..tostring(bIsAdded).." - bIsRemote: "..tostring(bIsRemote));
end
addEventHandler("onPlayerTriggerInvalidEvent", root, clientTriggersInvalidEvent);



-- https://wiki.multitheftauto.com/wiki/OnPlayerTriggerEventThreshold
-- gets triggered when a remote clients exceeds the event trigger treshold set by server in config -> max_player_triggered_events_per_interval
function clientTriggersEventThreshold()
	logViolation(source, "Exceeded event trigger threshold of "..tostring(getServerConfigSetting("max_player_triggered_events_per_interval")));
end
addEventHandler("onPlayerTriggerEventThreshold", root, clientTriggersEventThreshold);



-- https://wiki.multitheftauto.com/wiki/OnPlayerConnect
-- we use onPlayerConnect event to check if the player got a valid username
function clientConnectServer(strPlayerNick, strPlayerIP, strPlayerUsername, strPlayerSerial, iPlayerVersionNumber, strPlayerVersionString)
	if(not isPlayerNameValid(strPlayerNick)) then
		logAction("Client "..strPlayerNick.." with IP "..strPlayerIP.." and Serial "..strPlayerSerial.." tried to join with invalid nickname! Version: "..iPlayerVersionNumber.." | "..strPlayerVersionString);
		cancelEvent(true, "INVALID NICKNAME!");
		return;
	end
end
addEventHandler("onPlayerConnect", root, clientConnectServer);



-- https://wiki.multitheftauto.com/wiki/OnPlayerChangesWorldSpecialProperty
-- gets triggered when client changes world special property
function clientChangesWorldSpecialProperty(strProperty, bEnabled)
	logViolation(source, "Changed world special property \""..strProperty.."\" to "..tostring(bEnabled));
end
addEventHandler("onPlayerChangesWorldSpecialProperty", root, clientChangesWorldSpecialProperty);