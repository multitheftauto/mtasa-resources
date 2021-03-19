--
-- Anti-Cheat Control Panel
--
-- s_main.lua
--

local wasAllowedList = {}

addEventHandler ( "onResourceStart", resourceRoot,
	function ()
		doesResourceHasPermissions()
		for _,plr in ipairs(getElementsByType("player")) do
			updatePlayer(plr)
		end
	end
)

addEventHandler ( "onPlayerJoin", root,
	function ()
		updatePlayer(source)
	end
)

addEventHandler ( "onPlayerQuit", root,
	function ()
		wasAllowedList[source] = nil
	end
)

addEventHandler ( "onPlayerLogin", root,
	function ()
		updatePlayer(source)
	end
)

addEventHandler ( "onPlayerLogout", root,
	function ()
		updatePlayer(source)
	end
)


function updatePlayer(player)
	local oldAllowed = wasAllowedList[player]
	local newAllowed = isPlayerAllowedHere(player)
	wasAllowedList[player] = newAllowed

	if newAllowed and not oldAllowed then
		bindKey( player, "o", "down", "Show_AC_Panel" )
		outputChatBox ( "Press 'o' to open your AC panel", player )
		if not bAllowGui then return end
		sendAllSettingsToClient()
		triggerClientEvent(player, 'onAcpClientInitialSettings', resourceRoot, getServerConfigSettingsToTransfer() )
	elseif not newAllowed and oldAllowed then
		triggerClientEvent(player, 'aClientAcMenu', resourceRoot, "close" )
		unbindKey( player, "o", "down", "Show_AC_Panel" )
	end
end

function showACPanel(player)
	if not isPlayerAllowedHere(player) then return false end
	if not doesResourceHasPermissions() then return end
	triggerClientEvent(player, 'aClientAcMenu', resourceRoot, "toggle" )
end
addCommandHandler('acp',showACPanel)
addCommandHandler('Show_AC_Panel',showACPanel)


function getServerConfigSettingsToTransfer()
	local result = {}
	local settingNameList = { "disableac", "enablesd", "verifyclientsettings" }
	for _,name in ipairs(settingNameList) do
		local value = getServerConfigSetting(name)
		result[name] = value
	end

	local verifyFlags = getServerConfigSetting( "verifyclientsettings" )

	verifyFlags = -1-verifyFlags

	local stringresult = ""
	for i=1,32 do
		local isset = math.hasbit(verifyFlags, math.bit(i))
		stringresult = stringresult .. ( isset and "1" or "0" )
	end

	result["verifyclientsettingsstring"] = stringresult

	return result
end


--------------------------------------------------------------------
-- Check this resource can do stuff
--------------------------------------------------------------------
function doesResourceHasPermissions()
	if hasObjectPermissionTo( getThisResource(), "function.kickPlayer" ) and
	   hasObjectPermissionTo( getThisResource(), "function.setServerConfigSetting" ) and
	   hasObjectPermissionTo( getThisResource(), "function.fetchRemote" ) then
		bResourceHasPermissions = true
	end

	if not bDoneFirstCheck then
		bDoneFirstCheck = true
		if bResourceHasPermissions then
			bAllowGui = true
			return true
		end
	end

	if bAllowGui then
		return true
	end

	if not bResourceHasPermissions then
		outputChatBox( "AC Panel can not start until this command is run:" )
		outputChatBox( "aclrequest allow acpanel all" )
	else
		outputChatBox( "Please restart AC Panel" )
	end
	return false
end


--------------------------------------------------------------------
-- Check player can do stuff
--------------------------------------------------------------------
function isPlayerAllowedHere(player)
	local admingroup = get("admingroup") or "Admin"
	if not isPlayerInACLGroup(player, tostring(admingroup) ) then
		return false
	end
	return true
end

function isPlayerInACLGroup(player, groupName)
	local account = getPlayerAccount(player)
	if not account then
		return false
	end
	local accountName = getAccountName(account)
	for _,name in ipairs(split(groupName,',')) do
		local group = aclGetGroup(name)
		if group then
			for i,obj in ipairs(aclGroupListObjects(group)) do
				if obj == 'user.' .. accountName or obj == 'user.*' then
					return true
				end
			end
		end
	end
	return false
end
