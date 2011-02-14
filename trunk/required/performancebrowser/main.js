var columnNames = new Array();
var counter = 0;
var mainTimeout = null;

function performancebrowserLoad () {
	performancebrowserUpdate();
}


function performancebrowserUpdate () {
	updateAll();
	setNextUpdateTime( 3000 );
}

function setNextUpdateTime ( delay ) {
    if ( mainTimeout != null )
        clearTimeout(mainTimeout);
    mainTimeout = setTimeout ( "performancebrowserUpdate()" , delay );
}


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


function doUpdateHeaders(columns) {
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

function doUpdateRows(rows) {
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


String.prototype.htmlEntities = function () {
   return this.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
};


function showSpinner()
{
    document.getElementById("searchingSpinner").style.display = "inline";	
}

function hideSpinner()
{
    document.getElementById("searchingSpinner").style.display = "none";	
}


function performQuerySlow()
{
    performQuery(500)
}

function performQueryFast()
{
    performQuery(100)
}

function performQuery( delay )
{
    counter++
    showSpinner();
    setNextUpdateTime( delay )
}


function updateAll()
{
	var queryUser = document.getElementById("queryUser").innerHTML;
	var queryTarget = document.getElementById("queryTarget").value;
	var queryCategory = document.getElementById("queryCategory").value;
	var queryOptions = document.getElementById("queryOptions").value;
	var queryFilter = document.getElementById("queryFilter").value;

    setQuery ( counter++, queryUser, queryTarget, queryCategory, queryOptions, queryFilter,
		function (  counterReturn,
		            bQueryDone,
		            categoryColumns,categoryIndex,
		            targetColumns,targetIndex,
		            headers,
		            rows,
		            newQueryOptions,
		            newQueryFilter,
		            status1,status2)
        {
            if ( !bQueryDone )
            {
                setNextUpdateTime(500)
                return;
            }
/*
            if ( counterReturn + 1 != counter )
            {
                document.getElementById ( "statusLabel1" ).innerHTML = "..."
                return;
            }
*/
            if ( typeof(categoryColumns) == "object" )
                doUpdateCategories(categoryColumns,categoryIndex);

            if ( typeof(targetColumns) == "object" )
                doUpdateTargets(targetColumns,targetIndex);

            
            if ( typeof(headers) == "object" )
                doUpdateHeaders(headers);

            if ( typeof(rows) == "object" )
                doUpdateRows(rows);


            if ( typeof(newQueryOptions) == "string" )
                document.getElementById ( "queryOptions" ).value = newQueryOptions
                
            if ( typeof(newQueryFilter) == "string" )
                document.getElementById ( "queryFilter" ).value = newQueryFilter


            if ( typeof(status1) == "string" )
                document.getElementById ( "statusLabel1" ).innerHTML = status1
                
            if ( typeof(status2) == "string" )
                document.getElementById ( "statusLabel2" ).innerHTML = status2
                
            hideSpinner();
		}
	);
}
