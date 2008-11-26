<*
if querystring["resource"] ~= "" then
	local resource = getResourceFromName(querystring["resource"])
	if resource then
		local exports = getResourceExportedFunctions(resource)
		for k,v in pairs(exports) do
			*>
			function <* = v *> (  ) {
				var args = new Array();
				for ( var i = 0; i < arguments.length - 1 ; i++ )
			    {	
					args[i] = arguments[i];
				}

				var resultHandler = arguments[arguments.length-1];

				callFunction ( "<* = querystring["resource"] *>", "<* = v *>", resultHandler,

				function ( error ) /* called if an error occurs, 'error' contains a text message of the error */
				{
					alert("An error occured while calling '<* = v *>':\n\n" + error);
				},
				args);
			}
			<*
		end
	else
	*>
		Invalid resource
	<*
	end
else
	*>
	Specify a resource in the query string please!
	<*
end
*>