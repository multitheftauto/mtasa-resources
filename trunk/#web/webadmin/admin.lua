-- ACLs
function getACLs()
	local tbl = {}
	local acls = aclList()
	for k,v in ipairs(acls) do
		local tblRights = {}
		local rights = aclListRights (v)
		for l,w in ipairs(rights) do
			table.insert(tblRights, {name=w, access=aclGetRight(v,w)})
		end
		table.insert(tbl, {name=aclGetName(v), rights=tblRights})
	end
	return tbl
end

function setACLRight( aclname, rightname, access )
	local acl = aclGet(aclname)
	if ( acl ) then
		if ( aclSetRight ( acl, rightname, access ) ) then
			if ( aclSave() ) then
				return true
			end
		end 
	end
	return false
end

function removeACLRight ( aclname, rightname )
	local acl = aclGet ( aclname )
	if ( acl ) then
		if ( aclRemoveRight ( acl, rightname ) ) then
			if ( aclSave () ) then
				return true
			end
		end
	end
	return false
end

function createACL ( aclname )
	if ( aclCreate ( aclname ) ~= false ) then
		if ( aclSave () ) then
			return true;
		end
	end
	return false
end

function removeACL ( aclname )
	local acl = aclGet ( aclname )
	if ( acl ) then
		if ( aclDestroy ( acl ) ) then
			if ( aclSave() ) then
				return true
			end
		end
	end
	return false
end

-- GROUPS
function getGroups()
	local tbl = {}
	local acls = aclGroupList()
	if ( acls ) then
		for k,v in ipairs(acls) do
			
			local acltbl = {}
			local groupacls = aclGroupListACL(v)
			for l,w in ipairs(groupacls) do
				table.insert(acltbl,aclGetName(w))
			end
			table.insert(tbl, {acls=acltbl, objects=aclGroupListObjects(v), name=aclGroupGetName(v)} )
		end
	end
	return tbl
end

function addObjectToGroup(groupname, objectname)
	local aclgroup = aclGetGroup(groupname)
	if ( aclgroup ) then
		return aclGroupAddObject ( aclgroup, objectname )
	end
end

function addACLToGroup(groupname, aclname)
	local aclgroup = aclGetGroup(groupname)
	if ( aclgroup ) then
		local acl = aclGet ( aclname )
		if ( acl ) then
			return aclGroupAddACL ( aclgroup, acl )
		end
	end
end

function removeObjectFromGroup ( groupname, objectname )
	local group = aclGetGroup ( groupname )
	if ( group ) then
		if ( aclGroupRemoveObject ( group, objectname ) ) then
			if ( aclSave() ) then
				return true
			end
		end
	end
	return false
end

function removeACLFromGroup ( groupname, aclname )
	local group = aclGetGroup ( groupname )
	if ( group ) then
		local acl = aclGet(aclname)
		if ( acl ) then
			if ( aclGroupRemoveACL ( group, acl ) ) then
				if ( aclSave() ) then
					return true
				end
			end
		end
	end
	return false
end

function removeGroup ( groupname )
	local group = aclGetGroup ( groupname )
	if ( group ) then
		if ( aclDestroyGroup ( group ) ) then
			if ( aclSave() ) then
				return true
			end
		end
	end
	return false
end

function addGroup ( groupname ) 
	if ( aclCreateGroup ( groupname ) ) then
		if ( aclSave() ) then
			return true
		end
	end
	return false
end

function isAccountNameValid ( accountname )
	if ( getAccount ( accountname ) ) then
		return true
	end
	return false
end
