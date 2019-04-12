
#Region Interface

Procedure SwitchMode(Form) Export
	
	// Переключение редактора в другой режим
	EditMode = NOT Form["РежимРедактора_Markdown"];
	Form["РежимРедактора_Markdown"] = EditMode;
	
	Items = Form.Items;
	Items["КнопкаПереключенияРежимаРедактора_Markdown"].Check = NOT EditMode;
	
	If EditMode Then
		Form["СодержимоеHTML_Markdown"] = "";
	Else
		Form["СодержимоеHTML_Markdown"] = РедакторMarkdownВызовСервера.MarkdownToHTML(
			Form["ТекстовоеСодержимое_Markdown"]);
	EndIf;
	
	// Управление видимостью редактора и просмотрщика
	Items.ТекстовыйРедактор_Markdown.Visible = EditMode;
	Items.ПросмотрРезультата_Markdown.Visible = NOT EditMode;	
	
EndProcedure

#EndRegion