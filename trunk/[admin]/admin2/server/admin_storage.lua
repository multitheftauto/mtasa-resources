--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	server/admin_storage.lua
*
*	Original File by lil_Toady
*
**************************************]]

function aSetupStorage ()
	--local query = db.query ( "SELECT name FROM sqlite_master WHERE name='admin_alias'" )

	db.exec ( "CREATE TABLE IF NOT EXISTS alias ( ip TEXT, serial TEXT, name TEXT, time INTEGER )" )
	db.exec ( "CREATE TABLE IF NOT EXISTS warnings ( ip TEXT, serial TEXT, name TEXT, time INTEGER )" )

	local node = xmlLoadFile ( "conf\\interiors.xml" )
	if ( node ) then
		local interiors = 0
		while ( xmlFindChild ( node, "interior", interiors ) ) do
			local interior = xmlFindChild ( node, "interior", interiors )
			interiors = interiors + 1
			aInteriors[interiors] = {
				world = tonumber ( xmlNodeGetAttribute ( interior, "world" ) ),
				id = xmlNodeGetAttribute ( interior, "id" ),
				x = xmlNodeGetAttribute ( interior, "posX" ),
				y = xmlNodeGetAttribute ( interior, "posY" ),
				z = xmlNodeGetAttribute ( interior, "posZ" ),
				r = xmlNodeGetAttribute ( interior, "rot" )
			}
		end
		xmlUnloadFile ( node )
	end
	local node = xmlLoadFile ( "conf\\stats.xml" )
	if ( node ) then
		local stats = 0
		while ( xmlFindChild ( node, "stat", stats ) ) do
			local stat = xmlFindChild ( node, "stat", stats )
			local id = tonumber ( xmlNodeGetAttribute ( stat, "id" ) )
			local name = xmlNodeGetAttribute ( stat, "name" )
			aStats[id] = name
			stats = stats + 1
		end
		xmlUnloadFile ( node )
	end
	local node = xmlLoadFile ( "conf\\weathers.xml" )
	if ( node ) then
		local weathers = 0
		while ( xmlFindChild ( node, "weather", weathers ) ~= false ) do
		local weather = xmlFindChild ( node, "weather", weathers )
			local id = tonumber ( xmlNodeGetAttribute ( weather, "id" ) )
			local name = xmlNodeGetAttribute ( weather, "name" )
			aWeathers[id] = name
			weathers = weathers + 1
		end
		xmlUnloadFile ( node )
	end
	local node = xmlLoadFile ( "conf\\reports.xml" )
	if ( node ) then
		local messages = 0
		while ( xmlFindChild ( node, "message", messages ) ) do
			subnode = xmlFindChild ( node, "message", messages )
			local author = xmlFindChild ( subnode, "author", 0 )
			local subject = xmlFindChild ( subnode, "subject", 0 )
			local category = xmlFindChild ( subnode, "category", 0 )
			local text = xmlFindChild ( subnode, "text", 0 )
			local time = xmlFindChild ( subnode, "time", 0 )
			local read = ( xmlFindChild ( subnode, "read", 0 ) ~= false )
			local id = #aReports + 1
			aReports[id] = {}
			if ( author ) then aReports[id].author = xmlNodeGetValue ( author )
			else aReports[id].author = "" end
			if ( category ) then aReports[id].category = xmlNodeGetValue ( category )
			else aReports[id].category = "" end
			if ( subject ) then aReports[id].subject = xmlNodeGetValue ( subject )
			else aReports[id].subject = "" end
			if ( text ) then aReports[id].text = xmlNodeGetValue ( text )
			else aReports[id].text = "" end
			if ( time ) then aReports[id].time = xmlNodeGetValue ( time )
			else aReports[id].time = "" end
			aReports[id].read = read
			messages = messages + 1
		end
		xmlUnloadFile ( node )
	end
	local node = xmlLoadFile ( "conf\\messages.xml" )
	if ( node ) then
		for id, type in ipairs ( _types ) do
			local subnode = xmlFindChild ( node, type, 0 )
			if ( subnode ) then
				aLogMessages[type] = {}
				local groups = 0
				while ( xmlFindChild ( subnode, "group", groups ) ) do
					local group = xmlFindChild ( subnode, "group", groups )
					local action = xmlNodeGetAttribute ( group, "action" )
					local r = tonumber ( xmlNodeGetAttribute ( group, "r" ) )
					local g = tonumber ( xmlNodeGetAttribute ( group, "g" ) )
					local b = tonumber ( xmlNodeGetAttribute ( group, "b" ) )
					aLogMessages[type][action] = {}
					aLogMessages[type][action]["r"] = r or 0
					aLogMessages[type][action]["g"] = g or 255
					aLogMessages[type][action]["b"] = b or 0
					if ( xmlFindChild ( group, "all", 0 ) ) then aLogMessages[type][action]["all"] = xmlNodeGetValue ( xmlFindChild ( group, "all", 0 ) ) end
					if ( xmlFindChild ( group, "admin", 0 ) ) then aLogMessages[type][action]["admin"] = xmlNodeGetValue ( xmlFindChild ( group, "admin", 0 ) ) end
					if ( xmlFindChild ( group, "player", 0 ) ) then aLogMessages[type][action]["player"] = xmlNodeGetValue ( xmlFindChild ( group, "player", 0 ) ) end
					if ( xmlFindChild ( group, "log", 0 ) ) then aLogMessages[type][action]["log"] = xmlNodeGetValue ( xmlFindChild ( group, "log", 0 ) ) end
					groups = groups + 1
				end
			end
		end
		xmlUnloadFile ( node )
	end
end

function aReleaseStorage ()
	local node = xmlLoadFile ( "conf\\reports.xml" )
	if ( node ) then 
		local messages = 0
		while ( xmlFindChild ( node, "message", messages ) ~= false ) do
			local subnode = xmlFindChild ( node, "message", messages )
			xmlDestroyNode ( subnode )
			messages = messages + 1
		end
	else
		node = xmlCreateFile ( "conf\\reports.xml", "messages" )
	end
	for id, message in ipairs ( aReports ) do
		local subnode = xmlCreateChild ( node, "message" )
		for key, value in pairs ( message ) do
			if ( value ) then
				xmlNodeSetValue ( xmlCreateChild ( subnode, key ), tostring ( value ) )
			end
		end
	end
	xmlSaveFile ( node )
	xmlUnloadFile ( node )
end