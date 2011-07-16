local loadedMap = false
addEvent ( "saveloadtest_return",true )
function openResource ( resourceName )
	triggerServerEvent ( "openResource", getLocalPlayer(), resourceName )
end

addEventHandler ( "saveloadtest_return", getRootElement(),
	function ( command, returnValue, returnValue2, reason )
		reason = reason or ""
		if ( command ) == "open" then
			if ( returnValue ) then
				for k,vehicle in ipairs(getElementsByType"vehicle") do
					makeVehicleStatic(vehicle)
				end
				loadedMap = returnValue
				editor_gui.closeLoadDialog()
			else
				editor_gui.guiShowMessageBox ( "Map resource could not be started!", "error", "Error", true )
			end
		elseif ( command ) == "save" then
			if ( returnValue ) then
				loadedMap = returnValue2
				editor_gui.closeSaveDialog()
			else
				editor_gui.guiShowMessageBox ( "Map resource could not be saved! "..reason, "error", "Error", true )
				editor_gui.restoreSaveDialog()
			end	
		elseif ( command ) == "quickSave" then
			reason = reason or "The target resource may be in .zip format or corrupted."
			editor_gui.guiShowMessageBox ( "Map resource could not be saved! "..reason, "error", "Error", true )
			editor_gui.restoreSaveDialog()
		elseif ( command ) == "test" then
			reason = reason or ""
			editor_gui.guiShowMessageBox ( "Test could not be started! "..reason, "error", "Error", true )
			editor_gui.stopTest()
		end
	end
)

function saveResource ( resourceName )
	triggerServerEvent ( "saveResource", getLocalPlayer(), resourceName )
end

function newResource ()
	triggerServerEvent("newResource",getLocalPlayer())
end
