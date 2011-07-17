httpMenu = {}
local node = xmlLoadFile ( "conf\\web.xml" )
if ( node ) then
	local items = 0
	local resource = getResourceName ( getThisResource() )
	while ( xmlFindChild ( node, "item", items ) ~= false ) do
		local item = xmlFindChild ( node, "item", items )
		local section = xmlNodeGetAttribute ( item, "section" )
		local page = xmlNodeGetAttribute ( item, "page" )
		local icon = xmlNodeGetAttribute ( item, "icon" )
		local name = xmlNodeGetAttribute ( item, "name" )
		local alt = xmlNodeGetAttribute ( item, "alt" )
		if ( not httpMenu[section] ) then httpMenu[section] = {} end
		httpMenu[section][#httpMenu[section] + 1] = {}
		httpMenu[section][#httpMenu[section]]["resource"] = resource
		httpMenu[section][#httpMenu[section]]["page"] = page
		httpMenu[section][#httpMenu[section]]["icon"] = icon
		httpMenu[section][#httpMenu[section]]["name"] = name
		httpMenu[section][#httpMenu[section]]["alt"] = alt
		items = items + 1
	end
end
xmlUnloadFile ( node )

function httpAddMenuItem ( resource, section, name, page, icon, alt )
	if ( alt ) then
		resource = tostring ( resource )
		section = tostring ( section )
		name = tostring ( name )
		page = tostring ( page )
		icon = tostring ( icon )
		alt = tostring ( alt )
		if ( not httpMenu[section] ) then httpMenu[section] = {} end
		httpMenu[section][#httpMenu[section] + 1] = {}
		httpMenu[section][#httpMenu[section]]["resource"] = resource
		httpMenu[section][#httpMenu[section]]["page"] = page
		httpMenu[section][#httpMenu[section]]["icon"] = icon
		httpMenu[section][#httpMenu[section]]["name"] = name
		httpMenu[section][#httpMenu[section]]["alt"] = alt
	end
end

function httpGetMenuItems ()
	return httpMenu
end

function httpGetPlayerList()
	local playerList = {}
	for id, player in ipairs ( getElementsByType ( "player" ) ) do
		table.insert ( playerList, getPlayerName ( player ) )
		table.insert ( playerList, getPlayerPing ( player ) )
	end
	return playerList
end