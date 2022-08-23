#Region Interface

Function MarkdownToHTML(Val Text) Export
	 
	Template =
	"<!DOCTYPE HTML>
	|<html lang=""ru"">
	|<head>
	|<title>1C:Enterprise Markdown Editor by Alexander Zhilichev</title>
	|<meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8"" />
	|<meta http-equiv=""X-UA-Compatible"" content=""IE=9"" />
	|<meta name=""viewport"" content=""width=device-width, initial-scale=1"" />
	|<link href=""https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/3.0.1/github-markdown.min.css"" rel=""stylesheet"">
	|<style>.markdown-body{box-sizing:border-box;min-width:200px;max-width:980px;margin:0 auto;padding:45px;}@media(max-width:767px){.markdown-body{padding:15px;}}</style>
	|</head>
	|<body>
	|<article class=""markdown-body"">
	|<div id=""targetDiv""></div>
	|<script src=""https://cdn.rawgit.com/showdownjs/showdown/1.9.1/dist/showdown.min.js""></script>
	|<script>
	|	var text='%1',
	|		target=document.getElementById('targetDiv'),
	|		converter=new showdown.Converter({strikethrough: 'true', tables: 'true', tasklists: 'true'}),
	|		blockHtml=converter.makeHtml(text);
	|
	|	target.innerHTML=blockHtml;
	|</script>
	|</article>
	|</body>
	|</html>";	
	
	Text = StrReplace(Text, Chars.LF, "\r\n");
	Text = StrReplace(Text, "'", "\'");
	Text = StrReplace(Text, """", "\""");
	//Text = StrReplace(Text, "\", "\\");
	//Text = СтрЗаменить(Text, "<", "\<");
	//Text = СтрЗаменить(Text, ">", "\>");
	//Text = СтрЗаменить(Text, "`", "\`");
	//Text = СтрЗаменить(Text, "_", "\_");
	
	Return StrTemplate(Template, Text);
	
EndFunction

#EndRegion