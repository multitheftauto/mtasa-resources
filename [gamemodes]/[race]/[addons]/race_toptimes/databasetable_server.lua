--
-- databasetable_server.lua
--
-- A Lua table which is loaded/saved from the sqlite database
-- Handled column types are TEXT and REAL
--

SDatabaseTable = {}
SDatabaseTable.__index = SDatabaseTable
SDatabaseTable.instances = {}


---------------------------------------------------------------------------
--
-- SDatabaseTable:create()
--
--
--
---------------------------------------------------------------------------
function SDatabaseTable:create(name,columns,columnTypes)
    local id = #SDatabaseTable.instances + 1
    SDatabaseTable.instances[id] = setmetatable(
        {
            id = id,
            name = name,
            columns = columns,
            columnTypes = columnTypes,
            rows = {},
        },
        self
    )
    SDatabaseTable.instances[id]:postCreate()
    return SDatabaseTable.instances[id]
end


---------------------------------------------------------------------------
--
-- SDatabaseTable:destroy()
--
--
--
---------------------------------------------------------------------------
function SDatabaseTable:destroy()
    SDatabaseTable.instances[self.id] = nil
    self.id = 0
    ped = nil
    vehicle = nil
end


---------------------------------------------------------------------------
--
-- SDatabaseTable:postCreate()
--
--
--
---------------------------------------------------------------------------
function SDatabaseTable:postCreate()
    -- Set column types as strings if not set
    while #self.columnTypes < #self.columns do
        table.insert( self.columnTypes, 'TEXT' )
    end
end


---------------------------------------------------------------------------
--
-- SDatabaseTable:safestring()
--
--
--
---------------------------------------------------------------------------
function safestring( s )
    -- escape '
    return s:gsub( "(['])", "''" )
end

function qsafestring( s )
    -- ensure is wrapped in '
    return "'" .. safestring(s) .. "'"
end

function qsafetablename( s )
    return qsafestring(s)
end


---------------------------------------------------------------------------
--
-- SDatabaseTable:load()
--
--
--
---------------------------------------------------------------------------
function SDatabaseTable:load()
    for i=1,10 do
        if self:tryLoad() then
            return
        end
    end
end


---------------------------------------------------------------------------
--
-- SDatabaseTable:tryLoad()
--
--
--
---------------------------------------------------------------------------
function SDatabaseTable:tryLoad()
    outputDebug( 'TOPTIMES', 'SDatabaseTable: Loading ' .. self.name )
    self.rows = {}

    local cmd

    -- CREATE TABLE
    self:createTable()


    -- SELECT

    -- Build command
    cmd = 'SELECT * FROM ' .. qsafetablename( self.name )

    local sqlResults = executeSQLQuery( cmd )

    if not sqlResults then
        return false
    end

    -- Process into rows
    self.rows = {}
    for r,sqlRow in ipairs(sqlResults) do
        local row = {}
        for c,column in ipairs(self.columns) do
            row[column] = sqlRow[column]
        end
        table.insert( self.rows, row )
    end

    -- Make copy to detect changes
    self.rowsCopy = table.deepcopy(self.rows)

    return true
end


---------------------------------------------------------------------------
--
-- SDatabaseTable:save()
--
--
--
---------------------------------------------------------------------------
function SDatabaseTable:save()

    -- See if save required
    local bChanged = false
    if not self.rowsCopy or #self.rows ~= #self.rowsCopy then
        bChanged = true
    else
        for r,row in ipairs(self.rows) do
            for c,col in ipairs(self.columns) do
                if self.rows[r][col] ~= self.rowsCopy[r][col] then
                    bChanged = true
                    break
                end
            end
            if bChanged then
                break
            end
        end
    end

    if not bChanged then
        return
    end

    outputDebug( 'TOPTIMES', 'SDatabaseTable: Saving ' .. self.name )


    -- Being save
    executeSQLQuery( 'BEGIN TRANSACTION' );

    local cmd

    -- DELETE TABLE

    -- Build command
    --cmd = 'DELETE FROM ' .. qsafetablename( self.name )
    cmd = 'DROP TABLE IF EXISTS ' .. qsafetablename( self.name )
    executeSQLQuery( cmd )


    -- CREATE TABLE
    self:createTable()


    -- Rebuild
    -- For each row
    for r,row in ipairs(self.rows) do

        -- INSERT INTO

        cmd = 'INSERT INTO ' .. qsafetablename( self.name ) .. ' VALUES ('
        for c=1,#self.columns do
            if c > 1 then
                cmd = cmd .. ', '
            end
            local key = self.columns[c]
            if type(row[key]) == 'number' then
                cmd = cmd .. row[key] or 0
            else
                cmd = cmd .. qsafestring( row[key] or '' )
            end
        end
        cmd = cmd .. ')'

        executeSQLQuery( cmd )

    end

    executeSQLQuery( 'END TRANSACTION' );

    -- Make copy to detect changes
    self.rowsCopy = table.deepcopy(self.rows)

