justCreated = {}
local selectedElements = {}

addEventHandler("onElementSelect", getRootElement(),
	function ()
		selectedElements[source] = {}
		selectedElements[source].oldX, selectedElements[source].oldY, selectedElements[source].oldZ =
			edf.edfGetElementPosition(source)
		selectedElements[source].oldRX, selectedElements[source].oldRY, selectedElements[source].oldRZ =
			edf.edfGetElementRotation(source)
	end
)

addEventHandler("onElementDrop", getRootElement(),
	function ()
		--ignore the first placement
		if justCreated[source] then
			justCreated[source] = nil
		else
			local source = source --!w #2818
			triggerEvent(
				"onElementMove_undoredo", source,
				selectedElements[source].oldX, selectedElements[source].oldY, selectedElements[source].oldZ,
				selectedElements[source].oldRX, selectedElements[source].oldRY, selectedElements[source].oldRZ
			)
		end
		selectedElements[source] = nil
	end
)
