local g_screenX,g_screenY = guiGetScreenSize()
local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement(getThisResource())
local g_Me = getLocalPlayer()

local DISTANCE_FRONT_BEHIND = 0.03
local TIME_TO_DISPLAY = 2000
local SCALE = 1
if g_screenY > 768 then SCALE = 1.5 end

local frontTick
local behindTick
local delayDisplayFront = dxText:create("", 0.5, 0.87, true, "default-bold", SCALE)
local delayDisplayBehind = dxText:create("", 0.5, 0.93, true, "default-bold", SCALE)
delayDisplayFront:color(248,28,11)
delayDisplayBehind:color(80,233,11)
delayDisplayFront:type("shadow",1)
delayDisplayBehind:type("shadow",1)
delayDisplayFront:colorCode(true)
delayDisplayBehind:colorCode(true)

addEvent("showDelay", true)
addEventHandler("showDelay", g_Root,
	function(delayTime, optional)
		if tonumber(optional) then
			local cps = getElementData(g_Me, "race.checkpoint") - optional
			if cps < 2 then
				cps = ""
			else
				cps = "(-"..cps.."CPs) "
			end
			delayDisplayBehind:text("-"..msToTime(delayTime).." "..cps.."#FFFFFF"..addTeamColor(source))
			delayDisplayBehind:visible(true)
			behindTick = getTickCount()
			setTimer(hideDelayDisplay, TIME_TO_DISPLAY, 1, false)
		elseif type(optional) == "table" then
			if delayTime < 0 then
				-- outputChatBox("-"..msToTimeStr(-delayTime).." current record")
				delayDisplayFront:text("+"..msToTime(-delayTime).." record #"..optional[1])
				delayDisplayFront:color(255, 255, 0)
			elseif delayTime > 0 then
				-- outputChatBox("+"..msToTimeStr(delayTime).." current record")
				delayDisplayFront:text("-"..msToTime(delayTime).." record #"..optional[1])
				delayDisplayFront:color(0, 255, 255)
			end
			delayDisplayFront:visible(true)
			frontTick = getTickCount()
			setTimer(hideDelayDisplay, TIME_TO_DISPLAY, 1, true)
		else
            local cps = getElementData(source, "race.checkpoint") - getElementData(g_Me, "race.checkpoint")
			if cps < 2 then
				cps = ""
			else
				cps = "(+"..cps.."CPs) "
			end
			delayDisplayFront:text("+"..msToTime(delayTime).." "..cps.."#FFFFFF"..addTeamColor(source))
			delayDisplayFront:color(248,28,11)
			delayDisplayFront:visible(true)
			frontTick = getTickCount()
			setTimer(hideDelayDisplay, TIME_TO_DISPLAY, 1, true)
		end
	end
)

function hideDelayDisplay(front)
	if front == "both" then
		delayDisplayFront:visible(false)
		delayDisplayBehind:visible(false)
	elseif front then
		local pastTime = getTickCount() - frontTick
		if pastTime >= TIME_TO_DISPLAY then
			delayDisplayFront:visible(false)
		else
			if pastTime < 50 then pastTime = 50 end
			setTimer(hideDelayDisplay, pastTime, 1, true)
			-- outputChatBox("front dalassen")
		end
	else
		local pastTime = getTickCount() - behindTick
		if pastTime >= TIME_TO_DISPLAY then
			delayDisplayBehind:visible(false)
		else
			if pastTime < 50 then pastTime = 50 end
			setTimer(hideDelayDisplay, pastTime, 1, false)
			-- outputChatBox("behind dalassen")
		end
	end
end

addEventHandler('onClientResourceStart', g_ResRoot,
	function()
		local settingsFile = xmlLoadFile("settings.xml")
		if settingsFile then
			local pos = xmlNodeGetAttributes(settingsFile)
			delayDisplayFront:position(pos.x, pos.y - DISTANCE_FRONT_BEHIND)
			delayDisplayBehind:position(pos.x, pos.y + DISTANCE_FRONT_BEHIND)
		else
			settingsFile = xmlCreateFile("settings.xml","settings")
			xmlNodeSetAttribute(settingsFile,"x",0.5)
			xmlNodeSetAttribute(settingsFile,"y",0.9)
		end
		xmlSaveFile(settingsFile)
		xmlUnloadFile(settingsFile)
	end
)

