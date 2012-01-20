--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\main\admin_network.lua
*
*	Original File by lil_Toady
*
**************************************]]

aNetworkTab = {}

function aNetworkTab.Create ( tab )
	aNetworkTab.Tab = tab

	aNetworkTab.Panel 	= guiCreateTabPanel ( 0.40, 0.02, 0.59, 0.70, true, tab )
	aNetworkTab.Overview	= guiCreateTab ( "Network overview", aNetworkTab.Panel )
end

function aNetworkTab.onClientClick ( button )
	if ( button == "left" ) then

	end
end