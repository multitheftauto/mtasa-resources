--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_screenshot.lua
*
*	Original File by MCvarial
*
**************************************]]

aScreenShotWindows = {}
aScreenShotForm = nil

function aPlayerScreenShot (player)
	if aScreenShotForm == nil then
		local x,y = guiGetScreenSize()
		aScreenShotForm		= guiCreateWindow	( x / 2 - 300, y / 2 - 125, 600, 250, "Screenshot Management", false )
		aScreenShotList		= guiCreateGridList	( 0.03, 0.08, 0.70, 0.90, true, aScreenShotForm )
		aScreenShotNew		= guiCreateButton	( 0.75, 0.08, 0.42, 0.09, "Take New", true, aScreenShotForm )
		aScreenShotDelete	= guiCreateButton	( 0.75, 0.18, 0.42, 0.09, "Delete", true, aScreenShotForm )
		aScreenShotView		= guiCreateButton	( 0.75, 0.28, 0.42, 0.09, "View", true, aScreenShotForm )
		aScreenShotRefresh	= guiCreateButton	( 0.75, 0.38, 0.42, 0.09, "Refresh", true, aScreenShotForm )
		aScreenShotClose	= guiCreateButton	( 0.75, 0.88, 0.42, 0.09, "Close", true, aScreenShotForm )
		guiGridListAddColumn(aScreenShotList,"Player",0.31 )
		guiGridListAddColumn(aScreenShotList,"Admin",0.31 )
		guiGridListAddColumn(aScreenShotList,"Date",0.27 )
		addEventHandler("onClientGUIClick",aScreenShotForm,aScreenShotsClick)
		addEventHandler("onClientGUIDoubleClick",aScreenShotForm,aScreenShotsDoubleClick)
		aRegister("PlayerScreenShot",aScreenShotForm,aPlayerScreenShot,aPlayerScreenShotClose)
	end
	guiSetVisible(aScreenShotForm,true)
	guiBringToFront(aScreenShotForm)
	aScreenShotsRefresh()
end

function aScreenShotsRefresh ()
	if aScreenShotList then
		guiGridListClear(aScreenShotList)
		triggerServerEvent("aScreenShot",resourceRoot,"list",localPlayer)
	end
end

function aPlayerScreenShotClose ()
	if ( aScreenShotForm ) then
		removeEventHandler ( "onClientGUIClick", aScreenShotForm, aScreenShotsClick )
		removeEventHandler ( "onClientGUIDoubleClick", aScreenShotForm, aScreenShotsDoubleClick )
		destroyElement ( aScreenShotForm )
		aScreenShotForm,aScreenShotList,aScreenShotNew,aScreenShotDelete,aScreenShotView,aScreenShotRefresh,aScreenShotClose,aScreenShotForm = nil,nil,nil,nil,nil,nil,nil,nil
	end
end

function aScreenShotsDoubleClick (button)
	if button == "left" then
		if source == aScreenShotList then
			local row = guiGridListGetSelectedItem(aScreenShotList)
			if row ~= -1 then
				triggerServerEvent("aScreenShot",resourceRoot,"view",localPlayer,guiGridListGetItemData(aScreenShotList,row,1),guiGridListGetItemText(aScreenShotList,row,1))
			end
		end
	end
end

