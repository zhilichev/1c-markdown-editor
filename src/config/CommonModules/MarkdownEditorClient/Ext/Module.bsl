
#Region Interface

Procedure SwitchMode(Form) Export
	
	// Переключение редактора в другой режим
	EditMode = NOT Form["MarkdownEditor_EditMode"];
	Form["MarkdownEditor_EditMode"] = EditMode;
	
	Items = Form.Items;
	Items["MarkdownEditor_SwitchModeButton"].Check = NOT EditMode;
	
	If EditMode Then
		Form["MarkdownEditor_HTMLText"] = "";
	Else
		Form["MarkdownEditor_HTMLText"] = MarkdownEditorServerCall.MarkdownToHTML(
			Form["MarkdownEditor_SimpleText"]);
	EndIf;
	
	// Управление видимостью редактора и просмотрщика
	Items.MarkdownEditor_EditorField.Visible = EditMode;
	Items.MarkdownEditor_HTMLViewerField.Visible = NOT EditMode;	
	
EndProcedure

#EndRegion