--
--
-- performancebrowser_client.lua
--
--

me = localPlayer
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

		if queryCategoryName == "Lua time recordings" then
			
			local columns, rows = getPerformanceStats( queryCategoryName, queryOptionsText, queryFilterText )
			local a = {"Resource", "CPU Usage", "Recorded Time"}
			local b = g_HighUsageResources

			return triggerServerEvent( "onNotifyStats", resourceRoot, a, b, username, queryCategoryName, queryOptionsText, queryFilterText )
		end
		
		local a,b = getPerformanceStats( queryCategoryName, queryOptionsText, queryFilterText )
		triggerServerEvent( "onNotifyStats", resourceRoot, a, b, username, queryCategoryName, queryOptionsText, queryFilterText )
	end
)