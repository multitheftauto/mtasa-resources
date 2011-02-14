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

function performancebrowserLoad () {
    updateCategories();
	performancebrowserUpdate();

	var queryUser = document.getElementById("queryUser").innerHTML;
    getSelected ( queryUser,
		function(targetIndex,categoryIndex,queryOptionsText,queryFilterText)
		{
    		document.getElementById("queryTarget").selectedIndex = targetIndex;
    		document.getElementById("queryCategory").selectedIndex = categoryIndex;
    		document.getElementById("queryOptions").value = queryOptionsText;
    		document.getElementById("queryFilter").value = queryFilterText;
    		performQuery();
        }
	);
}


function performancebrowserUpdate () {
	updateHeaders();
	setTimeout ( "updateRows()", 800 );
	setTimeout ( "performancebrowserUpdate()" , 3000 );
}
			
function updateCategories() {
	var queryUser = document.getElementById("queryUser").innerHTML;
    getCategories ( queryUser,
		function(columns,bChanged,categoryIndex)
		{
		    doUpdateCategories( columns, categoryIndex );
    		document.getElementById("queryCategory").selectedIndex = categoryIndex;
        }
	);
}

/*
function maybeUpdateCategories() {
	var queryUser = document.getElementById("queryUser").innerHTML;
    getCategories ( queryUser,
		function(columns,bChanged,categoryIndex)
		{
		    if ( bChanged )
    		    doUpdateCategories( columns, categoryIndex );
        }
	);
}
*/

function doUpdateCategories(columns,categoryIndex) {

	var columnHeaders = document.getElementById ( "queryCategory" );
	while (columnHeaders.hasChildNodes())
	{
		columnHeaders.removeChild ( columnHeaders.firstChild );
	}

	if (columns.length != 0)
	{
	    for (i = 0; i < columns.length; i++)
		{
			var columnElement = document.createElement("option");
			var columnName = columns[i].htmlEntities();
			columnElement.innerHTML = columnName;
			columnHeaders.appendChild ( columnElement );
		}
	}
	
	document.getElementById("queryCategory").selectedIndex = categoryIndex;
}


function doUpdateTargets(columns,targetIndex) {

	var columnHeaders = document.getElementById ( "queryTarget" );
	while (columnHeaders.hasChildNodes())
	{
		columnHeaders.removeChild ( columnHeaders.firstChild );
	}

	if (columns.length != 0)
	{
	    for (i = 0; i < columns.length; i++)
		{
			var columnElement = document.createElement("option");
			var columnName = columns[i].htmlEntities();
			columnElement.innerHTML = columnName;
			columnHeaders.appendChild ( columnElement );
		}
	}
	
	document.getElementById("queryTarget").selectedIndex = targetIndex;
}


function updateHeaders() {
	var queryUser = document.getElementById("queryUser").innerHTML;
    getHttpColumns ( queryUser,
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
	var queryUser = document.getElementById("queryUser").innerHTML;
    getHttpRows ( queryUser,
		function(rows,bQuerydone,bTargetsChanged)
		{
		    if ( bQuerydone )
                document.getElementById("searchingSpinner").style.display = "none";
                
		    if ( bTargetsChanged )
                performQueryDelayed();

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
	var queryUser = document.getElementById("queryUser").innerHTML;
	var queryTarget = document.getElementById("queryTarget").value;
	var queryCategory = document.getElementById("queryCategory").value;
	var queryOptions = document.getElementById("queryOptions").value;
	var queryFilter = document.getElementById("queryFilter").value;

    setQuery ( queryUser, queryTarget, queryCategory, queryOptions, queryFilter,
		function (categoryColumns,bUpdateCategories,categoryIndex,targetColumns,bUpdateTargets,targetIndex)
        {
            if ( bUpdateCategories )
            {
                doUpdateCategories(categoryColumns,categoryIndex);
                performQueryDelayed();
            }
            if ( bUpdateTargets )
            {
                doUpdateTargets(targetColumns,targetIndex);
                performQueryDelayed();
            }
		}
	);
}
