--[[
<maplimit>
	<point x="" y="" />
	<point x="" y="" />
	<point x="" y="" />
</maplimit>
]]

function isLeft( x0, y0, x1, y1, x2, y2 )
	return  ( ( x1 - x0 ) * ( y2 - y0 ) - ( x2 - x0 ) * ( y1 - y0 ) )
end

function isInPoli( x0, y0, table )
	--local one = getTickCount()
	local wn = 0
	local k = 1
	while ( k < #table ) do
		if ( table[k].y <= y0 ) then
			if ( table[k+1].y > y0 ) then
				if ( isLeft( table[k].x, table[k].y, table[k+1].x, table[k+1].y, x0, y0 ) > 0 ) then
					wn = wn + 1
				end
			end
		else
			if ( table[k+1].y <= y0 ) then
				if ( isLeft( table[k].x, table[k].y, table[k+1].x, table[k+1].y, x0, y0 ) < 0 ) then
					wn = wn - 1
				end
			end
		end
		k = k + 1
	end
	--outputChatBox( getTickCount() - one )
	return wn
end

function buildTables()
	mapLimits = {}
	local groups = getElementsByType ( "maplimit" )
	for k,v in ipairs(groups) do
		mapLimits[k] = {}
		local points = getChildren ( v, "point" )
		if ( #points < 3 ) then
			outputDebugString("* Map Limits Error: too little points in a maplimit. Minimum is 3.", 1 )
			return
		end
		for i,j in ipairs(points) do
			mapLimits[k][i] = {}
			mapLimits[k][i].x = tonumber(getElementData( j, "x" ))
			mapLimits[k][i].y = tonumber(getElementData( j, "y" ))
			--mapLimits[k][i].marker = createMarker( mapLimits[k][i].x, mapLimits[k][i].y, 0 )
			--setElementVisibleTo ( mapLimits[k][i].marker, maplimitsRoot, false )
		end
	end
end

function onResourceStuff( resourcename )
	buildTables()
	if ( resourcename == getThisResource () ) then
		mapl_disp = textCreateDisplay ()
		mapl_text = textCreateTextItem ( "GO BACK TO THE GAME AREA!", 0.5, 0.5, "high", 255, 0, 0, 255, 2.5, "center", "center" )
		textDisplayAddText ( mapl_disp, mapl_text )
		players = getElementsByType( "player" )
		for k,v in ipairs(players) do
			stuff( v, 0, false )
		end
	end
end

function getChildren ( root, type )
	local elements = getElementsByType ( type )
	local result = {}
	for elementKey,elementValue in ipairs(elements) do
		if ( getElementParent( elementValue ) == root ) then
			result[ table.getn( result ) + 1 ] = elementValue
		end
	end
	return result
end

function onPlayerJoin()
	stuff( source, 0, false )
end

function onPlayerWasted()
	textDisplayRemoveObserver ( mapl_disp, source )
end

function stuff( player, flag )
	if (not isElement(player)) then return end
	--local one = getTickCount()
	if #mapLimits ~= 0 then
		local x, y, z = getElementPosition( player )
		local newFlag = true
		local k = 1
		while ( ( k <= #mapLimits ) and newFlag ) do
			local wn = isInPoli( x, y, mapLimits[k] )
			if ( wn ~= 0 ) then
				newFlag = false
			end
			k = k + 1
		end
		if ( flag ~= newFlag ) then
			if ( getElementInterior (player) == 0 ) then --dont trigger on interiors
				if ( newFlag ) then
					if ( not isPedDead( player ) ) then	--Lol, inefficient. Bite me.
						textDisplayAddObserver ( mapl_disp, player )
					end
				else
					textDisplayRemoveObserver ( mapl_disp, player )
				end
			end
		end
		if newFlag and ( not isPedDead( player ) ) then
			if ( getElementInterior (player) == 0 ) then --dont trigger on interiors
				local playerHP = getElementHealth( player )
				if ( playerHP > 10 ) then
					setElementHealth( player, playerHP - 1 )
				else
					killPed( player )
				end
			end
		end
		setTimer( stuff, 200, 1, player, newFlag )
		--outputChatBox( getTickCount() - one )
	else
		setTimer( stuff, 200, 1, player, flag )
	end
end
--[[
function showPoints( source )
	if #mapLimits ~= 0 then
		local booll = isElementVisibleTo ( mapLimits[1][1].marker, source )
		if booll then booll = false else booll = true end
		for k,v in ipairs(mapLimits) do
			local i = 1
			while i < #mapLimits[k] do
				setElementVisibleTo ( mapLimits[k][i].marker, source, booll )
				i = i + 1
			end
		end
	end
end
]]
maplimitsRoot = getRootElement()
addEventHandler( "onResourceStart", maplimitsRoot, onResourceStuff )
addEventHandler( "onResourceStop", maplimitsRoot, onResourceStuff )
addEventHandler( "onPlayerJoin", maplimitsRoot, onPlayerJoin )
addEventHandler( "onPlayerWasted", maplimitsRoot, onPlayerWasted )

--addCommandHandler ( "showpoints", showPoints )
