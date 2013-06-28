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
					
	 playerModels = 
[[hmogar.dff
wmycon.dff
wmyconb.dff
wmymech.dff
wmysgrd.dff
wmycon.dff
wmyconb.dff
wmysgrd.dff
swmocd.dff
hmogar.dff
wmycon.dff
wmyconb.dff
hmogar.dff
wmysgrd.dff
vbmocd.dff
bmyri.dff
bmybu.dff
bfybu.dff
bfyri.dff
bmyri.dff
bfyri.dff
hfyri.dff
hmyri.dff
hfyri.dff
hmyri.dff
omyri.dff
omyri.dff
sofybu.dff
wfyri.dff
wmyri.dff
wmybu.dff
wfybu.dff
sbmyri.dff
somobu.dff
somybu.dff
bmybu.dff
bfybu.dff
sbfyri.dff
sbmyri.dff
hfyri.dff
hmyri.dff
hfyri.dff
hmyri.dff
somyri.dff
somyri.dff
sofybu.dff
swfyri.dff
swmyri.dff
wmybu.dff
wfybu.dff
bmyri.dff
bmybu.dff
bfybu.dff
bfyri.dff
bmyri.dff
bfyri.dff
hfyri.dff
hmyri.dff
hfyri.dff
hmyri.dff
omyri.dff
omyri.dff
wfyri.dff
wmyri.dff
wmybu.dff
wfybu.dff
bfyri.dff
bmyri.dff
bmyst.dff
omost.dff
omyst.dff
ofyst.dff
wmyst.dff
wfyst.dff
hfyri.dff
hmyri.dff
omyri.dff
wfyri.dff
wmyri.dff
wmyboun.dff
swmyhp1.dff
swmyhp2.dff
sbmyst.dff
somost.dff
omyst.dff
sofyst.dff
swmyst.dff
swfyst.dff
sbfyri.dff
sbmyri.dff
hfyri.dff
hmyri.dff
somyri.dff
swfyri.dff
swmyri.dff
wmyboun.dff
bmyst.dff
omost.dff
omyst.dff
ofyst.dff
wmyst.dff
wfyst.dff
bfyri.dff
bmyri.dff
hfyri.dff
hmyri.dff
omyri.dff
wfyri.dff
wmyri.dff
wmyboun.dff
cwfofr.dff
cwfohb.dff
cwfyfr1.dff
cwfyfr2.dff
cwfyhb.dff
cwmofr.dff
cwmohb1.dff
cwmohb2.dff
cwmyfr.dff
cwmyhb1.dff
cwmyhb2.dff
bfybe.dff
bmybe.dff
hfybe.dff
hmybe.dff
wfybe.dff
wmybe.dff
wfyro.dff
wmyro.dff
wfylg.dff
wmyjg.dff
wfyjg.dff
wmybp.dff
bmymoun.dff
wmymoun.dff
bfybe.dff
hfybe.dff
swmyhp1.dff
swmyhp2.dff
wmyjg.dff
wfyjg.dff
wmybp.dff
bmymoun.dff
wmymoun.dff
wmyjg.dff
wfyjg.dff
wmybp.dff
bmymoun.dff
wmymoun.dff
wfybe.dff
bfybe.dff
bfori.dff
bfyri.dff
bmori.dff
bmyri.dff
hfori.dff
hfyri.dff
hmori.dff
hmyri.dff
ofori.dff
omyri.dff
omori.dff
ofyri.dff
wfyri.dff
wmyri.dff
wmori.dff
wfori.dff
wmybu.dff
wfybu.dff
sbfori.dff
sbfyri.dff
sbmori.dff
sbmyri.dff
hfori.dff
hfyri.dff
hmori.dff
hmyri.dff
sofori.dff
somyri.dff
somori.dff
sofyri.dff
swfyri.dff
swmyri.dff
swmori.dff
swfori.dff
wmybu.dff
wfybu.dff
bfori.dff
bfyri.dff
bmori.dff
bmyri.dff
hfori.dff
hfyri.dff
hmori.dff
hmyri.dff
ofori.dff
omyri.dff
omori.dff
ofyri.dff
wfyri.dff
wmyri.dff
wmori.dff
wfori.dff
wmybu.dff
wfybu.dff
wmyva.dff
bmydj.dff
bfyst.dff
bmyst.dff
bfost.dff
omost.dff
ofyst.dff
omyst.dff
hfyst.dff
hmyst.dff
hmost.dff
wfyst.dff
wmyst.dff
wmost.dff
smyst.dff
smyst2.dff
sbmost.dff
sbfyst.dff
sbmyst.dff
somost.dff
sofyst.dff
somyst.dff
hfyst.dff
hmyst.dff
hmost.dff
swfyst.dff
swmyst.dff
wmost.dff
bfyst.dff
bmyst.dff
omost.dff
ofyst.dff
omyst.dff
hfyst.dff
hmyst.dff
hmost.dff
wfyst.dff
wmyst.dff
wmost.dff
bfyst.dff
bmyst.dff
bmotr1.dff
bmydj.dff
bmost.dff
hfyst.dff
hmyst.dff
hmost.dff
hfost.dff
omyst.dff
ofyst.dff
ofost.dff
omost.dff
ofyst.dff
omyst.dff
wfyst.dff
wfyst.dff
wmyst.dff
wmost.dff
wfost.dff
wmotr1.dff
sbfost.dff
sbfyst.dff
sbmyst.dff
somyst.dff
sofyst.dff
sofost.dff
somost.dff
sofyst.dff
somyst.dff
swfyst.dff
swmost.dff
swfost.dff
swmyhp1.dff
swmyhp2.dff
sbmotr2.dff
swmotr1.dff
swmotr2.dff
swmotr3.dff
sbmytr3.dff
swmotr4.dff
swmotr5.dff
vwmycd.dff
bmost.dff
bfyst.dff
bmyst.dff
hfyst.dff
hmyst.dff
hmost.dff
hfost.dff
omyst.dff
ofyst.dff
ofost.dff
omost.dff
ofyst.dff
omyst.dff
wfyst.dff
wfyst.dff
wmyst.dff
wmost.dff
vwmotr1.dff
vwmotr2.dff
bfypro.dff
hfypro.dff
wfypro.dff
sfypro.dff
swfopro.dff
sbfypro.dff
shfypro.dff
vwfypro.dff
vbfypro.dff
vhfypro.dff
bmycr.dff
hmycr.dff
wmycr.dff
sbmycr.dff
shmycr.dff
swmycr.dff
vbmycr.dff
vhmycr.dff
vwmycr.dff
wmygol1.dff
wmygol2.dff
wmyva.dff
wbdyg1.dff
wbdyg2.dff
hmogar.dff
wmyva.dff
wbdyg1.dff
wbdyg2.dff
hmogar.dff
wmyva.dff
wbdyg1.dff
wbdyg2.dff
hmogar.dff
bmyap.dff
wmyplt.dff
wfystew.dff
bmyap.dff
wmyplt.dff
wfystew.dff
bmyap.dff
wmyplt.dff
wfystew.dff
bmydj.dff
bmydj.dff
vhmyelv.dff
vbmyelv.dff
vimyelv.dff
wmycon.dff
wmyconb.dff
wmymech.dff
dwfolc.dff
dwfylc1.dff
dwfylc2.dff
dwmolc1.dff
dwmolc2.dff
dwmylc1.dff
dwmylc2.dff
dnfolc1.dff
dnfolc2.dff
dnfylc.dff
dnmolc1.dff
dnmolc2.dff
dnmylc.dff
bmyap.dff
wmyplt.dff
wfystew.dff
ballas1.dff
ballas2.dff
ballas3.dff
fam1.dff
fam2.dff
fam3.dff
lsv1.dff
lsv2.dff
lsv3.dff
sfr1.dff
sfr2.dff
sfr3.dff
dnb1.dff
dnb2.dff
dnb3.dff
vmaff1.dff
vmaff2.dff
vmaff3.dff
vmaff4.dff
triada.dff
triadb.dff
triboss.dff
vla1.dff
vla2.dff
vla3.dff
bmydrug.dff
wmydrug.dff
hmydrug.dff
bikdrug.dff
wmybu.dff
wfybu.dff
sofybu.dff
bfybu.dff
bmybu.dff
bmycr.dff
hmori.dff
omost.dff
swmyhp1.dff
wfyri.dff
wfyst.dff
hfyst.dff
wfyri.dff
sofybu.dff
bfyri.dff]]
}


aBlockModsTab = {

	radioButtons = {
					{ type="none",			desc="None",			color=colorRed,		button=false, custom=false, text=aBlockModsTab_presets.none },
					{ type="all",			desc="All",				color=colorGreen,	button=false, custom=false, text=aBlockModsTab_presets.all },
					{ type="models_anims",	desc="Models+Anims",	color=colorWhite,	button=false, custom=false, text=aBlockModsTab_presets.modelsAnims },
					{ type="weapons",		desc="Some weapons",	color=colorWhite,	button=false, custom=false, text=aBlockModsTab_presets.weaponModels },
					{ type="players",		desc="Player Models",	color=colorWhite,	button=false, custom=false, text=aBlockModsTab_presets.playerModels },
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
