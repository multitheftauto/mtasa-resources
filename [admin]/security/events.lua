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