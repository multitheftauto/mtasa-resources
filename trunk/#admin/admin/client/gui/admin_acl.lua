--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_acl.lua
*
*	Original File by lil_Toady
*
**************************************]]

aAclForm = nil
aAclData = {}

function aManageACL ()
	if ( aAclForm == nil ) then
		aAclData["group_objects"] = {}
		aAclData["group_acls"] = {}
		aAclData["acl_rights"] = {}
		local x, y = guiGetScreenSize()
		aAclForm		= guiCreateWindow ( x / 2 - 230, y / 2 - 250, 460, 500, "ACL Management", false )
		aACLList		= guiCreateGridList ( 0.03, 0.05, 0.50, 0.90, true, aAclForm )
					   guiGridListSetSortingEnabled ( aACLList, false )
					   guiGridListAddColumn( aACLList, "", 0.10 )
					   guiGridListAddColumn( aACLList, "", 0.85 )
		aACLCreateGroup	= guiCreateButton ( 0.55, 0.05, 0.40, 0.04, "Create group", true, aAclForm )
		aACLCreateACL		= guiCreateButton ( 0.55, 0.10, 0.40, 0.04, "Create ACL", true, aAclForm )
		aACLLabel		= guiCreateLabel ( 0.55, 0.19, 0.40, 0.04, "", true, aAclForm )
		aACLSeparator		= guiCreateStaticImage ( 0.55, 0.235, 0.40, 0.0025, "client\\images\\dot.png", true, aAclForm )
		aACLDestroyGroup	= guiCreateButton ( 0.55, 0.25, 0.40, 0.04, "Destroy group", true, aAclForm )
		aACLDestroyACL	= guiCreateButton ( 0.55, 0.25, 0.40, 0.04, "Destroy ACL", true, aAclForm )
		aACLAddObject		= guiCreateButton ( 0.55, 0.30, 0.40, 0.04, "Add Object", true, aAclForm )
		aACLRemoveObject	= guiCreateButton ( 0.55, 0.35, 0.40, 0.04, "Remove Object", true, aAclForm )
		aACLAddACL		= guiCreateButton ( 0.55, 0.40, 0.40, 0.04, "Add ACL", true, aAclForm )
		aACLRemoveACL	= guiCreateButton ( 0.55, 0.45, 0.40, 0.04, "Remove ACL", true, aAclForm )

		aACLActionLabel	= guiCreateLabel ( 0.55, 0.31, 0.40, 0.04, "", true, aAclForm )
		aACLDropCurrent	= guiCreateEdit ( 0.55, 0.35, 0.40, 0.04, "", true, aAclForm )
					   guiSetEnabled ( aACLDropCurrent, false )
		aACLDropDown		= guiCreateStaticImage ( 0.91, 0.35, 0.04, 0.04, "client\\images\\dropdown.png", true, aAclForm )
		aACLDropList		= guiCreateGridList ( 0.55, 0.35, 0.40, 0.30, true, aAclForm )
					   guiGridListAddColumn( aACLDropList, "", 0.85 )
					   guiSetVisible ( aACLDropList, false )
		aACLOk		= guiCreateButton ( 0.55, 0.40, 0.19, 0.04, "Ok", true, aAclForm )
		aACLCancel		= guiCreateButton ( 0.76, 0.40, 0.19, 0.04, "Cancel", true, aAclForm )

		aACLAddRight		= guiCreateButton ( 0.55, 0.30, 0.40, 0.04, "Add Right", true, aAclForm )
		aACLExit		= guiCreateButton ( 0.75, 0.90, 0.27, 0.04, "Close", true, aAclForm )
		aclDisplayOptions ( "", "" )

		addEvent ( "aAdminACL", true )
		addEventHandler ( "aAdminACL", getLocalPlayer(), aAdminACL )
		addEventHandler ( "onClientGUIClick", aAclForm, aClientACLClick )
		addEventHandler ( "onClientGUIDoubleClick", aAclForm, aClientACLDoubleClick )
		--Register With Admin Form
		aRegister ( "ACLManage", aAclForm, aManageACL, aACLClose )
		triggerServerEvent ( "aAdmin", getLocalPlayer(), "sync", "aclgroups" )
	end
	guiSetVisible ( aAclForm, true )
	guiBringToFront ( aAclForm )
end

