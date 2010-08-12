local screenX,screenY = guiGetScreenSize()
local bgWidth,bgHeight = 100, 20

--Robbed from arc_
function msToTimeStr(ms,showCS)
	if not ms then
		return ''
	end
	if ms < 0 then
		if showCS then
			return "0:00:00"
		else 
			return "0:00"
		end
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
	
	if showCS then
		return minutes .. ':' .. seconds .. ':' .. centiseconds
	else
		return minutes .. ':' .. seconds
	end
end


addEventHandler ( "onClientRender", rootElement,
	function()
		for timer,data in pairs(missionTimers) do
			local msPassed = 0
			
			if not data.frozen then
				msPassed = getTickCount() - data.originalTick
			else
				msPassed = data.duration
			end
			
			local color = tocolor(255,255,255,255)
			if data.countdown then
				if not data.frozen then
					msPassed = data.duration - msPassed
				end
				if msPassed <= data.hurrytime then
					color = tocolor ( 255,0,0,255 )
				end
			end
			local x,y = toposition(data.x,data.y)
			local scale = data.scale or 1
			if data.bg then
				local width,height = bgWidth*scale,bgHeight*scale
				dxDrawImage ( x-width*0.5, y-height*0.5, width, height, "timeleft.png" )
			end
			dxDrawText ( msToTimeStr(msPassed,data.showCS), 
				x, 
				y, 
				x, 
				y, 
				color, 
				scale, 
				data.font or "default-bold", 
				"center", 
				"center" )
		end
	end
)


function toposition(x,y)
	local finalX,finalY = x,y
	if x > 1 then --Is X bigger than 1?  If so we've got an absolute position
		finalX = x
	elseif x < -1 then --We have a reversed absolute position
		finalX = screenX + x
	elseif x > 0 then --We have a relative position
		finalX = screenX * x
	else --We have a reversed relative position
		finalX = screenX - (screenX * x)
	end
	--
	if y > 1 then --Is Y bigger than 1?  If so we've got an absolute position
		finalY = y
	elseif y < -1 then --We have a reversed absolute position
		finalY = screenY + y
	elseif x > 0 then --We have a relative position
		finalY = screenY * y
	else --We have a reversed relative position
		finalY = screenY - (screenY * y)
	end
	return finalX,finalY
end
