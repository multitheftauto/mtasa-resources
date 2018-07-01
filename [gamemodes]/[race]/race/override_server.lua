--
-- override_server.lua
--


--------------------------------------------------------
--
-- Override
--
-- Multiple persistant settings
--
--------------------------------------------------------
Override = {}
Override.list = {}

addEventHandler( "onElementDestroy", g_Root,
	function()
		Override.list [ source ] = nil
	end
)


-- Gets
function Override.getVehicleCollideWorld( reason, element, value )
	return Override.get( reason, element, "race.collideworld" )
end

function Override.getVehicleCollideOthers( reason, element, value )
	return Override.get( reason, element, "race.collideothers" )
end

function Override.getAlphaOverride( reason, element, value )
	return Override.get( reason, element, "race.alpha" )
end

function Override.get( reason, element, var )
	return Override.list[element] and Override.list[element][var] and Override.list[element][var][reason] or nil
end


-- Sets
function Override.setCollideWorld( reason, element, value )
	Override.set( reason, element, value, "race.collideworld", 1 )
end

function Override.setCollideOthers( reason, element, value )
	Override.set( reason, element, value, "race.collideothers", 1 )
end

function Override.setAlpha( reason, element, value )
	Override.set( reason, element, value, "race.alpha", 255 )
end

function Override.set( reason, element, value, var, default )
	if not element then return end
	-- Recurse for each item if element is a table
	if type(element) == "table" then
		for _,item in ipairs(element) do
			Override.set( reason, item, value, var, default )
		end
		return
	end
	-- Add to override list
	if not Override.list[element] then		Override.list[element] = {}		end
	if not Override.list[element][var] then	Override.list[element][var] = { default=default}	end
	Override.list[element][var][reason] = value
	-- Set timer to auto-flush incase it is not done manually
	if not TimerManager.hasTimerFor("override") then
		TimerManager.createTimerFor("map","override"):setTimer( Override.flushAll, 50, 1 )
	end
end


-- Update. Find lowest value for each element var, and setElementData for it
function Override.flushAll()
	TimerManager.destroyTimersFor("override")
	-- For each element
	for element,varlist in pairs(Override.list) do
		-- For each var
		for var,valuelist in pairs(varlist) do
			-- Find the lowest value
			local lowestValue = var.default or 1000
			for _,value in pairs(valuelist) do
				lowestValue = math.min( lowestValue, value )
			end
			-- Set the lowest value for this element's var
			if isElement ( element ) then
				setElementData ( element, var, lowestValue )
			end
		end
	end
end


-- Remove
function Override.resetAll()
	-- For each element
	for element,varlist in pairs(Override.list) do
		-- For each var
		for var,valuelist in pairs(varlist) do
			-- Set the default value for this element's var
			if isElement ( element ) then
				setElementData ( element, var, var.default )
			end
		end
	end
	Override.list = {}
end
--------------------------------------------------------


--------------------------------------------------------
--
-- AddonOverride
--
-- This allows addons to manipulate player 'collide others' and 'alpha'
-- If calling serverside, ensure setElementData has [synchronize = false] to reduce bandwidth usage. Examples:
--		setElementData( player, "overrideCollide.ForMyAddonName", 0, false )		-- Collide 'off' for this player
--		setElementData( player, "overrideCollide.ForMyAddonName", nil, false )		-- Collide 'default' for this player
--		setElementData( player, "overrideAlpha.ForMyAddonName", 120, false )		-- Alpha '120 maximum' for this player
--		setElementData( player, "overrideAlpha.ForMyAddonName", nil, false )		-- Alpha 'default' for this player
--
-- Note: These values are automatically removed at the end of each map.
-- So if they are required for the next map, they will have to be set again in 'onMapStarting'
--------------------------------------------------------
AddonOverride = {}

addEventHandler('onElementDataChange', g_Root,
	function(dataName)
		if string.find( dataName, "override" ) == 1 then
			AddonOverride.apply( source, dataName )
		end
	end
)

function AddonOverride.apply( player, dataName )
	local vehicle = RaceMode.getPlayerVehicle( player )
	if vehicle then
		local value = getElementData( player, dataName )
		if string.find( dataName, "overrideCollide" ) == 1 then
			Override.setCollideOthers( dataName, vehicle, value )
		elseif string.find( dataName, "overrideAlpha" ) == 1 then
			Override.setAlpha( dataName, {player, vehicle}, value )
		end
	end
end

function AddonOverride.applyAll( player )
	for dataName, value in pairs( getAllElementData( player ) ) do
		if string.find( dataName, "override" ) == 1 then
			AddonOverride.apply( player, dataName )
		end
	end
end

function AddonOverride.removeAll()
	for _,player in ipairs( getElementsByType( "player" ) ) do
		for dataName, value in pairs( getAllElementData( player ) ) do
			if string.find( dataName, "override" ) == 1 then
				removeElementData( player, dataName )
			end
		end
	end
end
--------------------------------------------------------
