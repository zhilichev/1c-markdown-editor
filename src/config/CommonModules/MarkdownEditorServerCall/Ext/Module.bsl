
#Region Interface

Function MarkdownToHTML(Val Text) Export
	
	Template = MarkdownEditorServerCached.GetHTMLTemplate();
	
	Text = StrReplace(Text, Chars.LF, "\r\n");
	Text = StrReplace(Text, "'", "\'");
	
	Return StrTemplate(Template, Text);
	
EndFunction

#EndRegion