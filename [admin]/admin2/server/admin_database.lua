--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	server/admin_database.lua
*
*	Original File by lil_Toady
*
**************************************]]

-- ensure old database file gets renamed
if(fileExists("conf\\settings.db")) then
    local bRemoveOldFile = true
    
    if(not fileExists("admin.db")) then
        local uOldFile = fileOpen("conf\\settings.db")
        local uNewFile = fileCreate("admin.db")
        
        -- rename file
        if(uOldFile and uNewFile) then
            fileWrite(uNewFile, fileRead(uOldFile, fileGetSize(uOldFile)))
            fileFlush(uNewFile)
        end
        
        -- ensure file handlers getting closed
        if(uOldFile) then
            fileClose(uOldFile)
        end
        
        if(uNewFile) then
            fileClose(uNewFile)
        end
    else
        bRemoveOldFile = false
    end
    
    -- remove old database file on success
    if(bRemoveOldFile) then
        fileDelete("conf\\settings.db")
    end
end

db = {
    connection = dbConnect("sqlite", "admin.db"),
    results = {},
    timers = {},
    threads = {}
}

function db.timeout(handle)
    local cr = db.threads[handle]
    dbFree(handle)
    if (cr) then
        coroutine.resume(cr)
    end
end

function db.callback(handle)
    local cr = db.threads[handle]
    if (cr) then
        db.results[cr] = dbPoll(handle, 0)
    end

    dbFree(handle)

    if (cr) then
        if (db.timers[cr] and isTimer(db.timers[cr])) then
            killTimer(db.timers[cr])
        end
        coroutine.resume(cr)
    end
end

function db.query(query, ...)
    local cr = coroutine.running()
    
    local handle = dbQuery(db.callback, db.connection, query, ...)

    db.threads[handle] = cr
    db.timers[cr] = setTimer(db.timeout, 1000, 1, handle)

    coroutine.yield()

    db.threads[handle] = nil
    local result = db.results[cr]
    db.results[cr] = nil
    if (result) then
        return result
    end
    return {}
end

function db.exec(query, ...)
    dbExec(db.connection, query, ...)
end

function db.last_insert_id()
    local result = db.query("SELECT last_insert_rowid() as id")
    if (result and result[1]) then
        return result[1].id
    end
    return false
end
