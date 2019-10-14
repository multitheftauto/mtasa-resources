function inputGui(title, desc, callback,...)
  if inputWindow then return false end
  
  local inputWindow = guiCreateWindow( 0, 0, 300, 120, title, false )
  setElementData(inputWindow, "args", {...}, false)
  -- code copied from https://wiki.multitheftauto.com/wiki/CenterWindow
  local screenW, screenH = guiGetScreenSize()
  local windowW, windowH = guiGetSize(inputWindow, false)
  local x, y = (screenW - windowW) /2,(screenH - windowH) /2
  guiSetPosition(inputWindow, x, y, false)
  --
  local labelDesc = guiCreateLabel(0.02, 0.18, 0.96, 0.2, desc, true, inputWindow )
  guiLabelSetHorizontalAlign(labelDesc, "center")
  guiLabelSetVerticalAlign(labelDesc, "center")
  inputEdit = guiCreateEdit( 0.02,0.45,0.96,0.2, "", true, inputWindow )
  local inputAccept = guiCreateButton( 0.1, 0.75, 0.35, 0.15, "Accept", true, inputWindow )
  local inputCancel = guiCreateButton( 0.55, 0.75, 0.35, 0.15, "Cancel", true, inputWindow )
	addEventHandler ( "onClientGUIWorldClick", getRootElement(), inputGuiTyping )
  addEventHandler ( "onClientGUIClick", inputAccept, function(button,state)
    callback(button, state, guiGetText(inputEdit), unpack( getElementData( getElementParent ( source ), "args" ) ) )
    inputClose()
  end,false)
  
  addEventHandler ( "onClientGUIClick", inputCancel, inputClose ,false)
	guiSetInputEnabled ( true )
end

function inputGuiTyping()
	if source == inputEdit then
		guiSetInputEnabled ( true )
	else
		guiSetInputEnabled ( false )
	end
end

function inputClose()
  destroyElement(getElementParent(source))
  inputWindow = nil
  guiSetInputEnabled ( false )
end