function aACLClose ( destroy )
	if ( ( destroy ) or ( aPerformanceACL and guiCheckBoxGetSelected ( aPerformanceACL ) ) ) then
		if ( aAclForm ) then
			removeEventHandler ( "onClientGUIClick", aAclForm, aClientACLClick )
			removeEventHandler ( "onClientGUIDoubleClick", aAclForm, aClientACLDoubleClick )
			destroyElement ( aAclForm )
			aAclForm = nil
		end
	else
		guiSetVisible ( aAclForm, false )
	end
end

function aAdminACL ( type, acltable )
	guiGridListClear ( aACLList )
	if ( type == "aclgroups" ) then
		aAclData["viewing"] = nil
		aAclData["group_row"] = guiGridListAddRow ( aACLList )
		guiGridListSetItemText ( aACLList, aAclData["group_row"], 2, "Groups:", true, false )
		aAclData["groups"] = acltable["groups"]
		for id, name in ipairs ( acltable["groups"] ) do
			local row = guiGridListAddRow ( aACLList )
			guiGridListSetItemText ( aACLList, row, 1, "+", false, false )
			guiGridListSetItemText ( aACLList, row, 2, name, false, false )
		end
		local row = guiGridListAddRow ( aACLList )
		aAclData["acl_row"] = guiGridListAddRow ( aACLList )
		guiGridListSetItemText ( aACLList, aAclData["acl_row"], 2, "ACL:", true, false )
		aAclData["acl"] = acltable["acl"]
		for id, name in ipairs ( acltable["acl"] ) do
			local row = guiGridListAddRow ( aACLList )
			guiGridListSetItemText ( aACLList, row, 1, "+", false, false )
			guiGridListSetItemText ( aACLList, row, 2, name, false, false )
		end
		aclDisplayOptions ( "", "" )
	elseif ( type == "aclobjects" ) then
		aAclData["group_row"] = guiGridListAddRow ( aACLList )
		guiGridListSetItemText ( aACLList, aAclData["group_row"], 2, "Groups:", true, false )
		for i, group in ipairs ( aAclData["groups"] ) do
			local group_row = guiGridListAddRow ( aACLList )
			guiGridListSetItemText ( aACLList, group_row, 2, group, false, false )
			if ( group == acltable["name"] ) then
				aclDisplayOptions ( "Group", acltable["name"] )
				aAclData["objects_row"] = guiGridListAddRow ( aACLList )
				aAclData["group_objects"][group] = acltable["objects"]
				guiGridListSetItemText ( aACLList, aAclData["objects_row"], 2, "  objects:", true, false )
				for j, object in ipairs ( acltable["objects"] ) do
					local row = guiGridListAddRow ( aACLList )
					guiGridListSetItemText ( aACLList, row, 2, "  "..object, false, false )
				end
				aAclData["acls_row"] = guiGridListAddRow ( aACLList )
				aAclData["group_acls"][group] = acltable["acl"]
				guiGridListSetItemText ( aACLList, aAclData["acls_row"], 2, "  acl:", true, false )
				for j, acl in ipairs ( acltable["acl"] ) do
					local row = guiGridListAddRow ( aACLList )
					guiGridListSetItemText ( aACLList, row, 2, "  "..acl, false, false )
				end
				guiGridListSetItemText ( aACLList, group_row, 1, "-", false, false )
			else
				guiGridListSetItemText ( aACLList, group_row, 1, "+", false, false )
			end
		end
		aAclData["acl_row"] = guiGridListAddRow ( aACLList )
		guiGridListSetItemText ( aACLList, aAclData["acl_row"], 2, "ACL:", true, false )
		for id, name in ipairs ( aAclData["acl"] ) do
			local row = guiGridListAddRow ( aACLList )
			guiGridListSetItemText ( aACLList, row, 1, "+", false, false )
			guiGridListSetItemText ( aACLList, row, 2, name, false, false )
		end
	elseif ( type == "aclrights" ) then
		aAclData["viewing"] = "rights"
		aAclData["group_row"] = guiGridListAddRow ( aACLList )
		guiGridListSetItemText ( aACLList, aAclData["group_row"], 2, "Groups:", true, false )
		for id, name in ipairs ( aAclData["groups"] ) do
			local row = guiGridListAddRow ( aACLList )
			guiGridListSetItemText ( aACLList, row, 1, "+", false, false )
			guiGridListSetItemText ( aACLList, row, 2, name, false, false )
		end
		aAclData["acl_row"] = guiGridListAddRow ( aACLList )
		guiGridListSetItemText ( aACLList, aAclData["acl_row"], 2, "ACL:", true, false )
		for i, acl in ipairs ( aAclData["acl"] ) do
			local acl_row = guiGridListAddRow ( aACLList )
			guiGridListSetItemText ( aACLList, acl_row, 2, acl, false, false )
			if ( acl == acltable["name"] ) then
				aAclData["acl_rights"][acl] = acltable["rights"]
				aclDisplayOptions ( "ACL", acltable["name"] )
				aAclData["rights_row"] = guiGridListAddRow ( aACLList )
				guiGridListSetItemText ( aACLList, aAclData["rights_row"], 2, "  rights:", true, false )
				for name, access in pairs ( acltable["rights"] ) do
					local row = guiGridListAddRow ( aACLList )
					guiGridListSetItemText ( aACLList, row, 2, "  "..name, false, false )
					if guiGridListSetItemColor then
						guiGridListSetItemColor ( aACLList, row, 2, access and 0 or 255, access and 255 or 0, 0, 255)
					end
				end
				guiGridListSetItemText ( aACLList, acl_row, 1, "-", false, false )
			else
				guiGridListSetItemText ( aACLList, acl_row, 1, "+", false, false )
			end
		end
	end
