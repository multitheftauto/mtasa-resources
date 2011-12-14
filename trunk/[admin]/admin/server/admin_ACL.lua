--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_ACL.lua
*
*	Original File by lil_Toady
*
**************************************]]

function aSetupACL ()
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
		-- Add missing rights
		local totalAdded = 0
		for id, acl in ipairs ( aclList () ) do
			local aclName = aclGetName ( acl )
			if string.sub(aclName,1,8) ~= "autoACL_" then
				local node = temp_acl_nodes[aclName] or temp_acl_nodes["Default"]
				if node then
					totalAdded = totalAdded + aACLLoad ( acl, node )
				end
			end
		end
		if totalAdded > 0 then
			outputServerLog ( "Admin access list successfully updated " )
			outputConsole ( "Admin access list successfully updated " )
			outputDebugString ( "Admin added " .. totalAdded .. " missing rights" )
		end
		xmlUnloadFile ( node )
	else
		outputServerLog ( "Failed to install admin access list - File missing" )
		outputConsole ( "Failed to install admin access list - File missing" )
	end
end

function aACLLoad ( acl, node )
	local added = 0
	local rights = 0
	while ( xmlFindChild ( node, "right", rights ) ~= false ) do
		local rightNode = xmlFindChild ( node, "right", rights )
		local rightName = xmlNodeGetAttribute ( rightNode, "name" )
		local rightAccess = xmlNodeGetAttribute ( rightNode, "access" )
		if ( ( rightName ) and ( rightAccess ) ) then
			-- Add if missing from this acl
			if not aclRightExists ( acl, rightName ) then
				aclSetRight ( acl, rightName, rightAccess == "true" )
				added = added + 1
			end
		end
		rights = rights + 1
	end
	return added
end

_hasObjectPermissionTo = hasObjectPermissionTo
function hasObjectPermissionTo ( object, action )
	if ( ( isElement ( object ) ) and ( getElementType ( object ) == "player" ) ) then
		if ( aclGetAccount ( object ) ) then
			return _hasObjectPermissionTo ( aclGetAccount ( object ), action )
		end
	else
		return _hasObjectPermissionTo ( object, action )
	end
	return false
end

function aclGetAccount ( player )
	local account = getPlayerAccount ( player )
	if ( isGuestAccount ( account ) ) then return false
	else return "user."..getAccountName ( account ) end
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

function aclRightExists( acl, right )
	for _,name in ipairs( aclListRights( acl ) ) do
		if name == right then
			return true
		end
	end
	return false
end
