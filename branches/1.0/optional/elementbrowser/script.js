function load()
{	
	var root = null;
	getRootElement ( 
		function ( rootElement ) 
		{    
			root = rootElement; 
			generateNode ( root, null );
		}
	);
}

/**
This function calls the 'getElementInfo' function specified in elementbrowser.lua. This function
returns a few useful bits of information:
* The type of the element
* The ID of the element
* If the element has any children
* An object containing all the element data values that the element has
**/
function loadElementInfo(element)
{
	getElementInfo( element,
		function ( type, id, childcount, data )
		{
			var dataList = "{";
			for ( var key in data )
			{
				if ( key != "toJSONString" )
				{
					dataList += key + " = " + data[key] + ", ";
				}
			}
			if ( dataList != "{" )
			{
				dataList = dataList.substr(0, dataList.length-2);
				dataList += "}";
			}
			else
				dataList = "";

			var listElement = document.getElementById("E" + element.id);
			var idText = "";
			if ( id != "" )
				idText = "<strong>" + id + "</strong>: ";
			listElement.innerHTML = idText + type + " <i>" + dataList + "</i> <span class='temp' id='T" + element.id + "'></span>";
			element.childcount = childcount;
			if ( childcount != 0 )
			{
				listElement.className = "plus";
			}
			else
				listElement.className = "empty";
		}
	);
}

/**
Called when the user clicks on a node. Expands or hides the node, depending on it's current state. If the node is expanded
it requests the children from the server by calling expand()
**/
function onNodeClick(e) {
	if (!e) var e = window.event
	var target
	if ( e.target )
		target = e.target;
	else if ( e.srcElement )
		target = e.srcElement;

	if ( target == this || target.parentNode == this )
	{
		if ( target.parentNode == this )
			target = target.parentNode;
		var elementid = target.id.substr(1);
		var container = document.getElementById("C" + elementid);
		if ( target.className == "plus" )
		{
			target.className = "loading";
			if ( container )
			{
				container.style.display = "block";
			}
			expand(target.id.substr(1));
		}
		else if ( target.className == "minus" )
		{
			target.className = "plus";
			container.style.display = "none";
		}
	}
}

/** 
Generates a new 'li' element for the specified MTA game element, with the parent element specified
Specifying null as the parentid uses the root of the tree as the parent
**/
function generateNode ( element, parentid )
{
	var parent = null;
	if ( parentid == null )
		parent = document.getElementById("tree");
	else 
		parent = document.getElementById("C" + parentid );

	var node = document.getElementById("E" + element.id);
	if ( node == null )
	{
		node = document.createElement("li");
	}
	parent.appendChild(node);
	node.onclick=onNodeClick;
	if (node.captureEvents) node.captureEvents(Event.CLICK);
	node.innerHTML = "Loading...";
	node.id = "E" + element.id;
	node.className = "loading";
	loadElementInfo ( element );
}

/**
This function requests the child elements for a specified element
**/
function expand(elementid)
{
	var parentElement = elementManager.get ( elementid );
	if ( parentElement.childcount != 0 )
	{
		document.getElementById("T" + parentElement.id).innerHTML = "(Loading " + parentElement.childcount + " children...)";
		getElementChildren ( elementManager.get ( elementid ),
			function ( children )
			{
				var parent = document.getElementById("E" + elementid);
				if ( children.length != 0 )
				{
					parent.className = "minus";
					// create a container for the children
					var container = document.createElement("ul");
					container.id = "C" + elementid;
					parent.appendChild(container);
					// create elements for all the children inside the container
					for ( var i = 0; i  < children.length ; i++ )
						generateNode ( children[i], elementid );
					document.getElementById("T" + parentElement.id).innerHTML = "";
				}
				else
				{
					parent.className = "empty";
				}

			}
		);
	}
}