end

function aClientACLDoubleClick ( button )
	if ( button == "left" ) then
		if ( source == aACLList ) then
			local row = guiGridListGetSelectedItem ( aACLList )
			if ( row ~= -1 ) then
				local clicked = guiGridListGetItemText ( aACLList, row, 2 )
				local state = guiGridListGetItemText ( aACLList, row, 1 )
				if ( row > aAclData["acl_row"] ) then
					for i, acl in ipairs ( aAclData["acl"] ) do
						if ( acl == clicked ) then
							if ( state == "-" ) then
								triggerServerEvent ( "aAdmin", getLocalPlayer(), "sync", "aclgroups" )
							else
								triggerServerEvent ( "aAdmin", getLocalPlayer(), "sync", "aclrights", clicked )
							end
							return
						end
					end
				else
					for i, group in ipairs ( aAclData["groups"] ) do
						if ( group == clicked ) then
							if ( state == "-" ) then
								triggerServerEvent ( "aAdmin", getLocalPlayer(), "sync", "aclgroups" )
							else
								triggerServerEvent ( "aAdmin", getLocalPlayer(), "sync", "aclobjects", clicked )
							end
							return
						end
					end
				end
			end
		elseif ( source == aACLDropList ) then
			local row = guiGridListGetSelectedItem ( aACLDropList )
			if ( row ~= -1 ) then
				local clicked = guiGridListGetItemText ( aACLDropList, row, 1 )
				guiSetText ( aACLDropCurrent, clicked )
				guiSetVisible ( aACLDropList, false )
			end
		end
	end
end

