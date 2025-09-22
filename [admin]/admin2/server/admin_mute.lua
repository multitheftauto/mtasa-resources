--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	server/admin_mute.lua
*
*	Original File by omar-o22
*
**************************************]]
aMutedList = {}

addEventHandler ( "onPlayerJoin", root,
    function ()
        local serial = getPlayerSerial( source )
        if ( not aHasUnmuteTimer( source ) or isPlayerMuted( source ) ) then
            return
        end

        local duration = aGetRemainingUnmuteTime( serial )
        local reason = aGetRemainingUnmuteReason( serial )
        if (not duration or duration < 0 or not reason) then
            return
        end

        triggerEvent ( EVENT_MUTE, getElementByIndex("console", 0), "mute", { duration = duration, reason = reason, player = source } )
    end
)

addEventHandler ( "onPlayerQuit", root,
    function ()
        if ( not aHasUnmuteTimer( source ) or not isPlayerMuted( source ) ) then
            return
        end

        local serial = getPlayerSerial(source)
        local name = getPlayerName(source)

        if ( not isTimer(aMutedList[serial].timer) ) then
            return
        end

        local time = getTimerDetails( aMutedList[serial].timer )
        if ( not time ) then
            return
        end

        local admin = aMutedList[serial].admin
        local reason = aMutedList[serial].reason

        aSetRemainingUnmuteTime( source, time )
        killTimer( aMutedList[serial].timer )
        aAddOrUpdateMute( serial, name, admin, reason, time )
    end
)

addEventHandler ( "onResourceStop", resourceRoot, 
    function ()
        for serial, data in pairs( aMutedList ) do
            local remainingTime
            if ( data.timer and isTimer(data.timer) ) then
                local time = getTimerDetails( data.timer )
                if ( time ) then
                    remainingTime = time
                else
                    remainingTime = data.time
                end
            else
                remainingTime = data.time
            end

            aAddOrUpdateMute( serial, data.name, data.admin, data.reason, remainingTime, true )
        end
    end
)

addEventHandler ( "onResourceStart", resourceRoot, 
    function ()
        local result = db.query( "SELECT * FROM mutes" )
        for index, value in ipairs(result) do
            aMutedList[value.serial] = {}
            aMutedList[value.serial].name = value.name
            aMutedList[value.serial].admin = value.admin
            aMutedList[value.serial].reason = value.reason
            aMutedList[value.serial].time = value.time
           
            for _, player in ipairs( getElementsByType( "player" ) ) do
                if ( getPlayerSerial(player) == value.serial ) then
                    -- Silent mute
                    aSetPlayerMuted( player, true, value.time, value.admin, value.reason )
                end
            end
        end
    end
)

function aSetPlayerMuted ( player, state, time, admin, reason )
    if isElement(player) and getElementType(player) == "player" then
        setPlayerMuted ( player, state )
    end
    
    if not state then
        local serial = getPlayerSerial( player )
        aRemoveUnmuteTimer( serial )
        return true
    elseif state then
        aAddUnmuteTimer( player, admin, reason, time )
        return true
    end
    return false
end

function aAddUnmuteTimer( player, admin, reason, time )
	local serial = getPlayerSerial( player )
    if ( not aMutedList[serial] ) then
        aMutedList[serial] = {}
        aMutedList[serial].admin = getPlayerName(admin)
        aMutedList[serial].reason = reason
    end
    aMutedList[serial].name = getPlayerName( player )

    if ( time and time > 0 ) then
        aMutedList[serial].timer = setTimer(
            function( )
                for _, plr in ipairs( getElementsByType( "player" ) ) do
                    if getPlayerSerial( plr ) == serial and isPlayerMuted( plr ) then
                        triggerEvent ( EVENT_MUTE, getElementByIndex("console", 0), "unmute", {player = plr} )
                    end
                end
            end,
        time, 1 )
    elseif ( time == 0 ) then
        aSetRemainingUnmuteTime( player, 0 )
    end
