-- was #E1ECFE
function moduleStart ( name, title )
    return "<div style='background: #898B5E; padding:10px;' id='" .. name .. "'><img src='/ajax/loading.gif' style='float:right;display:none' id='" .. name .. "Loading'><strong>" .. title .. "</strong> <span id='" .. name .. "Status'>&nbsp;</span><br><br>";
end

function moduleEnd ( )
    return "</div>"
end

function start ( resource )
    return "<script src ='/ajax/ajax.js' type = 'text/javascript'></script><script src='/ajax/json.js' type='text/javascript'></script><script src='/ajax/exportedfunctions.js?resource=" .. resource .. "' type='text/javascript'></script>"
end