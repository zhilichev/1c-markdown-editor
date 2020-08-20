
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

		RefreshHTML = False;
		
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

	// Обработка команды оформления нумерованного списка
	ElsIf CommandName = "MarkdownEditorCommand_InsertNumberedList" Then
		InsertNumberedList(Form);

	// Обработка команды добавления ссылки
	ElsIf CommandName = "MarkdownEditorCommand_InsertLink" Then
	    InsertLink(Form);
		
	// Обработка команды добавления блока кода
	ElsIf CommandName = "MarkdownEditorCommand_InsertCodeBlock" Then
	    InsertCodeBlock(Form);
		
	// Обработка команды вставки ссылки на изображение
	ElsIf CommandName = "MarkdownEditorCommand_InsertImage" Then
		InsertImage(Form);
		RefreshHTML = False;
	EndIf;

	If RefreshHTML Then
		OnEditTextChange(Form, Form.MarkdownEditorAttribute_Text, True);
	EndIf;
	     
EndProcedure

Procedure OnEditTextChange(Form, Text, StandartProcessing) Export
	
	If Form.MarkdownEditorAttribute_EditMode = 2 Then
		Form.MarkdownEditorAttribute_HTML = MarkdownEditorClientServer.MarkdownToHTML(Text);	
	EndIf;
	
EndProcedure

#EndRegion

#Region InternalProceduresAndFunctions

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Процедуры инициации обработки текста

Procedure InsertBulletList(Form)

	// Получение текущего положения курсора в редакторе
	CursorPos = GetCursorPos(Form.Items.MarkdownEditorItem_EditorField);

	// Разделение многострочной строки на массив строк
	LinesArray = MarkdownEditorClientServer.MultilineTextToArray(Form.MarkdownEditorAttribute_Text);

	// Определение символа поиска и вставки/удаления
	KeyChars = "- ";
	KeyCharsLen = StrLen(KeyChars);

	// Определение номеров начальной и конечной строк
	BeginLine = (CursorPos.BeginningOfRow - 1);
	EndLine = (CursorPos.EndOfRow - 1);

	// Определение режима - вставка или удаление
	InsertMode = (FindCharsInLines(LinesArray, KeyChars, BeginLine, EndLine) = -1);
	
	If InsertMode Then
		InsertCharsAtBeginOfLines(LinesArray, KeyChars, BeginLine, EndLine);
	Else
		DelCharsFromBeginOfLines(LinesArray, KeyChars, BeginLine, EndLine);
	EndIf;
	
	Form.MarkdownEditorAttribute_Text = MarkdownEditorClientServer.ArrayToMultilineText(LinesArray);
	
	// Сдвиг позиций выделения текста за счет того, что добавлены или удалены символы
	If InsertMode Then
		CursorPos.BeginningOfColumn = CursorPos.BeginningOfColumn + KeyCharsLen;
		CursorPos.EndOfColumn = CursorPos.EndOfColumn + KeyCharsLen;
	Else
		If CursorPos.BeginningOfColumn >= KeyCharsLen + 1 Then
			CursorPos.BeginningOfColumn = CursorPos.BeginningOfColumn - KeyCharsLen;
		EndIf;
		
		If CursorPos.EndOfColumn >= KeyCharsLen + 1 Then
			CursorPos.EndOfColumn = CursorPos.EndOfColumn - KeyCharsLen;
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

Procedure InsertNumberedList(Form)

	// Получение текущего положения курсора в редакторе
	CursorPos = GetCursorPos(Form.Items.MarkdownEditorItem_EditorField);

	// Разделение многострочной строки на массив строк
	LinesArray = MarkdownEditorClientServer.MultilineTextToArray(Form.MarkdownEditorAttribute_Text);

	// Определение номеров начальной и конечной строк
	BeginLine = (CursorPos.BeginningOfRow - 1);
	EndLine = (CursorPos.EndOfRow - 1);

	For N = BeginLine To EndLine Do
		CheckPattern(LinesArray[N], "^(\s)*");
	EndDo;

EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Процедуры-обработчики оповещений

// Процедура-обработчик оповещения, вызываемаемый после закрытия окна добавления блока кода.
//
// Параметры:
//  CloseResuls - Произвольный - результат закрытия окна.
//  OwnerForm   - Form - форма, с которой связано событие.
//
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

// Процедура-обработчик оповещения, вызываемаемый после закрытия окна добавления ссылки на изображение.
//
// Параметры:
//  CloseResuls - Произвольный - результат закрытия окна.
//  OwnerForm   - Form - форма, с которой связано событие.
//
Procedure OnImageFormClose(CloseResult, OwnerForm) Export
	
	If CloseResult = Undefined Then
		Return;
	EndIf;
	
	EditorItem = OwnerForm.Items.MarkdownEditorItem_EditorField;
	
	// Получение текущего положения курсора в редакторе
	CursorPos = GetCursorPos(EditorItem);
	
	EditorItem.SelectedText = StrTemplate("![%1](%2)", CloseResult.AltText, CloseResult.URL);
	
	// Восстановление положения курсора
	Notify("MarkdownEditorEvent_RestoreCursorPosition", CursorPos, OwnerForm.UUID);	
	