end


---------------------------------------------------------------------------
--
-- SDatabaseTable:createTable()
--
--
--
---------------------------------------------------------------------------
function SDatabaseTable:createTable()

    local cmd

    -- CREATE TABLE

    -- Build command
    cmd = 'CREATE TABLE IF NOT EXISTS ' .. qsafetablename( self.name ) .. ' ('
    for c=1,#self.columns do
        if c > 1 then
            cmd = cmd .. ', '
        end
        local columnType = self.columnTypes[c]
        cmd = cmd .. qsafestring( self.columns[c] ) .. ' ' .. columnType
    end
    cmd = cmd .. ')'

    executeSQLQuery( cmd )

end


---------------------------------------------------------------------------
--
-- SDatabaseTable:dump()
--
--
--
---------------------------------------------------------------------------
function SDatabaseTable:dump()

    -- Table name
    outputConsole( '------' .. self.name .. '------' )

    -- Columns
    local line
    line = ''
    for c=1,#self.columns do
        line = line .. self.columns[c] .. '      '
    end
    outputConsole( line )

    -- Rows
    for r,row in ipairs(self.rows) do
        line = ''
        for key,value in pairs(row) do
            line = line .. key .. '=' .. value .. '      '
        end
        outputConsole( line )
    end

    outputConsole( '----------------------' )

end


--
-- Utility functions
--

---------------------------------------------------------------------------
--
-- SDatabaseTable:addColumn()
--
--
---------------------------------------------------------------------------
function SDatabaseTable:addColumn( columnName, columnType )
    table.insert( self.columns, columnName )
    table.insert( self.columnTypes, columnType or 'TEXT' )
    for r,row in ipairs(self.rows) do
        row[columnName] = columnType and columnType=='REAL' and 0 or ''
    end
end


---------------------------------------------------------------------------
--
-- SDatabaseTable:renameColumn()
--
-- newType is optional
--
---------------------------------------------------------------------------
function SDatabaseTable:renameColumn( oldName, newName, newType )
    -- Find column index
    local i = table.find( self.columns, oldName )
    if not i then
        return false
    end

    self.columns[i] = newName

    -- Rename at each row
    for r,row in ipairs(self.rows) do
        row[newName] = row[oldName]
        row[oldName] = nil
    end

    -- Handle chaging type
    if newType and self.columnTypes[i] ~= newType then

        self.columnTypes[i] = newType
        -- Change type at each row
        for r,row in ipairs(self.rows) do
            if newType == 'REAL' then
                row[newName] = tonumber(row[newName]) or 0
            else
                row[newName] = tostring(row[newName]) or ''
            end
        end
    end

    return true
end


---------------------------------------------------------------------------
--
-- SDatabaseTable:deleteColumn()
--
--
---------------------------------------------------------------------------
function SDatabaseTable:deleteColumn( columnName )
    -- Find column index
    local i = table.find( self.columns, columnName )
    if not i then
        return false
    end

    table.remove( self.columns, i )

    -- Remove at each row
    for r,row in ipairs(self.rows) do
        row[columnName] = nil
    end

    return true
end


---------------------------------------------------------------------------
--
-- Testing
--
--
--
---------------------------------------------------------------------------

addCommandHandler('addcol',
    function(player, command, ...)
		if not _TESTING and not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			return
		end
        g_SToptimesManager.mapTimes.dbTable:addColumn( ... )
        g_SToptimesManager.mapTimes.dbTable:save()
        g_SToptimesManager.mapTimes.dbTable:load()
    end
)

addCommandHandler('delcol',
    function(player, command, ...)
		if not _TESTING and not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			return
		end
        g_SToptimesManager.mapTimes.dbTable:deleteColumn( ... )
        g_SToptimesManager.mapTimes.dbTable:save()
        g_SToptimesManager.mapTimes.dbTable:load()
    end
)

addCommandHandler('rencol',
    function(player, command, ...)
		if not _TESTING and not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			return
		end
        g_SToptimesManager.mapTimes.dbTable:renameColumn( ... )
        g_SToptimesManager.mapTimes.dbTable:save()
        g_SToptimesManager.mapTimes.dbTable:load()
    end
)


