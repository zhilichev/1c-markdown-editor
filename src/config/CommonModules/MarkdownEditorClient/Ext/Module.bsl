﻿
#Region Interface

Procedure ExecCommand(Form, Command) Export
	
	// Признак необходимости обновления HTML-превью
	Var RefreshHTML;

	// Обновление поля HTML включено по умолчанию. В тех обработчиках, где нужно отключить,
	// прописать RefreshHTML = False.
	RefreshHTML = True;

	CommandName = Command.Name;
	
	// Обработка команды переключения режимов редактора
	If CommandName = "MarkdownEditorCommand_EditorMode" 
		OR CommandName = "MarkdownEditorCommand_ViewMode"
		OR CommandName = "MarkdownEditorCommand_PreviewMode" Then

		SwitchMode(Form, CommandName);

		RefreshHTML = False
		
	// Обработка команды оформления жирным шрифтов
	ElsIf CommandName = "MarkdownEditorCommand_SetBoldFont" Then
		SetFontStyle(Form, "**", NStr("en = '**bold font**'"));
		
	// Обработка команды оформления курсивным шрифтов
	ElsIf CommandName = "MarkdownEditorCommand_SetItalicFont" Then
		SetFontStyle(Form, "*", NStr("en = '*italic font*'"));
		
	// Обработка команды оформления зачеркнутым шрифтов
	ElsIf CommandName = "MarkdownEditorCommand_SetStrikethroughFont" Then
		SetFontStyle(Form, "~~", NStr("en = '~~strikethrough font~~'"));
		
	// Обработка команды оформления ненумерованного списка
	ElsIf CommandName = "MarkdownEditorCommand_InsertBulletList" Then
		InsertBulletList(Form);

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

	OnEditTextChange(Form, Form.MarkdownEditorAttribute_Text, True);
	     
EndProcedure

Procedure OnEditTextChange(Form, Text, StandartProcessing) Export
	
	If Form.MarkdownEditorAttribute_EditMode = 2 Then
		Form.MarkdownEditorAttribute_HTML = MarkdownEditorClientServer.MarkdownToHTML(Text);	
	EndIf;
	
EndProcedure

#EndRegion

#Region InternalProceduresAndFunctions

Function IsInsertBulletListMode(Val Text, Val BeginLine, Val EndLine, Val LineCount = Undefined)
	
	InsertMode = False;
	
	If LineCount = Undefined Then
		LineCount = StrLineCount(Text);
	EndIf;
	
	For N = BeginLine To EndLine Do
		LineText = StrGetLine(Text, N);
		
		If NOT StrStartWith(LineText, "- ") Then
			InsertMode = True;
			Break;
		EndIf;
	EndDo;
	
	Return InsertMode;
	
EndFunction

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
	CursorPos.Insert("FullSelection", False);
	
	EditorItem.GetTextSelectionBounds(CursorPos.BeginningOfRow, CursorPos.BeginningOfColumn,
		CursorPos.EndOfRow, CursorPos.EndOfColumn);
		
	Return CursorPos;
	
EndFunction

Procedure InsertBulletList(Form)

	EditorItem = Form.Items.MarkdownEditorItem_EditorField;

	// Получение текущего положения курсора в редакторе
	CursorPos = GetCursorPos(EditorItem);
	
	SourceText = Form.MarkdownEditorAttribute_Text;
	LineCount = StrLineCount(SourceText);
	
	// TODO: Работу со строками можно переделать с метода StrGetLine на массив строк
	InsertMode = IsInsertBulletListMode(SourceText, CursorPos.BeginningOfRow, CursorPos.EndOfRow, LineCount);   
	
	SelectedLines = New Array;
	For N = 1 To LineCount Do
		LineText = StrGetLine(SourceText, N);
		
		If (N >= CursorPos.BeginningOfRow) AND (N <= CursorPos.EndOfRow) Then
			If InsertMode Then
				If NOT StrStartWith(LineText, "- ") Then
					LineText = "- " + LineText;
				EndIf;
			Else
				LineText = Mid(LineText, 3);
			EndIf;
		EndIf;
		SelectedLines.Add(LineText);
	EndDo;
	
	Form.MarkdownEditorAttribute_Text = StrConcat(SelectedLines, Chars.CR);
	
	// Сдвиг позиций выделения текста за счет того, что добавлены или удалены символы
	If InsertMode Then
		CursorPos.BeginningOfColumn = CursorPos.BeginningOfColumn + 2;
		CursorPos.EndOfColumn = CursorPos.EndOfColumn + 2;
	Else
		If CursorPos.BeginningOfColumn > 3 Then
			CursorPos.BeginningOfColumn = CursorPos.BeginningOfColumn - 2;
		EndIf;
		
		If CursorPos.EndOfColumn > 3 Then
			CursorPos.EndOfColumn = CursorPos.EndOfColumn - 2;
		EndIf;
	EndIf;
	
	CursorPos.FullSelection = True;
	
	Notify("MarkdownEditorEvent_RestoreCursorPosition", CursorPos, Form.UUID);

EndProcedure

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
	
	If Form.MarkdownEditorAttribute_EditMode = 0 Then
		Form.MarkdownEditorAttribute_HTML = "";
	Else
		Form.MarkdownEditorAttribute_HTML = MarkdownEditorClientServer.MarkdownToHTML(
			Form.MarkdownEditorAttribute_Text);
	EndIf;	
		
	Items = Form.Items;
	Items.MarkdownEditorItem_EditorModeButton.Check = (Form.MarkdownEditorAttribute_EditMode = 0);
	Items.MarkdownEditorItem_ViewModeButton.Check = (Form.MarkdownEditorAttribute_EditMode = 1);
	Items.MarkdownEditorItem_PreviewModeButton.Check = (Form.MarkdownEditorAttribute_EditMode = 2);
	
	// Расчет доступности редактора и панелей редактирования
	EditorEnabled = (Form.MarkdownEditorAttribute_EditMode = 0 OR Form.MarkdownEditorAttribute_EditMode = 2);
	
	// Управление видимостью редактора и просмотрщика
	Items.MarkdownEditorItem_EditorField.Visible = EditorEnabled;
	Items.MarkdownEditorItem_HTMLViewerField.Visible = (Form.MarkdownEditorAttribute_EditMode = 1 OR Form.MarkdownEditorAttribute_EditMode = 2);	
	
	// Управление доступностью команд панели редактирования
	Items.MarkdownEditorItem_FontStyleButtonsGroup.Enabled = EditorEnabled;
	Items.MarkdownEditorItem_ListsButtonsGroup.Enabled = EditorEnabled;
	Items.MarkdownEditorItem_InsertButtonsGroup.Enabled = EditorEnabled;
	
EndProcedure

#EndRegion