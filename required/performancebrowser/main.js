var columnNames = new Array();


var wasValid = false;
function updateRightNamePreview()
{
	var rightnamepreview = document.getElementById("rightnamepreview");
	rightnamepreview.innerHTML = getRightNameFromTab(selectedTab);
	var validtab = validateTab();
	if ( validtab != wasValid )
	{
		wasValid = validtab;
		document.getElementById("addButton").disabled = !validtab;
	}
}

function performancebrowserUpdate () {
	updateHeaders();
	setTimeout ( "updateRows()", 800 );
	setTimeout ( "performancebrowserUpdate()" , 3000 );
}

function updateHeaders() {
    getHttpColumns
	(
		function(columns)
		{
			var columnHeaders = document.getElementById ( "headers" );
			while (columnHeaders.hasChildNodes())
			{
				columnHeaders.removeChild ( columnHeaders.firstChild );
			}

			if (columns.length != 0)
			{
			    for (i = 0; i < columns.length; i++)
				{
					var columnElement = document.createElement("td");
					var columnName = columns[i].name.htmlEntities();
					var columnSize = columns[i].size.htmlEntities();
					columnNames[i] = columnName;
					
					columnElement.className = "header";
					columnElement.id        = "columnx-" + columnName;
					columnElement.innerHTML = columnName;
					columnElement.style.width = '180px';
					columnElement.style.width = columnSize;
					
					columnHeaders.appendChild ( columnElement );
				}
			}
        }
	);
}

function updateRows() {
    getHttpRows
	(
		function(rows)
		{
			var performancebrowserElement = document.getElementById ( "performancebrowser" );
			while (performancebrowserElement.hasChildNodes())
			{
				performancebrowserElement.removeChild ( performancebrowserElement.firstChild );
            }

            if (rows.length != 0)
	        {
	            for (i = 0; i < rows.length; i++)
		        {
					var row = document.createElement("tr");
					row.className = rows[i][0]

					for (j = 1; j < rows[i].length; j++)
					{
						var cell = document.createElement("td");
						cell.id = columnNames[j-1];
						cell.className = rows[i][0]
						cell.innerHTML = rows[i][j].toString().htmlEntities();
						row.appendChild ( cell );
					}
					
					performancebrowserElement.appendChild ( row )
				}
			}
        }
	);
}

String.prototype.htmlEntities = function () {
   return this.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
};


var timeout = null;
function performQueryDelayed()
{
	if ( timeout != null )
		clearTimeout(timeout);
	timeout = setTimeout(performQuery, 500);
}

function performQuery()
{
	timeout = null;
	document.getElementById("searchingSpinner").style.display = "inline";
	var queryCategory = document.getElementById("queryCategory").value;
	var queryOptions = document.getElementById("queryOptions").value;
	var queryFilter = document.getElementById("queryFilter").value;

    setQuery ( queryCategory, queryOptions, queryFilter,
		function ()
        {
			document.getElementById("searchingSpinner").style.display = "none";
		}
	);
}