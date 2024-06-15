local radioSpeakers = {}
local blackColor = tocolor(0, 0, 0, 255)
local textColor = tocolor(150, 50, 150, 255)
local radioTable = {
	{"[Top 40 Mix] BAYERN Radio - Top40", "http://stream.antenne.de:80/top-40"},
	{"[Top 40 Mix] 1.FM - Absolute Top 40", "http://185.33.21.111:80/top40_32a"},
	{"[Top 40 Pop] Power 181", "http://listen.181fm.com/181-power_128k.mp3"},
	{"[80s] BAYERN Radio -  80ers", "http://stream.antenne.de:80/80er-kulthits"},
	{"[90s] BAYERN Radio -  90ers", "http://stream.antenne.de:80/90er-hits"},
	{"[RAP] RadioRecord RapClassics", "https://radiorecord.hostingradio.ru/rapclassics96.aacp"},
	{"[RAP] 1001 The Heat", "http://149.56.157.81:8569/listen.pls"},
	{"[HipHop] HOT 108 JAMZ", "https://live.powerhitz.com/hot108"},
	{"[Mix] Antena1 94.7", "http://51.254.29.40:80/stream2"},
	{"[Mix] Mix96", "https://radiorecord.hostingradio.ru/mix96.aacp"},
	{"[Mix] Radio SA", "https://y0b.net/radiosa.m3u"},
	{"[Mix] 181 The Mix", "http://listen.livestreamingservice.com/181-themix_64k.aac"},
	{"[DANCE] Dance One", "http://185.33.21.112:80/dance_128"},
	{"[DANCE] Dance Wave", "https://dancewave.online/dance.aac"},
	{"[DANCE] Dance Wave Retro", "https://retro.dancewave.online/retrodance.aac"},
	{"[DANCE] 1.FM - Deep House", "http://185.33.21.111:80/deephouse_64a"},
	{"[POP] Antenne Bayern", "http://stream.antenne.de:80/antenne"},
	{"[Roadman] UK DRILL RAP", "https://stream.zeno.fm/bmqy8pp9am8uv"},
	{"[Roadman] UK DRILL FM", "https://stream.zeno.fm/zbhn3mx74bhvv"},
	{"[Ghetto] Alabama's Finest", "http://66.85.47.227:8000/stream"},
	{"[HardBass] Russian HardBASS", "https://radiorecord.hostingradio.ru/hbass96.aacp"},
	{"[Trap] RadioRecord Trap96", "https://radiorecord.hostingradio.ru/trap96.aacp"},
	{"[Drift] Phonk Radio", "https://s2.radio.co/s2b2b68744/listen"},
	{"[Drift] Phonk Radio #2", "https://radiorecord.hostingradio.ru/phonk96.aacp"},
	{"[Drift] Phonk Radio #3", "https://stream.zeno.fm/lfrqotftczpuv"},
	{"[Drift] Phonk Radio #4", "https://stream.zeno.fm/ym4ywb2ezs8uv"},
	{"[Drift] Phonk Radio #5", "https://stream.zeno.fm/aeoju66zrnfuv"},
	{"[Drift] Phonk Radio #6", "https://stream.zeno.fm/71ntub27u18uv"},
	{"[Dubstep] Dub96", "https://radiorecord.hostingradio.ru/dub96.aacp"},
	{"[Random] 105.3 Easy POP and 90s", "http://157.90.133.87:8076/stream"},
	{"[House] True House Chill", "http://stream.truehouse.net:8000/chill"},
	{"[RnB Hits] PowerHitz", "http://66.85.88.174/realrnb"},
	{"[ROCK] BAYERN Radio - 90er Rock", "http://stream.antenne.de:80/90er-rock"},
	{"[ROCK] BAYERN Radio - Classic Rock", "http://stream.antenne.de:80/classic-rock-live"},
	{"[ROCK] 1.FM Classic Rock", "http://185.33.21.111:80/crock_64a"},
	{"[PT Radio & International] Antena1", "https://www.antena1.com.br/stream/"},
	{"[PT Radio] AlienWare", "https://sonic.paulatina.co:10995"}, -- http://elhuecodelasalsa.com/
	{"[Random] 100 Hit Radio", "https://radio1.streamserver.link/radio/8010/100hit-aac"},
	{"[Office] Office Hitz", "http://66.85.88.174/officemix"},
	{"[Pop] Antena1 - 94.7fm", "http://5.135.83.159:80/stream2"},
	{"[Blues] XRDS Blues", "http://198.58.106.133:8321/stream"},
	{"[RU] RussianMix", "https://radiorecord.hostingradio.ru/rus96.aacp"},
	{"[Jazz] Bay Smooth Jazz", "http://185.33.21.111:80/smoothjazz_64a"},
	{"[Trance] Amsterdam Trance", "http://185.33.21.111:80/atr_128"},
	{"[Trance] Absolute Trance Euro", "http://185.33.21.112:80/trance_128"},
	{"[Lovesongs] 100Hits Love", "https://194.97.151.139/lovesongs"},
	{"[ARAB] Arab HitsRadio", "https://icecast.omroep.nl/funx-arab-bb-mp3"},
	{"[ARAB] Arabesk FM", "https://yayin.arabeskfm.biz:8042/"},
	{"[90's] Star 90's", "http://listen.181fm.com/181-star90s_128k.mp3"},
	{"[Random] Hitradio OE3", "https://orf-live.ors-shoutcast.at/oe3-q1a.m3u"},
	{"[Jewish Radio] Jewish Music Stream", "https://stream.jewishmusicstream.com:8000/stream"},
	{"[Thailand Radio] COOLFahrenheit93", "http://103.253.132.7:5004"},
	{"[India] Bollywood Hits Radio", "https://stream.zeno.fm/rqqps6cbe3quv"},
	{"[Russia Radio 1] TatarRadiosi", "https://tatarradio.hostingradio.ru/tatarradio320.mp3"},
	{"[Russia Radio 2] Shanson", "https://chanson.hostingradio.ru:8041/chanson256.mp3"},
	{"[Russia Radio 3] EuropaRussia", "https://europarussia.ru:8006/live"},
	{"[Russia Radio 4] Blatnyachok", "http://89.188.115.214:8000"},
	{"[80s] Russian & International 80s", "https://radiorecord.hostingradio.ru/198096.aacp"},
	{"[90s] Russian & International 90s", "https://radiorecord.hostingradio.ru/sd9096.aacp"},
	{"[Top] 1.FM Hits 2000-s", "http://185.33.21.111:80/hits2000_128"},
	{"[2000s] BAYERN Radio -  2000-s", "http://stream.antenne.de:80/2000er-hits"},
	{"[2010s] BAYERN Radio -  2010-s", "http://stream.antenne.de:80/2010er-hits"},
	{"[70s] SomaFM Seventies", "https://ice1.somafm.com/seventies-128-aac"},
	{"[80s] BAYERN Radio -  80ers", "http://stream.antenne.de:80/80er-kulthits"},
	{"[90s] BAYERN Radio -  90ers", "http://stream.antenne.de:80/90er-hits"}, -- Alternative: http://s1-webradio.antenne.de/90er-hits
	{"[Top] BAYERN Radio -  Top 1000", "http://stream.antenne.de:80/top-1000"},
	{"[Random] BAYERN Radio - Chillout", "http://stream.antenne.de:80/chillout"},
	{"[Random] BAYERN Radio - Relax", "http://stream.antenne.de:80/relax"},
	{"[Random] BAYERN Radio - Lounge", "http://stream.antenne.de:80/lounge"},
	{"[Random] BAYERN Radio - In The Mix", "http://stream.antenne.de:80/in-the-mix"},
	{"[Random] BAYERN Radio - Spring Hits", "http://stream.antenne.de:80/fruehlings-hits"},
	{"[Random] BAYERN Radio - Happy Hits", "http://stream.antenne.de:80/happy-hits"},
	{"[Random] BAYERN Radio - Greatest Hits", "http://stream.antenne.de:80/greatest-hits"},
	{"[Random] BAYERN Radio - Party Hits", "http://stream.antenne.de:80/party-hits"},
	{"[Random] BAYERN Radio - Pop XXL", "http://stream.antenne.de:80/pop-xxl"},
	{"[Dance / RU] RadioRecord", "https://radiorecord.hostingradio.ru/rr_main96.aacp"},
	{"[Deep96] RadioRecord", "https://radiorecord.hostingradio.ru/deep96.aacp"},
	{"[Mix96] RadioRecord", "https://radiorecord.hostingradio.ru/mix96.aacp"},
	{"[Uplift96] RadioRecord", "https://radiorecord.hostingradio.ru/uplift96.aacp"},
	{"[Ambient96] RadioRecord", "https://radiorecord.hostingradio.ru/ambient96.aacp"},
	{"[Darkside96] RadioRecord", "https://radiorecord.hostingradio.ru/darkside96.aacp"},
	{"[Summer96] RadioRecord", "https://radiorecord.hostingradio.ru/summerparty96.aacp"},
	{"[Dance] BAYERN Radio - Dance XXL", "http://stream.antenne.de:80/dance-xxl"},
	{"[Dance] FunX Dance", "https://icecast.omroep.nl/funx-dance-bb-mp3"},
}

