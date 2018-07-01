--
-- Anti-Cheat Control Panel
--
-- c_gui_ac2.lua
--

aAntiCheatTab2 = {
}


function aAntiCheatTab2.Create ( tab )
	aAntiCheatTab2.Tab = tab

	xpos = 20
	ypos = 15

	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	-- Verify client files
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	gtaDataFiles =  {
			  {   1, "data/animgrp.dat" },
			  {   3, "data/ar_stats.dat" },
			  {   0, "data/carmods.dat" },
			  {   5, "data/clothes.dat" },
			  {   7, "data/default.dat" },
			  {   9, "data/default.ide" },
			  {  11, "data/gta.dat" },
			  {  25, "data/maps" },
			  {   6, "data/object.dat" },
			  {  13, "data/peds.ide" },
			  {  15, "data/pedstats.dat" },
			  {  17, "data/txdcut.ide" },
			  {  14, "data/vehicles.ide" },
			  {  20, "data/weapon.dat" },
			  {   4, "data/melee.dat" },
			  {  16, "data/water.dat" },
			  {  18, "data/water1.dat" },
			  {   2, "data/handling.cfg" },
			  {  19, "models/coll/weapons.col" },
			  {  21, "data/plants.dat" },
			  {  23, "data/furnitur.dat" },
			  {  24, "data/procobj.dat" },
			  {   8, "data/surface.dat" },
			  {  12, "data/surfinfo.dat" },
			  {  22, "anim/ped.ifp" },
			 }

	local msg = "Client files which are allowed to be customized:"
	local label1 = guiCreateLabel ( xpos, ypos, 700, 16, msg, false, tab )

	ypos = ypos + 30

	local gridlist		= guiCreateGridList ( xpos, ypos, 300, 386, false, tab )
	local col1 = 				  	  guiGridListAddColumn ( gridlist, "Filename", 0.65 )
	local col2 =				  	  guiGridListAddColumn ( gridlist, "Status", 0.25 )

	local verifyFlagsString = getServerConfigSetting( "verifyclientsettingsstring" )

	for _,info in ipairs(gtaDataFiles) do
		local id = info[1]
		local file = info[2]
		local c = string.sub(verifyFlagsString, id+1, id+1 )
		local allowed = (c == "1")
		--	outputDebug(""
		--		.. " included:" .. tostring(included)
		--		.. " c:" .. tostring(c)
		--		.. " id:" .. tostring(id)
		--		.. " file:" .. tostring(file)
		--		)

		local row = guiGridListAddRow ( gridlist )
		guiGridListSetItemText( gridlist, row, col1, file, false, false )

		if allowed then
			guiGridListSetItemText( gridlist, row, col2, "Allowed", false, false )
			guiGridListSetItemColor( gridlist, row, col2, unpack(colorRed) )
		else
			guiGridListSetItemText( gridlist, row, col2, "Blocked", false, false )
			guiGridListSetItemColor( gridlist, row, col2, unpack(colorGreen) )
		end

	end

	aAntiCheatTab2.Refresh()

end


function aAntiCheatTab2.Refresh ()
end

