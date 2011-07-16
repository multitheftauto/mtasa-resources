var _ms_XMLHttpRequest_ActiveX = ""; // Holds type of ActiveX to instantiate

// DO NOT USE THIS FOR QUERIES TO MTA, mta cannot decode UTF-8 strings, use escape instead
function encode( uri ) {
    if (encodeURIComponent) {
        return encodeURIComponent(uri);
    }

    if (escape) {
        return escape(uri);
    }
}

// DO NOT USE THIS FOR QUERIES TO MTA, mta cannot decode UTF-8 strings, use escape instead
function decode( uri ) {
    uri = uri.replace(/\+/g, ' ');

    if (decodeURIComponent) {
        return decodeURIComponent(uri);
    }

    if (unescape) {
        return unescape(uri);
    }

    return uri;
}


function AJAXRequest( method, url, data, process, async, dosend) {  
    var self = this;

    // check the dom to see if this is IE or not
    if (window.XMLHttpRequest) {
    	// Not IE
        self.AJAX = new XMLHttpRequest();
    } else if (window.ActiveXObject) {
        // IE
        // Instantiate the latest MS ActiveX Objects
        if (_ms_XMLHttpRequest_ActiveX) {
            self.AJAX = new ActiveXObject(_ms_XMLHttpRequest_ActiveX);
        } else {
	    // loops through the various versions of XMLHTTP to ensure we're using the latest
	    var versions = ["Msxml2.XMLHTTP.7.0", "Msxml2.XMLHTTP.6.0", "Msxml2.XMLHTTP.5.0", "Msxml2.XMLHTTP.4.0", "MSXML2.XMLHTTP.3.0", "MSXML2.XMLHTTP",
                        "Microsoft.XMLHTTP"];

            for (var i = 0; i < versions.length ; i++) {
                try {
		    // try to create the object
		    // if it doesn't work, we'll try again
		    // if it does work, we'll save a reference to the proper one to speed up future instantiations
                    self.AJAX = new ActiveXObject(versions[i]);

                    if (self.AJAX) {
                        _ms_XMLHttpRequest_ActiveX = versions[i];
                        break;
                    }
                }
                catch (objException) {
                // trap; try next one
                } ;
            }

            ;
        }
    }
    
    self.process = process;

    // create an anonymous function to log state changes
    self.AJAX.onreadystatechange = function( ) {
        self.process(self.AJAX);
    }

    // if no method specified, then default to POST
    if (!method) {
        method = "POST";
    }

    method = method.toUpperCase();

    if (typeof async == 'undefined' || async == null) {
        async = true;
    }

    self.AJAX.open(method, url, async);

    if (method == "POST") {
        //self.AJAX.setRequestHeader("Connection", "close"); // seems to cause issues in IE
        self.AJAX.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        self.AJAX.setRequestHeader("Method", "POST " + url + "HTTP/1.1");
    }

    // if dosend is true or undefined, send the request
    // only fails is dosend is false
    // you'd do this to set special request headers
    if ( dosend || typeof dosend == 'undefined' ) {
	    if ( !data ) data=""; 
	    self.AJAX.send(data);
    }
    return self.AJAX;
}

/* simple way to get a keycode from an event, e.g. onKeyDown */
function getKeyCode ( e )
{
    if(window.event) // IE
    {
        keynum = e.keyCode;
    }
    else if(e.which) // Netscape/Firefox/Opera
    {
        keynum = e.which;
    }
    return keynum;
}

var elementManager = new ElementManager();

function ElementManager() {
	this.elements = new Array();
	this.get = function (id) {
		for ( i = 0; i < this.elements.length; i++ )
		{
			var element = this.elements[i];
			if ( element.id != null  )
			{
				if ( element.id == id )
				{
					return element;
				}
			}
		}
		var newElement = new Element(id);
		this.elements[this.elements.length] = newElement;
		return newElement;
	}
}

var resourceManager = new ResourceManager();

function ResourceManager() {
	this.resources = new Array();
	this.get = function (name) {
		for ( i = 0; i < this.resources.length; i++ )
		{
			var resource = this.resources[i];
			if ( resource.name != null )
			{
				if ( resource.name == name )
				{
					return resource;
				}
			}
		}
		var newResource = new Resource(name);
		this.resources[this.resources.length] = newResource;
		return newResource;
	}
}

function Element(id) {
	this.id = id;
	this.toJSONString = function() {
		return '"^E^' + id + '"';
	}
}

function Resource(name) {
	this.name = name;
	this.toJSONString = function() {
		return '"^R^' + name + '"';
	}
}

var values;
var usePOST = true;
/** Call a server function **/
function callFunction ( resourceName, functionName, returnFunction, errorFunction, args )
{
    var url = "/" + resourceName + "/call/" + functionName;
	var data = "";
	var method="GET";
	if ( usePOST == true )
	{
		data = args.toJSONString();
		method = "POST";
	}
	else
	{
		for ( var i = 0; i < args.length ; i++ )
		{
			if ( i != 0 )
				url += "&";
			else
				url += "?";
			url += i + "=" + escape(args[i]);
		}
	}


    new AJAXRequest(method, url, data, 
    /* This is an anonymous function that handles every ajax return, processes it and passes it on to the function that needs it */
    function ( AJAX )
    {
        if (AJAX.readyState == 4) {

            if (AJAX.status == 200) {
				if ( returnFunction != null )
				{
					globalReturnTemp = returnFunction;
					//try
					{
						values = AJAX.responseText.parseJSON(function (key, value) {
							if ( typeof(value) == "string" )
							{
								if ( value.indexOf('^E^') == 0 )
								{
									return elementManager.get(value.substr(3));
								}
								else if ( value.indexOf('^R^') == 0 )
								{
									return resourceManager.get(value.substr(3));
								}
							}
							return value;  
						});	
						var argumentList = "";
						for ( i = 0; i < values.length ; i++ )
						{
							argumentList += "values[" + i + "]";
							if ( i != values.length - 1 )
								argumentList += ",";
						}
			
						var funcCall = "globalReturnTemp(" + argumentList + ");";

						eval ( funcCall );
						values = null;
						return;
					}
					/*catch (error)
					{
						if ( errorFunction != null )
							errorFunction (  error );
						return;
					}*/
				}

                if ( errorFunction != null )
                    errorFunction (  AJAX.responseText );
                return;
            }

            if ( AJAX.status == 404 ) {
                /* Silently fail for 404 (resource not running) to prevent errors on server restart */
                return;
            }

            if ( errorFunction != null )
                errorFunction ( "ajax: " + AJAX.statusText );
        }

    }
    
    , true);
}
