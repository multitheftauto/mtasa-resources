--
-- Anti-Cheat Control Panel
--
-- c_model_switcher.lua
--

modifiedPlayerModels = {}

function receiveModifiedPlayerModels(list)
	modifiedPlayerModels = list
	setTimer(checkForModifiedPlayerModel, 1000, 0)
end
addEvent("acpanel.gotModifiedPlayerModelsList", true)
addEventHandler("acpanel.gotModifiedPlayerModelsList", localPlayer, receiveModifiedPlayerModels)

function checkForModifiedPlayerModel()
	local model = getElementModel(localPlayer)
	-- See if we're using a modified model
	if (not isModelModified(model)) then
		return true
	end
	outputChatBox("This server doesn't allow modified player models (ID "..model..") switching models.", 255, 0, 0)
	local maxLoops = 0
	-- Find another model for us to use
	while true do
		model = model + 1
		if (model > 312) then -- Start from the begging if reached the end
			model = 1
		end
		if (not isModelModified(model) and setElementModel(localPlayer, model)) then -- Found one to use
			return true
		end
		maxLoops = maxLoops + 1
		if (maxLoops == 312) then -- In the unlikely event every model is modified
			outputChatBox("Unable to find an unmodified player model, killing you instead.", 255, 0, 0)
			setElementHealth(localPlayer, 0)
			return false
		end
	end
end

function isModelModified(model)
	for i, m in ipairs(modifiedPlayerModels) do
		if (m == model) then
			return true
		end
	end
	return false
end
