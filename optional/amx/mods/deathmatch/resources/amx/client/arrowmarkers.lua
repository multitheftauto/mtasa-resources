-- makes any arrow markers move up and down like in single player

local streamedMarkers = {}		-- { marker = { (baseX, baseY, baseZ | offsetX, offsetY, offsetZ, attachedTo = elem), anim = anim } }
local sin = math.sin

local function setMarkerZ(marker, angle)
	local info = streamedMarkers[marker]
	if not info then
		return
	end
	local baseX, baseY, baseZ
	if info.attachedTo then
		baseX, baseY, baseZ = getElementPosition(info.attachedTo)
		baseX, baseY, baseZ = baseX + info[1], baseY + info[2], baseZ + info[3]
	else
		baseX, baseY, baseZ = unpack(info)
	end
	setElementPosition(marker, baseX, baseY, baseZ + sin(angle))
end

addEventHandler('onClientElementStreamIn', getRootElement(),
	function()
		if getElementType(source) ~= 'marker' or getMarkerType(source) ~= 'arrow' then
			return
		end
		local attachedTo = getElementAttachedTo(source)
		if attachedTo then
			local x, y, z = getElementPosition(source)
			local baseX, baseY, baseZ = getElementPosition(attachedTo)
			detachElements(source)
			streamedMarkers[source] = { x - baseX, y - baseY, z - baseZ, attachedTo = attachedTo }
		else
			streamedMarkers[source] = { getElementPosition(source) }
		end
		streamedMarkers[source].anim = Animation.createAndPlay(source, { from = 0, to = 2*math.pi, time = 2000, repeats = 0, fn = setMarkerZ })
	end
)

addEventHandler('onClientElementStreamOut', getRootElement(),
	function()
		if getElementType(source) ~= 'marker' or getMarkerType(source) ~= 'arrow' then
			return
		end
		local info = streamedMarkers[source]
		if info.attachedTo then
			attachElements(source, info.attachedTo, unpack(info))
		else
			setElementPosition(source, unpack(info))
		end
		info.anim:remove()
		streamedMarkers[source] = nil
	end
)
