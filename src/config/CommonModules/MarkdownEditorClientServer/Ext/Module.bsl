#Region Interface

Function MarkdownToHTML(Val Text) Export
	 
	Template = 
	"<!DOCTYPE html>
	|<html>
	|<head>
	|	<meta charset=""utf-8""/>
	|	<meta http-equiv=""X-UA-Compatible"" content=""IE=9""/>
	|	<meta name=""viewport"" content=""width=device-width, initial-scale=1"">
	|	<link href=""https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/3.0.1/github-markdown.min.css"" rel=""stylesheet"">
	|	<style>.markdown-body{box-sizing:border-box;min-width:200px;max-width:980px;margin:0 auto;padding:45px;}@media(max-width:767px){.markdown-body{padding:15px;}}</style>
	|</head>
	|<body>
	|<article class=""markdown-body"">
	|	<div id=""content""></div>
	|	<script src=""https://cdn.jsdelivr.net/npm/marked/lib/marked.min.js""></script>
	| 	<script>
	|  		document.getElementById('content').innerHTML = marked('%1');
	|	</script>
	|</article>
	|</body>
	|</html>";
	
	Text = StrReplace(Text, Chars.LF, "\r\n");
	Text = StrReplace(Text, "'", "\'");
	
	Return StrTemplate(Template, Text);
	
EndFunction

#EndRegion