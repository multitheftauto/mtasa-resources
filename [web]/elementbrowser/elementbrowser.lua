function getElementInfo ( element )
    local data = getAllElementData(element)
    local childCount = getElementChildren(element)
    if ( childCount ) then
        childCount = #childCount
    else
        childCount = 0
    end
    return getElementType(element), getElementID(element),childCount, data
end