function speakersysGUI()
	if (speakersys) then
		return true
	end

	local screenX, screenY = guiGetScreenSize()

	speakersys = guiCreateWindow((screenX - 325) / 1.1, (screenY - 380) / 1.4, 325, 380, "SPEAKER MUSIC (RADIO/MP3)", false)
	guiSetAlpha(speakersys, 1)
	guiWindowSetSizable(speakersys, false)
	urlGrid = guiCreateGridList(10, 54, 304, 139, false, speakersys)
	urlEdit = guiCreateEdit(10, 25, 304, 26, "http://stream.antenne.de:80/80er-kulthits", false, speakersys)
	setBtn = guiCreateButton(10, 200, 150, 30, "CREATE SPEAKER", false, speakersys)
	destroyBox = guiCreateButton(162, 200, 150, 30, "DESTROY SPEAKER", false, speakersys)
	pauseBtn = guiCreateButton(10, 235, 150, 30, "Play - Pause", false, speakersys)
	close = guiCreateButton(162, 235, 150, 30, "Close", false, speakersys)

	xmlSetting = guiCreateCheckBox(15, 345, 160, 17, "Toggle other boxes", false, false, speakersys)
	enableLabel = guiCreateLabel(167, 345, 150, 17, "", false, speakersys)
	urlColumn = guiGridListAddColumn(urlGrid, "Internet Radio Station", 0.8)
	guiSetVisible(speakersys, false)

	if (not getSetting("box") or getSetting("box") == "ENABLED") then
		enable = true
		guiCheckBoxSetSelected(xmlSetting, true)
		setSetting("box", "ENABLED")
		guiSetText(enableLabel, "You hear all speakers")
		guiLabelSetColor(enableLabel, 0, 255, 0)
	elseif getSetting("box") == "DISABLED" then
		enable = nil
		guiCheckBoxSetSelected(xmlSetting, false)
		guiSetText(enableLabel, "You only hear your speaker")
		guiLabelSetColor(enableLabel, 255, 0, 0)
	end

	addEventHandler("onClientGUIClick", urlGrid, updateUrlEdit, false)

	for key, ent in pairs(radioTable) do
		local row = guiGridListAddRow(urlGrid)
		guiGridListSetItemText(urlGrid, row, urlColumn, ent[1], false, false)
	end
	setTimer(getRadioInfo, 10000, 0)
