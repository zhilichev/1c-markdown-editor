&AtClient
Var CursorPos;

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	// Вызов конструктора редактора
	MarkdownEditor.Constructor(ThisObject, Items.DefaultGroup);
	
	// Установка в поле примера текста Markdown
	ThisObject.MarkdownEditorAttribute_Text = DataProcessors.EditorTest.GetTemplate("SampleMarkdownText").GetText();
	
EndProcedure

&AtClient
Procedure NotificationProcessing(EventName, Parameter, Source)
	
	If EventName = "MarkdownEditorEvent_RestoreCursorPosition" AND Source = UUID Then
		CursorPos = Parameter;
		AttachIdleHandler("Attachable_MarkdownEditorRestoreCursorPosition", 0.01, True);
	EndIf;
	
EndProcedure

#Region AttachableHandlersOfMarkdownEditor

&AtClient
Procedure Attachable_MarkdownEditonOnHTMLFieldClick(EventData, StandardProcessing)
	
	// Обработчик кликов в поле HTML-документа
	
EndProcedure

&AtClient
Procedure Attachable_MarkdownEditorOnEditTextChange(Item, Text, StandardProcessing)
	
	MarkdownEditorClient.OnEditTextChange(ThisObject, Text, StandardProcessing);
	
EndProcedure

&AtClient
Procedure Attachable_MarkdownEditorExecCommand(Command)
	
	MarkdownEditorClient.ExecCommand(ThisObject, Command);
	
EndProcedure

&AtClient
Procedure Attachable_MarkdownEditorRestoreCursorPosition()
	
	CurrentItem = Items.MarkdownEditorItem_EditorField;
		
	// Восстановление положения курсора
	Items.MarkdownEditorItem_EditorField.SetTextSelectionBounds(
		CursorPos.BeginningOfRow, CursorPos.BeginningOfColumn,
		CursorPos.BeginningOfRow, CursorPos.BeginningOfColumn);	
	
EndProcedure

#EndRegion