local labelColor = {}
_guiLabelSetColor = guiLabelSetColor

function guiLabelSetColor ( label, ... )
    if not isElement ( label ) or getElementType ( label ) ~= "gui-label" then
        return false
    end
    
    local c = {...}
    for i=1,3 do
        c[i] = type ( c[i] ) == "number" and ( ( c[i] <= 255 and c[i] >= 0 ) and c[i] or 0 ) or 0
    end
    
    labelColor[label] = { c[1], c[2], c[3] }
    
    return _guiLabelSetColor ( label, c[1], c[2], c[3] )
end



function guiLabelGetColor ( label )
    if not isElement ( label ) or getElementType ( label ) ~= "gui-label" then
        return false
    end
    
    if not labelColor[label] then
        return 255, 255, 255
    end
    
    return unpack ( labelColor[label] )
end





_guiBringToFront = guiBringToFront
function guiBringToFront ( gui )
    if not isElement ( gui ) then
        return false
    end

    _guiBringToFront ( gui )

    if isElement ( warningWnd ) and gui ~= warningWnd then
        _guiBringToFront ( warningWnd )
    end

    return true
end