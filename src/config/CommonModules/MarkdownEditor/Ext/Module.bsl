
#Region Interface

// Процедура-конструктор редактора. Точка входа в процесс программного создания
// редактора.
//
// Параметры:
//  Form  - ManagedForm - форма, на которой будет размещен редактор.
//  Group - FormGroup - группа-владелец, внутри которой будут созданы 
//          элементы формы.
//
Procedure Constructor(Form, Group) Export
	
	InitFormData(Form, Group);
	
EndProcedure

#EndRegion

#Region InternalProceduresAndFunctions

// Запускает методы создания реквизитов, команд и элементов формы для редактора.
//
// Параметры:
//  Form  - ManagedForm - форма, на которой будет размещен редактор.
//  Group - FormGroup - группа-владелец, внутри которой будут созданы 
//          элементы формы.
//
Procedure InitFormData(Form, Group)
	
	// Список программно-создаваемых команд  формы
	Var CommandList;
	
	// Создание дополнительных реквизитов формы
	CreateFormAttributes(Form);
	
	// Создание дополнительных команд формы
	CreateFormCommands(Form, CommandList);
	
	// Создание элементов формы редактора
	CreateFormItems(Form, Group, CommandList);

	// Установка свойств по умолчанию
	SetDefaultParameters(Form);
	
EndProcedure

// Создает реквизиты формы, которые необходимы для работы редактора.
//
// Параметры:
//  Form  - ManagedForm - форма, для которой будут созданы реквизиты.
//
Procedure CreateFormAttributes(Form)
	
	// Программное создание необходимых реквизитов на форме
	
	// Реквизит MarkdownEditorAttribute_EditMode хранит состояние редактора:
	// - 0 - включен режим редактора;
	// - 1 - включен режим просмотра;
	// - 2 - включен режим предпросмотра при редактировании.
	EditorMode = New FormAttribute("MarkdownEditorAttribute_EditMode",
		New TypeDescription("Number", New NumberQualifiers(1, 0, AllowedSign.Nonnegative)));
		
	// Реквизит MarkdownEditorAttribute_Text хранит исходный plane-текст
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

