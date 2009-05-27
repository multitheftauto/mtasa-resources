--
-- traffic_sensor_client.lua
--

---------------------------------------------------------------------------
--
-- Handle events from Race
--
---------------------------------------------------------------------------

addEvent('onClientMapStarting', true)
addEventHandler('onClientMapStarting', getRootElement(),
	function(mapinfo)
		outputDebug( 'BIGDAR', 'onClientMapStarting' )
		if mapinfo.modename == "Destruction derby" or mapinfo.modename == "Freeroam" then
			Bigdar.allowed = false
		else
			Bigdar.allowed = true
		end
		Bigdar.finishedPlayers = {}
	end
)

addEvent('onClientMapStopping', true)
addEventHandler('onClientMapStopping', getRootElement(),
	function()
		outputDebug( 'BIGDAR', 'onClientMapStopping' )
	end
)

addEvent('onClientPlayerFinish', true)
addEventHandler('onClientPlayerFinish', getRootElement(),
	function()
		outputDebug( 'BIGDAR', 'onClientPlayerFinish' )
		Bigdar.finishedPlayers[source] = true
	end
)


---------------------------------------------------------------------------
-- Bigdar - Big radar
---------------------------------------------------------------------------
Bigdar = {}
Bigdar.smoothList = {}			-- {player = rrz}
Bigdar.finishedPlayers = {}
Bigdar.lastSmoothSeconds = 0
Bigdar.beginValidSeconds = nil
Bigdar.enabled = true		-- Manual override
Bigdar.allowed = true		-- Map override
Bigdar.hidden = true		-- Black screen override

function Bigdar.toggle()
    Bigdar.enabled = not Bigdar.enabled
    outputConsole( 'Bigdar is now ' .. (Bigdar.enabled and 'on' or 'off') .. '  -  Allowed ' .. (Bigdar.allowed and 'yes' or 'no') )
end

function isPlayerFinished(player)
	return Bigdar.finishedPlayers[player]
end

function Bigdar.render()
    -- Ensure map allows it, and player not dead, and in a vehicle and not spectating
	local vehicle = getPedOccupiedVehicle(g_Me)
    if     not Bigdar.allowed
		or isPlayerDead(g_Me)
		or isPlayerFinished(g_Me)
		or not vehicle
		or getCameraTarget() ~= vehicle
		then
			Bigdar.beginValidSeconds = nil
			return
    end

    -- Ensure at least 1 second since g_BeginValidSeconds was set
    local timeSeconds = getSecondCount()
    if not Bigdar.beginValidSeconds then
        Bigdar.beginValidSeconds = timeSeconds
    end
    if timeSeconds - Bigdar.beginValidSeconds < 1 then
        return
    end

    -- No draw if faded out or not enabled
    if
		Bigdar.hidden or
		not Bigdar.enabled then
			return
    end

	-- Icon definition
	local icon = { file='img/arrow_ts.png', w=80, h=56, r=255, g=220, b=210 }

    -- Calc smoothing vars
    local delta = timeSeconds - Bigdar.lastSmoothSeconds
    Bigdar.lastSmoothSeconds = timeSeconds
    local timeslice = math.clamp(0,delta*14,1)

    -- Get screen dimensions
    local screenX,screenY = guiGetScreenSize()
    local halfScreenX = screenX * 0.5
    local halfScreenY = screenY * 0.5

    -- Get my pos and rot
    local mx, my, mz = getElementPosition(g_Me)
    local _, _, mrz  = getCameraRot()

    -- To radians
    mrz = math.rad(-mrz)

	-- For each 'other player'
    for i,player in ipairs(getElementsByType('player')) do
        if player ~= g_Me and not isPlayerDead(player) and not isPlayerFinished(player) then

            -- Get other pos
            local ox, oy, oz = getElementPosition(player)

            -- Only draw marker if other player it is close enough, and not on screen
            local maxDistance = 60
            local alpha = 1 - getDistanceBetweenPoints3D( mx, my, mz, ox, oy, oz ) / maxDistance
            local onScreen = getScreenFromWorldPosition ( ox, oy, oz )

            if onScreen or alpha <= 0 then
                -- If no draw, reset smooth position
                Bigdar.smoothList[player] = nil
            else
                -- Calc draw scale
                local scalex = alpha * 0.5 + 0.5
                local scaley = alpha * 0.25 + 0.75

                -- Calc dir to
                local dx = ox - mx
                local dy = oy - my
                -- Calc rotz to
                local drz = math.atan2(dx,dy)
                -- Calc relative rotz to
                local rrz = drz - mrz

                -- Add smoothing to the relative rotz
                local smooth = Bigdar.smoothList[player] or rrz
                smooth = math.wrapdifference(-math.pi, smooth, rrz, math.pi)
                if math.abs(smooth-rrz) > 1.57 then
                    smooth = rrz	-- Instant jump if more than 1/4 of a circle to go
                end
                smooth = math.lerp( smooth, rrz, timeslice )
                Bigdar.smoothList[player] = smooth
                rrz = smooth

                -- Calc on screen pos for relative rotz
                local sx = math.sin(rrz)
                local sy = math.cos(rrz)

                -- Draw at edge of screen
                local X1 = halfScreenX
                local Y1 = halfScreenY
                local X2 = sx * halfScreenX + halfScreenX
                local Y2 = -sy * halfScreenY + halfScreenY
                local X
                local Y
                if math.abs(sx) > math.abs(sy) then
                    -- Left or right
                    if X2 < X1 then
                        -- Left
                        X = 32
                        Y = Y1+ (Y2-Y1)* (X-X1) / (X2-X1)
                    else
                        -- right
                        X = screenX-32
                        Y = Y1+ (Y2-Y1)* (X-X1) / (X2-X1)
                    end
                else
                    -- Top or bottom
                    if Y2 < Y1 then
                        -- Top
                        Y = 32
                        X = X1+ (X2-X1)* (Y-Y1) / (Y2 - Y1)
                    else
                        -- bottom
                        Y = screenY-32
                        X = X1+ (X2-X1)* (Y-Y1) / (Y2 - Y1)
                    end
                end
                dxDrawImage ( X-icon.w/2*scalex, Y-icon.h/2*scaley, icon.w*scalex, icon.h*scaley, icon.file, 180 + rrz * 180 / math.pi, 0, 0, tocolor(icon.r,icon.g,icon.b,255*alpha), false )
            end
        end
    end
end
addEventHandler('onClientRender', g_Root, Bigdar.render)


---------------------------------------------------------------------------
-- Various events

addEventHandler('onClientPlayerJoined', g_Root,
	function()
		--table.insertUnique(g_Players, source)
	end
)

addEventHandler('onClientPlayerQuit', g_Root,
	function()
		--table.removevalue(g_Players, source)
		Bigdar.smoothList[source] = nil
	end
)


addEvent ( "onClientScreenFadedOut", true )
addEventHandler ( "onClientScreenFadedOut", g_Root,
	function()
		Bigdar.hidden = true
	end
)

addEvent ( "onClientScreenFadedIn", true )
addEventHandler ( "onClientScreenFadedIn", g_Root,
	function()
		Bigdar.hidden = false
	end
)


---------------------------------------------------------------------------
--
-- Commands and binds
--
--
--
---------------------------------------------------------------------------

bindKey('F4', 'down',
    function()
        Bigdar.toggle()
    end
)

