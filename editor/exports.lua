function import(...)
    local editor_main = getResourceFromName("editor_main")
    return call(editor_main, "import", ...)
end
