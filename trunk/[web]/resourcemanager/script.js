var chunkStart = 1;
var itemsToLoadAtOnce = 20;
var firstload = true;
var oldhtml = new Array();

var resourceFromName = new Array();
var isRequesting = false;
var blockedRequests = 0;

var timeout = null;
function performSearchDelayed()
{
	if ( timeout != null )
		clearTimeout(timeout);
	timeout = setTimeout(performSearch, 500);
}

function performSearch()
{
	timeout = null;
	document.getElementById("searchingSpinner").style.display = "inline";
	var searchText = document.getElementById("searchText").value;
	var searchState = document.getElementById("searchState").value;
	
	if ( searchState == "any" ) 
		searchState = "";
	getResourcesSearch ( searchText, searchState,
		function ( resourceTable, stateTable )
        {
		
			for ( i = 0; i < resourceTable.length; i += 1 )
			{
				resourceTable[i].state = stateTable[i];
			}
			resourceTable = resourceTable.sort(
				function(a,b) 
				{ 
					if ( a.name.toLowerCase() < b.name.toLowerCase() )
						return -1;
					else if ( a.name.toLowerCase() > b.name.toLowerCase() ) 
						return 1;
					else
						return 0; 
				}
			);
				
			var resourceList = document.getElementById ( "resourcelist" );
		
			while ( resourceList.rows.length != 0 )
			{
				resourceList.deleteRow(0);
			}
			
			var contentTable = null;
			var activerow = null;
			var j = 3;
			for ( i = 0; i < resourceTable.length; i++ )
			{
				resourceFromName[resourceTable[i].name] = resourceTable[i];

				if (  i == 0 || resourceTable[i-1].name.substr(0,1).toLowerCase() != resourceTable[i].name.substr(0,1).toLowerCase())
				{	
					// add some padding cells if the last row wasn't filled
					if ( activerow != null )
					{
						for(;j != 0; j--) {
							var cell = activerow.insertCell(-1);
							cell.className = "resourcecell";
						}
					}
					
					var row = resourceList.insertRow (-1);
					
					var letterCell = row.insertCell(-1);
					if ( i == 0 ) 
						letterCell.className = "lettercell_first";
					else
						letterCell.className = "lettercell";
					letterCell.innerHTML =  resourceTable[i].name.substr(0,1).toUpperCase();
					
					var cell = row.insertCell(-1);
					if ( i != 0 ) 
						cell.className = "letterrowcontentcell";
						
					contentTable = document.createElement("table");
					contentTable.className = "resourcelisttable";
					activerow = contentTable.insertRow(-1);
					j = 3;
					cell.appendChild(contentTable);
				}

				if ( resourceTable[i].state == "loaded" ) 
					col = "#FF7F00";
				else if ( resourceTable[i].state == "running" )
					col = "#338833";
				else
					col = "#FF3333";

				if ( j == 0 ) {
					activerow = contentTable.insertRow(-1);
					j = 3;
				}
				var cell = activerow.insertCell(-1);
				cell.className = "resourcecell";
				cell.innerHTML = "<div id='resource-" + resourceTable[i].name + "' style='cursor: pointer; color:" + col + "' onClick='showInfo(\"" + resourceTable[i].name + "\")'><span style='font-weight: bold;'>" 
					+ resourceTable[i].name + "</span></div>";
				
				j--;
			}
			
			// add some padding cells if the last row wasn't filled
			if ( activerow != null )
			{
				for(;j != 0; j--) {
					var cell = activerow.insertCell(-1);
					cell.className = "resourcecell";
				}
			}
			document.getElementById("searchingSpinner").style.display = "none";
		}
	);
}

function refreshResourcesButton (refreshall)
{
	document.getElementById("refreshallbutton").value = ""
	document.getElementById("refreshallbutton").disabled = true
	document.getElementById("refreshbutton").value = ""
	document.getElementById("refreshbutton").disabled = true
	
	refreshResources(refreshall,
		function ()
		{
			performSearch()
			setTimeout("showRefreshButtons()",5000);
		}
	);
}

function showRefreshButtons ()
{
	document.getElementById("refreshallbutton").value = "refreshall";
	document.getElementById("refreshallbutton").disabled = false;
	document.getElementById("refreshbutton").value = "refresh";
	document.getElementById("refreshbutton").disabled = false;
}

function getButtons ( resource, resourceState )
{
    var html = "";
	if ( resourceState == "running" )
	{
		html += "<input type='button' value='start' disabled='true'>";
		html += "<input type='button' onClick=\"stopResourceButton('" + resource.name + "')\" value='stop'>" +
		"<input type='button' onClick=\"restartResourceButton('" + resource.name + "')\" value='restart'>";
		
	} 
	else if ( resourceState == "loaded" )
	{
		html += "<input type='button' onClick=\"startResourceButton('" + resource.name + "')\" value='start'>";
		html += "<input type='button' value='stop' disabled='true'>" +
		"<input type='button'  value='restart'  disabled='true'>";
		
	}
	else // failed
	{
		html += "<input type='button' value='start' disabled='true'>" +
			"<input type='button' value='stop' disabled='true'>" +
		"<input type='button' value='restart'  disabled='true'>";
	}
	return html;
}

