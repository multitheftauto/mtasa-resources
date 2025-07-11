local totalBar = 0
local loadingBar = 0
local resX, resY = guiGetScreenSize()

addEvent ( "saveloadtest_return",true )
function openResource ( resourceName )
	triggerServerEvent ( "openResource", localPlayer, resourceName )
end

addEventHandler ( "saveloadtest_return", root,
	function ( command, returnValue, returnValue2, reason )
		reason = reason or ""
		if ( command ) == "open" then
			if ( returnValue ) then
				for k,vehicle in ipairs(getElementsByType"vehicle") do
					makeVehicleStatic(vehicle)
				end
				editor_gui.closeLoadDialog()
			else
				exports.dialogs:messageBox("Error", "Map resource could not be started!", false, "ERROR", "OK")
			end
		elseif ( command ) == "save" then
			if ( returnValue ) then
				editor_gui.closeSaveDialog()
			else
				exports.dialogs:messageBox("Error", "Map resource could not be saved! " .. reason, false, "ERROR", "OK")
				editor_gui.restoreSaveDialog()
			end
		elseif ( command ) == "quickSave" then
			reason = reason or "The target resource may be in .zip format or corrupted."
			exports.dialogs:messageBox("Error", "Map resource could not be saved! " .. reason, false, "ERROR", "OK")
			editor_gui.restoreSaveDialog()
		elseif ( command ) == "test" then
			reason = reason or ""
			exports.dialogs:messageBox("Error", "Test resource could not be started! " .. reason, false, "ERROR", "OK")
			editor_gui.stopTest()
		elseif ( command == "close" ) then
			editor_gui.closeSaveDialog()
			editor_gui.closeLoadDialog()
		end
	end
)

function saveResource ( resourceName, directory )
	triggerServerEvent ( "saveResource", localPlayer, resourceName, nil, directory )
end

function newResource ()
	triggerServerEvent("newResource",localPlayer)
end

function showProgressBar(elementsDone, elementsTotal)
	if (type(elementsDone) == "boolean") then
		removeEventHandler("onClientRender", root, drawStaticBar)
		removeEventHandler("onClientRender", root, drawLoadingBar)
		loadingBar = 0
		totalBar = 0
		return
	end
	if (elementsDone == 0) then
		addEventHandler("onClientRender", root, drawStaticBar)
		addEventHandler("onClientRender", root, drawLoadingBar)
	end
	if (elementsTotal) then
		totalBar = elementsTotal
	end
	loadingBar = ((elementsDone / totalBar) * 100) * 5.2
end
addEvent("saveLoadProgressBar", true)
addEventHandler("saveLoadProgressBar", localPlayer, showProgressBar)

function drawStaticBar()
	dxDrawRectangle((resX/2)-270, (resY/2)-22, 540.0, 44.0, tocolor(0,0,0,150), false)
	dxDrawRectangle((resX/2)-265, (resY/2)-16, 530.0, 33.0, tocolor(0,0,0,250), false)
end

function drawLoadingBar()
	dxDrawRectangle((resX/2)-261, (resY/2)-12, loadingBar, 25.0, tocolor(200,200,50,255), false)
	dxDrawText("Loading... "..(math.floor(loadingBar/5.2)).."%", (resX/2)-145, (resY/2)-15, (resY/2)-1, (resX/2)-5, tocolor(0,0,255,255),1.0,"bankgothic","left","top",false,false,false)
end
