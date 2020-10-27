var map, maplayer, aeriallayer, playermarkers, blipmarkers;
var playericon = new OpenLayers.Icon("geticon.htm?id=02", new OpenLayers.Size(15,15));
var deadicon = new OpenLayers.Icon("geticon.htm?id=23", new OpenLayers.Size(15,15));
var radaricons = new Array();
for ( var i =0; i <= 63; i++ )
{
	var ai = i;
	if ( ai <= 9 )
		ai = "0" + ai;
	radaricons[i] = new OpenLayers.Icon("geticon.htm?id=" + ai, new OpenLayers.Size(15,15));
}
var playerlist = new Object;
var bliplist = new Object;

function init()
{
	map = new OpenLayers.Map( $('map'), {'maxResolution': 360/512, 'maxExtent':new OpenLayers.Bounds(-90.0,-90.0,90.0,90.0),
	'numZoomLevels':6,
	});

	map.addControl(new OpenLayers.Control.LayerSwitcher({'div':OpenLayers.Util.getElement('layerswitcher')}));

	maplayer = new OpenLayers.Layer.WMS( "San Andreas Map",
					"http://code.opencoding.net/tilecache/tilecache.cgi?", {layers: 'sa_map', format: 'image/png' } );
	map.addLayer(maplayer);

	aeriallayer = new OpenLayers.Layer.WMS( "San Andreas Aerial Map",
					"http://code.opencoding.net/tilecache/tilecache.cgi?", {layers: 'sa_aerial_map', format: 'image/png' } );
	map.addLayer(aeriallayer);

	map.zoomTo(2);

	blipmarkers = new OpenLayers.Layer.Markers("Radar Blips");
	map.addLayer(blipmarkers);

	playermarkers = new OpenLayers.Layer.Markers("Players");
	map.addLayer(playermarkers);

	updatePlayerInfo();
	updateBlips();
}

function addPlayerMarker(player)
{
	var feature = new OpenLayers.Feature(maplayer, gtaCoordToLonLat(player.pos.x, player.pos.y), {icon:playericon.clone()});
	var marker = feature.createMarker();
	marker.playerName = player.name;
	marker.feature = feature;
	marker.events.register("mousedown", marker, showplayerinfo);
	playermarkers.addMarker(marker);
	return feature;
}

function addBlipMarker(blip)
{
	var feature = new OpenLayers.Feature(maplayer, gtaCoordToLonLat(blip.pos.x, blip.pos.y), {icon:radaricons[blip.icon].clone()});
	var marker = feature.createMarker();
	marker.element = blip.element;
	marker.feature = feature;
	blipmarkers.addMarker(marker);
	return feature;
}

// Takes a GTA x and y and returns a x and y on the map
function gtaCoordToMap(x, y)
{
	var mapx = x * 0.03;
	var mapy = y * 0.03;
	return {x: mapx, y: mapy};
}

// Takes a GTA x and y and returns a LonLat
function gtaCoordToLonLat(x, y)
{
	var mapx = x * 0.03;
	var mapy = y * 0.03;
	return new OpenLayers.LonLat(mapx,mapy);
}

var blipUpdateCount = 0;
function updateBlips()
{
	getAllBlips (
		function ( blips )
		{
			for ( var k = 0; k < blips.length; k++ )
			{
				if  ( bliplist[blips[k].element.id] == null ) {
					bliplist[blips[k].element.id] = new Object();
					bliplist[blips[k].element.id].feature = addBlipMarker(blips[k]);
				} else {
					var latlong = gtaCoordToLonLat(blips[k].pos.x, blips[k].pos.y);
					bliplist[blips[k].element.id].feature.lonlat = latlong;
					bliplist[blips[k].element.id].feature.marker.moveTo(map.getLayerPxFromLonLat(latlong));
				}
				bliplist[blips[k].element.id].data = blips[k];
				bliplist[blips[k].element.id].lastUpdate = blipUpdateCount;

				/*if ( playerinfo[i].isdead )
					playerlist[playerinfo[i].name].feature.marker.icon = deadicon;
				else
					playerlist[playerinfo[i].name].feature.marker.icon = playericon;*/
			}
			for ( var j in bliplist )
			{
				if ( j != "toJSONString" )
				{
					if ( bliplist[j].lastUpdate != blipUpdateCount ) {
						blipmarkers.removeMarker(bliplist[j].feature.marker);
						delete bliplist[j];
					}
				}
			}


			blipUpdateCount++;

			setTimeout(updateBlips, 5000);
		}
	);
}

