local startx = 112
local starty = 1026
local startz = 14
local screenStartX = guiGetScreenSize()
local SPECWIDTH = screenStartX
local screenStartX = screenStartX * 0
local SPECHEIGHT = (SPECWIDTH / 16) * 7  -- height (changing requires palette adjustments too)
local screenStartY = SPECHEIGHT / 2
local BANDS = 40
local use_dx = true


local peakData, ticks, maxbpm, startTime, release, peak, peaks
function reset ( )
	peaks = {}
	for k=0, BANDS - 1 do
		peaks[k] = {}
	end
	peakData = {}
	ticks = getTickCount()
	maxbpm = 1
	bpmcount = 1
	startTime = 0
	release = { }
	peak = 0
end

addEvent("playmus", true)
addEventHandler("playmus", root, function ( url )
	if ( stream ) then
		destroyElement(stream)
	end

        -- Deal with sound
	stream = playSound3D(url, startx, starty, startz, true)
	setSoundMinDistance(stream, 1)
	setSoundMaxDistance(stream, 10000)
	setTimer(setSoundPanningEnabled, 1000, 1, stream, false)
	startTicks = getTickCount()
	ticks = getTickCount()
	reset ( )
	-- Deal with shaders

	-- Create shader
	shader_cinema, tec = dxCreateShader ( "texreptransform.fx" )
	if not shader_cinema then return end
	-- If the image is too bright, you can darken it
	-- If the image is too bright, you can darken it
	dxSetShaderValue ( shader_cinema, "gBrighten", -0.25 )
	-- Set the angle, grayscaled, rgb
	local radian=math.rad(0)
	dxSetShaderValue ( shader_cinema, "gRotAngle", radian )
	dxSetShaderValue ( shader_cinema, "gGrayScale", 0 )
	dxSetShaderValue ( shader_cinema, "gRedColor", 0 )
	dxSetShaderValue ( shader_cinema, "gGrnColor", 0 )
	dxSetShaderValue ( shader_cinema, "gBluColor", 0 )
	-- Set image alpha (1 max)
	dxSetShaderValue ( shader_cinema, "gAlpha", 1 )
	-- Set scrolling (san set negative and positive values)
	dxSetShaderValue ( shader_cinema, "gScrRig",  0)
       	dxSetShaderValue ( shader_cinema, "gScrDow", 0)
	-- Scale and offset (don't need to change that)
        dxSetShaderValue ( shader_cinema, "gHScale", 1 )
	dxSetShaderValue ( shader_cinema, "gVScale", 1 )
	dxSetShaderValue ( shader_cinema, "gHOffset", 0 )
	dxSetShaderValue ( shader_cinema, "gVOffset", 0 )
	if not shader_cinema then
		outputChatBox( "Could not create shader. Please use debugscript 3" )
		return
	else
                -- new render target slightly bigger
		tar = dxCreateRenderTarget ( SPECWIDTH, SPECHEIGHT )
		-- reduce our width
		SPECWIDTH = SPECWIDTH - 6
		-- Apply our shader to the drvin_screen texture
		engineApplyShaderToWorldTexture ( shader_cinema, "drvin_screen" )
	end
	addEventHandler("onClientRender", root, function ( )
                -- Get 2048 / 2 samples and return BANDS bars ( still needs scaling up )
		local fftData = getSoundFFTData(stream, 2048, BANDS)
		-- get our screen size
		local w, h = guiGetScreenSize()
		-- if fftData is false it hasn't loaded
		if ( fftData == false ) then
			dxDrawText("Stream not loaded yet.", w-300, h-150)
			return
		end
		-- Draw a nice now playing thingy
		if ( getSoundMetaTags(stream).stream_name ~= nil ) then
			local len = string.len(getSoundMetaTags(stream).stream_name)
			dxDrawText("Now Playing: " .. getSoundMetaTags(stream).stream_name, w-(270+(len*2.8)), h-150)
		else
			dxDrawText("Now Playing: -", w-(270), h-150)
		end
		-- Calculate our bars by the fft data
		calc ( fftData, stream )
	end)

end)
-- Util stuff
function timetostring ( input, input2 )
	local minutes = input / 60
	local seconds = input % 60
	local minutes2 = input2 / 60
	local seconds2 = input2 % 60
	return string.format("%2.2i:%2.2i", minutes2, seconds2)
end
function avg ( num )
	return maxbpm / bpmcount
end
function avg2 ( num1, num2, num )
	return (num1+num2)/num
end
function round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end
function getAverageBPM ( )
	return maxbpm / bpmcount
end
function min ( num1, num2 )
	return num1 <= num2 and num1 or num2
end
function max ( num1, num2 )
	return num1 >= num2 and num1 or num2
end
function calc ( fft, stream )
	-- Render to a render target and clear it
	dxSetRenderTarget( tar, true )

	-- Set a random seed
	math.randomseed ( getTickCount ( ) )
	-- Get our "Average" bpm
	local bpm = getSoundBPM ( stream )

	if ( bpm == false or bpm == nil or bpm == 0  ) then
		bpm = 1
	end

	local calced = {}
	local y = 0
	local bC=0
	local specbuf = 0
	local w, h = guiGetScreenSize()

	local r,g,b = 0,0,0
	local var = bpm + 37

	-- use bpm to determine r,g,b though there are better ways of doing this.
	if ( var <= 56 ) then
		r,g,b = 99, 184, 255
	end
	if ( var >= 57 and var < 83 ) then
		r,g,b = 238, 174, 238
	end
	if ( var >= 83 and var < 146 ) then
		r,g,b = 238, 174, 238
	end

	if ( var >= 146 and var < 166 ) then
		r,g,b = 99, 184, 255
	end
	if ( var > 166 and var <= 200 ) then
		r,g,b = 238, 201, 0
	end

	if ( var >= 200 ) then
		r,g,b = var, 0, 0
	end

	local tags = getSoundMetaTags(stream)
	local bSpawnParticles = true
	if ( bpm <= 1 and getSoundBPM ( stream ) == false and getSoundPosition ( stream ) <= 20 ) then
		r,g,b = 255, 255, 255
		dxDrawImage ( 0, 00, SPECWIDTH, SPECHEIGHT+100, "bg.png", 0, 0,0, tocolor(r, g, b, 255) )
		dxDrawText(string.format("Learning...", bpm), screenStartX+10, screenStartY-30, screenStartX+10, screenStartY-30, tocolor(255, 255, 255, 255 ), 1.5, "arial")
		bSpawnParticles = false
	else
		-- always make this bigger because when you tint it the image will look smaller.
		local var = 600
		local var2 = 400
		dxDrawImage ( -var2, -var, SPECWIDTH+(var2*2), SPECHEIGHT+(var*2)+100, "bg.png", 0, 0,0, tocolor(r, g, b, 255) )
	end
	local movespeed = (1 * (bpm / 180)) + 1
	local dir = bpm <= 100 and "down" or "up"
	local prevcalced = calced
        -- loop all the bands.
	for x, peak in ipairs(fft) do
		local posx = x - 1
		-- fft contains our precalculated data so just grab it.
		peak = fft [ x ]
		y=math.sqrt(peak)*3*(SPECHEIGHT-4); -- scale it (sqrt to make low values more visible)

		if (y > 200+SPECHEIGHT) then
			y=SPECHEIGHT+200
		end -- cap it
		calced[x] = y

		y = y - 1
		if ( y >= -1 ) then
			dxDrawRectangle((posx*(SPECWIDTH/BANDS))+10+screenStartX, screenStartY, 10, max((y+1)/4, 1), tocolor(r, g, b, 255 ))
		end
		if ( bSpawnParticles == true ) then
			for key = 0, 40 do
				if ( peaks[x][key] == nil ) then
					if ( #peaks[x] <= 20 and prevcalced[x] <= calced[x] and ( release[x] == true or release[x] == nil ) and y > 1 ) then
						local rnd = math.random(0, 0)
						peaks[x][key] = {}
						if ( dir == "up" ) then
							peaks[x][key]["pos"] = screenStartY
						else
							peaks[x][key]["pos"] = screenStartY+((y+1)/4)
						end
						peaks[x][key]["posx"] = (posx*(SPECWIDTH/BANDS))+12+screenStartX+(2-key)
						peaks[x][key]["alpha"] = 128
						peaks[x][key]["dirx"] = 0
						release[x] = false
						setTimer(function ( ) release[x] = true end, 100, 1)
					end
				else
					if ( bpm > 0 ) then
						local maxScreenPos = 290
						local AlphaMulti = 255 / maxScreenPos
						value = peaks[x][key]
						if ( value ~= nil ) then
							local sX = value.posx
							dxDrawRectangle( value.posx, value.pos, 2, 2, tocolor(r, g, b, value.alpha))
							value.pos = dir == "down" and value.pos + movespeed or value.pos - movespeed
							value.posx = value.posx + (movespeed <= 2 and math.random(-movespeed,movespeed) or math.random(-1, 1))
							value.alpha = value.alpha - (AlphaMulti) - math.random(1, 4)

							if ( value.alpha <= 0 ) then
								peaks[x][key] = nil
							end
						end
					end
				end
			end
		end
	end
	if ( bSpawnParticles == true ) then
		dxDrawText(string.format((tags.artist ~= nil and tags.artist .. ", " or "") .."BPM: %i", bpm), screenStartX+10, screenStartY-30, screenStartX+20, screenStartY-30, tocolor(255, 255, 255, 255 ), 1.5, "arial")
	end
	dxDrawText(tags.title or tags.stream_name or "Unknown", screenStartX+10, screenStartY-60, screenStartX+10, screenStartY-60, tocolor(255, 255, 255, 255 ), 2, "arial")
	dxDrawText(timetostring(getSoundLength(stream), getSoundPosition(stream)), SPECWIDTH-50, screenStartY-40, SPECWIDTH-80, screenStartY-40, tocolor(255, 255, 255, 255 ), 1.5, "arial")

	dxSetRenderTarget()
	dxSetShaderValue ( shader_cinema, "gTexture", tar )
end
