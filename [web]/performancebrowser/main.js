var columnNames = new Array();
var columnTints = new Array();
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


function doUpdateHeaderSections(columns) {
	var columnHeaders = document.getElementById ( "headerSections" );
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
			//var columnSize = columns[i].size.htmlEntities();
			var columnSpan = columns[i].span.toString().htmlEntities();
			
			columnElement.className = "header";
			columnElement.id        = "columnxs-" + columnName;
			columnElement.innerHTML = columnName;
			columnElement.style.width = '180px';
			//columnElement.style.width = columnSize;
			columnElement.colSpan = columnSpan;
			
			columnHeaders.appendChild ( columnElement );
		}
	}
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
            var columnTint = columns[i].tint.htmlEntities();
			columnNames[i] = columnName;
			columnTints[i] = columnTint;
			
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
			var rowClassName = rows[i][0].class;
			var rowBgColor = rows[i][0].color;
			row.className = rowClassName;

			for (j = 1; j < rows[i].length; j++)
			{
				var cell = document.createElement("td");
				cell.id = columnNames[j-1];
				cell.className = rowClassName;
				cell.innerHTML = rows[i][j].toString().htmlEntities();
			    cell.bgColor = applyTint( rowBgColor, columnTints[j-1] );
                cell.style.whiteSpace = "pre";
			    
				row.appendChild ( cell );
			}
			
			performancebrowserElement.appendChild ( row );
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
    performQuery(500);
}

function performQueryFast()
{
    performQuery(100);
}

function performQuery( delay )
{
    counter++
    showSpinner();
    setNextUpdateTime( delay );
}


function updateAll()
{
	var queryUser = document.getElementById("queryUser").innerHTML;
	var queryTarget = document.getElementById("queryTarget").value;
	var queryCategory = document.getElementById("queryCategory").value;
	var queryOptions = document.getElementById("queryOptions").value;
	var queryFilter = document.getElementById("queryFilter").value;
	var queryShowClients = document.getElementById("queryShowClients").checked ? "true" : "false";

    setQuery ( counter++, queryUser, queryTarget, queryCategory, queryOptions, queryFilter, queryShowClients,
		function (  counterReturn,
		            bQueryDone,
		            categoryColumns,categoryIndex,
		            targetColumns,targetIndex,
		            headers,
		            rows,
		            newQueryOptions,
		            newQueryFilter,
		            newQueryShowClients,
		            status1,status2,warning1)
        {

            if ( typeof(categoryColumns) == "object" )
                doUpdateCategories(categoryColumns,categoryIndex);

            if ( typeof(targetColumns) == "object" )
                doUpdateTargets(targetColumns,targetIndex);

            if ( bQueryDone )
            {
                if ( typeof(headers) == "object" )
                {
                    if ( typeof(headers[0]) == "object" )
                        doUpdateHeaderSections(headers[0]);
                        
                    if ( typeof(headers[1]) == "object" )
                        doUpdateHeaders(headers[1]);
                }

                if ( typeof(rows) == "object" )
                    doUpdateRows(rows);
            }

            if ( typeof(newQueryOptions) == "string" )
                document.getElementById ( "queryOptions" ).value = newQueryOptions;
                
            if ( typeof(newQueryFilter) == "string" )
                document.getElementById ( "queryFilter" ).value = newQueryFilter;
                
            if ( typeof(newQueryShowClients) == "string" )
                document.getElementById ( "queryShowClients" ).checked = (newQueryShowClients == "true");


            if ( typeof(status1) == "string" )
                document.getElementById ( "statusLabel1" ).innerHTML = status1;
                
            if ( typeof(status2) == "string" )
                document.getElementById ( "statusLabel2" ).innerHTML = status2;
                
            if ( typeof(warning1) == "string" )
                document.getElementById ( "warningLabel1" ).innerHTML = warning1;

            if ( !bQueryDone )
            {
                setNextUpdateTime(500);
                return;
            }
                
            hideSpinner();
		}
	);
}


////////////////////////////////////////////////
// Color manipulation
////////////////////////////////////////////////
function stringToRGB(color) {
    var R = parseInt(color.substring(1,3),16);
    var G = parseInt(color.substring(3,5),16);
    var B = parseInt(color.substring(5,7),16);
    return {R:R,G:G,B:B};
}

function RGBMultiply(a, b) {
    var R = a.R * b.R / 128;
    var G = a.G * b.G / 128;
    var B = a.B * b.B / 128;
    return {R:R,G:G,B:B};
}

function decimalToHex(d, padding) {
    var hex = parseInt(d+"").toString(16);
    padding = typeof (padding) === "undefined" || padding === null ? padding = 2 : padding;

    while (hex.length < padding) {
        hex = "0" + hex;
    }

    return hex;
}

Number.prototype.clamp = function(min, max) {
  return Math.min(Math.max(this, min), max);
};

function colorChannelToHex(d) {
    return decimalToHex(d.clamp(0,255),2);
}

function RGBToString(a) {
    return "#" + colorChannelToHex(a.R) + colorChannelToHex(a.G) + colorChannelToHex(a.B);
}


function applyTint(a,b) {
    var aa = stringToRGB(a);
    var bb = stringToRGB(b);
    var cc = RGBMultiply(aa,bb);
    var dd = RGBToString(cc);
    return dd;
}
