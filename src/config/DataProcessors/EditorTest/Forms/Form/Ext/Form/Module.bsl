
#Region Variables

// Для хранения позиции курсора до выполнения операции с текстом
&AtClient
Var CursorPos;

#EndRegion

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	// Вызов конструктора редактора
	MarkdownEditor.Constructor(ThisObject, Items.DefaultGroup);
	
EndProcedure

&AtClient
Procedure NotificationProcessing(EventName, Parameter, Source)
	
	// Проверка на событие RestoreCursorPosition - восстановление положения курсора в поле
	// редактирования текста и инициация обработчика ожидания.
	If Source = UUID AND EventName = "MarkdownEditorEvent_RestoreCursorPosition" Then
		CursorPos = Parameter;
		AttachIdleHandler("Attachable_MarkdownEditorRestoreCursorPosition", 0.01, True);
	EndIf;
	
EndProcedure

#EndRegion

#Region AttachableHandlersOfMarkdownEditor

// Подключаемая процедура-обработчик события EditTextChange (ИзменениеТекстаРедактирования)
// поля редактора.
//
// Parameters:
//  Item               - FormField - поле редактора Markdown.
//  Text               - String - contains a text to be edited.
//  StandardProcessing - Boolean - the sign of a standard (system) processing of the event
//                       is transferred to this parameter
//
&AtClient
Procedure Attachable_MarkdownEditorOnEditTextChange(Item, Text, StandardProcessing)
	
	MarkdownEditorClient.OnEditTextChange(ThisObject, Text, StandardProcessing);
	
EndProcedure

// Процедура-обработчик программно сгенерированных команд редактора.
//
&AtClient
Procedure Attachable_MarkdownEditorExecCommand(Command)
	
	MarkdownEditorClient.ExecCommand(ThisObject, Command);
	
EndProcedure

// Процедура-обработчик ожидания для восстановления позиции курсора после выполнения команды.
//
&AtClient
Procedure Attachable_MarkdownEditorRestoreCursorPosition()
	
	CurrentItem = Items.MarkdownEditorItem_EditorField;
		
	// Восстановление положения курсора
	If CursorPos.FullSelection Then
		Items.MarkdownEditorItem_EditorField.SetTextSelectionBounds(
			CursorPos.BeginningOfRow, CursorPos.BeginningOfColumn,
			CursorPos.EndOfRow, CursorPos.EndOfColumn);		
	Else
		Items.MarkdownEditorItem_EditorField.SetTextSelectionBounds(
			CursorPos.BeginningOfRow, CursorPos.BeginningOfColumn,
			CursorPos.BeginningOfRow, CursorPos.BeginningOfColumn);
	EndIf;
	
EndProcedure

#EndRegion