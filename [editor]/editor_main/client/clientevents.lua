-- serverside selection request
addEvent ( "doSelectElement", true )
addEvent ( "doSetVehicleStatic", true )
addEvent ( "doSetPedStatic", true )
-- client-side select/drop events
addEvent "onClientElementSelect"
addEvent "onClientElementDrop"
-- client-side create/destroy events
addEvent ( "onClientElementPreCreate" )
addEvent ( "onClientElementCreate", true )
addEvent ( "onClientElementDestroyed", true )
-- edf events
addEvent ( "doLoadEDF", true )
addEvent ( "doUnloadEDF", true )
-- client-side editor mode toggle events
addEvent "onFreecamMode"
addEvent "onCursorMode"
-- element double click
addEvent "onClientElementDoubleClick"
-- custom click event
addEvent "onClientWorldClick"
-- clipboard events
addEvent ( "doAddClipboardItem", true )
addEvent ( "doRemoveClipboardItem", true )
addEvent ( "doRemoveAllClipboardItems", true )
