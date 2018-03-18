nametag = {}
local nametags = {}
local g_screenX,g_screenY = guiGetScreenSize()
local bHideNametags = false

local NAMETAG_SCALE = 0.3 --Overall adjustment of the nametag, use this to resize but constrain proportions
local NAMETAG_ALPHA_DISTANCE = 50 --Distance to start fading out
local NAMETAG_ALPHA_DISSAPEAR_DISTANCE = 0 -- Distance to fade out close nametags
local NAMETAG_DISTANCE = 120 --Distance until we're gone
local NAMETAG_ALPHA = 120 --The overall alpha level of the nametag
--The following arent actual pixel measurements, they're just proportional constraints
local NAMETAG_TEXT_BAR_SPACE = 2
local NAMETAG_WIDTH = 50
local NAMETAG_HEIGHT = 5
local NAMETAG_TEXTSIZE = 0.7
local NAMETAG_OUTLINE_THICKNESS = 1.2
--
local NAMETAG_ALPHA_DIFF = NAMETAG_DISTANCE - NAMETAG_ALPHA_DISTANCE
local NAMETAG_ALPHA_DISSAPEAR_DIFF = NAMETAG_ALPHA_DISTANCE - NAMETAG_ALPHA_DISSAPEAR_DISTANCE
NAMETAG_SCALE = 1/NAMETAG_SCALE * 800 / g_screenY

-- Ensure the name tag doesn't get too big
local maxScaleCurve = { {0, 0}, {3, 3}, {13, 5} }
-- Ensure the text doesn't get too small/unreadable
local textScaleCurve = { {0, 0.8}, {0.8, 1.2}, {99, 99} }
-- Make the text a bit brighter and fade more gradually
local textAlphaCurve = { {0, 0}, {25, 100}, {120, 190}, {255, 190} }

function GhostPlayback:drawGhostNametag( info )
	if bHideNametags then
		return
	end
	local x,y,z = getCameraMatrix()
	local px,py,pz = getElementPosition ( self.vehicle )
	local pdistance = getDistanceBetweenPoints3D ( x,y,z,px,py,pz )
	if pdistance <= NAMETAG_DISTANCE then
		--Get screenposition
		local sx,sy = getScreenFromWorldPosition ( px, py, pz+0.6, 0.06 )
		if not sx and not sy then return end
		--Calculate our components
		local scale = 1/(NAMETAG_SCALE * (pdistance / NAMETAG_DISTANCE))
		local alpha = (pdistance - NAMETAG_ALPHA_DISTANCE) / NAMETAG_ALPHA_DIFF
		if alpha < 0 then
			alpha = (NAMETAG_ALPHA_DISTANCE - pdistance) / NAMETAG_ALPHA_DISSAPEAR_DIFF
			alpha = math.max( 0, math.min( 1, alpha ) )
			alpha = NAMETAG_ALPHA-(alpha*NAMETAG_ALPHA)
		else
			alpha = NAMETAG_ALPHA-(alpha*NAMETAG_ALPHA)
		end
		scale = math.evalCurve(maxScaleCurve,scale)
		local textscale = math.evalCurve(textScaleCurve,scale)
		local textalpha = math.evalCurve(textAlphaCurve,alpha)
		local outlineThickness = NAMETAG_OUTLINE_THICKNESS*(scale)
		--Draw our text
		local r,g,b = 150,150,150
		local offset = (scale) * NAMETAG_TEXT_BAR_SPACE/2
		dxDrawText ( info.name, sx, sy - offset, sx, sy - offset, tocolor(r,g,b,textalpha), textscale*NAMETAG_TEXTSIZE, "default", "center", "bottom", false, false, false )

		--We draw three parts to make the healthbar.  First the outline/background
		local drawX = sx - NAMETAG_WIDTH*scale/2
		drawY = sy + offset
		--[[local width,height =  NAMETAG_WIDTH*scale, NAMETAG_HEIGHT*scale
		dxDrawRectangle ( drawX, drawY, width, height, tocolor(0,0,0,alpha) )
		--Next the inner background
		local health = getElementHealth(vehicle)
		health = math.max(health - 250, 0)/750
		local p = -510*(health^2)
		local r,g = math.max(math.min(p + 255*health + 255, 255), 0), math.max(math.min(p + 765*health, 255), 0)
		dxDrawRectangle ( 	drawX + outlineThickness,
										drawY + outlineThickness,
										width - outlineThickness*2,
										height - outlineThickness*2,
										tocolor(r,g,0,0.4*alpha)
									)
					--Finally, the actual health
					dxDrawRectangle ( 	drawX + outlineThickness,
										drawY + outlineThickness,
										health*(width - outlineThickness*2),
										height - outlineThickness*2,
										tocolor(r,g,0,alpha)
									)--]]
		dxDrawText ( info.time, sx, drawY, sx, drawY, tocolor(r,g,b,textalpha), textscale*NAMETAG_TEXTSIZE*0.8, "default", "center", "top", false, false, false )
	end
end

addEvent ( "onClientScreenFadedOut", true )
addEventHandler ( "onClientScreenFadedOut", g_Root,
	function()
		bHideNametags = true
	end
)

addEvent ( "onClientScreenFadedIn", true )
addEventHandler ( "onClientScreenFadedIn", g_Root,
	function()
		bHideNametags = false
	end
)

function math.evalCurve( curve, input )
	-- First value
	if input<curve[1][1] then
		return curve[1][2]
	end
	-- Interp value
	for idx=2,#curve do
		if input<curve[idx][1] then
			local x1 = curve[idx-1][1]
			local y1 = curve[idx-1][2]
			local x2 = curve[idx][1]
			local y2 = curve[idx][2]
			-- Find pos between input points
			local alpha = (input - x1)/(x2 - x1);
			-- Map to output points
			return math.lerp(y1,y2,alpha)
		end
	end
	-- Last value
	return curve[#curve][2]
end

function math.lerp(from,to,alpha)
    return from + (to-from) * alpha
end

