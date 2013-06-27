--
-- Anti-Cheat Control Panel
--
-- _common.lua
--

_version = "0.1.4"

MIN_CLIENT_VERSION_FOR_MOD_BLOCKS = "1.3.1-9.04818"

function outputDebug(msg)
	msg = getTickCount() .. " " .. msg
	outputDebugString(msg)
end


function stripColorCodes ( text )
	return string.gsub ( text, '#%x%x%x%x%x%x', '' )
end


function table.find(t, ...)
	local args = { ... }
	if #args == 0 then
		for k,v in pairs(t) do
			if v then
				return k, v
			end
		end
		return false
	end
	
	local value = table.remove(args)
	if value == '[nil]' then
		value = nil
	end
	for k,v in pairs(t) do
		for i,index in ipairs(args) do
			if type(index) == 'function' then
				v = index(v)
			else
				if index == '[last]' then
					index = #v
				end
				v = v[index]
			end
		end
		if v == value then
			return k, t[k]
		end
	end
	return false
end


function math.bit(p)
  return 2 ^ (p - 1)  -- 1-based indexing
end

-- Typical call:  if hasbit(x, bit(3)) then ...
function math.hasbit(x, p)
  return x % (p + p) >= p       
end


newline = "\n"

colorYellow = {255,255,0}
colorGreen = {128,255,128}
colorRed = {255,128,128}
colorGrey = {128,128,128}
colorLtGrey = {192,192,192}
colorWhite = {255,255,255}

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

aBlockModsTab_presets = {

	 none =		"",

	 all =			"*",

	 modelsAnims =	".ifp" .. newline ..
					".dff",

	 weaponModels =  "grenade.dff" .. newline ..
					"teargas.dff" .. newline ..
					"molotov.dff" .. newline ..
					"colt45.dff" .. newline ..
					"silenced.dff" .. newline ..
					"desert_eagle.dff" .. newline ..
					"chromegun.dff" .. newline ..
					"sawnoff.dff" .. newline ..
					"shotgspa.dff" .. newline ..
					"micro_uzi.dff" .. newline ..
					"mp5lng.dff" .. newline ..
					"ak47.dff" .. newline ..
					"m4.dff" .. newline ..
					"cuntgun.dff" .. newline ..
					"rocketla.dff" .. newline ..
					"heatseek.dff" .. newline ..
					"flame.dff" .. newline ..
					"minigun.dff" .. newline ..
					"satchel.dff" .. newline ..
					"tec9.dff" .. newline ..
					"sniper.dff",
}


aBlockModsTab = {

	radioButtons = {
					{ type="none",			desc="None",			color=colorRed,		button=false, custom=false, text=aBlockModsTab_presets.none },
					{ type="all",			desc="All",				color=colorGreen,	button=false, custom=false, text=aBlockModsTab_presets.all },
					{ type="models_anims",	desc="Models+Anims",	color=colorWhite,	button=false, custom=false, text=aBlockModsTab_presets.modelsAnims },
					{ type="weapons",		desc="Some weapons",	color=colorWhite,	button=false, custom=false, text=aBlockModsTab_presets.weaponModels },
					{ type="custom",		desc="Custom",			color=colorWhite,	button=false, custom=true,	text="" },
				}
}

function aBlockModsTab.getInfoForType(type)
	for _,info in ipairs(aBlockModsTab.radioButtons) do	
		if info.type == type then
			return info
		end
	end
end


---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
aServerConfigTab_presets = {
	 none			=	"",
	 maxMinClient	=	"1.3.1-9.04835",
	 release		=	"1.3.1-9.04709",
}

aServerConfigTab = {


	radioButtons = {
					{ type="none",		desc="None",					color=colorRed,		button=false, custom=false, text=aServerConfigTab_presets.none },
					{ type="latest",	desc="Latest anti-cheat defs",	color=colorGreen,	button=false, custom=false, text=aServerConfigTab_presets.maxMinClient },
					{ type="release",	desc="Current release version",	color=colorWhite,	button=false, custom=false, text=aServerConfigTab_presets.release },
					{ type="custom",	desc="Custom",					color=colorWhite,	button=false, custom=true,	text="" },
				}
}


function aServerConfigTab.getInfoForType(type)
	for _,info in ipairs(aServerConfigTab.radioButtons) do	
		if info.type == type then
			return info
		end
	end
end
