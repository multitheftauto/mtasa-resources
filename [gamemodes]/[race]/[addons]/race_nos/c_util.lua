local DEBUG = true
local rootElement = getRootElement()
local resName = getResourceName(getThisResource())

local c_DefaultPopupTimeout = 5000 --ms
local c_FadeDelta = .03 --alpha per frame
local c_MaxAlpha = .9

local function fadeIn(wnd)
	local function raiseAlpha()
		local newAlpha = guiGetAlpha(wnd) + c_FadeDelta
		if newAlpha <= c_MaxAlpha then
			guiSetAlpha(wnd, newAlpha)
		else
			removeEventHandler("onClientRender", rootElement, raiseAlpha)
		end
	end
	addEventHandler("onClientRender", rootElement, raiseAlpha)
end

local function fadeOut(wnd)
	local function lowerAlpha()
		local newAlpha = guiGetAlpha(wnd) - c_FadeDelta
		if newAlpha >= 0 then
			guiSetAlpha(wnd, newAlpha)
		else
			removeEventHandler("onClientRender", rootElement, lowerAlpha)
			destroyElement(wnd)
		end
	end
	addEventHandler("onClientRender", rootElement, lowerAlpha)
end

function outputGuiPopup(text, timeout)
	local screenX, screenY = guiGetScreenSize()
	local width = 500
	local height = 20
	local wndPopup = guiCreateWindow((screenX - width) / 2, screenY - height, width, height, '', false)
	
	guiSetAlpha(wndPopup, 0)
	guiSetFont(wndPopup, "clear-normal")
	guiSetText(wndPopup, text)
	
	guiWindowSetMovable(wndPopup, false)
	guiWindowSetSizable(wndPopup, false)
	
	fadeIn(wndPopup)
	setTimer(fadeOut, timeout or c_DefaultPopupTimeout, 1, wndPopup)
end


---- FPS 

FPSMax = 1
FPSAvg = 1
FPSCalc = 0
FPSTime = getTickCount() + 1000
AVGTbl = {}
val = 1

function CalcFps( )
	if (getTickCount() < FPSTime) then
		FPSCalc = FPSCalc + 1
	else
		if (FPSCalc > FPSMax) then
			FPSMax = FPSCalc
		end
		if val == 101 then val = 1 end
		AVGTbl[val] = FPSCalc
		FPSAvg = 0
		for k,v in pairs(AVGTbl) do
			FPSAvg = FPSAvg + v
		end
		FPSAvg = math.floor(FPSAvg / #AVGTbl)
		FPSCalc = 0
		FPSTime = getTickCount() + 1000
		val = val + 1
	end
end


function GetCurrentFps()
	return FPSCalc
end


function GetAverageFps()
	return FPSAvg
end


--
-- DEBUG
--
function alert(message, channel)
	if not DEBUG then return end

	message = resName..": "..tostring(message)

	if channel == "console" then
		outputConsole(message)
		return
	end
	
	if channel == "chat" then
		outputChatBox(message)
		return
	end
	
	outputDebugString(message)
end
