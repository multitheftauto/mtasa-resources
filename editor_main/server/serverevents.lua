-- server-side select/drop events
addEvent ( "onElementSelect", true )
addEvent ( "onElementDrop", true )
-- serverside create/destroy events
addEvent "onElementCreate"
addEvent "onElementDestroy"
-- edf interface events
addEvent "onEDFLoad"
addEvent "onEDFUnload"
-- element general requests
addEvent ( "doLockElement", true )
addEvent ( "doUnlockElement", true )
addEvent ( "doCreateElement", true )
addEvent ( "doCloneElement", true )
addEvent ( "doDestroyElement", true )
-- element synchronization requests
addEvent ( "syncProperty", true )
addEvent ( "syncProperties", true )
-- undo/redo requests
addEvent ( "doUndo", true )
addEvent ( "doRedo", true )
-- undo/redo events
addEvent "onElementCreate_undoredo"
addEvent "onElementMove_undoredo"
addEvent "onElementDestroy_undoredo"
addEvent "onElementPropertiesChange_undoredo"
-- map settings sync
addEvent ( "doSaveMapSettings", true )
-- client-start events
addEvent ( "onClientRequestEDF", true )
addEvent ( "onClientGUILoaded", true )
