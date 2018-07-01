---Preset definitons for drawing team select layouts, for 2 and 4 teams.  After that it just uses gridlists
screenX,screenY = guiGetScreenSize()
presetSpawnScreen = {
	aspect = 4/3,
	--Most formats are x,y,width,height
	[2] = {
		interval = 0.2578125,
		text = { 0.376171875,0.3697916667,0.4890625,0.1197916667 },
		icon = { path="images/team.png",0.1533203125,0.3203125,0.1669921875,0.22265625},
		backdrop = {path="images/backdrop.png",0.1533203125,0.3203125,0.7255859375,0.22265625}, --positioned from the centre
	},
	[4] = {
		interval = 0.180989583333,
		text = { 0.388671875,0.3046875,0.3369140625,0.0729166667 },
		icon = { path="images/team.png",0.2216796875,0.265625,0.11328125,0.1510416667},
		backdrop = {path="images/backdrop.png",0.2216796875,0.265625,0.490234375,0.1510416667}, --positioned from the centre
	}
}
presetSpawnScreen[3] = presetSpawnScreen[4]

infoTextX,infoTextY = 0.5*screenX, 0.13*screenY
infoTextScale,infoTextFont,infoTextColor,infoTextOutlineColour = (0.1*screenY)/15,"clear",tocolor(255,255,255,255),tocolor(0,0,0,255)

changeTeamX,changeTeamY = 0.5*screenX,screenY - 17

guiWidth,guiHeight = 0.3857421875*screenX,0.578125*screenY
guiX,guiY = (0.5*screenX)-(guiWidth*0.5),0.24*screenY