// Создает команды для управления редактором.
//
// Parameters:
//  Form        - ManagedForm - форма, для которой будут созданы команды.
//  NewCommands - Structure - структура, в которую будут помещены свойства новых команд.
//
Procedure CreateFormCommands(Form, NewCommands)
	
	// Программное создание команд
	NewCommands = New Structure;

	// Команда переключения в режим "Редактор"
	Command = Form.Commands.Add("MarkdownEditorCommand_EditorMode");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.MarkdownEditorMode;
	Command.ToolTip        = NStr("en = 'Switch to editor mode'");
	Command.Representation = ButtonRepresentation.Picture;
	Command.Shortcut       = New Shortcut(Key.E, True, False, True);
	
	NewCommands.Insert("SwitchToEditorMode", Command.Name);

	// Команда переключения в режим "Просмотр"
	Command = Form.Commands.Add("MarkdownEditorCommand_ViewMode");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.MarkdownViewMode;
	Command.ToolTip        = NStr("en = 'Switch to view mode'");
	Command.Representation = ButtonRepresentation.Picture;
	Command.Shortcut       = New Shortcut(Key.V, True, False, True);
	
	NewCommands.Insert("SwitchToViewMode", Command.Name);	

	// Команда переключения в режим "Редактор"
	Command = Form.Commands.Add("MarkdownEditorCommand_PreviewMode");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.MarkdownPreviewMode;
	Command.ToolTip        = NStr("en = 'Switch to live preview mode'");
	Command.Representation = ButtonRepresentation.Picture;
	Command.Shortcut       = New Shortcut(Key.P, True, False, True);
	
	NewCommands.Insert("SwitchToPreviewMode", Command.Name);
	
	// Команда полужирного начертания шрифта
	Command = Form.Commands.Add("MarkdownEditorCommand_SetBoldFont");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.MarkdownBold;
	Command.Representation = ButtonRepresentation.Picture;
	Command.ToolTip        = NStr("en = 'Bold'");
	Command.Shortcut       = New Shortcut(Key.B, True, False, True);
	
	NewCommands.Insert("SetBoldFont", Command.Name);
	
	// Команда курсивного начертания шрифта
	Command = Form.Commands.Add("MarkdownEditorCommand_SetItalicFont");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.MarkdownItalic;
	Command.Representation = ButtonRepresentation.Picture;
	Command.ToolTip        = NStr("en = 'Italic'");
	Command.Shortcut       = New Shortcut(Key.I, True, False, True);
	
	NewCommands.Insert("SetItalicFont", Command.Name);
	
	// Команда зачеркнутого начертания шрифта
	Command = Form.Commands.Add("MarkdownEditorCommand_SetStrikethroughFont");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.MarkdownStrikethrough;
	Command.Representation = ButtonRepresentation.Picture;
	Command.ToolTip        = NStr("en = 'Strikethrough'");
	Command.Shortcut       = New Shortcut(Key.S, True, False, True);
	
	NewCommands.Insert("SetStrikethroughFont", Command.Name);
	
	// Команда добавления ненумерованного списка
	Command = Form.Commands.Add("MarkdownEditorCommand_InsertBulletList");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.MarkdownBulletList;
	Command.Representation = ButtonRepresentation.Picture;
	Command.ToolTip        = NStr("en = 'Bullet list'");
	
	NewCommands.Insert("InsertBulletList", Command.Name);
	
	// Команда добавления нумерованного списка
	Command = Form.Commands.Add("MarkdownEditorCommand_InsertNumberedList");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.MarkdownNumberedList;
	Command.Representation = ButtonRepresentation.Picture;
	Command.ToolTip        = NStr("en = 'Numbered list'");
	
	NewCommands.Insert("InsertNumberedList", Command.Name);
	
	// Команда добавления ссылки
	Command = Form.Commands.Add("MarkdownEditorCommand_InsertLink");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.MarkdownLink;
	Command.Representation = ButtonRepresentation.Picture;
	Command.ToolTip        = NStr("en = 'Insert link'");
	
	NewCommands.Insert("InsertLink", Command.Name);
	
	// Команда добавления блока кода
	Command = Form.Commands.Add("MarkdownEditorCommand_InsertCodeBlock");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.MarkdownCodeBlock;
	Command.Representation = ButtonRepresentation.Picture;
	Command.ToolTip        = NStr("en = 'Insert code block'");
	
	NewCommands.Insert("InsertCodeBlock", Command.Name);
	
	// Команда добавления изображения
	Command = Form.Commands.Add("MarkdownEditorCommand_InsertImage");
	Command.Action         = "Attachable_MarkdownEditorExecCommand";
	Command.Picture        = PictureLib.MarkdownImage;
	Command.Representation = ButtonRepresentation.Picture;
	Command.ToolTip        = NStr("en = 'Insert image'");
	
	NewCommands.Insert("InsertImage", Command.Name);	
	
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции создания элементов формы редактора

// Создает элементы формы интерфейса редактора.
//
// Параметры:
//  Form       - ManagedForm - форма, для которой создается редактор.
//  OwnerGroup - FormGroup - группа элементов формы, внутри которой будет создан редактор.
//  Commands   - Structure - структура со свойствами команд для редактора.
//
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
	ModeButtonsGroup.Representation = ButtonGroupRepresentation.Compact;
	
	// Кнопка включения режима "Редактор"
	EditorModeButton = Items.Add("MarkdownEditorItem_EditorModeButton", Type("FormButton"),
		ModeButtonsGroup);

	EditorModeButton.CommandName = Commands.SwitchToEditorMode;
	
	// Кнопка включения режима "Просмотр"
	ViewModeButton = Items.Add("MarkdownEditorItem_ViewModeButton", Type("FormButton"),
		ModeButtonsGroup);
		
	ViewModeButton.CommandName = Commands.SwitchToViewMode;

	// Кнопка включения режима "Редактор + предпросмотр"
	PreviewModeButton = Items.Add("MarkdownEditorItem_PreviewModeButton", Type("FormButton"),
		ModeButtonsGroup);

	PreviewModeButton.CommandName = Commands.SwitchToPreviewMode;

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

