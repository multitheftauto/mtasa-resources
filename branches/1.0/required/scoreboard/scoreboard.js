var columnNames = new Array();

function scoreboardUpdate () {
	updateHeaders();
	setTimeout ( "updateRows()", 800 );
	setTimeout ( "scoreboardUpdate()" , 3000 );
}

function updateHeaders() {
	getScoreboardColumns (
		function ( columns ) {
			var columnHeaders = document.getElementById ( "headers" );
			while ( columnHeaders.hasChildNodes() ) {
				columnHeaders.removeChild ( columnHeaders.firstChild );
			}
			
			if ( columns.length != 0 ) {
				for ( i = 0; i < columns.length; i++ ) {
					var columnElement = document.createElement("td");
					var columnName = columns[i].name.htmlEntities();
					columnNames[i] = columnName;
					
					columnElement.className = "header";
					columnElement.id        = "column-" + columnName;
					columnElement.innerHTML = columnName;
					columnElement.style.width = (columns.size * 100) + "%";
					
					columnHeaders.appendChild ( columnElement );
				}
			}
        }
	);
}

function updateRows() {
	getScoreboardRows (
		function ( scoreboardRows ) {
			var scoreboardElement = document.getElementById ( "scoreboard" );
			while ( scoreboardElement.hasChildNodes() ) {
				scoreboardElement.removeChild ( scoreboardElement.firstChild );
			}
			
			if ( scoreboardRows.length != 0 ) {
				for ( i = 0; i < scoreboardRows.length; i++ ) {
					var row = document.createElement("tr");
					row.className = scoreboardRows[i][0]
					
					for ( j = 1; j < scoreboardRows[i].length; j++ ) {
						var cell = document.createElement("td");
						cell.id = columnNames[j-1];
						cell.className = scoreboardRows[i][0]
						cell.innerHTML = scoreboardRows[i][j].toString().htmlEntities();
						row.appendChild ( cell );
					}
					
					scoreboardElement.appendChild ( row )
				}
			}
        }
	);
}

String.prototype.htmlEntities = function () {
   return this.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
};