var mainContainer;
var otherMapsContainer;
var otherMapsLabel;
var gamemodeList;

var runningGamemodeName = "";
var runningMapName = "";
var noMapsNorModes = true;
var mapListsLeft = 0;

function onBodyLoad() {
	mainContainer = document.getElementById ( "contentarea" );
	gamemodeListRefresh();
}

function checkIfEmpty() {
	mapListsLeft--;
	if ( ( mapListsLeft == 0 ) && (noMapsNorModes) ) {
		var emptyLabel = document.createElement("span");
		emptyLabel.innerHTML = "The server is empty!";
		mainContainer.appendChild ( emptyLabel );
	}
}

function gamemodeListRefresh () {
	getCachedGamemodeList (
		function ( gamemodeList ) {
			while ( mainContainer.hasChildNodes() ) {
				mainContainer.removeChild ( mainContainer.firstChild );
			}

			mapListsLeft = gamemodeList.length + 1;

			for ( i = 0; i < gamemodeList.length ; i++ ) {
				var gamemodeContainer = document.createElement("div");
				gamemodeContainer.id = "div-" + gamemodeList[i].name;
				gamemodeContainer.className = "gmdiv";

				var gamemodeLabel = document.createElement("span");
				gamemodeLabel.id = "label-" + gamemodeList[i].name;
				gamemodeLabel.className = "mapsheader";
				gamemodeLabel.innerHTML = gamemodeList[i].name;
				gamemodeLabel.gamemodeName = gamemodeList[i].name

				gamemodeContainer.headerLabel = gamemodeLabel


				mainContainer.appendChild ( gamemodeLabel );
				mainContainer.appendChild ( gamemodeContainer );

				expandMapList(gamemodeList[i])
			}

			otherMapsContainer = document.createElement("div");
			otherMapsContainer.id = "none-div";
			otherMapsContainer.className = "gmdiv";

			otherMapsLabel = document.createElement("span");
			otherMapsLabel.id = "none-label";
			otherMapsLabel.className = "mapsheader";
			otherMapsLabel.innerHTML = "non-gamemode maps";

			otherMapsContainer.headerLabel = otherMapsLabel;

			mainContainer.appendChild ( otherMapsLabel );
			mainContainer.appendChild ( otherMapsContainer );

			expandMapList(false);
		}
	);

	highlightRunning();
}

function highlightRunning() {
	getRunningGamemode (
		function (gamemode) {
			var previousLabel = document.getElementById("label-" + runningGamemodeName);
			if (previousLabel) {
				previousLabel.className = "mapsheader";
			}

			if (gamemode) {
				runningGamemodeName = gamemode.name;
				var newLabel = document.getElementById("label-" + runningGamemodeName);
				if (newLabel) {
					newLabel.className = "highlighted mapsheader";
				}
			}
			else {
				runningGamemodeName = "";
			}

			getRunningGamemodeMap (
				function (map) {
					var previousLabel = document.getElementById("map-" + runningMapName);
					if (previousLabel) {
						previousLabel.className = "map";
					}

					if (map) {
						runningMapName = map.name;
						var newLabel = document.getElementById("map-" + runningMapName);
						if (newLabel) {
							newLabel.className = "highlighted map";
						}
					}
					else {
						runningMapName = "";
					}
				}
			);
		}
	);

	setTimeout("highlightRunning();", 5000)
}

function expandMapList( gamemode ) {
	getMapsCompatibleWithGamemode ( gamemode,
		function (mapList) {
			var gamemodeContainer;
			var noMapsForGamemode = true;

			if (gamemode) {
				noMapsNorModes = false;
				gamemodeContainer = document.getElementById("div-" + gamemode.name);
			}
			else {
				gamemodeContainer = otherMapsContainer;
				if ( mapList.length == 0 )
					otherMapsLabel.style.display = 'none';
				else
					noMapsNorModes = false;
			}

			for ( i = 0; i < mapList.length ; i++ ) {
				noMapsForGamemode = false;
				var mapLabel = document.createElement("span");
				mapLabel.id = "map-" + mapList[i].name;
				mapLabel.innerHTML = mapList[i].name;
				mapLabel.mapName = mapList[i].name;
				mapLabel.className = "map";

				if ( gamemodeContainer != otherMapsContainer ) {
					mapLabel.gamemodeName = gamemode.name;
					mapLabel.style.cursor = "pointer"
					mapLabel.onclick = function (){
										changeGamemodeByName ( this.gamemodeName, this.mapName, function() { highlightRunning(); } );
									}
				}

				gamemodeContainer.appendChild ( mapLabel )
				gamemodeContainer.appendChild ( document.createElement("br") )
			}

			if (noMapsForGamemode) {
				gamemodeContainer.headerLabel.style.cursor = "pointer"
				gamemodeContainer.headerLabel.onclick = function(){
														changeGamemodeByName ( this.gamemodeName, function() { highlightRunning(); } )
													}
			}


			checkIfEmpty();
		}
	);
}