function startResourceButton ( resourceName )
{
	var resource = resourceFromName[resourceName];
    //document.getElementById ( "state-" + resourceName ).innerHTML = "<img src='/ajax/loading.gif' id='loading-" + resourceName + "'/>";

	startResource ( resource,
		function ( wasSuccessful ) {
			var newState;
			getResourceState ( resource,
				function ( state ) {
					newState = state;
					
					if ( state == "loaded" ) 
						col = "#FF7F00";
					else if ( state == "running" )
						col = "#338833";
					else
						col = "#FF3333";
					document.getElementById ( "resource-" + resource.name ) .style.color = col;
					
					if ( currentResourceInfo == resource )
						document.getElementById( "startstopbuttons" ).innerHTML = getButtons ( resource, newState );
				}
			);
		}
	);
	refreshInfo ( )
}

function restartResourceButton ( resourceName )
{
    var resource = resourceFromName[resourceName];
    //document.getElementById ( "state-" + resourceName ).innerHTML = "<img src='/ajax/loading.gif' id='loading-" + resourceName + "'/>";

	restartResource ( resource,
		function ( wasSuccessful ) {
			//alert('Restart successful');
			var newState;
			getResourceState ( resource,
				function ( state ) {
					newState = state;
					
					if ( state == "loaded" ) 
						col = "#FF7F00";
					else if ( state == "running" )
						col = "#338833";
					else
						col = "#FF3333";
					document.getElementById ( "resource-" + resource.name ) .style.color = col;
					
					if ( currentResourceInfo == resource )
						document.getElementById( "startstopbuttons" ).innerHTML = getButtons ( resource, newState );
				}
			);
		}
	);
	refreshInfo ( )
}

function stopResourceButton ( resourceName )
{
	var resource = resourceFromName[resourceName];
	
	stopResource ( resource,
		function ( wasSuccessful ) {
			var newState;
			getResourceState ( resource,
				function ( state ) {
					newState = state;
					
					if ( state == "loaded" ) 
						col = "#FF7F00";
					else if ( state == "running" )
						col = "#338833";
					else
						col = "#FF3333";
					document.getElementById ( "resource-" + resource.name ) .style.color = col;
					
					if ( currentResourceInfo == resource )
						document.getElementById( "startstopbuttons" ).innerHTML = getButtons ( resource, newState );
				}
			);
		}
	);
	refreshInfo ( )
}

var currentResourceInfo = null;
function showInfo ( resourceName )
{
	var resource = resourceFromName[resourceName];
	currentResourceInfo = resource;
    getInfo ( resource );

	var resourceInfoHeight = (window.pageYOffset + window.innerHeight/4)
	
    document.getElementById ( "resourceinfo" ).style.display = "inline";
	
	document.getElementById( "resultlist" ).style.right = "30%";
	
	document.getElementById("startstopbuttons" ).innerHTML = getButtons(resource, "waiting");
}

function hideInfo ( )
{
    document.getElementById ( "resourceinfo" ).style.display = "none";
	document.getElementById( "resultlist" ).style.right = "0px";
}

var lastResource;
function getInfo ( resource )
{
    lastResource = resource;
    document.getElementById ( "resourceInfoLoading" ).style.display = "inline";
    document.getElementById ( "resourceinfocontent" ).style.display = "none";
	
	getResourceInfo( resource, 
        function ( result ) /* called when the results arrive, each result in a seperate variable */
        {
            var contentarea = document.getElementById ( "resourceinfocontent" );
            document.getElementById ( "resourceInfoLoading" ).style.display = "none";
            contentarea.style.display = "block";
            var html = "Resource state: " + result.state + "<br/>";
            if ( result.failurereason != "" )
                html += "Fail reason: " + result.failurereason + "<br/>";
            if ( result.state == "running" )
            {
                html += "Started: " + result.starttime + "<br/>";
            }
            else
                html += "Last started: " + result.starttime + "<br/>";

            html += "Loaded: " + result.loadtime + "<br/>";
			
			if ( result.author != false )
				html += "Author: " + result.author + "<br/>";
			if ( result.version != false )
				html += "Version: " + result.version + "<br/>";
			
			document.getElementById( "resourcename" ).innerHTML = resource.name;

            contentarea.innerHTML = html;

            document.getElementById ( "resourceInfoLoading" ).style.display = "none";
			
			document.getElementById("startstopbuttons" ).innerHTML = getButtons(resource, result.state);
        }
	);
}

function refreshInfo ( )
{
    getInfo ( lastResource );
}