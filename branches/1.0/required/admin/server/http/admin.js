var pagePrev
var pageCurrent
var pageMain = "/admin/main.htm"

function onLoad()
{
	var loc = parent.window.location
	if ( loc.href.indexOf("admin") == -1 )
	{
		parent.window.location = loc + "admin/";
	}
	setCurrentPage ( pageMain );
}

function setCurrentPage ( page )
{
    if ( page == pageMain )
	{
		pagePrev = undefined;
	}
	else
	{
		pagePrev = pageCurrent;
	}
	pageCurrent = page;
	new AJAXRequest ( "GET", pageCurrent, null, 
		function ( AJAX ) { 
			if ( AJAX.readyState == 4 && AJAX.status == 200 )
			{
				document.getElementById('page').innerHTML = AJAX.responseText;
			}
		}
	);
}

function setHomePage ( )
{
	setCurrentPage ( pageMain );
}

function setPreviousPage ( )
{
	if ( pagePrev != undefined )
	{
		setCurrentPage ( pagePrev );	
	}
}

function getServerIP ( )
{
	var location = window.location
	location.slice(6);
}

//Tables stuff
var rowSelected

function playerListRefresh () {
	var playerlist = document.getElementById ( "playerlist" );
	if ( playerlist )
	{
		httpGetPlayerList (
			function ( playerTable )
			{
				if ( playerTable.length >= 0 )
				{
					for ( i = 0; i < playerTable.length; i++ )
					{
						var row
						if ( document.getElementById ( "player_" + playerTable[i] ) == undefined )
						{
							var row = document.createElement("tr");
							playerlist.appendChild ( row );
							row.id = "player_" + playerTable[i];
							row.onclick = rowSelect;
						}
						var row = document.getElementById ( "player_" + playerTable[i] )
						var html = "<td><span style='cursor: pointer; font-weight: bold;'>" + playerTable[i] + "</span></td><td>" + playerTable[i + 1] + "</td>";
						row.innerHTML = html;
						i++;
					}
				}
			}
		);
		setTimeout("playerListRefresh();", 5000);
	}
	else
	{
		rowSelected = undefined;
	}
}

function rowSelect () {
	if ( rowSelected != undefined )
	{
		rowSelected.style.background="";
	}
	this.style.background="#BBBD95";
	rowSelected = this;
}