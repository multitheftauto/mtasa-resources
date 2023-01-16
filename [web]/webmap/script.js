const rad = Math.PI / 180;
const extent = [-3000, -3000, 3000, 3000];

const syncedPlayers = {};
const syncedRadarBlips = {};

let popupEl;
let gtasaProjection;
let tilegrid;
let playerVectorSource;
let radarBlipVectorSource;
let mousePositionControl;
let layerSwitcherControl;
let map;
let selectSingleClick;
let selectedPlayer;
let followingPlayer;

function init() {
  popupEl = document.getElementById('popup');

  gtasaProjection = new ol.proj.Projection({
    code: 'ZOOMIFY',
    units: 'pixels',
    extent,
  });

  tilegrid = new ol.tilegrid.TileGrid({
    extent,
    resolutions: [8, 4, 2, 1],
  });

  playerVectorSource = new ol.source.Vector({
    projection: gtasaProjection,
  });

  radarBlipVectorSource = new ol.source.Vector({
    projection: gtasaProjection,
  });

  mousePositionControl = new ol.control.MousePosition({
    coordinateFormat: ol.coordinate.createStringXY(0),
  });

  layerSwitcherControl = new ol.control.LayerSwitcher({
    tipLabel: 'Layers',
  });

  popupOverlay = new ol.Overlay({
    autoPan: true,
    autoPanAnimation: {
      duration: 250,
    },
    element: popupEl,
  });

  map = new ol.Map({
    controls: [layerSwitcherControl, mousePositionControl],
    layers: [
      new ol.layer.Group({
        layers: [
          new ol.layer.Tile({
            source: new ol.source.TileDebug({
              tileGrid: tilegrid,
              projection: gtasaProjection,
            }),
            title: 'Grid Debug',
            visible: false,
            zIndex: 100,
          }),
          new ol.layer.Vector({
            source: radarBlipVectorSource,
            title: 'Radar Blips',
            visible: true,
            zIndex: 80,
          }),
          new ol.layer.Vector({
            source: playerVectorSource,
            title: 'Players',
            visible: true,
            zIndex: 90,
          }),
        ],
        title: 'Overlays',
      }),
      new ol.layer.Group({
        fold: 'open',
        layers: [
          new ol.layer.Tile({
            source: new ol.source.XYZ({
              projection: gtasaProjection,
              tileSize: 500,
              url:
                'https://assets.multitheftauto.com/mtasa-resources/webmap/sa_aerial_map/v2/{z}_{x}_{y}.jpg',
              wrapX: false,
            }),
            title: 'San Andreas Aerial Map V2',
            type: 'base',
            visible: true,
          }),
          new ol.layer.Tile({
            source: new ol.source.XYZ({
              projection: gtasaProjection,
              tileSize: 500,
              url:
                'https://assets.multitheftauto.com/mtasa-resources/webmap/sa_aerial_map/v1/{z}_{x}_{y}.jpg',
              wrapX: false,
            }),
            title: 'San Andreas Aerial Map',
            type: 'base',
            visible: false,
          }),
          new ol.layer.Tile({
            source: new ol.source.XYZ({
              projection: gtasaProjection,
              tileSize: 500,
              url:
                'https://assets.multitheftauto.com/mtasa-resources/webmap/sa_map/v1/{z}_{x}_{y}.jpg',
              wrapX: false,
            }),
            title: 'San Andreas Map',
            type: 'base',
            visible: false,
          }),
        ],
        title: 'Map style',
      }),
    ],
    overlays: [popupOverlay],
    target: 'map',
    view: new ol.View({
      center: ol.extent.getCenter(extent),
      extent,
      projection: gtasaProjection,
      resolutions: tilegrid.getResolutions(),
      showFullExtent: true,
      zoom: 0,
    }),
  });

  map.on('singleclick', function (e) {
    const features = map.getFeaturesAtPixel(e.pixel);

    for (let i = 0; i < features.length; i++) {
      const feature = features[i];
      const playerEntry = Object.entries(syncedPlayers).find(function (entry) {
        return entry[1].feature === feature;
      });
      if (!playerEntry) continue;

      selectedPlayer = playerEntry[0];

      const player = syncedPlayers[selectedPlayer];

      let html =
        selectedPlayer +
        "<button type='button' onclick='closePopup();' style='position:absolute;right:0;top:0;'>close</button><br/><div style='font-size: 0.8em;'>";

      if (player.vehicle) html += 'In vehicle: ' + player.vehicle + '<br/>';

      html +=
        "Send: <input type='text' id='sendMessageBox' onkeyup='checkSendMessage(event);' />";
      if (selectedPlayer === followingPlayer) var checked = "checked='checked'";

      html +=
        "<input type='checkbox' id='followPlayerCheckbox' onclick='followPlayer();' " +
        checked +
        " onchange='followPlayer();' /> <label for='followPlayerCheckbox'>Follow</label>";
      html += '</div>';

      popupEl.innerHTML = html;

      popupOverlay.setPosition(e.coordinate);

      return;
    }

    closePopup();
  });

  updatePlayerBlips();
  updateRadarBlips();
}