var updateCount = 0;
function updatePlayerInfo()
{
	players (
		function ( playerinfo )
		{
			for ( var i = 0; i < playerinfo.length; i++ )
			{
				if  ( playerlist[playerinfo[i].name] == null ) {
					playerlist[playerinfo[i].name] = new Object();
					playerlist[playerinfo[i].name].feature = addPlayerMarker(playerinfo[i]);


				} else {
					var latlong = gtaCoordToLonLat(playerinfo[i].pos.x, playerinfo[i].pos.y);
					playerlist[playerinfo[i].name].feature.lonlat = latlong;


					if ( playerToFollow == playerinfo[i].name )
						map.setCenter(latlong, map.getZoom(), false, false);

					playerlist[playerinfo[i].name].feature.marker.moveTo(map.getLayerPxFromLonLat(latlong));
				}
				playerlist[playerinfo[i].name].data = playerinfo[i];
				playerlist[playerinfo[i].name].lastUpdate = updateCount;

				/*if ( playerinfo[i].isdead )
					playerlist[playerinfo[i].name].feature.marker.icon = deadicon;
				else
					playerlist[playerinfo[i].name].feature.marker.icon = playericon;*/
			}
			for ( var j in playerlist )
			{
				if ( j != "toJSONString" )
				{
					if ( playerlist[j].lastUpdate != updateCount ) {
						playermarkers.removeMarker(playerlist[j].feature.marker);
						delete playerlist[j];
					}
				}
			}


			updateCount++;

			setTimeout(updatePlayerInfo, 1000);
		}
	);
}
function checkSendMessage(e)
{

	var characterCode

	if(e && e.which){ //if which property of event object is supported (NN4)
		e = e
		characterCode = e.which //character code is contained in NN4's which property
		}
	else{
		e = event
		characterCode = e.keyCode //character code is contained in IE's keyCode property
	}

	if(characterCode == 13){ //if generated character code is equal to ascii 13 (if enter key)
		var messageBox = document.getElementById('sendMessageBox');
		sendPlayerMessage ( popupPlayer, messageBox.value, function() { } );
		messageBox.value = "";
	return false
	}
	else{
	return true
	}
}

var playerToFollow = null;

function followPlayer()
{
	var followPlayerCheckbox = document.getElementById("followPlayerCheckbox");
	if ( followPlayerCheckbox.checked == true )
		playerToFollow = popupPlayer;
	else
		playerToFollow = null;
}

var popup;
var popupPlayer = null;
function showplayerinfo(evt) {
	 // check to see if the popup was hidden by the close box
	 // if so, then destroy it before continuing
	if (popup != null) {
		if (!popup.visible()) {
			playermarkers.map.removePopup(popup);
			popup.destroy();
			popup = null;
		}
	}
	if (popup == null) {
		var playerinfo = playerlist[this.playerName].data;
		var html = playerinfo.name + "<br/><div style='font-size: 0.8em;'>";
		if ( playerinfo.vehicle != null )
			html += "In vehicle: " + playerinfo.vehicle + "<br/>";

		popupPlayer= this.playerName;

		html += "Send: <input type='text' id='sendMessageBox' onkeyup='checkSendMessage(event);' />"
		if ( popupPlayer == playerToFollow )
			var checked = "checked='checked'";

		html += "<input type='checkbox' id='followPlayerCheckbox' onclick='followPlayer();' " + checked + " onchange='followPlayer();' /> <label for='followPlayerCheckbox'>Follow</label>"
		html += "</div>";


		popup = this.feature.createPopup(true);
		popup.setContentHTML(html);
		popup.setBackgroundColor("#888888");
		popup.setOpacity(0.8);
		playermarkers.map.addPopup(popup);
	} else {
		playermarkers.map.removePopup(popup);
		popup.destroy();
		popup = null;
	}
	OpenLayers.Event.stop(evt);
}

