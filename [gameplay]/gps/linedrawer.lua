local ENABLE_FAILISH_ATTEMPT_AT_ANTI_ALIASING = false

local OVERLAY_WIDTH      = 256
local OVERLAY_HEIGHT     = 256
local OVERLAY_LINE_WIDTH = 5
local OVERLAY_LINE_COLOR = tocolor ( 0, 200, 0, 255 )
local OVERLAY_LINE_AA    = tocolor ( 0, 200, 0, 200 )

local linePoints  = { }
local renderStuff = { }

function removeLinePoints ( )
	linePoints = { }
	for name, data in pairs ( renderStuff ) do
		unloadTile ( name )
	end
end

function addLinePoint ( posX, posY )
	-- Calculate the row and column of the radar tile we will be targeting
	local row = 11 - math.floor  ( ( posY + 3000 ) / 500 )
	local col =      math.floor ( ( posX + 3000 ) / 500 )

	-- If it's off the map, don't bother
	if row < 0 or row > 11 or col < 0 or col > 11 then
		return false
	end

	-- Check the start position of the tile
	local startX = col * 500 - 3000
	local startY = 3000 - row * 500

	-- Now get the tile position (We don't want to calculate this for every point on render)
	local tileX = ( posX - startX ) / 500 * OVERLAY_WIDTH
	local tileY = ( startY - posY ) / 500 * OVERLAY_HEIGHT

	-- Now calulcate the ID and get the name of the tile
	local id   = col + row * 12
	local name = string.format ( "radar%02d", id )

	-- Make sure the line point table exists
	if not linePoints [ name ] then
		linePoints [ name ] = { }
	end

	-- Now add this point
	table.insert ( linePoints[name], { posX = tileX, posY = tileY } )

	-- Success!
	return true
end

function loadTile ( name )
	-- Create our fabulous shader. Abort on failure
	local shader = dxCreateShader ( "overlay.fx" )
	if not shader then
		return false
	end

	-- Create a render target. Again, abort on failure (don't forget to delete the shader!)
	local rt = dxCreateRenderTarget ( OVERLAY_WIDTH, OVERLAY_HEIGHT, true )
	if not rt then
		destroyElement ( shader )
		return false
	end

	-- Mix 'n match
	dxSetShaderValue ( shader, "gOverlay", rt )

	-- Start drawing
	dxSetRenderTarget ( rt )

	-- Get the points involved, and get the starting position
	local points = linePoints [ name ]
	local prevX, prevY = points [ 1 ].posX, points [ 1 ] .posY

	-- Loop through all points we have to draw, and draw them
	for index, point in ipairs ( points ) do
		local newX = point.posX
		local newY = point.posY

		if ENABLE_FAILISH_ATTEMPT_AT_ANTI_ALIASING then
			dxDrawLine ( prevX - 1, prevY - 1, newX - 1, newY - 1, OVERLAY_LINE_AA, OVERLAY_LINE_WIDTH )
			dxDrawLine ( prevX + 1, prevY - 1, newX + 1, newY - 1, OVERLAY_LINE_AA, OVERLAY_LINE_WIDTH )
			dxDrawLine ( prevX - 1, prevY + 1, newX - 1, newY + 1, OVERLAY_LINE_AA, OVERLAY_LINE_WIDTH )
			dxDrawLine ( prevX + 1, prevY + 1, newX + 1, newY + 1, OVERLAY_LINE_AA, OVERLAY_LINE_WIDTH )
		end

		dxDrawLine ( prevX, prevY, newX, newY, OVERLAY_LINE_COLOR, OVERLAY_LINE_WIDTH )

		prevX = newX
		prevY = newY
	end

	-- Now let's show our fabulous work to the commoners!
	engineApplyShaderToWorldTexture ( shader, name )

	-- Store the stuff in memories
	renderStuff [ name ] = { shader = shader, rt = rt }

	-- We won
	return true
end

function unloadTile ( name )
	destroyElement ( renderStuff[name].shader )
	destroyElement ( renderStuff[name].rt )
	renderStuff[name] = nil
	return true
end

addEventHandler ( "onClientHUDRender", getRootElement ( ),
	function ( )
		local visibleTileNames = table.merge ( engineGetVisibleTextureNames ( "radar??" ), engineGetVisibleTextureNames ( "radar???" ) )

		for name, data in pairs ( renderStuff ) do
			if not table.find ( visibleTileNames, name ) then
				unloadTile ( name )
			end
		end

		for index, name in ipairs ( visibleTileNames ) do
			if linePoints [ name ] and not renderStuff [ name ] then
				loadTile ( name )
			end
		end
	end
)
