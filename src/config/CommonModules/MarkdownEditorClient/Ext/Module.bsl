
#Region Interface

Procedure ExecCommand(Form, Command) Export
	
	CommandName = Command.Name;
	
	// Обработка команды переключения режимов редактора
	If CommandName = "MarkdownEditorCommand_EditorMode" 
		OR CommandName = "MarkdownEditorCommand_ViewMode"
		OR CommandName = "MarkdownEditorCommand_PreviewMode" Then

		SwitchMode(Form, CommandName);
		
	// Обработка команды оформления жирным шрифтов
	ElsIf CommandName = "MarkdownEditorCommand_SetBoldFont" Then
		SetFontStyle(Form, "**", NStr("en = '**bold font**'"));
		
	// Обработка команды оформления курсивным шрифтов
	ElsIf CommandName = "MarkdownEditorCommand_SetItalicFont" Then
		SetFontStyle(Form, "*", NStr("en = '*italic font*'"));
		
	// Обработка команды оформления зачеркнутым шрифтов
	ElsIf CommandName = "MarkdownEditorCommand_SetStrikethroughFont" Then
		SetFontStyle(Form, "~~", NStr("en = '~~strikethrough font~~'"));
		
	// Обработка команды добавления ссылки
	ElsIf CommandName = "MarkdownEditorCommand_InsertLink" Then
	    InsertLink(Form);
		
	// Обработка команды добавления блока кода
	ElsIf CommandName = "MarkdownEditorCommand_InsertCodeBlock" Then
	    InsertCodeBlock(Form);
		
	// Обработка команды вставки ссылки на изображение
	ElsIf CommandName = "MarkdownEditorCommand_InsertImage" Then
		InsertImage(Form);
		
	EndIf;
	     
EndProcedure

Procedure OnEditTextChange(Form, Text, StandartProcessing) Export
	
	If Form.MarkdownEditorAttribute_EditMode = 2 Then
		Form.MarkdownEditorAttribute_HTML = MarkdownEditorClientServer.MarkdownToHTML(Text);	
	EndIf;
	
EndProcedure

#EndRegion

#Region InternalProceduresAndFunctions

// Return description position of editor's cursor.
//
// Parameters:
//  EditorItem - FormField - editor's field.
//
// Returned value:
//  Structure of cursor position.
//
Function GetCursorPos(EditorItem)
	
	CursorPos = New Structure;
	CursorPos.Insert("BeginningOfRow", 0);
	CursorPos.Insert("BeginningOfColumn", 0);
	CursorPos.Insert("EndOfRow", 0);
	CursorPos.Insert("EndOfColumn", 0);
	
	EditorItem.GetTextSelectionBounds(CursorPos.BeginningOfRow, CursorPos.BeginningOfColumn,
		CursorPos.EndOfRow, CursorPos.EndOfColumn);
		
	Return CursorPos;
	
EndFunction

Procedure InsertCodeBlock(Form)
	
	NotifyDescription = New NotifyDescription("OnCodeBlockFormClose", MarkdownEditorClient, Form);
	OpenForm("CommonForm.CodeBlock", , Form, , , , NotifyDescription, FormWindowOpeningMode.LockOwnerWindow);	
	
EndProcedure

Procedure InsertImage(Form)
	
	NotifyDescription = New NotifyDescription("OnImageFormClose", MarkdownEditorClient, Form);
	OpenForm("CommonForm.InsertImage", , Form, , , , NotifyDescription, FormWindowOpeningMode.LockOwnerWindow);
	
EndProcedure

Procedure InsertLink(Form)
	
	NotifyDescription = New NotifyDescription("OnLinkFormClose", MarkdownEditorClient, Form);
	OpenForm("CommonForm.InsertLink", , Form, , , , NotifyDescription, FormWindowOpeningMode.LockOwnerWindow);
	
EndProcedure

