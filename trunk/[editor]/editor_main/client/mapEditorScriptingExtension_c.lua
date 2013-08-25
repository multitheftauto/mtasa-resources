-- FILE: 	mapEditorScriptingExtension_c.lua
-- PURPOSE:	Prevent the map editor feature set being limited by what MTA can load from a map file by adding a script file to maps
-- VERSION:	RemoveWorldObjects (v1) AutoLOD (v1) BreakableObjects (v1)

function requestLODsClient()
	triggerServerEvent("requestLODsClient", resourceRoot)
end
addEventHandler("onClientResourceStart", resourceRoot, requestLODsClient)

function setLODsClient(lodTbl)
	for i, model in ipairs(lodTbl) do
		engineSetModelLODDistance(model, 300)
	end
end
addEvent("setLODsClient", true)
addEventHandler("setLODsClient", resourceRoot, setLODsClient)

function applyBreakableState()
	for k, obj in pairs(getElementsByType("object", resourceRoot)) do
		local breakable = getElementData(obj, "breakable")
		if breakable then
			setObjectBreakable(obj, breakable == "true")
		end
	end
end
addEventHandler("onClientResourceStart", resourceRoot, applyBreakableState)