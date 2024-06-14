local sounds, antiSpam = {}, {}

function startStream(url, vol)

	if (not antiSpam[client]) then
		antiSpam[client] = 0
		setTimer(function(plr)
			antiSpam[plr] = nil end, 10000, 1, client)
	end

	antiSpam[client] = ((antiSpam[client] or 0) + 1)

	if (antiSpam[client] > 5) then -- More than 5 boxes in 10 seconds
		return false
	end

	local dist = 65
	local serial = getPlayerSerial(client)

	if (not sounds[client]) then
		sounds[client] = {}
	end

	if (sounds[client][serial] and isElement(sounds[client][serial][1])) then
		destroyElement(sounds[client][serial][1])
	end

	local x, y, z = getElementPosition(client)
	local interior = getElementInterior(client)
	local dimension = getElementDimension(client)

	local box = createObject(2229, x - 0.5, y + 0.5, z - 1, 0, 0, rx)
	setElementDimension(box, dimension)
	setElementInterior(box, interior)

	local vehicle = getPedOccupiedVehicle(client)

	if (isPedInVehicle(client) and vehicle and isElement(vehicle)) then
		sounds[client][serial] = {box, url, x, y, z + 2, vehicle, interior, dimension, vol, dist, getPlayerName(client)}
		setElementCollisionsEnabled(box, false)
		attachElements(box, vehicle, -0.7, -1.5, -0.1, 0, 90, 0)
	else
		sounds[client][serial] = {box, url, x, y, z, false, interior, dimension, vol, dist, getPlayerName(client)}
		setElementCollisionsEnabled(box, false)
	end

	outputServerLog("[SPEAKER] "..getPlayerName(client):gsub("#%x%x%x%x%x%x", "").." created speaker with URL: "..url)
	triggerClientEvent(root, "speaker.setBox", client, sounds[client])
end
addEvent("speaker.startStream", true)
addEventHandler("speaker.startStream", root, startStream)

function setting(vol, dist)
	local serial = getPlayerSerial(client)

	if (sounds[client]) then
		if (vol) then
			triggerClientEvent(root, "speaker.setData", client, vol, "vol", serial)
			return true
		end

		if (dist) then
			triggerClientEvent(root, "speaker.setData", client, dist, "dist", serial)
			return true
		end
	end
end
addEvent("speaker.change", true)
addEventHandler("speaker.change", root, setting)

function openGUI(player)
	triggerClientEvent(player, "Speaker.openInterface", player)
end
addCommandHandler("sound", openGUI, false, false)
addCommandHandler("music", openGUI, false, false)
addCommandHandler("musica", openGUI, false, false)
addCommandHandler("song", openGUI, false, false)
addCommandHandler("radio", openGUI, false, false)
addCommandHandler("speaker", openGUI, false, false)

function delAdmin(player, cmd, ID)
	if (hasObjectPermissionTo(player, "function.kickPlayer", false)) then
		local s2 = getPlayerFromName(ID)

		if (ID and s2 and sounds[s2]) then
			local serial = getPlayerSerial(s2)
			destroyElement(sounds[s2][serial][1])
			triggerClientEvent(root, "speaker.setData", player, false, "destroy", serial)
			outputChatBox("Speaker removed!", player, 0, 255, 0)
			sounds[s2] = nil
		else
			outputChatBox("Error, the player does not exist or does not have a speaker.", player, 255, 0, 0)
		end
	end
end
addCommandHandler("delbox", delAdmin)

function destroySpeaker()
	local serial = getPlayerSerial(client)
	if (sounds[client]) then
		destroyElement(sounds[client][serial][1])
		triggerClientEvent(root, "speaker.setData", client, false, "destroy", serial)
		sounds[client] = nil
	end
end
addEvent("speaker.destroy", true)
addEventHandler("speaker.destroy", root, destroySpeaker)

function pauseSpeaker()
	if (sounds[client]) then
		local serial = getPlayerSerial(client)
		triggerClientEvent(root, "speaker.ps", client, serial)
	end
end
addEvent("speaker.pause", true)
addEventHandler("speaker.pause", root, pauseSpeaker)

function getSpeakers()
	local ltable = {}
	local speakers = 0

	for k, v in pairs(sounds) do
		for k2, v2 in pairs(v) do
			ltable[k2] = sounds[k][k2]
			speakers = speakers + 1
		end
	end

	if (speakers > 0) then
		triggerClientEvent(client, "speaker.setBox", client, ltable)
	end
end
addEvent("getSpeakers", true)
addEventHandler("getSpeakers", root, getSpeakers)

function onPlayerQuit()
	local serial = getPlayerSerial(source)

	if (sounds[source]) then
		destroyElement(sounds[source][serial][1])
		triggerClientEvent(root, "speaker.setData", source, false, "destroy", serial)
		sounds[source] = nil
	end
end
addEventHandler("onPlayerQuit", root, onPlayerQuit)