--
-- Anti-Cheat Control Panel
--
-- s_img_mod.lua
--


addEventHandler( "onPlayerModInfo", root,
function ( filename, modList )
	local player = source
	for _,mod in ipairs(modList) do			-- Check each modified item
		if isImgModBlocked( mod.name ) then
			local msg = "Modified " .. mod.name .. " in " .. filename .. " not allowed"
			kickPlayer( source, msg )
			--outputDebug( msg )
			return
		end
	end

	-- Get list of modified player models
	local modifiedPlayerModels = {}
	if get("*switchplayermodels") == "true" and filename == "gta3.img" then
		for _,mod in ipairs(modList) do
			if tonumber(mod.id) < 313 and string.find(mod.name, ".dff") then
				table.insert(modifiedPlayerModels, tonumber(mod.id))
			end
		end
		if #modifiedPlayerModels > 0 then
			triggerClientEvent(player, "acpanel.gotModifiedPlayerModelsList", player, modifiedPlayerModels)
		end
	end
end
)


addEventHandler ( "onResourceStart", resourceRoot,
	function ()
		for _,plr in ipairs(getElementsByType("player")) do
			resendPlayerModInfo(plr)
		end
	end
)


function isImgModBlocked( name )
	local defText = getBlockDefText()

	local type = getPanelSetting( "blockmods.type" )
	--outputDebug( "Checking " .. name .. " against type " .. tostring(type) )
	--outputDebug( tostring(defText) )

	local lineList = split(defText,"\n")
	for _,line in ipairs(lineList) do
		local line = string.gsub(line, "\r", "")
		--outputDebug( "Checking " .. name .. " against line " .. tostring(line) )
		if line == "*" or string.find(name,line) then
			return true
		end
	end
	return false
end


function getBlockDefText()
	local type = getPanelSetting( "blockmods.type" )
	local info = aBlockModsTab.getInfoForType( type )
	if info.custom then
		return getPanelSetting( "blockmods.customText" )
	else
		return info.text
	end
end

