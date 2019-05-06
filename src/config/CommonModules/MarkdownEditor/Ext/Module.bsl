
#Region Interface

Procedure Constructor(Form, OwnerGroup) Export
	
	InitFormData(Form, OwnerGroup);
	
EndProcedure

#EndRegion

#Region InternalProceduresAndFunctions

Procedure InitFormData(Form, OwnerGroup)
	
	// Создаваемые команды формы
	Var NewCommands;
	
	// Создание дополнительных реквизитов формы
	CreateFormAttributes(Form);
	
	// Создание дополнительных команд формы
	CreateFormCommands(Form, NewCommands);
	
	// Создание элементов формы редактора
	CreateFormItems(Form, OwnerGroup, NewCommands);
	
EndProcedure

Procedure CreateFormAttributes(Form)
	
	// Программное создание необходимых реквизитов на форме
	
	// Реквизит MarkdownEditorAttribute_EditMode хранит состояние редактора:
	// - True - включен редактор;
	// - False - включен режим просмотра.
	EditorMode = New FormAttribute("MarkdownEditorAttribute_EditMode",
		New TypeDescription("Boolean"));
		
	// Реквизит MarkdownEditorAttribute_Text хранит исходный текст
	MarkdownText = New FormAttribute("MarkdownEditorAttribute_Text", 
		New TypeDescription("String"), , , True);
		
	// Реквизит MarkdownEditorAttribute_HTML хранит преобразованный HTML-код
	HTMLText = New FormAttribute("MarkdownEditorAttribute_HTML", New TypeDescription("String"));
		
	NewAttributes = New Array;
	NewAttributes.Add(EditorMode);
	NewAttributes.Add(MarkdownText);
	NewAttributes.Add(HTMLText);
	
	Form.ChangeAttributes(NewAttributes);
	
	// Установка значений новых реквизитов формы
	Form.MarkdownEditorAttribute_EditMode = True;	
	
EndProcedure

Procedure CreateFormCommands(Form, NewCommands)
	
	// Программное создание команд
	NewCommands = New Structure;
	
	// Команда переключения режима редактора
	Command = Form.Commands.Add("MarkdownEditorCommand_SwitchMode");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.ViewMode;
	Command.Representation = ButtonRepresentation.Picture;
	Command.ToolTip        = NStr("en = 'Preview mode'");
	Command.Shortcut       = New Shortcut(Key.V, True, False, True);
	
	NewCommands.Insert("SwitchMode", Command.Name);
	
	// Команда полужирного начертания шрифта
	Command = Form.Commands.Add("MarkdownEditorCommand_SetBoldFont");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.Bold;
	Command.Representation = ButtonRepresentation.Picture;
	Command.ToolTip        = NStr("en = 'Bold'");
	Command.Shortcut       = New Shortcut(Key.B, True, False, True);
	
	NewCommands.Insert("SetBoldFont", Command.Name);
	
	// Команда курсивного начертания шрифта
	Command = Form.Commands.Add("MarkdownEditorCommand_SetItalicFont");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.Italic;
	Command.Representation = ButtonRepresentation.Picture;
	Command.ToolTip        = NStr("en = 'Italic'");
	Command.Shortcut       = New Shortcut(Key.I, True, False, True);
	
	NewCommands.Insert("SetItalicFont", Command.Name);
	
	// Команда зачеркнутого начертания шрифта
	Command = Form.Commands.Add("MarkdownEditorCommand_SetStrikethroughFont");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.Strikethrough;
	Command.Representation = ButtonRepresentation.Picture;
	Command.ToolTip        = NStr("en = 'Strikethrough'");
	Command.Shortcut       = New Shortcut(Key.S, True, False, True);
	
	NewCommands.Insert("SetStrikethroughFont", Command.Name);
	
	// Команда добавления ненумерованного списка
	Command = Form.Commands.Add("MarkdownEditorCommand_InsertBulletList");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.BulletList;
	Command.Representation = ButtonRepresentation.Picture;
	Command.ToolTip        = NStr("en = 'Bullet list'");
	
	NewCommands.Insert("InsertBulletList", Command.Name);
	
	// Команда добавления нумерованного списка
	Command = Form.Commands.Add("MarkdownEditorCommand_InsertNumberedList");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.NumberedList;
	Command.Representation = ButtonRepresentation.Picture;
	Command.ToolTip        = NStr("en = 'Numbered list'");
	
	NewCommands.Insert("InsertNumberedList", Command.Name);
	
	// Команда добавления ссылки
	Command = Form.Commands.Add("MarkdownEditorCommand_InsertLink");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.Link;
	Command.Representation = ButtonRepresentation.Picture;
	Command.ToolTip        = NStr("en = 'Insert link'");
	
	NewCommands.Insert("InsertLink", Command.Name);
	
	// Команда добавления блока кода
	Command = Form.Commands.Add("MarkdownEditorCommand_InsertCodeBlock");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.CodeBlock;
	Command.Representation = ButtonRepresentation.Picture;
	Command.ToolTip        = NStr("en = 'Insert code block'");
	
	NewCommands.Insert("InsertCodeBlock", Command.Name);	
	
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции создания элементов формы редактора

Procedure CreateFormItems(Form, OwnerGroup, Commands)
	
	Items = Form.Items;
	
	// Создание общей группы, на которой будут размещены все элементы редактора
	MainGroup = Items.Add("MarkdownEditorItem_MainGroup", Type("FormGroup"), OwnerGroup);
	MainGroup.Type      = FormGroupType.UsualGroup;
	MainGroup.Group     = ChildFormItemsGroup.Vertical;
	MainGroup.ShowTitle = False;
	