EndProcedure

// Процедура-обработчик оповещения, вызываемаемый после закрытия окна добавления ссылки.
//
// Параметры:
//  CloseResuls - Произвольный - результат закрытия окна.
//  OwnerForm   - Form - форма, с которой связано событие.
//
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции определения и изменения свойств редактора

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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции обработки текста

Function CheckPattern(Val String, Val Pattern)

	TextPattern =
		"<Model xmlns=""http://v8.1c.ru/8.1/xdto"" xmlns:xs=""http://www.w3.org/2001/XMLSchema"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xsi:type=""Model"">
		|<package targetNamespace=""sample-my-package"">
		|<valueType name=""testtypes"" base=""xs:string"">
		|<pattern>" + Pattern + "</pattern>
		|</valueType>
		|<objectType name=""TestObj"">
		|<property xmlns:d4p1=""sample-my-package"" name=""TestItem"" type=""d4p1:testtypes""/>
		|</objectType>
		|</package>
		|</Model>";


	XMLReader = New XMLReader;
	XMLReader.SetString(TextPattern);

    Model = XDTOFactory.ReadXML(XMLReader);
    MyXDTOFactory = New XDTOFactory(Model);
    Package = MyXDTOFactory.Packages.Get("sample-my-package");
    Test = MyXDTOFactory.Create(Package.Get("TestObj"));

    Try
        Test.TestItem = String;
        Return True;
	Except
        Return False;
	EndTry;	

EndFunction

// Удаляет из начала каждой строки многострочного текста символы, указанные в параметре Chars.
//
// Параметры:
//  TextLines - Массив - массив строк многострочного текста.
//  Chars     - Строка - строка символов, которую необходимо удалить.
//  BeginLine - Число - индекс первого обрабатываемого элемента массива TextLines.
//  EndLine   - Число - индекс последнего обрабатываемого элемента массива TextLines.
//
Procedure DelCharsFromBeginOfLines(TextLines, Val Chars, Val BeginLine = 0, Val EndLine = Undefined)

	// Если конечный элемент не определен, то поиск идет по всем элементам массива
	If EndLine = Undefined Then
		EndLine = TextLines.UBound();
	EndIf;

	// Определение длины искомой строки. Значение +1 добавляется потому, что символы в строке нумеруются с единицы
	CharsStrLen = StrLen(Chars) + 1;
	
	For N = BeginLine To EndLine Do
		SearchToStrIn = TextLines[N];

		If StrStartWith(SearchToStrIn, Chars) Then
			TextLines.Set(N, Mid(SearchToStrIn, CharsStrLen));
		EndIf;
	EndDo;

EndProcedure

// Возвращает номер первой строки многострочного текста, в начале которой найдено значение из параметра Chars.
//
// Параметры:
//  TextLines - Массив - массив строк многострочного текста.
//  Chars     - Строка - строка символов, которую необходимо найти.
//  BeginLine - Число  - индекс первого обрабатываемого элемента массива TextLines.
//  EndLine   - Число  - индекс последнего обрабатываемого элемента массива TextLines.
//
// Возвращаемое значение:
//  Число. Индекс элемента массива. Если значение не найдено, возвращается -1.
//
Function FindCharsInLines(Val TextLines, Val Chars, Val BeginLine = 0, Val EndLine = Undefined)

	// Определяется результат, если не получится найти искомое значение
	ItemIndex = -1;

	// Если конечный элемент не определен, поиск идет по всем элементам массива
	If EndLine = Undefined Then
		EndLine = TextLines.UBound();
	EndIf;

	For N = BeginLine To EndLine Do
		SearchToStrIn = TextLines[N];

		// Поиск ведется до первого совпадения начала строки с искомыми символами
		If StrStartWith(SearchToStrIn, Chars) Then
			ItemIndex = N;
			Break;
		EndIf;
	EndDo;

	Return ItemIndex;

EndFunction

// Вставляет в начало каждой строки многострочного текста символы, указанные в параметре Chars.
//
// Параметры:
//  TextLines - Массив - массив строк многострочного текста.
//  Chars     - Строка - строка символов, которую необходимо вставить.
//  BeginLine - Число - индекс первого обрабатываемого элемента массива TextLines.
//  EndLine   - Число - индекс последнего обрабатываемого элемента массива TextLines.
//
Procedure InsertCharsAtBeginOfLines(TextLines, Val Chars, Val BeginLine = 0, Val EndLine = Undefined)

	// Если конечный элемент не определен, то поиск идет по всем элементам массива
	If EndLine = Undefined Then
		EndLine = TextLines.UBound();
	EndIf;
	
	For N = BeginLine To EndLine Do
		SearchToStrIn = TextLines[N];

		If NOT StrStartWith(SearchToStrIn, Chars) Then
			TextLines.Set(N, Chars + SearchToStrIn);
		EndIf;
	EndDo;	

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

#EndRegion