function aScreenShotsClick (button)
	if button == "left" then
		if source == aScreenShotClose then
			aPlayerScreenShotClose()
		elseif source == aScreenShotNew then
			if guiGridListGetSelectedItem(aTab1.PlayerList ) == -1 then
				aMessageBox("error","No player selected!")
			else
				local name = guiGridListGetItemPlayerName(aTab1.PlayerList,guiGridListGetSelectedItem(aTab1.PlayerList),1)
				triggerServerEvent("aScreenShot",resourceRoot,"new",localPlayer,getPlayerFromNick(name))
			end
		elseif source == aScreenShotDelete then
			local row = guiGridListGetSelectedItem ( aScreenShotList )
			if row ~= -1 then
				triggerServerEvent("aScreenShot",resourceRoot,"delete",localPlayer,guiGridListGetItemData(aScreenShotList,row,1))
				guiGridListRemoveRow(aScreenShotList,row)
			end
		elseif source == aScreenShotRefresh then
			aScreenShotsRefresh()
		elseif source == aScreenShotView then
			local row = guiGridListGetSelectedItem(aScreenShotList)
			if row ~= -1 then
				triggerServerEvent("aScreenShot",resourceRoot,"view",localPlayer,guiGridListGetItemData(aScreenShotList,row,1),guiGridListGetItemText(aScreenShotList,row,1))
			end
		else
			for player,gui in pairs (aScreenShotWindows) do
				if gui.button == source or source == gui.screenshot then
					destroyElement(gui.window)
					aScreenShotWindows[player] = nil
				end
			end
		end
	end
end

addEvent("aClientScreenShot",true)
addEventHandler("aClientScreenShot",resourceRoot,
	function (action,player,data,arg1,arg2,arg3)
		if action == "new" then
			local title
			if type(player) == "string" then
				title = player
			elseif isElement(player) then
				title = getPlayerName(player)
			else
				return
			end
			local x, y = guiGetScreenSize()
			aScreenShotWindows[player] = {}
			aScreenShotWindows[player].window = guiCreateWindow((x/2)-400,(y/2)-300,800,600,title,false)
			aScreenShotWindows[player].label = guiCreateLabel(0,0,1,1,"Loading...",true,aScreenShotWindows[player].window)
			aScreenShotWindows[player].button = guiCreateButton(0.93,0.95,0.6,0.4,"Close",true,aScreenShotWindows[player].window)
			addEventHandler ( "onClientGUIClick", aScreenShotWindows[player].button, aScreenShotsClick )
			guiLabelSetHorizontalAlign(aScreenShotWindows[player].label,"center")
			guiLabelSetVerticalAlign(aScreenShotWindows[player].label,"center")
		elseif action == "list" then
			if not isElement(aScreenShotList) then return end
			guiGridListClear ( aScreenShotList )
			for i,screenshot in ipairs (data) do
				local row = guiGridListAddRow(aScreenShotList)
				guiGridListSetItemText(aScreenShotList,row,1,screenshot.player,false,false)
				guiGridListSetItemText(aScreenShotList,row,2,screenshot.admin,false,false)
				guiGridListSetItemText(aScreenShotList,row,3,screenshot.realtime,false,false)
				guiGridListSetItemData(aScreenShotList,row,1,screenshot.id)
			end
		else
			if not aScreenShotWindows[player] or not isElement(aScreenShotWindows[player].window) then return end
			if action == "view" then
				local time = tostring(getRealTime().timestamp)
				local file = fileCreate("screenshots/"..time..".jpg")
				fileWrite(file,data)
				fileClose(file)
				aScreenShotWindows[player].screenshot = guiCreateStaticImage(0,0,1,1,"screenshots/"..time..".jpg",true,aScreenShotWindows[player].window)
				addEventHandler ( "onClientGUIClick", aScreenShotWindows[player].screenshot, aScreenShotsClick )
				guiBringToFront(aScreenShotWindows[player].button)
				if isElement(player) and isElement(aScreenShotList) then
					local row = guiGridListAddRow(aScreenShotList)
					guiGridListSetItemText(aScreenShotList,row,1,getPlayerName(player),false,false)
					guiGridListSetItemText(aScreenShotList,row,2,arg1,false,false)
					guiGridListSetItemText(aScreenShotList,row,3,arg2,false,false)
					guiGridListSetItemData(aScreenShotList,row,1,arg3)
				end
			elseif action == "minimized" then
				guiSetText(aScreenShotWindows[player].label,"Player is minimized, try again later")
			elseif action == "disabled" then
				guiSetText(aScreenShotWindows[player].label,"Player does not allow taking screenshots")
			elseif action == "quit" then
				guiSetText(aScreenShotWindows[player].label,"Player has quit")
			end
		end
	end
)
