--
-- Anti-Cheat Control Panel
--
-- c_gui_ac.lua
--

aAntiCheatTab = {
}


function aAntiCheatTab.Create ( tab )
	aAntiCheatTab.Tab = tab

	xpos = 20
	ypos = 10

	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	-- AC list
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	local acInfoList = {
				{ id=1, desc="Classic health/armour hack detector" },
				{ id=4, desc="Detects presence of trainer. Capital letters in the message are for tagging particular trainers" },
				{ id=5, desc="Detects use of trainer. " },
				{ id=6, desc="Detects use of trainer incl.: player movement, health/damage, weapons, money, gamespeed, game cheats, aimbot" },
				{ id=7, desc="Detects use of trainer." },
				{ id=8, desc="Detects unauthorized mods. Capital letters in the message are for tagging particular items e.g. CLEO - Cleo detected, RENDER - Wall hack detected" },
				{ id=11, desc="Dll injector / Trainer" },
				{ id=13, desc="Data files issue" },
				{ id=17, desc="Speed / wall hacks" },
				{ id=18, desc="Modifed game files" },
				{ id=21, desc="Trainers / custom gta_sa.exe" },
			}

	local disabledAcDesc = getServerConfigSetting( "disableac" )
	--outputDebug( "disabledAcDesc" .. tostring(disabledAcDesc) )
	disabledAcList = split(disabledAcDesc, ",")

	local label1 = guiCreateLabel ( xpos, ypos, 100, 16, "AC settings:", false, tab )
	guiSetFont(label1, "default-bold-small" )

	ypos = ypos + 17

	for _,info in ipairs(acInfoList) do
		local bEnabled = not table.find(disabledAcList, tostring(info.id))
		local label1 = guiCreateLabel ( xpos,		ypos, 50, 16,	"AC #" .. info.id,			false, tab )
		local label2 = guiCreateLabel ( xpos+70,	ypos, 50, 16,	bEnabled and "ON" or "OFF", false, tab )
		local label3 = guiCreateLabel ( xpos+110,	ypos, 450, 16,	"( "..info.desc.." )",		false, tab )
		if bEnabled then
			guiLabelSetColor(label2, unpack(colorGreen) )
		else
			guiLabelSetColor(label2, unpack(colorRed) )
			guiSetFont(label2, "default-bold-small" )
		end
		guiLabelSetColor(label3, unpack(colorGrey) )
		ypos = ypos + 14
	end

	ypos = ypos + 2

	local msg = "To turn OFF an AC#, add number to <disabledac> setting in mtaserver.conf and restart server"
	local label1 = guiCreateLabel ( xpos, ypos, 700, 16, msg, false, tab )
	guiLabelSetColor(label1, unpack(colorYellow) )
	guiSetFont(label1, "default-small" )

	ypos = ypos + 20


	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	-- SD list
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	local sdInfoList = {
				{ id=12, sver="1.3.1",         cver="1.3.1",         desc="Disallow custom D3D9.DLL" },
				{ id=14, sver="1.3.1-9.04605", cver="1.3.1-9.04605", desc="Disallow virtual machines such as VMWare" },
				{ id=15, sver="1.3.1-9.04791", cver="1.3.1-9.04791", desc="Disallow disabled driver signing" },
				{ id=16, sver="1.3.1-9.05097", cver="1.3.1-9.05097", desc="Disallow disabled AC components" },
				{ id=20, sver="1.3.1-9.05097", cver="1.3.1-9.05097", desc="Disallow modified gta3.img" },
			}

	local enableSdDesc = getServerConfigSetting( "enablesd" )
	--outputDebug( "enableSdDesc" .. tostring(enableSdDesc) )
	enableSdList = split(enableSdDesc, ",")

	local label1 = guiCreateLabel ( xpos, ypos, 100, 16, "SD settings:", false, tab )
	guiSetFont(label1, "default-bold-small" )

	ypos = ypos + 17

	for _,info in ipairs(sdInfoList) do
		local bEnabled = table.find(enableSdList, tostring(info.id))
		local name = "SD #" .. info.id
		local label1 = guiCreateLabel ( xpos,		ypos, 50, 16,	name,						false, tab )
		local label2 = guiCreateLabel ( xpos+70,	ypos, 50, 16,	bEnabled and "ON" or "OFF", false, tab )
		local label3 = guiCreateLabel ( xpos+110,	ypos, 450, 16,	"( "..info.desc.." )",		false, tab )
		if bEnabled then
			guiLabelSetColor(label2, unpack(colorGreen) )
		else
			guiLabelSetColor(label2, unpack(colorRed) )
			guiSetFont(label2, "default-bold-small" )
		end
		guiLabelSetColor(label3, unpack(colorGrey) )
		ypos = ypos + 14
		if bEnabled then
			if getVersion().sortable < info.sver then
				outputChatBox( "Need at least server version " .. info.sver .. " To use " .. name )
			end
		end
	end

	ypos = ypos + 2

	local msg = "To turn ON a SD#, add number to <enabledsd> setting in mtaserver.conf and restart server"
	local label1 = guiCreateLabel ( xpos, ypos, 700, 16, msg, false, tab )
	guiSetFont(label1, "default-bold-small" )
	guiLabelSetColor(label1, unpack(colorYellow) )

	ypos = ypos + 25


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

	ypos = ypos + 20

	local gridlist		= guiCreateGridList ( xpos, ypos, 300, 100, false, tab )
	local col1 = 				  	  guiGridListAddColumn ( gridlist, "Filename", 0.65 )
	local col2 =				  	  guiGridListAddColumn ( gridlist, "Allowed", 0.25 )

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

	aAntiCheatTab.Refresh()

end


function aAntiCheatTab.Refresh ()
end