end

function aRemoveUnmuteTimer( serial )
    local serial = serial
    
	if ( not aMutedList[serial] or not aMutedList[serial].timer )  then
        return false
    end

    if ( isTimer( aMutedList[serial].timer ) ) then
        killTimer( aMutedList[serial].timer )
    end
    aMutedList[serial] = nil
    db.exec( "DELETE FROM mutes WHERE serial = ?", serial )
    return true
end

function aSetRemainingUnmuteTime( player, time )
    local serial = getPlayerSerial( player )
    if ( not aMutedList[serial] ) then
        return false
    end

    aMutedList[serial].time = time
    return true
end

function aGetRemainingUnmuteTime( serial )
    if ( not aMutedList[serial] ) then
        return false
    end

    if ( isTimer( aMutedList[serial].timer ) ) then
        local remainingTime = getTimerDetails( aMutedList[serial].timer )
        return remainingTime
    end

    if aMutedList[serial].time then
        return aMutedList[serial].time
    end

    return nil
end

function aGetRemainingUnmuteReason( serial )
    if ( not aMutedList[serial] or not aMutedList[serial].reason ) then
        return false
    end

    return aMutedList[serial].reason
end

function aHasUnmuteTimer( player )
	local serial = getPlayerSerial( player )
    return aMutedList[serial]
end

function aAddOrUpdateMute(serial, player, admin, reason, time, isRestarted)
    local result
    local query_text = "SELECT serial FROM mutes WHERE serial = ?"
    if ( isRestarted ) then
        local query = dbQuery( db.connection, query_text, serial )
        result = dbPoll( query, -1 )
    else
        result = db.query( query_text, serial )
    end

    if #result > 0 then
        return db.exec( "UPDATE mutes SET name = ?, admin = ?, reason = ?, time = ? WHERE serial = ?", player, admin, reason, time, serial )
    else
        return db.exec( "INSERT INTO mutes (serial, name, admin, reason, time) VALUES (?, ?, ?, ?, ?)", serial, player, admin, reason, time )
    end
    return false
end

function aGetMutesList()
    return aMutedList
end

function handleMuteRequest(action, data)
    -- Basic security check
    if ( client and source ~= client ) then
        return
    end
    
    -- Permissions check
    if ( not hasObjectPermissionTo(source, "command."..action, false) ) then
        outputChatBox( "Access denied for '" .. tostring(action) .. "'", source, 255, 168, 0 )
        return
    end

    -- Add mute
    if action == "mute" then
        if ( not data or not data.duration or not data.player ) then
            return
        end

        if isPlayerMuted( data.player ) then
            return
        end

        local time
        if ( data.duration == 0 ) then
            time = "Permanent"
        else
            time = secondsToTimeDesc( data.duration / 1000 )
        end
        
        aSetPlayerMuted( data.player, true, data.duration, source, data.reason )
        aAction( "player", "mute", source, data.player, time )
    -- Remove mute
    elseif ( action == "unmute" ) then
        local mute = aMutedList[data.serial]

        -- Unlikely to occur, but advise admin if mute failed for some reason
        if ( not mute ) then
            outputChatBox( "Mute action failed - check mute details.", source, 255, 0, 0 )
            return
        end

        if ( mute ) then
            -- Checks if the player online
            local player

            for _, plr in ipairs(getElementsByType("player")) do
                if ( getPlayerSerial( plr ) == data.serial ) then
                    player = plr
                    break
                end
            end
            if ( player ) then
                aSetPlayerMuted( player, false )
            else
                aRemoveUnmuteTimer( data.serial ) -- if not found remove his serial from table
            end

            aAction( "player", "unmute", source, ( player and data.player or mute.name ) )
        end
    end
end

addEvent(EVENT_MUTE, true)
addEventHandler(EVENT_MUTE, root, handleMuteRequest)