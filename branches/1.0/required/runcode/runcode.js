var resultstext;

function onBodyLoad () {
	resultstext = document.getElementById("results");
}

function webRun () {
	httpRun (
		codefield.getCode(),
		function () {
			var tempString = "";
			if (arguments[0] == true) {
				var first = true;
				if (arguments.length > 1) {
					tempString = "Result: ";
					for (var i = 1; i < arguments.length; i++) {
						if (first == true) {
							first = false;
						}
						else {
							tempString = tempString + ", ";
						}
						tempString = tempString + arguments[i];
					}
				}
				else {
					tempString = "No results."
				}
				resultstext.setAttribute("class", "result");
			}
			else {
				tempString = "Error: " + arguments[1];
				resultstext.setAttribute("class", "error");
			}
			resultstext.innerHTML = tempString;
		}
	);
}