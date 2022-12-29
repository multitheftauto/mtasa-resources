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

// Check data is JSON
function isJSON(str) {
	try {
		JSON.parse(str);
	} catch (e) {
		return false;
	}
    return true;
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

            for (const version of versions) {
                try {
					// try to create the object
					// if it doesn't work, we'll try again
					// if it does work, we'll save a reference to the proper one to speed up future instantiations
                    self.AJAX = new ActiveXObject(version);

                    if (self.AJAX) {
                        _ms_XMLHttpRequest_ActiveX = version;
                        break;
                    }
                }
                catch (objException) {
                	// trap; try next one
                }
            }
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
		if (method == "POST" && isJSON(data)) // change content type
			self.AJAX.setRequestHeader("Content-Type", "application/json");
			
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

class ElementManager {
	constructor() {
		this.elements = new Array();
	}
	
	get(id) {
		for (const element of this.elements) {
			if (element.id != null && element.id == id) {
				return element;
			}
		}
		const newElement = new Element(id);
		this.elements[this.elements.length] = newElement;
		return newElement;
	}
}

class ResourceManager {
	constructor() {
		this.resources = new Array();
	}

	get(name) {
		for (const resource of this.resources) {
			if (resource.name != null && resource.name == name) {
				return resource;
			}
		}
		const newResource = new Resource(name);
		this.resources[this.resources.length] = newResource;
		return newResource;
	}
}

class Element {
	constructor(id) {
		this.id = id;
	}

	toString() {
		return '^E^' + this.id;
	}
}


class Resource {
	constructor(name) {
		this.name = name;
	}

	toString() {
		return '^R^' + this.name;
	}
}

var elementManager = new ElementManager();
var resourceManager = new ResourceManager();

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
		data = JSON.stringify(args, serverObjectsSerializer);
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
						values = JSON.parse(AJAX.responseText, serverObjectsDeserializer);

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

function serverObjectsDeserializer(_key, value) {
	if (typeof(value) == "string") {
		if (value.startsWith('^E^')) {
			return elementManager.get(value.substring(3));
		}

		if (value.startsWith('^R^')) {
			return resourceManager.get(value.substring(3));
		}
	}

	return value;
}

function serverObjectsSerializer(_key, value) {
	if (value instanceof Resource || value instanceof Element) {
		return value.toString();
	}

	return value;
}