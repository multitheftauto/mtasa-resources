--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_ACL.lua
*
*	Original File by lil_Toady
*
**************************************]]


-- cmd: nil			- legacy call
--		"maintain"	- if enough entries are missing, add them
--		"force"		- force install or rights, as per "conf\\ACL.xml"
function aSetupACL ( cmd )
	if ( aGetSetting ( "installed" ) ) then
		if cmd ~= "maintain" and cmd ~= "force" then
			return		-- Do nothing if installed and no cmd
		end
	else
		cmd = "force"	-- Force if not installed
	end
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
		if cmd == "maintain" then
			-- Count missing rights
			local totalMissing, totalRights = 0,0
			for id, acl in ipairs ( aclList () ) do
				local aclName = aclGetName ( acl )
				local node = temp_acl_nodes[aclName] or temp_acl_nodes["Default"]
				if node then
					local missing,rights = aACLLoad ( acl, node, "countmissing" )
					totalMissing = totalMissing + missing
					totalRights = totalRights + rights
				end
			end
			if totalMissing > 0 then
				outputDebugString( "admin maintain - totalRights:" .. totalRights .. "  totalMissing:" .. totalMissing )
			end
			if totalMissing < totalRights / 2 then
				return	-- Not enough to warrent a re-add
			end
		end
		-- Add rights
		for id, acl in ipairs ( aclList () ) do
			local aclName = aclGetName ( acl )
			local node = temp_acl_nodes[aclName] or temp_acl_nodes["Default"]
			if node then
				-- Do 'addmissing' or 'addall' depending on what's required
				aACLLoad ( acl, node, cmd == "maintain" and "addmissing" or "addall" )
			end
		end
		if cmd == "maintain" then
			outputConsole ( "Admin access list successfully updated" )
		else
			outputConsole ( "Admin access list successfully installed" )
		end
	else
		outputConsole ( "Failed to install admin access list - File missing" )
	end
	aSetSetting ( "installed", true )
end

-- cmd:	"countmissing"	- count missing entries
--		"addmissing"	- add missing entries
--		"addall"		- add all entries
function aACLLoad ( acl, node, cmd )
	local missing = 0
	local rights = 0
	while ( xmlFindChild ( node, "right", rights ) ~= false ) do
		local rightNode = xmlFindChild ( node, "right", rights )
		local rightName = xmlNodeGetAttribute ( rightNode, "name" )
		local rightAccess = xmlNodeGetAttribute ( rightNode, "access" )
		if ( ( rightName ) and ( rightAccess ) ) then
			if cmd == "addall" then
				aclSetRight ( acl, rightName, rightAccess == "true" )
			else
				if not aclRightExists ( acl, rightName ) then
					missing = missing + 1
					if cmd == "addmissing" then
						aclSetRight ( acl, rightName, rightAccess == "true" )
					end
				end
			end
		end
		rights = rights + 1
	end
	return missing, rights
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

-- Command to force reinstall of rights for the admin panel
addCommandHandler ( "adminreinstall",
	function(source)
		if ( hasObjectPermissionTo ( source, "function.aclSetRight" ) ) then
			aSetupACL( "force" )
		end
	end
)