end
addEventHandler("onClientResourceStart", resourceRoot, speakersysGUI)

function updateUrlEdit()
	if (guiGridListGetItemText(urlGrid, guiGridListGetSelectedItem(urlGrid), 1) ~= "") then
		for key, ent in pairs(radioTable) do
			if (guiGridListGetItemText(urlGrid, guiGridListGetSelectedItem(urlGrid), 1) == ent[1]) then
				guiSetText(urlEdit, ent[2])
			end
		end
	end
end

function openGUI()
	if (guiGetVisible(speakersys)) then
		guiSetVisible(speakersys, false)
		showCursor(false)
	else
		guiSetVisible(speakersys, true)
		showCursor(true)
	end
end
addEvent("Speaker.openInterface", true)
addEventHandler("Speaker.openInterface", root, openGUI)
bindKey("F3", "down", openGUI)

function clickEvent()
	if (source == setBtn) then
		local vol = 1.0
		local url = guiGetText(urlEdit)

		if not (url) or (url == "") or (string.len(url) > 550) or not string.find(url, "http") then
			return outputChatBox("SPEAKER: Invalid URL, please check your input!", 255, 0, 0)
		end

		triggerServerEvent("speaker.startStream", localPlayer, url, vol)

	elseif (source == close) then
		openGUI()
	elseif (source == pauseBtn) then
		triggerServerEvent("speaker.pause", localPlayer)
	elseif (source == destroyBox) then
		triggerServerEvent("speaker.destroy", localPlayer)
	elseif (source == xmlSetting) then
		enable = not enable

		if (enable) then
			outputChatBox("NOTE: Reconnect to listen to deactivated songs again", 0, 255, 0)
			setSetting("box", "ENABLED")
			guiCheckBoxSetSelected(xmlSetting, true)
			guiSetText(enableLabel, "You hear all speakers")
			guiLabelSetColor(enableLabel, 0, 255, 0)
		else
			setSetting("box", "DISABLED")
			guiCheckBoxSetSelected(xmlSetting, false)
			guiSetText(enableLabel, "You only hear your music")
			guiLabelSetColor(enableLabel, 255, 0, 0)
		end
	end
end
addEventHandler("onClientGUIClick", resourceRoot, clickEvent)

function setData(value, theType, serial)
	if (not radioSpeakers[serial]) then
		return
	end

	if (not isElement(radioSpeakers[serial][1])) then
		return
	end

	if (theType == "vol") then
		setSoundVolume(radioSpeakers[serial][1], value)
	elseif (theType == "dist") then
		setSoundMaxDistance(radioSpeakers[serial][1], 65)
	elseif (theType == "destroy") then
		stopSound(radioSpeakers[serial][1])
		destroyElement(radioSpeakers[serial][2])
		radioSpeakers[serial] = nil
	end
