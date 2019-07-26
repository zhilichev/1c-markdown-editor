#Region Interface

Function MarkdownToHTML(Val Text) Export
	 
	Template = 
	"<!DOCTYPE html>
	|<html>
	|<head>
	|	<meta charset=""utf-8""/>
	|	<meta http-equiv=""X-UA-Compatible"" content=""IE=9""/>
	|	<link href=""http://www.redmine.org/stylesheets/application.css"" rel=""stylesheet"">
	|</head>
	|<body>
	|	<div id=""content""></div>
	|	<script src=""https://cdn.jsdelivr.net/npm/marked/lib/marked.min.js""></script>
	| 	<script>
	|  		document.getElementById('content').innerHTML = marked('%1');
	|	</script>
	|</body>
	|</html>";
	
	Text = StrReplace(Text, Chars.LF, "\r\n");
	Text = StrReplace(Text, "'", "\'");
	
	Return StrTemplate(Template, Text);
	
EndFunction

#EndRegion