#Region ОсновнаяКоманднаяПанель
	
	// Главная командная панель управления редактором
	MainCommandBar = Items.Add("MarkdownEditorItem_MainCommandBar", 
		Type("FormGroup"), MainGroup);
		
	MainCommandBar.Type = FormGroupType.CommandBar;
	MainCommandBar.HorizontalStretch = True;
	
#EndRegion

#Region ГруппаКнопокРежимаРедактора

	// Группа кнопок отображения кнопки переключения режимов "редактор" / "просмотр"
	ModeButtonsGroup = Items.Add("MarkdownEditorItem_ModeButtonsGroup", Type("FormGroup"),
		MainCommandBar);
		
	ModeButtonsGroup.Type = FormGroupType.ButtonGroup;
	
	// Кнопка переключения режима редактора
	SwitchModeButton = Items.Add("MarkdownEditorItem_SwitchModeButton", Type("FormButton"),
		ModeButtonsGroup);
		
	SwitchModeButton.CommandName = Commands.SwitchMode;

#EndRegion

#Region ГруппаКнопокОформленияШрифта
	
	// Группа кнопок изменения начертания текста
	FontStyleButtonsGroup = Items.Add("MarkdownEditorItem_FontStyleButtonsGroup", Type("FormGroup"),
		MainCommandBar);
		
	FontStyleButtonsGroup.Type = FormGroupType.ButtonGroup;
	FontStyleButtonsGroup.Representation = ButtonGroupRepresentation.Compact;
	
	// Кнопка полужирного начертания текста
	BoldFontButton = Items.Add("MarkdownEditorItem_BoldFontButton", Type("FormButton"),
		FontStyleButtonsGroup);
		
	BoldFontButton.CommandName = Commands.SetBoldFont;
	
	// Кнопка курсивного начертания текста
	ItalicFontButton = Items.Add("MarkdownEditorItem_ItalicFontButton", Type("FormButton"),
		FontStyleButtonsGroup);
		
	ItalicFontButton.CommandName = Commands.SetItalicFont;
	
	// Кнопка зачеркнутого начертания текста
	StrikethroughFontButton = Items.Add("MarkdownEditorItem_StrikethroughFontButton", Type("FormButton"),
		FontStyleButtonsGroup);
		
	StrikethroughFontButton.CommandName = Commands.SetStrikethroughFont;	
	
#EndRegion

#Region ГруппаКнопокСпиской

	// Группа кнопок создания списков
	ListsButtonsGroup = Items.Add("MarkdownEditorItem_ListsButtonsGroup", Type("FormGroup"),
		MainCommandBar);
		
	ListsButtonsGroup.Type = FormGroupType.ButtonGroup;
	ListsButtonsGroup.Representation = ButtonGroupRepresentation.Compact;
	
	// Кнопка ненумерованного списка
	BulletListButton = Items.Add("MarkdownEditorItem_BulletListButton", Type("FormButton"),
		ListsButtonsGroup);
		
	BulletListButton.CommandName = Commands.InsertBulletList;
	
	// Кнопка нумерованного списка
	NumberedListButton = Items.Add("MarkdownEditorItem_NumberedListButton", Type("FormButton"),
		ListsButtonsGroup);
		
	NumberedListButton.CommandName = Commands.InsertNumberedList;	

#EndRegion

#Region ГруппаКнопокВставки

	// Группа кнопок вставки различные объектов
	InsertButtonsGroup = Items.Add("MarkdownEditorItem_InsertButtonsGroup", Type("FormGroup"),
		MainCommandBar);
		
	InsertButtonsGroup.Type = FormGroupType.ButtonGroup;
	InsertButtonsGroup.Representation = ButtonGroupRepresentation.Compact;		
		
	InsertLinkButton = Items.Add("MarkdownEditorItem_InsertLinkButton", Type("FormButton"),
		InsertButtonsGroup);
		
	InsertLinkButton.CommandName = Commands.InsertLink;
	
	InsertCodeBlockButton = Items.Add("MarkdownEditorItem_InsertCodeBlockButton", Type("FormButton"),
		InsertButtonsGroup);
		
	InsertCodeBlockButton.CommandName = Commands.InsertCodeBlock;	

#EndRegion

#Region РедакторТекста

	// Создание текстового поля для редактирования простого текста
	EditorTextField = Items.Add("MarkdownEditorItem_EditorField", Type("FormField"),
		MainGroup);
		
	EditorTextField.DataPath = "MarkdownEditorAttribute_Text";
	EditorTextField.Type = FormFieldType.InputField;
	
	EditorTextField.AutoMaxWidth = False;
	EditorTextField.AutoMaxHeight = False;	
	EditorTextField.MultiLine = True;
	EditorTextField.TitleLocation = FormItemTitleLocation.None;
	EditorTextField.ExtendedEdit = True;
	EditorTextField.HorizontalStretch = True;
	EditorTextField.VerticalStretch = True;	

#EndRegion

#Region MarkdownViewer

	// Создание поля HTML-документа для просмотра результата
	HTMLViewerField = Items.Add("MarkdownEditorItem_HTMLViewerField", Type("FormField"), 
		MainGroup);
	
	HTMLViewerField.DataPath = "MarkdownEditorAttribute_HTML";
	HTMLViewerField.Type = FormFieldType.HTMLDocumentField;
	HTMLViewerField.TitleLocation = FormItemTitleLocation.None;
	
	HTMLViewerField.AutoMaxWidth = False;
	HTMLViewerField.AutoMaxHeight = False;	
	HTMLViewerField.HorizontalStretch = True;
	HTMLViewerField.VerticalStretch = True;	
	
	// TODO: Написать обработчик нажатия
	//HTMLViewerField.SetAction("OnClick", "Attachable_MarkdownEditonOnHTMLFieldClick");

#EndRegion
	
EndProcedure

#EndRegion