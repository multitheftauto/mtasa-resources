--
--
-- performancebrowser_client.lua
--
--

me = getLocalPlayer ()
local bSupportsStats = getPerformanceStats ~= nil

addEventHandler("onClientResourceStart", resourceRoot,
	function (resource)
		local a,b = nil,nil
		if bSupportsStats then
			a,b = getPerformanceStats( "" )
		end
		triggerServerEvent( "onNotifyTargetEnabled", resourceRoot, bSupportsStats, a, b ) 
    end
)

--[[
addEvent('onClientRequestCategories', true)
addEventHandler('onClientRequestCategories', me,
	function( username )
		local a,b = getPerformanceStats( "" )
		triggerServerEvent( "onNotifyCategories", resourceRoot, username, a, b ) 
	end
)
--]]

addEvent('onClientRequestStats', true)
addEventHandler('onClientRequestStats', me,
	function( username, queryCategoryName, queryOptionsText, queryFilterText )
		local a,b = getPerformanceStats( queryCategoryName, queryOptionsText, queryFilterText )
		triggerServerEvent( "onNotifyStats", resourceRoot, a, b, username, queryCategoryName, queryOptionsText, queryFilterText ) 
	end
)
