var resultstext;

function onBodyLoad () {
	resultstext = CodeMirror.fromTextArea(document.getElementById("code"),{tabMode: "indent",matchBrackets: true,theme: "neat"});
}

function webRun () {
	httpRun(resultstext.getValue(),
		function () {
			alert(arguments[0])
		}
	);
}