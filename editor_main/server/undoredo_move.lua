justCreated = {}
local selectedElements = {}

local function isElementMoved(element)
	if not selectedElements[element] then
		return false
	end

	local oldX,  oldY,  oldZ  = selectedElements[element].oldX,  selectedElements[element].oldY,  selectedElements[element].oldZ
	local oldRX, oldRY, oldRZ = selectedElements[element].oldRX, selectedElements[element].oldRY, selectedElements[element].oldRZ
	local oldScale = selectedElements[element].oldScale

	local newX,  newY,  newZ  = edf.edfGetElementPosition(element)
	local newRX, newRY, newRZ = edf.edfGetElementRotation(element)
	local newScale = edf.edfGetElementScale(element)


	return oldX ~= newX or oldY ~= newY or oldZ ~= newZ or oldRX ~= newRX or oldRY ~= newRY or oldRZ ~= newRZ or oldScale ~= newScale
end

addEventHandler("onElementSelect", root,
	function ()
		selectedElements[source] = {}
		selectedElements[source].oldX, selectedElements[source].oldY, selectedElements[source].oldZ =
			edf.edfGetElementPosition(source)
		selectedElements[source].oldRX, selectedElements[source].oldRY, selectedElements[source].oldRZ =
			edf.edfGetElementRotation(source)
		selectedElements[source].oldScale = edf.edfGetElementScale(source)
	end
)

addEventHandler("onElementDrop", root,
	function ()
		if (client and not isPlayerAllowedToDoEditorAction(client,"moveElement")) or (client and client~=edf.edfGetCreatorClient(source) and not isPlayerAllowedToDoEditorAction(client,"moveOtherElement")) then
			-- Reset position if moved
			if isElementMoved(source) then
				editor_gui.outputMessage ("You don't have permissions to move that element!", client,255,0,0)
				edf.edfSetElementPosition(source,selectedElements[source].oldX,selectedElements[source].oldY,selectedElements[source].oldZ)
				edf.edfSetElementRotation(source,selectedElements[source].oldRX,selectedElements[source].oldRY,selectedElements[source].oldRZ)
				edf.edfSetElementScale(source,selectedElements[source].oldScale)
			end
			-- Set as no longer selected
			selectedElements[source] = nil
			return
		end

		--ignore the first placement
		if justCreated[source] then
			justCreated[source] = nil
		elseif isElementMoved(source) then
			local source = source --!w #2818
			triggerEvent(
				"onElementMove_undoredo", source,
				selectedElements[source].oldX, selectedElements[source].oldY, selectedElements[source].oldZ,
				selectedElements[source].oldRX, selectedElements[source].oldRY, selectedElements[source].oldRZ,
				selectedElements[source].oldScale
			)
		end
		selectedElements[source] = nil
	end
)
