--
--
-- Manage emergency map backups stored in a dummy resource
--
--

local mapBackupsResourceName = "editor_map_backups"


---------------------------------------------------------------------------
--
-- getMapBackupResource
--
-- Get resource to store map backups in
--
---------------------------------------------------------------------------
function getMapBackupResource()
    return getResourceFromName( mapBackupsResourceName ) or createResource( mapBackupsResourceName )
end


---------------------------------------------------------------------------
--
-- backupMapFiles
--
-- Copy all map files from supplied resource into backup resource
--
---------------------------------------------------------------------------
function backupMapFiles( srcResourceName )
    local time = getRealTime()
	local dateString = string.format( '%04d%02d%02d%02d%02d%02d'
						,time.year + 1900
						,time.month + 1
						,time.monthday
						,time.hour
						,time.minute
						,time.second
						)

	local backupResource = getMapBackupResource()
	local backupResourceName = getResourceName( backupResource )

    -- Copy resource maps to backup directory
    local files = getResourceFiles( getResourceFromName( srcResourceName ), "map" )
    if files then
	    for j,srcFilename in ipairs(files) do
            local backupFilename = dateString.."_"..srcFilename;
            local srcFilePath = ":"..srcResourceName.."/"..srcFilename
            local backupFilePath = ":"..backupResourceName.."/"..backupFilename
            if fileCopy( srcFilePath, backupFilePath, true ) then
                insertResourceFile( backupResource, backupFilename, "mapbackup" )
            end
	    end
    end

    -- Tidy once
    if not doneTidyMapBackups then
        doneTidyMapBackups = true
        tidyMapBackups()
    end
end


---------------------------------------------------------------------------
--
-- tidyMapBackups
--
-- Remove older files that exceed limits
--
---------------------------------------------------------------------------
function tidyMapBackups()

    -- Limits
    local maxNumUniqueDays = 7
    local minNumFiles = 30
    local maxNumFiles = 300

	local backupResource = getMapBackupResource()

    local files = getResourceFiles( backupResource, "mapbackup" )
    if files then
        table.sort( files )
        local numDates, numFiles, prevDate = 0, 0, 0
        for i=#files,1,-1 do
            local backupFilename = files[i]
            local date = string.sub( backupFilename, 0, 6 )
            if date ~= prevDate then
                prevDate = date
                numDates = numDates + 1
            end
            numFiles = numFiles + 1

            -- Check limits
            if numFiles > minNumFiles and
                  ( numDates > maxNumUniqueDays
                 or numFiles > maxNumFiles ) then
                    removeResourceFile( backupResource, backupFilename, "mapbackup" )
            end
        end
    end
end