#Region ГруппаКнопокСписков

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
	
	InsertCodeBlockButton = Items.Add("MarkdownEditorItem_InsertImage", Type("FormButton"),
		InsertButtonsGroup);
		
	InsertCodeBlockButton.CommandName = Commands.InsertImage;	

#EndRegion

#Region РедакторТекста

	// Создание общей группы, на которой будут размещены все элементы редактора
	EditorViewerGroup = Items.Add("MarkdownEditorItem_EditorViewer", Type("FormGroup"), MainGroup);
	EditorViewerGroup.Type      = FormGroupType.UsualGroup;
	EditorViewerGroup.Group     = ChildFormItemsGroup.Horizontal;
	EditorViewerGroup.ShowTitle = False;

	// Создание текстового поля для редактирования простого текста
	EditorTextField = Items.Add("MarkdownEditorItem_EditorField", Type("FormField"),
		EditorViewerGroup);
		
	EditorTextField.DataPath = "MarkdownEditorAttribute_Text";
	EditorTextField.Type = FormFieldType.InputField;
	
	EditorTextField.AutoMaxWidth = False;
	EditorTextField.AutoMaxHeight = False;	
	EditorTextField.MultiLine = True;
	EditorTextField.TitleLocation = FormItemTitleLocation.None;
	EditorTextField.ExtendedEdit = True;
	EditorTextField.HorizontalStretch = True;
	EditorTextField.VerticalStretch = True;
	EditorTextField.EditTextUpdate = EditTextUpdate.OnValueChange;
	
	EditorTextField.SetAction("EditTextChange", "Attachable_MarkdownEditorOnEditTextChange");

#EndRegion

#Region MarkdownViewer

	// Создание поля HTML-документа для просмотра результата
	HTMLViewerField = Items.Add("MarkdownEditorItem_HTMLViewerField", Type("FormField"), 
		EditorViewerGroup);
	
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

// Устанавливает настройки и параметры редактора значениями по умолчанию.
//
// Параметры:
//  Form      - ManagedForm - форма-владелец редактора.
//  DefParams - Structure - структура со значениями параметров.
// 
Procedure SetDefaultParameters(Form, Val DefParams = Undefined)

	If DefParams = Undefined Then
		DefParams = New Structure;
		DefParams.Insert("MarkdownEditorAttribute_EditMode", 0);
		DefParams.Insert("EditorModeCheckedButton", "MarkdownEditorItem_EditorModeButton");
	EndIf;

	// Установка значений реквизитов формы
	Form.MarkdownEditorAttribute_EditMode = DefParams.MarkdownEditorAttribute_EditMode;

	// Установка свойств элементов формы
	If DefParams.MarkdownEditorAttribute_EditMode = 0 Then
		Form.Items.MarkdownEditorItem_EditorModeButton.Check = True;
		Form.Items.MarkdownEditorItem_EditorField.Visible = True;
		Form.Items.MarkdownEditorItem_HTMLViewerField.Visible = False;
	
	ElsIf DefParams.MarkdownEditorAttribute_EditMode = 1 Then
		Form.Items.MarkdownEditorItem_ViewModeButton.Check = True;
		Form.Items.MarkdownEditorItem_EditorField.Visible = False;
		Form.Items.MarkdownEditorItem_HTMLViewerField.Visible = True;

	ElsIf DefParams.MarkdownEditorAttribute_EditMode = 2 Then
		Form.Items.MarkdownEditorItem_PreviewModeButton.Check = True;
		Form.Items.MarkdownEditorItem_EditorField.Visible = True;
		Form.Items.MarkdownEditorItem_HTMLViewerField.Visible = True;
	EndIf;

EndProcedure

#EndRegion