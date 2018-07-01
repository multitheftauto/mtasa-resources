--
-- Anti-Cheat Control Panel
--
-- _common.lua
--

_version = "0.1.8"

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
[[cj.dff
truth.dff
maccer.dff
andre.dff
bbthin.dff
bb.dff
emmet.dff
male01.dff
janitor.dff
bfori.dff
bfost.dff
vbfycrp.dff
bfyri.dff
bfyst.dff
bmori.dff
bmost.dff
bmyap.dff
bmybu.dff
bmybe.dff
bmydj.dff
bmyri.dff
bmycr.dff
bmyst.dff
wmybmx.dff
wbdyg1.dff
wbdyg2.dff
wmybp.dff
wmycon.dff
bmydrug.dff
wmydrug.dff
hmydrug.dff
dwfolc.dff
dwmolc1.dff
dwmolc2.dff
dwmylc1.dff
hmogar.dff
wmygol1.dff
wmygol2.dff
hfori.dff
hfost.dff
hfyri.dff
hfyst.dff
jethro.dff
hmori.dff
hmost.dff
hmybe.dff
hmyri.dff
hmycr.dff
hmyst.dff
omokung.dff
wmymech.dff
bmymoun.dff
wmymoun.dff
ofost.dff
ofyri.dff
ofyst.dff
omori.dff
omost.dff
omyri.dff
omyst.dff
wmyplt.dff
wmopj.dff
bfypro.dff
hfypro.dff
kendl.dff
bmypol1.dff
bmypol2.dff
wmoprea.dff
sbfyst.dff
wmosci.dff
wmysgrd.dff
swmyhp1.dff
swmyhp2.dff
swfopro.dff
wfystew.dff
swmotr1.dff
wmotr1.dff
bmotr1.dff
vbmybox.dff
vwmybox.dff
vhmyelv.dff
vbmyelv.dff
vimyelv.dff
vwfypro.dff
ryder3.dff
vwfyst1.dff
wfori.dff
wfost.dff
wfyjg.dff
wfyri.dff
wfyro.dff
wfyst.dff
wmori.dff
wmost.dff
wmyjg.dff
wmylg.dff
wmyri.dff
wmyro.dff
wmycr.dff
wmyst.dff
ballas1.dff
ballas2.dff
ballas3.dff
fam1.dff
fam2.dff
fam3.dff
lsv1.dff
lsv2.dff
lsv3.dff
maffa.dff
maffb.dff
mafboss.dff
vla1.dff
vla2.dff
vla3.dff
triada.dff
triadb.dff
sindaco.dff
triboss.dff
dnb1.dff
dnb2.dff
dnb3.dff
vmaff1.dff
vmaff2.dff
vmaff3.dff
vmaff4.dff
dnmylc.dff
dnfolc1.dff
dnfolc2.dff
dnfylc.dff
dnmolc1.dff
dnmolc2.dff
sbmotr2.dff
swmotr2.dff
sbmytr3.dff
swmotr3.dff
wfybe.dff
bfybe.dff
hfybe.dff
sofybu.dff
sbmyst.dff
sbmycr.dff
bmycg.dff
wfycrk.dff
hmycm.dff
wmybu.dff
bfybu.dff
smokev.dff
wfybu.dff
dwfylc1.dff
wfypro.dff
wmyconb.dff
wmybe.dff
wmypizz.dff
bmobar.dff
cwfyhb.dff
cwmofr.dff
cwmohb1.dff
cwmohb2.dff
cwmyfr.dff
cwmyhb1.dff
bmyboun.dff
wmyboun.dff
wmomib.dff
bmymib.dff
wmybell.dff
bmochil.dff
sofyri.dff
somyst.dff
vwmybjd.dff
vwfycrp.dff
sfr1.dff
sfr2.dff
sfr3.dff
bmybar.dff
wmybar.dff
wfysex.dff
wmyammo.dff
bmytatt.dff
vwmycr.dff
vbmocd.dff
vbmycr.dff
vhmycr.dff
sbmyri.dff
somyri.dff
somybu.dff
swmyst.dff
wmyva.dff
copgrl3.dff
gungrl3.dff
mecgrl3.dff
nurgrl3.dff
crogrl3.dff
gangrl3.dff
cwfofr.dff
cwfohb.dff
cwfyfr1.dff
cwfyfr2.dff
cwmyhb2.dff
dwfylc2.dff
dwmylc2.dff
omykara.dff
wmykara.dff
wfyburg.dff
vwmycd.dff
vhfypro.dff
suzie.dff
omonood.dff
omoboat.dff
wfyclot.dff
vwmotr1.dff
vwmotr2.dff
vwfywai.dff
sbfori.dff
swfyri.dff
wmyclot.dff
sbfost.dff
sbfyri.dff
sbmocd.dff
sbmori.dff
sbmost.dff
shmycr.dff
sofori.dff
sofost.dff
sofyst.dff
somobu.dff
somori.dff
somost.dff
swmotr5.dff
swfori.dff
swfost.dff
swfyst.dff
swmocd.dff
swmori.dff
swmost.dff
shfypro.dff
sbfypro.dff
swmotr4.dff
swmyri.dff
smyst.dff
smyst2.dff
sfypro.dff
vbfyst2.dff
vbfypro.dff
vhfyst3.dff
bikera.dff
bikerb.dff
bmypimp.dff
swmycr.dff
wfylg.dff
wmyva2.dff
bmosec.dff
bikdrug.dff
wmych.dff
sbfystr.dff
swfystr.dff
heck1.dff
heck2.dff
bmycon.dff
wmycd1.dff
bmocd.dff
vwfywa2.dff
wmoice.dff
tenpen.dff
pulaski.dff
Hernandez.dff
dwayne.dff
smoke.dff
sweet.dff
ryder.dff
forelli.dff
tbone.dff
laemt1.dff
lvemt1.dff
sfemt1.dff
lafd1.dff
lvfd1.dff
sffd1.dff
lapd1.dff
sfpd1.dff
lvpd1.dff
csher.dff
lapdm1.dff
swat.dff
fbi.dff
army.dff
dsher.dff
zero.dff
rose.dff
paul.dff
cesar.dff
ogloc.dff
wuzimu.dff
torino.dff
jizzy.dff
maddogg.dff
cat.dff
claude.dff]]
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
