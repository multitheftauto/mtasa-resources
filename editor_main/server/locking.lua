local locked = {}

function getLockedElement(client)
	return locked[client]
end

function setLockedElement(client, element)
	if isElement(getLockedElement(client)) then
		setElementData(locked[client], "me:locked", false)
	end
	if element then
		setElementData(element, "me:locked", client)
		locked[client] = element
	else
		locked[client] = nil
	end
end

addEventHandler("doLockElement", root,
	function ()
		setLockedElement(client, source)
	end
)

local function removeClientLock()
	local client = client or source
	setLockedElement(client, nil)
end

addEventHandler("doUnlockElement", root, removeClientLock)
addEventHandler("onPlayerQuit", root, removeClientLock)