function aClientACLClick ( button )
	if ( source ~= aACLDropList ) then guiSetVisible ( aACLDropList, false ) end
	if ( button == "left" ) then
		if ( source == aACLExit ) then
			aACLClose ( false )
		elseif ( source == aACLCreateGroup ) then
			aInputBox ( "Create ACL Group", "Enter group name:", "", "triggerServerEvent ( \"aAdmin\", getLocalPlayer(), \"aclcreate\", \"group\", $value )" )
		elseif ( source == aACLCreateACL ) then
			aInputBox ( "Create ACL", "Enter acl name:", "", "triggerServerEvent ( \"aAdmin\", getLocalPlayer(), \"aclcreate\", \"acl\", $value )" )
		elseif ( source == aACLAddObject ) then
			aInputBox ( "Create ACL Group", "Enter object name:", "", "triggerServerEvent ( \"aAdmin\", getLocalPlayer(), \"acladd\", \"object\", \""..aAclData["current"].."\", $value )" )
		elseif ( source == aACLAddRight ) then
			aInputBox ( "Create ACL", "Enter right name:", "", "triggerServerEvent ( \"aAdmin\", getLocalPlayer(), \"acladd\", \"right\", \""..aAclData["current"].."\", $value )" )
		elseif ( source == aACLDestroyGroup ) then
			aMessageBox ( "warning", "Are you sure to destroy "..aAclData["current"].." group?", "triggerServerEvent ( \"aAdmin\", getLocalPlayer(), \"acldestroy\", \"group\", \""..aAclData["current"].."\" )" )
		elseif ( source == aACLDestroyACL ) then
			aMessageBox ( "warning", "Are you sure to destroy "..aAclData["current"].." ACL?", "triggerServerEvent ( \"aAdmin\", getLocalPlayer(), \"acldestroy\", \"acl\", \""..aAclData["current"].."\" )" )
		elseif ( ( source == aACLRemoveObject ) or ( source == aACLAddACL ) or ( source == aACLRemoveACL ) ) then
			guiSetVisible ( aACLAddObject, false )
			guiSetVisible ( aACLRemoveObject, false )
			guiSetVisible ( aACLAddACL, false )
			guiSetVisible ( aACLRemoveACL, false )
			guiSetVisible ( aACLDropCurrent, true )
			guiSetVisible ( aACLDropDown, true )
			guiSetVisible ( aACLOk, true )
			guiSetVisible ( aACLCancel, true )
			guiSetVisible ( aACLActionLabel, true )
			guiGridListClear ( aACLDropList )
			local table = {}
			guiSetText ( aACLActionLabel, guiGetText ( source )..":" )
			if ( source == aACLRemoveObject ) then table = aAclData["group_objects"][aAclData["current"]]
			elseif ( source == aACLAddACL ) then table = aAclData["acl"]
			elseif ( source == aACLRemoveACL ) then table = aAclData["group_acls"][aAclData["current"]] end
			if ( #table >= 1 ) then guiSetText ( aACLDropCurrent, table[1] ) end
			for id, object in ipairs ( table ) do
				guiGridListSetItemText ( aACLDropList, guiGridListAddRow ( aACLDropList ), 1, object, false, false )
			end
		elseif ( source == aACLDropDown ) then
			guiSetVisible ( aACLDropList, true )
			guiBringToFront ( aACLDropList )
		elseif ( source == aACLCancel ) then
			aclDisplayOptions ( aAclData["viewing"], aAclData["current"] )
		elseif ( source == aACLOk ) then
			local action = guiGetText ( aACLActionLabel )
			if ( action == "Remove Object:" ) then
				triggerServerEvent ( "aAdmin", getLocalPlayer(), "aclremove", "object", aAclData["current"], guiGetText ( aACLDropCurrent ) )
			elseif ( action == "Add ACL:" ) then
				triggerServerEvent ( "aAdmin", getLocalPlayer(), "acladd", "acl", aAclData["current"], guiGetText ( aACLDropCurrent ) )
			elseif ( action == "Remove ACL:" ) then
				triggerServerEvent ( "aAdmin", getLocalPlayer(), "aclremove", "acl", aAclData["current"], guiGetText ( aACLDropCurrent ) )
			end
		end
	end
end

function aclDisplayOptions ( state, name )
	guiSetVisible ( aACLSeparator, false )
	aAclData["viewing"] = state
	if ( state ~= "" ) then
		aAclData["current"] = name
		guiSetVisible ( aACLSeparator, true )
		guiSetText ( aACLLabel, state..": "..name )
	else
		aAclData["current"] = ""
		guiSetText ( aACLLabel, "" )
	end
	guiSetVisible ( aACLDestroyGroup, false )
	guiSetVisible ( aACLDestroyACL, false )
	guiSetVisible ( aACLAddObject, false )
	guiSetVisible ( aACLRemoveObject, false )
	guiSetVisible ( aACLAddACL, false )
	guiSetVisible ( aACLRemoveACL, false )
	guiSetVisible ( aACLAddRight, false )
	guiSetVisible ( aACLDropCurrent, false )
	guiSetVisible ( aACLDropList, false )
	guiSetVisible ( aACLDropDown, false )
	guiSetVisible ( aACLCancel, false )
	guiSetVisible ( aACLOk, false )
	guiSetVisible ( aACLActionLabel, false )
	if ( state == "ACL" ) then
		guiSetVisible ( aACLDestroyACL, true )
		guiSetVisible ( aACLAddRight, true )
	elseif ( state == "Group" ) then
		guiSetVisible ( aACLDestroyGroup, true )
		guiSetVisible ( aACLAddObject, true )
		guiSetVisible ( aACLAddACL, true )
		guiSetVisible ( aACLRemoveObject, true )
		guiSetVisible ( aACLRemoveACL, true )
	end
end