end
addEvent("speaker.setData", true)
addEventHandler("speaker.setData", root, setData)

function setPaused(serial)
	if (not radioSpeakers[serial]) then
		return
	end

	if (not isElement(radioSpeakers[serial][1])) then
		return
	end
	setSoundPaused(radioSpeakers[serial][1], not isSoundPaused(radioSpeakers[serial][1]))
end
addEvent("speaker.ps", true)
addEventHandler("speaker.ps", root, setPaused)

function setBox(str)
	if (not str) then
		return
	end

	for serial, ent in pairs(str) do

		if (radioSpeakers[serial] and isElement(radioSpeakers[serial][1])) then
			destroyElement(radioSpeakers[serial][1])
			destroyElement(radioSpeakers[serial][2])
		end

		if (isElement(ent[1])) then
			if (ent[11] == getPlayerName(localPlayer) or enable) then
				local radio = playSound3D(ent[2], ent[3], ent[4], ent[5], true, false)
				setElementData(radio, "ob", ent[11])
				local dumm = createObject(1337, ent[3], ent[4], ent[5])
				setElementAlpha(dumm, 0)
				setElementCollisionsEnabled(dumm, false)
				attachElements(dumm, ent[1], -0.32, -0.22, 0.8)
				radioSpeakers[serial] = {radio, dumm}

				if (ent[6] and isElement(ent[6])) then
					attachElements(radio, ent[6])
				end

				setElementInterior(radio, ent[7])
				setElementDimension(radio, ent[8])
				setSoundVolume(radio, ent[9])
				setSoundMaxDistance(radio, ent[10])
				setInteriorSoundsEnabled(false)
			end
		end
	end
end
addEvent("speaker.setBox", true)
addEventHandler("speaker.setBox", root, setBox)

function getRadioInfo()
	for key, radio in pairs(radioSpeakers) do
		if (radio[1] and isElement(radio[1])) then
			radioSpeakers[key][3] = nil
			table.insert(radioSpeakers[key], getSoundMetaTags(radio[1]).stream_title or getSoundMetaTags(radio[1]).title)
		end
	end
end

function drawData()
	for key, radio in pairs(radioSpeakers) do
		if (radio[2] and isElement(radio[2] and radio[1])) then
			local eX, eY, eZ = getElementPosition(radio[2])
			eZ = (eZ + 1)
			local sx, sy = getScreenFromWorldPosition(eX, eY, eZ)
			local cameraX, cameraY, cameraZ = getCameraMatrix()

			if (sx and sy) then
				if (not enable and getElementData(radio[1], "ob") ~= getPlayerName(localPlayer)) then
					stopSound(radio[1])
					destroyElement(radio[2])
					radioSpeakers[key] = nil
					return false
				end

				local distance = getDistanceBetweenPoints3D(cameraX, cameraY, cameraZ, eX, eY, eZ)

				if (distance <= 65 and isLineOfSightClear(cameraX, cameraY, cameraZ, eX, eY, eZ, true, false, false, false, false, false) and radio[3]) then
					local height = dxGetFontHeight(1, "default-bold")
					local owner = getElementData(radio[1], "ob")
					text = radio[3]

					if toggle then
						text = "Owner: " .. owner .. " - " .. text .. ""
					end

					local width = dxGetTextWidth(text, 1, "default-bold")

					dxDrawRectangle(sx - width / 2 - 5, sy, width + 8, height, blackColor, false)
					dxDrawText(text, sx - width / 2, sy, sx - width / 2, sy, textColor, 1, "default-bold")
				end
			end
		end
	end
end
addEventHandler("onClientRender", root, drawData)

function toggleCursor(key, state)
	toggle = not toggle
end
bindKey("lalt", "both", toggleCursor)

settingsXMLFile = nil

function onStartup()
	triggerServerEvent("getSpeakers", localPlayer)

	settingsXMLFile = xmlLoadFile("settings.xml")
	if not settingsXMLFile then
		settingsXMLFile = xmlCreateFile("settings.xml", "settings")
	end
end
addEventHandler("onClientResourceStart", resourceRoot, onStartup)

onStartup()

function setSetting(setting, value)
	if value then
		value = tostring(value)
		xmlNodeSetAttribute(settingsXMLFile, setting, value)
	end
	xmlSaveFile(settingsXMLFile)
end

function getSetting(setting)
	if setting then
		local val = xmlNodeGetAttribute(settingsXMLFile, setting)
		if val then
			return val
		else
			return false
		end
	else
		return false
	end
end