function addPlayerBlip(player) {
  const feature = new ol.Feature({
    geometry: new ol.geom.Point([player.pos.x, player.pos.y]),
  });

  feature.setStyle(
    new ol.style.Style({
      image: new ol.style.Icon({
        color: player.isdead ? [200, 0, 0, 1] : [255, 255, 255, 1],
        rotation: -player.rot * rad,
        src: 'geticon.htm?id=02',
      }),
    }),
  );

  playerVectorSource.addFeature(feature);

  return feature;
}

function addRadarBlip(blip) {
  const feature = new ol.Feature({
    geometry: new ol.geom.Point([blip.pos.x, blip.pos.y]),
  });

  let image;

  const color = blip.color;
  color[3] = color[3] / 255; // 0..1 scale

  if (blip.icon === 0) {
    image = new ol.style.RegularShape({
      angle: 45 * rad,
      fill: new ol.style.Fill({ color }),
      points: 4,
      radius: blip.size * 4,
      stroke: new ol.style.Stroke({ color: [0, 0, 0, 1], width: 1.5 }),
    });
  } else {
    image = new ol.style.Icon({
      // color, // Works, but disabled because tint is not used in GTA/MTA for radar blip icons
      src: 'geticon.htm?id=' + String(blip.icon).padStart(2, 0),
    });
  }

  feature.setStyle(new ol.style.Style({ image }));

  radarBlipVectorSource.addFeature(feature);
  return feature;
}

function updateRadarBlips() {
  getAllRadarBlips(function (blips) {
    // Delete destroyed blips
    Object.entries(syncedRadarBlips)
      .filter(function (entry) {
        return !blips.find(function (blip) {
          return blip.element.id === entry[0];
        });
      })
      .forEach(function (entry) {
        radarBlipVectorSource.removeFeature(entry[1].feature);
        delete syncedRadarBlips[entry[0]];
      });

    // Add/refresh existing blips
    blips.forEach(function (blip) {
      if (!syncedRadarBlips[blip.element.id]) {
        syncedRadarBlips[blip.element.id] = {};
      } else {
        // We delete the old feature to be able to reset some styles
        // not possible to edit through existing methods provided by OL
        radarBlipVectorSource.removeFeature(
          syncedRadarBlips[blip.element.id].feature,
        );
      }

      syncedRadarBlips[blip.element.id].feature = addRadarBlip(blip);
      syncedRadarBlips[blip.element.id].data = blip;
    });

    setTimeout(updateRadarBlips, 5000);
  });
}

function updatePlayerBlips() {
  getAllPlayers(function (players) {
    // Delete disconnected players
    Object.entries(syncedPlayers)
      .filter(function (entry) {
        return !players.find(function (player) {
          return player.name === entry[0];
        });
      })
      .forEach(function (entry) {
        playerVectorSource.removeFeature(entry[1].feature);
        delete syncedPlayers[entry[0]];
      });

    if (selectedPlayer) {
      if (syncedPlayers[selectedPlayer]) {
        popupOverlay.setPosition(
          syncedPlayers[selectedPlayer].feature.getGeometry().getCoordinates(),
        );
      } else {
        closePopup();
      }
    }

    if (followingPlayer) {
      if (syncedPlayers[followingPlayer]) {
        map
          .getView()
          .setCenter(
            syncedPlayers[followingPlayer].feature
              .getGeometry()
              .getCoordinates(),
          );
      } else {
        followingPlayer = null;
      }
    }

    // Add/refresh connected players
    players.forEach(function (player) {
      if (!syncedPlayers[player.name]) {
        syncedPlayers[player.name] = {};
      } else {
        // We delete the old feature to be able to reset some styles
        // not possible to edit through existing methods provided by OL
        playerVectorSource.removeFeature(syncedPlayers[player.name].feature);
      }

      syncedPlayers[player.name].feature = addPlayerBlip(player);
      syncedPlayers[player.name].data = player;
    });

    setTimeout(updatePlayerBlips, 1000);
  });
}

function checkSendMessage(e) {
  // If not enter key, stop here
  if (e.keyCode !== 13) return true;

  const messageBox = document.getElementById('sendMessageBox');
  const message = messageBox.value.trim();
  messageBox.value = '';

  // If no message entered, stop here
  if (!message) return true;

  sendPlayerMessage(selectedPlayer, message, function () {});

  return false;
}

function followPlayer() {
  if (document.getElementById('followPlayerCheckbox').checked) {
    followingPlayer = selectedPlayer;
    map
      .getView()
      .setCenter(
        syncedPlayers[followingPlayer].feature.getGeometry().getCoordinates(),
      );
  } else {
    followingPlayer = null;
  }
}

function closePopup() {
  popupOverlay.setPosition(undefined);
  selectedPlayer = null;
}