addCommandHandler("setdelaypos",
	function(cmd,x,y)
		if x and y then
			if tonumber(x) and tonumber(y) then
				delayDisplayFront:position(x, y - DISTANCE_FRONT_BEHIND)
				delayDisplayBehind:position(x, y + DISTANCE_FRONT_BEHIND)
				delayDisplayFront:text("FRONT")
				delayDisplayBehind:text("BEHIND")
				delayDisplayFront:color(255, 0, 0)
				delayDisplayBehind:color(0, 255, 0)
				delayDisplayFront:visible(true)
				delayDisplayBehind:visible(true)
				setTimer(hideDelayDisplay, TIME_TO_DISPLAY, 1, "both")
				local settingsFile = xmlLoadFile("settings.xml")
				if settingsFile then
					xmlNodeSetAttribute(settingsFile,"x",x)
					xmlNodeSetAttribute(settingsFile,"y",y)
				end
				xmlSaveFile(settingsFile)
				xmlUnloadFile(settingsFile)
			else
				outputChatBox("WRONG PARAMETERS! Syntax is /setdelaypos x y", 255, 0, 0)
			end
		else
			outputChatBox("WRONG PARAMETERS! Syntax is /setdelaypos x y", 255, 0, 0)
		end
	end
)

function msToTimeStr(ms)
	if not ms then
		return ''
	end
	local centiseconds = tostring(math.floor(math.fmod(ms, 1000)/10))
	if #centiseconds == 1 then
		centiseconds = '0' .. centiseconds
	end
	local s = math.floor(ms / 1000)
	local seconds = tostring(math.fmod(s, 60))
	if #seconds == 1 then
		seconds = '0' .. seconds
	end
	local minutes = tostring(math.floor(s / 60))
	return minutes .. ':' .. seconds .. ':' .. centiseconds
end


-- Exported function for settings menu, KaliBwoy

function showCPDelays()
	triggerServerEvent( "onClientShowCPDelays", resourceRoot )
end

function hideCPDelays()
	triggerServerEvent( "onClientHideCPDelays", resourceRoot )
end

-------------------------------------------------------------------------------------------------------------------------
function addTeamColor(player)
	local customNick = getElementData(player, "vip.colorNick")
	if customNick then return customNick end
	local playerTeam = getPlayerTeam ( player ) 
	if ( playerTeam ) then
		local r,g,b = getTeamColor ( playerTeam )
		local n1 = toHex(r)
		local n2 = toHex(g)
		local n3 = toHex(b)
		if r <= 16 then n1 = "0"..n1 end
		if g <= 16 then n2 = "0"..n2 end
		if b <= 16 then n3 = "0"..n3 end
		return "#"..n1..""..n2..""..n3..""..getPlayerNametagText(player)
	else
		return getPlayerNametagText(player)
	end
end
-------------------------------------------------------------------------------------------------------------------------
function toHex(n)
    local hexnums = {"0","1","2","3","4","5","6","7",
                     "8","9","A","B","C","D","E","F"}
    local str,r = "",n%16
    if n-r == 0 then str = hexnums[r+1]
    else str = toHex((n-r)/16)..hexnums[r+1] end
    return str
end

function onClientResourceStart()
	showCPDelays()
end
addEventHandler("onClientResourceStart",resourceRoot,onClientResourceStart)

function msToTime(ms)
	if not ms then
		return ''
	end
local centiseconds = tostring(math.floor(math.fmod(ms, 1000)))
	if #centiseconds == 1 then
		centiseconds = '00' .. centiseconds
	elseif #centiseconds == 2 then
		centiseconds = '0' .. centiseconds
	end
local s = math.floor(ms / 1000)
local seconds = tostring(math.fmod(s, 60))
	if #seconds == 1 then
		seconds = '0' .. seconds
	end
local minutes = tostring(math.floor(s / 60))
	if #minutes == 1 then
		minutes = '' .. minutes
	end
return minutes .. ':' .. seconds .. ':' .. centiseconds
end
