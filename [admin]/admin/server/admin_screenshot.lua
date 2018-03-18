--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_screenshot.lua
*
*	Original File by MCvarial
*
**************************************]]

local con = dbConnect("sqlite", ":/registry.db")
dbExec(con, "CREATE TABLE IF NOT EXISTS `admin_screenshots` (`id` INTEGER, `player` TEXT, `serial` TEXT, `admin` TEXT, `realtime` TEXT)")
local screenshots = {}
local currentid = 0

addEventHandler("onResourceStart", resourceRoot, function()
	dbQuery(resourceStartedCallback, {}, con, "SELECT `id` FROM `admin_screenshots`")
end
)

function resourceStartedCallback(qh)
	local result = dbPoll(qh, 0)
	for i, screenshot in ipairs(result) do
		if screenshot.id > currentid then
			currentid = screenshot.id
		end
	end
end

addEvent("aScreenShot",true)
addEventHandler("aScreenShot",resourceRoot,
	function (action,admin,player,arg1,arg2)
		if not isElement(admin) then return end
		if not hasObjectPermissionTo(admin,"command.takescreenshot") then return end
		if action == "new" then
			if not isElement(player) then return end
			if screenshots[player] then
				table.insert(screenshots[player].admins,admin)
			else
				local t = getRealTime()
				screenshots[player] = {player=player,admin=getPlayerName(admin),admins={admin},realtime=t.monthday.."/"..(t.month+1).."/"..(t.year+1900).." "..t.hour..":"..t.minute..":"..t.second}
				takePlayerScreenShot(player,800,600,getPlayerName(player))
				triggerClientEvent(admin,"aClientScreenShot",resourceRoot,"new",player)
			end
		elseif action == "list" then
			dbQuery(clientScreenShotCallback, {admin}, con, "SELECT `id`,`player`,`admin`,`realtime` FROM `admin_screenshots`")
		elseif action == "delete" then
			if fileExists("screenshots/"..player..".jpg") then
				fileDelete("screenshots/"..player..".jpg")
			end
			dbExec(con, "DELETE FROM `admin_screenshots` WHERE `id`=?", player)
		elseif action == "view" then
			if fileExists("screenshots/"..player..".jpg") then
				local file = fileOpen("screenshots/"..player..".jpg")
				local imagedata = fileRead(file,fileGetSize(file))
				fileClose(file)
				triggerClientEvent(admin,"aClientScreenShot",resourceRoot,"new",arg1)
				triggerLatentClientEvent(admin,"aClientScreenShot",resourceRoot,"view",arg1,imagedata)
			end
		end
	end
)

function clientScreenShotCallback(qh, admin)
	local result = dbPoll(qh, 0)
	if (not isElement(admin)) then return end
	triggerClientEvent(admin, "aClientScreenShot", resourceRoot, "list", nil, result)
end

addEventHandler("onPlayerScreenShot",root,
	function (resource,status,imagedata,timestamp,tag)
		if resource == getThisResource() then
			local screenshot = screenshots[source]
			if not screenshot then return end
			if status == "ok" then
				currentid = currentid + 1
				dbExec(con, "INSERT INTO `admin_screenshots`(`id`,`player`,`serial`,`admin`,`realtime`) VALUES(?,?,?,?,?)",currentid,getPlayerName(source),getPlayerSerial(source),screenshot.admin,screenshot.realtime)
				if fileExists("screenshots/"..currentid..".jpg") then
					fileDelete("screenshots/"..currentid..".jpg")
				end
				local file = fileCreate("screenshots/"..currentid..".jpg")
				fileWrite(file,imagedata)
				fileClose(file)
				for i,admin in ipairs (screenshot.admins) do
					if isElement(admin) then
						triggerLatentClientEvent(admin,"aClientScreenShot",resourceRoot,"view",source,imagedata,screenshot.admin,screenshot.realtime,currentid)
					end
				end
			else
				for i,admin in ipairs (screenshot.admins) do
					if isElement(admin) then
						triggerClientEvent(admin,"aClientScreenShot",resourceRoot,status,source)
					end
				end
			end
			screenshots[source] = nil
		end
	end
)

addEventHandler("onPlayerQuit",root,
	function ()
		if screenshots[source] then
			for i,admin in ipairs (screenshots[source].admins) do
				triggerClientEvent(admin,"aClientScreenShot",resourceRoot,"quit",source)
			end
			screenshots[source] = nil
		end
	end
)