Procedure OnCodeBlockFormClose(CloseResult, OwnerForm) Export
	
	If CloseResult = Undefined Then
		Return;
	EndIf;
	
	EditorItem = OwnerForm.Items.MarkdownEditorItem_EditorField;
	
	// Получение текущего положения курсора в редакторе
	CursorPos = GetCursorPos(EditorItem);
	
	EditorItem.SelectedText = StrTemplate("```%1%2%3```", Chars.CR, CloseResult, Chars.CR);
	
	// Восстановление положения курсора
	Notify("MarkdownEditorEvent_RestoreCursorPosition", CursorPos, OwnerForm.UUID);	
	
EndProcedure

Procedure OnImageFormClose(CloseResult, OwnerForm) Export
	
EndProcedure

Procedure OnLinkFormClose(CloseResult, OwnerForm) Export
	
	If CloseResult = Undefined OR IsBlankString(CloseResult.Address) Then
		Return;
	EndIf;
	
	EditorItem = OwnerForm.Items.MarkdownEditorItem_EditorField;
	
	// Получение текущего положения курсора в редакторе
	CursorPos = GetCursorPos(EditorItem);
	
	If IsBlankString(CloseResult.LinkText) Then
		LinkText = CloseResult.Address;
	Else
		LinkText = CloseResult.LinkText;
	EndIf;
	
	EditorItem.SelectedText = StrTemplate("[%1](%2%3)", LinkText, CloseResult.Address);
	
	// Восстановление положения курсора
	Notify("MarkdownEditorEvent_RestoreCursorPosition", CursorPos, OwnerForm.UUID);	
	
EndProcedure

Procedure SetFontStyle(Form, Marker, BlankString)
	
	EditorItem = Form.Items.MarkdownEditorItem_EditorField;
	
	// Необходимо запомнить позицию курсора
	CursorPos = GetCursorPos(EditorItem);
		
	SelectedText = EditorItem.SelectedText;
	
	If IsBlankString(EditorItem.SelectedText) Then
		SelectedText = BlankString;
		
	ElsIf StrStartWith(SelectedText, Marker) AND StrEndsWith(SelectedText, Marker) Then
		TextLen = StrLen(SelectedText);
		SelectedText = Mid(SelectedText, 3, TextLen - 4);
		
	Else
		SelectedText = Marker + EditorItem.SelectedText + Marker;
	EndIf;
	
	EditorItem.SelectedText = SelectedText;
	
	// Восстановление положения курсора
	Notify("MarkdownEditorEvent_RestoreCursorPosition", CursorPos, Form.UUID);	
	
EndProcedure

Procedure SwitchMode(Form, CommandName)

	// Переключение режима редактора в соответствии с командой
	If CommandName = "MarkdownEditorCommand_EditorMode" Then
		Form.MarkdownEditorAttribute_EditMode = 0;
	ElsIf CommandName = "MarkdownEditorCommand_ViewMode" Then
		Form.MarkdownEditorAttribute_EditMode = 1;
	Else
		Form.MarkdownEditorAttribute_EditMode = 2;
	EndIf;
		
	Items = Form.Items;
	Items.MarkdownEditorItem_EditorModeButton.Check = (Form.MarkdownEditorAttribute_EditMode = 0);
	Items.MarkdownEditorItem_ViewModeButton.Check = (Form.MarkdownEditorAttribute_EditMode = 1);
	Items.MarkdownEditorItem_PreviewModeButton.Check = (Form.MarkdownEditorAttribute_EditMode = 2);
	
	If Form.MarkdownEditorAttribute_EditMode = 0 Then
		Form.MarkdownEditorAttribute_HTML = "";
	Else
		Form.MarkdownEditorAttribute_HTML = MarkdownEditorClientServer.MarkdownToHTML(
			Form.MarkdownEditorAttribute_Text);
	EndIf;
	
	// Управление видимостью редактора и просмотрщика
	Items.MarkdownEditorItem_EditorField.Visible = (Form.MarkdownEditorAttribute_EditMode = 0 OR Form.MarkdownEditorAttribute_EditMode = 2);
	Items.MarkdownEditorItem_HTMLViewerField.Visible = (Form.MarkdownEditorAttribute_EditMode = 1 OR Form.MarkdownEditorAttribute_EditMode = 2);	
	
EndProcedure

#EndRegion