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
				{ id=26, desc="Anti-cheat component blocked" },
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

	ypos = ypos + 5

	local msg = "To turn OFF an AC#, add number to <disabledac> setting in mtaserver.conf and restart server"
	local label1 = guiCreateLabel ( xpos, ypos, 700, 16, msg, false, tab )
	guiLabelSetColor(label1, unpack(colorYellow) )
	guiSetFont(label1, "default-bold-small" )

	ypos = ypos + 25


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
				{ id=22, sver="1.3.4-9.05884", cver="1.3.4-9.05884", desc="Disallow resource download errors/corruption (Lua script files)" },
				{ id=23, sver="1.3.4-9.05884", cver="1.5.2-9.07911", desc="Disallow resource download errors/corruption (Non-Lua files e.g. png,dff)" },
				{ id=28, sver="1.3.4-9.05884", cver="1.3.4-9.05884", desc="Disallow Linux Wine" },
				{ id=31, sver="1.5.3",         cver="1.5.3-9.11204", desc="Ignore injected keyboard inputs" },
				{ id=32, sver="1.5.3",         cver="1.5.3-9.11528", desc="Ignore injected mouse button inputs and movement" },
				{ id=33, sver="1.5.6",         cver="1.5.6",         desc="Disallow software of the category 'Net limiter'" },
				{ id=34, sver="1.5.6",         cver="1.5.6",         desc="Disallow internet café users" },
				{ id=35, sver="1.5.6",         cver="1.5.6",         desc="Disallow certain software with \"FPS locking\" capabilities" },
				{ id=36, sver="1.5.7",         cver="1.5.7",         desc="Disallow AutoHotKey base application (used to load .ahk files)" },
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

	ypos = ypos + 5

	local msg = "To turn ON a SD#, add number to <enabledsd> setting in mtaserver.conf and restart server"
	local label1 = guiCreateLabel ( xpos, ypos, 700, 16, msg, false, tab )
	guiSetFont(label1, "default-bold-small" )
	guiLabelSetColor(label1, unpack(colorYellow) )

	ypos = ypos + 25

	aAntiCheatTab.Refresh()

end


function aAntiCheatTab.Refresh ()
end

