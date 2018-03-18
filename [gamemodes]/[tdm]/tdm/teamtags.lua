local root = getRootElement()
local g_screenX,g_screenY = guiGetScreenSize()
local BONE_ID = 8
local WORLD_OFFSET = 0.4
local ICON_PATH = "images/teamtags.png"
local ICON_WIDTH = 0.35*g_screenX
-- local ICON_HEIGHT = 0.213333333333*g_screenY
--
local iconHalfWidth = ICON_WIDTH/2
-- local iconHalfHeight = ICON_HEIGHT/2


--Draw the tag image
addEventHandler ( "onClientRender", root,
	function()
		local localTeam = getPlayerTeam ( localPlayer )
		for i,player in ipairs(getElementsByType"player") do
			while true do
				--Ignore the local player
				if player == localPlayer then
					break
				end
				--is he in our team?
				if not localTeam or localTeam ~= getPlayerTeam ( player ) then
					break
				end
				--is he streamed in?
				if not isElementStreamedIn(player) then
					break
				end
				--is he on screen?
				if not isElementOnScreen(player) then
					break
				end
				local headX,headY,headZ = getPedBonePosition(player,BONE_ID)
				headZ = headZ + WORLD_OFFSET
				--is the head position on screen?
				local absX,absY = getScreenFromWorldPosition ( headX,headY,headZ )
				if not absX or not absY then
					break
				end
				local camX,camY,camZ = getCameraMatrix()
				local r,g,b = getPlayerNametagColor ( player )
				local color = tocolor(r,g,b,112)
				dxDrawTag ( absX, absY, color, getDistanceBetweenPoints3D(camX, camY, camZ, headX, headY, headZ) )
				break
			end
		end
	end
)

function dxDrawTag ( posX, posY, color, distance )
	distance = 1/distance
	dxDrawImage ( posX - iconHalfWidth*distance, posY - iconHalfWidth*distance, ICON_WIDTH*distance, ICON_WIDTH*distance, ICON_PATH, 0, 0, 0, color, false )
end

