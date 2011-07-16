--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_ACL.lua
*
*	Original File by lil_Toady
*
**************************************]]

ACLCommands = {}

function aSetupACL ()
	if ( aGetSetting ( "installed" ) ) then return end
	local temp_acl_nodes = {}
	local node = xmlLoadFile ( "conf\\ACL.xml" )
	if ( node ) then
		--Get ACLs
		local acls = 0
		while ( xmlFindChild ( node, "acl", acls ) ~= false ) do
			local aclNode = xmlFindChild ( node, "acl", acls )
			local aclName = xmlNodeGetAttribute ( aclNode, "name" )
			if ( ( aclNode ) and ( aclName ) ) then
				temp_acl_nodes[aclName] = aclNode
			end
			acls = acls + 1
		end
		for id, acl in ipairs ( aclList () ) do
			local aclName = aclGetName ( acl )
			if ( temp_acl_nodes[aclName] ) then
				aACLLoad ( acl, temp_acl_nodes[aclName] )
			elseif ( temp_acl_nodes["Default"] ) then
				aACLLoad ( acl, temp_acl_nodes["Default"] )
			end
		end
		outputConsole ( "Admin access list successfully installed" )
	else
		outputConsole ( "Failed to install admin access list - File missing" )
	end
	aSetSetting ( "installed", true )
end

function aACLLoad ( acl, node )
	local rights = 0
	while ( xmlFindChild ( node, "right", rights ) ~= false ) do
		local rightNode = xmlFindChild ( node, "right", rights )
		local rightName = xmlNodeGetAttribute ( rightNode, "name" )
		local rightAccess = xmlNodeGetAttribute ( rightNode, "access" )
		if ( ( rightName ) and ( rightAccess ) ) then
			if ( rightAccess == "true" ) then rightAccess = true
			else rightAccess = false end
			aclSetRight ( acl, rightName, rightAccess )
			if ( string.find ( rightName, "command." ) ) then
				local command = string.gsub ( rightName, "command.", "" )
				table.insert ( ACLCommands, command )
			end
		end
		rights = rights + 1
	end
end

function aclGetAccountGroups ( account )
	local acc = getAccountName ( account )
	if ( not acc ) then return false end
	local res = {}
	acc = "user."..acc
	local all = "user.*"
	for ig, group in ipairs ( aclGroupList() ) do
		for io, object in ipairs ( aclGroupListObjects ( group ) ) do
			if ( ( acc == object ) or ( all == object ) ) then
				table.insert ( res, aclGroupGetName ( group ) )
				break
			end
		end
	end
	return res
end