editorElements = { }

function isEditorElement(element)
	if not element or not isElement(element) or not editorElements[element] then
		return false
	else
		return true
	end
end

function registerEditorElements(...)
	for k,element in ipairs(arg) do
		editorElements[element] = true
	end
end
