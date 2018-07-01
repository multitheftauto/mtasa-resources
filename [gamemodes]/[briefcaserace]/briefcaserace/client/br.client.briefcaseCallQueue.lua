local root = getRootElement()
local briefcaseResource
local callQueue = {}

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()),
function (resource)
	briefcaseResource = getResourceFromName("briefcase")
	if (briefcaseResource) then
		-- resource already started
--outputDebugString("briefcase    resource already started")
		addEventHandler("onClientResourceStop", root, onBriefcaseStop)
	else
		-- resource not yet started
--outputDebugString("briefcase    resource not yet started")
		addEventHandler("onClientResourceStart", root, onBriefcaseStart)
	end
end
)

function onBriefcaseStart(resource)
	if (getResourceName(resource) == "briefcase") then
		removeEventHandler("onClientResourceStart", root, onBriefcaseStart)
		addEventHandler("onClientResourceStop", root, onBriefcaseStop)
		briefcaseResource = resource
		-- pop queue
		for i=1,#callQueue do
--outputDebugString("callingg " .. callQueue[i].fn)
			call(resource, callQueue[i].fn, unpack(callQueue[i].args))
		end
	end
end

function onBriefcaseStop(resource)
	if (getResourceName(resource) == "briefcase") then
		removeEventHandler("onClientResourceStop", root, onBriefcaseStop)
		addEventHandler("onClientResourceStart", root, onBriefcaseStart)
		briefcaseResource = false
	end
end


function scheduleBriefcaseCall(functionName, ...)
	if (briefcaseResource) then
--outputDebugString("1. calling " .. functionName)
		call(briefcaseResource, functionName, unpack(arg))
	else
--outputDebugString("2. calling " .. functionName)
		table.insert(callQueue, {fn = functionName, args = arg})
	end
end
